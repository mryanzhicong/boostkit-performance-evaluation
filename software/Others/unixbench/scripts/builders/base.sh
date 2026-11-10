#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_unixbench_base() {
    local archive local_archive actual_version
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == 6.0.1 ]] || { log 'ERROR: only UnixBench 6.0.1 is supported'; return 10; }
    [[ "$(normalize_arch "$(uname -m)")" == "$(normalize_arch "${EXPECTED_ARCH}")" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'; return 20;
    }
    require_unixbench_vm_host || return $?
    start_unixbench_vm || return $?
    verify_unixbench_guest_os || return $?
    capture_unixbench_vm_environment || return $?
    install_unixbench_guest_packages || return $?
    archive="${PERF_WORK_DIR}/v6.0.1.tar.gz"
    local_archive="${UNIXBENCH_ARCHIVE_DIR}/v6.0.1.tar.gz"
    if [[ -f "${local_archive}" ]]; then
        log "using local archive ${local_archive}"
        cp -- "${local_archive}" "${archive}" || return 30
    else
        log "downloading official archive ${UNIXBENCH_ARCHIVE_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 -o "${archive}.part" "${UNIXBENCH_ARCHIVE_URL}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${UNIXBENCH_ARCHIVE_SHA256}" "${archive}" | sha256sum -c - || {
        log 'ERROR: official archive checksum mismatch'; return 30;
    }
    tar -tzf "${archive}" | python3 "${SCRIPT_DIR}/scripts/results/verify_archive.py" || return 30
    vm_copy_in "${archive}" "/root/v6.0.1.tar.gz" || return 30
    vm_exec tar -xzf /root/v6.0.1.tar.gz -C /root || return 40
    vm_exec test -f "${GUEST_RUN_DIR}/Run" || { log 'ERROR: UnixBench/Run is missing inside the reference VM'; return 40; }
    vm_copy_out "${GUEST_RUN_DIR}/Run" "${PERF_WORK_DIR}/Run" || return 40
    actual_version="$(sed -n 's/^my \$version = "\([^"]*\)";.*/\1/p' "${PERF_WORK_DIR}/Run")"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: requested ${SOFTWARE_VERSION}, source reports ${actual_version}"; return 40;
    }
    log 'building upstream UnixBench inside the reference VM without source patches'
    vm_exec make -C "${GUEST_RUN_DIR}" -j "${UNIXBENCH_VM_VCPUS}" || return 40
    vm_exec test -x "${GUEST_RUN_DIR}/pgms/dhry2reg" || {
        log 'ERROR: UnixBench build is incomplete'; return 40;
    }
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}
