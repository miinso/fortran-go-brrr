# rules_fortran

Fortran rules for Bazel.

[Documentation](https://miinso.github.io/rules_fortran/)

## Supported Platforms

| Host | Target |
|------|--------|
| Linux x86_64 | x86_64-unknown-linux-gnu |
| Linux ARM64 | aarch64-unknown-linux-gnu |
| macOS x86_64 | x86_64-apple-darwin |
| macOS ARM64 | arm64-apple-darwin |
| Windows x86_64 | x86_64-pc-windows-msvc |

All platforms can cross-compile to `wasm32-unknown-emscripten`.

## Setup

### Bzlmod (recommended)

Add to your `MODULE.bazel`:

```starlark
bazel_dep(name = "rules_fortran")
git_override(
    module_name = "rules_fortran",
    remote = "https://github.com/miinso/rules_fortran.git",
    commit = "...",  # see releases
)
```

### WORKSPACE

Not supported. Use Bzlmod.

## Usage

```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_binary", "fortran_library", "fortran_test")

fortran_library(
    name = "mylib",
    srcs = ["mylib.f90"],
)

fortran_binary(
    name = "myapp",
    srcs = ["main.f90"],
    deps = [":mylib"],
)

fortran_test(
    name = "mytest",
    srcs = ["test.f90"],
    deps = [":mylib"],
)
```

### C/Fortran Interop

Fortran and C targets can depend on each other:

```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_library")
load("@rules_cc//cc:defs.bzl", "cc_library", "cc_binary")

# Fortran calls C
cc_library(name = "c_math", srcs = ["c_math.c"])
fortran_binary(
    name = "fortran_calls_c",
    srcs = ["main.f90"],
    deps = [":c_math"],
)

# C calls Fortran
fortran_library(name = "fortran_math", srcs = ["math.f90"])
cc_binary(
    name = "c_calls_fortran",
    srcs = ["main.c"],
    deps = [":fortran_math"],
)
```
