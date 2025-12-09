# WebAssembly

Source: [`examples/wasm/`](https://github.com/miinso/rules_fortran/tree/master/examples/wasm)

Cross-compile Fortran to WebAssembly using Emscripten.

## Prerequisites

Add emsdk to your `MODULE.bazel`:

```starlark
bazel_dep(name = "emsdk", version = "4.0.7")
```

## 3.A. Hello World

```
wasm/
├── BUILD.bazel
└── hello.f90
```

<<< @/../examples/wasm/hello.f90{fortran}

<<< @/../examples/wasm/BUILD.bazel{starlark}

```bash
bazel build //wasm:hello_wasm
node bazel-bin/wasm/hello_cc.js
```

```
Hello from wasm32 with rules_fortran!
```

The `cc_binary` target works as a native executable. Wrapping it with `wasm_cc_binary` produces WebAssembly output instead.

## 3.B. LAPACK

```
wasm/
├── BUILD.bazel
└── full.c
```

<<< @/../examples/wasm/full.c{c}

```starlark
cc_binary(
    name = "full",
    srcs = ["full.c"],
    deps = [
        "@blas//:single",
        "@lapack//:single",
        "@lapacke//:single",
    ],
)

wasm_cc_binary(
    name = "full_wasm",
    cc_target = ":full",
    outputs = ["full.js", "full.wasm"],
)
```

```bash
bazel build //wasm:full_wasm
node bazel-bin/wasm/full.js
```

```
OK
    3.00     0.33     0.67
    6.00     2.00     0.50
   10.00     3.67    -0.50
```
