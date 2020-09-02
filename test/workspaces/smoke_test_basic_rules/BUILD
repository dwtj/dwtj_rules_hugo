load(
    "@dwtj_rules_hugo//hugo:defs.bzl",
    "hugo_website",
    "hugo_import",
    "hugo_library",
)

package(default_visibility = ["//visibility:public"])

hugo_website(
    name = "website_in_root_pkg",
    srcs = ["//a_different_pkg:some_content.md"],
    deps = [
        ":import_in_root_pkg",
        ":library_in_root_pkg",
    ],
)

_EMPTY_FRONT_MATTER = "+++\n+++"

hugo_import(
    name = "import_in_root_pkg",
    src = "content_in_root_pkg.md",
    path = "content/bar.md",
    add_front_matter = _EMPTY_FRONT_MATTER,
)

hugo_library(
    name = "library_in_root_pkg",
    srcs = ["config.toml"],
)

genrule(
    name = "my_genrule",
    outs = ["config.toml"],
    cmd_bash = '''echo 'baseURL = "http://example.org"' > "$(RULEDIR)/config.toml"'''
)
