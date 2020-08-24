# This file was instantiated from a template with the following substitutions:
#
# - REPOSITORY_NAME: {REPOSITORY_NAME}

def register_hugo_toolchain():
    native.register_toolchains(
        "@{REPOSITORY_NAME}//:hugo_toolchain",
    )