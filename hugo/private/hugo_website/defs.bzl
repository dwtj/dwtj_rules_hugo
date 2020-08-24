'''Defines the `hugo_website` rule.
'''

HugoWebsiteInfo = provider(
    fields = {
        "srcs": "A `depset` of `File`s pointing to all of the source files that should be provided to `hugo`.",
        "website_archive": "A `File` pointing to the output website archive built by this rule.",
    }
)

_HUGO_TOOLCHAIN_TYPE = "@dwtj_rules_hugo//hugo/toolchains/hugo_toolchain:toolchain_type"

def _build_script_name(ctx):
    return ctx.attr.name + ".build.sh"

def _website_archive_name(ctx):
    return ctx.attr.name + ".tar.gz"

def _build_dir_name(ctx):
    return ctx.attr.name + ".hugo_website"

def _extract_hugo_exec(ctx):
    return ctx.toolchains[_HUGO_TOOLCHAIN_TYPE] \
              .hugo_toolchain_info \
              .hugo_exec

def _hugo_website_impl(ctx):
    # Extract some information from the env for brevity.
    hugo_exec = _extract_hugo_exec(ctx)
    srcs = depset(direct = ctx.files.srcs)
    config_file = ctx.file.config

    # Declare some temporaries.
    build_script = ctx.actions.declare_file(_build_script_name(ctx))
    build_dir = ctx.actions.declare_directory(_build_dir_name(ctx))

    # Declare the output.
    website_archive = ctx.actions.declare_file(_website_archive_name(ctx))

    ctx.actions.expand_template(
        template = ctx.file._run_hugo_build_script_template,
        output = build_script,
        substitutions = {
            "{HUGO_EXEC}": hugo_exec.path,
            "{CONFIG_FILE}": config_file.path,
            "{WEBSITE_BUILD_DIR}": build_dir.path, 
            "{WEBSITE_ARCHIVE}": website_archive.path,
        },
    )

    ctx.actions.run(
        executable = build_script,
        inputs = depset(
            direct = [
                hugo_exec,
                config_file,
            ],
            transitive = [
                srcs,
            ]
        ),
        outputs = [
            website_archive,
            build_dir,
        ],
        mnemonic = "HugoBuild",
        progress_message = "Building and archiving Hugo website `{}`".format(ctx.label),
    )

    return [
        DefaultInfo(files = depset([website_archive])),
        HugoWebsiteInfo(
            srcs = srcs,
            website_archive = website_archive,
        )
    ]

hugo_website = rule(
    implementation = _hugo_website_impl,
    toolchains = [_HUGO_TOOLCHAIN_TYPE],
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
        ),
        "config": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "_run_hugo_build_script_template": attr.label(
            default = Label("@dwtj_rules_hugo//hugo:private/hugo_website/TEMPLATE.run_hugo_build.sh"),
            allow_single_file = True,
        ),
    }
)
