'''Defines the `hugo_library` rule.
'''

load("//hugo:private/common/paths.bzl", "package_relative_path")
load("//hugo:private/common/providers/HugoSourcesInfo.bzl", "HugoSourcesInfo")

_HUGO_LIBRARY_DOC_STRINGS = {
'RULE': \
'''A `hugo_library` represents a Hugo website fragment. It is essentially a
collection of Hugo source files and their corresponding paths relative to a
Hugo website root.

A `hugo_library` target lets you wrap multiple related source files, organize
them into a file hierarchy, and provide them as one to `hugo_website` targets.

Note that this rule is not involved in building Hugo websites or website
fragments. It is only a collection of Hugo website source files. The sources in
a `hugo_library` are only built within the source tree of a `hugo_website` in
which they have been included.

A `hugo_library` target takes its Bazel package to be the root directory of a
collection of Hugo source files. For each of the source files in `srcs`, the
file's path relative to this root is recorded and used to later place that
source file within Hugo websites.

A `hugo_library` is included in a `hugo_website` by including it in a website's
`deps` attribute. Doing so means that each file in the `hugo_library` should
be placed into the source tree of that `hugo_website`; specifically, each
file is placed at its corresponding `path` *relative to the website's root*.

This way in which the `hugo_library` target's package is used as a website
root is quite like `hugo_website` targets.

Also like `hugo_website`, `srcs` must be in this Bazel package or a Bazel
subpackage. Otherwise, analysis of this target will fail.

Note that the `hugo_website` will fail if two of its source files are mapped
to the same path within its source tree. Thus both the contents and paths of
files are part of a `hugo_library`'s public interface.

This rule will fail if two of its source files are mapped to the same relative
path.

This rule will fail if no sources are provided (i.e. `srcs` is empty and there
are no sources provided by any `deps`).
''',

"SRCS_ATTR":
'''A list of source files to include in this target. All of these source
files should be in this target's package or one of its subpackages.
''',

"DEPS_ATTR":
'''A list of targets providing `HugoSourcesInfo` (e.g. `hugo_library`s and
`hugo_import`s) whose sources should be included in this `hugo_library`
target and any Hugo targets which depend upon this target.
'''
}

def _add_all_srcs(source_srcs, target_srcs):
    for (path, src_file) in source_srcs.items():
        _add_src_to_srcs(path, src_file, target_srcs)

def _add_src_to_srcs(path, src_file, srcs):
    if srcs.get(path) == None:
        srcs[path] = src_file
    else:
        fail("Tried to add a source file to path `{}`, but another file is already located at that path.".format(path))

def _hugo_library_impl(ctx):
    # Add `srcs` & `deps` to a dict; return a `HugoSourcesInfo` wrapping it.
    srcs = dict()
    for src in ctx.files.srcs:
        pkg_relative_path = package_relative_path(ctx, src)
        if pkg_relative_path == None:
            fail("While analyzing a `hugo_library` target labeled `{}`, found a source file which isn't in this package or one of its subpackages: `{}`.".format(ctx.label, src.path))
        _add_src_to_srcs(pkg_relative_path, src, srcs)
    for dep in ctx.attr.deps:
        _add_all_srcs(dep[HugoSourcesInfo].srcs, srcs)

    if len(srcs) == 0:
        fail("While analyzing a `hugo_library` target labeled `{}`, no source files were found.")

    return [
        HugoSourcesInfo(
            srcs = srcs,
        ),
    ]

hugo_library = rule(
    doc = _HUGO_LIBRARY_DOC_STRINGS["RULE"],
    implementation = _hugo_library_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = _HUGO_LIBRARY_DOC_STRINGS["SRCS_ATTR"],
            mandatory = False,
            allow_empty = True,
            allow_files = True,
        ),
        "deps": attr.label_list(
            doc = _HUGO_LIBRARY_DOC_STRINGS["DEPS_ATTR"],
            mandatory = False,
            allow_empty = True,
            allow_files = False,
            providers = [HugoSourcesInfo],
        ),
    },
    provides = [HugoSourcesInfo],
)
