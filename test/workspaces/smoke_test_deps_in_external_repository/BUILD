load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")

hugo_website(
    name = "my_website",
    srcs = ["content/baz.md"],
    deps = [
        "@my_external_repository//:import_in_root_pkg",
        "@my_external_repository//:library_in_root_pkg",
        "@my_external_repository//my_website:four_imports",
    ],
)
