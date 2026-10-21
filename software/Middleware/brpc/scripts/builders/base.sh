#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_brpc_dependencies() {
    local required package library header
    local packages=()

    for required in git cmake make gcc g++ protoc python3 curl sed grep install tee nproc; do
        if command -v "${required}" >/dev/null 2>&1; then
            continue
        fi
        case "${required}" in
            git) package="git" ;;
            cmake) package="cmake" ;;
            make) package="make" ;;
            gcc) package="gcc" ;;
            g++) package="gcc-c++" ;;
            protoc) package="protobuf-compiler" ;;
            python3) package="python3" ;;
            curl) package="curl" ;;
            sed) package="sed" ;;
            grep) package="grep" ;;
            install|tee|nproc) package="coreutils" ;;
        esac
        log_message "missing required BRPC build command: ${required}"
        packages+=("${package}")
    done

    # BRPC links against these system libraries.  Test the headers instead of
    # assuming that a package name proves the compiler can use the library.
    for library in openssl gflags leveldb protobuf rdma; do
        case "${library}" in
            openssl) header="openssl/ssl.h"; package="openssl-devel" ;;
            gflags) header="gflags/gflags.h"; package="gflags-devel" ;;
            leveldb) header="leveldb/db.h"; package="leveldb-devel" ;;
            protobuf) header="google/protobuf/message.h"; package="protobuf-devel" ;;
            rdma) header="infiniband/verbs.h"; package="rdma-core-devel" ;;
        esac
        if ! printf '#include <%s>\nint main(){return 0;}\n' "${header}" \
            | g++ -x c++ -fsyntax-only - 2>/dev/null; then
            log_message "missing required BRPC development headers: ${library}"
            packages+=("${package}")
        fi
    done

    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install BRPC build prerequisites"
        return 30
    fi
    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing BRPC build packages: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif ! command -v sudo >/dev/null 2>&1; then
        log_message "ERROR: sudo is required to install BRPC build prerequisites"
        return 30
    elif ! sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"; then
        log_message "ERROR: failed to install BRPC build prerequisites"
        return 30
    fi

    for required in git cmake make gcc g++ protoc python3 curl sed grep install tee nproc; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required BRPC build command remains unavailable: ${required}"
            return 30
        fi
    done
    for library in openssl gflags leveldb protobuf rdma; do
        case "${library}" in
            openssl) header="openssl/ssl.h" ;;
            gflags) header="gflags/gflags.h" ;;
            leveldb) header="leveldb/db.h" ;;
            protobuf) header="google/protobuf/message.h" ;;
            rdma) header="infiniband/verbs.h" ;;
        esac
        if ! printf '#include <%s>\nint main(){return 0;}\n' "${header}" \
            | g++ -x c++ -fsyntax-only - 2>/dev/null; then
            log_message "ERROR: required BRPC development headers remain unavailable: ${library}"
            return 30
        fi
    done
}

configure_rdma_example_for_modern_protobuf() {
    # The example CMake is configured separately from the upstream library.
    # Only its private build file is adjusted; server.cpp/client.cpp stay intact.
    local example_cmake_file="${EXAMPLE_DIR}/CMakeLists.txt"
    local absl_cmake_file="${EXAMPLE_DIR}/brpc_rdma_example_absl.cmake"
    [[ -f "${example_cmake_file}" ]] || {
        log_message "ERROR: official RDMA performance example CMake file is missing: ${example_cmake_file}"
        return 40
    }
    sed -i 's/set(CMAKE_CXX_STANDARD 11)/set(CMAKE_CXX_STANDARD 17)/' \
        "${example_cmake_file}" || {
        log_message "ERROR: could not enable C++17 for the official performance example"
        return 40
    }
    grep -Fq 'set(CMAKE_CXX_STANDARD 17)' "${example_cmake_file}" || {
        log_message "ERROR: the official example C++11 setting was not found"
        return 40
    }

    install -m 0644 "${SCRIPT_DIR}/rdma_example_absl.cmake" "${absl_cmake_file}" || {
        log_message "ERROR: could not provide the Abseil dependencies for the official example"
        return 40
    }
    sed -i \
        -e '/^include(FindProtobuf)$/a\include(${CMAKE_CURRENT_LIST_DIR}/brpc_rdma_example_absl.cmake)' \
        -e '/^[[:space:]]*${PROTOBUF_LIBRARIES}[[:space:]]*$/a\    ${BRPC_RDMA_EXAMPLE_ABSL_TARGETS}' \
        -e '/^[[:space:]]*${THRIFT_LIB}[[:space:]]*$/a\    ${RDMA_LIB}\n    z' \
        "${example_cmake_file}" || {
        log_message "ERROR: could not link the official example dependencies"
        return 40
    }
    grep -Fq 'include(${CMAKE_CURRENT_LIST_DIR}/brpc_rdma_example_absl.cmake)' "${example_cmake_file}" \
        && grep -Fq '${BRPC_RDMA_EXAMPLE_ABSL_TARGETS}' "${example_cmake_file}" \
        && grep -Fq '    ${RDMA_LIB}' "${example_cmake_file}" || {
        log_message "ERROR: official example dependency configuration is incomplete"
        return 40
    }
    log_message "configured the official performance example for current Protobuf and Abseil"
}

build_brpc_base() {
    local actual_version

    initialize_runtime || return $?
    require_brpc_dependencies || return $?
    [[ ! -e "${SOURCE_DIR}" && ! -e "${BUILD_DIR}" && ! -e "${SERVICE_DIR}" ]] || {
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    }

    # The official getting_started.md builds BRPC with the default g++
    # toolchain.  Record the compiler actually used by this build.
    COMPILER_BINARY="g++"
    COMPILER_VERSION_STRING="$("${COMPILER_BINARY}" --version | head -n 1)"
    log_message "using compiler: ${COMPILER_BINARY} (${COMPILER_VERSION_STRING})"

    export GIT_TERMINAL_PROMPT=0
    log_message "cloning brpc ${SOFTWARE_VERSION} from ${BRPC_SOURCE_URL}"
    git clone --branch "${SOFTWARE_VERSION}" --depth 1 \
        "${BRPC_SOURCE_URL}" "${SOURCE_DIR}" || {
        log_message "ERROR: failed to clone brpc ${SOFTWARE_VERSION}"
        return 30
    }

    # The server binary has no --version switch.  RELEASE_VERSION from the
    # checked-out release is the authoritative version evidence.
    actual_version="$(<"${SOURCE_DIR}/RELEASE_VERSION")"
    actual_version="${actual_version//[[:space:]]/}"
    [[ "${actual_version}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: source RELEASE_VERSION '${actual_version}' does not match ${SOFTWARE_VERSION}"
        return 40
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40

    configure_rdma_example_for_modern_protobuf || return $?

    log_message "building the official brpc library with cmake (Release)"
    mkdir -p "${BUILD_DIR}"
    cmake -S "${SOURCE_DIR}" -B "${BUILD_DIR}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_DEBUG_SYMBOLS=OFF \
        -DWITH_RDMA=ON \
        -DBUILD_BRPC_TOOLS=OFF || {
        log_message "ERROR: cmake configure of the brpc library failed"
        return 40
    }
    cmake --build "${BUILD_DIR}" -j "$(nproc)" || {
        log_message "ERROR: cmake build of the brpc library failed"
        return 40
    }
    [[ -f "${BUILD_DIR}/output/lib/libbrpc.a" ]] || {
        log_message "ERROR: official libbrpc.a was not produced under ${BUILD_DIR}/output/lib"
        return 40
    }

    # RDMA support is a compile-time requirement of this upstream example;
    # --use_rdma=false on both processes keeps the measured transport TCP.
    log_message "building official example/rdma_performance server and client"
    mkdir -p "${EXAMPLE_DIR}/build"
    cmake -S "${EXAMPLE_DIR}" -B "${EXAMPLE_DIR}/build" \
        -DCMAKE_BUILD_TYPE=Release || {
        log_message "ERROR: cmake configure of example/rdma_performance failed"
        return 40
    }
    cmake --build "${EXAMPLE_DIR}/build" -j "$(nproc)" \
        --target client --target server || {
        log_message "ERROR: cmake build of rdma_performance client/server failed"
        return 40
    }
    [[ -x "${RDMA_SERVER_BIN}" ]] || {
        log_message "ERROR: official server binary was not produced: ${RDMA_SERVER_BIN}"
        return 40
    }
    [[ -x "${RDMA_CLIENT_BIN}" ]] || {
        log_message "ERROR: official client binary was not produced: ${RDMA_CLIENT_BIN}"
        return 40
    }
    log_message "brpc ${SOFTWARE_VERSION} official TCP performance example is ready"
}
