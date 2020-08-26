# This file was instantiated from a template with the following substitutions:
#
# - HUGO_EXEC: {HUGO_EXEC}
# - HUGO_SOURCE_DIR: {HUGO_SOURCE_DIR}
# - WEBSITE_ARCHIVE: {WEBSITE_ARCHIVE}

set -e

HUGO_DEFAULT_DESTINATION_DIR="{HUGO_SOURCE_DIR}/public"
EXECROOT="$PWD"

"{HUGO_EXEC}" --source="{HUGO_SOURCE_DIR}"

cd "$EXECROOT"
tar --create --gzip \
    --file "{WEBSITE_ARCHIVE}" \
    --directory "$HUGO_DEFAULT_DESTINATION_DIR" \
    .

