#!/bin/sh -
# This script is intended to be executed from the root of the main repository.

set -e

ROOT_WORKSPACE="$PWD"

cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_basics"
bazel clean
bazel build //...

cd "$ROOT_WORKSPACE/test/workspaces/smoke_test_markdown_deps"
bazel clean
bazel build //...
