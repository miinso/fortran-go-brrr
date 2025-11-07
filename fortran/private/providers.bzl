"""Fortran providers."""

FortranInfo = provider(
    doc = """Provider for Fortran compilation information.
    
    This provider is used to propagate information about compiled Fortran
    code, including module files, object files, and transitive dependencies.
    """,
    fields = {
        "transitive_sources": "depset of source files (for building)",
        "transitive_modules": "depset of module files (.mod)",
        "transitive_objects": "depset of object files (.o)",
        "module_map": "dict mapping module names to module files",
        "compile_flags": "list of compilation flags",
        "link_flags": "list of link flags",
    },
)

FortranToolchainInfo = provider(
    doc = "Information about the Fortran toolchain.",
    fields = {
        "compiler": "The Fortran compiler executable",
        "linker": "The linker executable",
        "archiver": "The archiver executable (ar)",
        "compiler_flags": "Default compiler flags",
        "linker_flags": "Default linker flags",
        "preprocessor_flag": "Flag to enable preprocessing (e.g., '-cpp', '-fpp')",
        "preprocessor_flags": "Default preprocessor flags (e.g., ['-D_OPENMP'])",
        "supports_module_path": "Whether compiler supports -J flag for modules",
        "module_flag_format": "Format string for module path flag (e.g., '-J{}', '-module {}')",
        "all_files": "All toolchain files",
    },
)
