#!/usr/bin/env bash
# ==============================================================================
# libwebp start stage -- validate the containerised payload before measuring.
# ==============================================================================
# The private container is created by the build stage and stays alive until the
# stop stage; nothing is measured here.  The stage proves that the container
# really carries the pinned cwebp/dwebp build, that the benchmark harness is
# readable through the case mount and that the measurement process is not
# confined to a subset of the CPUs.  The benchmark inputs are generated inside
# the container by the harness, so there is no media mount to probe.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_libwebp_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_libwebp_docker || return $?
    check_libwebp_container || return 40
    libwebp_verify_runtime_payload || return $?
    libwebp_container_exec test -r "${SCRIPT_DIR}/scripts/harness/bench_encode.py" || {
        log_message "ERROR: the encode harness is not readable in the container"
        return 30
    }
    libwebp_container_exec test -r "${SCRIPT_DIR}/fixtures/media.json" || {
        log_message "ERROR: the scenario manifest is not readable in the container"
        return 30
    }

    libwebp_container_exec sh -c 'grep -m1 "model name" /proc/cpuinfo || true; printf "cpus: %s\n" "$(nproc)"'
    # Evidence that the measurement is NOT pinned: the container process sees the
    # whole CPU set and the whole NUMA topology.
    libwebp_container_exec python3 -c \
        'import os; cpus = sorted(os.sched_getaffinity(0)); print(f"allowed cpus: {len(cpus)} ({cpus[0]}-{cpus[-1]})")'
    log_message "container ${LIBWEBP_CONTAINER_NAME} is ready; no CPU/memory pinning, generated dashboard inputs"
}
