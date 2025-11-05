# Reference BLAS Example

This example demonstrates how to use the reference BLAS (Basic Linear Algebra Subprograms) library with Fortran in Bazel.

## Contents

- **`main.f90`** - Simple DGEMM (matrix multiplication) example
- **`BUILD.bazel`** - Bazel build configuration
- **`run.sh`** - Wrapper script for running BLAS tests with input redirection
- **`data/`** - Test input files for BLAS Level 2 and Level 3 tests

## Building and Running

### Build the main example:
```bash
bazel build //examples/refblas:main
```

### Run the main example:
```bash
bazel run //examples/refblas:main
```

### Run BLAS tests:
```bash
# Run all BLAS Level 2 and Level 3 tests
bazel test //examples/refblas:all

# Run specific test (e.g., double precision Level 2)
bazel test //examples/refblas:dblat2

# Run with verbose output
bazel test //examples/refblas:all --test_output=all
```

## Available Tests

The example includes BLAS tests for all precision types:

**Level 2 Tests (matrix-vector operations):**
- `sblat2` - Single precision real
- `dblat2` - Double precision real
- `cblat2` - Single precision complex
- `zblat2` - Double precision complex

**Level 3 Tests (matrix-matrix operations):**
- `sblat3` - Single precision real
- `dblat3` - Double precision real
- `cblat3` - Single precision complex
- `zblat3` - Double precision complex

## Dependencies

The BLAS library is fetched automatically from the reference implementation via the `@blas` repository defined in `blas.BUILD`.

## Using BLAS in Your Code

To use BLAS in your Fortran code, add it to your target's `deps`:

```starlark
fortran_binary(
    name = "my_app",
    srcs = ["my_app.f90"],
    deps = ["@blas"],  # Include all BLAS routines
)
```

Or depend on specific precision libraries:

```starlark
fortran_binary(
    name = "my_app",
    srcs = ["my_app.f90"],
    deps = [
        "@blas//:double",   # Double precision routines only
        # "@blas//:single",   # Single precision
        # "@blas//:complex",  # Complex precision
        # "@blas//:complex16", # Double complex precision
    ],
)
```

The `@blas` target provides all BLAS routines across all precisions, while the precision-specific targets (`:double`, `:single`, etc.) provide only the routines for that precision type.
