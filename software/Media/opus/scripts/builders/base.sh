#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_opus_dependencies() {
    local -a packages=(gcc gcc-c++ make cmake python3 curl tar gzip xz pkgconf-pkg-config)
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing fixed-point Opus build packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${packages[@]}" || {
        log 'ERROR: Opus build dependency installation failed'
        return 30
    }
    local command_name
    for command_name in cc c++ make python3 curl tar sha256sum; do
        container_exec command -v "${command_name}" >/dev/null 2>&1 || {
            log "ERROR: required command is missing in the Opus container: ${command_name}"
            return 30
        }
    done
}

stage_original_scripts() {
    [[ -f "${OPUS_REFERENCE_DIR}/build_install.sh" ]] || {
        log "ERROR: original Opus build script is missing: ${OPUS_REFERENCE_DIR}/build_install.sh"
        return 30
    }
    rm -rf "${OPUS_WORK_SCRIPTS}"
    mkdir -p "${OPUS_WORK_SCRIPTS}" "${OPUS_WORK_SCRIPTS}/.work/audio"
    cp -a "${OPUS_REFERENCE_DIR}/." "${OPUS_WORK_SCRIPTS}/" || return 30
    chmod +x "${OPUS_WORK_SCRIPTS}/run_bench.sh" \
        "${OPUS_WORK_SCRIPTS}/build_install.sh" 2>/dev/null || true
    local local_archive="${OPUS_ASSET_DIR}/${OPUS_ARCHIVE_NAME}"
    if [[ -s "${local_archive}" ]]; then
        cp -- "${local_archive}" "${PERF_WORK_DIR}/${OPUS_ARCHIVE_NAME}" || return 30
        log "staged local Opus source archive at the original path"
    fi
    if [[ -f "${OPUS_AUDIO_FILE}" ]]; then
        cp -- "${OPUS_AUDIO_FILE}" "${OPUS_WORK_SCRIPTS}/.work/audio/${OPUS_AUDIO_NAME}.wav" || return 30
        log "staged local Opus audio sample: ${OPUS_AUDIO_FILE}"
    elif [[ -f "${OPUS_ASSET_DIR}/${OPUS_AUDIO_NAME}.wav" ]]; then
        cp -- "${OPUS_ASSET_DIR}/${OPUS_AUDIO_NAME}.wav" "${OPUS_WORK_SCRIPTS}/.work/audio/${OPUS_AUDIO_NAME}.wav" || return 30
        log "staged local Opus audio sample from ${OPUS_ASSET_DIR}"
    else
        log "local Opus audio sample is absent; original bench.py will download it"
    fi
    log "staged original Opus scripts at ${OPUS_WORK_SCRIPTS}"
}

build_with_original_script() {
    log 'calling original build_install.sh in the original layout'
    container_exec sh -c "export BENCH_ENV_READY='${OPUS_WORK_SCRIPTS}' && \
        bash '${OPUS_WORK_SCRIPTS}/build_install.sh'" 2>&1 | \
        tee "${RESULTS_DIR}/build.log"
    local status=${PIPESTATUS[0]}
    if [[ "${status}" -ne 0 ]]; then
        log "ERROR: original build_install.sh exited ${status}"
        return 30
    fi
    container_exec test -x "${OPUS_DEMO}" || {
        log "ERROR: opus_demo was not produced at ${OPUS_DEMO}"
        return 30
    }
    printf '1.6.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
    log 'original build_install.sh produced the fixed-point Opus build'
}

build_opus_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.6.1" ]] || {
        log 'ERROR: only Opus 1.6.1 is supported'
        return 10
    }
    require_host_commands || return $?
    require_opus_container || return $?
    install_opus_dependencies || return $?
    stage_original_scripts || return $?
    build_with_original_script || return $?
    printf '%s\n' "${OPUS_CONTAINER_IMAGE}" > "${OPUS_CONTAINER_IMAGE_FILE}"
    log 'Opus 1.6.1 fixed-point build is ready (original build script)'
}
