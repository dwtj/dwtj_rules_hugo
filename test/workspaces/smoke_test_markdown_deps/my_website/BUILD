load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")
load("@dwtj_rules_markdown//markdown:defs.bzl", "markdown_library")

hugo_website(
    name = "my_website",
    srcs = [
        "content/hello.md",
        "config.yml",
    ],
)

markdown_library(
    name = "hello",
    srcs = ["content/hello.md"],
)
