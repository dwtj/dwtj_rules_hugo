'''Defines the `hugo_website` rule.
'''

load("//hugo:private/hugo_import/defs.bzl", "HugoImportInfo")

HugoWebsiteInfo = provider(
    fields = {
        "srcs": "A `depset` of `File`s pointing to all of the source files. This includes all of the files which will be included in the source tree provided to the `hugo` command.",
        "website_archive": "A `File` pointing to the output website archive built by this rule.",
    }
)

_HUGO_TOOLCHAIN_TYPE = "@dwtj_rules_hugo//hugo/toolchains/hugo_toolchain:toolchain_type"

def _build_script_name(ctx):
    return ctx.attr.name + ".hugo_build.sh"

def _server_script_name(ctx):
    return ctx.attr.name + ".hugo_server.sh"

def _website_archive_name(ctx):
    return ctx.attr.name + ".tar.gz"

def _extract_hugo_exec(ctx):
    return ctx.toolchains[_HUGO_TOOLCHAIN_TYPE] \
              .hugo_toolchain_info \
              .hugo_exec

def _hugo_src_dir_name(ctx):
    return "{}.hugo_website".format(ctx.attr.name)

# NOTE(dwtj): Here are the high-level steps involved in this rule impl:
#
# 1. Check that all of the `srcs` files are in the same package as this
#    `hugo_website` or in one of its subpackages.
# 2. Declare and create a Hugo source directory.  This is the directory which
#    will be passed to the `hugo` command's `--source` flag. This might also be
#    thought of as the Hugo build directory. Hugo will only "see" the files
#    placed under this directory.
# 3. We "place" all `srcs` files under this directory using symlinks. Their
#    location relative to the Hugo source tree is the same as the Bazel source
#    file's location relative to the package which declared this `hugo_website`.
# 4. We instantiate and run a script which executes `hugo` and `tar`s its
#    output.
# 5. We instantiate a script which executes `hugo server`
#
# Constructing this intermediary Hugo source directory may seem unnecessary.
# After all, why not just use the `hugo_website` rules's package as a the Hugo
# source directory. The problem with this is that some files in `srcs` may not
# be Bazel source files. Files which in this package but are *built* by Bazel,
# will be located over in a different root within `execroot` (e.g.
# `bazel-out/k8-fastbuild/bin`).
def _hugo_website_impl(ctx):
    # Extract some information from the env for brevity.
    hugo_exec = _extract_hugo_exec(ctx)
    srcs = depset(direct = ctx.files.srcs)
    hugo_website_package = ctx.label.package
    hugo_src_dir_name = _hugo_src_dir_name(ctx)

    # Add all `srcs` as symlinks under `hugo_src_dir`. We need to find where
    #  within this directory each source needs to be placed. To find this, we
    #  need to drop a `File` path's root and the directories up to this rule's
    #  package.
    symlinks = []
    for src in ctx.files.srcs:
        # Check that this `srcs` file is in the expected package.
        #
        # NOTE(dwtj): Here's some background that I learned about [`File`][1].
        #  If an input `File` is in the Bazel source tree (i.e. if `is_source`
        #  is true) then it should have the empty string as its `root`. However,
        #  if it is a Bazel-generated file, it should have a non-empty `root`,
        #  e.g., `bazel-out/k8-fastbuild/bin`. Here, we want to check that a
        #  `srcs` file is somewhere under the expected package. Regardless of
        #  which `root` the file is in, we can use `short_path` to drop the root
        #  and then just check its prefix.
        #  
        #  ---
        #
        #  1: https://docs.bazel.build/versions/3.4.0/skylark/lib/File.html
        if not str(src.short_path).startswith(hugo_website_package):
            fail("A `hugo_website` source file is outside of package `{}`.".format(hugo_website_package))

        # We drop the file's root by using `short_path`, and we drop the package
        #  in which this `hugo_website` instance is defined with a string slice.
        hugo_relative_path = src.short_path[len(hugo_website_package):]

        # Declare and create the symlink to `src`.
        path = "{}/{}".format(hugo_src_dir_name, hugo_relative_path)
        symlink = ctx.actions.declare_file(path)
        ctx.actions.symlink(
            output = symlink,
            target_file = src,
            progress_message = "Symlinking `{}` into Hugo source directory of `hugo_website` labeled `{}`".format(src, ctx.label),
        )
        symlinks.append(symlink)

    # Now include all srcs from deps as symlinks within the Hugo src directory.
    # TODO(dwtj): Make sure that Bazel actually creates an error if one file
    #  clobbers another.
    # TODO(dwtj): Consider making a friendlier error message if one file
    #  clobbers another. 
    for dep in ctx.attr.deps:
        src_file = dep[HugoImportInfo].src
        path = dep[HugoImportInfo].path

        # Symlink the file within the Hugo source directory. (Note that declared
        # files are relative to the this package.)
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

    # Declare the output archive.
    website_archive = ctx.actions.declare_file(_website_archive_name(ctx))

    # Declare, write, and run the build script.
    build_script = ctx.actions.declare_file(_build_script_name(ctx))
    ctx.actions.expand_template(
        template = ctx.file._run_hugo_build_script_template,
        output = build_script,
        substitutions = {
            "{HUGO_EXEC}": hugo_exec.path,
            # TODO(dwtj): This use of `build_script.dirname` is an ugly hack.
            "{HUGO_SOURCE_DIR}": "{}/{}".format(build_script.dirname, hugo_src_dir_name),
            "{WEBSITE_ARCHIVE}": website_archive.path,
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
            website_archive,
        ],
        mnemonic = "HugoWebsiteBuild",
        progress_message = "Building and archiving Hugo website `{}`".format(ctx.label),
    )

    # Declare and write the server scipt.
    server_script = ctx.actions.declare_file(_server_script_name(ctx))
    ctx.actions.expand_template(
        template = ctx.file._run_hugo_server_script_template,
        output = server_script,
        substitutions = {
            "{HUGO_EXEC}": hugo_exec.path,
            # TODO(dwtj): The way `HUGO_SOURCE_DIR` is set feels like a hack.
            "{HUGO_SOURCE_DIR}": "{}/{}".format(ctx.label.package, hugo_src_dir_name),
        }
    )

    return [
        DefaultInfo(
            files = depset([website_archive]),
            executable = server_script,
            runfiles = ctx.runfiles(
                files = [
                    hugo_exec,
                ],
                transitive_files = symlinks,
            ),
        ),
        HugoWebsiteInfo(
            srcs = srcs,
            website_archive = website_archive,
        )
    ]

hugo_website = rule(
    doc = "A simple rule which builds a Hugo website with the `hugo` command and then archives the output with `tar`. A `hugo_website`'s Bazel package is taken to be the Hugo website's root directory. This means that the Bazel `BUILD` file declaring the `hugo_website` should be a siblings of its Hugo top-level files & directories, e.g., `config.toml`, `content/`, `layouts/`, etc.",
    implementation = _hugo_website_impl,
    toolchains = [_HUGO_TOOLCHAIN_TYPE],
    provides = [HugoWebsiteInfo],
    attrs = {
        "srcs": attr.label_list(
            doc = "A list of files to be included in the website. Be aware that the rule will fail if a source file given here is located outside of this `hugo_website`'s package or subpackages. A `glob()` expression may be an appropriate value for this attribute, but be aware that Bazel `glob`s do not reach into Bazel subpackages.",
            allow_files = True,
            allow_empty = False,
        ),
        "deps": attr.label_list(
            allow_files = False,
            providers = [HugoImportInfo],
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
