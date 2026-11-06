#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Eigen is a header-only library and the measured workload is the upstream
# bench_gemm driver that the build stage already compiled inside the private
# container.  The start stage therefore verifies the measured artefacts instead
# of starting a service: the pinned source tree must still report the requested
# version, the driver and self-check binaries must exist and run, and the timing
# wrapper must have python3.  Every check runs inside the container, so it
# describes exactly the process tree the test stage measures.
start_eigen_runtime() {
    initialize_runtime || return $?
    check_eigen_container || return $?
    mkdir -p "${PERF_WORK_DIR}/logs" || return 40
    eigen_container_exec test -d "${SOURCE_DIR}" || {
        log_message "ERROR: the pinned Eigen source tree is missing: ${SOURCE_DIR}"
        return 40
    }
    local expected_version
    expected_version="$(eigen_container_exec sed -n 's/^#define EIGEN_VERSION_STRING "\(.*\)"$/\1/p' \
        "${SOURCE_DIR}/Eigen/Version" | head -n 1)" || expected_version=""
    if [[ "${expected_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: source tree reports Eigen ${expected_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    local gemm probe
    gemm="$(gemm_binary_path)"
    probe="$(probe_binary_path)"
    if ! eigen_container_exec test -x "${gemm}"; then
        log_message "ERROR: the measured GEMM driver is missing: ${gemm}"
        return 40
    fi
    if ! eigen_container_exec test -x "${probe}"; then
        log_message "ERROR: the Eigen self-check binary is missing: ${probe}"
        return 40
    fi
    eigen_container_exec_at "${PROBE_DIR}" "${probe}" \
        > "${PERF_WORK_DIR}/logs/start-probe.log" 2>&1 || {
        log_message "ERROR: the Eigen self-check binary failed during start"
        return 40
    }
    if ! grep -q "^EIGEN_VERSION_STRING=${SOFTWARE_VERSION}$" \
        "${PERF_WORK_DIR}/logs/start-probe.log"; then
        log_message "ERROR: the self-check does not report Eigen ${SOFTWARE_VERSION}"
        return 40
    fi
    if ! eigen_container_exec_at "${PROBE_DIR}" "${gemm}" -s 8 4 4 -t 1 -p 1 \
        > "${PERF_WORK_DIR}/logs/start-gemm.log" 2>&1; then
        log_message "ERROR: the measured GEMM driver failed its start smoke run"
        return 40
    fi
    if ! grep -q '^eigen cpu .* GFLOPS' "${PERF_WORK_DIR}/logs/start-gemm.log"; then
        log_message "ERROR: the GEMM driver did not print a throughput line during start"
        return 40
    fi
    eigen_container_exec python3 --version >/dev/null 2>&1 || {
        log_message "ERROR: python3 is required by the measurement wrapper inside the container"
        return 40
    }
    log_message "Eigen ${SOFTWARE_VERSION} GEMM runtime is ready: $(matrix_point_count) matrix points x (1 warmup + ${EIGEN_REPS} repetitions), tries=${EIGEN_GEMM_TRIES}, repeats=${EIGEN_GEMM_REPEATS}"
    return 0
}
