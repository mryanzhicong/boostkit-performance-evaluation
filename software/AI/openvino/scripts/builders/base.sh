#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_torch_wheel() {
    local local_wheel="${OPENVINO_WHEEL_DIR}/${OPENVINO_TORCH_WHEEL}"
    local wheel="${OPENVINO_WHEEL_CACHE}/${OPENVINO_TORCH_WHEEL}"
    if [[ -f "${local_wheel}" ]]; then
        log "using local PyTorch CPU wheel ${local_wheel}"
        cp -- "${local_wheel}" "${wheel}" || return 30
    else
        log "downloading PyTorch CPU wheel ${OPENVINO_TORCH_WHEEL_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${wheel}.part" "${OPENVINO_TORCH_WHEEL_URL}" || return 30
        mv -- "${wheel}.part" "${wheel}" || return 30
    fi
    [[ -s "${wheel}" ]] || { log 'ERROR: PyTorch wheel is empty'; return 30; }
    python3 - "${wheel}" <<'PY'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as archive:
    bad = archive.testzip()
    if bad is not None:
        raise SystemExit(f"ERROR: corrupt zip member: {bad}")
print("PyTorch wheel zip verified")
PY
    sha256sum "${wheel}" | tee "${PERF_WORK_DIR}/torch-wheel.sha256"
}

fetch_torchvision_wheel() {
    [[ -n "${OPENVINO_TORCHVISION_WHEEL}" ]] || return 0
    local wheel="${OPENVINO_WHEEL_CACHE}/${OPENVINO_TORCHVISION_WHEEL}"
    local local_wheel="${OPENVINO_WHEEL_DIR}/${OPENVINO_TORCHVISION_WHEEL}"
    if [[ -f "${local_wheel}" ]]; then
        log "using local torchvision CPU wheel ${local_wheel}"
        cp -- "${local_wheel}" "${wheel}" || return 30
    else
        log "downloading torchvision CPU wheel ${OPENVINO_TORCHVISION_WHEEL_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${wheel}.part" "${OPENVINO_TORCHVISION_WHEEL_URL}" || return 30
        mv -- "${wheel}.part" "${wheel}" || return 30
    fi
    [[ -s "${wheel}" ]] || { log 'ERROR: torchvision wheel is empty'; return 30; }
    sha256sum "${wheel}" | tee "${PERF_WORK_DIR}/torchvision-wheel.sha256"
}

install_openvino_dependencies() {
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

install_openvino_python_packages() {
    local -a requirements=(
        "torch==2.9.1+cpu"
        "numpy==2.4.6"
        "pillow==13.0.0"
        "openvino==2026.2.1"
        "onnx==1.19.1"
    )
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        requirements+=("torchvision==0.24.1+cpu")
    else
        requirements+=("torchvision==0.24.1")
    fi
    log "installing pinned packages: ${requirements[*]}"
    if ! container_exec sh -c '
        set -e
        deps="$1"; wheels="$2"; shift 2
        python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
            --no-warn-script-location --only-binary=:all: --target "$deps" \
            --find-links "$wheels" \
            --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
            --timeout 120 "$@"
    ' sh "${OPENVINO_DEPS_DIR}" "${OPENVINO_WHEEL_CACHE}" "${requirements[@]}"; then
        log 'Huawei PyPI mirror failed; retrying with pypi.org'
        container_exec sh -c '
            set -e
            deps="$1"; wheels="$2"; shift 2
            python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
                --no-warn-script-location --only-binary=:all: --target "$deps" \
                --find-links "$wheels" --index-url https://pypi.org/simple --timeout 120 "$@"
        ' sh "${OPENVINO_DEPS_DIR}" "${OPENVINO_WHEEL_CACHE}" "${requirements[@]}" || {
            log 'ERROR: Python dependency installation failed'
            return 30
        }
    fi
}

verify_openvino_runtime() {
    container_exec python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py"
}

fetch_resnet_weights() {
    local target="${OPENVINO_TORCH_HOME}/hub/checkpoints/${OPENVINO_weight_file}"
    local local_weight="${OPENVINO_WEIGHT_DIR}/${OPENVINO_weight_file}"
    mkdir -p "$(dirname -- "${target}")"
    if [[ -f "${local_weight}" ]]; then
        log "using local ResNet18 weights ${local_weight}"
        cp -- "${local_weight}" "${target}" || return 30
    elif [[ ! -f "${target}" ]]; then
        log "downloading official ResNet18 weights ${OPENVINO_weight_url}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${target}.part" "${OPENVINO_weight_url}" || return 30
        mv -- "${target}.part" "${target}" || return 30
    fi
    printf '%s  %s\n' "${OPENVINO_weight_sha256}" "${target}" | sha256sum -c - || {
        log "ERROR: ResNet18 weight checksum mismatch"
        return 30
    }
}

build_openvino_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "2026.2.1" ]] || {
        log 'ERROR: only OpenVINO 2026.2.1 is supported'
        return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_host_commands || return $?
    [[ ! -e "${OPENVINO_DEPS_DIR}/openvino" ]] || {
        log 'ERROR: dependency directory already contains OpenVINO'
        return 20
    }
    require_openvino_container || return $?
    install_openvino_dependencies || return $?
    fetch_torch_wheel || return $?
    fetch_torchvision_wheel || return $?
    install_openvino_python_packages || return $?
    verify_openvino_runtime || return $?
    fetch_resnet_weights || return $?
    printf '2026.2.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${OPENVINO_CONTAINER_IMAGE}" > "${OPENVINO_CONTAINER_IMAGE_FILE}"
    log 'OpenVINO 2026.2.1 CPU runtime is ready inside the private container'
}
