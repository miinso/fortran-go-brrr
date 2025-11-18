"""Implementation of fortran_binary rule."""

load("@rules_cc//cc/common:cc_info.bzl", "CcInfo")
load(":compile.bzl", "compile_fortran")
load(":providers.bzl", "FortranInfo")

def _fortran_binary_impl(ctx):
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

    # Collect dependencies from both Fortran and C/C++ libraries
    # transitive_objects = [] # TODO: per object linking
    transitive_libraries = []
    module_map = {}
    link_flags = []
    cc_libraries = []
    cc_objects = []

    for dep in ctx.attr.deps:
        # Handle Fortran dependencies
        if FortranInfo in dep:
            transitive_libraries.append(dep[FortranInfo].transitive_libraries)
            module_map.update(dep[FortranInfo].module_map)
            link_flags.extend(dep[FortranInfo].link_flags)

        # Handle C/C++ dependencies
        if CcInfo in dep:
            linking_context = dep[CcInfo].linking_context
            for linker_input in linking_context.linker_inputs.to_list():
                # Collect libraries
                for library in linker_input.libraries:
                    # Prefer PIC static library, fall back to non-PIC
                    if library.pic_static_library != None:
                        cc_libraries.append(library.pic_static_library)
                    elif library.static_library != None:
                        cc_libraries.append(library.static_library)

                    # TODO(minseo): Handle dynamic libraries

                    # Collect object files
                    if hasattr(library, "objects") and library.objects != None:
                        cc_objects.extend(library.objects)

                # Collect user link flags
                if hasattr(linker_input, "user_link_flags"):
                    link_flags.extend(linker_input.user_link_flags)

    # Compile sources
    fortran_objects = []
    for src in ctx.files.srcs:
        result = compile_fortran(
            ctx = ctx,
            toolchain = toolchain,
            src = src,
            module_map = module_map,
            copts = ctx.attr.copts,
            defines = ctx.attr.defines,
        )
        fortran_objects.append(result.object)

    # Collect all libraries from dependencies in topological order
    # (dependencies come after dependents, allowing linker to resolve symbols correctly)
    # See: https://bazel.build/extending/depsets#order
    fortran_libraries = depset(
        transitive = transitive_libraries,
        order = "topological",
    ).to_list()

    # Combine Fortran and C/C++ libraries
    all_libraries = fortran_libraries + cc_libraries

    # Combine all object files (Fortran + C/C++)
    all_objects = fortran_objects + cc_objects

    # Link executable
    executable = ctx.actions.declare_file(ctx.label.name)

    args = ctx.actions.args()

    # Add all object files first (both Fortran and C/C++)
    for obj in all_objects:
        args.add(obj)

    # Add libraries in topological order with deduplication
    # rules_cc did use a set to dedup libraries
    seen_libraries = {}
    for lib in all_libraries:
        if lib not in seen_libraries:
            args.add(lib)
            seen_libraries[lib] = True

    args.add("-o", executable.path)
    args.add_all(toolchain.linker_flags)

    # Add link flags from dependencies
    # say we trust `cc_common.merge_cc_infos` to do its job
    args.add_all(link_flags)
    args.add_all(ctx.attr.linkopts)

    # Use param file to avoid (possible) "Argument list too long" errors
    args.use_param_file("@%s", use_always = True)
    args.set_param_file_format("multiline")

    ctx.actions.run(
        executable = toolchain.linker,
        arguments = [args],
        inputs = depset(
            direct = all_objects + all_libraries,
            transitive = [toolchain.all_files],
        ),
        outputs = [executable],
        mnemonic = "FortranLink",
        progress_message = "Linking Fortran binary {}".format(executable.short_path),
        use_default_shell_env = True,
    )

    # Create runfiles
    # See: https://bazel.build/extending/rules#runfiles
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
            providers = [[FortranInfo], [CcInfo]],
            doc = "List of fortran_library or cc_library targets to link against.",
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
