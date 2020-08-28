'''Defines the `hugo_import` rule.
'''

HugoImportInfo = provider(
    fields = {
        "src": "A `File` to be included in a Hugo website which depends upon this import.",
        "path": "A string encoding the relative path within the Hugo website where this import's `File` should be placed.",
    }
)

def _hugo_import_impl(ctx):
    if len(ctx.attr.path) == 0:
        fail("Illegal attribute value: `hugo_import.path` cannot be set to the empty string.")
    return [
        HugoImportInfo(
            src = ctx.file.src,
            path = ctx.attr.path,
        )
    ]

hugo_import = rule(
    implementation = _hugo_import_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            cfg = "host",
        ),
        "path": attr.string(
            mandatory = True,
        ),
    },
    provides = [HugoImportInfo],
)
