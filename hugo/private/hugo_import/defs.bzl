'''Defines the `hugo_import` rule.
'''

load("//hugo:private/common/providers/HugoSourcesInfo.bzl", "HugoSourcesInfo")

_HUGO_IMPORT_DOC_STRINGS = {
# TODO(dwtj): Write a doc string for this rule.
"RULE":
'''
''',

# TODO(dwtj): Write a doc string for the `src` attr.
"SRC_ATTR":
'''
''',

# TODO(dwtj): Write a doc string for the `path` attr.
"PATH_ATTR":
'''
''',

# TODO(dwtj): Consider failing if a file already has front matter.
"ADD_FRONT_MATTER_ATTR":
'''If this is non-empty, then the imported file is actually a new file whose
contents are created by prepending this string (plus a newline) to the
beginning of the `src` file's contents. The new file will be placed in this
target's package and with this target's `name`.

This attribute may be useful for adding a front matter section to
Bazel-generated files which don't already have a front matter section. (E.g.,
you want to include a file is generated by `stardoc` in your Hugo website, but
the `stardoc`-generated file doesn't have a front matter section).

If this is set to the empty string (the default value), no copying
is performed, i.e., the `src` file is imported and used without copying or
modifying it.

Note that this does not check to see whether the `src` file already has a front
matter section or modify one if it already exists.
'''
}

def _copy_file_with_front_matter(actions, label, name, front_matter, src_file):
    '''Declares and writes a `File` like `src_file` but with `front_matter`.

    Note that a (Unix-style) newline is inserted between `front_matter` and
    the contents of the `file`.

    A temporary file is named `<name>.front_matter` is also created containing
    just the `front_matter` string followed by a single (Unix-style) newline.

    Args:
      actions: The `Actions` object to use.
      label: The label of the `hugo_import` rule for which these actions are
        being performed.
      name: The name of the generated file.
      front_matter: A string to be prepended to the contents of `src_file`.
      src_file: The `File` whose contents are appended to `front_matter`.
    Returns:
      A newly declared and written `File` object in the current package.
    '''
    # TODO(dwtj): Figure out a way to do this without creating this temporary
    #  `.front_matter` file (or another small temporary file).
    front_matter_file = actions.declare_file(name + ".front_matter")
    actions.write(
        output = front_matter_file,
        content = front_matter + "\n",
        is_executable = False,
    )

    # TODO(dwtj): Use something besides `cat` for Windows portability.
    output_file = actions.declare_file(name)
    actions.run_shell(
        outputs = [output_file],
        command = 'cat "{}" "{}" > "{}"'.format(
            front_matter_file.path,
            src_file.path,
            output_file.path,
        ),
        inputs = [
            front_matter_file,
            src_file,
        ],
        use_default_shell_env = False,
        mnemonic = "AddFrontMatter",
        progress_message = "Adding front matter to Hugo source file in `hugo_import` labeled `{}`.".format(label),
    )
    return output_file

def _hugo_import_impl(ctx):
    if len(ctx.attr.path) == 0:
        fail("Illegal attribute value: `hugo_import.path` cannot be set to the empty string.")

    front_matter = ctx.attr.add_front_matter

    if (front_matter == ""):
        # Use the `src` directly with no alterations. No output files.
        return [
            HugoSourcesInfo(
                srcs = {
                    ctx.attr.path: ctx.file.src,
                }
            ),
        ]
    else:
        # Add the front matter to src. Declare this new file to be an output.
        src = _copy_file_with_front_matter(
            actions = ctx.actions,
            label = ctx.label,
            name = ctx.attr.name + ".hugo_import",
            front_matter = front_matter,
            src_file = ctx.file.src,
        )
        return [
            DefaultInfo(
                files = depset(direct = [src]),
            ),
            HugoSourcesInfo(
                srcs = {
                    ctx.attr.path: src,
                },
            ),
        ]

hugo_import = rule(
    doc = _HUGO_IMPORT_DOC_STRINGS["RULE"],
    implementation = _hugo_import_impl,
    attrs = {
        "src": attr.label(
            doc = _HUGO_IMPORT_DOC_STRINGS["SRC_ATTR"],
            allow_single_file = True,
            mandatory = True,
            cfg = "host",
        ),
        "path": attr.string(
            doc = _HUGO_IMPORT_DOC_STRINGS["PATH_ATTR"],
            mandatory = True,
        ),
        "add_front_matter": attr.string(
            doc = _HUGO_IMPORT_DOC_STRINGS["ADD_FRONT_MATTER_ATTR"],
            default = "",
            mandatory = False,
        ),
    },
    provides = [HugoSourcesInfo],
)
