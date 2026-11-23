#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_uavs3d_archive() {
    local archive_name="$1" expected_sha256="$2" url="$3"
    local local_archive="${UAVS3D_ARCHIVE_DIR}/${archive_name}"
    local archive="${PERF_WORK_DIR}/${archive_name}"
    if [[ -f "${local_archive}" ]]; then
        log "using local source archive ${local_archive}"
        cp -- "${local_archive}" "${archive}" || return 30
    else
        log "downloading official source archive ${url}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" "${url}" || return 30
        mv -- "${archive}.part" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${expected_sha256}" "${archive}" | sha256sum -c - || {
        log "ERROR: source archive checksum mismatch: ${archive_name}"
        return 30
    }
}

install_uavs3d_dependencies() {
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing uavs3d build and runtime packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y \
        gcc gcc-c++ make cmake python3 gawk tar gzip xz || {
        log 'ERROR: container build dependencies failed'
        return 30
    }
    container_exec sh -c 'command -v gcc >/dev/null && command -v cmake >/dev/null && command -v python3 >/dev/null' || {
        log 'ERROR: container build dependencies are incomplete'
        return 30
    }
}

build_uavs3d_source() {
    local source_dir="$1" name="$2"
    log "building ${name} inside the private container"
    container_exec sh -c '
        set -e
        cd "$1"
        cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -ffp-contract=off"
        cmake --build build --parallel "$2"
    ' sh "${source_dir}" "${UAVS3D_BUILD_JOBS}" || {
        log "ERROR: ${name} build failed"
        return 40
    }
}

resolve_uavs3d_actual_version() {
    local version_output actual_version
    version_output="$(container_exec "${UAVS3D_DECODER_BIN}" -v 1 2>&1 || true)"
    actual_version="$(printf '%s\n' "${version_output}" | \
        sed -nE 's/.*uavs2d: ([0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    if [[ -z "${actual_version}" ]]; then
        log 'ERROR: built decoder did not report a usable version'
        printf '%s\n' "${version_output}" >&2
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: requested ${SOFTWARE_VERSION}, built decoder reports ${actual_version}"
        return 40
    fi
    printf '%s\n' "${actual_version}"
}

build_uavs3d_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.2" ]] || {
        log 'ERROR: only uavs3d 1.2 is supported'
        return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_host_commands || return $?
    [[ ! -e "${UAVS3D_DECODER_SOURCE_DIR}" && ! -e "${UAVS3D_ENCODER_SOURCE_DIR}" ]] || {
        log 'ERROR: source directory already exists'
        return 20
    }
    require_uavs3d_container || return $?
    install_uavs3d_dependencies || return $?
    fetch_uavs3d_archive "${UAVS3D_DECODER_ARCHIVE}" \
        "${UAVS3D_DECODER_SHA256}" "${UAVS3D_DECODER_URL}" || return $?
    fetch_uavs3d_archive "${UAVS3D_ENCODER_ARCHIVE}" \
        "${UAVS3D_ENCODER_SHA256}" "${UAVS3D_ENCODER_URL}" || return $?
    container_exec tar -xzf "${PERF_WORK_DIR}/${UAVS3D_DECODER_ARCHIVE}" \
        -C "${UAVS3D_SOURCE_ROOT}" || return 30
    container_exec tar -xzf "${PERF_WORK_DIR}/${UAVS3D_ENCODER_ARCHIVE}" \
        -C "${UAVS3D_SOURCE_ROOT}" || return 30
    container_exec test -f "${UAVS3D_DECODER_SOURCE_DIR}/CMakeLists.txt" || {
        log 'ERROR: uavs3d source tree is incomplete'
        return 30
    }
    container_exec test -f "${UAVS3D_ENCODER_SOURCE_DIR}/CMakeLists.txt" || {
        log 'ERROR: uavs3e source tree is incomplete'
        return 30
    }
    build_uavs3d_source "${UAVS3D_DECODER_SOURCE_DIR}" uavs3d || return $?
    build_uavs3d_source "${UAVS3D_ENCODER_SOURCE_DIR}" uavs3e || return $?
    container_exec test -x "${UAVS3D_DECODER_BIN}" || {
        log 'ERROR: uavs3dec was not built'
        return 40
    }
    container_exec test -x "${UAVS3D_ENCODER_BIN}" || {
        log 'ERROR: uavs3enc was not built'
        return 40
    }
    local actual_version
    actual_version="$(resolve_uavs3d_actual_version)" || return $?
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${UAVS3D_CONTAINER_IMAGE}" > "${UAVS3D_CONTAINER_IMAGE_FILE}"
    log "uavs3d ${actual_version} and uavs3e 1.3 are ready inside ${UAVS3D_CONTAINER_NAME}"
}
