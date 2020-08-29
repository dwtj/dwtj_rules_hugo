'''Defines the `hugo_toolchain` rule. It is used to make toolchain instances.
'''

# TODO(dwtj): Consider moving these definitions into the `//hugo` package so
#  that all Starlark definitions in this project will be in that package.

HugoToolchainInfo = provider(
    fields = {
        "hugo_exec": "A `File` pointing to a `hugo` executable (in the host configuration)."
    }
)

def _hugo_toolchain_impl(toolchain_ctx):
    toolchain_info = platform_common.ToolchainInfo(
        hugo_toolchain_info = HugoToolchainInfo(
            hugo_exec = toolchain_ctx.file.hugo,
        ),
    )
    return [toolchain_info]

hugo_toolchain = rule(
    implementation = _hugo_toolchain_impl,
    attrs = {
        "hugo": attr.label(
            doc = "The `hugo` executable (in the host configuration) to use to build Hugo websites.",
            allow_single_file = True,
            executable = True,
            cfg = "host",
        ),
    },
)
