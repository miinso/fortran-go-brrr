#!/usr/bin/env python3
"""Cross-platform wrapper script to run BLAS tests with input redirection."""
import sys
import subprocess
import os

binary = sys.argv[1]
input_file = sys.argv[2]

# Bazel on Windows puts external repos in parent runfiles
# 1) Strip "external/", 2) append "..", then 3) use the right slash
# "external/_main~repo~blas/foo" -> "..\_main~repo~blas\foo"
if os.name == 'nt':
    binary = os.path.normpath(os.path.join('..', binary[9:]))

with open(input_file, 'r') as f:
    subprocess.run([binary], stdin=f, check=True, text=True)
