# Basic

Source: [`examples/basic/`](https://github.com/miinso/rules_fortran/tree/master/examples/basic)

## 1.A. Hello World

```
basic/
├── BUILD.bazel
└── hello.f90
```

<<< @/../examples/basic/hello.f90{fortran}

```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_binary")

fortran_binary(
    name = "hello",
    srcs = ["hello.f90"],
)
```

```bash
bazel run //basic:hello
```

```
Hello from Fortran with rules_fortran!
```

## 1.B. Binary with Dependency

```
basic/
├── BUILD.bazel
├── main.f90
└── math.f90
```

```fortran
! math.f90
module math
    implicit none
contains
    function square(x) result(y)
        real, intent(in) :: x
        real :: y
        y = x * x
    end function square
end module math
```

```fortran
! main.f90
program main
    use math
    implicit none
    print *, "5^2 =", square(5.0)
end program main
```

```starlark
fortran_library(
    name = "math",
    srcs = ["math.f90"],
)

fortran_binary(
    name = "main",
    srcs = ["main.f90"],
    deps = [":math"],
)
```

```bash
bazel run //basic:main
```

```
5^2 = 25.0
```

## 1.C. Include Files

```
basic/
├── BUILD.bazel
├── include/
│   └── constants.inc
└── use_include.f90
```

<<< @/../examples/basic/include/constants.inc{fortran}

<<< @/../examples/basic/use_include.f90{fortran}

```starlark
fortran_binary(
    name = "constants",
    srcs = ["use_include.f90"],
    hdrs = ["include/constants.inc"],
    includes = ["include"],
)
```

```bash
bazel run //basic:constants
```

```
PI = 3.1415927
E = 2.7182817
MAX_ITERATIONS = 1000
PASSED
```
