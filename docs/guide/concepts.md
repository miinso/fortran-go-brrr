# Fortran Build Concepts

## Fortran vs C/C++

Fortran has different compilation semantics than C/C++, which affects how build systems must handle it.

### Module Files

In C/C++, headers are textual includes processed by the preprocessor. In Fortran, `module` declarations compile to binary `.mod` files containing type signatures, interfaces, and metadata.

```fortran
module math        ! Compiles to math.mod
    implicit none
contains
    function add(a, b) result(c)
        real, intent(in) :: a, b
        real :: c
        c = a + b
    end function add
end module math
```

When another file says `use math`, the compiler reads `math.mod` to verify types and interfaces. This means:

1. **Modules must be compiled before their users** - strict build ordering required
2. **Module files are compiler-specific** - gfortran `.mod` files are incompatible with flang
3. **Module names are case-insensitive** - `USE MATH` and `use math` refer to the same module

### Dependency Ordering

Consider three files:

```
a.f90: module a (no dependencies)
b.f90: module b, uses a
c.f90: program c, uses a and b
```

Valid compilation order: `a.f90` → `b.f90` → `c.f90`

Invalid: `b.f90` first (needs `a.mod`), or `c.f90` first (needs both)

In C/C++, object files can be compiled in any order. In Fortran, sources must be compiled in dependency order.

## How rules_fortran Handles This

### Source Ordering Within a Target

Within a single `fortran_library`, sources are compiled in the order listed in `srcs`. Each source can use modules produced by sources listed before it:

```starlark
fortran_library(
    name = "mylib",
    srcs = [
        "a.f90",  # Defines module a
        "b.f90",  # Can use a
        "c.f90",  # Can use a and b
    ],
)
```

::: warning
You must list sources in dependency order. If `b.f90` uses module `a`, then `a.f90` must appear before `b.f90` in the `srcs` list.
:::

### Module Propagation Across Targets

When one target depends on another, module files are propagated via `FortranInfo`:

```starlark
fortran_library(
    name = "base",
    srcs = ["base.f90"],  # Defines module base
)

fortran_library(
    name = "advanced",
    srcs = ["advanced.f90"],  # Can use base
    deps = [":base"],
)
```

The `deps` attribute makes all modules from `:base` available when compiling `advanced.f90`.

### C Interoperability

Fortran 2003 introduced `iso_c_binding` for calling C functions and being called from C. rules_fortran provides `CcInfo` from `fortran_library`, enabling:

- `cc_binary` / `cc_library` / `cc_test` can depend on `fortran_library`
- `fortran_binary` / `fortran_library` / `fortran_test` can depend on `cc_library`

See the [C/Fortran Interop example](/examples/interop) for details.
