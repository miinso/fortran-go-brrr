"""Bzlmod extensions for rules_fortran."""

load("//fortran:repositories.bzl", "flang_register_toolchains")

# Default configuration
_DEFAULT_VERSION = "v21.1.3"
_DEFAULT_REPO_OWNER = "miinso"
_DEFAULT_REPO_NAME = "flang"

def _flang_impl(module_ctx):
    """Implementation of flang extension."""
    flang_register_toolchains(
        name = "flang",
        version = _DEFAULT_VERSION,
        repo_owner = _DEFAULT_REPO_OWNER,
        repo_name = _DEFAULT_REPO_NAME,
    )

flang = module_extension(
    implementation = _flang_impl,
    tag_classes = {},
    doc = """Module extension for Flang toolchains.

    Example:
        flang = use_extension("@rules_fortran//fortran:extensions.bzl", "flang")
        use_repo(
            flang,
            "flang_linux_x86_64",
            "flang_linux_aarch64",
            "flang_macos_x86_64",
            "flang_macos_aarch64",
            "flang_windows_x86_64",
        )
    """,
)
