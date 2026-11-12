#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_torch_wheel() {
    local local_wheel="${TORCHVISION_WHEEL_DIR}/${TORCHVISION_TORCH_WHEEL}"
    local wheel="${TORCHVISION_WHEEL_CACHE}/${TORCHVISION_TORCH_WHEEL}"
    if [[ -f "${local_wheel}" ]]; then
        log "using local PyTorch CPU wheel ${local_wheel}"
        cp -- "${local_wheel}" "${wheel}" || return 30
    else
        log "downloading PyTorch CPU wheel ${TORCHVISION_TORCH_WHEEL_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${wheel}.part" "${TORCHVISION_TORCH_WHEEL_URL}" || return 30
        mv -- "${wheel}.part" "${wheel}" || return 30
    fi
    [[ -s "${wheel}" ]] || { log 'ERROR: PyTorch wheel is empty'; return 30; }
    python3 - "${wheel}" <<'PY'
import sys, zipfile
path = sys.argv[1]
try:
    with zipfile.ZipFile(path) as archive:
        bad = archive.testzip()
        if bad is not None:
            raise ValueError(f"corrupt zip member: {bad}")
except zipfile.BadZipFile as exc:
    raise SystemExit(f"ERROR: invalid PyTorch wheel: {exc}")
print("PyTorch wheel zip verified")
PY
    sha256sum "${wheel}" | tee "${PERF_WORK_DIR}/torch-wheel.sha256"
}

install_torchvision_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing Python runtime packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        python3 python3-pip tar gzip xz curl ca-certificates libgomp libstdc++ || {
        log 'ERROR: container runtime dependencies failed'
        return 30
    }
    container_exec sh -c 'python3 -c "import sys; assert sys.version_info[:2] == (3, 11), sys.version"; python3 -m pip --version >/dev/null' || {
        log 'ERROR: Python 3.11/pip is unavailable inside the container'
        return 30
    }
}

install_torchvision_python_packages() {
    log "installing torch ${TORCH_VERSION}+cpu, torchvision ${TORCHVISION_VERSION}, numpy ${NUMPY_VERSION}, pillow ${PILLOW_VERSION}"
    if ! container_exec sh -c '
        set -e
        python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
            --no-warn-script-location --only-binary=:all: --target "$1" \
            --find-links "$2" \
            --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
            --timeout 120 \
            "torch==2.9.1+cpu" "torchvision==0.24.1" "numpy==2.4.6" "pillow==13.0.0"
    ' sh "${TORCHVISION_DEPS_DIR}" "${TORCHVISION_WHEEL_CACHE}"; then
        log 'Huawei PyPI mirror failed; retrying with pypi.org'
        container_exec sh -c '
            set -e
            python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
                --no-warn-script-location --only-binary=:all: --target "$1" \
                --find-links "$2" --index-url https://pypi.org/simple --timeout 120 \
                "torch==2.9.1+cpu" "torchvision==0.24.1" "numpy==2.4.6" "pillow==13.0.0"
        ' sh "${TORCHVISION_DEPS_DIR}" "${TORCHVISION_WHEEL_CACHE}" || {
            log 'ERROR: Python dependency installation failed'
            return 30
        }
    fi
}

verify_torchvision_runtime() {
    container_exec python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py"
}

stage_local_weights() {
    local checkpoints="${TORCHVISION_TORCH_HOME}/hub/checkpoints"
    local file sha
    mkdir -p "${checkpoints}"
    for pair in \
        "${TORCHVISION_weight_v2_file}:${TORCHVISION_weight_v2_sha256}" \
        "${TORCHVISION_weight_v3_file}:${TORCHVISION_weight_v3_sha256}"; do
        file="${pair%%:*}"
        sha="${pair##*:}"
        if [[ -f "${TORCHVISION_WEIGHT_DIR}/${file}" ]]; then
            log "staging local model weights ${file}"
            cp -- "${TORCHVISION_WEIGHT_DIR}/${file}" "${checkpoints}/${file}" || return 30
            printf '%s  %s\n' "${sha}" "${checkpoints}/${file}" | sha256sum -c - || {
                log "ERROR: local model weight checksum mismatch: ${file}"
                return 30
            }
        else
            log "local model weight is absent; torchvision will download ${file}"
        fi
    done
}

build_torchvision_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "0.24.1" ]] || {
        log 'ERROR: only torchvision 0.24.1 is supported'
        return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_host_commands || return $?
    require_torchvision_container || return $?
    install_torchvision_dependencies || return $?
    fetch_torch_wheel || return $?
    install_torchvision_python_packages || return $?
    verify_torchvision_runtime || return $?
    stage_local_weights || return $?
    printf '0.24.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${TORCHVISION_CONTAINER_IMAGE}" > "${TORCHVISION_CONTAINER_IMAGE_FILE}"
    log 'torchvision 0.24.1 CPU runtime is ready inside the private container'
}
