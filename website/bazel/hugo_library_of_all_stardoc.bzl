'''Defines the `hugo_library_of_all_stardoc` macro.
'''

load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_library")
load("//bazel:hugo_import_stardoc.bzl", "hugo_import_stardoc")

_ALL_STARDOC_IMPORTS = {
    "@dwtj_rules_hugo//hugo:private/common/providers/HugoSourcesInfo.bzl": "HugoSourcesInfo",
    "@dwtj_rules_hugo//hugo:private/common/providers/HugoWebsiteInfo.bzl": "HugoWebsiteInfo",
    "@dwtj_rules_hugo//hugo:private/common/providers/HugoToolchainInfo.bzl": "HugoToolchainInfo",
    "@dwtj_rules_hugo//hugo:private/hugo_import/defs.bzl": "hugo_import",
    "@dwtj_rules_hugo//hugo:private/hugo_library/defs.bzl": "hugo_library",
    "@dwtj_rules_hugo//hugo:private/hugo_toolchain/defs.bzl": "hugo_toolchain",
    "@dwtj_rules_hugo//hugo:private/hugo_website/defs.bzl": "hugo_website",
    "@dwtj_rules_hugo//hugo:private/local_hugo_repository/defs.bzl": "local_hugo_repository",
}

def hugo_library_of_all_stardoc(name, all_bzl):
    '''Create a `hugo_library` which wraps all of the indicated stardoc content.

    Args:
      name: The name of the created `hugo_library`.
      all_bzl: The label of a `bzl_library` target which includes all bzl deps.
    Returns:
      `None`
    '''

    for (in_file_label, content_name) in _ALL_STARDOC_IMPORTS.items():
        hugo_import_stardoc(
            name = content_name,
            hugo_path = "content/" + content_name + ".md",
            stardoc_input = in_file_label,
            bzl_deps = [all_bzl],
        )

    all_hugo_imports = _ALL_STARDOC_IMPORTS.values()
    hugo_library(
        name = name,
        deps = all_hugo_imports,
    )
