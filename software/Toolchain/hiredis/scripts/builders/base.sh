#!/usr/bin/env bash
# Base build: fetch and verify the pinned hiredis source on the host, then build
# the static library with the upstream Makefile defaults and compile the
# case-owned benchmark harnesses inside this task's private openEuler container.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# Host prerequisites are Docker plus the download/verification tools; every
# compiler and build dependency is installed inside the container.
require_host_transfer_commands() {
    local missing=()
    local command_name
    for command_name in curl sha256sum tar; do
        command -v "${command_name}" >/dev/null 2>&1 || missing+=("${command_name}")
    done
    if (( ${#missing[@]} > 0 )); then
        fail_message "host download/verification tools are incomplete: ${missing[*]}; relying on the pre-placed offline archive"
    fi
    return 0
}

prepare_hiredis_build_container() {
    # install_weak_deps=False: the read-only /etc/passwd and /etc/group mounts
    # make scriptlets that call useradd/groupadd fail, so weak dependencies
    # (java-devel, shadow, dbus-daemon, ...) must not be pulled in.
    local -a dnf_options=(--setopt=install_weak_deps=False)
    require_host_transfer_commands
    require_hiredis_docker || return 30
    start_hiredis_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the hiredis build toolchain inside the private container"
    hiredis_container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make tar gzip coreutils findutils sed gawk grep \
        glibc-devel binutils util-linux python3 || {
        fail_message "container build dependencies failed to install"
        return 30
    }
}

build_hiredis_harnesses() {
    mkdir -p "${PERF_WORK_DIR}/hiredis-bench" || return 30

    log_message "compiling the RESP replay / formatting harness inside the private container"
    hiredis_container_exec_at "${CASE_DIR}" \
        cc ${HIREDIS_HARNESS_CFLAGS} -I "${HIREDIS_SRC_DIR}" \
        bench/resp_bench.c "${HIREDIS_LIBRARY}" -lm \
        -o "${HIREDIS_BENCH_BIN}" > "${HIREDIS_STATE_DIR}/harness-bench.log" 2>&1 || {
        fail_message "failed to compile bench/resp_bench.c, see ${HIREDIS_STATE_DIR}/harness-bench.log"
        return 30
    }

    log_message "compiling the upstream local-test runner inside the private container"
    hiredis_container_exec_at "${CASE_DIR}" \
        cc ${HIREDIS_HARNESS_CFLAGS} -I "${HIREDIS_SRC_DIR}" \
        -Dmain=hiredis_upstream_test_main \
        -DHIREDIS_EXPECT_LOCAL_TESTS="${HIREDIS_EXPECT_LOCAL_TESTS}" \
        bench/upstream_local_main.c "${HIREDIS_LIBRARY}" -lm \
        -o "${HIREDIS_UPSTREAM_BIN}" > "${HIREDIS_STATE_DIR}/harness-upstream.log" 2>&1 || {
        fail_message "failed to compile bench/upstream_local_main.c, see ${HIREDIS_STATE_DIR}/harness-upstream.log"
        return 30
    }

    log_message "compiling the offline network-namespace launcher inside the private container"
    hiredis_container_exec_at "${CASE_DIR}" \
        cc ${HIREDIS_HARNESS_CFLAGS} -I "${HIREDIS_SRC_DIR}" \
        bench/netns_loopback_up.c \
        -o "${HIREDIS_NETNS_PREP}" > "${HIREDIS_STATE_DIR}/harness-netns.log" 2>&1 || {
        fail_message "failed to compile bench/netns_loopback_up.c, see ${HIREDIS_STATE_DIR}/harness-netns.log"
        return 30
    }

    local binary
    for binary in "${HIREDIS_BENCH_BIN}" "${HIREDIS_UPSTREAM_BIN}" "${HIREDIS_NETNS_PREP}"; do
        if ! hiredis_container_exec test -x "${binary}"; then
            fail_message "benchmark harness binary is missing after the build: ${binary}"
            return 30
        fi
    done
    return 0
}

build_hiredis_base() {
    initialize_runtime || return $?
    prepare_hiredis_build_container || return $?

    log_message "fetching hiredis ${SOFTWARE_VERSION} source archive"
    fetch_source_archive || return $?

    if hiredis_container_exec test -e "${HIREDIS_SRC_DIR}"; then
        hiredis_container_exec rm -rf -- "${HIREDIS_SRC_DIR}"
    fi
    log_message "extracting ${HIREDIS_SOURCE_ARCHIVE} inside the private container"
    hiredis_container_exec tar -xzf "${HIREDIS_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}" || {
        fail_message "failed to extract ${HIREDIS_SOURCE_ARCHIVE}"
        return 30
    }
    if hiredis_container_exec test -d "${PERF_WORK_DIR}/hiredis-1.5.0"; then
        hiredis_container_exec mv -- "${PERF_WORK_DIR}/hiredis-1.5.0" "${HIREDIS_SRC_DIR}" || {
            fail_message "failed to place the extracted hiredis source tree"
            return 30
        }
    fi
    if ! hiredis_container_exec test -f "${HIREDIS_SRC_DIR}/Makefile" || \
        ! hiredis_container_exec test -f "${HIREDIS_SRC_DIR}/hiredis.h" || \
        ! hiredis_container_exec test -f "${HIREDIS_SRC_DIR}/test.c"; then
        fail_message "source archive does not contain the expected hiredis tree"
        return 30
    fi

    log_message "building the static hiredis library with -j${HIREDIS_BUILD_JOBS} inside the private container"
    hiredis_container_exec_at "${HIREDIS_SRC_DIR}" \
        make -j "${HIREDIS_BUILD_JOBS}" static OPTIMIZATION="${HIREDIS_OPTIMIZATION}" \
        > "${HIREDIS_STATE_DIR}/build.log" 2>&1 || {
        fail_message "hiredis build failed, see ${HIREDIS_STATE_DIR}/build.log"
        return 30
    }
    if ! hiredis_container_exec test -f "${HIREDIS_LIBRARY}"; then
        fail_message "static library was not produced: ${HIREDIS_LIBRARY}"
        return 30
    fi

    build_hiredis_harnesses || return $?

    local actual_version
    actual_version="$(hiredis_container_exec "${HIREDIS_BENCH_BIN}" --version 2>/dev/null || true)"
    if [[ -z "${actual_version}" ]]; then
        fail_message "cannot determine the built hiredis version"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "requested hiredis ${SOFTWARE_VERSION}, built ${actual_version}"
        return 30
    fi

    cat > "${HIREDIS_STATE_DIR}/build-provenance.txt" <<EOF
software=hiredis
version=${actual_version}
source_archive=${HIREDIS_SOURCE_NAME}
source_sha256=${HIREDIS_SOURCE_SHA256}
source_bytes=${HIREDIS_SOURCE_SIZE}
build_target=static
optimization=${HIREDIS_OPTIMIZATION}
harness_cflags=${HIREDIS_HARNESS_CFLAGS}
build_jobs=${HIREDIS_BUILD_JOBS}
c_compiler=$(compiler_identity)
container_image=$(hiredis_container_exec cat /etc/os-release 2>/dev/null | sed -n 's/^PRETTY_NAME=//p' | tr -d '"' || true)
library=${HIREDIS_LIBRARY}
benchmark_binary=${HIREDIS_BENCH_BIN}
netns_loopback_launcher=${HIREDIS_NETNS_PREP}
upstream_test_binary=${HIREDIS_UPSTREAM_BIN}
upstream_expected_local_tests=${HIREDIS_EXPECT_LOCAL_TESTS}
EOF
    log_message "hiredis ${actual_version} built; harnesses compiled inside the private container"
    return 0
}
