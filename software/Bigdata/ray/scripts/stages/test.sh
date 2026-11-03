#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_ray_benchmark() {
    initialize_runtime || return $?
    check_ray_container || return $?
    ray_container_exec test -x "${RAY_VENV}/bin/python" || return 50
    ray_container_exec test -s "${RAY_SHUFFLE_SCRIPT}" || return 50
    log_message "running official single-node Shuffle: ${RAY_NUM_PARTITIONS} x ${RAY_PARTITION_SIZE} bytes, ${RAY_WARMUP_ROUNDS} warmup + ${RAY_FORMAL_ROUNDS} formal rounds"
    ray_container_exec env "PATH=${RAY_VENV}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
        "VIRTUAL_ENV=${RAY_VENV}" "${RAY_VENV}/bin/python" "${RAY_RUNNER_SCRIPT}" \
        --shuffle-script "${RAY_SHUFFLE_SCRIPT}" \
        --work-dir "${PERF_WORK_DIR}" \
        --ray-temp-dir "${RAY_SOCKET_DIR}" \
        --results-dir "${RESULTS_DIR}" || {
        log_message 'ERROR: official Ray Shuffle benchmark failed'
        return 50
    }
}
