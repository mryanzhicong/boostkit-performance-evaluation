#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_ray_dependencies() {
    local -a missing=() dnf_options=()
    require_ray_docker || return $?
    command -v curl >/dev/null 2>&1 || missing+=(curl)
    command -v sha256sum >/dev/null 2>&1 || missing+=(coreutils)
    command -v awk >/dev/null 2>&1 || missing+=(gawk)
    command -v sed >/dev/null 2>&1 || missing+=(sed)
    (( ${#missing[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing missing Ray dependencies: ${missing[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    else
        sudo -n dnf "${dnf_options[@]}" install -y "${missing[@]}" || return 30
    fi
}

prepare_official_shuffle() {
    local source="${RAY_OFFLINE_DIR}/shuffle_test.py"
    if [[ -s "${source}" ]]; then
        log_message "using local official shuffle script: ${source}"
        cp -- "${source}" "${RAY_SHUFFLE_SCRIPT}" || return 30
    else
        log_message "downloading official Ray ${SOFTWARE_VERSION} shuffle script"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${RAY_SHUFFLE_SCRIPT}" "${RAY_SHUFFLE_URL}" || return 30
    fi
    printf '%s  %s\n' "${RAY_SHUFFLE_SHA256}" "${RAY_SHUFFLE_SCRIPT}" | sha256sum -c - || return 30
}

build_ray_base() {
    local -a dnf_options=()
    initialize_runtime || return $?
    install_ray_dependencies || return $?
    start_ray_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing Python 3.11 and pip inside the private openEuler container'
    ray_container_exec_root dnf "${dnf_options[@]}" install -y python3 python3-pip coreutils || return 30
    local container_python_version
    container_python_version="$(ray_container_exec python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')" || return 30
    [[ "${container_python_version}" == 3.11 ]] || {
        log_message "ERROR: container Python is ${container_python_version}, expected 3.11"; return 30;
    }
    prepare_official_shuffle || return $?
    cp -- "${SCRIPT_DIR}/scripts/run_shuffle.py" "${RAY_RUNNER_SCRIPT}" || return 30
    ray_container_exec python3 -m venv "${RAY_VENV}" || {
        log_message 'ERROR: failed to create private Python environment inside the container'; return 30;
    }
    local wheel_name wheel_checksum wheel
    wheel_name="ray-2.55.1-cp311-cp311-manylinux2014_${EXPECTED_ARCH}.whl"
    case "${EXPECTED_ARCH}" in
        x86_64) wheel_checksum=d5382da181c03ee2f502ef46cf0ae4bbc30157b5bd9a67d7651f6a272528a85a ;;
        aarch64) wheel_checksum=0ea2f670a7725833ad2333a8c46ab69865ad06c8e5de9f65695e0f8f35331cec ;;
        *) log_message "ERROR: no official Ray wheel for ${EXPECTED_ARCH}"; return 30 ;;
    esac
    wheel="${PERF_WORK_DIR}/${wheel_name}"
    if [[ -s "${RAY_OFFLINE_DIR}/${wheel_name}" ]]; then
        log_message "using local official Ray wheel: ${RAY_OFFLINE_DIR}/${wheel_name}"
        cp -- "${RAY_OFFLINE_DIR}/${wheel_name}" "${wheel}" || return 30
    else
        log_message "downloading official Ray ${SOFTWARE_VERSION} wheel"
        ray_container_exec "${RAY_VENV}/bin/python" -m pip download --no-deps \
            --only-binary=:all: --dest "${PERF_WORK_DIR}" "ray==${SOFTWARE_VERSION}" || return 30
    fi
    [[ -s "${wheel}" ]] || { log_message "ERROR: official Ray wheel is missing: ${wheel_name}"; return 30; }
    printf '%s  %s\n' "${wheel_checksum}" "${wheel}" | sha256sum -c - || return 30
    ray_container_exec "${RAY_VENV}/bin/python" -m pip install "${wheel}" || return 30
    local actual
    actual="$(ray_container_exec "${RAY_VENV}/bin/python" -c 'import ray; print(ray.__version__)')" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || { log_message "ERROR: installed Ray version is ${actual}"; return 30; }
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "official Ray ${actual} is ready in ${RAY_VENV}"
}
