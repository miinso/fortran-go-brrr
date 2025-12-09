# Quick Start

## Hello World

**hello.f90**
```fortran
program hello
    print *, "Hello, Fortran!"
end program hello
```

**BUILD.bazel**
```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_binary")

fortran_binary(
    name = "hello",
    srcs = ["hello.f90"],
)
```

```bash
bazel run //:hello
```

## Modules and Libraries

Fortran organizes code into **modules**. Unlike C/C++ headers, Fortran modules are compiled artifacts (`.mod` files) that must be built before any code that `use`s them.

**math.f90**
```fortran
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

**main.f90**
```fortran
program main
    use math
    implicit none
    print *, "4^2 =", square(4.0)
end program main
```

**BUILD.bazel**
```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_binary", "fortran_library")

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

rules_fortran handles module dependency ordering automatically. When you declare `deps = [":math"]`, the build system ensures `math.mod` is generated before compiling `main.f90`.

## Tests

```starlark
load("@rules_fortran//fortran:defs.bzl", "fortran_test")

fortran_test(
    name = "math_test",
    srcs = ["math_test.f90"],
    deps = [":math"],
)
```

```bash
bazel test //...
```
