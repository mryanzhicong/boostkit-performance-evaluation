#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_ray_runtime() {
    initialize_runtime || return $?
    check_ray_container || return $?
    ray_container_exec test -x "${RAY_VENV}/bin/python" || {
        log_message 'ERROR: private official Ray runtime or shuffle script is missing'
        return 40
    }
    ray_container_exec test -s "${RAY_SHUFFLE_SCRIPT}" || return 40
    ray_container_exec test -s "${RAY_RUNNER_SCRIPT}" || return 40
    verify_shuffle_python_dependencies || return 40
    local available_cpus available_shm
    available_cpus="$(ray_container_exec nproc)" || return 40
    available_shm="$(ray_container_exec df -B1 --output=avail /dev/shm | tail -1 | tr -d ' ')" || return 40
    [[ "${available_cpus}" =~ ^[0-9]+$ && "${available_shm}" =~ ^[0-9]+$ ]] || return 40
    if (( available_cpus < RAY_NUM_CPUS || available_shm < RAY_OBJECT_STORE_BYTES )); then
        log_message "ERROR: G5 single-node profile needs ${RAY_NUM_CPUS} CPUs and ${RAY_OBJECT_STORE_BYTES} bytes free in /dev/shm; available: ${available_cpus} CPUs, ${available_shm} bytes"
        return 40
    fi
    log_message 'private container Ray runtime and single-node resources are ready'
}
