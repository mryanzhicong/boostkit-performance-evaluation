#!/usr/bin/env bash
# ==============================================================================
# Tongsuo start stage -- validate the containerised payload before measuring.
# ==============================================================================
# The private container is created by the build stage and stays alive until the
# stop stage; nothing is measured here.  The stage proves that the container
# really carries the pinned in-tree `apps/openssl` build, that the result and case
# directories are visible through the case mount and that the measurement process
# is not confined to a subset of the CPUs.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_tongsuo_runtime() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_tongsuo_docker || return $?
    check_tongsuo_container || return 40
    tongsuo_verify_runtime_payload || return $?
    tongsuo_container_exec test -r "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" || {
        log_message "ERROR: the strict parser is not readable in the container"
        return 30
    }

    tongsuo_container_exec sh -c 'grep -m1 "model name" /proc/cpuinfo || true; printf "cpus: %s\n" "$(nproc)"'
    # Evidence that the measurement is NOT pinned: the container process sees the
    # whole CPU set and the whole NUMA topology.
    tongsuo_container_exec python3 -c \
        'import os; cpus = sorted(os.sched_getaffinity(0)); print(f"allowed cpus: {len(cpus)} ({cpus[0]}-{cpus[-1]})")' \
        2>/dev/null || tongsuo_container_exec nproc
    tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./apps/openssl version -a | head -n 6 || true
    log_message "container ${TONGSUO_CONTAINER_NAME} is ready; no CPU/memory pinning, ${TONGSUO_WARMUPS} warm-up + ${TONGSUO_SAMPLES} samples per scenario"
}
