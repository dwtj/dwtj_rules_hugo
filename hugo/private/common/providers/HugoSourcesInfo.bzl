'''Defines the `HugoSourcesInfo` provider.
'''

_HUGO_SOURCES_INFO_DOC_STRINGS = {
# TODO(dwtj): Write a doc string for the whole provider.
"PROVIDER":
'''
''',

"SRCS_FIELD":
'''A map from strings to `File`s. Each relationship in this map encodes a
Hugo source file and its path relative to a Hugo source root.
'''
}

HugoSourcesInfo = provider(
    doc = _HUGO_SOURCES_INFO_DOC_STRINGS["PROVIDER"],
    fields = {
        "srcs": _HUGO_SOURCES_INFO_DOC_STRINGS["SRCS_FIELD"],
    }
)
