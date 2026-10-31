#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_build_dependencies() {
    local -a packages=(git curl tar xz gcc gcc-c++ openssl-devel perl pkgconf python3 perf)
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

install_rust_toolchain() {
    local archive="${RUST_ARCHIVE_DIR}/${RUST_ARCHIVE}"
    local unpack_dir="${PERF_WORK_DIR}/rust-unpack"
    if [[ ! -s "${archive}" ]]; then
        archive="${PERF_WORK_DIR}/${RUST_ARCHIVE}"
        if [[ ! -s "${archive}" ]]; then
            log_message "downloading official Rust ${SOFTWARE_VERSION} for ${RUST_TARGET_TRIPLE}"
            with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
                -o "${archive}" \
                "${RUST_RELEASE_BASE}/${RUST_ARCHIVE}" || return 30
        fi
    else
        log_message "using local Rust archive: ${archive}"
    fi
    printf '%s  %s\n' "${RUST_ARCHIVE_SHA256}" "${archive}" | sha256sum -c - || return 30
    rm -rf "${unpack_dir}"
    mkdir -p "${unpack_dir}"
    tar -xJf "${archive}" -C "${unpack_dir}" || return 30
    log_message "installing the official toolchain into ${RUST_HOME}"
    (cd "${unpack_dir}/rust-${SOFTWARE_VERSION}-${RUST_TARGET_TRIPLE}" && \
        ./install.sh --prefix="${RUST_HOME}" \
            --without=rust-docs,rust-docs-json-preview \
            --disable-ldconfig) || return 30
    [[ -x "${RUSTC_BIN}" && -x "${CARGO_BIN}" ]] || {
        log_message 'ERROR: official toolchain installation is incomplete'
        return 30
    }
    record_actual_version || return $?
    log_message "installed rustc: $(< "${PERF_WORK_DIR}/rustc-version.txt")"
}

install_rustc_perf() {
    local offline_archive="${RUST_ARCHIVE_DIR}/rustc-perf-${RUSTC_PERF_REVISION}.tar.gz"
    if [[ -d "${RUSTC_PERF_DIR}/.git" ]]; then
        log_message 'rustc-perf checkout already present in this work directory'
        [[ "$(git -C "${RUSTC_PERF_DIR}" rev-parse HEAD)" == "${RUSTC_PERF_REVISION}" ]] || {
            log_message "ERROR: rustc-perf checkout is not at ${RUSTC_PERF_REVISION}"
            return 30
        }
    elif [[ -s "${offline_archive}" ]]; then
        # The offline archive is produced by `git archive` from the pinned
        # revision, so a sidecar marker file records it for verification.
        log_message "using local rustc-perf archive: ${offline_archive}"
        mkdir -p "${RUSTC_PERF_DIR}"
        tar -xzf "${offline_archive}" -C "${RUSTC_PERF_DIR}" --strip-components=1 || return 30
        [[ -f "${RUSTC_PERF_DIR}/collector/compile-benchmarks/README.md" ]] || {
            log_message 'ERROR: local rustc-perf archive is incomplete'
            return 30
        }
        printf '%s\n' "${RUSTC_PERF_REVISION}" > "${RUSTC_PERF_DIR}/.boostkit-revision"
    else
        log_message "fetching upstream rustc-perf ${RUSTC_PERF_REVISION}"
        git init -q "${RUSTC_PERF_DIR}" || return 30
        git -C "${RUSTC_PERF_DIR}" remote add origin "${RUSTC_PERF_REPOSITORY}" || return 30
        with_network_proxy git -C "${RUSTC_PERF_DIR}" fetch --depth 1 origin "${RUSTC_PERF_REVISION}" || return 30
        git -C "${RUSTC_PERF_DIR}" checkout --detach FETCH_HEAD || return 30
        [[ "$(git -C "${RUSTC_PERF_DIR}" rev-parse HEAD)" == "${RUSTC_PERF_REVISION}" ]] || {
            log_message "ERROR: rustc-perf checkout is not at ${RUSTC_PERF_REVISION}"
            return 30
        }
    fi
    [[ -f "${RUSTC_PERF_DIR}/collector/compile-benchmarks/README.md" ]] || {
        log_message 'ERROR: rustc-perf checkout is missing its benchmark suite'
        return 30
    }
}

build_collector() {
    load_rust_toolchain || return $?
    log_message 'building the unmodified upstream collector with the installed toolchain'
    (cd "${RUSTC_PERF_DIR}" && \
        with_network_proxy env CARGO_HOME="${CARGO_HOME}" TMPDIR="${TMPDIR}" \
            cargo build -p collector --release --locked --quiet) || return 30
    [[ -x "${COLLECTOR_BIN}" ]] || {
        log_message 'ERROR: collector binary is missing after the build'
        return 30
    }
}

build_rust_base() {
    initialize_runtime || return $?
    install_build_dependencies || return $?
    install_rust_toolchain || return $?
    install_rustc_perf || return $?
    build_collector || return $?
}
