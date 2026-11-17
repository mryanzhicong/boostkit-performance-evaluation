#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_tensorflow_benchmarks() {
    local run_status=0
    initialize_runtime || return $?
    check_tensorflow_container || return $?
    rm -rf "${TF_OUT_DIR}"
    mkdir -p "${TF_OUT_DIR}"
    log "running ${TF_MODEL} modes='${TF_RUN_MODES}' qps='${TF_QPS_LIST}' warmup=${TF_WARMUP}s duration=${TF_DURATION}s"
    container_exec sh -c "cd '${TF_SOURCE_DIR}' && \
        MODEL_NAME='${TF_MODEL}' \
        MODEL='${TF_MODEL_DIR}' \
        DATA='${TF_DATA_FILE}' \
        OUT_DIR='${TF_OUT_DIR}' \
        PORT=8890 \
        THREAD_NUM='${TF_THREAD_NUM}' \
        CLIENT_THREAD_NUM='${TF_CLIENT_THREAD_NUM}' \
        WARMUP='${TF_WARMUP}' \
        DURATION='${TF_DURATION}' \
        QPS_LIST='${TF_QPS_LIST}' \
        RUN_MODES='${TF_RUN_MODES}' \
        MAX_INFLIGHT='${TF_MAX_INFLIGHT}' \
        REQUEST_MIN_BATCH_SIZE='${TF_REQUEST_MIN_BATCH_SIZE}' \
        REQUEST_MAX_BATCH_SIZE='${TF_REQUEST_MAX_BATCH_SIZE}' \
        TF_NUM_INTEROP_THREADS='${TF_THREAD_NUM}' \
        TF_NUM_INTRAOP_THREADS='${TF_THREAD_NUM}' \
        BIN_SERVER='${TF_SOURCE_DIR}/bazel-bin/predictor_server' \
        BIN_CLIENT=/usr/local/bin/brpc_client \
        SERVER_STARTUP_TIMEOUT='${TF_SERVER_STARTUP_TIMEOUT}' \
        MACHINE_LABEL='${EXPECTED_ARCH}' \
        sh tools/run_serving_benchmark.sh" 2>&1 | tee "${TF_RAW_LOG}" || run_status="${PIPESTATUS[0]}"
    if [[ "${run_status}" -ne 0 ]]; then
        log "ERROR: TensorFlow benchmark exited ${run_status}"
        return 50
    fi
    [[ -s "${TF_CSV_PATH}" ]] || {
        log "ERROR: benchmark result CSV is missing: ${TF_CSV_PATH}"
        return 50
    }
    TF_IMAGE_SHA256="$(awk '{print $1}' "${TF_IMAGE_SHA256_FILE}")"
    TF_SOURCE_COMMIT="$(cat "${TF_SOURCE_COMMIT_FILE}")"
    TF_ASSET_SHA256="$(cat "${TF_ASSET_SHA256_FILE}")"
    export TF_IMAGE TF_IMAGE_SHA256 TF_SOURCE_COMMIT TF_ASSET_SHA256
    SOFTWARE_VERSION="${SOFTWARE_VERSION}" EXPECTED_ARCH="${EXPECTED_ARCH}" \
        TF_MODEL="${TF_MODEL}" TF_RUN_MODES="${TF_RUN_MODES}" TF_QPS_LIST="${TF_QPS_LIST}" \
        TF_WARMUP="${TF_WARMUP}" TF_DURATION="${TF_DURATION}" \
        TF_THREAD_NUM="${TF_THREAD_NUM}" TF_CLIENT_THREAD_NUM="${TF_CLIENT_THREAD_NUM}" \
        TF_MAX_INFLIGHT="${TF_MAX_INFLIGHT}" \
        TF_REQUEST_MIN_BATCH_SIZE="${TF_REQUEST_MIN_BATCH_SIZE}" \
        TF_REQUEST_MAX_BATCH_SIZE="${TF_REQUEST_MAX_BATCH_SIZE}" \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${TF_CSV_PATH}" "${TF_OUT_DIR}/metadata.txt" \
        "${RESULTS_DIR}/benchmark_tensorflow.json" || return 50
}
