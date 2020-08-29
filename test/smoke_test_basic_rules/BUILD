# This defines some very basic Hugo targets for use in testing and debugging.
# More thorough tests are available in the various test workpsaces under
# `//test/workspaces`.
#
# NOTE(dwtj): I have found that having a few tests here in the main workspace
# (rather than in some separate test workspace) is useful for debugging.
# Specifically, I have had trouble getting my VS Code Starlark debugger work
# across multiple workspaces (though, I haven't tried very hard).

load(
    "//hugo:defs.bzl",
    "hugo_website",
    "hugo_library",
    "hugo_import",
)

hugo_website(
    name = "my_hugo_website",
    srcs = ["config.toml"],
    deps = [
        ":my_hugo_import",
    ]
)

hugo_library(
    name = "my_hugo_library",
    srcs = ["content/some_content.md"],
)

hugo_import(
    name = "my_hugo_import",
    src = "content.md",
    path = "content/content.md",
)
