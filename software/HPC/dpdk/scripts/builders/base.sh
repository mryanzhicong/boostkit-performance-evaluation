#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

verify_meson_and_elftools() {
    container_exec sh -c '
        set -eu
        gcc --version
        g++ --version
        meson --version
        ninja --version
        pkg-config --version
        python3 -c "import elftools; print(\"pyelftools:\", elftools.__version__)"
        python3 -c "
import subprocess, sys
ver = subprocess.check_output([\"meson\", \"--version\"], text=True).strip()
parts = tuple(int(p) for p in ver.split(\".\")[:2])
if parts < (0, 61):
    sys.exit(f\"meson >= 0.61 required, got {ver}\")
"
    ' > "${RESULTS_DIR}/toolchain-versions.txt" 2>&1 || {
        log 'ERROR: required DPDK build toolchain (gcc/meson>=0.61/ninja/pyelftools) check failed inside container'
        return 30
    }
}

build_dpdk_base() {
    local archive sha256_value source_version build_cpu ver_out actual_ver cache_line_size ldd_out test_cmd status=0
    local -a dnf_options=()
    initialize_runtime || return $?
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_dpdk_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing DPDK build dependencies inside the private container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make meson ninja-build \
        python3 python3-pyelftools pkgconf-pkg-config \
        numactl numactl-devel curl tar xz util-linux || {
        log 'ERROR: container build dependencies failed'
        return 30
    }
    verify_meson_and_elftools || return $?
    acquire_dpdk_tarball || return $?
    archive="${PERF_WORK_DIR}/${DPDK_TARBALL_NAME}"
    sha256_value="$(sha256sum "${archive}")"
    sha256_value="${sha256_value%% *}"
    printf '%s\n' "${sha256_value}" > "${DPDK_SHA_STATE_FILE}"
    printf 'md5=%s\nsha256=%s\narchive=%s\n' \
        "${DPDK_EXPECTED_MD5}" "${sha256_value}" "${DPDK_TARBALL_NAME}" > "${RESULTS_DIR}/source-checksum.txt"
    [[ ! -e "${DPDK_SOURCE_DIR}" ]] || {
        log "ERROR: refusing to extract into existing source directory: ${DPDK_SOURCE_DIR}"
        return 30
    }
    log "extracting ${DPDK_TARBALL_NAME} inside the private container"
    container_exec tar -xJf "${archive}" -C "${PERF_WORK_DIR}" || return 30
    [[ -f "${DPDK_SOURCE_DIR}/VERSION" ]] || {
        log "ERROR: extracted DPDK source missing VERSION file: ${DPDK_SOURCE_DIR}"
        return 30
    }
    source_version="$(tr -d '\r\n' < "${DPDK_SOURCE_DIR}/VERSION")"
    [[ "${source_version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: extracted DPDK VERSION is ${source_version}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    log 'configuring minimal CPU-side DPDK 26.11.0 with meson (-Dplatform=generic)'
    set +e
    container_exec meson setup "${DPDK_BUILD_DIR}" "${DPDK_SOURCE_DIR}" \
        --buildtype=release \
        -Dplatform=generic \
        -Ddefault_library=static \
        -Ddeveloper_mode=disabled \
        -Denable_apps=test \
        -Denable_drivers=mempool/ring \
        -Denable_libs=cmdline,hash,mbuf,mempool,ring,net,kvargs,rcu,timer,ptr_compress \
        -Dmax_lcores=detect \
        -Dmax_numa_nodes=detect \
        2>&1 | tee "${RESULTS_DIR}/meson-setup.log"
    status="${PIPESTATUS[0]}"
    set -e
    [[ "${status}" -eq 0 ]] || { log "ERROR: meson setup failed (rc=${status})"; return 40; }

    log 'building dpdk-test with ninja inside the private container'
    set +e
    container_exec sh -c 'ninja -C "$1" -j "$(nproc)"' sh "${DPDK_BUILD_DIR}" \
        2>&1 | tee "${RESULTS_DIR}/ninja-build.log"
    status="${PIPESTATUS[0]}"
    set -e
    [[ "${status}" -eq 0 ]] || { log "ERROR: ninja build failed (rc=${status})"; return 40; }

    [[ -x "${DPDK_TEST_BIN}" ]] || {
        log "ERROR: built dpdk-test binary missing: ${DPDK_TEST_BIN}"
        return 40
    }
    for test_cmd in hash_perf_autotest ring_perf_autotest memcpy_perf_autotest mempool_perf_autotest_1core; do
        grep -aFq "${test_cmd}" "${DPDK_TEST_BIN}" || {
            log "ERROR: required autotest command not compiled into dpdk-test: ${test_cmd}"
            return 40
        }
    done
    ldd_out="$(container_exec ldd "${DPDK_TEST_BIN}")" || {
        log 'ERROR: ldd failed on dpdk-test inside the container'
        return 40
    }
    if grep -q 'not found' <<< "${ldd_out}"; then
        log "ERROR: missing shared libraries for dpdk-test: ${ldd_out}"
        return 40
    fi
    container_exec meson configure "${DPDK_BUILD_DIR}" > "${RESULTS_DIR}/meson-config.txt" 2>&1 || return 40
    container_exec grep -nE 'RTE_MAX_LCORE|RTE_MAX_NUMA_NODES|RTE_CACHE_LINE_SIZE' \
        "${DPDK_BUILD_DIR}/rte_build_config.h" > "${RESULTS_DIR}/rte-build-config.txt" || return 40
    cache_line_size="$(sed -nE 's/^#define[[:space:]]+RTE_CACHE_LINE_SIZE[[:space:]]+([0-9]+).*/\1/p' "${DPDK_BUILD_DIR}/rte_build_config.h" | head -n 1)"
    [[ "${cache_line_size}" =~ ^[0-9]+$ ]] || {
        log 'ERROR: failed to read RTE_CACHE_LINE_SIZE from rte_build_config.h'
        return 40
    }
    printf '%s\n' "${cache_line_size}" > "${DPDK_CACHELINE_STATE_FILE}"

    container_exec python3 "${SCRIPT_DIR}/scripts/results/select_cpus.py" \
        --min-cores 1 --output "${DPDK_CPU_STATE_FILE}" || {
        log 'ERROR: failed to discover NUMA 0 physical CPU inside container'
        return 40
    }
    build_cpu="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["bench_cpu"])' "${DPDK_CPU_STATE_FILE}")"
    log "verifying actual built DPDK version via version_autotest on CPU ${build_cpu}"
    ver_out="$(container_exec env -u DPDK_TEST -u DPDK_TEST_PARAMS -u DPDK_TEST_SKIP \
        "${DPDK_TEST_BIN}" \
        -l "${build_cpu}" --main-lcore="${build_cpu}" \
        --no-pci --no-huge -m "${DPDK_MEM_MB}" \
        --file-prefix="dpdk-ver-${PERF_RUN_ID}" --no-telemetry \
        -- version_autotest 2>&1)" || {
        printf '%s\n' "${ver_out}" > "${RESULTS_DIR}/binary-version.txt"
        log 'ERROR: version_autotest failed inside the container'
        return 40
    }
    printf '%s\n' "${ver_out}" > "${RESULTS_DIR}/binary-version.txt"
    grep -q 'Test OK' <<< "${ver_out}" || {
        log 'ERROR: version_autotest did not report Test OK'
        return 40
    }
    actual_ver="$(printf '%s\n' "${ver_out}" | sed -nE 's/.*DPDK[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    [[ "${actual_ver}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: built binary reported DPDK '${actual_ver}', expected '${SOFTWARE_VERSION}'"
        return 40
    }
    printf '%s\n' "${actual_ver}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "DPDK ${actual_ver} generic static base build is ready inside container ${DPDK_CONTAINER_NAME}"
}
