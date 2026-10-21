#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

preserve_spec_build_logs() {
    local build_log relative_path destination

    if [[ ! -d "${SPEC_OUTPUT_ROOT}/benchspec/CPU" ]]; then
        return
    fi
    while IFS= read -r -d '' build_log; do
        relative_path="${build_log#"${SPEC_DIR}/"}"
        destination="${RESULTS_DIR}/spec-build-logs/${relative_path}"
        if ! mkdir -p "$(dirname "${destination}")" || \
           ! cp "${build_log}" "${destination}"; then
            log_message "ERROR: failed to preserve SPEC build log: ${build_log}"
            return 50
        fi
    done < <(find "${SPEC_OUTPUT_ROOT}/benchspec/CPU" -type f -name 'make*.out' -print0)
}

run_gcc_benchmarks() {
    local actual_version config_source spec_label spec_group

    initialize_runtime || return $?
    if [[ ! -x "${GCC_BIN}" || ! -x "${GXX_BIN}" || ! -x "${GFORTRAN_BIN}" ]]; then
        log_message "ERROR: private GCC C, C++, or Fortran compiler is missing"
        return 40
    fi
    if ! GCC_VERSION_STRING="$("${GCC_BIN}" --version 2>/dev/null | head -n 1)"; then
        log_message "ERROR: built GCC cannot report its version"
        return 40
    fi
    actual_version="$(printf '%s\n' "${GCC_VERSION_STRING}" | awk '{print $NF}')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built GCC reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    if [[ -L "${BENCHMARK_DATA_DIR}" ]]; then
        log_message "ERROR: GCC benchmark data directory must not be a symlink: ${BENCHMARK_DATA_DIR}"
        return 50
    fi
    if [[ -e "${BENCHMARK_DATA_DIR}" ]]; then
        if [[ ! -f "${BENCHMARK_DATA_DIR}/.gcc-run-id" ]] || \
            [[ "$(<"${BENCHMARK_DATA_DIR}/.gcc-run-id")" != "${PERF_RUN_ID}" ]]; then
            log_message "ERROR: GCC benchmark data directory belongs to another run: ${BENCHMARK_DATA_DIR}"
            return 50
        fi
    else
        mkdir -p "${BENCHMARK_DATA_DIR}"
        printf '%s\n' "${PERF_RUN_ID}" > "${BENCHMARK_DATA_DIR}/.gcc-run-id"
    fi
    mkdir -p "${RESULTS_DIR}" "${SPEC_MOUNT_DIR}"
    if [[ "${EUID}" -eq 0 ]]; then
        if ! mount -o loop,ro "${SPEC_CPU2017_ISO}" "${SPEC_MOUNT_DIR}"; then
            log_message "ERROR: failed to mount the SPEC CPU2017 ISO"
            return 50
        fi
    elif ! sudo -n mount -o loop,ro "${SPEC_CPU2017_ISO}" "${SPEC_MOUNT_DIR}"; then
        log_message "ERROR: failed to mount the SPEC CPU2017 ISO"
        return 50
    fi
    if ! (
        cd "${SPEC_MOUNT_DIR}"
        env -u SPEC ./install.sh -f -d "${SPEC_DIR}"
    ) 2>&1 | tee "${RESULTS_DIR}/spec-install.log"; then
        log_message "ERROR: SPEC CPU2017 installation failed"
        return 50
    fi
    if [[ ! -x "${SPEC_DIR}/bin/runcpu" || ! -x "${SPEC_DIR}/bin/specperl" ]]; then
        log_message "ERROR: SPEC CPU2017 installation is incomplete"
        return 50
    fi
    config_source="${SCRIPT_DIR}/scripts/${SPEC_CONFIG_NAME}"
    if [[ ! -f "${config_source}" ]]; then
        log_message "ERROR: SPEC CPU2017 GCC configuration is missing: ${config_source}"
        return 50
    fi
    if ! sed \
        -e "s|^%   define  gcc_dir[[:space:]].*$|%   define  gcc_dir        ${INSTALL_DIR}|" \
        "${config_source}" > "${SPEC_CONFIG_PATH}"; then
        log_message "ERROR: failed to place the SPEC CPU2017 GCC configuration"
        return 50
    fi
    if ! grep -Fxq "%   define  gcc_dir        ${INSTALL_DIR}" "${SPEC_CONFIG_PATH}"; then
        log_message "ERROR: SPEC CPU2017 GCC compiler path was not updated"
        return 50
    fi
    spec_label="$(awk '$1 == "%" && $2 == "define" && $3 == "label" {print $4; exit}' "${SPEC_CONFIG_PATH}")"
    spec_group="$(awk '$1 == "%" && $2 == "define" && $3 == "group" {print $4; exit}' "${SPEC_CONFIG_PATH}")"
    if [[ ! "${spec_label}" =~ ^[A-Za-z0-9._-]+$ || ! "${spec_group}" =~ ^[A-Za-z0-9._-]+$ ]] || \
        ! grep -Fqx 'output_root          = %{top}/result/%{group}/%{label}' "${SPEC_CONFIG_PATH}"; then
        log_message "ERROR: unsupported SPEC CPU2017 output_root configuration"
        return 50
    fi
    SPEC_OUTPUT_ROOT="${SPEC_DIR}/result/${spec_group}/${spec_label}"
    SPEC_RESULT_DIR="${SPEC_OUTPUT_ROOT}/result"
    if ! cp "${SPEC_CONFIG_PATH}" "${RESULTS_DIR}/${SPEC_CONFIG_NAME}"; then
        log_message "ERROR: failed to preserve the SPEC CPU2017 GCC configuration"
        return 50
    fi
    if ! cat /proc/sys/kernel/randomize_va_space > "${ASLR_STATE_FILE}"; then
        log_message "ERROR: failed to record the current ASLR setting"
        return 50
    fi
    if [[ "${EUID}" -eq 0 ]]; then
        if ! printf '0\n' > /proc/sys/kernel/randomize_va_space || \
            ! printf '3\n' > /proc/sys/vm/drop_caches; then
            log_message "ERROR: failed to prepare the requested SPEC CPU2017 system settings"
            return 50
        fi
    elif ! printf '0\n' | sudo -n tee /proc/sys/kernel/randomize_va_space >/dev/null || \
        ! printf '3\n' | sudo -n tee /proc/sys/vm/drop_caches >/dev/null; then
        log_message "ERROR: failed to prepare the requested SPEC CPU2017 system settings"
        return 50
    fi
    log_message "running SPEC CPU2017 intrate: ${SPEC_COPIES} copies, one iteration"
    if ! (
        cd "${SPEC_DIR}"
        source ./shrc
        runcpu --config="${SPEC_CONFIG_NAME}" intrate -n 1 -C "${SPEC_COPIES}"
    ) 2>&1 | tee "${RESULTS_DIR}/raw-output.log"; then
        preserve_spec_build_logs || return $?
        log_message "ERROR: SPEC CPU2017 intrate failed"
        return 50
    fi
    if awk '
        /^Build errors for intrate:/ && $0 != "Build errors for intrate: None" {
            has_build_errors = 1
        }
        END { exit !has_build_errors }
    ' "${RESULTS_DIR}/raw-output.log"; then
        preserve_spec_build_logs || return $?
        log_message "ERROR: SPEC CPU2017 intrate reported benchmark build errors"
        return 50
    fi
    if [[ ! -d "${SPEC_RESULT_DIR}" ]]; then
        log_message "ERROR: SPEC CPU2017 result directory is missing"
        return 50
    fi
    if ! mkdir -p "${RESULTS_DIR}/spec-results" || \
        ! cp -a "${SPEC_RESULT_DIR}/." "${RESULTS_DIR}/spec-results/"; then
        log_message "ERROR: failed to preserve SPEC CPU2017 result files"
        return 50
    fi
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT GCC_VERSION_STRING SPEC_COPIES SPEC_CONFIG_NAME
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/spec-results" \
        "${RESULTS_DIR}/benchmark_gcc.json"; then
        log_message "ERROR: failed to normalize the SPEC CPU2017 results"
        return 50
    fi
    log_message "SPEC CPU2017 results written to raw-output.log, spec-results, and benchmark_gcc.json"
}
