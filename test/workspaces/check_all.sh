#!/bin/sh -
# This script is intended to be executed from the root of the main repository.

set -e

ROOT_WORKSPACE="$PWD"

# The target `//my_website:my_website` should succeed, but the target
# `//my_website:my_website_with_bad_src` should fail.
cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_basic_rules"
bazel clean
bazel build //my_website
if bazel build //my_website:my_website_with_bad_src > /dev/null 2> /dev/null ; then
    echo 'ERROR: bazel build @smoke_test_basics//:my_website:my_website_with_bad_src` should have failed, but it passed.'
    exit 1
fi

cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_markdown_deps"
bazel clean
bazel build //...
