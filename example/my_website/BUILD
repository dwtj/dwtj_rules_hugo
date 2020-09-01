load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

hugo_website(
    name = "my_website",
    srcs = glob(["**/*"]),
)

pkg_tar(
    name = "my_website_archive",
    srcs = [":my_website"],
)
