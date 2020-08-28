load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")

hugo_website(
    name = "my_website",
    srcs = [
        "config.toml",
        "layouts/index.html",
        "foo.md",
    ],
)

# Make a markdown file with just an empty front matter.
genrule(
    name = "bazel_generated_content",
    outs = ["foo.md"],
    cmd_bash = 'echo "---\r---\r" > $(RULEDIR)/foo.md'
)

hugo_website(
    name = "my_website_with_bad_src",
    srcs = [
        "config.toml",
        "layouts/index.html",
        "//:foo.md",
    ],
)
