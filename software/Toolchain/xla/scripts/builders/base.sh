#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_build_dependencies() {
    local -a packages=(git curl jq python3 tar gzip unzip findutils sed coreutils which)
    local -a missing=()
    local -a dnf_options=()
    local package
    for package in "${packages[@]}"; do
        rpm -q "${package}" >/dev/null 2>&1 || missing+=("${package}")
    done
    (( ${#missing[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing build packages: ${missing[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    else
        log_message 'ERROR: dnf requires root or passwordless sudo'
        return 30
    fi
}

fetch_bazelisk() {
    local archive_name expected_sha256 local_archive
    case "${EXPECTED_ARCH}" in
        x86_64)
            archive_name="bazelisk-linux-amd64"
            expected_sha256="${BAZELISK_X86_64_SHA256}"
            ;;
        aarch64)
            archive_name="bazelisk-linux-arm64"
            expected_sha256="${BAZELISK_AARCH64_SHA256}"
            ;;
    esac
    mkdir -p "$(dirname "${BAZELISK_BIN}")"
    local_archive="${XLA_ARCHIVE_DIR}/${archive_name}-${BAZELISK_VERSION}"
    if [[ -x "${BAZELISK_BIN}" ]]; then
        log_message "reusing cached bazelisk ${BAZELISK_VERSION}"
    elif [[ -s "${local_archive}" ]]; then
        log_message "using local bazelisk archive: ${local_archive}"
        cp "${local_archive}" "${BAZELISK_BIN}" || return 30
    else
        log_message "downloading bazelisk ${BAZELISK_VERSION} for ${archive_name}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${BAZELISK_BIN}" \
            "${BAZELISK_RELEASE_BASE}/${BAZELISK_VERSION}/${archive_name}" || return 30
    fi
    verify_sha256 "${BAZELISK_BIN}" "${expected_sha256}" || return 30
    chmod 0755 "${BAZELISK_BIN}"
}

clone_xla() {
    log_message "cloning ${XLA_REPOSITORY} at ${XLA_COMMIT}"
    with_network_proxy git clone --quiet --filter=blob:none \
        "${XLA_REPOSITORY}" "${XLA_SRC_DIR}" || return 30
    with_network_proxy git -C "${XLA_SRC_DIR}" checkout --quiet --detach "${XLA_COMMIT}" || return 30
    local actual_commit
    actual_commit="$(git -C "${XLA_SRC_DIR}" rev-parse --short=12 HEAD)"
    [[ "${actual_commit}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: cloned XLA is ${actual_commit}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    [[ "$(git -C "${XLA_SRC_DIR}" rev-parse HEAD)" == "${XLA_COMMIT}" ]] || {
        log_message 'ERROR: full commit verification failed'
        return 30
    }
    printf '%s\n' "${actual_commit}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_xla_base() {
    initialize_runtime || return $?
    install_build_dependencies || return $?
    fetch_bazelisk || return $?
    clone_xla || return $?
    [[ -f "${XLA_SRC_DIR}/.bazelversion" ]] || {
        log_message 'ERROR: the pinned checkout has no .bazelversion'
        return 40
    }
    log_message "building the official benchmark harness with bazel $(< "${XLA_SRC_DIR}/.bazelversion")"
    (
        cd "${XLA_SRC_DIR}" || exit 40
        # The official build_binaries.sh configures the CPU backend first and
        # treats a configuration failure as informational.
        if [[ -f ./configure.py ]]; then
            with_network_proxy env TMPDIR="${TMPDIR}" \
                python3 ./configure.py --backend=CPU \
                || log_message 'WARN: configure.py --backend=CPU failed; continuing'
        fi
        with_network_proxy env TMPDIR="${TMPDIR}" \
            "${BAZELISK_BIN}" --output_user_root="${PERF_WORK_DIR}/bazel-root" \
            build -c opt --config=nonccl --jobs="$(getconf _NPROCESSORS_ONLN)" \
            //xla/tools/multihost_hlo_runner:hlo_runner_main \
            //xla/tools:compute_xspace_stats_main
    ) || return 40
    [[ -x "${HLO_RUNNER_BIN}" && -x "${XSPACE_STATS_BIN}" ]] || {
        log_message 'ERROR: benchmark harness binaries are missing after the build'
        return 40
    }
    [[ -f "${OFFICIAL_RUN_BENCHMARK}" ]] || {
        log_message 'ERROR: the official run_benchmark.sh is missing in the checkout'
        return 40
    }
    log_message "XLA ${SOFTWARE_VERSION} built with the official benchmark harness"
}
