"""Bzlmod extensions for rules_fortran."""

load("//fortran:llvm_repositories.bzl", "register_llvm_flang_toolchains")

def _llvm_flang_impl(module_ctx):
    """Implementation of llvm_flang extension."""

    # Collect all prebuilt configurations
    for mod in module_ctx.modules:
        for prebuilt in mod.tags.prebuilt:
            register_llvm_flang_toolchains(
                name = prebuilt.name,
                version = prebuilt.version,
                repo_owner = prebuilt.repo_owner,
                repo_name = prebuilt.repo_name,
                url_template = prebuilt.url_template if prebuilt.url_template else None,
                sha256 = prebuilt.sha256,
                register_all = True,
            )

_prebuilt = tag_class(
    attrs = {
        "name": attr.string(
            default = "llvm_flang",
            doc = "Repository name",
        ),
        "version": attr.string(
            mandatory = True,
            doc = "LLVM/Flang version (e.g., 'v21.1.3')",
        ),
        "repo_owner": attr.string(
            mandatory = True,
            doc = "GitHub repository owner",
        ),
        "repo_name": attr.string(
            mandatory = True,
            doc = "GitHub repository name",
        ),
        "url_template": attr.string(
            doc = "Custom URL template",
        ),
        "sha256": attr.string_dict(
            doc = "SHA256 checksums per platform",
        ),
    },
)

llvm_flang = module_extension(
    implementation = _llvm_flang_impl,
    tag_classes = {
        "prebuilt": _prebuilt,
    },
    doc = """Module extension for configuring LLVM/Flang toolchains.

    Example:
        llvm_flang = use_extension("@rules_fortran//fortran:extensions.bzl", "llvm_flang")

        llvm_flang.prebuilt(
            version = "v21.1.3",
            repo_owner = "miinso",
            repo_name = "flang",
            sha256 = {...},
        )

        use_repo(llvm_flang, "llvm_flang")
    """,
)
