"""Repository rules for downloading prebuilt LLVM/Flang binaries."""

def _get_platform_info(repository_ctx):
    """Determine the current platform and return target triple matching archive names."""

    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    # Normalize architecture names
    arch_map = {
        "amd64": "x86_64",
        "x86_64": "x86_64",
        "x64": "x86_64",
        "aarch64": "arm64",
        "arm64": "arm64",
    }
    normalized_arch = arch_map.get(arch, arch)

    # Determine target triple matching the actual archive filenames
    if "linux" in os_name:
        if normalized_arch == "x86_64":
            # TODO: suppress normal (ubuntu-latest) build and use the musl static build as default
            # return "x86_64-unknown-linux-gnu", "linux", normalized_arch
            return "x86_64-unknown-linux-gnu-static", "linux", normalized_arch
        elif normalized_arch == "arm64": # TODO: not implemented
            return "aarch64-linux-gnu", "linux", normalized_arch
    elif "mac" in os_name or "darwin" in os_name:
        if normalized_arch == "x86_64":
            return "x86_64-apple-darwin", "macos", normalized_arch
        elif normalized_arch == "arm64":
            return "arm64-apple-darwin", "macos", normalized_arch
    elif "windows" in os_name:
        if normalized_arch == "x86_64":
            return "x86_64-pc-windows-msvc", "windows", normalized_arch
        elif normalized_arch == "arm64":
            return "aarch64-pc-windows-msvc", "windows", normalized_arch

    fail("Unsupported platform: {} {}".format(os_name, arch))

def _create_build_files(repository_ctx):
    """Create BUILD.bazel and WORKSPACE files for the LLVM/Flang repository."""

    # Create BUILD file for the toolchain
    repository_ctx.file("BUILD.bazel", """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "flang-new",
    srcs = glob(["bin/flang-new*"]),
)

filegroup(
    name = "llvm-ar",
    srcs = glob(["bin/llvm-ar*"]),
)

filegroup(
    name = "clang",
    srcs = glob(["bin/clang*"]),
)

filegroup(
    name = "lld",
    srcs = glob(["bin/ld.lld*", "bin/lld*"]),
)

filegroup(
    name = "compiler_files",
    srcs = glob([
        "bin/**",
        "lib/**",
        "include/**",
    ]),
)

filegroup(
    name = "all_files",
    srcs = glob(["**/*"]),
)

# flang/clang runtime libraries needed for linking Fortran code
# these are required when C/C++ code calls Fortran functions that depend on runtime lib routines
filegroup(
    name = "runtime_libraries",
    srcs = select({
        "@platforms//os:windows": glob([
            "lib/clang/*/lib/*/flang_rt.runtime.static.lib", # TODO: what about /MD /MTd /MDd
            "lib/clang/*/lib/*/clang_rt.builtins-*.lib", # [x86_64, aarch64]
        ]),
        "@platforms//os:macos": glob([
            "lib/clang/*/lib/*/libflang_rt.runtime.a",
            "lib/clang/*/lib/*/libclang_rt.osx.a",
        ]),
        "@platforms//os:linux": glob([
            "lib/clang/*/lib/*/libflang_rt.runtime.a",
            "lib/clang/*/lib/*/libclang_rt.builtins.a",
        ]),
        "//conditions:default": [],
    }),
)

# Export binaries for toolchain use
exports_files(
    glob([
        "bin/*",
        "lib/*",
    ]),
)
""")

    # Create WORKSPACE file
    repository_ctx.file("WORKSPACE", """
workspace(name = "{}")
""".format(repository_ctx.name))

def _llvm_flang_prebuilt_impl(repository_ctx):
    """Download prebuilt LLVM/Flang from GitHub releases or use local files."""

    # Get platform information
    target_triple, os_type, arch = _get_platform_info(repository_ctx)

    # Get configuration
    version = repository_ctx.attr.version
    repo_owner = repository_ctx.attr.repo_owner
    repo_name = repository_ctx.attr.repo_name
    local_dist_dir = repository_ctx.attr.local_dist_dir

    # Strip 'v' prefix from version for filename if present
    # GitHub release tags use 'v21.1.3' but asset filenames use '21.1.3'
    version_no_prefix = version[1:] if version.startswith("v") else version

    # Determine file extension based on OS
    file_extension = "zip" if os_type == "windows" else "tar.gz"

    # Construct filename - Format: flang+llvm-{version}-{target-triple}.{tar.gz|zip}
    filename = "flang+llvm-{}-{}.{}".format(version_no_prefix, target_triple, file_extension)

    # Check for local file first if local_dist_dir is specified
    if local_dist_dir:
        local_path = repository_ctx.path(local_dist_dir).get_child(filename)
        if local_path.exists:
            repository_ctx.report_progress("Using local file: {}".format(local_path))
            repository_ctx.extract(
                archive = local_path,
                stripPrefix = repository_ctx.attr.strip_prefix,
            )
            # Skip download, go to BUILD file creation
            _create_build_files(repository_ctx)
            return None

    # Fall back to downloading from GitHub
    url = "https://github.com/{}/{}/releases/download/{}/{}".format(
        repo_owner,
        repo_name,
        version,
        filename,
    )

    # Custom URL format if provided
    if repository_ctx.attr.url_template:
        url = repository_ctx.attr.url_template.format(
            version = version,
            target_triple = target_triple,
            os = os_type,
            arch = arch,
        )

    # Download and extract
    repository_ctx.download_and_extract(
        url = url,
        sha256 = repository_ctx.attr.sha256.get(target_triple, ""),
        stripPrefix = repository_ctx.attr.strip_prefix,
    )

    # Create BUILD and WORKSPACE files
    _create_build_files(repository_ctx)
    return None

llvm_flang_prebuilt = repository_rule(
    implementation = _llvm_flang_prebuilt_impl,
    attrs = {
        "version": attr.string(
            mandatory = True,
            doc = "LLVM/Flang version (e.g., 'v21.1.3')",
        ),
        "repo_owner": attr.string(
            default = "your-org",
            doc = "GitHub repository owner",
        ),
        "repo_name": attr.string(
            default = "llvm-flang-builds",
            doc = "GitHub repository name",
        ),
        "url_template": attr.string(
            doc = "Custom URL template with {version}, {target_triple}, {os}, {arch} placeholders",
        ),
        "strip_prefix": attr.string(
            default = "flang+llvm-21.1.3",
            doc = "Strip prefix from extracted archive",
        ),
        "sha256": attr.string_dict(
            default = {},
            doc = "SHA256 checksums for each target triple",
        ),
        "local_dist_dir": attr.string(
            default = "",
            doc = "Local directory containing prebuilt archives (for development). If specified and file exists, will use local file instead of downloading.",
        ),
    },
    doc = """Downloads prebuilt LLVM/Flang binaries from GitHub releases.
    
    This repository rule automatically detects the current platform and
    downloads the appropriate prebuilt binaries.
    
    Example:
        llvm_flang_prebuilt(
            name = "llvm_flang",
            version = "v21.1.3",
            repo_owner = "your-org",
            repo_name = "llvm-flang-builds",
            sha256 = {
                "x86_64-linux-gnu": "abc123...",
                "aarch64-linux-gnu": "def456...",
                "x86_64-apple-darwin": "ghi789...",
                "aarch64-apple-darwin": "jkl012...",
            },
        )
    """,
)

def _llvm_flang_multiplatform_impl(repository_ctx):
    """Create a platform-aware LLVM/Flang repository."""
    
    target_triple, os_type, arch = _get_platform_info(repository_ctx)
    
    # Select the appropriate repository based on platform
    build_content = """
package(default_visibility = ["//visibility:public"])

platform(
    name = "host_platform",
    constraint_values = [
        "@platforms//os:{os}",
        "@platforms//cpu:{arch}",
    ],
)

alias(
    name = "flang-new",
    actual = select({{
        "@platforms//os:linux": "@llvm_flang_linux_{arch}//:flang-new",
        "@platforms//os:macos": "@llvm_flang_macos_{arch}//:flang-new",
        "@platforms//os:windows": "@llvm_flang_windows_{arch}//:flang-new",
    }}),
)

alias(
    name = "llvm-ar",
    actual = select({{
        "@platforms//os:linux": "@llvm_flang_linux_{arch}//:llvm-ar",
        "@platforms//os:macos": "@llvm_flang_macos_{arch}//:llvm-ar",
        "@platforms//os:windows": "@llvm_flang_windows_{arch}//:llvm-ar",
    }}),
)

filegroup(
    name = "all_files",
    srcs = select({{
        "@platforms//os:linux": ["@llvm_flang_linux_{arch}//:all_files"],
        "@platforms//os:macos": ["@llvm_flang_macos_{arch}//:all_files"],
        "@platforms//os:windows": ["@llvm_flang_windows_{arch}//:all_files"],
    }}),
)
""".format(os = os_type, arch = arch)
    
    repository_ctx.file("BUILD.bazel", build_content)
    repository_ctx.file("WORKSPACE", 'workspace(name = "{}")'.format(repository_ctx.name))

llvm_flang_multiplatform = repository_rule(
    implementation = _llvm_flang_multiplatform_impl,
    doc = """Creates platform-aware aliases for LLVM/Flang repositories.
    
    This is a convenience rule that creates aliases to platform-specific
    LLVM/Flang repositories.
    """,
)

def register_llvm_flang_toolchains(
        name = "llvm_flang",
        version = "v21.1.3",
        repo_owner = "miinso",
        repo_name = "flang",
        url_template = None,
        sha256 = {},
        local_dist_dir = "",
        register_all = True):
    """Register LLVM/Flang toolchains for all supported platforms.

    Args:
        name: Base name for repositories
        version: LLVM/Flang version tag
        repo_owner: GitHub repository owner
        repo_name: GitHub repository name
        url_template: Custom URL template (optional)
        sha256: Dictionary of SHA256 checksums per platform
        local_dist_dir: Local directory with prebuilt archives (for development)
        register_all: Whether to register toolchains for all platforms

    Example:
        register_llvm_flang_toolchains(
            version = "v21.1.3",
            repo_owner = "miinso",
            repo_name = "flang",
            local_dist_dir = "dist",  # Use local files from dist/ folder
            sha256 = {
                "x86_64-unknown-linux-gnu": "abc...",
                "aarch64-linux-gnu": "def...",
                "x86_64-apple-darwin": "ghi...",
                "arm64-apple-darwin": "jkl...",
                "x86_64-pc-windows-msvc": "mno...",
            },
        )
    """

    # Define all supported platforms
    # Map internal names to target triples matching the archive names
    platforms = {
        "linux_x86_64": "x86_64-unknown-linux-gnu",
        "linux_aarch64": "aarch64-linux-gnu",
        "macos_x86_64": "x86_64-apple-darwin",
        "macos_aarch64": "arm64-apple-darwin",
        "windows_x86_64": "x86_64-pc-windows-msvc",
    }

    # Create repositories for each platform
    for platform_name, target_triple in platforms.items():
        repo_name_full = "{}_{}".format(name, platform_name)

        llvm_flang_prebuilt(
            name = repo_name_full,
            version = version,
            repo_owner = repo_owner,
            repo_name = repo_name,
            url_template = url_template,
            sha256 = sha256,
            local_dist_dir = local_dist_dir,
        )

    # Create multiplatform alias repository
    llvm_flang_multiplatform(
        name = name,
    )
