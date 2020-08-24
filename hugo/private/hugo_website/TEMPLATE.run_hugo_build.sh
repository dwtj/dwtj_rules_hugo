# This file was instantiated from a template with the following substitutions:
#
# - HUGO_EXEC: {HUGO_EXEC}
# - CONFIG_FILE: {CONFIG_FILE}
# - WEBSITE_BUILD_DIR: {WEBSITE_BUILD_DIR}
# - WEBSITE_ARCHIVE: {WEBSITE_ARCHIVE}

set -e

mkdir -p "{WEBSITE_BUILD_DIR}"

"{HUGO_EXEC}" \
    --config="{CONFIG_FILE}" \
    --destination="{WEBSITE_BUILD_DIR}"

tar --create --gzip --file "{WEBSITE_ARCHIVE}" --directory "{WEBSITE_BUILD_DIR}" .
