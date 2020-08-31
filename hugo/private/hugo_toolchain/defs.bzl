'''Defines the `hugo_toolchain`.
'''

load("//hugo:private/common/providers/HugoToolchainInfo.bzl", "HugoToolchainInfo")

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
