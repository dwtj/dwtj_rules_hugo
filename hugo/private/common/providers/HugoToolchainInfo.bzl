'''Defines the `HugoToolchainInfo` provider.
'''

HugoToolchainInfo = provider(
    fields = {
        "hugo_exec": "A `File` pointing to a `hugo` executable (in the host configuration)."
    }
)
