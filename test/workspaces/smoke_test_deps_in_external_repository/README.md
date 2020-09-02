# Smoke Test Workspace: Use Dependencies in External Repositories

This test workspace is designed to help check for problems when a `hugo_website`
rule depends on a rule defined in an external repository. Specifically, this
repository:

- Includes its sibling test workspace, `@smoke_test_basic_rules`, as an
  external repository.
- Defines a `hugo_website` which depends upon a rule defined in the sibling test
  workspace.
