"""Fortran toolchain definitions."""

load("//fortran/private:providers.bzl", "FortranToolchainInfo")

def _fortran_toolchain_impl(ctx):
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
    },
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
