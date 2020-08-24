'''Defines the `local_hugo_repository` repository rule.
'''

_HUGO_SYMLINK_NAME = "hugo"

def _local_hugo_repository_impl(repository_ctx):
    hugo_path = repository_ctx.which('hugo')
    if hugo_path == None:
        fail("Failed to find a `hugo` executable on the system `PATH`. Could not initialize `local_hugo_repository` `{}`".format(repository_ctx.name))

    repository_ctx.symlink(hugo_path, _HUGO_SYMLINK_NAME)

    repository_ctx.template(
        "BUILD",
        repository_ctx.attr._build_file_template,
        substitutions = {
            "{REPOSITORY_NAME}": repository_ctx.name,
            "{RULES_HUGO_REPOSITORY_NAME}": "dwtj_rules_hugo",
            "{HUGO_LABEL}": ":" + _HUGO_SYMLINK_NAME,
        },
        executable = False,
    )

    repository_ctx.template(
        "defs.bzl",
        repository_ctx.attr._defs_bzl_file_template,
        substitutions = {
            "{REPOSITORY_NAME}": repository_ctx.name,
            "{RULES_HUGO_REPOSITORY_NAME}": "dwtj_rules_hugo"
        },
        executable = False,
    )

    # TODO(dwtj): Figure out how the return value ought to be set.
    return None

local_hugo_repository = repository_rule(
    doc = "Searches the system `PATH` for a `hugo` executable. If it is not found, then this rule fails. If it is found, then this executable is symlinked into the root of this external repository. Additionally, a `hugo_toolchain` (labeled `//:hugo_toolchain`) is synthesized in the root package of this external repository to wrap this executable symlink. This toolchain can be registered with the helper macro `//:defs.bzl%register_hugo_toolchain`.",
    attrs = {
        "_build_file_template": attr.label(
            default = Label("@dwtj_rules_hugo//hugo:private/local_hugo_repository/TEMPLATE.BUILD"),
            allow_single_file = True,
        ),
        "_defs_bzl_file_template": attr.label(
            default = Label("@dwtj_rules_hugo//hugo:private/local_hugo_repository/TEMPLATE.defs.bzl"),
            allow_single_file = True,
        ),
    },
    implementation = _local_hugo_repository_impl,
    environ = [
        # This rule is sensitive to changes to `PATH` because it searches `PATH`
        # to find a `hugo` executable.
        "PATH",
    ],
    local = True,
)
