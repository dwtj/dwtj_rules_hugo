# Make a markdown file with just an empty front matter.
genrule(
    name = "bazel_generated_content",
    outs = ["foo.md"],
    cmd_bash = 'echo "---\r---\r" > $(RULEDIR)/foo.md',
    visibility = ["//my_website:__pkg__"],
)