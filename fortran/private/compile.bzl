"""Fortran compilation actions."""

load(":providers.bzl", "FortranToolchainInfo")

CompileResult = provider(
    fields = ["object", "module"],
)

def _is_free_form(src):
    """Check if source file is free-form Fortran."""
    ext = src.extension
    return ext in ["f90", "f95", "f03", "f08", "F90", "F95", "F03", "F08"]

def _needs_preprocessing(src):
    """Check if source file needs preprocessing."""
    ext = src.extension
    return ext in ["F", "F90", "F95", "F03", "F08"]

def _extract_module_name(src):
    """Extract potential module name from source file.
    
    This is a heuristic - the actual module name is determined during compilation.
    """
    basename = src.basename
    # Remove extension
    for ext in [".f90", ".f95", ".f03", ".f08", ".F90", ".F95", ".F03", ".F08", ".f", ".F"]:
        if basename.endswith(ext):
            basename = basename[:-len(ext)]
            break
    return basename.lower()

def compile_fortran(ctx, toolchain, src, module_map, copts):
    """Compile a single Fortran source file.
    
    Args:
        ctx: Rule context
        toolchain: FortranToolchainInfo provider
        src: Source file to compile
        module_map: Dictionary of module names to module files
        copts: Additional compilation options
        
    Returns:
        CompileResult with object and module files
    """
    # Declare output files
    obj = ctx.actions.declare_file(
        "{}_objs/{}.o".format(ctx.label.name, src.basename.replace(".", "_"))
    )
    
    # Assume this file might create a module
    module_name = _extract_module_name(src)
    mod = ctx.actions.declare_file(
        "{}_modules/{}.mod".format(ctx.label.name, module_name)
    )
    
    # Build arguments
    args = ctx.actions.args()
    
    # Compiler flags
    args.add_all(toolchain.compiler_flags)
    args.add_all(copts)
    
    # Free-form or fixed-form
    if _is_free_form(src):
        args.add("-ffree-form")
    else:
        args.add("-ffixed-form")
    
    # Preprocessing
    if _needs_preprocessing(src):
        args.add("-cpp")
    
    # Module output directory
    module_dir = mod.dirname
    if toolchain.supports_module_path:
        flag = toolchain.module_flag_format.format(module_dir)
        args.add(flag)
    
    # Module search paths from dependencies
    module_dirs = depset(transitive = [
        depset([m.dirname for m in dep_module_map.values()])
        for dep_module_map in [module_map]
    ]).to_list()
    
    for dir in depset(module_dirs).to_list():
        if toolchain.supports_module_path:
            args.add("-I" + dir)
    
    # Compile command
    args.add("-c")
    args.add(src.path)
    args.add("-o", obj.path)
    
    # Collect input modules
    input_modules = []
    for mod_file in module_map.values():
        input_modules.append(mod_file)
    
    # Run compilation
    ctx.actions.run(
        executable = toolchain.compiler,
        arguments = [args],
        inputs = depset(
            direct = [src],
            transitive = [depset(input_modules), toolchain.all_files],
        ),
        outputs = [obj, mod],
        mnemonic = "FortranCompile",
        progress_message = "Compiling Fortran {}".format(src.short_path),
    )
    
    return CompileResult(
        object = obj,
        module = mod if _is_free_form(src) else None,  # Only modern Fortran has modules
    )
