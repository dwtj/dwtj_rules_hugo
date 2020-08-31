exports_files(glob([
    # TODO(dwtj): Figure out how to move these templates out of the glob to
    #  adhere to the `buildifier` lint warning.
    "private/hugo_website/TEMPLATE.run_hugo_build.sh",
    "private/hugo_website/TEMPLATE.run_hugo_server.sh",
    # NOTE(dwtj): We export all `bzl` files in this package so that the
    #  website can wrap these files in `bzl_library` targets and pass them
    #  to `stardoc`. We don't want to declare `bzl_library` targets and
    #  `stardoc` targets in this package, because then all users of these
    #  rules would also depend upon the `bazel-skylib` and `stardoc`
    #  external repositories.
    "**/*.bzl",
]))

filegroup(
    name = "all_bzl_files_in_project",
    srcs = glob(["**/*.bzl"]),
    # TODO(dwtj): These files are probably only needed for the website. Can we
    #  make visibility narrow even though the website is in an external
    #  repository?
    visibility = ["//visibility:public"]
)
