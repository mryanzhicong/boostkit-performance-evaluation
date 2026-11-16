#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# One measured process: the complete stdout/stderr is kept in
# <evidence_dir>/<label>.log and its wall time / exit code / peak RSS in
# <evidence_dir>/<label>.json.  The timing harness itself runs inside the private
# container, so every sample is produced by a container-native child process and
# docker's management overhead never lands inside a measurement window.
run_timed() {
    local evidence_dir="$1" label="$2" workdir="$3"
    shift 3
    mkdir -p "${evidence_dir}"
    local rc=0
    eigen_container_exec_at "${workdir}" \
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --json "${evidence_dir}/${label}.json" \
        --log "${evidence_dir}/${label}.log" \
        --timeout "${EIGEN_RUN_TIMEOUT}" \
        -- "$@" || rc=$?
    if ((rc != 0)); then
        # Surface the reason in the job log: a CI failure must be diagnosable
        # without downloading the result artifact.
        log_message "ERROR: ${evidence_dir} ${label} failed with exit code ${rc}"
        if [[ -f "${evidence_dir}/${label}.log" ]]; then
            log_message "---- tail of ${label}.log ----"
            while IFS= read -r line; do log_message "  ${line}"; done \
                < <(tail -n 40 -- "${evidence_dir}/${label}.log")
            log_message "---- end of ${label}.log ----"
        fi
    fi
    return "${rc}"
}

scenario_labels() {
    printf 'warmup\n'
    local index
    for index in $(seq 1 "${EIGEN_REPS}"); do
        printf 'rep%s\n' "${index}"
    done
}

# One matrix point of the pinned upstream GEMM matrix.  The driver is the
# unmodified upstream bench_gemm; its -s option takes rows, columns and depth, so
# the (m, k, n) point C(m x n) = A(m x k) * B(k x n) is passed as `-s m n k`.
measure_matrix_point() {
    local m="$1" k="$2" n="$3"
    local slug binary label scratch evidence
    slug="$(matrix_slug "${m}" "${k}" "${n}")"
    binary="$(gemm_binary_path)"
    evidence="${RUNS_DIR}/${slug}"
    if ! eigen_container_exec test -x "${binary}"; then
        log_message "ERROR: measured GEMM driver is missing: ${binary}"
        return 40
    fi
    if ! eigen_container_exec python3 --version >/dev/null 2>&1; then
        log_message "ERROR: python3 is required by the measurement wrapper inside the container"
        return 40
    fi
    while IFS= read -r label; do
        scratch="${SCRATCH_DIR}/${slug}/${label}"
        rm -rf -- "${scratch}"
        mkdir -p "${scratch}"
        log_message "matrix point ${slug}: ${label} (${m} x ${k} * ${k} x ${n})"
        run_timed "${evidence}" "${label}" "${scratch}" \
            "${binary}" -s "${m}" "${n}" "${k}" \
            -t "${EIGEN_GEMM_TRIES}" -p "${EIGEN_GEMM_REPEATS}" || return 50
    done < <(scenario_labels)
    return 0
}

read_identity_file() {
    local path="$1" fallback="$2"
    if [[ -s "${path}" ]]; then
        head -n 1 "${path}"
    else
        printf '%s\n' "${fallback}"
    fi
}

run_eigen_benchmarks() {
    initialize_runtime || return $?
    check_eigen_container || return $?
    validate_reps || return $?
    eigen_container_exec test -d "${SOURCE_DIR}" || {
        log_message "ERROR: the pinned Eigen source tree is missing: ${SOURCE_DIR}"
        return 40
    }
    eigen_container_exec python3 --version >/dev/null 2>&1 || {
        log_message "ERROR: python3 is required by the measurement wrapper inside the container"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}" "${SCRATCH_DIR}" "${PERF_WORK_DIR}/logs"
    local triple m k n
    for triple in "${EIGEN_GEMM_MATRIX[@]}"; do
        read -r m k n <<< "${triple}"
        measure_matrix_point "${m}" "${k}" "${n}" || return $?
    done

    COMPILER_IDENTITY="$(read_identity_file "${PERF_WORK_DIR}/compiler.txt" "$(eigen_container_exec c++ --version 2>/dev/null | head -n 1)")"
    EIGEN_MATRIX_CSV="$(matrix_csv)"
    export EIGEN_MATRIX_CSV
    export EIGEN_COMPILER="${COMPILER_IDENTITY}"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID
    export EIGEN_REPS EIGEN_GEMM_TRIES EIGEN_GEMM_REPEATS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" \
        --matrix "${EIGEN_MATRIX_CSV}" \
        --reps "${EIGEN_REPS}" \
        --tries "${EIGEN_GEMM_TRIES}" \
        --repeats "${EIGEN_GEMM_REPEATS}" \
        --software-version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" \
        --variant "${PERF_VARIANT}" \
        --run-id "${PERF_RUN_ID}" \
        --compiler "${COMPILER_IDENTITY:-unknown}" || {
        log_message "ERROR: the GEMM result parser rejected the measured samples"
        return 50
    }
    log_message "complete GEMM matrix finished: $(matrix_point_count) matrix points x (1 warmup + ${EIGEN_REPS} repetitions) x ${EIGEN_GEMM_TRIES} tries x ${EIGEN_GEMM_REPEATS} repeats"
}
