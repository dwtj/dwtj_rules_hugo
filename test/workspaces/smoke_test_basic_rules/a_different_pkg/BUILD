exports_files(["some_content.md"], visibility = ["//my_website:__pkg__"])

# Make a markdown file with just an empty front matter.
genrule(
    name = "some_bazel_generated_content",
    outs = ["some_bazel_generated_content.md"],
    cmd_bash = 'echo "---\r---\r" > $(RULEDIR)/some_bazel_generated_content.md',
    visibility = ["//my_website:__pkg__"],
)