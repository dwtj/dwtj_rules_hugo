load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")
load("@dwtj_rules_markdown//markdown:defs.bzl", "markdown_library")

hugo_website(
    name = "my_website",
    srcs = ["index.md"],
    config = "config.yml",
)

markdown_library(
    name = "some_markdown",
    srcs = [
        "index.md",
    ],
)
