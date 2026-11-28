#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_source() {
    if [[ -f "${TF_SOURCE_DIR}/tools/run_serving_benchmark.sh" ]]; then
        log "using existing TensorFlow source checkout ${TF_SOURCE_DIR}"
    else
        rm -rf "${TF_SOURCE_DIR}"
        if [[ -d "${TF_ASSET_DIR}/tensorflow" ]]; then
            log "copying local TensorFlow source from ${TF_ASSET_DIR}/tensorflow"
            cp -a --reflink=auto "${TF_ASSET_DIR}/tensorflow" "${TF_SOURCE_DIR}" || return 30
        else
            log "cloning TensorFlow ${TF_SOURCE_BRANCH} from ${TF_SOURCE_REPOSITORY}"
            with_network_proxy git clone --depth 1 --branch "${TF_SOURCE_BRANCH}" \
                "${TF_SOURCE_REPOSITORY}" "${TF_SOURCE_DIR}" || return 30
        fi
    fi
    [[ -f "${TF_SOURCE_DIR}/tools/run_serving_benchmark.sh" ]] || {
        log 'ERROR: TensorFlow source does not contain tools/run_serving_benchmark.sh'
        return 30
    }
    if [[ -d "${TF_SOURCE_DIR}/.git" ]]; then
        TF_SOURCE_COMMIT="$(git -C "${TF_SOURCE_DIR}" rev-parse HEAD)" || return 30
    else
        TF_SOURCE_COMMIT="unknown"
    fi
    printf '%s\n' "${TF_SOURCE_COMMIT}" > "${TF_SOURCE_COMMIT_FILE}"
    log "TensorFlow source commit: ${TF_SOURCE_COMMIT}"
}

prepare_assets() {
    if [[ -d "${TF_ASSET_DIR}/tf_benchmark/din_mmoe" ]]; then
        TF_ASSET_ROOT="${TF_ASSET_DIR}/tf_benchmark"
        log "using extracted benchmark assets at ${TF_ASSET_ROOT}"
    elif [[ -d "${TF_ASSET_ROOT}/${TF_MODEL}" ]]; then
        log "using existing extracted assets at ${TF_ASSET_ROOT}"
    else
        [[ -s "${TF_BENCH_ARCHIVE}" ]] || {
            log "ERROR: benchmark asset archive is missing: ${TF_BENCH_ARCHIVE}"
            return 30
        }
        log "extracting benchmark assets ${TF_BENCH_ARCHIVE}"
        mkdir -p "${PERF_WORK_DIR}/assets"
        tar -xzf "${TF_BENCH_ARCHIVE}" -C "${PERF_WORK_DIR}/assets" || return 30
        [[ -d "${TF_ASSET_ROOT}/${TF_MODEL}" ]] || {
            log "ERROR: extracted assets do not contain ${TF_ASSET_ROOT}/${TF_MODEL}"
            return 30
        }
    fi
    TF_MODEL_DIR="${TF_ASSET_ROOT}/${TF_MODEL}/1"
    TF_DATA_FILE="${TF_ASSET_ROOT}/benchmark_dataset/${TF_MODEL}.tsv"
    export TF_ASSET_ROOT TF_MODEL_DIR TF_DATA_FILE
    [[ -f "${TF_MODEL_DIR}/saved_model.pb" ]] || {
        log "ERROR: SavedModel is missing: ${TF_MODEL_DIR}/saved_model.pb"
        return 30
    }
    [[ -f "${TF_DATA_FILE}" ]] || {
        log "ERROR: benchmark dataset is missing: ${TF_DATA_FILE}"
        return 30
    }
    if [[ -f "${TF_BENCH_ARCHIVE}" ]]; then
        TF_ASSET_SHA256="$(sha256sum "${TF_BENCH_ARCHIVE}" | awk '{print $1}')"
    else
        TF_ASSET_SHA256="$(find "${TF_ASSET_ROOT}" -type f -print0 | sort -z | \
            xargs -0 sha256sum | sha256sum | awk '{print $1}')"
    fi
    printf '%s\n' "${TF_ASSET_SHA256}" > "${TF_ASSET_SHA256_FILE}"
    log "benchmark assets SHA-256: ${TF_ASSET_SHA256}"
}

check_container_tools() {
    container_exec test -x /usr/local/bin/brpc_client || {
        log 'ERROR: brpc_client is missing in the benchmark image'
        return 30
    }
    container_exec sh -c 'command -v bazel >/dev/null' || {
        log 'ERROR: bazel is missing in the benchmark image'
        return 30
    }
    container_exec test -d "${TF_MODEL_DIR}" || {
        log "ERROR: model directory is not visible inside the container: ${TF_MODEL_DIR}"
        return 30
    }
    container_exec test -f "${TF_DATA_FILE}" || {
        log "ERROR: dataset is not visible inside the container: ${TF_DATA_FILE}"
        return 30
    }
}

prepare_bazel_offline_cache() {
    local seeded=0
    if [[ -d "${TF_BAZEL_CACHE_SEED}/content_addressable" ]]; then
        if [[ ! -d "${TF_BAZEL_REPOSITORY_CACHE}" ]]; then
            local entries
            [[ -d "${TF_BAZEL_CACHE_SEED}/content_addressable/sha256" ]] && \
                entries="$(find "${TF_BAZEL_CACHE_SEED}/content_addressable/sha256" \
                    -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)"
            log "seeding Bazel repository cache from ${TF_BAZEL_CACHE_SEED} (${entries:-0} entries)"
            cp -a "${TF_BAZEL_CACHE_SEED}" "${TF_BAZEL_REPOSITORY_CACHE}" || return 30
        else
            log "reusing task Bazel repository cache ${TF_BAZEL_REPOSITORY_CACHE}"
        fi
        seeded=1
    else
        log "no prepared Bazel repository cache in ${TF_BAZEL_CACHE_SEED}"
    fi
    mkdir -p "${TF_BAZEL_REPOSITORY_CACHE}"
    if [[ "${seeded}" -eq 0 && -z "$(ls -A "${TF_BAZEL_REPOSITORY_CACHE}" 2>/dev/null)" ]]; then
        log 'WARNING: Bazel repository cache is empty; the build needs network access'
    fi
}

build_predictor_server() {
    local distdir_option=""
    if [[ -d "${TF_SOURCE_DIR}/download" ]]; then
        distdir_option="--distdir=${TF_SOURCE_DIR}/download"
    elif [[ -d "${TF_DISTDIR}" ]]; then
        distdir_option="--distdir=${TF_DISTDIR}"
    fi
    prepare_bazel_offline_cache || return $?
    log "building //:predictor_server with bazel (distdir=${distdir_option:-none})"
    container_exec sh -c "cd '${TF_SOURCE_DIR}' && \
        bazel --output_user_root=./output build \
        --noenable_bzlmod \
        --repository_cache='${TF_BAZEL_REPOSITORY_CACHE}' \
        --cxxopt=-std=c++17 --host_cxxopt=-std=c++17 \
        --copt=-O3 --host_copt=-O3 --copt=-march=armv8.5-a \
        --host_copt=-I/usr/local/include --linkopt=-L/usr/local/lib64 \
        --host_linkopt=-L/usr/local/lib64 \
        --linkopt=-Wl,-rpath,/usr/local/lib64 \
        --host_linkopt=-Wl,-rpath,/usr/local/lib64 \
        --action_env=LD_LIBRARY_PATH=/usr/local/lib64:\$LD_LIBRARY_PATH \
        --action_env=TF_SYSTEM_LIBS=boringssl,snappy \
        ${distdir_option} --copt=-w --host_copt=-w \
        //:predictor_server" || return 30
    container_exec test -x "${TF_SOURCE_DIR}/bazel-bin/predictor_server" || {
        log 'ERROR: predictor_server was not produced by bazel'
        return 30
    }
}

build_tensorflow_base() {
    initialize_runtime || return $?
    require_host_commands || return $?
    require_tensorflow_container || return $?
    prepare_source || return $?
    prepare_assets || return $?
    check_container_tools || return $?
    build_predictor_server || return $?
    printf '2.20.0\n' > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${TF_IMAGE}" > "${PERF_WORK_DIR}/image.txt"
    log 'TensorFlow 2.20.0 benchmark image, source and predictor_server are ready'
}
