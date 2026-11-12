#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_torchvision_runtime() {
    local minimum_bytes source_video source_bytes source_sha256
    initialize_runtime || return $?
    check_torchvision_container || return $?
    container_exec python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py" || {
        log 'ERROR: pinned TorchVision CPU runtime is not usable inside the container'
        return 40
    }
    minimum_bytes=$((1920 * 1080 * 3 / 2))
    for source_video in \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_BQ}" \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_FILM}" \
        "${TORCHVISION_VIDEO_DIR}/${TORCHVISION_VIDEO_MESSI}"; do
        [[ -f "${source_video}" ]] || {
            log "ERROR: reference video is missing: ${source_video}"
            return 40
        }
        source_bytes="$(stat -c '%s' "${source_video}")"
        if (( source_bytes < minimum_bytes )); then
            log "ERROR: reference video needs at least one complete frame: ${source_video}"
            return 40
        fi
        source_sha256="$(sha256sum "${source_video}" | awk '{print $1}')"
        log "source video: ${source_video} (${source_bytes} bytes, sha256 ${source_sha256})"
    done
    if [[ -d "${TORCHVISION_WEIGHT_DIR}" ]]; then
        log "local weight directory is available: ${TORCHVISION_WEIGHT_DIR}"
    else
        log 'local weight directory is absent; torchvision will download official weights'
    fi
    log 'TorchVision runtime and input videos are ready inside the private container'
}
