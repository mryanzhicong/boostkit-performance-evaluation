#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_llama_cpp_benchmarks() {
    local raw_json raw_log result_json model_sha status=0
    initialize_runtime || return $?
    check_llama_cpp_container || return $?
    raw_json="${RESULTS_DIR}/benchmark_llama_bench.json"
    raw_log="${RESULTS_DIR}/benchmark_llama_bench.log"
    result_json="${RESULTS_DIR}/benchmark_llama_cpp.json"
    [[ ! -e "${raw_json}" && ! -e "${result_json}" ]] || {
        log 'ERROR: refusing to overwrite existing benchmark result files'
        return 50
    }
    if ! verify_model_file "${LLAMA_CPP_MODEL_PATH}"; then
        prepare_bge_m3_model || return $?
    fi
    model_sha="$(sha256sum "${LLAMA_CPP_MODEL_PATH}")"
    model_sha="${model_sha%% *}"
    log "running upstream llama-bench inside container ${LLAMA_CPP_CONTAINER_NAME}: -p 512 -b 512 -n 0 -t 1 -r 5"
    set +e
    {
        container_exec env OMP_NUM_THREADS=1 "${LLAMA_CPP_BENCH_BIN}" \
            -m "${LLAMA_CPP_MODEL_PATH}" \
            -p 512 -b 512 -n 0 -t 1 -r 5 \
            --progress -o json \
            > "${raw_json}"
    } 2>&1 | tee "${raw_log}"
    status="${PIPESTATUS[0]}"
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log "ERROR: llama-bench exited with non-zero status ${status}"
        return 50
    fi
    [[ -s "${raw_json}" ]] || {
        log "ERROR: llama-bench produced empty JSON output: ${raw_json}"
        return 50
    }
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${raw_json}" "${result_json}" \
        --model-sha256 "${model_sha}" \
        --expected-commit "${SOFTWARE_VERSION}" || return 50
    log 'normalized llama-bench pp512,b512,t1 metrics successfully'
}
