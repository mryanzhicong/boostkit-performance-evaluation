#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_official_wheel() {
    local name="scann-1.4.2-cp39-cp39-manylinux_2_27_${EXPECTED_ARCH}.whl"
    local expected
    case "${EXPECTED_ARCH}" in
        aarch64) expected=7de7e076be04d7c1df19dcbc73770ac25646988aa8a2bdf388c7168c5e13b02e ;;
        x86_64) expected=b34f64f7ed9349cad2d5be9dd90f3b203278fc94d2920bc51e95895ae50b22b0 ;;
    esac
    mkdir -p "${ANN_ROOT}/wheelhouse"
    if [[ -f "${SCANN_WHEEL_ROOT}/${EXPECTED_ARCH}/${name}" ]]; then
        local actual
        actual="$(sha256sum "${SCANN_WHEEL_ROOT}/${EXPECTED_ARCH}/${name}")"
        [[ "${actual%% *}" == "${expected}" ]] || {
            log "ERROR: local ScaNN wheel SHA-256 mismatch: ${name}"; return 30;
        }
        cp -- "${SCANN_WHEEL_ROOT}/${EXPECTED_ARCH}/${name}" "${ANN_ROOT}/wheelhouse/${name}" || return 30
        log "using verified local ScaNN wheel: ${name}"
    else
        log 'no local ScaNN wheel; Docker build will download official 1.4.2 wheel'
    fi
}

prepare_proxy_certificates() {
    local path basename
    mkdir -p "${ANN_ROOT}/ca-anchors"
    [[ -n "${PERF_PROXY:-}" ]] || return 0
    [[ -d "${SCANN_CA_ANCHORS_DIR}" ]] || {
        log "ERROR: proxy CA anchors are missing: ${SCANN_CA_ANCHORS_DIR}"; return 30;
    }
    shopt -s nullglob
    for path in "${SCANN_CA_ANCHORS_DIR}"/*.crt "${SCANN_CA_ANCHORS_DIR}"/*.pem; do
        basename="$(basename "${path}")"
        cp -- "${path}" "${ANN_ROOT}/ca-anchors/${basename%.*}.crt" || return 30
    done
    shopt -u nullglob
    [[ -n "$(find "${ANN_ROOT}/ca-anchors" -maxdepth 1 -type f -name '*.crt' -print -quit)" ]] || {
        log 'ERROR: proxy CA anchor directory has no .crt or .pem files'; return 30;
    }
}

build_scann_base() {
    initialize_runtime || return $?
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'; return 20;
    }
    command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 || {
        log 'ERROR: accessible Docker daemon is required'; return 30;
    }
    command -v git >/dev/null 2>&1 || { log 'ERROR: git is required'; return 30; }
    command -v python3 >/dev/null 2>&1 || { log 'ERROR: python3 is required'; return 30; }
    python3 -c 'import sys; assert sys.version_info >= (3, 10), sys.version' || {
        log 'ERROR: ann-benchmarks coordinator requires Python 3.10 or newer'; return 30;
    }
    [[ ! -e "${ANN_ROOT}" ]] || { log 'ERROR: refusing to reuse ann-benchmarks worktree'; return 30; }
    log "cloning official ann-benchmarks ${ANNB_REVISION}"
    with_network_proxy git clone --filter=blob:none \
        https://github.com/erikbern/ann-benchmarks.git "${ANN_ROOT}" || return 30
    git -C "${ANN_ROOT}" checkout --detach "${ANNB_REVISION}" || return 30
    [[ "$(git -C "${ANN_ROOT}" rev-parse HEAD)" == "${ANNB_REVISION}" ]] || return 30
    git -C "${ANN_ROOT}" diff --quiet || return 30
    mkdir -p "${ANN_ROOT}/results"
    prepare_official_wheel || return $?
    prepare_proxy_certificates || return $?
    cp -- "${SCRIPT_DIR}/scripts/Dockerfile.scann" "${ANN_ROOT}/Dockerfile.scann" || return 30
    log 'creating private ann-benchmarks coordinator environment'
    python3 -m venv "${ANN_VENV}" || return 30
    with_network_proxy "${ANN_VENV}/bin/python" -m pip install \
        -i https://mirrors.aliyun.com/pypi/simple/ \
        numpy==2.2.4 h5py==3.13.0 pyyaml==6.0.2 scikit-learn==1.6.1 \
        matplotlib==3.10.1 docker==7.1.0 psutil==7.0.0 \
        ansicolors==1.1.8 jinja2==3.1.6 || return 30
    local -a proxy_args=()
    if [[ -n "${PERF_PROXY:-}" ]]; then
        proxy_args+=(--build-arg "HTTP_PROXY=${PERF_PROXY}" --build-arg "HTTPS_PROXY=${PERF_PROXY}")
    fi
    log "building official ScaNN 1.4.2 wheel image ${SCANN_IMAGE_TAG}"
    docker build --rm "${proxy_args[@]}" -t "${SCANN_IMAGE_TAG}" \
        -f "${ANN_ROOT}/Dockerfile.scann" "${ANN_ROOT}" || return 30
    verify_scann_image || return 30
    printf '1.4.2\n' > "${PERF_ACTUAL_VERSION_FILE}"
    log 'ScaNN 1.4.2 wheel and pinned ann-benchmarks are ready'
}
