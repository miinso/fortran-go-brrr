# Contributing

## Testing

### Unit Tests

Unit tests validate rule behavior using Bazel's analysis testing framework:

```bash
bazel test //test/unit/...
```

Test coverage includes:
- `fortran_library` and `fortran_binary` rules
- Module propagation via `FortranInfo`
- C/C++ interop via `CcInfo`
- Dependency propagation
- Edge cases and linking

### Integration Tests

The `examples/` directory is a separate Bazel module that imports `rules_fortran`. It serves as integration tests for real-world usage:

```bash
cd examples
bazel test //basic:all //blas:all
bazel build //wasm:hello_wasm //wasm:full_wasm
```

## Running CI Locally

```bash
bazel test //test/... --verbose_failures --test_output=all
```
