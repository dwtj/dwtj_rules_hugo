'''Defines the `hugo_website` rule.
'''

load("//hugo:private/common/paths.bzl", "package_relative_path")
load("//hugo:private/common/providers/HugoSourcesInfo.bzl", "HugoSourcesInfo")
load("//hugo:private/common/providers/HugoWebsiteInfo.bzl", "HugoWebsiteInfo")

_HUGO_TOOLCHAIN_TYPE = "@dwtj_rules_hugo//hugo/toolchains/hugo_toolchain:toolchain_type"

_HUGO_WEBSITE_DOC_STRINGS = {
"RULE":
'''A simple rule which builds a Hugo website with the `hugo` command. The output
directory is named the same as the rule's name attribute.

A `hugo_website`'s Bazel package is taken to be the Hugo website's root
directory. This means that the Bazel `BUILD` file declaring the `hugo_website`
should be a siblings of its Hugo top-level files & directories (e.g.,
`config.toml`, `content/`, `layouts/`, etc).
''',

"SRCS_ATTR":
'''A list of files to be included in the website.

Be aware that the rule will fail if a source file given here is located
outside of this `hugo_website`'s package or subpackages.

A `glob()` expression may be an appropriate value for this attribute, but be
aware that Bazel `glob`s do not reach into Bazel subpackages.
''',

"DEPS_ATTR":
'''A list of targets providing `HugoSourcesInfo` (e.g. `hugo_library`s and
`hugo_import`s) whose sources should be included in this `hugo_website`.
''',
}

def _build_script_name(ctx):
    return ctx.attr.name + ".hugo_build.sh"

def _server_script_name(ctx):
    return ctx.attr.name + ".hugo_server.sh"

# NOTE(dwtj): WARNING: There is currently a hack in Hugo build script which
#  only works if the output directory and the source directory are siblings.
# TODO(dwtj): Consider making that logic more robust.
def _hugo_output_dir_name(ctx):
    return ctx.attr.name

def _hugo_src_dir_name(ctx):
    return ctx.attr.name + ".hugo_source"

def _extract_hugo_exec(ctx):
    return ctx.toolchains[_HUGO_TOOLCHAIN_TYPE] \
              .hugo_toolchain_info \
              .hugo_exec

# NOTE(dwtj): Here are the high-level steps involved in this rule impl:
#
#  1. Check that all of the `srcs` files are in the same package as this
#     `hugo_website` or in one of its subpackages.
#  2. Declare and create a Hugo source directory.  This is the directory which
#     will be passed to the `hugo` command's `--source` flag. This might also be
#     thought of as the Hugo build directory. Hugo will only "see" the files
#     placed under this directory.
#  3. We "place" all `srcs` files under this directory using symlinks. Their
#     location relative to the Hugo source tree is the same as the Bazel source
#     file's location relative to the package which declared this `hugo_website`.
#  4. We also "place" all source files in `deps` under this directory using
#     symlinks.
#  5. We instantiate and run a script which executes `hugo` to build the output
#     directory.
#  6. We instantiate a script which executes `hugo server`
#
#  Constructing this intermediary Hugo source directory may seem unnecessary.
#  After all, why not just use the `hugo_website` rules's package as a the Hugo
#  source directory. The problem with this is that some files in `srcs` may not
#  be Bazel source files. Files which are in this package but are *built* by
#  Bazel will be located over in a different root under `execroot` (e.g.
#  `<execroot>/bazel-out/k8-fastbuild/bin`).
def _hugo_website_impl(ctx):
    # Extract some information from the env for brevity.
    hugo_exec = _extract_hugo_exec(ctx)
    srcs = depset(direct = ctx.files.srcs)
    hugo_website_package = ctx.label.package
    hugo_src_dir_name = _hugo_src_dir_name(ctx)

    # Add all `srcs` as symlinks under `hugo_src_dir`. We use the
    #  `package_relative_path()` helper function to find where each source file
    #  needs to be placed within the Hugo source tree.
    symlinks = []
    for src in ctx.files.srcs:
        pkg_relative_path = package_relative_path(ctx, src)
        if pkg_relative_path == None:
            fail("While analyzing a `hugo_website` target labeled `{}`, found a source file which isn't in this package or one of its subpackages: `{}`.".format(ctx.label, src.path))

        # Declare and create the symlink to `src`.
        hugo_src_path = "{}/{}".format(hugo_src_dir_name, pkg_relative_path)
        symlink = ctx.actions.declare_file(hugo_src_path)
        ctx.actions.symlink(
            output = symlink,
            target_file = src,
            progress_message = "Symlinking `{}` into Hugo source directory of `hugo_website` labeled `{}`".format(src, ctx.label),
            is_executable = False,
        )
        symlinks.append(symlink)

    # Now include all srcs from deps as symlinks within the Hugo src directory.
    # TODO(dwtj): Make sure that Bazel actually creates an error if one file
    #  clobbers another.
    # TODO(dwtj): Consider making a friendlier error message if one file
    #  clobbers another.
    for dep in ctx.attr.deps:
        for (path, src_file) in dep[HugoSourcesInfo].srcs.items():
            # Symlink the file within the Hugo source directory. (Note that
            # declared files are relative to the this package.)
            path = "{}/{}".format(hugo_src_dir_name, path)
            symlink = ctx.actions.declare_file(path)
            ctx.actions.symlink(
                output = symlink,
                target_file = src_file,
                progress_message = "Symlinking `{}` into Hugo source directory of the `hugo_website` labeled `{}`".format(src_file, ctx.label)
            )
            symlinks.append(symlink)

    # Wrap the `symlinks` list in a `depset`.
    symlinks = depset(direct = symlinks)

    # Declare the outputs.
    hugo_output_dir = ctx.actions.declare_directory(_hugo_output_dir_name(ctx))

    # Declare, write, and run the build script.
    build_script = ctx.actions.declare_file(_build_script_name(ctx))
    ctx.actions.expand_template(
        template = ctx.file._run_hugo_build_script_template,
        output = build_script,
        substitutions = {
            "{HUGO_EXEC}": hugo_exec.path,
            # TODO(dwtj): This use of `build_script.dirname` is an ugly hack.
            "{HUGO_SOURCE_DIR}": "{}/{}".format(build_script.dirname, hugo_src_dir_name),
            "{HUGO_OUTPUT_DIR}": hugo_output_dir.path,
        },
    )
    ctx.actions.run(
        executable = build_script,
        inputs = depset(
            direct = [
                hugo_exec,
            ],
            transitive = [
                symlinks,
            ]
        ),
        outputs = [
            hugo_output_dir,
        ],
        mnemonic = "HugoWebsiteBuild",
        progress_message = "Building Hugo website `{}`".format(ctx.label),
    )

    # Declare and write the server scipt.
    server_script = ctx.actions.declare_file(_server_script_name(ctx))
    # TODO(dwtj): The way `HUGO_SOURCE_DIR` is set (still) feels like a hack.
    hugo_serve_source_dir_path = hugo_src_dir_name \
                                     if ctx.label.package == "" \
                                     else "{}/{}".format(
                                         ctx.label.package,
                                         hugo_src_dir_name
                                     )
    ctx.actions.expand_template(
        template = ctx.file._run_hugo_server_script_template,
        output = server_script,
        substitutions = {
            "{HUGO_EXEC}": hugo_exec.short_path,
            "{HUGO_SOURCE_DIR}": hugo_serve_source_dir_path,
        }
    )

    return [
        DefaultInfo(
            files = depset([
                hugo_output_dir,
            ]),
            executable = server_script,
            runfiles = ctx.runfiles(
                files = [
                    hugo_exec,
                ],
                transitive_files = symlinks,
            ),
        ),
        HugoWebsiteInfo(
            output_dir = hugo_output_dir,
        )
    ]

hugo_website = rule(
    doc = _HUGO_WEBSITE_DOC_STRINGS["RULE"],
    implementation = _hugo_website_impl,
    toolchains = [_HUGO_TOOLCHAIN_TYPE],
    provides = [HugoWebsiteInfo],
    attrs = {
        "srcs": attr.label_list(
            doc = _HUGO_WEBSITE_DOC_STRINGS["SRCS_ATTR"],
            allow_files = True,
            allow_empty = False,
        ),
        "deps": attr.label_list(
            doc = _HUGO_WEBSITE_DOC_STRINGS["DEPS_ATTR"],
            allow_files = False,
            providers = [HugoSourcesInfo],
            allow_empty = True,
            default = list(),
        ),
        "_run_hugo_build_script_template": attr.label(
            default = Label("@dwtj_rules_hugo//hugo:private/hugo_website/TEMPLATE.run_hugo_build.sh"),
            allow_single_file = True,
        ),
        "_run_hugo_server_script_template": attr.label(
            default = Label("@dwtj_rules_hugo//hugo:private/hugo_website/TEMPLATE.run_hugo_server.sh"),
            allow_single_file = True,
        ),
    },
    executable = True,
)
