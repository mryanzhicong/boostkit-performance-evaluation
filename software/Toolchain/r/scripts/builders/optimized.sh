#!/usr/bin/env bash
set -euo pipefail

# The optimized variant is intentionally reserved: it must fail explicitly
# instead of silently reusing the base build, and must not write
# build_variant.json (the framework treats exit code 30 as a build failure).
echo "ERROR: optimized variant is not implemented for r" >&2
exit 30
