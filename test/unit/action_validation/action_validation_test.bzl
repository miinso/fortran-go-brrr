"""Unit tests for action validation (compiler flags, includes, defines)."""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:defs.bzl", "fortran_library")
load("//test/unit:common.bzl", "assert_argv_contains")

def _copts_appear_in_compile_action_test_impl(ctx):
    """Test that copts are passed to the compiler."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that custom copts appear in compile action
    compile_action = compile_actions[0]
    assert_argv_contains(env, compile_action, "-O3")
    assert_argv_contains(env, compile_action, "-march=native")

    return analysistest.end(env)

copts_appear_in_compile_action_test = analysistest.make(
    _copts_appear_in_compile_action_test_impl,
)

def _defines_appear_in_compile_action_test_impl(ctx):
    """Test that defines are passed to the compiler."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that defines appear as -D flags
    compile_action = compile_actions[0]
    assert_argv_contains(env, compile_action, "-DUSE_MPI")
    assert_argv_contains(env, compile_action, "-D_OPENMP")

    return analysistest.end(env)

defines_appear_in_compile_action_test = analysistest.make(
    _defines_appear_in_compile_action_test_impl,
)

# def _includes_appear_in_compile_action_test_impl(ctx):
#     """Test that includes are passed to the compiler."""
#     env = analysistest.begin(ctx)
#     target = analysistest.target_under_test(env)

#     actions = analysistest.target_actions(env)
#     compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

#     asserts.true(
#         env,
#         len(compile_actions) > 0,
#         "Expected at least one FortranCompile action",
#     )

#     # Check that includes appear as -I flags
#     compile_action = compile_actions[0]
#     assert_argv_contains_prefix(env, compile_action, "-Iinclude")

#     return analysistest.end(env)

# includes_appear_in_compile_action_test = analysistest.make(
#     _includes_appear_in_compile_action_test_impl,
# )

def _module_paths_in_compile_action_test_impl(ctx):
    """Test that module paths from deps appear in compile action."""
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    actions = analysistest.target_actions(env)
    compile_actions = [a for a in actions if a.mnemonic == "FortranCompile"]

    asserts.true(
        env,
        len(compile_actions) > 0,
        "Expected at least one FortranCompile action",
    )

    # Check that module path from dependency appears
    compile_action = compile_actions[0]
    action_str = str(compile_action.argv)

    # Module paths should be included for dependencies
    has_module_path = "modules" in action_str or "-I" in action_str

    asserts.true(
        env,
        has_module_path,
        "Expected module paths from deps in compile action",
    )

    return analysistest.end(env)

module_paths_in_compile_action_test = analysistest.make(
    _module_paths_in_compile_action_test_impl,
)

def action_validation_test_suite(name):
    """Test suite for action validation."""

    # Test copts
    fortran_library(
        name = "lib_with_copts",
        srcs = ["simple_regular.f90"],
        copts = ["-O3", "-march=native"],
        tags = ["manual"],
    )

    # Test defines (requires uppercase .F90 extension for preprocessing)
    fortran_library(
        name = "lib_with_defines",
        srcs = ["simple.F90"],
        defines = ["USE_MPI", "_OPENMP"],
        tags = ["manual"],
    )

    # # Test includes (not implemented yet, see #13)
    # fortran_library(
    #     name = "lib_with_includes",
    #     srcs = ["simple_regular.f90"],
    #     includes = ["include"],
    #     tags = ["manual"],
    # )

    # Test module paths from deps
    fortran_library(
        name = "dep_with_module",
        srcs = ["module_a.f90"],
        tags = ["manual"],
    )

    fortran_library(
        name = "lib_using_module",
        srcs = ["module_b.f90"],
        deps = [":dep_with_module"],
        tags = ["manual"],
    )

    # Create tests
    copts_appear_in_compile_action_test(
        name = "copts_appear_in_compile_action_test",
        target_under_test = ":lib_with_copts",
    )

    defines_appear_in_compile_action_test(
        name = "defines_appear_in_compile_action_test",
        target_under_test = ":lib_with_defines",
    )

    # TODO(#13): enable when includes attribute is implemented
    # includes_appear_in_compile_action_test(
    #     name = "includes_appear_in_compile_action_test",
    #     target_under_test = ":lib_with_includes",
    # )

    module_paths_in_compile_action_test(
        name = "module_paths_in_compile_action_test",
        target_under_test = ":lib_using_module",
    )

    # Bundle into test suite
    native.test_suite(
        name = name,
        tests = [
            ":copts_appear_in_compile_action_test",
            ":defines_appear_in_compile_action_test",
            # ":includes_appear_in_compile_action_test",  # TODO(#13)
            ":module_paths_in_compile_action_test",
        ],
    )
