"""Implementation of fortran_binary rule."""

load(":providers.bzl", "FortranInfo", "FortranToolchainInfo")
load(":compile.bzl", "compile_fortran")

def _fortran_binary_impl(ctx):
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

    # Collect dependencies
    transitive_libraries = []
    module_map = {}
    link_flags = []

    for dep in ctx.attr.deps:
        if FortranInfo in dep:
            transitive_libraries.append(dep[FortranInfo].transitive_libraries)
            module_map.update(dep[FortranInfo].module_map)
            link_flags.extend(dep[FortranInfo].link_flags)

    # Compile sources
    objects = []
    for src in ctx.files.srcs:
        result = compile_fortran(
            ctx = ctx,
            toolchain = toolchain,
            src = src,
            module_map = module_map,
            copts = ctx.attr.copts,
            defines = ctx.attr.defines,
        )
        objects.append(result.object)
    
    # Collect all libraries from dependencies
    all_libraries = depset(
        transitive = transitive_libraries,
    ).to_list()
    
    # Link executable
    executable = ctx.actions.declare_file(ctx.label.name)
    
    args = ctx.actions.args()
    
    # Add local object files first
    for obj in objects:
        args.add(obj)
    
    # On Unix-like systems, the linker processes libraries in order and only extracts
    # symbols that are currently needed. This can cause issues with circular dependencies
    # or when a library A depends on library B, but B comes first in the link order.
    #
    # Solutions:
    # 1. Use -Wl,--start-group ... -Wl,--end-group (Linux) or -Wl,-(  -Wl,-) (BSD)
    # 2. Specify libraries in correct dependency order (trickier to compute?)
    # 3. Specify libraries twice (simpler?)
    #
    # let's try #3: list all libraries twice
    # TODO: see how rules_cc people handled this one
    
    # First pass: Add all library files
    for lib in all_libraries:
        args.add(lib)
    
    # Second pass: Add them again to resolve circular/reverse dependencies
    for lib in all_libraries:
        args.add(lib)
    
    args.add("-o", executable.path)
    args.add_all(toolchain.linker_flags)
    args.add_all(link_flags)
    args.add_all(ctx.attr.linkopts)
    
    # Use param file to avoid "Argument list too long" errors on Windows/Linux
    args.use_param_file("@%s", use_always = True)
    args.set_param_file_format("multiline")
    
    ctx.actions.run(
        executable = toolchain.linker,
        arguments = [args],
        inputs = depset(
            direct = objects + all_libraries,
            transitive = [toolchain.all_files],
        ),
        outputs = [executable],
        mnemonic = "FortranLink",
        progress_message = "Linking Fortran binary {}".format(executable.short_path),
        use_default_shell_env = True,
    )
    
    return [
        DefaultInfo(
            files = depset([executable]),
            executable = executable,
        ),
    ]

fortran_binary = rule(
    implementation = _fortran_binary_impl,
    doc = """Compiles and links Fortran sources into an executable.
    
    This rule compiles Fortran source files and links them with
    dependencies into an executable binary.
    
    Example:
        fortran_binary(
            name = "myapp",
            srcs = ["main.f90"],
            deps = [":mylib"],
            linkopts = ["-llapack"],
        )
    """,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".f", ".f90", ".f95", ".f03", ".f08", ".F", ".F90", ".F95", ".F03", ".F08"],
            doc = "List of Fortran source files to compile.",
        ),
        "deps": attr.label_list(
            providers = [FortranInfo],
            doc = "List of fortran_library targets to link against.",
        ),
        "copts": attr.string_list(
            doc = "Additional compiler options.",
        ),
        "defines": attr.string_list(
            doc = "Preprocessor defines for .F files (e.g., ['_OPENMP', 'USE_MPI']).",
        ),
        "linkopts": attr.string_list(
            doc = "Additional linker options.",
        ),
    },
    executable = True,
    toolchains = ["@rules_fortran//fortran:toolchain_type"],
)
