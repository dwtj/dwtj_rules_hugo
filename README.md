# Bazel Rules for Hugo-Generated Static Websites

## Build Your Hugo Website with Bazel

Add a `hugo_website` rule to a Bazel package to declare a Hugo website.

```starlark
load("@dwtj_rules_hugo//hugo:defs.bzl", "hugo_website")

hugo_website(
    name = "my_website",
    srcs = [
        "config.toml",
        "content/my_content.md",
    ),
)
```

Then when you run `bazel build :my_website`, Bazel will execute Hugo and
build the website. The output directory generated by Hugo will be located
within `bazel-bin`, specifically, `bazel-bin/<rule_package>/<rule_name>/`.

## Features

A `hugo_website` can:

- Be browsed locally in your web browser via `hugo serve` using `bazel run`.
- Be packaged into an archive using Bazel's official [`rules_pkg`][1].
- Include Bazel-built files as Hugo source files.

Here's a brief example of this last item.

1. A [`stardoc`][2] rule parses some starlark code and generates a Markdown
   file.
2. Using a `hugo_import` rule, this Markdown file can be included in a
   `hugo_website` as a content file.
3. When the `hugo_website` is built, Hugo compiles this Stardoc-generated
   Markdown file to HTML.

## Configuring Your Bazel Workspace

Add something like this to your Bazel project's `WORKSPACE` file to make these
rules available within your project as an external workspace.

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

DWTJ_RULES_HUGO_SHA256 = "0b0b292ea89fc0c29e24a52eb164aa45341c0c46a616e66c0aa87536a4054379"
DWTJ_RULES_HUGO_COMMIT = "9780c52b97addaa53f74a935bab6500099f816bd"

http_archive(
    name = "dwtj_rules_hugo",
    url = "https://github.com/dwtj/dwtj_rules_hugo/archive/{}.zip".format(DWTJ_RULES_HUGO_COMMIT),
    strip_prefix = "dwtj_rules_hugo-{}".format(DWTJ_RULES_HUGO_COMMIT),
    sha256 = DWTJ_RULES_HUGO_SHA256,
)

load("@dwtj_rules_hugo//hugo:repositories.bzl", "local_hugo_repository")

local_hugo_repository(name = "local_hugo")

load("@local_hugo//:defs.bzl", "register_hugo_toolchain")

register_hugo_toolchain()
```

Here's what this configuration snippet does:

- The `http_archive()` rule fetches the rules from GitHub.
- Then the `local_hugo_repository()` rule searches your system `PATH` for a
  `hugo` executable and wraps it in a Hugo toolchain instance.
- The `register_hugo_toolchain()` rule finally registers this toolchain
  instance so that the other Hugo rules can find a `hugo` executable.


## Links

- See the [example project][3] for a very simple example of these rules being
  configured and used to build a Hugo website.
- See the [project website][4] for reference documentation on the rules and
  their attributes.

---

1: https://github.com/bazelbuild/rules_pkg
2: https://github.com/bazelbuild/stardoc
3: https://dwtj.github.io/dwtj_rules_hugo/
4: https://github.com/dwtj/dwtj_rules_hugo/tree/main/example
