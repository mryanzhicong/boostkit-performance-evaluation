#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_tensorflow_runtime() {
    initialize_runtime || return $?
    check_tensorflow_container || return $?
    container_exec test -x "${TF_SOURCE_DIR}/bazel-bin/predictor_server" || {
        log 'ERROR: predictor_server is missing; run the build stage first'
        return 40
    }
    container_exec test -x /usr/local/bin/brpc_client || {
        log 'ERROR: brpc_client is missing in the benchmark image'
        return 40
    }
    container_exec test -f "${TF_MODEL_DIR}/saved_model.pb" || {
        log "ERROR: model is not visible inside the container: ${TF_MODEL_DIR}"
        return 40
    }
    container_exec test -f "${TF_DATA_FILE}" || {
        log "ERROR: dataset is not visible inside the container: ${TF_DATA_FILE}"
        return 40
    }
    log 'TensorFlow benchmark image, model, dataset and binaries are ready'
}
