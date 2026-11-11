#!/usr/bin/env bash
# ==============================================================================
# opencv start stage -- validate the containerised payload before measuring.
# ==============================================================================
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_opencv_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    opencv_resolve_media || return $?
    require_opencv_docker || return $?
    check_opencv_container || return 40
    opencv_verify_runtime_payload || return $?
    opencv_media_probe || return $?

    opencv_container_exec sh -c 'grep -m1 "model name" /proc/cpuinfo || true; printf "cpus: %s\n" "$(nproc)"'
    # Evidence that the measurement is NOT pinned: the process sees the whole CPU set.
    opencv_container_exec python3 -c \
        'import os; cpus = sorted(os.sched_getaffinity(0)); print(f"allowed cpus: {len(cpus)} ({cpus[0]}-{cpus[-1]})")'
    log_message "container ${OPENCV_CONTAINER_NAME} is ready; media: ${OPENCV_MEDIA_DIR}"
}
