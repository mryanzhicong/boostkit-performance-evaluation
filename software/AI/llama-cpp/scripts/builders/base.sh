#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

acquire_upstream_source() {
    local local_repo=""
    if [[ -d "${LLAMA_CPP_OFFLINE_DIR}/llama.cpp.git" ]]; then
        local_repo="${LLAMA_CPP_OFFLINE_DIR}/llama.cpp.git"
    elif [[ -d "${LLAMA_CPP_OFFLINE_DIR}/llama.cpp/.git" ]]; then
        local_repo="${LLAMA_CPP_OFFLINE_DIR}/llama.cpp"
    fi
    if [[ -e "${LLAMA_CPP_SOURCE_DIR}" ]]; then
        log "ERROR: refusing to clone into non-empty source directory: ${LLAMA_CPP_SOURCE_DIR}"
        return 30
    fi
    if [[ -n "${local_repo}" ]]; then
        log "cloning llama.cpp from offline mirror: ${local_repo}"
        if ! container_exec git clone --no-checkout "${local_repo}" "${LLAMA_CPP_SOURCE_DIR}"; then
            rm -rf -- "${LLAMA_CPP_SOURCE_DIR}"
            log 'WARNING: offline git mirror clone failed, falling back to upstream GitHub'
        elif ! container_exec git -C "${LLAMA_CPP_SOURCE_DIR}" checkout --detach "${SOFTWARE_VERSION}"; then
            rm -rf -- "${LLAMA_CPP_SOURCE_DIR}"
            log "WARNING: offline git mirror missing commit ${SOFTWARE_VERSION}, falling back to upstream GitHub"
        else
            return 0
        fi
    fi
    log "cloning unmodified upstream llama.cpp (${SOFTWARE_VERSION}) inside the private container"
    container_exec git clone --no-checkout "${LLAMA_CPP_REPO_URL}" "${LLAMA_CPP_SOURCE_DIR}" || return 30
    container_exec git -C "${LLAMA_CPP_SOURCE_DIR}" checkout --detach "${SOFTWARE_VERSION}" || return 30
}

verify_built_binaries() {
    local full_commit version_output built_commit ldd_output
    for bin in "${LLAMA_CPP_BENCH_BIN}" "${LLAMA_CPP_SERVER_BIN}" "${LLAMA_CPP_EMBEDDING_BIN}"; do
        [[ -x "${bin}" ]] || { log "ERROR: built binary missing: ${bin}"; return 40; }
        ldd_output="$(container_exec ldd "${bin}")" || { log "ERROR: ldd failed for ${bin}"; return 40; }
        if grep -q 'not found' <<< "${ldd_output}"; then
            log "ERROR: missing shared libraries for ${bin}: ${ldd_output}"
            return 40
        fi
    done
    container_exec "${LLAMA_CPP_BENCH_BIN}" --help >/dev/null || {
        log 'ERROR: llama-bench --help failed inside the container'
        return 40
    }
    version_output="$(container_exec "${LLAMA_CPP_SERVER_BIN}" --version 2>&1)" || {
        log 'ERROR: llama-server --version failed inside the container'
        return 40
    }
    printf '%s\n' "${version_output}" > "${RESULTS_DIR}/binary-version.txt"
    built_commit="$(printf '%s\n' "${version_output}" | sed -nE 's/^version:[[:space:]]*[0-9]+[[:space:]]*\(([0-9a-fA-F]{7,40})\).*$/\1/p' | head -n 1)"
    built_commit="${built_commit,,}"
    full_commit="$(tr -d '\r\n' < "${RESULTS_DIR}/source-commit.txt")"
    [[ -n "${built_commit}" && "${SOFTWARE_VERSION}" == "${built_commit}"* && "${full_commit}" == "${built_commit}"* ]] || {
        log "ERROR: binary embedded commit '${built_commit}' does not match requested ${SOFTWARE_VERSION} (${full_commit})"
        return 40
    }
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_llama_cpp_base() {
    local full_commit
    local -a dnf_options=()
    initialize_runtime || return $?
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_llama_cpp_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing build dependencies inside the private container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ libgomp cmake ninja-build git curl ca-certificates tar gzip xz || {
        log 'ERROR: container build dependencies failed'
        return 30
    }
    container_exec sh -c 'gcc --version && g++ --version && cmake --version && ninja --version && git --version' \
        > "${RESULTS_DIR}/toolchain-versions.txt" 2>&1 || {
        log 'ERROR: required build toolchain commands are unavailable inside the container'
        return 30
    }
    acquire_upstream_source || return $?
    container_exec git -C "${LLAMA_CPP_SOURCE_DIR}" diff --quiet || {
        log 'ERROR: upstream llama.cpp source tree is dirty'
        return 30
    }
    full_commit="$(container_exec git -C "${LLAMA_CPP_SOURCE_DIR}" rev-parse HEAD)" || return 30
    full_commit="${full_commit,,}"
    [[ "${full_commit}" == "${SOFTWARE_VERSION}"* ]] || {
        log "ERROR: checked out commit ${full_commit} does not match ${SOFTWARE_VERSION}"
        return 30
    }
    printf '%s\n' "${full_commit}" > "${RESULTS_DIR}/source-commit.txt"
    log 'configuring unmodified upstream llama.cpp inside the private container'
    container_exec env CFLAGS="-O3 -funroll-loops" CXXFLAGS="-O3 -funroll-loops" \
        cmake -S "${LLAMA_CPP_SOURCE_DIR}" -B "${LLAMA_CPP_BUILD_DIR}" -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLAMA_CURL=OFF \
        -DGGML_CCACHE=OFF || {
        log 'ERROR: cmake configure failed inside the container'
        return 40
    }
    log 'building ggml-cpu, llama-embedding, llama-bench, and llama-server inside the private container'
    container_exec sh -c 'cmake --build "$1" --target ggml-cpu llama-embedding llama-bench llama-server -j "$(nproc)"' \
        sh "${LLAMA_CPP_BUILD_DIR}" || {
        log 'ERROR: cmake build failed inside the container'
        return 40
    }
    verify_built_binaries || return $?
    log "llama.cpp ${SOFTWARE_VERSION} (${full_commit}) base build is ready inside the private container"
}
