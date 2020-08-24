'''Some macros to help fetch & config some dependencies used in test workspaces.
'''

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# This version was chosen because it was the latest as of 2020-07-06.
_DWTJ_RULES_MARKDOWN_COMMIT = "c555fe9dca1782c123ec8eda1fdba11345e9e5e7"
_DWTJ_RULES_MARKDOWN_SHA256 = "f5ed694d7a3998e68f2d3648263e59d8dfd5a815f985909c343a94f6c534ed10"

def fetch_dwtj_rules_markdown():
    http_archive(
        name = "dwtj_rules_markdown",
        sha256 = _DWTJ_RULES_MARKDOWN_SHA256,
        strip_prefix = "dwtj_rules_markdown-{}".format(_DWTJ_RULES_MARKDOWN_COMMIT),
        url = "https://github.com/dwtj/dwtj_rules_markdown/archive/{}.zip".format(_DWTJ_RULES_MARKDOWN_COMMIT),
    )
    