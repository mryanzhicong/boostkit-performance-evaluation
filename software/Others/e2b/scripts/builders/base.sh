#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_e2b_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "${E2B_RPM_VERSION}" ]] || {
        log "ERROR: only E2B ${E2B_RPM_VERSION} is supported by this case"; return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: the runner architecture differs from the requested architecture'; return 20
    }
    host_preflight || return $?
    bash "${SCRIPT_DIR}/scripts/host/stage-e2b-artifacts.sh" || return $?
    bash "${SCRIPT_DIR}/scripts/host/install-e2b-suite.sh" || return $?
    ensure_go || return $?
    build_bench_binary || return $?
    write_actual_version "${E2B_RPM_VERSION}"
    log "build complete: E2B ${E2B_RPM_VERSION} under ${E2B_INSTALL_DIR}, sandbox-bench at ${E2B_BENCH_BIN}"
}
