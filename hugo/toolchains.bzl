'''This exports all public toolchain rules in this project.
'''

load("//hugo/toolchains/hugo_toolchain:defs.bzl", _hugo_toolchain = "hugo_toolchain")

hugo_toolchain = _hugo_toolchain
