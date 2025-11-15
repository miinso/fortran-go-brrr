"""Implementation of fortran_library rule."""

load(":providers.bzl", "FortranInfo", "FortranToolchainInfo")
load(":compile.bzl", "compile_fortran")
load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cc_toolchain")

def _fortran_library_impl(ctx):
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

    # Collect transitive dependencies
    transitive_sources = [dep[FortranInfo].transitive_sources for dep in ctx.attr.deps if FortranInfo in dep]
    transitive_modules = [dep[FortranInfo].transitive_modules for dep in ctx.attr.deps if FortranInfo in dep]
    transitive_objects = [dep[FortranInfo].transitive_objects for dep in ctx.attr.deps if FortranInfo in dep]
    transitive_libraries = [dep[FortranInfo].transitive_libraries for dep in ctx.attr.deps if FortranInfo in dep]
    
    # Merge module maps from dependencies
    module_map = {}
    for dep in ctx.attr.deps:
        if FortranInfo in dep:
            module_map.update(dep[FortranInfo].module_map)
    
    # Compile sources
    objects = []
    modules = []
    local_module_map = {}
    
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
        if result.module:
            modules.append(result.module)
            # Use source basename as key for the module directory
            # The directory may contain 0 or more .mod files
            src_key = src.basename.replace(".", "_")
            local_module_map[src_key] = result.module
    
    # Update module map
    module_map.update(local_module_map)
    
    # Create static library if there are objects
    if objects:
        archive = ctx.actions.declare_file("lib{}.a".format(ctx.label.name))
        
        # Use param file to avoid "Argument list too long" errors on Windows/Linux
        # This is especially important for large libraries like LAPACK with thousands of object files
        args = ctx.actions.args()
        args.add("rcs")
        args.add(archive.path)
        
        # Add each object file separately to ensure they are on separate lines in param file
        # This avoids MSVC linker's 131071 character per line limit
        for obj in objects:
            args.add(obj)
        
        args.use_param_file("@%s", use_always = True)
        args.set_param_file_format("multiline")
        
        ctx.actions.run(
            executable = toolchain.archiver,
            arguments = [args],
            inputs = objects,
            outputs = [archive],
            mnemonic = "FortranArchive",
            progress_message = "Creating Fortran archive {}".format(archive.short_path),
        )
        output_files = [archive] + modules
        libraries = [archive]
    else:
        output_files = modules
        libraries = []
    
    # Create CcInfo provider for C/C++ interoperability
    # See: https://bazel.build/versions/8.4.0/configure/integrate-cpp
    cc_info_providers = []
    if libraries:
        # Get CC toolchain for creating CcInfo
        cc_toolchain = find_cc_toolchain(ctx)
        feature_configuration = cc_common.configure_features(
            ctx = ctx,
            cc_toolchain = cc_toolchain,
        )

        # Create a library to link for C/C++ consumers
        library_to_link = cc_common.create_library_to_link(
            actions = ctx.actions,
            feature_configuration = feature_configuration,
            static_library = archive,
        )

        # Get Fortran toolchain to access runtime libraries
        fortran_toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

        # Create a linker input with Fortran runtime libraries
        linker_input = cc_common.create_linker_input(
            owner = ctx.label,
            libraries = depset([library_to_link]),
            user_link_flags = depset([lib.path for lib in fortran_toolchain.runtime_libraries]), # here are the paths to link
            additional_inputs = depset(fortran_toolchain.runtime_libraries), # bazel to know where the actual files are
        )

        # Create linking context
        linking_context = cc_common.create_linking_context(
            linker_inputs = depset([linker_input]),
        )

        # Create CcInfo
        cc_info_providers.append(
            CcInfo(
                compilation_context = cc_common.create_compilation_context(),
                linking_context = linking_context,
            )
        )

    return [
        DefaultInfo(files = depset(output_files)),
        FortranInfo(
            transitive_sources = depset(
                direct = ctx.files.srcs,
                transitive = transitive_sources,
            ),
            transitive_modules = depset(
                direct = modules,
                transitive = transitive_modules,
            ),
            transitive_objects = depset(
                direct = objects,
                transitive = transitive_objects,
            ),
            transitive_libraries = depset(
                direct = libraries,
                transitive = transitive_libraries,
                order = "topological",
            ),
            module_map = module_map,
            compile_flags = ctx.attr.copts,
            link_flags = ctx.attr.linkopts,
        ),
    ] + cc_info_providers

fortran_library = rule(
    implementation = _fortran_library_impl,
    doc = """Compiles Fortran sources into a static library.
    
    This rule compiles Fortran source files and creates a static library.
    It handles module dependencies automatically and provides FortranInfo
    to dependent targets.
    
    Example:
        fortran_library(
            name = "mylib",
            srcs = ["module.f90", "utils.f90"],
            deps = [":otherlib"],
            copts = ["-O2"],
        )
    """,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".f", ".f90", ".f95", ".f03", ".f08", ".F", ".F90", ".F95", ".F03", ".F08"],
            doc = "List of Fortran source files to compile.",
        ),
        "deps": attr.label_list(
            providers = [FortranInfo],
            doc = "List of other fortran_library targets that this library depends on.",
        ),
        "copts": attr.string_list(
            doc = "Additional compiler options to pass to the Fortran compiler.",
        ),
        "defines": attr.string_list(
            doc = "Preprocessor defines for .F files (e.g., ['_OPENMP', 'USE_MPI']).",
        ),
        "linkopts": attr.string_list(
            doc = "Additional linker options (propagated to binaries).",
        ),
        "includes": attr.string_list(
            doc = "List of include directories to add to the compile line.",
        ),
        # https://bazel.build/versions/8.4.0/configure/integrate-cpp
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    toolchains = [
        "@rules_fortran//fortran:toolchain_type",
        "@bazel_tools//tools/cpp:toolchain_type", # to create CcInfo (not just reading it like in fortran_binary)
    ],
    fragments = ["cpp"], # `cc_common.configure_features()` requires this fragment thing
)
