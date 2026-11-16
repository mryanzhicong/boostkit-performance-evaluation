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

prepare_rinetd_build_container() {
    # install_weak_deps=False: the read-only /etc/passwd and /etc/group mounts
    # make scriptlets that call useradd/groupadd fail, so weak dependencies
    # (java-devel, shadow, dbus-daemon, ...) must not be pulled in.
    local -a dnf_options=(--setopt=install_weak_deps=False)
    require_rinetd_docker || return 30
    start_rinetd_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the rinetd build toolchain inside the private container"
    rinetd_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make tar gzip coreutils findutils sed gawk grep \
        glibc-devel binutils util-linux python3 || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
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

# Runs one host function body inside the container at the given directory.
container_at() {
    local directory="$1"
    shift
    rinetd_container_exec_at "${directory}" "$@"
}

build_rinetd_binary() {
    if rinetd_container_exec test -e "${RINETD_SOURCE_DIR}"; then
        log_message "ERROR: rinetd source directory already exists: ${RINETD_SOURCE_DIR}"
        return 20
    fi
    download_rinetd_archive || { report_attempted_sources; return 30; }
    log_message "extracting ${RINETD_ARCHIVE_NAME} inside the private container"
    rinetd_container_exec tar -C "${PERF_WORK_DIR}/src" -xzf "${RINETD_ARCHIVE}" || {
        log_message "ERROR: cannot extract ${RINETD_ARCHIVE}"
        return 30
    }
    log_message "configuring rinetd ${RINETD_VERSION} inside the private container"
    if ! rinetd_container_exec_at "${RINETD_SOURCE_DIR}" \
        ./configure --prefix="${RINETD_PREFIX}" >"${LOG_DIR}/configure.log" 2>&1; then
        log_message "ERROR: configuring rinetd ${RINETD_VERSION} failed"
        tail -n 40 -- "${LOG_DIR}/configure.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    log_message "building rinetd ${RINETD_VERSION} with make -j${RINETD_BUILD_JOBS} inside the private container"
    if ! rinetd_container_exec_at "${RINETD_SOURCE_DIR}" \
        make -j"${RINETD_BUILD_JOBS}" >"${LOG_DIR}/make.log" 2>&1; then
        log_message "ERROR: building rinetd ${RINETD_VERSION} failed"
        tail -n 40 -- "${LOG_DIR}/make.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    log_message "installing rinetd ${RINETD_VERSION} inside the private container"
    if ! rinetd_container_exec_at "${RINETD_SOURCE_DIR}" \
        make install >"${LOG_DIR}/install.log" 2>&1; then
        log_message "ERROR: installing rinetd ${RINETD_VERSION} failed"
        tail -n 40 -- "${LOG_DIR}/install.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    if ! rinetd_container_exec test -x "${RINETD_BIN}"; then
        log_message "ERROR: rinetd binary was not installed: ${RINETD_BIN}"
        return 30
    fi
    local reported
    reported="$(rinetd_container_exec "${RINETD_BIN}" -v 2>&1 | awk '{print $2; exit}')" || {
        log_message "ERROR: cannot query the rinetd version: ${RINETD_BIN} -v"
        return 30
    }
    RINETD_VERSION_STRING="${reported}"
    [[ "${RINETD_VERSION_STRING}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: built rinetd reports ${RINETD_VERSION_STRING}, requested ${SOFTWARE_VERSION}"
        return 30
    }
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${RINETD_VERSION_STRING}" > "${PERF_ACTUAL_VERSION_FILE}" || return 30
    log_message "rinetd ${RINETD_VERSION_STRING} is ready at ${RINETD_BIN}"
}

build_rinetd_benchmark() {
    local source="${SCRIPT_DIR}/scripts/bench/rinetd_bench.c"
    if ! rinetd_container_exec test -f "${source}"; then
        log_message "ERROR: benchmark harness source is missing: ${source}"
        return 30
    fi
    log_message "compiling the loopback TCP benchmark harness inside the private container (log: logs/bench-build.log)"
    if ! rinetd_container_exec gcc -O2 -std=c11 -Wall -Wextra -pthread \
        -o "${RINETD_BENCH_BIN}" "${source}" >"${LOG_DIR}/bench-build.log" 2>&1; then
        log_message "ERROR: compiling the rinetd benchmark harness failed"
        tail -n 40 -- "${LOG_DIR}/bench-build.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    if ! rinetd_container_exec test -x "${RINETD_BENCH_BIN}"; then
        log_message "ERROR: benchmark harness was not produced: ${RINETD_BENCH_BIN}"
        return 30
    fi
    return 0
}

verify_rinetd_build() {
    local reported
    reported="$(rinetd_container_exec "${RINETD_BIN}" -v 2>&1 | head -n 1)"
    log_message "version probe: ${reported}"
    [[ "${reported}" == "rinetd ${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: version probe does not match rinetd ${SOFTWARE_VERSION}: ${reported}"
        return 30
    }
}

build_rinetd_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    prepare_rinetd_build_container || return $?
    build_rinetd_binary || return $?
    build_rinetd_benchmark || return $?
    verify_rinetd_build || return $?
    log_message "rinetd ${RINETD_VERSION_STRING} and the benchmark harness are ready inside the private container"
}
