#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Eigen is a header-only library and the measured workload are upstream BTL
# executables that the build stage already produced inside the private
# container.  The start stage therefore verifies the measured artefacts instead
# of starting a service: both build groups must contain every BTL executable,
# the resolved flags must be recorded, and the compiled self-check must still
# report the requested Eigen version.  Every one of those checks runs inside the
# container, so it describes exactly the process tree the test stage measures.
start_eigen_runtime() {
    initialize_runtime || return $?
    check_eigen_container || return $?
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
    if [[ "${EXPECTED_ARCH}" == "aarch64" && -z "${EIGEN_NATIVE_FLAG}" ]]; then
        log_message "ERROR: the aarch64 native build flag was not resolved during build"
        return 40
    fi
    local group action binary probe_binary
    for group in "${EIGEN_GROUPS[@]}"; do
        probe_binary="${PROBE_DIR}/eigen_probe_${group}"
        if ! eigen_container_exec test -x "${probe_binary}"; then
            log_message "ERROR: the ${group} self-check binary is missing: ${probe_binary}"
            return 40
        fi
        eigen_container_exec_at "${PROBE_DIR}" "${probe_binary}" \
            > "${PERF_WORK_DIR}/logs/start-probe-${group}.log" 2>&1 || {
            log_message "ERROR: the ${group} self-check binary failed during start"
            return 40
        }
        if ! grep -q "^EIGEN_VERSION_STRING=${SOFTWARE_VERSION}$" \
            "${PERF_WORK_DIR}/logs/start-probe-${group}.log"; then
            log_message "ERROR: the ${group} self-check does not report Eigen ${SOFTWARE_VERSION}"
            return 40
        fi
        for action in "${EIGEN_ACTIONS[@]}"; do
            binary="$(btl_binary_path "${group}" "${action}")"
            if ! eigen_container_exec test -x "${binary}"; then
                log_message "ERROR: the measured BTL executable is missing: ${binary}"
                return 40
            fi
        done
    done
    eigen_container_exec python3 --version >/dev/null 2>&1 || {
        log_message "ERROR: python3 is required by the measurement wrapper inside the container"
        return 40
    }
    log_message "Eigen ${SOFTWARE_VERSION} BTL runtime is ready: $((${#EIGEN_GROUPS[@]})) build groups x $((${#EIGEN_ACTIONS[@]})) actions, repetitions=${EIGEN_REPS}"
    log_message "vectorised group flag (${EXPECTED_ARCH}): ${EIGEN_NATIVE_FLAG:--march=native}"
    return 0
}
