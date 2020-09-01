'''Defines the `HugoWebsiteInfo` provider.
'''

_HUGO_WEBSITE_INFO_DOC_STRINGS = {
# TODO(dwtj): Write a doc string describing this provider.
"PROVIDER":
'''
''',

"OUTPUT_DIR_FIELD":
'''A `File` pointing to the output directory created by this rule.
''',
}

HugoWebsiteInfo = provider(
    doc = _HUGO_WEBSITE_INFO_DOC_STRINGS["PROVIDER"],
    fields = {
        "output_dir": _HUGO_WEBSITE_INFO_DOC_STRINGS["OUTPUT_DIR_FIELD"],
    }
)
