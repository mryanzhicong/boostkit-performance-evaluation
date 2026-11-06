#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_jemalloc() {
    case "${PERF_VARIANT:-base}" in
        base) ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_jemalloc_optimized
            return $?
            ;;
        *) jemalloc_log "ERROR: unsupported build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    [[ -x /home/runner/software/jemalloc/malloc_benchmark ]] || {
        jemalloc_log 'ERROR: preinstalled malloc_benchmark is missing; place the architecture-specific binary before a Framework run'
        return 30
    }
    bash "${SCRIPT_DIR}/scripts/builders/base.sh"
}
