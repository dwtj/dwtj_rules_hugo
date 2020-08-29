'''Defines the `HugoWebsiteInfo` provider.
'''

_HUGO_WEBSITE_INFO_DOC_STRINGS = {
# TODO(dwtj): Write a doc string describing this provider.
"PROVIDER":
'''
''',

"SRCS_ATTR":
'''A `depset` of `File`s pointing to all of the source files. This includes
all of the files which will be included in the source tree provided to the
`hugo` command.
''',

"WEBSITE_ARCHIVE_ATTR":
'''A `File` pointing to the output website archive built by this rule.
''',
}

HugoWebsiteInfo = provider(
    doc = _HUGO_WEBSITE_INFO_DOC_STRINGS["PROVIDER"],
    fields = {
        "srcs": _HUGO_WEBSITE_INFO_DOC_STRINGS["SRCS_ATTR"],
        "website_archive": _HUGO_WEBSITE_INFO_DOC_STRINGS["WEBSITE_ARCHIVE_ATTR"],
    }
)
