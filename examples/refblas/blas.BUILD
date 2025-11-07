"""BUILD file for netlib BLAS.

This provides Reference BLAS 3.12.0 from netlib.org.

Available library targets:
  :single    - Single precision real (REAL)
  :double    - Double precision real (REAL*8)
  :complex   - Single precision complex (COMPLEX)
  :complex16 - Double precision complex (COMPLEX*16)
  :blas      - All precisions combined

Usage:
  deps = ["@blas//:double"]  # Only builds double precision
  deps = ["@blas//:blas"]    # All precisions

Note: Unlike CMake's BUILD_SINGLE/BUILD_DOUBLE/BUILD_COMPLEX/BUILD_COMPLEX16
options, Bazel only builds what you actually depend on. Just reference the
precision target you need - unused precisions won't be compiled.
"""

load("@rules_fortran//:defs.bzl", "fortran_binary", "fortran_library", "fortran_test")

# Auxiliary BLAS routines (required by all precisions)
ALLBLAS_SRCS = [
    "lsame.f",
    "xerbla.f",
    "xerbla_array.f",
]

# Single precision BLAS Level 1 routines
SBLAS1_SRCS = [
    "isamax.f",
    "sasum.f",
    "saxpy.f",
    "scopy.f",
    "sdot.f",
    "snrm2.f90",
    "srot.f",
    "srotg.f90",
    "sscal.f",
    "sswap.f",
    "sdsdot.f",
    "srotmg.f",
    "srotm.f",
]

# Single precision BLAS Level 2 routines
SBLAS2_SRCS = [
    "sgemv.f",
    "sgbmv.f",
    "ssymv.f",
    "ssbmv.f",
    "sspmv.f",
    "strmv.f",
    "stbmv.f",
    "stpmv.f",
    "strsv.f",
    "stbsv.f",
    "stpsv.f",
    "sger.f",
    "ssyr.f",
    "sspr.f",
    "ssyr2.f",
    "sspr2.f",
]

# Single precision BLAS Level 3 routines
SBLAS3_SRCS = [
    "sgemm.f",
    "ssymm.f",
    "ssyrk.f",
    "ssyr2k.f",
    "strmm.f",
    "strsm.f",
    "sgemmtr.f",
]

# Double precision BLAS Level 1 routines
DBLAS1_SRCS = [
    "idamax.f",
    "dasum.f",
    "daxpy.f",
    "dcopy.f",
    "ddot.f",
    "dnrm2.f90",
    "drot.f",
    "drotg.f90",
    "dscal.f",
    "dsdot.f",
    "dswap.f",
    "drotmg.f",
    "drotm.f",
]

# Double precision BLAS Level 2 routines
DBLAS2_SRCS = [
    "dgemv.f",
    "dgbmv.f",
    "dsymv.f",
    "dsbmv.f",
    "dspmv.f",
    "dtrmv.f",
    "dtbmv.f",
    "dtpmv.f",
    "dtrsv.f",
    "dtbsv.f",
    "dtpsv.f",
    "dger.f",
    "dsyr.f",
    "dspr.f",
    "dsyr2.f",
    "dspr2.f",
]

# Double precision BLAS Level 3 routines
DBLAS3_SRCS = [
    "dgemm.f",
    "dsymm.f",
    "dsyrk.f",
    "dsyr2k.f",
    "dtrmm.f",
    "dtrsm.f",
    "dgemmtr.f",
]

# Complex precision BLAS Level 1 routines
CBLAS1_SRCS = [
    "scabs1.f",
    "scasum.f",
    "scnrm2.f90",
    "icamax.f",
    "caxpy.f",
    "ccopy.f",
    "cdotc.f",
    "cdotu.f",
    "csscal.f",
    "crotg.f90",
    "cscal.f",
    "cswap.f",
    "csrot.f",
]

# Complex auxiliary routines (real BLAS called by complex)
CB1AUX_SRCS = [
    "isamax.f",
    "sasum.f",
    "saxpy.f",
    "scopy.f",
    "snrm2.f90",
    "sscal.f",
]

# Complex precision BLAS Level 2 routines
CBLAS2_SRCS = [
    "cgemv.f",
    "cgbmv.f",
    "chemv.f",
    "chbmv.f",
    "chpmv.f",
    "ctrmv.f",
    "ctbmv.f",
    "ctpmv.f",
    "ctrsv.f",
    "ctbsv.f",
    "ctpsv.f",
    "cgerc.f",
    "cgeru.f",
    "cher.f",
    "chpr.f",
    "cher2.f",
    "chpr2.f",
]

# Complex precision BLAS Level 3 routines
CBLAS3_SRCS = [
    "cgemm.f",
    "csymm.f",
    "csyrk.f",
    "csyr2k.f",
    "ctrmm.f",
    "ctrsm.f",
    "chemm.f",
    "cherk.f",
    "cher2k.f",
    "cgemmtr.f",
]

# Double complex precision BLAS Level 1 routines
ZBLAS1_SRCS = [
    "dcabs1.f",
    "dzasum.f",
    "dznrm2.f90",
    "izamax.f",
    "zaxpy.f",
    "zcopy.f",
    "zdotc.f",
    "zdotu.f",
    "zdscal.f",
    "zrotg.f90",
    "zscal.f",
    "zswap.f",
    "zdrot.f",
]

# Double complex auxiliary routines (real BLAS called by complex)
ZB1AUX_SRCS = [
    "idamax.f",
    "dasum.f",
    "daxpy.f",
    "dcopy.f",
    "dnrm2.f90",
    "dscal.f",
]

# Double complex precision BLAS Level 2 routines
ZBLAS2_SRCS = [
    "zgemv.f",
    "zgbmv.f",
    "zhemv.f",
    "zhbmv.f",
    "zhpmv.f",
    "ztrmv.f",
    "ztbmv.f",
    "ztpmv.f",
    "ztrsv.f",
    "ztbsv.f",
    "ztpsv.f",
    "zgerc.f",
    "zgeru.f",
    "zher.f",
    "zhpr.f",
    "zher2.f",
    "zhpr2.f",
]

# Double complex precision BLAS Level 3 routines
ZBLAS3_SRCS = [
    "zgemm.f",
    "zsymm.f",
    "zsyrk.f",
    "zsyr2k.f",
    "ztrmm.f",
    "ztrsm.f",
    "zhemm.f",
    "zherk.f",
    "zher2k.f",
    "zgemmtr.f",
]

# Compiler flags matching netlib BLAS defaults
# - See: https://flang.llvm.org/docs/OptionComparison.html
BLAS_COPTS = ["-O2"]

# Core libraries without error handlers (BLAS routines only, no xerbla)
# These are public so test programs can use them with their own xerbla implementations
fortran_library(
    name = "single_core",
    srcs = ["lsame.f"] + SBLAS1_SRCS + SBLAS2_SRCS + SBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "double_core",
    srcs = ["lsame.f"] + DBLAS1_SRCS + DBLAS2_SRCS + DBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex_core",
    srcs = ["lsame.f"] + CBLAS1_SRCS + CB1AUX_SRCS + CBLAS2_SRCS + CBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex16_core",
    srcs = ["lsame.f"] + ZBLAS1_SRCS + ZB1AUX_SRCS + ZBLAS2_SRCS + ZBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

# Auxiliary library with error handlers (shared by all precisions)
fortran_library(
    name = "aux",
    srcs = ALLBLAS_SRCS,
    copts = BLAS_COPTS,
)

# Complete BLAS libraries with error handlers
# For normal use - includes default xerbla implementation
fortran_library(
    name = "single",
    srcs = SBLAS1_SRCS + SBLAS2_SRCS + SBLAS3_SRCS,
    deps = [":aux"],
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "double",
    srcs = DBLAS1_SRCS + DBLAS2_SRCS + DBLAS3_SRCS,
    deps = [":aux"],
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex",
    srcs = CBLAS1_SRCS + CB1AUX_SRCS + CBLAS2_SRCS + CBLAS3_SRCS,
    deps = [":aux"],
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex16",
    srcs = ZBLAS1_SRCS + ZB1AUX_SRCS + ZBLAS2_SRCS + ZBLAS3_SRCS,
    deps = [":aux"],
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

# Complete BLAS library with all precisions
fortran_library(
    name = "blas",
    deps = [
        ":single",
        ":double",
        ":complex",
        ":complex16",
    ],
    visibility = ["//visibility:public"],
)

# Test binaries (Level 1)
fortran_test(
    name = "sblat1",
    srcs = ["TESTING/sblat1.f"],
    deps = [":single"],
    size = "small",
)

fortran_test(
    name = "dblat1",
    srcs = ["TESTING/dblat1.f"],
    deps = [":double"],
    size = "small",
)

fortran_test(
    name = "cblat1",
    srcs = ["TESTING/cblat1.f"],
    deps = [":complex"],
    size = "small",
)

fortran_test(
    name = "zblat1",
    srcs = ["TESTING/zblat1.f"],
    deps = [":complex16"],
    size = "small",
)

# Test binaries (Level 2 - need input files)
# Test programs provide their own xerbla, so use *_core libraries
fortran_binary(
    name = "sblat2",
    srcs = ["TESTING/sblat2.f"],
    deps = [":single_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "dblat2",
    srcs = ["TESTING/dblat2.f"],
    deps = [":double_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "cblat2",
    srcs = ["TESTING/cblat2.f"],
    deps = [":complex_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "zblat2",
    srcs = ["TESTING/zblat2.f"],
    deps = [":complex16_core"],
    visibility = ["//visibility:public"],
)

# Test binaries (Level 3 - need input files)
# Test programs provide their own xerbla, so use *_core libraries
fortran_binary(
    name = "sblat3",
    srcs = ["TESTING/sblat3.f"],
    deps = [":single_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "dblat3",
    srcs = ["TESTING/dblat3.f"],
    deps = [":double_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "cblat3",
    srcs = ["TESTING/cblat3.f"],
    deps = [":complex_core"],
    visibility = ["//visibility:public"],
)

fortran_binary(
    name = "zblat3",
    srcs = ["TESTING/zblat3.f"],
    deps = [":complex16_core"],
    visibility = ["//visibility:public"],
)

