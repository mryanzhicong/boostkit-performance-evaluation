#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_cargo_mirror() {
    mkdir -p "${PERF_WORK_DIR}/cargo" || return 40
    cat > "${PERF_WORK_DIR}/cargo/config.toml" <<'EOF'
[source.crates-io]
replace-with = "rsproxy-sparse"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[net]
git-fetch-with-cli = true
EOF
}

install_pinned_rust_toolchain() {
    local channel
    channel="$(sed -nE 's/^[[:space:]]*channel = "([^"]+)"$/\1/p' \
        "${LANCE_SOURCE_DIR}/rust-toolchain.toml" | head -n 1)"
    [[ "${channel}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
        log "ERROR: invalid upstream Rust toolchain channel: ${channel}"; return 40;
    }
    log "installing upstream pinned Rust ${channel} from RsProxy"
    container_exec "${PERF_WORK_DIR}/cargo/bin/rustup" toolchain install "${channel}" \
        --profile minimal || return 40
    container_exec sh -c 'cd "$1" && "$2/bin/rustc" --version' sh \
        "${LANCE_SOURCE_DIR}" "${PERF_WORK_DIR}/cargo" || return 40
}

build_lance_base() {
    local version
    local -a dnf_options=()
    initialize_runtime || return $?
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'; return 20;
    }
    require_lance_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing build dependencies inside the private container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make cmake pkgconf-pkg-config openssl-devel python3 python3-devel \
        python3-pip tar gzip curl ca-certificates git zlib-devel protobuf-compiler || {
        log 'ERROR: container build dependencies failed'; return 30;
    }
    container_exec protoc --version || {
        log 'ERROR: protoc is unavailable inside the Lance container'; return 30;
    }
    log 'cloning unmodified upstream Lance v13.0.0 inside the private container'
    container_exec git clone --depth 1 --branch v13.0.0 \
        https://github.com/lance-format/lance.git "${LANCE_SOURCE_DIR}" || return 30
    container_exec git -C "${LANCE_SOURCE_DIR}" diff --quiet || return 30
    [[ -f "${LANCE_SOURCE_DIR}/python/Cargo.toml" ]] || { log 'ERROR: Python source missing'; return 30; }
    [[ -f "${LANCE_SOURCE_DIR}/benchmarks/sift/index.py" && \
       -f "${LANCE_SOURCE_DIR}/benchmarks/sift/metrics.py" ]] || {
        log 'ERROR: pinned source is missing its SIFT benchmark tools'; return 30;
    }
    version="$(sed -nE 's/^version = "([^"]+)"$/\1/p' "${LANCE_SOURCE_DIR}/python/Cargo.toml" | head -n 1)"
    [[ "${version}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: source reports ${version}, expected ${SOFTWARE_VERSION}"; return 30;
    }
    container_exec git -C "${LANCE_SOURCE_DIR}" rev-parse HEAD > "${RESULTS_DIR}/source-commit.txt" || return 30
    log 'creating private Python environment inside the container'
    container_exec python3 -m venv "${LANCE_VENV}" || return 40
    container_exec "${LANCE_VENV}/bin/python" -m pip install --upgrade pip maturin || return 40
    log 'installing SIFT benchmark dependencies inside the container'
    container_exec "${LANCE_VENV}/bin/python" -m pip install \
        'numpy>=1.22' 'pyarrow>=14' pandas ml_dtypes 'torch>=2.0' || return 40
    log 'configuring private RsProxy Cargo mirror and installing upstream pinned Rust toolchain'
    prepare_cargo_mirror || return $?
    container_exec curl -fSL --retry 3 --connect-timeout 30 \
        -o "${PERF_WORK_DIR}/rustup-init.sh" "${LANCE_RUSTUP_SCRIPT_URL}" || return 40
    container_exec sh "${PERF_WORK_DIR}/rustup-init.sh" -y --no-modify-path \
        --profile minimal --default-toolchain none || return 40
    install_pinned_rust_toolchain || return $?
    log 'building unmodified upstream pylance with maturin --release inside the container'
    container_exec sh -c 'cd "$1" && PATH="$2:$PATH" VIRTUAL_ENV="$3" \
        "$3/bin/maturin" develop --release' sh \
        "${LANCE_SOURCE_DIR}/python" "${PERF_WORK_DIR}/cargo/bin" "${LANCE_VENV}" || return 40
    container_exec "${LANCE_VENV}/bin/python" -c \
        'import importlib.metadata as m, lance; assert m.version("pylance") == "13.0.0"' || return 40
    container_exec "${LANCE_VENV}/bin/python" -m pip freeze > "${RESULTS_DIR}/python-dependencies.txt" || return 40
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Lance ${version} source build is ready"
}
