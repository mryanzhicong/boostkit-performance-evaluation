#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

XLA_BUILD_PACKAGES=(git curl jq python3 tar gzip unzip findutils sed coreutils
    which diffutils patch make gcc gcc-c++)

install_build_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing build packages inside the XLA container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${XLA_BUILD_PACKAGES[@]}" || {
        log_message 'ERROR: failed to install build packages inside the XLA container'
        return 30
    }
    local command_name
    for command_name in git curl jq python3 tar unzip; do
        container_exec command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required command is missing in the XLA container: ${command_name}"
            return 30
        }
    done
}

# The bazelisk binary lives under PERF_WORK_DIR, which is bind-mounted into the
# container; the offline archive is read on the host and staged there.
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
    log_message "cloning ${XLA_REPOSITORY} at ${XLA_COMMIT} inside the container"
    container_exec git clone --quiet --filter=blob:none \
        "${XLA_REPOSITORY}" "${XLA_SRC_DIR}" || return 30
    container_exec git -C "${XLA_SRC_DIR}" checkout --quiet --detach "${XLA_COMMIT}" || return 30
    local actual_commit
    actual_commit="$(container_exec git -C "${XLA_SRC_DIR}" rev-parse --short=12 HEAD)" || return 30
    [[ "${actual_commit}" == "${SOFTWARE_VERSION}" ]] || {
        log_message "ERROR: cloned XLA is ${actual_commit}, expected ${SOFTWARE_VERSION}"
        return 30
    }
    [[ "$(container_exec git -C "${XLA_SRC_DIR}" rev-parse HEAD)" == "${XLA_COMMIT}" ]] || {
        log_message 'ERROR: full commit verification failed'
        return 30
    }
    printf '%s\n' "${actual_commit}" > "${PERF_ACTUAL_VERSION_FILE}"
}

build_xla_base() {
    initialize_runtime || return $?
    require_xla_container || return $?
    install_build_dependencies || return $?
    fetch_bazelisk || return $?
    clone_xla || return $?
    container_exec test -f "${XLA_SRC_DIR}/.bazelversion" || {
        log_message 'ERROR: the pinned checkout has no .bazelversion'
        return 40
    }
    log_message "building the official benchmark harness inside the container"
    container_exec sh -c \
        "cd '${XLA_SRC_DIR}' && \
         if [ -f ./configure.py ]; then python3 ./configure.py --backend=CPU || true; fi && \
         '${BAZELISK_BIN}' --output_user_root='${PERF_WORK_DIR}/bazel-root' \
           build -c opt --config=nonccl --jobs='$(getconf _NPROCESSORS_ONLN)' \
           //xla/tools/multihost_hlo_runner:hlo_runner_main \
           //xla/tools:compute_xspace_stats_main" || return 40
    container_exec test -x "${HLO_RUNNER_BIN}" || {
        log_message 'ERROR: benchmark harness binaries are missing after the build'
        return 40
    }
    container_exec test -x "${XSPACE_STATS_BIN}" || {
        log_message 'ERROR: benchmark harness binaries are missing after the build'
        return 40
    }
    container_exec test -f "${OFFICIAL_RUN_BENCHMARK}" || {
        log_message 'ERROR: the official run_benchmark.sh is missing in the checkout'
        return 40
    }
    log_message "XLA ${SOFTWARE_VERSION} built with the official benchmark harness"
}
