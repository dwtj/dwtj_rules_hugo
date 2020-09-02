#!/bin/sh -
# This script is intended to be executed from the root of the main repository.

set -e

ROOT_WORKSPACE="$PWD"

# Three websites should build successfully, but one should fail.
cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_basic_rules"
bazel clean
bazel build //my_website
bazel build //my_website:my_website_with_hugo_imports
bazel build //:website_in_root_pkg
if bazel build //my_website:my_website_with_bad_src > /dev/null 2> /dev/null ; then
    echo 'ERROR: bazel build @smoke_test_basics//:my_website:my_website_with_bad_src` should have failed, but it passed.'
    exit 1
fi

# All targets in this workspace should build without error.
cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_deps_in_external_repository"
bazel clean
bazel build //...

# All targets in this workspace should build without error.
cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_markdown_deps"
bazel clean
bazel build //...
