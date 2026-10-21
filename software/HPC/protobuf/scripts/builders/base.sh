#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_build_commands() {
    local required_command package
    local packages=() dnf_options=()
    for required_command in git cmake make nproc sha256sum cmp python3 "${CXX_BINARY}"; do
        command -v "${required_command}" >/dev/null 2>&1 && continue
        case "${required_command}" in
            nproc|sha256sum|cmp) package="coreutils" ;;
            g++|c++) package="gcc-c++" ;;
            clang++) package="clang" ;;
            /*)
                log_message "ERROR: custom C++ compiler is unavailable: ${required_command}"
                return 30
                ;;
            *) package="${required_command}" ;;
        esac
        packages+=("${package}")
    done
    if ((${#packages[@]})); then
        command -v dnf >/dev/null 2>&1 || {
            log_message "ERROR: dnf is required to install Protobuf build dependencies"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log_message "installing missing Protobuf build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            command -v sudo >/dev/null 2>&1 || return 30
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required_command in git cmake make nproc sha256sum cmp python3 "${CXX_BINARY}"; do
        command -v "${required_command}" >/dev/null 2>&1 || {
            log_message "ERROR: required command remains unavailable: ${required_command}"
            return 30
        }
    done
}


check_architecture() {
    local actual_architecture expected_architecture
    actual_architecture="$(normalized_architecture "$(uname -m)")"
    expected_architecture="$(normalized_architecture "${EXPECTED_ARCH}")"
    if [[ "${actual_architecture}" != "${expected_architecture}" ]]; then
        log_message "ERROR: expected architecture ${expected_architecture}, runner is ${actual_architecture}"
        return 20
    fi
}


prepare_benchmark_source() {
    local local_source="${PROTOBUF_BENCHMARK_REPO:-/home/runner/software/protobuf/AccLibBenchmark}"
    if [[ -d "${local_source}/.git" ]]; then
        log_message "using local AccLibBenchmark repository ${local_source}"
        git clone --quiet --no-checkout "${local_source}" "${BENCHMARK_REPO_DIR}" || return 40
    else
        log_message "cloning AccLibBenchmark from ${BENCHMARK_SOURCE_URL}"
        GIT_TERMINAL_PROMPT=0 git clone --quiet --no-checkout \
            "${BENCHMARK_SOURCE_URL}" "${BENCHMARK_REPO_DIR}" || return 40
    fi
    git -C "${BENCHMARK_REPO_DIR}" checkout --quiet --detach \
        "${BENCHMARK_SOURCE_REVISION}" || return 40
    [[ -f "${BENCHMARK_SOURCE_DIR}/benchmark_main.cpp" ]] || {
        log_message "ERROR: pinned protobuf-benchmark source is missing"
        return 40
    }
    python3 "${SCRIPT_DIR}/scripts/fix_fixtures.py" \
        "${BENCHMARK_SOURCE_DIR}/benchmark_common.h" || return 40
    git -C "${BENCHMARK_REPO_DIR}" diff -- protobuf-benchmark/benchmark_common.h \
        > "${RESULTS_DIR}/benchmark_source.diff"
    [[ -s "${RESULTS_DIR}/benchmark_source.diff" ]] || {
        log_message "ERROR: fixed-fixture source diff is empty"
        return 40
    }
}


build_google_benchmark() {
    log_message "building Google Benchmark ${GOOGLE_BENCHMARK_VERSION}"
    GIT_TERMINAL_PROMPT=0 git clone --quiet --depth 1 \
        --branch "${GOOGLE_BENCHMARK_VERSION}" \
        "${GOOGLE_BENCHMARK_URL}" "${GOOGLE_BENCHMARK_SOURCE_DIR}" || return 40
    cmake -S "${GOOGLE_BENCHMARK_SOURCE_DIR}" -B "${GOOGLE_BENCHMARK_BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release -DBENCHMARK_ENABLE_TESTING=OFF \
        -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_INSTALL_PREFIX="${GOOGLE_BENCHMARK_INSTALL_DIR}" || return 40
    cmake --build "${GOOGLE_BENCHMARK_BUILD_DIR}" --parallel "$(nproc)" || return 40
    cmake --install "${GOOGLE_BENCHMARK_BUILD_DIR}" || return 40
}


clone_protobuf_source() {
    if [[ -e "${SOURCE_DIR}" ]]; then
        log_message "ERROR: source directory already exists: ${SOURCE_DIR}"
        return 20
    fi
    export GIT_TERMINAL_PROMPT=0
    log_message "cloning protobuf v${SOFTWARE_VERSION} from ${PROTOBUF_SOURCE_URL}"
    if ! git clone --branch "v${SOFTWARE_VERSION}" --depth 1 \
        "${PROTOBUF_SOURCE_URL}" "${SOURCE_DIR}"; then
        log_message "ERROR: failed to clone protobuf v${SOFTWARE_VERSION}"
        return 30
    fi
}


record_actual_version() {
    local version_output actual_version
    if ! version_output="$("${PROTOC_BIN}" --version 2>&1)"; then
        log_message "ERROR: built protoc cannot report its version"
        return 40
    fi
    actual_version="${version_output#libprotoc }"
    actual_version="${actual_version%%[[:space:]]*}"
    if [[ -z "${actual_version}" || "${actual_version}" == "${version_output}" ]]; then
        log_message "ERROR: unexpected protoc version output: ${version_output}"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: built protoc reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 40
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
}


build_protobuf_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_build_commands || return $?
    if [[ -e "${SOURCE_DIR}" || -e "${BUILD_DIR}" || -e "${INSTALL_DIR}" ||
          -e "${BENCHMARK_REPO_DIR}" || -e "${GOOGLE_BENCHMARK_SOURCE_DIR}" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    prepare_benchmark_source || {
        log_message "ERROR: failed to prepare the pinned AccLibBenchmark source"
        return 40
    }
    clone_protobuf_source || return $?
    CXX_VERSION="$("${CXX_BINARY}" --version | head -n 1)"
    log_message "building protobuf with the upstream CMake Release configuration"
    if ! cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -Dprotobuf_BUILD_TESTS=OFF \
        -Dprotobuf_BUILD_SHARED_LIBS=OFF \
        -Dprotobuf_FORCE_FETCH_DEPENDENCIES=ON \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}"; then
        log_message "ERROR: upstream CMake configuration failed"
        return 40
    fi
    if ! make -C "${BUILD_DIR}" -j"$(nproc)"; then
        log_message "ERROR: upstream CMake build failed"
        return 40
    fi
    if ! make -C "${BUILD_DIR}" install; then
        log_message "ERROR: private protobuf installation failed"
        return 40
    fi
    if [[ ! -x "${PROTOC_BIN}" ]]; then
        log_message "ERROR: private protoc was not installed: ${PROTOC_BIN}"
        return 40
    fi
    record_actual_version || return $?
    build_google_benchmark || {
        log_message "ERROR: failed to build Google Benchmark"
        return 40
    }
    log_message "building the original protobuf-benchmark C++ cases"
    if ! cmake -S "${SCRIPT_DIR}/scripts/benchmark_project" -B "${BENCHMARK_BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBENCHMARK_SOURCE_DIR="${BENCHMARK_SOURCE_DIR}" \
        -DCMAKE_PREFIX_PATH="${INSTALL_DIR};${GOOGLE_BENCHMARK_INSTALL_DIR}"; then
        log_message "ERROR: protobuf-benchmark CMake configuration failed"
        return 40
    fi
    if ! cmake --build "${BENCHMARK_BUILD_DIR}" --parallel "$(nproc)"; then
        log_message "ERROR: protobuf-benchmark C++ build failed"
        return 40
    fi
    [[ -x "${BENCHMARK_BIN}" && -x "${FIXTURE_DUMP_BIN}" ]] || return 40
    log_message "protobuf ${SOFTWARE_VERSION} and fixed-fixture C++ benchmark are ready"
}
