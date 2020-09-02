load("@rules_pkg//:pkg.bzl", "pkg_tar")
load(
    "@dwtj_rules_hugo//hugo:defs.bzl",
    "hugo_website",
    "hugo_library",
)
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//bazel:hugo_library_of_all_stardoc.bzl", "hugo_library_of_all_stardoc")

alias(
    name = "site",
    actual = ":gh_pages_website",
)

pkg_tar(
    name = "gh_pages_archive",
    srcs = [":gh_pages_website"],
    strip_prefix = "gh_pages_website",
    package_dir = "docs",
)

hugo_website(
    name = "gh_pages_website",
    srcs = ["config.toml"],
    deps = [
        "gh_pages_theme",
        ":all_stardoc_content",
    ],
)

hugo_library(
    name = "gh_pages_theme",
    srcs = glob([
        "assets/sass/*",
        "layouts/**/*"
    ]),
    # NOTE(dwtj): This theme is public so that it can be used in my other Bazel
    #  rules projects.
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "all_bzl",
    srcs = ["@dwtj_rules_hugo//hugo:all_bzl_files_in_project"]
)

hugo_library_of_all_stardoc(
    name = "all_stardoc_content",
    all_bzl = ":all_bzl",
)
