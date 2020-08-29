'''Defines the `hugo_toolchain:toolchain_type`.
'''

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

exports_files([
    # NOTE(dwtj): We export the `bzl` file in this package so that the website
    #  can use it in `stardoc` rules. See `//hugo:BUILD` for more info.
    "defs.bzl"
])
