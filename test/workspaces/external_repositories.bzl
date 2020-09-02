'''Some macros to help fetch & config some dependencies used in test workspaces.
'''

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# This version was chosen because it was the latest as of 2020-09-02.
_DWTJ_RULES_MARKDOWN_COMMIT = "b32ad69255e8e81a1528f9b7a6d60c1bd9055950"
_DWTJ_RULES_MARKDOWN_SHA256 = "93a4affec2a1b66a38033af9385c3b9b749357218799b43d82428e0a9fd761dc"

def fetch_dwtj_rules_markdown():
    http_archive(
        name = "dwtj_rules_markdown",
        sha256 = _DWTJ_RULES_MARKDOWN_SHA256,
        strip_prefix = "dwtj_rules_markdown-{}".format(_DWTJ_RULES_MARKDOWN_COMMIT),
        url = "https://github.com/dwtj/dwtj_rules_markdown/archive/{}.zip".format(_DWTJ_RULES_MARKDOWN_COMMIT),
    )
