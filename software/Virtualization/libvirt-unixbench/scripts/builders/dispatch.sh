#!/usr/bin/env bash
set -euo pipefail
# Stage dispatcher: the framework calls the function named in case.yaml, which the
# variant script defines.  Only the base variant exists today.
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
