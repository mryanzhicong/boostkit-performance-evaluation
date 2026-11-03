#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

check_architecture() {
    local actual expected
    actual="$(normalize_architecture "$(uname -m)")"
    expected="$(normalize_architecture "${EXPECTED_ARCH}")"
    [[ "${actual}" == "${expected}" ]] || {
        log_message "ERROR: expected architecture ${expected}, runner is ${actual}"
        return 20
    }
}

version_from_gmp_header() {
    local header="${GMP_PREFIX}/include/gmp.h"
    [[ -f "${header}" ]] || return 1
    local major minor patch
    major="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION" {print $3; exit}' "${header}")"
    minor="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION_MINOR" {print $3; exit}' "${header}")"
    patch="$(awk '$1 == "#define" && $2 == "__GNU_MP_VERSION_PATCHLEVEL" {print $3; exit}' "${header}")"
    [[ -n "${major}" && -n "${minor}" ]] || return 1
    printf '%s.%s.%s\n' "${major}" "${minor}" "${patch:-0}"
}

version_from_mpfr_header() {
    local header="${MPFR_PREFIX}/include/mpfr.h"
    [[ -f "${header}" ]] || return 1
    awk '$1 == "#define" && $2 == "MPFR_VERSION_STRING" {gsub(/"/, "", $3); print $3; exit}' "${header}"
}

version_from_mpc_header() {
    local header="${MPC_PREFIX}/include/mpc.h"
    [[ -f "${header}" ]] || return 1
    awk '$1 == "#define" && $2 == "MPC_VERSION_STRING" {gsub(/"/, "", $3); print $3; exit}' "${header}"
}

run_logged() {
    local log_file="$1" label="$2"
    shift 2
    log_message "${label} (log: ${log_file})"
    if ! "$@" >"${log_file}" 2>&1; then
        log_message "ERROR: ${label} failed"
        log_message "---- tail of ${log_file} ----"
        tail -n 40 -- "${log_file}" | while IFS= read -r line; do log_message "  ${line}"; done
        log_message "---- end of ${log_file} ----"
        return 30
    fi
}

# The host keeps only the download/verification tools; every build command runs
# through the private container with the case work directory mounted unchanged.
require_host_transfer_commands() {
    local command_name
    for command_name in curl sha256sum awk sed; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required host command is unavailable: ${command_name}"
            return 30
        }
    done
}

prepare_libmpc_build_container() {
    require_libmpc_docker || return 30
    start_libmpc_container || return $?
    if ! libmpc_container_exec_root dnf --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make m4 tar xz gzip diffutils findutils coreutils \
        sed gawk grep util-linux file binutils glibc-devel python3 \
        >"${LOG_DIR}/container-packages.log" 2>&1; then
        log_message "ERROR: failed to install the container build packages"
        tail -n 40 -- "${LOG_DIR}/container-packages.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    log_message "container build packages are installed"
}

run_logged_at() {
    local workdir="$1" log_file="$2" label="$3"
    shift 3
    log_message "${label} (log: ${log_file})"
    if ! libmpc_container_exec_at "${workdir}" "$@" >"${log_file}" 2>&1; then
        log_message "ERROR: ${label} failed"
        log_message "---- tail of ${log_file} ----"
        tail -n 40 -- "${log_file}" | while IFS= read -r line; do log_message "  ${line}"; done
        log_message "---- end of ${log_file} ----"
        return 30
    fi
}

extract_archive() {
    local archive="$1" destination="$2" label="$3"
    log_message "extracting ${label}"
    libmpc_container_exec tar -C "${PERF_WORK_DIR}/src" -xf "${archive}" || {
        log_message "ERROR: cannot extract ${archive}"
        return 30
    }
}

build_gmp_dependency() {
    [[ ! -e "${GMP_SOURCE_DIR}" ]] || {
        log_message "ERROR: GMP source directory already exists: ${GMP_SOURCE_DIR}"
        return 20
    }
    download_gmp_archive || { report_attempted_sources; return 30; }
    extract_archive "${GMP_ARCHIVE}" "${GMP_SOURCE_DIR}" "${GMP_ARCHIVE_NAME}" || return 30
    run_logged_at "${GMP_SOURCE_DIR}" "${LOG_DIR}/gmp-configure.log" "configuring GMP ${GMP_VERSION}" \
        ./configure --prefix="${GMP_PREFIX}" --disable-shared --enable-static || return $?
    run_logged_at "${GMP_SOURCE_DIR}" "${LOG_DIR}/gmp-make.log" "building GMP ${GMP_VERSION} with make -j${MPC_BUILD_JOBS}" \
        make -j"${MPC_BUILD_JOBS}" || return $?
    run_logged_at "${GMP_SOURCE_DIR}" "${LOG_DIR}/gmp-install.log" "installing GMP ${GMP_VERSION}" make install || return $?
    GMP_VERSION_STRING="$(version_from_gmp_header)" || {
        log_message "ERROR: cannot read the GMP version from gmp.h"
        return 30
    }
    [[ "${GMP_VERSION_STRING}" == "${GMP_VERSION}" ]] || {
        log_message "ERROR: dependency GMP reports ${GMP_VERSION_STRING}, expected ${GMP_VERSION}"
        return 30
    }
    log_message "GMP ${GMP_VERSION_STRING} dependency is ready at ${GMP_PREFIX}"
}

build_mpfr_dependency() {
    [[ ! -e "${MPFR_SOURCE_DIR}" ]] || {
        log_message "ERROR: MPFR source directory already exists: ${MPFR_SOURCE_DIR}"
        return 20
    }
    download_mpfr_archive || { report_attempted_sources; return 30; }
    extract_archive "${MPFR_ARCHIVE}" "${MPFR_SOURCE_DIR}" "${MPFR_DEP_ARCHIVE_NAME}" || return 30
    run_logged_at "${MPFR_SOURCE_DIR}" "${LOG_DIR}/mpfr-configure.log" "configuring MPFR ${MPFR_DEP_VERSION} against ${GMP_PREFIX}" \
        ./configure --prefix="${MPFR_PREFIX}" --with-gmp="${GMP_PREFIX}" --disable-shared || return $?
    run_logged_at "${MPFR_SOURCE_DIR}" "${LOG_DIR}/mpfr-make.log" "building MPFR ${MPFR_DEP_VERSION} with make -j${MPC_BUILD_JOBS}" \
        make -j"${MPC_BUILD_JOBS}" || return $?
    run_logged_at "${MPFR_SOURCE_DIR}" "${LOG_DIR}/mpfr-install.log" "installing MPFR ${MPFR_DEP_VERSION}" make install || return $?
    MPFR_VERSION_STRING="$(version_from_mpfr_header)" || {
        log_message "ERROR: cannot read the MPFR version from mpfr.h"
        return 30
    }
    [[ "${MPFR_VERSION_STRING}" == "${MPFR_DEP_VERSION}" ]] || {
        log_message "ERROR: dependency MPFR reports ${MPFR_VERSION_STRING}, expected ${MPFR_DEP_VERSION}"
        return 30
    }
    log_message "MPFR ${MPFR_VERSION_STRING} dependency is ready at ${MPFR_PREFIX}"
}

build_mpc_library() {
    [[ ! -e "${MPC_SOURCE_DIR}" ]] || {
        log_message "ERROR: libmpc source directory already exists: ${MPC_SOURCE_DIR}"
        return 20
    }
    download_mpc_archive || { report_attempted_sources; return 30; }
    extract_archive "${MPC_ARCHIVE}" "${MPC_SOURCE_DIR}" "${MPC_ARCHIVE_NAME}" || return 30
    run_logged_at "${MPC_SOURCE_DIR}" "${LOG_DIR}/configure.log" "configuring libmpc ${MPC_VERSION} against GMP and MPFR prefixes" \
        ./configure --prefix="${MPC_PREFIX}" \
            --with-gmp="${GMP_PREFIX}" --with-mpfr="${MPFR_PREFIX}" --disable-shared || return $?
    run_logged_at "${MPC_SOURCE_DIR}" "${LOG_DIR}/make.log" "building libmpc ${MPC_VERSION} with make -j${MPC_BUILD_JOBS}" \
        make -j"${MPC_BUILD_JOBS}" || return $?
    run_logged_at "${MPC_SOURCE_DIR}" "${LOG_DIR}/install.log" "installing libmpc ${MPC_VERSION}" make install || return $?
    MPC_VERSION_STRING="$(version_from_mpc_header)" || {
        log_message "ERROR: cannot read the libmpc version from mpc.h"
        return 30
    }
    [[ "${MPC_VERSION_STRING}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built libmpc reports ${MPC_VERSION_STRING}, requested ${SOFTWARE_VERSION}"
        return 30
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${MPC_VERSION_STRING}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
}

build_mpc_benchmark() {
    local source="${SCRIPT_DIR}/scripts/bench/mpc_bench.c"
    [[ -f "${source}" ]] || {
        log_message "ERROR: benchmark harness source is missing: ${source}"
        return 30
    }
    log_message "compiling the fixed-workload libmpc benchmark harness (log: logs/bench-build.log)"
    if ! libmpc_container_exec gcc -O2 -std=c11 -Wall -Wextra -o "${MPC_BENCH_BIN}" "${source}" \
        -I"${MPC_PREFIX}/include" -I"${MPFR_PREFIX}/include" -I"${GMP_PREFIX}/include" \
        -L"${MPC_PREFIX}/lib" -L"${MPFR_PREFIX}/lib" -L"${GMP_PREFIX}/lib" \
        -lmpc -lmpfr -lgmp -lm >"${LOG_DIR}/bench-build.log" 2>&1; then
        log_message "ERROR: compiling the libmpc benchmark harness failed"
        tail -n 40 -- "${LOG_DIR}/bench-build.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    libmpc_container_exec test -x "${MPC_BENCH_BIN}" || {
        log_message "ERROR: benchmark harness was not produced: ${MPC_BENCH_BIN}"
        return 30
    }
}

verify_mpc_build() {
    local version_line
    version_line="$(libmpc_container_exec "${MPC_BENCH_BIN}" mpc_mul 256 2>&1 | grep '^VERSION ' || true)"
    [[ -n "${version_line}" ]] || {
        log_message "ERROR: benchmark harness cannot report its library versions"
        return 30
    }
    log_message "${version_line}"
    [[ "${version_line}" == *"mpc=${SOFTWARE_VERSION}"* ]] || {
        log_message "ERROR: harness links an unexpected libmpc version: ${version_line}"
        return 30
    }
}

build_mpc_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    require_host_transfer_commands || return $?
    prepare_libmpc_build_container || return $?
    build_gmp_dependency || return $?
    build_mpfr_dependency || return $?
    build_mpc_library || return $?
    build_mpc_benchmark || return $?
    verify_mpc_build || return $?
    log_message "libmpc ${MPC_VERSION_STRING} (GMP ${GMP_VERSION_STRING}, MPFR ${MPFR_VERSION_STRING}) is ready at ${MPC_PREFIX}"
}
