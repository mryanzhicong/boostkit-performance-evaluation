#!/usr/bin/env bash
# Build-stage dispatcher: the case has a single variant.
set -o pipefail

FIO_CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck disable=SC1091
source "${FIO_CASE_DIR}/scripts/common.sh"
# shellcheck disable=SC1091
source "${FIO_CASE_DIR}/scripts/builders/base.sh"

build_fio() {
    configure_runtime_paths
    case "${PERF_VARIANT}" in
        base)
            build_fio_base
            ;;
        optimized)
            build_fio_optimized
            ;;
        *)
            log "ERROR: unknown variant '${PERF_VARIANT}'"
            return 30
            ;;
    esac
}

# The framework sources this file and calls build_fio; keep the entry point last.
