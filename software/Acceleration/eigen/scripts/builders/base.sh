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
        gcc gcc-c++ make cmake tar gzip coreutils findutils sed gawk grep \
        util-linux file glibc-devel binutils python3 which || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
    eigen_container_exec cmake --version >/dev/null 2>&1 || {
        log_message "ERROR: cmake is not usable inside the private container"
        return 30
    }
    eigen_container_exec c++ --version >/dev/null 2>&1 || {
        log_message "ERROR: c++ is not usable inside the private container"
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
        eigen_container_exec test -f "${SOURCE_DIR}/bench/btl/CMakeLists.txt" >/dev/null 2>&1; then
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
    eigen_container_exec test -f "${SOURCE_DIR}/bench/btl/CMakeLists.txt" || {
        log_message "ERROR: the extracted archive does not contain bench/btl"
        return 30
    }
    if ! eigen_container_exec test -f "${SOURCE_DIR}/bench/spbench/CMakeLists.txt"; then
        log_message "WARNING: bench/spbench is not present in the archive"
    fi
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

# The "-march=native" style flag of the vectorised group.  aarch64 compilers do
# not all accept -mcpu=native, so the flag is verified by compiling a minimal
# program and persisted for the later stages.
resolve_native_flag() {
    local candidates=() flag
    if [[ -n "${EIGEN_NATIVE_FLAG}" ]]; then
        log_message "reusing resolved native flag: ${EIGEN_NATIVE_FLAG}"
        return 0
    fi
    case "${EXPECTED_ARCH}" in
        x86_64) candidates=(-march=native) ;;
        aarch64) candidates=(-mcpu=native -march=armv8-a+simd) ;;
        *)
            log_message "ERROR: no native flag rule for architecture ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    mkdir -p "${PROBE_DIR}"
    printf 'int main() { return 0; }\n' > "${PROBE_DIR}/flag-probe.cc"
    for flag in "${candidates[@]}"; do
        if eigen_container_exec_at "${PROBE_DIR}" \
            c++ -x c++ flag-probe.cc -o flag-probe "${flag}" \
            > "${PROBE_DIR}/flag-probe.log" 2>&1; then
            EIGEN_NATIVE_FLAG="${flag}"
            printf '%s\n' "${flag}" > "${NATIVE_FLAG_FILE}"
            log_message "vectorised group flag for ${EXPECTED_ARCH}: ${flag}"
            return 0
        fi
        log_message "WARNING: the compiler rejected ${flag}; trying the next candidate"
    done
    log_message "ERROR: no supported native instruction-set flag for ${EXPECTED_ARCH}"
    return 30
}

build_dir_for_group() {
    printf '%s/%s\n' "${BUILD_ROOT}" "$1"
}

configure_group() {
    local group="$1" flags build_dir log
    flags="$(group_cxx_flags "${group}")"
    build_dir="$(build_dir_for_group "${group}")"
    log="${PERF_WORK_DIR}/logs/configure-${group}.log"
    mkdir -p "${PERF_WORK_DIR}/logs"
    if eigen_container_exec test -f "${build_dir}/CMakeCache.txt" >/dev/null 2>&1; then
        log_message "reusing existing ${group} build tree: ${build_dir}"
        return 0
    fi
    rm -rf -- "${build_dir}"
    log_message "configuring ${group} BTL build tree inside the private container (CMAKE_CXX_FLAGS='${flags}')"
    # Eigen 5.0.1 still declares bench/btl with a pre-3.5 cmake_minimum_required;
    # CMake 4.x rejects that unless the policy floor is raised explicitly.
    eigen_container_exec_at "${SOURCE_DIR}" \
        cmake -S "${SOURCE_DIR}" -B "${build_dir}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_FLAGS="${flags}" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DEIGEN_BUILD_BTL=ON \
        -DEIGEN_BUILD_TESTING=OFF \
        -DEIGEN_BUILD_DOC=OFF \
        -DEIGEN_BUILD_DEMOS=OFF \
        -DEIGEN_BUILD_BLAS=OFF \
        -DEIGEN_BUILD_LAPACK=OFF \
        -DEIGEN_BUILD_SPBENCH=OFF \
        > "${log}" 2>&1 || {
        log_message "ERROR: cmake configure failed for group ${group}; see ${log}"
        print_log_tail "${log}"
        return 30
    }
    if ! eigen_container_exec grep -q "btl_eigen3_matmat" \
        "${build_dir}/bench/btl/libs/eigen3/Makefile" >/dev/null 2>&1; then
        log_message "WARNING: the ${group} build tree does not list btl_eigen3_matmat in its generated Makefile"
    fi
}

build_group() {
    local group="$1" build_dir log target
    build_dir="$(build_dir_for_group "${group}")"
    log="${PERF_WORK_DIR}/logs/build-${group}.log"
    log_message "building upstream BTL targets for group ${group} with -j${EIGEN_JOBS} inside the private container"
    eigen_container_exec_at "${build_dir}" \
        cmake --build "${build_dir}" -j "${EIGEN_JOBS}" \
        --target btl_eigen3_matmat btl_eigen3_vecmat btl_eigen3_adv btl_eigen3_linear \
        > "${log}" 2>&1 || {
        log_message "ERROR: BTL build failed for group ${group}; see ${log}"
        print_log_tail "${log}"
        return 30
    }
    for target in btl_eigen3_matmat btl_eigen3_vecmat btl_eigen3_adv btl_eigen3_linear; do
        if ! eigen_container_exec test -x "${build_dir}/bench/btl/libs/eigen3/${target}"; then
            log_message "ERROR: the ${group} build did not produce ${target}"
            return 30
        fi
    done
    log_message "BTL targets built for group ${group}"
}

compile_probe() {
    local group="$1" flags probe_binary log
    flags="$(group_cxx_flags "${group}")"
    mkdir -p "${PROBE_DIR}"
    probe_binary="${PROBE_DIR}/eigen_probe_${group}"
    log="${PROBE_DIR}/compile-${group}.log"
    log_message "compiling the Eigen self-check program with the ${group} flags inside the private container"
    # shellcheck disable=SC2086
    eigen_container_exec c++ -std=c++17 -O3 ${flags} -I "${SOURCE_DIR}" \
        "${SCRIPT_DIR}/scripts/eigen_probe.cpp" -o "${probe_binary}" > "${log}" 2>&1 || {
        log_message "ERROR: the Eigen self-check program does not compile with the ${group} flags"
        print_log_tail "${log}"
        return 30
    }
    eigen_container_exec_at "${PROBE_DIR}" "${probe_binary}" > "${PROBE_DIR}/${group}.txt" 2>&1 || {
        log_message "ERROR: the Eigen self-check program failed at runtime for group ${group}"
        print_log_tail "${PROBE_DIR}/${group}.txt"
        return 30
    }
    log_message "self-check (${group}): $(grep -c '^define ' "${PROBE_DIR}/${group}.txt") instruction-set macros, $(grep -E '^(selftest|gemm_sum)' "${PROBE_DIR}/${group}.txt" | tr '\n' ' ')"
}

# Fixed-dimension driver: reuses the unmodified upstream BTL action headers and
# the upstream Portable_Perf_Analyzer, with the measured dimension pinned.  The
# upstream sweep is measured as well, but it only times its largest size (see
# scripts/btl_single_point.cpp), so the per-dimension GFLOPS values come from
# this driver.  It is compiled and smoke-tested inside the private container.
compile_single_point() {
    local group="$1" flags binary log
    flags="$(group_cxx_flags "${group}")"
    binary="$(single_point_binary_path "${group}")"
    log="${PROBE_DIR}/compile-single-point-${group}.log"
    mkdir -p "${PROBE_DIR}"
    # shellcheck disable=SC2086
    eigen_container_exec c++ -std=c++17 -O3 -DNDEBUG -fno-exceptions ${flags} \
        -I "${SOURCE_DIR}/bench/btl/actions" \
        -I "${SOURCE_DIR}/bench/btl/generic_bench" \
        -I "${SOURCE_DIR}/bench/btl/generic_bench/utils" \
        -I "${SOURCE_DIR}/bench/btl/libs/eigen3" \
        -I "${SOURCE_DIR}/bench/btl/libs/STL" \
        -I "${SOURCE_DIR}" \
        "${SCRIPT_DIR}/scripts/btl_single_point.cpp" -o "${binary}" > "${log}" 2>&1 || {
        log_message "ERROR: the fixed-dimension BTL driver does not compile with the ${group} flags"
        print_log_tail "${log}"
        return 30
    }
    eigen_container_exec_at "${PROBE_DIR}" "${binary}" matrix_matrix 64 \
        > "${PROBE_DIR}/single-point-smoke-${group}.log" 2>&1 || {
        log_message "ERROR: the fixed-dimension BTL driver failed its smoke run for group ${group}"
        print_log_tail "${PROBE_DIR}/single-point-smoke-${group}.log"
        return 30
    }
    log_message "fixed-dimension BTL driver ready for group ${group}: $(tail -n 1 "${PROBE_DIR}/single-point-smoke-${group}.log" | sed 's/^ *//')"
}

probe_version_value() {
    local group="$1"
    sed -n 's/^EIGEN_VERSION_STRING=//p' "${PROBE_DIR}/${group}.txt" | head -n 1
}

verify_group_difference() {
    local group_a="$1" group_b="$2"
    local only_b
    only_b="$(comm -13 <(grep '^define ' "${PROBE_DIR}/${group_a}.txt" | sort) \
                       <(grep '^define ' "${PROBE_DIR}/${group_b}.txt" | sort) || true)"
    if [[ -n "${only_b}" ]]; then
        log_message "group ${group_b} additionally defines: $(printf '%s ' ${only_b})"
        return 0
    fi
    if [[ "${EXPECTED_ARCH}" == "aarch64" ]]; then
        log_message "WARNING: ${group_b} did not add a new instruction-set macro on aarch64; the compiler native flag may not expose extra features on this CPU"
        return 0
    fi
    log_message "ERROR: the ${group_b} group did not enable any additional instruction set"
    return 30
}

verify_group_versions() {
    local group expected="${SOFTWARE_VERSION}" value
    for group in "${EIGEN_GROUPS[@]}"; do
        value="$(probe_version_value "${group}")" || value=""
        if [[ "${value}" != "${expected}" ]]; then
            log_message "ERROR: the ${group} self-check reports Eigen ${value:-unknown}, requested ${expected}"
            return 30
        fi
    done
}

# Runtime self-check on a real upstream BTL target: the cholesky sweep is the
# cheapest complete upstream run (100 sizes, ~2 s) and proves that the measured
# binaries really execute the upstream benchmark engine and its size sweep.
btl_runtime_self_check() {
    local group="${EIGEN_GROUPS[0]}"
    local binary="${BUILD_ROOT}/${group}/bench/btl/libs/eigen3/btl_eigen3_adv"
    local scratch="${SCRATCH_DIR}/selfcheck"
    local log="${PERF_WORK_DIR}/logs/selfcheck-btl.log"
    eigen_container_exec test -x "${binary}" || {
        log_message "ERROR: BTL self-check binary is missing: ${binary}"
        return 30
    }
    rm -rf -- "${scratch}"
    mkdir -p "${scratch}"
    log_message "runtime self-check: one upstream BTL sweep (btl_eigen3_adv, action cholesky) inside the private container"
    if ! eigen_container_exec_at "${scratch}" \
        env BTL_CONFIG="-a cholesky ${EIGEN_BTL_CONFIG}" "${binary}" > "${log}" 2>&1; then
        log_message "ERROR: the upstream BTL self-check run failed; see ${log}"
        print_log_tail "${log}"
        return 30
    fi
    local size_lines
    size_lines="$(grep -c 'MFlops' "${log}" || true)"
    if ((size_lines < EIGEN_BTL_NB_POINT)); then
        log_message "ERROR: the BTL self-check produced ${size_lines} measurement lines, expected ${EIGEN_BTL_NB_POINT}"
        print_log_tail "${log}"
        return 30
    fi
    log_message "runtime self-check passed: ${size_lines} upstream BTL measurements (first: $(grep 'MFlops' "${log}" | head -n 1 | sed 's/^ *//'))"
}

record_actual_version() {
    local value
    value="$(probe_version_value "${EIGEN_GROUPS[0]}")" || value=""
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
    resolve_native_flag || return $?
    COMPILER_IDENTITY="$(compiler_identity)" || COMPILER_IDENTITY="unknown"
    CMAKE_IDENTITY="$(eigen_container_exec cmake --version 2>/dev/null | head -n 1)" || CMAKE_IDENTITY="unknown"
    log_message "compiler (container): ${COMPILER_IDENTITY:-unknown}"
    log_message "build tool (container): ${CMAKE_IDENTITY:-unknown}"
    local group
    for group in "${EIGEN_GROUPS[@]}"; do
        configure_group "${group}" || return $?
        build_group "${group}" || return $?
        compile_probe "${group}" || return $?
        compile_single_point "${group}" || return $?
    done
    verify_group_versions || return $?
    verify_group_difference "${EIGEN_GROUPS[0]}" "${EIGEN_GROUPS[1]}" || return $?
    btl_runtime_self_check || return $?
    record_actual_version || return $?
    printf '%s\n' "${COMPILER_IDENTITY}" > "${PERF_WORK_DIR}/compiler.txt"
    printf '%s\n' "${CMAKE_IDENTITY}" > "${PERF_WORK_DIR}/cmake.txt"
    printf 'container_image=%s\n' "$(eigen_container_exec sed -n 's/^PRETTY_NAME=//p' /etc/os-release 2>/dev/null | tr -d '"' || true)" \
        > "${PERF_WORK_DIR}/container-image.txt"
    log_message "base build completed: Eigen ${SOFTWARE_VERSION} BTL in $((${#EIGEN_GROUPS[@]})) build groups, $((${#EIGEN_ACTIONS[@]})) actions, ${EIGEN_REPS} repetitions"
}
