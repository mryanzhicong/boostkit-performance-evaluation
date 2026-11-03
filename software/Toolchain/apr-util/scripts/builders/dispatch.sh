#!/usr/bin/env bash
# Variant dispatch for the APR-util case.
#
# The base variant builds the pinned APR and APR-util releases as static
# libraries.  The optimized variant is reserved: it fails clearly (exit 30) and
# never writes build_variant.json, so a caller can never mistake a failed
# optimized request for a valid base measurement.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/base.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/optimized.sh"

write_build_variant() {
    local variant="$1"
    python3 - "${RESULTS_DIR}/build_variant.json" "${variant}" <<'PY'
import json
import sys
from pathlib import Path

output = Path(sys.argv[1])
variant = sys.argv[2]
output.parent.mkdir(parents=True, exist_ok=True)
output.write_text(
    json.dumps({"variant": variant, "parameters": {"variant": variant}}, ensure_ascii=False)
    + "\n",
    encoding="utf-8",
)
PY
}

build_apr_util() {
    validate_variant || return $?
    validate_version || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    mkdir -p "${APR_UTIL_STATE_DIR}" "${TMPDIR}" || {
        fail_message "cannot create the build state directory"
        return 30
    }
    case "${PERF_VARIANT}" in
        base)
            build_apr_util_base || return $?
            write_build_variant base || return 30
            ;;
        optimized)
            build_apr_util_optimized || return $?
            ;;
        *)
            fail_message "unsupported variant: ${PERF_VARIANT}"
            return 10
            ;;
    esac
    log_message "build variant ${PERF_VARIANT} finished"
    return 0
}
