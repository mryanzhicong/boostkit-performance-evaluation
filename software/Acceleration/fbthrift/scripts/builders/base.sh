#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

CLANG16_SHA_AARCH64="e624cd19010fce9d7ba89066ab36d633514be9ce0237416943c1c05c59d1bf3c"
CLANG16_SHA_X86_64="2be9b9d5e2ca1f6411d9988496a820c556c65c4354c3949fe411646986922468"

fbthrift_clang_archive() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf 'clang+llvm-16.0.6-aarch64-linux-gnu.tar.xz\n' ;;
        x86_64) printf 'clang+llvm-16.0.6-x86_64-linux-gnu.tar.xz\n' ;;
        *) log_message "ERROR: unsupported architecture for clang 16: ${EXPECTED_ARCH}"; return 10 ;;
    esac
}

fbthrift_clang_sha256() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        aarch64) printf '%s\n' "${CLANG16_SHA_AARCH64}" ;;
        x86_64) printf '%s\n' "${CLANG16_SHA_X86_64}" ;;
        *) return 10 ;;
    esac
}

copy_fbthrift_clang_runtime() {
    # Directory-based toolchains (e.g. a distro clang-16 package) link against
    # shared libraries outside their own tree; the container does not have them,
    # so their closure is copied next to the compiler and put on LD_LIBRARY_PATH.
    local root="$1" lib source
    command -v ldd >/dev/null 2>&1 || return 0
    mkdir -p "${root}/lib"
    while IFS= read -r source; do
        [[ -n "${source}" && -f "${source}" ]] || continue
        case "$(basename "${source}")" in
            libc.so.6|libm.so.6|ld-linux*|linux-vdso*) continue ;;
        esac
        lib="${root}/lib/$(basename "${source}")"
        [[ -e "${lib}" ]] || cp -L "${source}" "${lib}" || return 30
    done < <(ldd "${root}/bin/clang" 2>/dev/null | awk '{print $3}' | grep -v '^$')
    return 0
}

verify_fbthrift_clang16() {
    local root="$1"
    [[ -x "${root}/bin/clang++" ]] || return 30
    "${root}/bin/clang++" --version 2>/dev/null | head -1 | grep -q "version 16\.0\.6" || {
        log_message "ERROR: ${root}/bin/clang++ is not clang 16.0.6"
        return 30
    }
}

download_fbthrift_clang16() {
    local archive="$1" destination="$2" sha="$3"
    local url attempt rc part_size
    # The archive is ~780 MB and the runner's link to GitHub stalls for minutes at
    # a time, so each transfer is resumable, aborts a stalled connection after a
    # minute, and every mirror gets two attempts.  The mirror that actually works
    # is tried first because the two earlier failures cost 30 minutes each.
    local -a urls=(
        "https://gh-proxy.com/https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/${archive}"
        "https://ghfast.top/https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/${archive}"
        "https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/${archive}"
        "https://hub.gitmirror.com/https://github.com/terralang/llvm-build/releases/download/llvm-16.0.6/${archive}"
    )
    for url in "${urls[@]}"; do
        for attempt in 1 2; do
            log_message "downloading clang 16 (attempt ${attempt}): ${url}"
            if fbthrift_with_proxy curl -fL --retry 2 --retry-delay 3 --connect-timeout 30 \
                --speed-limit 51200 --speed-time 60 --max-time 2400 -C - \
                -o "${destination}.part" "${url}"; then
                mv -f "${destination}.part" "${destination}" || return 30
                [[ "$(sha256sum "${destination}" | awk '{print $1}')" == "${sha}" ]] || {
                    log_message "ERROR: clang 16 archive checksum mismatch: ${destination}"
                    rm -f "${destination}"
                    return 30
                }
                return 0
            fi
            rc=$?
            part_size="$(stat -c %s "${destination}.part" 2>/dev/null || printf '0')"
            log_message "clang 16 download failed (rc=${rc}) from ${url}; ${part_size} bytes cached, retrying"
            # A server without range support rejects the resume offset; restart clean.
            if [ "${rc}" = "33" ]; then
                rm -f "${destination}.part"
            fi
            sleep 10
        done
    done
    rm -f "${destination}.part"
    return 30
}

cache_fbthrift_clang_tarball() {
    # The Blue runner keeps /home/runner/software across runs; caching the archive
    # there means the full-matrix run does not download 780 MB again.
    local tarball="$1" name target="${FBTHRIFT_OFFLINE_DIR:-}"
    [ -n "${tarball}" ] && [ -s "${tarball}" ] || return 0
    [ -n "${target}" ] || return 0
    name="$(basename "${tarball}")"
    [ -s "${target}/${name}" ] && return 0
    mkdir -p "${target}" 2>/dev/null || {
        log_message "WARNING: cannot create the clang 16 cache directory ${target}"
        return 0
    }
    [ -w "${target}" ] || {
        log_message "WARNING: the clang 16 cache directory is not writable: ${target}"
        return 0
    }
    log_message "caching the clang 16 archive for later runs: ${target}/${name}"
    cp -f "${tarball}" "${target}/${name}.part" 2>/dev/null &&
        mv -f "${target}/${name}.part" "${target}/${name}" 2>/dev/null &&
        log_message "cached the clang 16 archive" || {
        rm -f "${target}/${name}.part"
        log_message "WARNING: failed to cache the clang 16 archive in ${target}"
    }
    return 0
}

prepare_fbthrift_clang16() {
    local archive sha tarball
    if verify_fbthrift_clang16 "${CLANG_ROOT}" 2>/dev/null; then
        COMPILER_VERSION_STRING="$("${CLANG_ROOT}/bin/clang++" --version | head -1)"
        return 0
    fi
    # An administrator-provided toolchain outside the task work dir is copied in:
    # the container only mounts PERF_WORK_DIR, so host paths are not visible there.
    if [ -n "${FBTHRIFT_CLANG16_DIR}" ] && verify_fbthrift_clang16 "${FBTHRIFT_CLANG16_DIR}" 2>/dev/null \
        && [ "${FBTHRIFT_CLANG16_DIR%/}" != "${CLANG_ROOT%/}" ]; then
        log_message "copying the provided clang 16 toolchain into ${CLANG_ROOT}"
        rm -rf "${CLANG_ROOT}"
        cp -a "${FBTHRIFT_CLANG16_DIR}" "${CLANG_ROOT}" || return 30
        copy_fbthrift_clang_runtime "${CLANG_ROOT}" || return $?
        verify_fbthrift_clang16 "${CLANG_ROOT}" || return $?
        COMPILER_VERSION_STRING="$("${CLANG_ROOT}/bin/clang++" --version | head -1)"
        return 0
    fi
    archive="$(fbthrift_clang_archive)" || return $?
    sha="$(fbthrift_clang_sha256)" || return $?
    if [ -n "${FBTHRIFT_CLANG16_TARBALL}" ] && [ -s "${FBTHRIFT_CLANG16_TARBALL}" ]; then
        tarball="${FBTHRIFT_CLANG16_TARBALL}"
    elif [ -s "${FBTHRIFT_OFFLINE_DIR}/${archive}" ]; then
        tarball="${FBTHRIFT_OFFLINE_DIR}/${archive}"
    elif [ -s "${FBTHRIFT_LEGACY_OFFLINE_DIR}/${archive}" ]; then
        tarball="${FBTHRIFT_LEGACY_OFFLINE_DIR}/${archive}"
    else
        mkdir -p "${PERF_WORK_DIR}/downloads"
        tarball="${PERF_WORK_DIR}/downloads/${archive}"
        [ -s "${tarball}" ] || download_fbthrift_clang16 "${archive}" "${tarball}" "${sha}" || {
            log_message "ERROR: clang 16 archive ${archive} is not available offline or from the mirrors"
            return 30
        }
    fi
    log_message "verifying clang 16 archive: ${tarball}"
    [[ "$(sha256sum "${tarball}" | awk '{print $1}')" == "${sha}" ]] || {
        log_message "ERROR: clang 16 archive checksum mismatch: ${tarball}"
        return 30
    }
    mkdir -p "${CLANG_ROOT}" || return 30
    log_message "extracting clang 16 into ${CLANG_ROOT}"
    tar -xf "${tarball}" -C "${CLANG_ROOT}" --strip-components=1 || return 30
    verify_fbthrift_clang16 "${CLANG_ROOT}" || return $?
    COMPILER_VERSION_STRING="$("${CLANG_ROOT}/bin/clang++" --version | head -1)"
    cache_fbthrift_clang_tarball "${tarball}"
    log_message "clang 16 ready: ${COMPILER_VERSION_STRING}"
}

ensure_fbthrift_clang16_in_container() {
    # The compiler must run inside the container, not only on the host: a
    # directory-based toolchain resolves host libraries that the container lacks.
    fbthrift_container_exec env LD_LIBRARY_PATH="${CLANG_ROOT}/lib" "${CLANG_ROOT}/bin/clang++" --version >/dev/null 2>&1 && return 0
    log_message 'clang 16 is incomplete inside the container; copying its runtime libraries'
    copy_fbthrift_clang_runtime "${CLANG_ROOT}" || return $?
    fbthrift_container_exec env LD_LIBRARY_PATH="${CLANG_ROOT}/lib" "${CLANG_ROOT}/bin/clang++" --version >/dev/null 2>&1 || {
        log_message "ERROR: clang 16 cannot run inside the container: ${CLANG_ROOT}"
        return 30
    }
    log_message "clang 16 runs inside the container"
}

clone_stack_tag() {
    local url="$1" destination="$2" name="$3" tag="${4:-${STACK_VERSION}}" attempt candidate
    if [ -d "${destination}/.git" ]; then
        log_message "reusing existing ${name} checkout: ${destination}"
        return 0
    fi
    [ ! -e "${destination}" ] || { log_message "ERROR: ${destination} exists but is not a git checkout"; return 40; }
    # GitHub closes connections from this runner without a usable error message,
    # so every repository gets up to three attempts per endpoint plus one
    # read-through mirror before the build gives up.
    local -a candidates=("${url}")
    case "${url}" in
        https://github.com/*) candidates+=("https://gitclone.com/${url#https://}") ;;
    esac
    for candidate in "${candidates[@]}"; do
        for attempt in 1 2 3; do
            log_message "cloning ${name} ${tag} (attempt ${attempt}): ${candidate}"
            if fbthrift_with_proxy git clone --branch "${tag}" --depth 1 \
                --recurse-submodules "${candidate}" "${destination}"; then
                if [ "$(git -C "${destination}" rev-parse HEAD)" = \
                     "$(git -C "${destination}" rev-parse "refs/tags/${tag}^{commit}" 2>/dev/null)" ]; then
                    log_message "${name} checkout matches ${tag}"
                    return 0
                fi
                log_message "ERROR: ${name} checkout does not match tag ${tag}"
                rm -rf "${destination}"
                return 40
            fi
            rm -rf "${destination}"
            sleep $((attempt * 10))
        done
    done
    log_message "ERROR: cannot clone ${name} from ${url}"
    return 40
}

prepare_fbthrift_sources() {
    clone_stack_tag "${FOLLY_SOURCE_URL}" "${SOURCE_DIR}" folly "${STACK_VERSION}" || return $?
    clone_stack_tag "${FIZZ_SOURCE_URL}" "${FIZZ_DIR}" fizz "${STACK_VERSION}" || return $?
    clone_stack_tag "${WANGLE_SOURCE_URL}" "${WANGLE_DIR}" wangle "${STACK_VERSION}" || return $?
    clone_stack_tag "${THRIFT_SOURCE_URL}" "${THRIFT_DIR}" fbthrift "${STACK_VERSION}" || return $?
    clone_stack_tag "${FAST_FLOAT_SOURCE_URL}" "${FAST_FLOAT_DIR}" fast_float "${FAST_FLOAT_TAG}" || return $?
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return $?
}

copy_fbthrift_acclib() {
    [[ -f "${ACCLIB_SOURCE}/fbthrift_folly_benchmark/CMakeLists.txt" ]] || {
        log_message "ERROR: AccLibBenchmark fbthrift_folly_benchmark is missing: ${ACCLIB_SOURCE}"
        return 30
    }
    rm -rf "${PERF_WORK_DIR}/acclib-source"
    mkdir -p "${PERF_WORK_DIR}/acclib-source"
    cp -a "${ACCLIB_SOURCE}/fbthrift_folly_benchmark" "${PERF_WORK_DIR}/acclib-source/" || return 30
    log_message "copied the private AccLibBenchmark fixture into the task work dir"
}

install_fbthrift_build_deps() {
    log_message 'installing build dependencies inside the private container'
    fbthrift_container_exec_root dnf -y --setopt=install_weak_deps=False install \
        cmake make gcc gcc-c++ python3 tar gzip xz bzip2 which diffutils \
        glibc-devel binutils time boost-devel glog-devel gflags-devel \
        libevent-devel openssl-devel zlib-devel double-conversion-devel \
        fmt-devel libunwind-devel lz4-devel zstd-devel libsodium-devel \
        liburing-devel snappy-devel gtest-devel gmock-devel libaio-devel \
        libatomic numactl libicu-devel || return 30
}

build_fbthrift_base() {
    initialize_runtime || return $?
    require_fbthrift_docker || return $?
    start_fbthrift_container || return $?
    install_fbthrift_build_deps || return $?
    prepare_fbthrift_clang16 || return $?
    ensure_fbthrift_clang16_in_container || return $?
    prepare_fbthrift_sources || return $?
    copy_fbthrift_acclib || return $?
    log_message 'building folly -> fizz -> wangle -> fbthrift and AccLibBenchmark inside the container'
    fbthrift_container_exec env FBTHRIFT_SKIP_DNF=1 FBTHRIFT_SKIP_GIT=1 "PERF_PROXY=${PERF_PROXY:-}" \
        bash "${SCRIPT_DIR}/scripts/build_acclib_stack.sh" \
        "${PERF_WORK_DIR}" "${SOURCE_DIR}" "${FAST_FLOAT_DIR}" "${SOFTWARE_VERSION}" \
        "${PERF_WORK_DIR}/acclib-source" "${CLANG_ROOT}" || {
        log_message 'ERROR: the upstream stack or AccLibBenchmark build failed'
        return 40
    }
    [[ -x "${SERVER_BINARY}" && -x "${CLIENT_BINARY}" ]] || {
        log_message "ERROR: benchmark binaries are missing after the build"
        return 40
    }
    log_message "build finished: ${SERVER_BINARY}"
}
