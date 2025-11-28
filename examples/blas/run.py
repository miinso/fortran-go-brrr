#!/usr/bin/env python3
"""Cross-platform wrapper script to run BLAS tests with input redirection."""
import sys
import subprocess
import os

binary = sys.argv[1]
input_file = sys.argv[2]

# Bazel runfiles paths:
# - bzlmod: "../+_repo_rules+blas/sblat2" (already relative, needs normpath on Windows)
# - WORKSPACE: "external/_main~repo~blas/foo" (needs "../" prefix + strip "external/")
if os.name == 'nt':
    if binary.startswith('external/'):
        # Old WORKSPACE-style path
        binary = os.path.normpath(os.path.join('..', binary[9:]))
    else:
        # bzlmod-style path (already relative)
        binary = os.path.normpath(binary)

with open(input_file, 'r') as f:
    subprocess.run([binary], stdin=f, check=True, text=True)
