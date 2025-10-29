"""Repository rules for downloading prebuilt LLVM/Flang binaries."""

def _get_platform_info(repository_ctx):
    """Determine the current platform and return target triple."""
    
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()
    
    # Normalize architecture names
    arch_map = {
        "amd64": "x86_64",
        "x86_64": "x86_64",
        "x64": "x86_64",
        "aarch64": "aarch64",
        "arm64": "aarch64",
    }
    arch = arch_map.get(arch, arch)
    
    # Determine target triple
    if "linux" in os_name:
        if arch == "x86_64":
            return "x86_64-linux-gnu", "linux", arch
        elif arch == "aarch64":
            return "aarch64-linux-gnu", "linux", arch
    elif "mac" in os_name or "darwin" in os_name:
        if arch == "x86_64":
            return "x86_64-apple-darwin", "macos", arch
        elif arch == "aarch64":
            return "aarch64-apple-darwin", "macos", arch
    elif "windows" in os_name:
        if arch == "x86_64":
            return "x86_64-pc-windows-msvc", "windows", arch
        elif arch == "aarch64":
            return "aarch64-pc-windows-msvc", "windows", arch
    
    fail("Unsupported platform: {} {}".format(os_name, arch))

def _llvm_flang_prebuilt_impl(repository_ctx):
    """Download prebuilt LLVM/Flang from GitHub releases."""
    
    # Get platform information
    target_triple, os_type, arch = _get_platform_info(repository_ctx)
    
    # Get configuration
    version = repository_ctx.attr.version
    repo_owner = repository_ctx.attr.repo_owner
    repo_name = repository_ctx.attr.repo_name
    
    # Construct filename and URL
    # Format: llvm-flang-{version}-{target-triple}.tar.gz
    filename = "llvm-flang-{}-{}.tar.gz".format(version, target_triple)
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
    
    # Create BUILD file for the toolchain
    repository_ctx.file("BUILD.bazel", """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "flang-new",
    srcs = ["bin/flang-new"],
)

filegroup(
    name = "llvm-ar",
    srcs = ["bin/llvm-ar"],
)

filegroup(
    name = "clang",
    srcs = ["bin/clang"],
)

filegroup(
    name = "lld",
    srcs = ["bin/ld.lld"],
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

# Export binaries for toolchain use
exports_files([
    "bin/flang-new",
    "bin/llvm-ar",
    "bin/clang",
    "bin/ld.lld",
])
""")
    
    # Create WORKSPACE file
    repository_ctx.file("WORKSPACE", """
workspace(name = "{}")
""".format(repository_ctx.name))
    
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
            default = "",
            doc = "Strip prefix from extracted archive",
        ),
        "sha256": attr.string_dict(
            default = {},
            doc = "SHA256 checksums for each target triple",
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
        repo_name = "llvm-flang-builds",
        url_template = None,
        sha256 = {},
        register_all = True):
    """Register LLVM/Flang toolchains for all supported platforms.
    
    Args:
        name: Base name for repositories
        version: LLVM/Flang version tag
        repo_owner: GitHub repository owner
        repo_name: GitHub repository name
        url_template: Custom URL template (optional)
        sha256: Dictionary of SHA256 checksums per platform
        register_all: Whether to register toolchains for all platforms
    
    Example:
        register_llvm_flang_toolchains(
            version = "v21.1.3",
            repo_owner = "myorg",
            repo_name = "llvm-builds",
            sha256 = {
                "x86_64-linux-gnu": "abc...",
                "aarch64-linux-gnu": "def...",
                "x86_64-apple-darwin": "ghi...",
                "aarch64-apple-darwin": "jkl...",
            },
        )
    """
    
    # Define all supported platforms
    platforms = {
        "linux_x86_64": "x86_64-linux-gnu",
        "linux_aarch64": "aarch64-linux-gnu",
        "macos_x86_64": "x86_64-apple-darwin",
        "macos_aarch64": "aarch64-apple-darwin",
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
        )
    
    # Create multiplatform alias repository
    llvm_flang_multiplatform(
        name = name,
    )
