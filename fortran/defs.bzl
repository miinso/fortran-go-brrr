"""Public API for rules_fortran."""

load(
    "//fortran/private:fortran_binary.bzl",
    _fortran_binary = "fortran_binary",
)
load(
    "//fortran/private:fortran_library.bzl",
    _fortran_library = "fortran_library",
)
load(
    "//fortran/private:fortran_test.bzl",
    _fortran_test = "fortran_test",
)
load(
    "//fortran/private:providers.bzl",
    _FortranInfo = "FortranInfo",
)

# Public rules
fortran_binary = _fortran_binary
fortran_library = _fortran_library
fortran_test = _fortran_test

# Public providers
FortranInfo = _FortranInfo
