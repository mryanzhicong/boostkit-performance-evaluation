#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_cubesandbox_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == 0.8.0 ]] || {
        log 'ERROR: only CubeSandbox 0.8.0 is supported by this case'; return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: the runner architecture differs from the requested architecture'; return 20
    }
    host_preflight || return $?
    prepare_source || return $?
    ensure_go || return $?
    build_cube_bench || return $?
    local reported="${CUBESANDBOX_RELEASE_TAG#v}"
    printf '%s\n' "${reported}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "build complete: CubeSandbox ${reported} benchmark client from commit ${CUBESANDBOX_COMMIT}"
}
