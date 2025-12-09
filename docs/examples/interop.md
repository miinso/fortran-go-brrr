# Interop

Source: [`examples/interop/`](https://github.com/miinso/rules_fortran/tree/master/examples/interop)

`fortran_library` provides `CcInfo`, enabling bidirectional linking between Fortran and C/C++ targets.

## 2.A. fortran-calling-c

```
interop/
├── BUILD.bazel
├── c_math.c
├── c_math.h
└── fortran_calls_c.f90
```

<<< @/../examples/interop/c_math.h{c}

<<< @/../examples/interop/c_math.c{c}

<<< @/../examples/interop/fortran_calls_c.f90{fortran}

```starlark
cc_library(
    name = "c_math",
    srcs = ["c_math.c"],
    hdrs = ["c_math.h"],
)

fortran_test(
    name = "fortran_calls_c",
    srcs = ["fortran_calls_c.f90"],
    deps = [":c_math"],
)
```

```bash
bazel run //interop:fortran_calls_c
```

```
PASS: c_add_doubles(2.0, 3.0) = 5.0
```

## 2.B. c-calling-fortran

```
interop/
├── BUILD.bazel
├── c_calls_fortran.c
└── fortran_math.f90
```

<<< @/../examples/interop/fortran_math.f90{fortran}

<<< @/../examples/interop/c_calls_fortran.c{c}

```starlark
fortran_library(
    name = "fortran_math",
    srcs = ["fortran_math.f90"],
)

cc_test(
    name = "c_calls_fortran",
    srcs = ["c_calls_fortran.c"],
    deps = [":fortran_math"],
)
```

```bash
bazel run //interop:c_calls_fortran
```

```
PASS: fortran_square(5.0) = 25.0
```
