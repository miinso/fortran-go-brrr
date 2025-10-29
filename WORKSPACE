"""WORKSPACE file for rules_fortran."""

workspace(name = "rules_fortran")

# This WORKSPACE file is for developing rules_fortran itself.
# Users of rules_fortran should use MODULE.bazel (Bzlmod) or
# load rules_fortran via http_archive in their own WORKSPACE.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Skylib - Bazel utility functions
http_archive(
    name = "bazel_skylib",
    sha256 = "cd55a062e763b9349921f0f5db8c3933288dc8ba4f76dd9416aac68acee3cb94",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.5.0/bazel-skylib-1.5.0.tar.gz",
    ],
)

# Platforms
http_archive(
    name = "platforms",
    sha256 = "218efe8ee736d26a3572663b374a253c012b716d8af0c07e842e82f238a0a7ee",
    urls = [
        "https://github.com/bazelbuild/platforms/releases/download/0.0.8/platforms-0.0.8.tar.gz",
    ],
)

# For testing: register local toolchains
# Users will configure this in their own WORKSPACE/MODULE.bazel
# register_toolchains("//fortran/toolchains:all")
