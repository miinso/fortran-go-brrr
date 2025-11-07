"""Implementation of fortran_test rule."""

load(":providers.bzl", "FortranInfo", "FortranToolchainInfo")
load(":compile.bzl", "compile_fortran")

def _fortran_test_impl(ctx):
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

    # Collect dependencies
    transitive_objects = []
    module_map = {}
    link_flags = []
    
    for dep in ctx.attr.deps:
        if FortranInfo in dep:
            transitive_objects.append(dep[FortranInfo].transitive_objects)
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
    
    # Collect all objects
    all_objects = depset(
        direct = objects,
        transitive = transitive_objects,
    ).to_list()
    
    # Link test executable
    executable = ctx.actions.declare_file(ctx.label.name)
    
    args = ctx.actions.args()
    args.add_all(all_objects)
    args.add("-o", executable.path)
    args.add_all(toolchain.linker_flags)
    args.add_all(link_flags)
    args.add_all(ctx.attr.linkopts)
    
    ctx.actions.run(
        executable = toolchain.linker,
        arguments = [args],
        inputs = depset(
            direct = all_objects,
            transitive = [toolchain.all_files],
        ),
        outputs = [executable],
        mnemonic = "FortranLinkTest",
        progress_message = "Linking Fortran test {}".format(executable.short_path),
        use_default_shell_env = True,
    )
    
    # Create runfiles
    runfiles = ctx.runfiles(files = [executable])
    for dep in ctx.attr.deps:
        runfiles = runfiles.merge(ctx.runfiles(transitive_files = dep[DefaultInfo].default_runfiles.files))
    
    return [
        DefaultInfo(
            files = depset([executable]),
            executable = executable,
            runfiles = runfiles,
        ),
    ]

fortran_test = rule(
    implementation = _fortran_test_impl,
    doc = """Compiles and links Fortran sources into a test executable.
    
    This rule is similar to fortran_binary but is used for test targets.
    The resulting executable will be run as part of `bazel test`.
    
    Example:
        fortran_test(
            name = "mytest",
            srcs = ["test.f90"],
            deps = [":mylib"],
        )
    """,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".f", ".f90", ".f95", ".f03", ".f08", ".F", ".F90", ".F95", ".F03", ".F08"],
            doc = "List of Fortran test source files.",
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
    test = True,
    toolchains = ["@rules_fortran//fortran:toolchain_type"],
)
