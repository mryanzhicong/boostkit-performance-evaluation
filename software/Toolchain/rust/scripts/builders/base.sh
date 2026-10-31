#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

RUST_BUILD_PACKAGES=(git curl tar xz gcc gcc-c++ make cmake openssl-devel
    zlib-devel perl pkgconf python3 perf findutils sed coreutils diffutils which)

install_build_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing build packages inside the Rust container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${RUST_BUILD_PACKAGES[@]}" || {
        log_message 'ERROR: failed to install build packages inside the Rust container'
        return 30
    }
    local command_name
    for command_name in git curl tar xz gcc make cmake python3 perf; do
        container_exec command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required command is missing in the Rust container: ${command_name}"
            return 30
        }
    done
}

install_rust_toolchain() {
    local offline_archive="${RUST_ARCHIVE_DIR}/${RUST_ARCHIVE}"
    local archive="${PERF_WORK_DIR}/${RUST_ARCHIVE}"
    local unpack_dir="${PERF_WORK_DIR}/rust-unpack"
    if [[ -s "${offline_archive}" ]]; then
        log_message "using local Rust archive: ${offline_archive}"
        cp "${offline_archive}" "${archive}" || return 30
    elif [[ -s "${archive}" ]]; then
        log_message "using cached Rust archive: ${archive}"
    else
        log_message "downloading official Rust ${SOFTWARE_VERSION} for ${RUST_TARGET_TRIPLE}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive}" \
            "${RUST_RELEASE_BASE}/${RUST_ARCHIVE}" || return 30
    fi
    printf '%s  %s\n' "${RUST_ARCHIVE_SHA256}" "${archive}" | sha256sum -c - || return 30
    container_exec rm -rf "${unpack_dir}"
    container_exec mkdir -p "${unpack_dir}"
    log_message "installing the official toolchain into ${RUST_HOME} inside the container"
    container_exec sh -c \
        "tar -xJf '${archive}' -C '${unpack_dir}' && cd '${unpack_dir}/rust-${SOFTWARE_VERSION}-${RUST_TARGET_TRIPLE}' && ./install.sh --prefix='${RUST_HOME}' --without=rust-docs,rust-docs-json-preview --disable-ldconfig" || return 30
    container_exec test -x "${RUSTC_BIN}" || {
        log_message 'ERROR: official toolchain installation is incomplete'
        return 30
    }
    record_actual_version || return $?
    log_message "installed rustc: $(< "${PERF_WORK_DIR}/rustc-version.txt")"
}

install_rustc_perf() {
    local offline_archive="${RUST_ARCHIVE_DIR}/rustc-perf-${RUSTC_PERF_REVISION}.tar.gz"
    local staged_archive="${PERF_WORK_DIR}/rustc-perf-${RUSTC_PERF_REVISION}.tar.gz"
    if [[ -d "${RUSTC_PERF_DIR}/.git" ]]; then
        log_message 'rustc-perf checkout already present in this work directory'
        [[ "$(container_exec git -C "${RUSTC_PERF_DIR}" rev-parse HEAD)" == "${RUSTC_PERF_REVISION}" ]] || {
            log_message "ERROR: rustc-perf checkout is not at ${RUSTC_PERF_REVISION}"
            return 30
        }
    elif [[ -s "${offline_archive}" ]]; then
        # The offline archive is produced by `git archive` from the pinned
        # revision, so a sidecar marker file records it for verification.
        log_message "using local rustc-perf archive: ${offline_archive}"
        cp "${offline_archive}" "${staged_archive}" || return 30
        container_exec mkdir -p "${RUSTC_PERF_DIR}"
        container_exec tar -xzf "${staged_archive}" -C "${RUSTC_PERF_DIR}" --strip-components=1 || return 30
        container_exec test -f "${RUSTC_PERF_DIR}/collector/compile-benchmarks/README.md" || {
            log_message 'ERROR: local rustc-perf archive is incomplete'
            return 30
        }
        printf '%s\n' "${RUSTC_PERF_REVISION}" > "${RUSTC_PERF_DIR}/.boostkit-revision"
    else
        log_message "fetching upstream rustc-perf ${RUSTC_PERF_REVISION}"
        container_exec git init -q "${RUSTC_PERF_DIR}" || return 30
        container_exec git -C "${RUSTC_PERF_DIR}" remote add origin "${RUSTC_PERF_REPOSITORY}" || return 30
        container_exec git -C "${RUSTC_PERF_DIR}" fetch --depth 1 origin "${RUSTC_PERF_REVISION}" || return 30
        container_exec git -C "${RUSTC_PERF_DIR}" checkout --detach FETCH_HEAD || return 30
        [[ "$(container_exec git -C "${RUSTC_PERF_DIR}" rev-parse HEAD)" == "${RUSTC_PERF_REVISION}" ]] || {
            log_message "ERROR: rustc-perf checkout is not at ${RUSTC_PERF_REVISION}"
            return 30
        }
    fi
    container_exec test -f "${RUSTC_PERF_DIR}/collector/compile-benchmarks/README.md" || {
        log_message 'ERROR: rustc-perf checkout is missing its benchmark suite'
        return 30
    }
}

build_collector() {
    log_message 'building the unmodified upstream collector with the installed toolchain inside the container'
    # The private toolchain prefix is not on the container PATH by default.
    container_exec sh -c \
        "export PATH='${RUST_HOME}/bin:\$PATH' && cd '${RUSTC_PERF_DIR}' && cargo build -p collector --release --locked --quiet" || return 30
    container_exec test -x "${COLLECTOR_BIN}" || {
        log_message 'ERROR: collector binary is missing after the build'
        return 30
    }
}

build_rust_base() {
    initialize_runtime || return $?
    require_rust_container || return $?
    install_build_dependencies || return $?
    install_rust_toolchain || return $?
    install_rustc_perf || return $?
    build_collector || return $?
}
