# This file was instantiated from a template with the following substitutions:
#
# - HUGO_EXEC: {HUGO_EXEC}
# - HUGO_SOURCE_DIR: {HUGO_SOURCE_DIR}
# - HUGO_OUTPUT_DIR: {HUGO_OUTPUT_DIR}

set -e

# TODO(dwtj): This hack assumes that the source and output directories are
#  siblings. Consider making this more robust.
HUGO_OUTPUT_DIR_BASENAME=$(basename "{HUGO_OUTPUT_DIR}")
HUGO_OUTPUT_DIR_RELATIVE_TO_SOURCE_DIR="../$HUGO_OUTPUT_DIR_BASENAME"

"{HUGO_EXEC}" \
    --destination="$HUGO_OUTPUT_DIR_RELATIVE_TO_SOURCE_DIR" \
    --source="{HUGO_SOURCE_DIR}"
