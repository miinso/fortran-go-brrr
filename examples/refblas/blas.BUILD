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
    "BLAS/SRC/lsame.f",
    "BLAS/SRC/xerbla.f",
    "BLAS/SRC/xerbla_array.f",
]

# Single precision BLAS Level 1 routines
SBLAS1_SRCS = [
    "BLAS/SRC/isamax.f",
    "BLAS/SRC/sasum.f",
    "BLAS/SRC/saxpy.f",
    "BLAS/SRC/scopy.f",
    "BLAS/SRC/sdot.f",
    "BLAS/SRC/snrm2.f90",
    "BLAS/SRC/srot.f",
    "BLAS/SRC/srotg.f90",
    "BLAS/SRC/sscal.f",
    "BLAS/SRC/sswap.f",
    "BLAS/SRC/sdsdot.f",
    "BLAS/SRC/srotmg.f",
    "BLAS/SRC/srotm.f",
]

# Single precision BLAS Level 2 routines
SBLAS2_SRCS = [
    "BLAS/SRC/sgemv.f",
    "BLAS/SRC/sgbmv.f",
    "BLAS/SRC/ssymv.f",
    "BLAS/SRC/ssbmv.f",
    "BLAS/SRC/sspmv.f",
    "BLAS/SRC/strmv.f",
    "BLAS/SRC/stbmv.f",
    "BLAS/SRC/stpmv.f",
    "BLAS/SRC/strsv.f",
    "BLAS/SRC/stbsv.f",
    "BLAS/SRC/stpsv.f",
    "BLAS/SRC/sger.f",
    "BLAS/SRC/ssyr.f",
    "BLAS/SRC/sspr.f",
    "BLAS/SRC/ssyr2.f",
    "BLAS/SRC/sspr2.f",
]

# Single precision BLAS Level 3 routines
SBLAS3_SRCS = [
    "BLAS/SRC/sgemm.f",
    "BLAS/SRC/ssymm.f",
    "BLAS/SRC/ssyrk.f",
    "BLAS/SRC/ssyr2k.f",
    "BLAS/SRC/strmm.f",
    "BLAS/SRC/strsm.f",
    "BLAS/SRC/sgemmtr.f",
]

# Double precision BLAS Level 1 routines
DBLAS1_SRCS = [
    "BLAS/SRC/idamax.f",
    "BLAS/SRC/dasum.f",
    "BLAS/SRC/daxpy.f",
    "BLAS/SRC/dcopy.f",
    "BLAS/SRC/ddot.f",
    "BLAS/SRC/dnrm2.f90",
    "BLAS/SRC/drot.f",
    "BLAS/SRC/drotg.f90",
    "BLAS/SRC/dscal.f",
    "BLAS/SRC/dsdot.f",
    "BLAS/SRC/dswap.f",
    "BLAS/SRC/drotmg.f",
    "BLAS/SRC/drotm.f",
]

# Double precision BLAS Level 2 routines
DBLAS2_SRCS = [
    "BLAS/SRC/dgemv.f",
    "BLAS/SRC/dgbmv.f",
    "BLAS/SRC/dsymv.f",
    "BLAS/SRC/dsbmv.f",
    "BLAS/SRC/dspmv.f",
    "BLAS/SRC/dtrmv.f",
    "BLAS/SRC/dtbmv.f",
    "BLAS/SRC/dtpmv.f",
    "BLAS/SRC/dtrsv.f",
    "BLAS/SRC/dtbsv.f",
    "BLAS/SRC/dtpsv.f",
    "BLAS/SRC/dger.f",
    "BLAS/SRC/dsyr.f",
    "BLAS/SRC/dspr.f",
    "BLAS/SRC/dsyr2.f",
    "BLAS/SRC/dspr2.f",
]

# Double precision BLAS Level 3 routines
DBLAS3_SRCS = [
    "BLAS/SRC/dgemm.f",
    "BLAS/SRC/dsymm.f",
    "BLAS/SRC/dsyrk.f",
    "BLAS/SRC/dsyr2k.f",
    "BLAS/SRC/dtrmm.f",
    "BLAS/SRC/dtrsm.f",
    "BLAS/SRC/dgemmtr.f",
]

# Complex precision BLAS Level 1 routines
CBLAS1_SRCS = [
    "BLAS/SRC/scabs1.f",
    "BLAS/SRC/scasum.f",
    "BLAS/SRC/scnrm2.f90",
    "BLAS/SRC/icamax.f",
    "BLAS/SRC/caxpy.f",
    "BLAS/SRC/ccopy.f",
    "BLAS/SRC/cdotc.f",
    "BLAS/SRC/cdotu.f",
    "BLAS/SRC/csscal.f",
    "BLAS/SRC/crotg.f90",
    "BLAS/SRC/cscal.f",
    "BLAS/SRC/cswap.f",
    "BLAS/SRC/csrot.f",
]

# Complex auxiliary routines (real BLAS called by complex)
CB1AUX_SRCS = [
    "BLAS/SRC/isamax.f",
    "BLAS/SRC/sasum.f",
    "BLAS/SRC/saxpy.f",
    "BLAS/SRC/scopy.f",
    "BLAS/SRC/snrm2.f90",
    "BLAS/SRC/sscal.f",
]

# Complex precision BLAS Level 2 routines
CBLAS2_SRCS = [
    "BLAS/SRC/cgemv.f",
    "BLAS/SRC/cgbmv.f",
    "BLAS/SRC/chemv.f",
    "BLAS/SRC/chbmv.f",
    "BLAS/SRC/chpmv.f",
    "BLAS/SRC/ctrmv.f",
    "BLAS/SRC/ctbmv.f",
    "BLAS/SRC/ctpmv.f",
    "BLAS/SRC/ctrsv.f",
    "BLAS/SRC/ctbsv.f",
    "BLAS/SRC/ctpsv.f",
    "BLAS/SRC/cgerc.f",
    "BLAS/SRC/cgeru.f",
    "BLAS/SRC/cher.f",
    "BLAS/SRC/chpr.f",
    "BLAS/SRC/cher2.f",
    "BLAS/SRC/chpr2.f",
]

# Complex precision BLAS Level 3 routines
CBLAS3_SRCS = [
    "BLAS/SRC/cgemm.f",
    "BLAS/SRC/csymm.f",
    "BLAS/SRC/csyrk.f",
    "BLAS/SRC/csyr2k.f",
    "BLAS/SRC/ctrmm.f",
    "BLAS/SRC/ctrsm.f",
    "BLAS/SRC/chemm.f",
    "BLAS/SRC/cherk.f",
    "BLAS/SRC/cher2k.f",
    "BLAS/SRC/cgemmtr.f",
]

# Double complex precision BLAS Level 1 routines
ZBLAS1_SRCS = [
    "BLAS/SRC/dcabs1.f",
    "BLAS/SRC/dzasum.f",
    "BLAS/SRC/dznrm2.f90",
    "BLAS/SRC/izamax.f",
    "BLAS/SRC/zaxpy.f",
    "BLAS/SRC/zcopy.f",
    "BLAS/SRC/zdotc.f",
    "BLAS/SRC/zdotu.f",
    "BLAS/SRC/zdscal.f",
    "BLAS/SRC/zrotg.f90",
    "BLAS/SRC/zscal.f",
    "BLAS/SRC/zswap.f",
    "BLAS/SRC/zdrot.f",
]

# Double complex auxiliary routines (real BLAS called by complex)
ZB1AUX_SRCS = [
    "BLAS/SRC/idamax.f",
    "BLAS/SRC/dasum.f",
    "BLAS/SRC/daxpy.f",
    "BLAS/SRC/dcopy.f",
    "BLAS/SRC/dnrm2.f90",
    "BLAS/SRC/dscal.f",
]

# Double complex precision BLAS Level 2 routines
ZBLAS2_SRCS = [
    "BLAS/SRC/zgemv.f",
    "BLAS/SRC/zgbmv.f",
    "BLAS/SRC/zhemv.f",
    "BLAS/SRC/zhbmv.f",
    "BLAS/SRC/zhpmv.f",
    "BLAS/SRC/ztrmv.f",
    "BLAS/SRC/ztbmv.f",
    "BLAS/SRC/ztpmv.f",
    "BLAS/SRC/ztrsv.f",
    "BLAS/SRC/ztbsv.f",
    "BLAS/SRC/ztpsv.f",
    "BLAS/SRC/zgerc.f",
    "BLAS/SRC/zgeru.f",
    "BLAS/SRC/zher.f",
    "BLAS/SRC/zhpr.f",
    "BLAS/SRC/zher2.f",
    "BLAS/SRC/zhpr2.f",
]

# Double complex precision BLAS Level 3 routines
ZBLAS3_SRCS = [
    "BLAS/SRC/zgemm.f",
    "BLAS/SRC/zsymm.f",
    "BLAS/SRC/zsyrk.f",
    "BLAS/SRC/zsyr2k.f",
    "BLAS/SRC/ztrmm.f",
    "BLAS/SRC/ztrsm.f",
    "BLAS/SRC/zhemm.f",
    "BLAS/SRC/zherk.f",
    "BLAS/SRC/zher2k.f",
    "BLAS/SRC/zgemmtr.f",
]

# Compiler flags matching netlib BLAS defaults
# - See: https://flang.llvm.org/docs/OptionComparison.html
BLAS_COPTS = ["-O2"]

# Core libraries without error handlers (BLAS routines only, no xerbla)
# These are public so test programs can use them with their own xerbla implementations
fortran_library(
    name = "single_core",
    srcs = ["BLAS/SRC/lsame.f"] + SBLAS1_SRCS + SBLAS2_SRCS + SBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "double_core",
    srcs = ["BLAS/SRC/lsame.f"] + DBLAS1_SRCS + DBLAS2_SRCS + DBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex_core",
    srcs = ["BLAS/SRC/lsame.f"] + CBLAS1_SRCS + CB1AUX_SRCS + CBLAS2_SRCS + CBLAS3_SRCS,
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex16_core",
    srcs = ["BLAS/SRC/lsame.f"] + ZBLAS1_SRCS + ZB1AUX_SRCS + ZBLAS2_SRCS + ZBLAS3_SRCS,
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
    srcs = CBLAS1_SRCS + CBLAS2_SRCS + CBLAS3_SRCS,
    deps = [":aux", ":single"],
    copts = BLAS_COPTS,
    visibility = ["//visibility:public"],
)

fortran_library(
    name = "complex16",
    srcs = ZBLAS1_SRCS + ZBLAS2_SRCS + ZBLAS3_SRCS,
    deps = [":aux", ":double"],
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

