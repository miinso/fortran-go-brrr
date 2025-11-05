#!/bin/bash
# Generic wrapper script to run tests with input redirection
set -e

BINARY="$1"
INPUT="$2"

"$BINARY" < "$INPUT"
