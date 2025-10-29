"""Implementation of fortran_library rule."""

load(":providers.bzl", "FortranInfo", "FortranToolchainInfo")
load(":compile.bzl", "compile_fortran")

def _fortran_library_impl(ctx):
    toolchain = ctx.toolchains["@rules_fortran//fortran:toolchain_type"].fortran

    # Collect transitive dependencies
    transitive_sources = [dep[FortranInfo].transitive_sources for dep in ctx.attr.deps if FortranInfo in dep]
    transitive_modules = [dep[FortranInfo].transitive_modules for dep in ctx.attr.deps if FortranInfo in dep]
    transitive_objects = [dep[FortranInfo].transitive_objects for dep in ctx.attr.deps if FortranInfo in dep]
    
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
        ctx.actions.run(
            executable = toolchain.archiver,
            arguments = ["rcs", archive.path] + [obj.path for obj in objects],
            inputs = objects,
            outputs = [archive],
            mnemonic = "FortranArchive",
            progress_message = "Creating Fortran archive {}".format(archive.short_path),
        )
        output_files = [archive] + modules
    else:
        output_files = modules
    
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
            module_map = module_map,
            compile_flags = ctx.attr.copts,
            link_flags = ctx.attr.linkopts,
        ),
    ]

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
        "linkopts": attr.string_list(
            doc = "Additional linker options (propagated to binaries).",
        ),
        "includes": attr.string_list(
            doc = "List of include directories to add to the compile line.",
        ),
    },
    toolchains = ["@rules_fortran//fortran:toolchain_type"],
)
