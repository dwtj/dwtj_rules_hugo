# This file was instantiated from a template with the following substitutions:
#
# - HUGO_EXEC: {HUGO_EXEC}
# - HUGO_SOURCE_DIR: {HUGO_SOURCE_DIR}

set -e

"{HUGO_EXEC}" server --source="{HUGO_SOURCE_DIR}" "$@"
