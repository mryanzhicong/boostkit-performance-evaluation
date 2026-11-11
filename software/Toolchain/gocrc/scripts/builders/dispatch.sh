#!/usr/bin/env bash
# Dispatch the build stage.  There is no variant-specific build: the unified
# procedure installs the bootstrap Go release and builds the openEuler golang
# go1.24.6 toolchain from source on every architecture.  `PERF_VARIANT` is kept
# as a label so the existing workflow dropdowns stay valid.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_gocrc() {
    validate_variant || return $?
    initialize_runtime || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_gocrc_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_gocrc_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"},"software_version":"%s","toolchains":{"bootstrap":{"version":"%s","goroot":"%s"},"measured":{"version":"%s","goroot":"%s","source_commit":"%s"},"architecture":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" "${SOFTWARE_VERSION}" \
        "${GO_BOOTSTRAP_VERSION}" "${GO_BOOTSTRAP_GOROOT}" \
        "${GO_OPTIMIZED_VERSION}" "${GO_OPTIMIZED_GOROOT}" "${GO_SRC_COMMIT}" \
        "${EXPECTED_ARCH}" \
        > "${RESULTS_DIR}/build_variant.json"
    return 0
}
