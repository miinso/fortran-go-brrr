"""Repository rules for downloading prebuilt Flang binaries."""

# Supported platforms and their target triples
PLATFORMS = {
    "linux_x86_64": "x86_64-unknown-linux-gnu",
    "linux_aarch64": "aarch64-linux-gnu",
    "macos_x86_64": "x86_64-apple-darwin",
    "macos_aarch64": "arm64-apple-darwin",
    "windows_x86_64": "x86_64-pc-windows-msvc",
}

def _get_platform_info(repository_ctx):
    """Determine the current platform and return target triple."""
    os_name = repository_ctx.os.name.lower()
    arch = repository_ctx.os.arch.lower()

    arch_map = {
        "amd64": "x86_64",
        "x86_64": "x86_64",
        "x64": "x86_64",
        "aarch64": "arm64",
        "arm64": "arm64",
    }
    normalized_arch = arch_map.get(arch, arch)

    if "linux" in os_name:
        if normalized_arch == "x86_64":
            return "x86_64-unknown-linux-gnu-static", "linux", normalized_arch
        elif normalized_arch == "arm64":
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

def _create_build_file(repository_ctx):
    """Create BUILD.bazel for the Flang repository."""
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
    srcs = glob(["bin/clang*"], allow_empty = True),
)

filegroup(
    name = "lld",
    srcs = glob(["bin/ld.lld*", "bin/lld*"], allow_empty = True),
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

filegroup(
    name = "runtime_libraries",
    srcs = select({
        "@platforms//os:windows": glob([
            "lib/clang/*/lib/*/flang_rt.runtime.static.lib",
            "lib/clang/*/lib/*/clang_rt.builtins-*.lib",
        ], allow_empty = True),
        "@platforms//os:macos": glob([
            "lib/clang/*/lib/*/libflang_rt.runtime.a",
            "lib/clang/*/lib/*/libclang_rt.osx.a",
        ], allow_empty = True),
        "@platforms//os:linux": glob([
            "lib/clang/*/lib/*/libflang_rt.runtime.a",
            "lib/clang/*/lib/*/libclang_rt.builtins.a",
        ], exclude = [
            "lib/clang/*/lib/i386*/**",
            "lib/clang/*/lib/*-i386/**",
        ], allow_empty = True),
        "//conditions:default": [],
    }),
)

exports_files(
    glob(["bin/*", "lib/*"], allow_empty = True),
)
""")

def _flang_prebuilt_impl(repository_ctx):
    """Download prebuilt Flang from GitHub releases."""
    target_triple, os_type, _ = _get_platform_info(repository_ctx)

    version = repository_ctx.attr.version
    version_no_prefix = version[1:] if version.startswith("v") else version

    file_ext = "zip" if os_type == "windows" else "tar.gz"
    filename = "flang+llvm-{}-{}.{}".format(version_no_prefix, target_triple, file_ext)

    url = "https://github.com/{}/{}/releases/download/{}/{}".format(
        repository_ctx.attr.repo_owner,
        repository_ctx.attr.repo_name,
        version,
        filename,
    )

    if repository_ctx.attr.url_template:
        url = repository_ctx.attr.url_template.format(
            version = version,
            target_triple = target_triple,
            os = os_type,
        )

    repository_ctx.download_and_extract(
        url = url,
        sha256 = repository_ctx.attr.sha256.get(target_triple, ""),
        stripPrefix = repository_ctx.attr.strip_prefix,
    )

    _create_build_file(repository_ctx)

_flang_prebuilt = repository_rule(
    implementation = _flang_prebuilt_impl,
    attrs = {
        "version": attr.string(mandatory = True),
        "repo_owner": attr.string(mandatory = True),
        "repo_name": attr.string(mandatory = True),
        "url_template": attr.string(),
        "strip_prefix": attr.string(default = "flang+llvm-21.1.3"),
        "sha256": attr.string_dict(default = {}),
    },
)

def flang_register_toolchains(
        name = "flang",
        version = "v21.1.3",
        repo_owner = "miinso",
        repo_name = "flang",
        url_template = None,
        sha256 = {}):
    """Register Flang toolchains for all supported platforms.

    Args:
        name: Base name for repositories (default: "flang")
        version: Flang version tag (default: "v21.1.3")
        repo_owner: GitHub repository owner (default: "miinso")
        repo_name: GitHub repository name (default: "flang")
        url_template: Custom URL template (optional)
        sha256: SHA256 checksums per target triple (optional)
    """
    for platform_name in PLATFORMS.keys():
        _flang_prebuilt(
            name = "{}_{}".format(name, platform_name),
            version = version,
            repo_owner = repo_owner,
            repo_name = repo_name,
            url_template = url_template,
            sha256 = sha256,
        )
