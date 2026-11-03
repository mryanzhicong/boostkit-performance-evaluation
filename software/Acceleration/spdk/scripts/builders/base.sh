#!/usr/bin/env bash
# Base build for SPDK v26.09: verified sources (SPDK + DPDK fork + ISA-L),
# in-tree meson DPDK build, SPDK static libraries and the bdevperf example.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Assigned while the base build runs, then persisted to build-meta.json.
SPDK_SOURCE_ORIGIN=""
SPDK_SOURCE_ARCHIVE_SHA256=""
DPDK_SOURCE_ORIGIN=""
DPDK_SOURCE_ARCHIVE_SHA256=""
ISA_L_SOURCE_ORIGIN=""
ISA_L_SOURCE_ARCHIVE_SHA256=""
SPDK_CONFIGURE_ARGS=()
SPDK_DPDK_BUILD_FLAGS=""
SPDK_BUILD_STARTED=""
SPDK_BUILD_FINISHED=""
SPDK_ACTUAL_VERSION=""
SPDK_FULL_ACTUAL_VERSION=""
SPDK_HEADER_VERSION=""

# Software and register checks happen before anything is downloaded so a
# wrong request fails fast with the contract exit code 20.
check_platform() {
    local requested_arch runner_arch
    requested_arch="$(normalize_architecture "${EXPECTED_ARCH}")"
    runner_arch="$(normalize_architecture "$(uname -m)")"
    if [[ "${requested_arch}" != "${runner_arch}" ]]; then
        log_message "ERROR: requested architecture ${requested_arch} but the runner is ${runner_arch}"
        return 20
    fi
    case "${SOFTWARE_VERSION}" in
        "26.09") ;;
        *)
            log_message "ERROR: unsupported SPDK version ${SOFTWARE_VERSION}; this case is pinned to 26.09"
            return 20
            ;;
    esac
    case "${requested_arch}" in
        x86_64|aarch64) ;;
        *)
            log_message "ERROR: unsupported architecture ${requested_arch}"
            return 20
            ;;
    esac
}

spdk_source_candidates() {
    printf 'file:%s\n' "${SPDK_OFFLINE_DIR}/${SPDK_TARBALL_NAME}"
    printf 'file:%s\n' "${SPDK_OFFLINE_DIR}/spdk-${SPDK_RELEASE_TAG}.tar.gz"
    # gh-proxy passes the official codeload archive through unchanged.
    printf 'url:%s\n' "https://gh-proxy.com/https://github.com/spdk/spdk/archive/refs/tags/${SPDK_RELEASE_TAG}.tar.gz"
    # gitee repacks the archive, so only the normalised tree digest matches.
    printf 'url:%s\n' "https://gitee.com/mirrors/spdk/repository/archive/${SPDK_RELEASE_TAG}.tar.gz"
    printf 'url:%s\n' "https://github.com/spdk/spdk/archive/refs/tags/${SPDK_RELEASE_TAG}.tar.gz"
}

dpdk_source_candidates() {
    printf 'file:%s\n' "${SPDK_OFFLINE_DIR}/${DPDK_TARBALL_NAME}"
    printf 'url:%s\n' "https://gh-proxy.com/https://github.com/spdk/dpdk/archive/${DPDK_FORK_COMMIT}.tar.gz"
    printf 'url:%s\n' "https://github.com/spdk/dpdk/archive/${DPDK_FORK_COMMIT}.tar.gz"
}

isa_l_source_candidates() {
    printf 'file:%s\n' "${SPDK_OFFLINE_DIR}/${ISA_L_TARBALL_NAME}"
    printf 'url:%s\n' "https://gh-proxy.com/https://github.com/intel/isa-l/archive/${ISA_L_COMMIT}.tar.gz"
    printf 'url:%s\n' "https://gitee.com/mirrors/isa-l/repository/archive/${ISA_L_COMMIT}.tar.gz"
    printf 'url:%s\n' "https://github.com/intel/isa-l/archive/${ISA_L_COMMIT}.tar.gz"
}

acquire_spdk_source() {
    local candidates=()
    mapfile -t candidates < <(spdk_source_candidates)
    if ! acquire_verified_source "spdk" "${SPDK_TREE_SHA256}" "${SOURCE_DIR}" \
        "${PERF_WORK_DIR}/acquire/spdk" "${candidates[@]}"; then
        return 30
    fi
    SPDK_SOURCE_ORIGIN="${ACQUIRED_SOURCE_ORIGIN}"
    SPDK_SOURCE_ARCHIVE_SHA256="${ACQUIRED_ARCHIVE_SHA256}"
}

acquire_dpdk_source() {
    local candidates=()
    mapfile -t candidates < <(dpdk_source_candidates)
    if ! acquire_verified_source "dpdk" "${DPDK_TREE_SHA256}" "${DPDK_DIR}" \
        "${PERF_WORK_DIR}/acquire/dpdk" "${candidates[@]}"; then
        return 30
    fi
    DPDK_SOURCE_ORIGIN="${ACQUIRED_SOURCE_ORIGIN}"
    DPDK_SOURCE_ARCHIVE_SHA256="${ACQUIRED_ARCHIVE_SHA256}"
}

acquire_isa_l_source() {
    local candidates=()
    mapfile -t candidates < <(isa_l_source_candidates)
    if ! acquire_verified_source "isa-l" "${ISA_L_TREE_SHA256}" "${ISA_L_DIR}" \
        "${PERF_WORK_DIR}/acquire/isa-l" "${candidates[@]}"; then
        return 30
    fi
    ISA_L_SOURCE_ORIGIN="${ACQUIRED_SOURCE_ORIGIN}"
    ISA_L_SOURCE_ARCHIVE_SHA256="${ACQUIRED_ARCHIVE_SHA256}"
}

# Architecture-dependent build switches.  The DPDK submodule build
# (dpdkbuild/Makefile) picks the instruction set from the host unless the Arm
# platform detection script is unavailable, in which case it needs an explicit
# generic platform.
configure_spdk_build_environment() {
    SPDK_CONFIGURE_ARGS=(
        --disable-tests
        --disable-unit-tests
        --disable-apps
        # the case only runs bdevperf; build that single example explicitly
        --disable-examples
        --without-crypto
        --without-isal-crypto
        --without-dpdk-compressdev
        --without-ocf
        --without-xnvme
        --without-vfio-user
        --without-rbd
        --without-fsdev
        --without-avahi
        --without-golang
        --without-sma
        --without-nvme-cuse
    )
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        x86_64)
            # x86_64 keeps DPDK's native CPU instruction set and nasm kernels.
            SPDK_DPDK_BUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS:-}"
            ;;
        aarch64)
            # aarch64 assembles ISA-L with gas and, when the SoC is not a known
            # Arm machine, needs DPDK's generic platform target.
            SPDK_DPDK_BUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS:-}"
            if [[ ! -f "${DPDK_DIR}/config/arm/armv8_machine.py" ]]; then
                SPDK_DPDK_BUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS} -Dplatform=generic"
                SPDK_DPDK_BUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS# }"
            fi
            ;;
        *)
            log_message "ERROR: unsupported architecture for the build"
            return 20
            ;;
    esac
}

configure_spdk() {
    local log_file="${LOG_DIR}/configure.log" status
    log_message "configuring SPDK inside the private container: ./configure ${SPDK_CONFIGURE_ARGS[*]}"
    set +e
    spdk_container_exec_at "${SOURCE_DIR}" \
        env DPDKBUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS}" \
        ./configure "${SPDK_CONFIGURE_ARGS[@]}" 2>&1 | tee "${log_file}"
    status="${PIPESTATUS[0]}"
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log_message "ERROR: SPDK configure failed (exit ${status}); see ${log_file}"
        flush_log_tail "${log_file}" 40
        return 30
    fi
    [[ -f "${SOURCE_DIR}/mk/config.mk" ]] || {
        log_message 'ERROR: SPDK configure did not create mk/config.mk'
        return 30
    }
}

build_spdk() {
    local log_file="${LOG_DIR}/make.log" started finished
    if [[ ! "${SPDK_BUILD_JOBS}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: invalid build parallelism PERF_SPDK_BUILD_JOBS=${SPDK_BUILD_JOBS}"
        return 30
    fi
    started="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    # Build only what the measurement needs.  `--disable-examples` keeps the
    # default target from compiling the other examples; the single example the
    # case runs is then built explicitly on top of the libraries/modules.
    log_message "building SPDK libraries/modules and the bdevperf example inside the container with -j${SPDK_BUILD_JOBS} (log: ${log_file})"
    set +e
    spdk_container_exec_at "${SOURCE_DIR}" \
        env DPDKBUILD_FLAGS="${SPDK_DPDK_BUILD_FLAGS}" \
        bash -c 'make -j"${1}" && make -j"${1}" -C examples/bdev/bdevperf' \
        spdk-build "${SPDK_BUILD_JOBS}" 2>&1 | tee "${log_file}"
    local status="${PIPESTATUS[0]}"
    set -e
    if [[ "${status}" -ne 0 ]]; then
        log_message "ERROR: SPDK build failed (exit ${status}); see ${log_file}"
        flush_log_tail "${log_file}" 40
        return 30
    fi
    finished="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    SPDK_BUILD_STARTED="${started}"
    SPDK_BUILD_FINISHED="${finished}"
    [[ -x "${BDEVPERF_BIN}" ]] || {
        log_message "ERROR: bdevperf was not built at ${BDEVPERF_BIN}"
        return 30
    }
}

# The actual version must come from the built artifact, never from the request.
record_spdk_version() {
    local version_file="${SOURCE_DIR}/VERSION" header="${SOURCE_DIR}/include/spdk/version.h"
    [[ -s "${version_file}" ]] || {
        log_message "ERROR: built SPDK tree has no VERSION file"
        return 30
    }
    [[ -s "${header}" ]] || {
        log_message "ERROR: build did not generate include/spdk/version.h"
        return 30
    }
    local full_version major minor patch suffix actual_version
    full_version="$(tr -d '[:space:]' < "${version_file}")"
    major="$(awk '$1 == "#define" && $2 == "SPDK_VERSION_MAJOR" { print $3 }' "${header}")"
    minor="$(awk '$1 == "#define" && $2 == "SPDK_VERSION_MINOR" { print $3 }' "${header}")"
    patch="$(awk '$1 == "#define" && $2 == "SPDK_VERSION_PATCH" { print $3 }' "${header}")"
    suffix="$(awk -F'"' '$1 ~ /#define SPDK_VERSION_SUFFIX/ { print $2 }' "${header}")"
    if [[ -z "${major}" || -z "${minor}" || -z "${patch}" ]]; then
        log_message "ERROR: cannot read the SPDK version from ${header}"
        return 30
    fi
    actual_version="${major}.$(printf '%02d' "${minor}")"
    log_message "built SPDK ${actual_version} (full version: ${full_version}, patch ${patch}, suffix '${suffix}')"
    if [[ "${full_version}" != "${SPDK_FULL_VERSION}" ]]; then
        log_message "ERROR: built SPDK full version ${full_version} differs from the pinned ${SPDK_FULL_VERSION}"
        return 30
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested SPDK ${SOFTWARE_VERSION} but the built artifact reports ${actual_version}"
        return 30
    fi
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    SPDK_ACTUAL_VERSION="${actual_version}"
    SPDK_FULL_ACTUAL_VERSION="${full_version}"
    SPDK_HEADER_VERSION="${major}.${minor}.${patch}"
}

write_build_meta() {
    local compiler_version
    compiler_version="$(spdk_container_exec cc --version 2>/dev/null | sed -n '1p' || true)"
    [[ -n "${compiler_version}" ]] || compiler_version="unknown"
    python3 - "${BUILD_META_FILE}" \
        "${SPDK_ACTUAL_VERSION}" "${SPDK_FULL_ACTUAL_VERSION}" "${DPDK_FULL_VERSION}" \
        "${DPDK_FORK_COMMIT}" "${ISA_L_COMMIT}" \
        "${SPDK_TREE_SHA256}" "${DPDK_TREE_SHA256}" "${ISA_L_TREE_SHA256}" \
        "${SPDK_SOURCE_ARCHIVE_SHA256}" "${DPDK_SOURCE_ARCHIVE_SHA256}" "${ISA_L_SOURCE_ARCHIVE_SHA256}" \
        "${SPDK_SOURCE_ORIGIN}" "${DPDK_SOURCE_ORIGIN}" "${ISA_L_SOURCE_ORIGIN}" \
        "${SPDK_BUILD_JOBS}" "${SPDK_BUILD_STARTED}" "${SPDK_BUILD_FINISHED}" \
        "${compiler_version}" "${SPDK_CONFIGURE_ARGS[*]}" "${BDEVPERF_BIN}" \
        "$(normalize_architecture "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" <<'PYEOF'
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

(output, actual, actual_full, dpdk_full, dpdk_commit, isa_l_commit, spdk_tree,
 dpdk_tree, isa_l_tree, spdk_archive, dpdk_archive, isa_l_archive, spdk_origin,
 dpdk_origin, isa_l_origin, jobs, started, finished, compiler, configure_args,
 bdevperf, architecture, run_id) = sys.argv[1:]

payload = {
    "recorded_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "software": "spdk",
    "requested_version": os.environ.get("SOFTWARE_VERSION", actual),
    "actual_version": actual,
    "actual_full_version": actual_full,
    "architecture": architecture,
    "run_id": run_id,
    "dependencies": {
        "dpdk": {"version": dpdk_full, "commit": dpdk_commit, "source": dpdk_origin,
                 "archive_sha256": dpdk_archive, "source_tree_sha256": dpdk_tree},
        "isa_l": {"commit": isa_l_commit, "source": isa_l_origin,
                  "archive_sha256": isa_l_archive, "source_tree_sha256": isa_l_tree},
    },
    "sources": {
        "spdk": {"tag": "v" + actual, "source": spdk_origin,
                 "archive_sha256": spdk_archive, "source_tree_sha256": spdk_tree},
    },
    "build": {
        "jobs": int(jobs),
        "compiler": compiler,
        "configure_args": configure_args.split(),
        "targets": ["all (libraries and modules)", "examples/bdev/bdevperf"],
        "python_modules": ["jinja2", "yaml", "tabulate", "elftools"],
        "started_at": started,
        "finished_at": finished,
    },
    "binaries": {"bdevperf": bdevperf},
}
output_path = Path(output)
output_path.parent.mkdir(parents=True, exist_ok=True)
temporary = output_path.with_name(output_path.name + ".tmp")
temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
temporary.replace(output_path)
PYEOF
    [[ -s "${BUILD_META_FILE}" ]] || {
        log_message 'ERROR: cannot record the build metadata'
        return 30
    }
}

build_spdk_base() {
    initialize_runtime || return $?
    prepare_spdk_build_container || return 30
    check_platform || return $?
    install_build_dependencies || return $?
    ensure_python_modules || return $?
    acquire_spdk_source || return $?
    acquire_dpdk_source || return $?
    acquire_isa_l_source || return $?
    configure_spdk_build_environment || return $?
    configure_spdk || return $?
    build_spdk || return $?
    record_spdk_version || return $?
    write_build_meta || return $?
    log_message "SPDK ${SPDK_ACTUAL_VERSION} base build finished in the container: ${BDEVPERF_BIN}"
}
