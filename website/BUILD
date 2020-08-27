load("//hugo:defs.bzl", "hugo_website")

alias(
    name = "website",
    actual = ":dwtj_rules_hugo_github_io",
)

hugo_website(
    name = "dwtj_rules_hugo_github_io",
    srcs = glob(
        include = ["**/*"],
        exclude = ["BUILD"],
    ),
)
