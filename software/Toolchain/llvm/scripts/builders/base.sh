#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host-side prerequisites are limited to Docker plus the download/verification
# tools.  The compiler, cmake, ninja and Python all live inside the private
# container.
require_host_transfer_commands() {
    local required=(curl sha256sum awk sed head) missing=() command_name
    for command_name in "${required[@]}"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            missing+=("${command_name}")
        fi
    done
    if (( ${#missing[@]} > 0 )); then
        log_message "ERROR: missing host download/verification commands: ${missing[*]}"
        return 30
    fi
    return 0
}

# Create the private container and install the build toolchain there.  The
# container is created before the download so the build proves the private
# runtime is available even when every network fetch fails.
prepare_llvm_build_container() {
    local -a dnf_options=()
    # Weak dependencies can pull in scriptlets that call groupadd/useradd; the
    # container mounts /etc/passwd and /etc/group read-only, so those scriptlets
    # would fail and make dnf exit non-zero.  Install only hard dependencies.
    dnf_options+=("--setopt=install_weak_deps=False")
    require_host_transfer_commands || return $?
    require_llvm_docker || return 30
    start_llvm_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the LLVM build dependencies inside the private container"
    llvm_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ cmake ninja-build make \
        tar gzip xz coreutils findutils which sed gawk grep diffutils \
        ca-certificates python3 || {
        log_message "ERROR: container build dependencies failed"
        return 30
    }
    return 0
}

verify_checksum() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified sha256 $(basename "${file}")"
}

materialize_asset() {
    local name="$1" expected="$2" destination="$3"
    shift 3
    local -a urls=("$@")
    local offline_candidate="${LLVM_OFFLINE_DIR}/${name}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        verify_checksum "${destination}" "${expected}" && return 0
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline_candidate}" ]]; then
        log_message "using pre-placed offline asset: ${offline_candidate}"
        cp -- "${offline_candidate}" "${destination}" || return 30
        verify_checksum "${destination}" "${expected}"
        return $?
    fi
    local url
    local downloaded=0
    for url in "${urls[@]}"; do
        log_message "downloading ${url}"
        if ! curl -fL --retry 2 --retry-delay 2 --connect-timeout 20 --max-time 3600 \
            -o "${destination}.part" "${url}"; then
            log_message "WARNING: download failed, trying the next source: ${url}"
            rm -f -- "${destination}.part"
            continue
        fi
        if verify_checksum "${destination}.part" "${expected}"; then
            mv -- "${destination}.part" "${destination}"
            downloaded=1
            break
        fi
        log_message "WARNING: checksum mismatch from ${url}, trying the next source"
        rm -f -- "${destination}.part"
    done
    if (( downloaded == 0 )); then
        log_message "ERROR: every download source failed for ${name}"
        log_message "ERROR:   offline candidate: ${offline_candidate}"
        local attempted
        for attempted in "${urls[@]}"; do log_message "ERROR:   attempted: ${attempted}"; done
        return 30
    fi
    log_message "materialized ${name} ($(stat -c %s "${destination}") bytes)"
}

verify_compiler_tools() {
    local cmake_version major rest minor
    cmake_version="$(llvm_container_exec "${CMAKE_BIN}" --version 2>/dev/null | sed -n 's/^cmake version \([0-9][0-9.]*\).*/\1/p' | head -n 1 || true)"
    if [[ -z "${cmake_version}" ]]; then
        log_message "ERROR: cmake is not available as ${CMAKE_BIN} inside the private container"
        return 30
    fi
    log_message "container cmake ${cmake_version}"
    major="${cmake_version%%.*}"
    rest="${cmake_version#*.}"
    minor="${rest%%.*}"
    if (( major < 3 || (major == 3 && minor < 20) )); then
        log_message "ERROR: LLVM ${LLVM_VERSION} requires cmake >= 3.20, found ${cmake_version}"
        return 30
    fi
    local compiler
    for compiler in gcc g++; do
        if ! llvm_container_exec sh -c "command -v ${compiler} >/dev/null 2>&1"; then
            log_message "ERROR: ${compiler} is required to build LLVM inside the private container"
            return 30
        fi
    done
    log_message "container compiler: $(llvm_container_exec g++ --version 2>/dev/null | head -n 1 || true)"
    if llvm_container_exec sh -c 'command -v ninja >/dev/null 2>&1'; then
        log_message "container ninja: $(llvm_container_exec ninja --version 2>/dev/null || true)"
    else
        log_message "WARNING: ninja is unavailable inside the private container; falling back to Unix Makefiles"
    fi
}

cmake_generator_args() {
    if llvm_container_exec sh -c 'command -v ninja >/dev/null 2>&1'; then
        printf 'Ninja\n'
    else
        printf 'Unix Makefiles\n'
    fi
}

extract_source() {
    local archive="${PERF_WORK_DIR}/downloads/${LLVM_ARCHIVE_NAME}"
    if llvm_container_exec test -d "${LLVM_SRC}/llvm"; then
        log_message "reusing extracted llvm-project source tree at ${LLVM_SRC}"
        return 0
    fi
    materialize_asset "${LLVM_ARCHIVE_NAME}" "${LLVM_ARCHIVE_SHA256}" "${archive}" \
        "${LLVM_ARCHIVE_URLS[@]}" || return $?
    llvm_container_exec rm -rf -- "${LLVM_SRC}" || return 30
    llvm_container_exec mkdir -p "${LLVM_SRC}" || return 30
    log_message "extracting ${LLVM_ARCHIVE_NAME} (about 2 GB uncompressed) inside the private container"
    if ! llvm_container_exec tar -xzf "${archive}" -C "${LLVM_SRC}" --strip-components=1; then
        log_message "ERROR: failed to extract the llvm-project source archive"
        return 30
    fi
    if ! llvm_container_exec test -d "${LLVM_SRC}/llvm"; then
        log_message "ERROR: extracted archive has no llvm/ subdirectory"
        return 30
    fi
    return 0
}

reuse_existing_build() {
    if [[ -z "${LLVM_REUSE_BUILD_DIR}" ]]; then
        return 1
    fi
    log_message "WARNING: reusing an external LLVM build tree for local validation: ${LLVM_REUSE_BUILD_DIR}"
    if ! llvm_container_exec test -x "${OPT_BIN}" || ! llvm_container_exec test -x "${LLC_BIN}"; then
        log_message "ERROR: reuse build directory has no bin/opt and bin/llc: ${LLVM_REUSE_BUILD_DIR}"
        return 30
    fi
    return 0
}

configure_build() {
    if llvm_container_exec test -f "${LLVM_BUILD_DIR}/CMakeCache.txt"; then
        log_message "reusing existing LLVM build directory at ${LLVM_BUILD_DIR}"
        return 0
    fi
    local generator
    generator="$(cmake_generator_args)"
    log_message "configuring LLVM inside the private container: Release, LLVM_TARGETS_TO_BUILD=${LLVM_TARGET_NAME}, generator=${generator}"
    llvm_container_exec_env "${CMAKE_BIN}" -S "${LLVM_SRC}/llvm" -B "${LLVM_BUILD_DIR}" -G "${generator}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD="${LLVM_TARGET_NAME}" \
        -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF \
        -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_DOCS=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF -DLLVM_ENABLE_TERMINFO=OFF \
        -DLLVM_ENABLE_ZLIB=OFF -DLLVM_ENABLE_ZSTD=OFF \
        -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_LIBEDIT=OFF \
        -DLLVM_ENABLE_CURL=OFF -DLLVM_ENABLE_HTTPLIB=OFF \
        -DLLVM_BUILD_UTILS=OFF -DLLVM_INSTALL_UTILS=OFF || {
        log_message "ERROR: LLVM cmake configuration failed inside the private container"
        return 40
    }
}

compile_tools() {
    log_message "building opt and llc inside the private container (this is the expensive step; -j ${LLVM_BUILD_JOBS})"
    if ! llvm_container_exec_env "${CMAKE_BIN}" --build "${LLVM_BUILD_DIR}" --target opt llc -j "${LLVM_BUILD_JOBS}"; then
        log_message "ERROR: LLVM build of opt/llc failed inside the private container"
        return 40
    fi
    if ! llvm_container_exec test -x "${OPT_BIN}"; then
        log_message "ERROR: LLVM build finished but ${OPT_BIN} is missing"
        return 40
    fi
    if ! llvm_container_exec test -x "${LLC_BIN}"; then
        log_message "ERROR: LLVM build finished but ${LLC_BIN} is missing"
        return 40
    fi
}

record_actual_version() {
    local version_line version
    version_line="$(llvm_container_exec "${OPT_BIN}" --version 2>&1 || true)"
    if [[ -z "${version_line}" ]]; then
        log_message "ERROR: failed to execute ${OPT_BIN} --version inside the private container"
        return 40
    fi
    version="$(printf '%s\n' "${version_line}" | sed -n 's/^[[:space:]]*LLVM version \([0-9][0-9.]*\).*/\1/p' | head -n 1)"
    if [[ -z "${version}" ]]; then
        log_message "ERROR: could not parse the LLVM version from opt --version"
        printf '%s\n' "${version_line}" | sed -n '1,6p'
        return 40
    fi
    LLVM_VERSION_STRING="$(printf '%s\n' "${version_line}" | sed -n 's/^[[:space:]]*LLVM version \(.*\)$/\1/p' | head -n 1)"
    if [[ "${version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested LLVM ${SOFTWARE_VERSION} but built ${version}"
        return 40
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual LLVM version: ${version}"
    log_message "opt reports: LLVM version ${LLVM_VERSION_STRING}"
}

generate_corpus() {
    log_message "generating the deterministic ${LLVM_IR_FUNCTIONS}-function IR corpus inside the private container"
    llvm_container_exec_env python3 "${SCRIPT_DIR}/scripts/generate_ir.py" \
        --output-dir "${CORPUS_DIR}" --functions "${LLVM_IR_FUNCTIONS}" || return 40
    local module
    for module in arith.ll mem.ll branch.ll; do
        if ! llvm_container_exec test -s "${CORPUS_DIR}/${module}"; then
            log_message "ERROR: generated IR module is missing: ${module}"
            return 40
        fi
    done
    return 0
}

build_llvm_base() {
    initialize_runtime || return $?
    if [[ -n "${LLVM_REUSE_BUILD_DIR}" ]]; then
        # Local-validation shortcut: the external build tree is not below the
        # mounted work directory, so expose it to the container read-only.
        if [[ "${LLVM_REUSE_BUILD_DIR}" != "${PERF_WORK_DIR}"/* ]]; then
            LLVM_CONTAINER_EXTRA_ARGS+=(
                --mount "type=bind,source=${LLVM_REUSE_BUILD_DIR},target=${LLVM_REUSE_BUILD_DIR},readonly"
            )
        fi
        prepare_llvm_build_container || return $?
        reuse_existing_build || return $?
    else
        prepare_llvm_build_container || return $?
        verify_compiler_tools || return $?
        extract_source || return $?
        configure_build || return $?
        compile_tools || return $?
    fi
    record_actual_version || return $?
    generate_corpus || return $?
    log_message "base build completed: LLVM ${SOFTWARE_VERSION} opt/llc (${LLVM_TARGET_NAME}) inside the private container"
}
