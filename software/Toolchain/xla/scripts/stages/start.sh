#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stage_hlo_artifact() {
    local hlo_name="$1" expected_sha256="$2" download_url="$3"
    local staged_path="${BENCHMARK_DIR}/${hlo_name}"
    if [[ -s "${staged_path}" ]]; then
        log_message "using cached HLO artifact: ${staged_path}"
    elif [[ -s "${XLA_ARCHIVE_DIR}/${hlo_name}" ]]; then
        log_message "using local HLO artifact: ${XLA_ARCHIVE_DIR}/${hlo_name}"
        cp "${XLA_ARCHIVE_DIR}/${hlo_name}" "${staged_path}" || return 30
    elif [[ -n "${download_url}" ]]; then
        log_message "downloading HLO artifact: ${hlo_name}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${staged_path}" "${download_url}" || return 30
    else
        log_message "ERROR: HLO artifact is unavailable: ${hlo_name}"
        return 40
    fi
    verify_sha256 "${staged_path}" "${expected_sha256}" || return $?
}

stage_benchmark_workloads() {
    mkdir -p "${BENCHMARK_DIR}"
    stage_hlo_artifact "${XLA_GEMMA3_HLO_NAME}" "${XLA_GEMMA3_HLO_SHA256}" \
        "${XLA_GEMMA3_HLO_URL}" || return $?
    stage_hlo_artifact "${XLA_GEMMA2_HLO_NAME}" "${XLA_GEMMA2_HLO_SHA256}" \
        "${XLA_GEMMA2_HLO_URL}" || return $?
    local repo_path="${XLA_SRC_DIR}/xla/tools/benchmarks/hlo/${XLA_GEMMA4_HLO_NAME}"
    if [[ ! -s "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" ]]; then
        [[ -s "${repo_path}" ]] || {
            log_message "ERROR: the pinned checkout does not contain ${XLA_GEMMA4_HLO_NAME}"
            return 40
        }
        cp "${repo_path}" "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" || return 40
    fi
    verify_sha256 "${BENCHMARK_DIR}/${XLA_GEMMA4_HLO_NAME}" \
        "${XLA_GEMMA4_HLO_SHA256}" || return $?
    log_message 'all three official CPU HLO workloads are staged and verified'
}

# Drive one benchmark through the repository's own run_benchmark.sh, which
# derives CPU_TIME/WALL_TIME (milliseconds) from the XSpace profile.
run_official_benchmark() {
    local benchmark_name="$1" hlo_path="$2" num_repeats="$3" output_dir="$4"
    mkdir -p "${output_dir}"
    (
        export BENCHMARK_NAME="${benchmark_name}"
        export CONFIG_ID="${CONFIG_ID}"
        export HARDWARE_CATEGORY="${HARDWARE_CATEGORY}"
        export OUTPUT_DIR="${output_dir}"
        export RUNNER_BINARY="${HLO_RUNNER_BIN}"
        export STATS_BINARY="${XSPACE_STATS_BIN}"
        export DEVICE_TYPE_FLAG="host"
        export LOCAL_ARTIFACT_PATH="${hlo_path}"
        export INPUT_FORMAT=""
        export XLA_FLAGS_JSON="[]"
        export RUNTIME_FLAGS_JSON="[\"--num_repeats=${num_repeats}\"]"
        export COMMIT_SHA="${XLA_COMMIT}"
        export WORKFLOW_RUN_ID="${PERF_RUN_ID}"
        bash "${OFFICIAL_RUN_BENCHMARK}"
    )
}

start_xla_runtime() {
    local smoke_dir
    initialize_runtime || return $?
    [[ -x "${HLO_RUNNER_BIN}" && -x "${XSPACE_STATS_BIN}" ]] || {
        log_message 'ERROR: XLA benchmark harness is missing; build stage did not complete'
        return 40
    }
    command -v jq >/dev/null 2>&1 || {
        log_message 'ERROR: jq is required by the official run_benchmark.sh'
        return 40
    }
    stage_benchmark_workloads || return $?

    # Smoke-run the smallest official workload once through the complete
    # official chain so the test stage only times a verified toolchain.
    smoke_dir="${PERF_WORK_DIR}/smoke"
    rm -rf "${smoke_dir}"
    log_message "smoke-running ${XLA_GEMMA3_BENCHMARK} through the official harness"
    if ! run_official_benchmark "${XLA_GEMMA3_BENCHMARK}" \
        "${BENCHMARK_DIR}/${XLA_GEMMA3_HLO_NAME}" 1 "${smoke_dir}"; then
        rm -rf "${smoke_dir}"
        log_message 'ERROR: the official harness smoke run failed'
        return 40
    fi
    if ! jq -e '.run_status == "SUCCESS" and (.metrics.CPU_TIME.value > 0) and
              (.metrics.WALL_TIME.value > 0)' \
        "${smoke_dir}/results.json" >/dev/null 2>&1; then
        rm -rf "${smoke_dir}"
        log_message 'ERROR: the smoke run did not produce a successful CPU measurement'
        return 40
    fi
    rm -rf "${smoke_dir}"
    log_message 'XLA benchmark runtime is ready'
}
