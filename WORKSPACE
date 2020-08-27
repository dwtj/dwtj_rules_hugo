workspace(name = "dwtj_rules_hugo")

load("//hugo:repositories.bzl", "local_hugo_repository")

local_hugo_repository(name = "local_hugo")

load("@local_hugo//:defs.bzl", "register_hugo_toolchain")

register_hugo_toolchain()
