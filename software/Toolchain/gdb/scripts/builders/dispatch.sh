#!/usr/bin/env bash
# Build-stage entry point: dispatch between the base and the (unsupported) optimized
# variant.  The framework calls ``build_gdb`` from this file.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "${SCRIPT_DIR}/scripts/builders/base.sh"
source "${SCRIPT_DIR}/scripts/builders/optimized.sh"

build_gdb() {
    initialize_runtime || return $?
    validate_variant || return $?
    validate_reps || return $?
    case "${PERF_VARIANT}" in
        base)
            build_gdb_base
            ;;
        optimized)
            build_gdb_optimized
            ;;
        *)
            fail_message "unsupported build variant: ${PERF_VARIANT}"
            return 30
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    build_gdb
    exit $?
fi
