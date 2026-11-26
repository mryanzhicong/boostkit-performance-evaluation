#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

release_data_volume() {
    local state="${RESULTS_DIR}/data_volume"
    if [[ ! -f "${state}" ]]; then
        log "leaving the pre-existing ${CUBESANDBOX_DATA_DIR} volume in place (this run did not create it)"
        return 0
    fi
    local loop="" line
    while IFS= read -r line; do
        case "${line}" in
            loop=*) loop="${line#loop=}" ;;
            img=*) CUBESANDBOX_DATA_IMG="${line#img=}" ;;
        esac
    done <"${state}"
    [[ -n "${CUBESANDBOX_DATA_LOOP}" ]] && loop="${CUBESANDBOX_DATA_LOOP}"
    if mountpoint -q "${CUBESANDBOX_DATA_DIR}" 2>/dev/null; then
        log "unmounting the case-managed volume at ${CUBESANDBOX_DATA_DIR}"
        sudo -n umount "${CUBESANDBOX_DATA_DIR}" 2>/dev/null || return 50
    fi
    if [[ -n "${loop}" ]]; then
        sudo -n losetup -d "${loop}" 2>/dev/null || true
    fi
    if [[ -e "${CUBESANDBOX_DATA_IMG}" ]]; then
        sudo -n rm -f "${CUBESANDBOX_DATA_IMG}" 2>/dev/null || true
    fi
    sudo -n rmdir "${CUBESANDBOX_DATA_DIR}" 2>/dev/null || true
    rm -f -- "${state}" 2>/dev/null || true
    CUBESANDBOX_DATA_CREATED=0
    return 0
}

stop_cubesandbox_runtime() {
    local status=0
    initialize_runtime >/dev/null 2>&1 || true
    if cubesandbox_resolve_cli_dir >/dev/null 2>&1; then
        cleanup_sandboxes || { log 'ERROR: sandbox cleanup failed'; status=50; }
    else
        log 'CubeSandbox CLIs are not installed; nothing to clean'
    fi
    release_data_volume || status=50
    if [[ "${CUBESANDBOX_TEARDOWN:-0}" == 1 ]]; then
        local down_script=""
        if [[ -n "${CUBESANDBOX_PACKAGE_DIR}" && -f "${CUBESANDBOX_PACKAGE_DIR}/down.sh" ]]; then
            down_script="${CUBESANDBOX_PACKAGE_DIR}/down.sh"
        else
            down_script="$(sudo -n find /usr/local /opt /home -maxdepth 8 -name 'down.sh' 2>/dev/null | head -1 || true)"
        fi
        if [[ -n "${down_script}" ]]; then
            log "tearing down the CubeSandbox installation (CUBESANDBOX_TEARDOWN=1)"
            ( cd "$(dirname "${down_script}")" && sudo -n bash ./down.sh ) \
                >"${PERF_WORK_DIR}/one-click-down.log" 2>&1 || status=50
        else
            log 'no one-click down.sh found; leaving the installation in place'
        fi
    fi
    restore_host_dns || log 'WARN: the host resolv.conf restore did not complete cleanly'
    return "${status}"
}
