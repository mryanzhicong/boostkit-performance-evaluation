#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every compiler and build dependency lives inside the private openEuler
# container.  The host keeps only Docker plus the download/verification tools, so
# this helper never installs packages on the runner; a missing host tool is
# reported as a warning because the pre-placed offline archive can still be used.
require_host_transfer_commands() {
    local missing=() cmd
    for cmd in curl sha256sum awk; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    ((${#missing[@]} == 0)) && return 0
    log_message "WARNING: host download/verification tools are incomplete: ${missing[*]}; the pre-placed offline archive is the only usable source"
    return 0
}

# Dependency installation happens inside the container; the host never runs dnf
# or apt-get for this case.
prepare_eigen_build_container() {
    local -a dnf_options=(--setopt=install_weak_deps=False)
    require_host_transfer_commands
    require_eigen_docker || return 30
    start_eigen_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing Eigen build dependencies inside the private container"
    eigen_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make tar gzip coreutils findutils sed gawk grep \
        util-linux file glibc-devel binutils python3 which || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
    eigen_container_exec c++ --version >/dev/null 2>&1 || {
        log_message "ERROR: c++ is not usable inside the private container"
        return 30
    }
    eigen_container_exec python3 --version >/dev/null 2>&1 || {
        log_message "ERROR: python3 is not usable inside the private container"
        return 30
    }
}

verify_sha256() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 1
    fi
    log_message "verified sha256 $(basename "${file}")"
}

print_log_tail() {
    local path="$1" lines="${2:-40}"
    [[ -f "${path}" ]] || return 0
    log_message "---- tail of ${path} ----"
    while IFS= read -r line; do log_message "  ${line}"; done < <(tail -n "${lines}" -- "${path}")
    log_message "---- end of ${path} ----"
}

curl_common_options() {
    local -a options=(--fail --location --retry 3 --retry-delay 3 --connect-timeout 30)
    if [[ -n "${PERF_PROXY:-}" ]]; then
        options+=(--proxy "${PERF_PROXY}")
    fi
    printf '%s\n' "${options[@]}"
}

# Every URL that may serve the pinned archive, in preference order.  The
# dedicated runners cannot reliably reach github.com, and the only byte-identical
# copy of the release is the upstream GitLab tag archive, so gitlab.com is the
# primary network source; the pre-placed offline directory is preferred over any
# network source.  Every candidate is verified against the same pinned SHA-256.
asset_candidates() {
    local -a candidates=()
    [[ -z "${PERF_EIGEN_ARCHIVE_URL}" ]] || candidates+=("${PERF_EIGEN_ARCHIVE_URL}")
    [[ -z "${PERF_EIGEN_MIRROR}" ]] || candidates+=("${PERF_EIGEN_MIRROR%/}/${EIGEN_ARCHIVE_NAME}")
    candidates+=("${EIGEN_ARCHIVE_URL}")
    [[ -z "${EIGEN_PROXY_PREFIX}" ]] || candidates+=("${EIGEN_PROXY_PREFIX%/}/${EIGEN_ARCHIVE_URL}")
    local candidate seen=""
    for candidate in "${candidates[@]}"; do
        [[ "${seen}" == *"|${candidate}|"* ]] && continue
        seen+="|${candidate}|"
        printf '%s\n' "${candidate}"
    done
}

materialize_archive() {
    local offline="${EIGEN_OFFLINE_DIR}/${EIGEN_ARCHIVE_NAME}"
    mkdir -p "$(dirname "${SOURCE_ARCHIVE}")"
    if [[ -f "${SOURCE_ARCHIVE}" ]]; then
        if verify_sha256 "${SOURCE_ARCHIVE}" "${EIGEN_ARCHIVE_SHA256}"; then
            return 0
        fi
        log_message "discarding corrupted cached archive: ${SOURCE_ARCHIVE}"
        rm -f -- "${SOURCE_ARCHIVE}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline archive: ${offline}"
        cp -- "${offline}" "${SOURCE_ARCHIVE}"
        if verify_sha256 "${SOURCE_ARCHIVE}" "${EIGEN_ARCHIVE_SHA256}"; then
            return 0
        fi
        log_message "ERROR: pre-placed offline archive is not the pinned upstream release: ${offline}"
        rm -f -- "${SOURCE_ARCHIVE}"
        return 30
    fi
    local tried=() candidate
    local -a curl_options=()
    mapfile -t curl_options < <(curl_common_options)
    while IFS= read -r candidate; do
        tried+=("${candidate}")
        log_message "downloading ${candidate}"
        if ! curl "${curl_options[@]}" -o "${SOURCE_ARCHIVE}.part" "${candidate}"; then
            log_message "WARNING: download failed, trying the next source: ${candidate}"
            rm -f -- "${SOURCE_ARCHIVE}.part"
            continue
        fi
        if verify_sha256 "${SOURCE_ARCHIVE}.part" "${EIGEN_ARCHIVE_SHA256}"; then
            mv -- "${SOURCE_ARCHIVE}.part" "${SOURCE_ARCHIVE}"
            return 0
        fi
        log_message "WARNING: checksum mismatch from ${candidate}, trying the next source"
        rm -f -- "${SOURCE_ARCHIVE}.part"
    done < <(asset_candidates)
    log_message "ERROR: could not obtain a verified ${EIGEN_ARCHIVE_NAME} from any source"
    log_message "ERROR: attempted URLs:"
    for candidate in "${tried[@]}"; do
        log_message "  - ${candidate}"
    done
    log_message "ERROR: place the official archive in ${EIGEN_OFFLINE_DIR}/ or set PERF_EIGEN_ARCHIVE_URL"
    return 30
}

extract_source() {
    if eigen_container_exec test -f "${SOURCE_DIR}/Eigen/Version" >/dev/null 2>&1 &&
        eigen_container_exec test -f "${SOURCE_DIR}/bench/bench_gemm.cpp" >/dev/null 2>&1; then
        log_message "reusing extracted Eigen sources at ${SOURCE_DIR}"
        return 0
    fi
    rm -rf -- "${SOURCE_DIR}"
    mkdir -p "${SOURCE_DIR}"
    log_message "extracting $(basename "${SOURCE_ARCHIVE}") inside the private container"
    eigen_container_exec tar -xzf "${SOURCE_ARCHIVE}" -C "${SOURCE_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Eigen archive"
        return 30
    }
    eigen_container_exec test -f "${SOURCE_DIR}/Eigen/Version" || {
        log_message "ERROR: extracted Eigen sources have an unexpected layout"
        return 30
    }
    eigen_container_exec test -f "${SOURCE_DIR}/bench/bench_gemm.cpp" || {
        log_message "ERROR: the extracted archive does not contain bench/bench_gemm.cpp"
        return 30
    }
}

verify_source_version() {
    local extracted
    extracted="$(eigen_container_exec sed -n 's/^#define EIGEN_VERSION_STRING "\(.*\)"$/\1/p' \
        "${SOURCE_DIR}/Eigen/Version" | head -n 1)" || extracted=""
    if [[ "${extracted}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: the archive reports Eigen ${extracted:-unknown}, requested ${SOFTWARE_VERSION}"
        return 30
    fi
    log_message "upstream archive reports Eigen ${extracted} (Eigen/Version)"
}

# The measured driver is the unmodified upstream bench/bench_gemm.cpp.  It is
# compiled once inside the private container (Eigen is header-only, so the host
# never touches the source) and smoke-tested on one fixed matrix point; the smoke
# run proves that the binary really prints the "eigen cpu ... GFLOPS" line the
# parser pins.
compile_gemm_driver() {
    local binary log smoke
    binary="$(gemm_binary_path)"
    log="${PROBE_DIR}/compile-gemm.log"
    smoke="${PROBE_DIR}/gemm-smoke.log"
    mkdir -p "${PROBE_DIR}"
    log_message "compiling upstream bench/bench_gemm.cpp inside the private container"
    eigen_container_exec c++ -std=c++17 -O3 -DNDEBUG -I "${SOURCE_DIR}" \
        "${SOURCE_DIR}/bench/bench_gemm.cpp" -o "${binary}" > "${log}" 2>&1 || {
        log_message "ERROR: upstream bench/bench_gemm.cpp does not compile"
        print_log_tail "${log}"
        return 30
    }
    eigen_container_exec test -x "${binary}" || {
        log_message "ERROR: the GEMM driver is missing after the build: ${binary}"
        return 30
    }
    eigen_container_exec_at "${PROBE_DIR}" "${binary}" -s 32 8 4 -t 1 -p 1 \
        > "${smoke}" 2>&1 || {
        log_message "ERROR: the GEMM driver failed its smoke run"
        print_log_tail "${smoke}"
        return 30
    }
    grep -q 'Matrix sizes = 32x4 \* 4x8' "${smoke}" || {
        log_message "ERROR: the GEMM driver did not print the expected matrix header"
        print_log_tail "${smoke}"
        return 30
    }
    grep -Eq '^eigen cpu[[:space:]]+[0-9.eE+-]+s[[:space:]]+[0-9.]+ GFLOPS' "${smoke}" || {
        log_message "ERROR: the GEMM driver did not print the pinned throughput line"
        print_log_tail "${smoke}"
        return 30
    }
    log_message "GEMM driver ready: $(grep -E '^eigen cpu ' "${smoke}" | head -n 1 | sed 's/^ *//')"
}

# Build/run self-check: it prints the Eigen version read from the pinned upstream
# headers and multiplies two deterministic dense float matrices with Eigen, so a
# mis-compiled build fails here instead of during the measurement.
compile_probe() {
    local binary log runlog
    binary="$(probe_binary_path)"
    log="${PROBE_DIR}/compile-probe.log"
    runlog="${PROBE_DIR}/probe.log"
    mkdir -p "${PROBE_DIR}"
    log_message "compiling the Eigen self-check program inside the private container"
    eigen_container_exec c++ -std=c++17 -O3 -I "${SOURCE_DIR}" \
        "${SCRIPT_DIR}/scripts/eigen_probe.cpp" -o "${binary}" > "${log}" 2>&1 || {
        log_message "ERROR: the Eigen self-check program does not compile"
        print_log_tail "${log}"
        return 30
    }
    eigen_container_exec_at "${PROBE_DIR}" "${binary}" > "${runlog}" 2>&1 || {
        log_message "ERROR: the Eigen self-check program failed at runtime"
        print_log_tail "${runlog}"
        return 30
    }
    grep -q '^selftest=ok$' "${runlog}" || {
        log_message "ERROR: the Eigen self-check reported a failed matrix product"
        print_log_tail "${runlog}"
        return 30
    }
    log_message "self-check: $(grep -E '^(selftest|gemm_sum)' "${runlog}" | tr '\n' ' ')"
}

probe_version_value() {
    sed -n 's/^EIGEN_VERSION_STRING=//p' "${PROBE_DIR}/probe.log" | head -n 1
}

record_actual_version() {
    local value
    value="$(probe_version_value)" || value=""
    if [[ -z "${value}" ]]; then
        log_message "ERROR: could not read the Eigen version from the self-check program"
        return 30
    fi
    if [[ "${value}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested Eigen ${SOFTWARE_VERSION} but the built headers are ${value}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${value}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual Eigen version: ${value}"
}

# The compiler that actually built the case lives inside the private container;
# the provenance record must describe it, not the host toolchain.
compiler_identity() {
    eigen_container_exec c++ --version 2>/dev/null | head -n 1
}

build_eigen_base() {
    initialize_runtime || return $?
    prepare_eigen_build_container || return $?
    materialize_archive || return $?
    extract_source || return $?
    verify_source_version || return $?
    compile_gemm_driver || return $?
    compile_probe || return $?
    COMPILER_IDENTITY="$(compiler_identity)" || COMPILER_IDENTITY="unknown"
    log_message "compiler (container): ${COMPILER_IDENTITY:-unknown}"
    record_actual_version || return $?
    printf '%s\n' "${COMPILER_IDENTITY}" > "${PERF_WORK_DIR}/compiler.txt"
    printf 'container_image=%s\n' "$(eigen_container_exec sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"' || true)" \
        > "${PERF_WORK_DIR}/container-image.txt"
    log_message "base build completed: Eigen ${SOFTWARE_VERSION} bench_gemm matrix points=$(matrix_point_count), tries=${EIGEN_GEMM_TRIES}, repeats=${EIGEN_GEMM_REPEATS}, repetitions=${EIGEN_REPS}"
}
