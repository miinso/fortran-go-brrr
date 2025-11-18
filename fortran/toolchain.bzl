"""Fortran toolchain definitions."""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")
load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load("//fortran/private:providers.bzl", "FortranToolchainInfo")

def _make_runtime_ccinfo(ctx, cc_toolchain, feature_configuration, runtime_libs):
    """Create CcInfo for Fortran runtime libraries.

    This creates a CcInfo provider containing the Fortran runtime libraries
    (libflang_rt.runtime.a, libclang_rt.builtins.a) in a way that can be
    merged once into all fortran_library targets,

    Args:
        ctx: Rule context
        cc_toolchain: The C++ toolchain
        feature_configuration: Feature configuration from cc_common
        runtime_libs: List of runtime library files

    Returns:
        CcInfo provider containing the runtime libraries
    """
    if not runtime_libs:
        # No runtime libs - return empty CcInfo
        return CcInfo(
            compilation_context = cc_common.create_compilation_context(),
            linking_context = cc_common.create_linking_context(),
        )

    # Create library_to_link for each runtime library
    libraries_to_link = []
    for lib in runtime_libs:
        # Determine if this is a static or dynamic library based on extension
        # TODO: shared lib support
        is_static = lib.extension == "a" or lib.extension == "lib"
        is_dynamic = lib.extension in ["so", "dylib", "dll"]

        library_to_link = cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            cc_toolchain = cc_toolchain,
            static_library = lib if is_static else None,
            dynamic_library = lib if is_dynamic else None,
        )
        libraries_to_link.append(library_to_link)

    # Create linker_input with the runtime libraries
    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(libraries_to_link),
        # NOTE: additional link flags (like -lpthread) should be in linker_flags if needed
    )

    # Create and return CcInfo
    linking_context = cc_common.create_linking_context(
        linker_inputs = depset([linker_input]),
    )

    return CcInfo(
        compilation_context = cc_common.create_compilation_context(),
        linking_context = linking_context,
    )

def _fortran_toolchain_impl(ctx):
    # Collect runtime library files from dependencies
    runtime_lib_files = []
    for dep in ctx.attr.runtime_libraries:
        runtime_lib_files.extend(dep[DefaultInfo].files.to_list())

    # Get C++ toolchain and create CcInfo for runtime libraries
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # Create CcInfo for runtime libraries (kind of similar to rules_rust stdlib_linkflags)
    runtime_ccinfo = _make_runtime_ccinfo(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        feature_configuration = feature_configuration,
        runtime_libs = runtime_lib_files,
    )

    toolchain_info = FortranToolchainInfo(
        compiler = ctx.file.compiler,
        linker = ctx.file.linker,
        archiver = ctx.file.archiver,
        compiler_flags = ctx.attr.compiler_flags,
        linker_flags = ctx.attr.linker_flags,
        preprocessor_flag = ctx.attr.preprocessor_flag,
        preprocessor_flags = ctx.attr.preprocessor_flags,
        supports_module_path = ctx.attr.supports_module_path,
        module_flag_format = ctx.attr.module_flag_format,
        runtime_libraries = runtime_lib_files,
        runtime_ccinfo = runtime_ccinfo,
        all_files = depset(
            direct = [
                ctx.file.compiler,
                ctx.file.linker,
                ctx.file.archiver,
            ],
            transitive = [dep[DefaultInfo].files for dep in ctx.attr.tool_deps],
        ),
    )

    return [
        platform_common.ToolchainInfo(
            fortran = toolchain_info,
        ),
        toolchain_info,
    ]

fortran_toolchain = rule(
    implementation = _fortran_toolchain_impl,
    doc = """Defines a Fortran toolchain.
    
    This rule defines a Fortran toolchain with compiler, linker, and archiver
    along with default flags.
    
    Example:
        fortran_toolchain(
            name = "linux_toolchain",
            compiler = "@flang//:bin/flang-new",
            linker = "@flang//:bin/flang-new",
            archiver = "@flang//:bin/llvm-ar",
            compiler_flags = ["-Wall", "-O2"],
            linker_flags = ["-lm"],
        )
    """,
    attrs = {
        "compiler": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "The Fortran compiler executable.",
        ),
        "linker": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "The linker executable.",
        ),
        "archiver": attr.label(
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            doc = "The archiver executable (typically 'ar').",
        ),
        "compiler_flags": attr.string_list(
            default = [],
            doc = "Default flags to pass to the compiler.",
        ),
        "linker_flags": attr.string_list(
            default = [],
            doc = "Default flags to pass to the linker.",
        ),
        "preprocessor_flag": attr.string(
            default = "-cpp",
            doc = "Flag to enable preprocessing (e.g., '-cpp' for gfortran/flang, '-fpp' for ifort).",
        ),
        "preprocessor_flags": attr.string_list(
            default = [],
            doc = "Default preprocessor flags (e.g., ['-D_OPENMP', '-DUSE_MPI']).",
        ),
        "supports_module_path": attr.bool(
            default = True,
            doc = "Whether the compiler supports specifying module output directory.",
        ),
        "module_flag_format": attr.string(
            default = "-J{}",
            doc = "Format string for module path flag. Use {} as placeholder for path.",
        ),
        "tool_deps": attr.label_list(
            allow_files = True,
            doc = "Additional tool dependencies (e.g., runtime libraries).",
        ),
        "runtime_libraries": attr.label_list(
            default = [],
            doc = "flang/clang runtime libraries (flang_rt, clang_rt) for C/Fortran interop.",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
)

def _fortran_toolchain_alias_impl(ctx):
    """Implementation of fortran_toolchain_alias."""
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran
    return [
        DefaultInfo(files = toolchain.all_files),
        toolchain,
    ]

fortran_toolchain_alias = rule(
    implementation = _fortran_toolchain_alias_impl,
    doc = """Creates an alias to the current Fortran toolchain.
    
    This can be used to access toolchain files or information.
    """,
    toolchains = ["@rules_fortran//fortran:toolchain_type"],
)
