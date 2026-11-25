#!/usr/bin/env bash
# Optimized build: the same upstream commit with the case-owned BoostKit Kunpeng
# patch applied on a copy of the source tree.  The patch must be present and
# match its pinned SHA-256; otherwise the build fails instead of falling back to
# the unpatched base tree.
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"

build_rapidjson_optimized() {
    local run_id="${PERF_RUN_ID}" arch
    rapidjson_check_inputs || return $?
    arch="$(rapidjson_arch "${EXPECTED_ARCH}")"
    log_message "optimized build: rapidjson ${SOFTWARE_VERSION} + ${RAPIDJSON_PATCH_FILE} on ${arch} (run ${run_id})"
    if [[ "${arch}" == "aarch64" ]]; then
        log_message 'aarch64: appending -march=armv8.2-a+simd -DRAPIDJSON_NEON'
    fi

    require_rapidjson_docker || return $?
    rapidjson_verify_patch || return 30
    rapidjson_fetch_inputs || return $?
    start_rapidjson_container || return $?
    trap 'remove_rapidjson_container || true' EXIT

    rapidjson_install_dependencies || return $?
    rapidjson_unpack_sources || return $?
    rapidjson_apply_patch || return $?
    rapidjson_compile || return $?
    rapidjson_smoke_test || return $?
    rapidjson_detect_version || return $?
    rapidjson_write_build_variant || return $?

    trap - EXIT
    log_message "optimized build finished; container ${RAPIDJSON_CONTAINER_NAME} is retained for the start/test stages"
}
