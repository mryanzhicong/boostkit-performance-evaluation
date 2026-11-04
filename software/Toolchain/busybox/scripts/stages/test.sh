#!/usr/bin/env bash
# Test stage: one warm-up plus PERF_REPS independent repetitions of every applet
# scenario, offline, with per-repetition wall time, peak RSS and a compact
# correctness report.  The normalized result file is produced by the strict
# parser in scripts/results/parse_benchmark.py.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

read_network_mode() {
    if [[ -s "${BUSYBOX_OFFLINE_DIR_MODE_FILE}" ]]; then
        cat "${BUSYBOX_OFFLINE_DIR_MODE_FILE}"
    else
        printf 'unknown\n'
    fi
}

# Run one scenario repetition.  $1 scenario, $2 label (warmup|repN).
run_scenario_once() {
    local scenario="$1"
    local label="$2"
    local run_dir="${BUSYBOX_RUNS_DIR}/${scenario}"
    local json_path="${run_dir}/${label}.json"
    local log_path="${run_dir}/${label}.log"
    local check_path="${run_dir}/${label}.check"
    local network_mode
    network_mode="$(read_network_mode)"

    scenario_argv "${scenario}" || return 50
    local output_path
    output_path="$(scenario_output_path "${scenario}")"
    rm -f -- "${output_path}" "${check_path}"

    local -a timing_args=(--json "${json_path}" --log "${log_path}")
    case "${scenario}" in
        sha256sum_hash|grep_count|awk_aggregate)
            # Small stdout captured in the log; no separate artifact needed.
            ;;
        tar_gzip_create)
            # the archive is written through tar's own -f option
            ;;
        *)
            timing_args+=(--stdout-file "${output_path}")
            ;;
    esac
    if [[ "${network_mode}" == "unshare" ]]; then
        timing_args+=(--offline)
    fi

    mkdir -p "${run_dir}"
    log_message "scenario ${scenario} ${label} starting (network mode ${network_mode}, inside the private container)"
    # The timing harness runs inside the private container, so every sample is
    # produced by a container-native child process and docker's management
    # overhead never lands inside a measurement window.
    busybox_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${SCRIPTS_DIR}/run_timed.py" "${timing_args[@]}" -- "${SCENARIO_CMD[@]}" || {
        local rc=$?
        fail_message "scenario ${scenario} ${label} failed with exit code ${rc}"
        if [[ -f "${log_path}" ]]; then
            tail -40 "${log_path}" || true
        fi
        return 50
    }
    if [[ -f "${json_path}" ]] && grep -q '"exit_code": 0' "${json_path}"; then
        :
    else
        fail_message "scenario ${scenario} ${label} did not report a zero exit code"
        [[ -f "${log_path}" ]] && tail -40 "${log_path}"
        return 50
    fi

    local verify_output="-"
    if [[ "${scenario}" == "tar_gzip_create" ]]; then
        verify_output="${BUSYBOX_OUT_DIR}/tar_gzip_create.tar.gz"
    elif [[ -s "${output_path}" ]]; then
        verify_output="${output_path}"
    fi
    # The verifier runs the built BusyBox binary again for cross-checks, so it
    # must execute in the same container (the host libc cannot run these
    # binaries).  `docker exec` does not inherit the stage environment, so every
    # value the verifier reads is passed explicitly.
    local -a verifier_env=(
        env
        "BUSYBOX_BIN=${BUSYBOX_BIN}"
        "BUSYBOX_FIXTURE_CORPUS_BYTES=${BUSYBOX_FIXTURE_CORPUS_BYTES}"
        "BUSYBOX_FIXTURE_CORPUS_SHA256=${BUSYBOX_FIXTURE_CORPUS_SHA256}"
        "BUSYBOX_FIXTURE_GZIP_BYTES=${BUSYBOX_FIXTURE_GZIP_BYTES}"
        "BUSYBOX_FIXTURE_GZIP_SHA256=${BUSYBOX_FIXTURE_GZIP_SHA256}"
        "BUSYBOX_FIXTURE_SORT_LINES=${BUSYBOX_FIXTURE_SORT_LINES}"
        "BUSYBOX_FIXTURE_TAR_ENTRIES=${BUSYBOX_FIXTURE_TAR_ENTRIES}"
        "BUSYBOX_FIXTURE_TAR_BYTES=${BUSYBOX_FIXTURE_TAR_BYTES}"
        "BUSYBOX_CORPUS_SHA256SUM_ARGS=${BUSYBOX_CORPUS_SHA256SUM_ARGS}"
        "BUSYBOX_EXPECT_GREP_MATCHES=${BUSYBOX_EXPECT_GREP_MATCHES}"
        "BUSYBOX_EXPECT_SED_SHA256=${BUSYBOX_EXPECT_SED_SHA256}"
        "BUSYBOX_EXPECT_CUT_SHA256=${BUSYBOX_EXPECT_CUT_SHA256}"
        "BUSYBOX_EXPECT_AWK_SUM=${BUSYBOX_EXPECT_AWK_SUM}"
    )
    busybox_container_exec_at "${PERF_WORK_DIR}" \
        "${verifier_env[@]}" python3 "${SCRIPTS_DIR}/verify_outputs.py" \
        "${scenario}" "${verify_output}" "${log_path}" "${check_path}" "${label}" || {
        fail_message "scenario ${scenario} ${label} failed its output verification"
        cat "${check_path}" 2>/dev/null || true
        return 50
    }
    rm -f -- "${output_path}"
    return 0
}

aggregate_raw_output() {
    local network_mode="$1"
    {
        printf '# BusyBox %s applet measurement output\n' "${SOFTWARE_VERSION}"
        printf '# architecture: %s\n' "${EXPECTED_ARCH}"
        printf '# repetitions: %s (plus %s warm-up per scenario)\n' "${BUSYBOX_REPS}" "${BUSYBOX_WARMUPS}"
        printf '# network mode during measurement: %s\n' "${network_mode}"
        for scenario in "${BUSYBOX_SCENARIOS[@]}"; do
            for log_file in "${BUSYBOX_RUNS_DIR}/${scenario}"/*.log; do
                [[ -f "${log_file}" ]] || continue
                printf '\n===== %s =====\n' "${log_file#"${BUSYBOX_RUNS_DIR}"/}"
                cat -- "${log_file}"
            done
            for check_file in "${BUSYBOX_RUNS_DIR}/${scenario}"/*.check; do
                [[ -f "${check_file}" ]] || continue
                printf '\n===== %s =====\n' "${check_file#"${BUSYBOX_RUNS_DIR}"/}"
                cat -- "${check_file}"
            done
        done
    } > "${RESULTS_DIR}/raw-output.log" || {
        fail_message "failed to write ${RESULTS_DIR}/raw-output.log"
        return 50
    }
    [[ -s "${RESULTS_DIR}/raw-output.log" ]] || {
        fail_message "raw output log is empty"
        return 50
    }
    return 0
}

run_busybox_benchmarks() {
    validate_variant || return $?
    validate_reps || return $?
    configure_runtime_paths || return $?
    initialize_runtime || return $?
    check_busybox_container || return $?
    if ! busybox_container_exec test -x "${BUSYBOX_BIN}"; then
        fail_message "the BusyBox binary is missing; run the build and start stages first"
        return 50
    fi
    if [[ ! -s "${BUSYBOX_FIXTURE_MANIFEST}" ]]; then
        fail_message "the fixture manifest is missing; run the start stage first"
        return 50
    fi
    local network_mode
    network_mode="$(read_network_mode)"
    if [[ "${network_mode}" == "unknown" ]]; then
        fail_message "the measurement network mode is unknown; run the start stage first"
        return 50
    fi
    if [[ "${network_mode}" != "unshare" ]]; then
        log_message "WARNING: measuring with network mode '${network_mode}' (namespace isolation unavailable on this runner)"
    fi

    local scenario
    for scenario in "${BUSYBOX_SCENARIOS[@]}"; do
        run_scenario_once "${scenario}" warmup || return 50
        log_message "scenario ${scenario} warmup ok"
    done

    local repetition
    for ((repetition = 1; repetition <= BUSYBOX_REPS; repetition++)); do
        log_message "measurement repetition ${repetition}/${BUSYBOX_REPS}"
        for scenario in "${BUSYBOX_SCENARIOS[@]}"; do
            run_scenario_once "${scenario}" "rep${repetition}" || return 50
            log_message "scenario ${scenario} rep${repetition} ok"
        done
    done

    aggregate_raw_output "${network_mode}" || return 50

    export BUSYBOX_NETWORK_MODE="${network_mode}"
    export BUSYBOX_C_COMPILER="$(compiler_identity)"
    export BUSYBOX_ACTUAL_VERSION_STRING="$(cat "${PERF_ACTUAL_VERSION_FILE}" 2>/dev/null || true)"
    export BUSYBOX_APPLET_COUNT="$(cat "${BUSYBOX_STATE_DIR}/applet-count.txt" 2>/dev/null || echo 0)"
    export BUSYBOX_SOURCE_SHA256 BUSYBOX_SOURCE_NAME BUSYBOX_BUILD_JOBS BUSYBOX_CFLAGS
    export BUSYBOX_REQUIRED_APPLETS_TEXT="${BUSYBOX_REQUIRED_APPLETS[*]}"
    export BUSYBOX_FIXTURE_SHA256_CORPUS="${BUSYBOX_FIXTURE_CORPUS_SHA256}"
    export BUSYBOX_FIXTURE_SHA256_GZIP="${BUSYBOX_FIXTURE_GZIP_SHA256}"
    export BUSYBOX_FIXTURE_SHA256_SORT="${BUSYBOX_FIXTURE_SORT_SHA256}"
    export BUSYBOX_FIXTURE_SHA256_TAR="${BUSYBOX_FIXTURE_TAR_CONTENT_SHA256}"

    python3 "${SCRIPTS_DIR}/results/parse_benchmark.py" \
        "${BUSYBOX_RUNS_DIR}" "${RESULTS_DIR}/results.json" || {
        fail_message "result parsing failed"
        return 50
    }

    log_message "all ${#BUSYBOX_SCENARIOS[@]} scenarios finished with ${BUSYBOX_REPS} repetitions"
    return 0
}
