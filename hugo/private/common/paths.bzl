'''Defines some helper functions for manipulating `File` paths.
'''

def package_relative_path(ctx, file):
    '''The `File`'s relative path within the current target's package.

    Args:
      ctx: The current target's [`ctx` object][1]. This is used to get the
        current target's package.
      file: A [`File` object][2].
    Returns:
      A string encoding the `file`'s package-relative path or `None` if `file`
      is not in the current package or one of its subpackages.

    ---

    1: https://docs.bazel.build/versions/3.4.0/skylark/lib/ctx.html
    2: https://docs.bazel.build/versions/3.4.0/skylark/lib/File.html
    '''
    target_pkg = ctx.label.package

    # NOTE(dwtj): Here's some background that I learned about `File`. If an
    #  input `File` is in the Bazel source tree (i.e. if `is_source` is true)
    #  then it should have the empty string as its `root`. However, if it is a
    #  Bazel-generated file, it should have a non-empty `root`, e.g.,
    #  `bazel-out/k8-fastbuild/bin`. Regardless of which `root` the file is in,
    #  we can use `short_path` to drop the root.
    if not file.short_path.startswith(target_pkg):
        return None
    else:
        # Drop the root prefix (using `short_path` and drop the package prefix
        # by string slicing.
        return file.short_path[len(target_pkg):]
