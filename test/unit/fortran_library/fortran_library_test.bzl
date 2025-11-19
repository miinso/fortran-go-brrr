"""Unit tests for fortran_library rule."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//:defs.bzl", "fortran_library")
load("//fortran/private:providers.bzl", "FortranInfo")

def _fortran_library_provides_ccinfo_test_impl(ctx):
    """Test that fortran_library provides CcInfo for C interop."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Assert CcInfo is provided
    asserts.true(
        env,
        CcInfo in target,
        "fortran_library must provide CcInfo for C interop",
    )

    # Assert linking context exists
    if CcInfo in target:
        cc_info = target[CcInfo]
        linker_inputs = cc_info.linking_context.linker_inputs.to_list()
        asserts.true(
            env,
            len(linker_inputs) > 0,
            "fortran_library must provide linker inputs",
        )

    return analysistest.end(env)

fortran_library_provides_ccinfo_test = analysistest.make(
    _fortran_library_provides_ccinfo_test_impl,
)

def _fortran_library_provides_fortran_info_test_impl(ctx):
    """Test that fortran_library provides FortranInfo."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    # Check FortranInfo provider exists
    asserts.true(
        env,
        FortranInfo in target,
        "fortran_library must provide FortranInfo",
    )

    return analysistest.end(env)

fortran_library_provides_fortran_info_test = analysistest.make(
    _fortran_library_provides_fortran_info_test_impl,
)

def fortran_library_test_suite(name):
    """Test suite for fortran_library rule."""

    # Create test fixture
    fortran_library(
        name = "simple_lib",
        srcs = ["simple.f90"],
        tags = ["manual"],  # Don't build unless explicitly requested
    )

    # Create tests
    fortran_library_provides_ccinfo_test(
        name = "provides_ccinfo_test",
        target_under_test = ":simple_lib",
    )

    fortran_library_provides_fortran_info_test(
        name = "provides_fortran_info_test",
        target_under_test = ":simple_lib",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":provides_ccinfo_test",
            ":provides_fortran_info_test",
        ],
    )
