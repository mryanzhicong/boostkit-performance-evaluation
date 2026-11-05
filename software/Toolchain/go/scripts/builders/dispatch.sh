#!/usr/bin/env bash
# Dispatch the build stage.  There is no variant-specific build any more: the
# unified procedure installs the official Go release and builds the openEuler
# golang go1.24.6 toolchain from source on every architecture.  `PERF_VARIANT`
# is kept as a label so the existing workflow dropdowns stay valid.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_go() {
    validate_variant || return $?
    initialize_runtime || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_go_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_go_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"},"toolchains":{"official":"%s","optimized":"%s","architecture":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" "${SOFTWARE_VERSION}" "${GO_OPTIMIZED_VERSION}" "${EXPECTED_ARCH}" \
        > "${RESULTS_DIR}/build_variant.json"
    return 0
}
