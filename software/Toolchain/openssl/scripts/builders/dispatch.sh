#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
source "$(dirname "${BASH_SOURCE[0]}")/optimized.sh"

build_openssl() {
    openssl_configure_paths || return $?
    case "${PERF_VARIANT:-base}" in
        base) build_openssl_base || return $? ;;
        optimized) build_openssl_optimized || return $? ;;
        *) log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
    [[ -s "${RESULTS_DIR}/build_variant.json" ]] || {
        log_message 'ERROR: build stage did not produce build_variant.json'
        return 40
    }
    log_message "build stage finished: variant=${PERF_VARIANT} version=${SOFTWARE_VERSION}"
}
