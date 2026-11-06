#!/usr/bin/env bash
# ==============================================================================
# libavif start stage -- validate the containerised payload before measuring.
# ==============================================================================
# The private container is created by the build stage and stays alive until the
# stop stage; nothing is measured here.  The stage proves that the container
# really carries the pinned avifenc/avifdec build, that the open-box media is
# readable through the read-only mount and that the measurement process is not
# confined to a subset of the CPUs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_libavif_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    libavif_resolve_media || return $?
    require_libavif_docker || return $?
    check_libavif_container || return 40
    libavif_verify_runtime_payload || return $?
    libavif_media_probe || return $?

    libavif_container_exec sh -c 'grep -m1 "model name" /proc/cpuinfo || true; printf "cpus: %s\n" "$(nproc)"'
    # Evidence that the measurement is NOT pinned: the container process sees the
    # whole CPU set and the whole NUMA topology.
    libavif_container_exec python3 -c \
        'import os; cpus = sorted(os.sched_getaffinity(0)); print(f"allowed cpus: {len(cpus)} ({cpus[0]}-{cpus[-1]})")'
    log_message "container ${LIBAVIF_CONTAINER_NAME} is ready; media: ${LIBAVIF_MEDIA_DIR}"
}
