load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//bazel:hugo_library_of_all_stardoc.bzl", "hugo_library_of_all_stardoc")

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
        ":all_stardoc_content",
    ],
)

bzl_library(
    name = "all_bzl",
    srcs = ["@dwtj_rules_hugo//hugo:all_bzl_files_in_project"]
)

hugo_library_of_all_stardoc(
    name = "all_stardoc_content",
    all_bzl = ":all_bzl",
)
