load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")
load("//bazel:hugo_import_stardoc.bzl", "hugo_import_stardoc")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

alias(
    name = "site",
    actual = ":dwtj_rules_hugo_github_io",
)

hugo_website(
    name = "dwtj_rules_hugo_github_io",
    srcs = glob(
        include = [
            "config.toml",
            "assets/**/*",
            "layouts/**/*",
        ],
        exclude = [
            "WORKSPACE",
            "BUILD",
            "bazel",
            "bazel-bin",
            "bazel-out",
            "bazel-testlogs",
            "bazel-website",
            "bazel-dwtj_rules_hugo_github_io",
        ],
    ),
    deps = [
        ":defs",
    ],
)

bzl_library(
    name = "all_bzl",
    srcs = [
        "@dwtj_rules_hugo//hugo:all_bzl_files_in_project",
    ]
)

hugo_import_stardoc(
    name = "defs",
    hugo_path = "content/defs.md",
    stardoc_input = "@dwtj_rules_hugo//hugo:defs.bzl",
    bzl_deps = [":all_bzl"],
)
