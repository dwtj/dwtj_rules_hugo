# This file was instantiated from a template with the following substitutions:
#
# - REPOSITORY_NAME: {REPOSITORY_NAME}
# - RULES_HUGO_REPOSITORY_NAME: {RULES_HUGO_REPOSITORY_NAME}
# - HUGO_LABEL: {HUGO_LABEL}

load("@{RULES_HUGO_REPOSITORY_NAME}//hugo/toolchains/hugo_toolchain:defs.bzl", "hugo_toolchain")

hugo_toolchain(
    name = "_hugo_toolchain",
    hugo = "{HUGO_LABEL}",
)

toolchain(
    name = "hugo_toolchain",
    toolchain = ":_hugo_toolchain",
    toolchain_type = "@{RULES_HUGO_REPOSITORY_NAME}//hugo/toolchains/hugo_toolchain:toolchain_type",
    visibility = ["//visibility:public"],
)
