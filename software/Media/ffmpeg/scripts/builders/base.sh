#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_ffmpeg_dependencies() {
    local -a packages=(gcc make python3 pkgconf-pkg-config curl tar gzip xz)
    local -a dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        packages+=(nasm)
    fi
    log 'installing FFmpeg build packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${packages[@]}" || {
        log 'ERROR: FFmpeg build dependency installation failed'
        return 30
    }
    local command_name
    for command_name in cc make python3 pkg-config curl tar sha256sum; do
        container_exec command -v "${command_name}" >/dev/null 2>&1 || {
            log "ERROR: required command is missing in the FFmpeg container: ${command_name}"
            return 30
        }
    done
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        container_exec command -v nasm >/dev/null 2>&1 || {
            log 'ERROR: nasm is required for the x86_64 FFmpeg build'
            return 30
        }
    fi
}

stage_original_scripts() {
    [[ -f "${FFMPEG_REFERENCE_DIR}/build_install.sh" ]] || {
        log "ERROR: original FFmpeg build script is missing: ${FFMPEG_REFERENCE_DIR}/build_install.sh"
        return 30
    }
    rm -rf "${FFMPEG_WORK_SCRIPTS}"
    mkdir -p "${FFMPEG_WORK_SCRIPTS}" "${FFMPEG_ORIGINAL_SOFTWARE}/downloads"
    cp -a "${FFMPEG_REFERENCE_DIR}/." "${FFMPEG_WORK_SCRIPTS}/" || return 30
    chmod +x "${FFMPEG_WORK_SCRIPTS}/run_bench.sh" \
        "${FFMPEG_WORK_SCRIPTS}/build_install.sh" 2>/dev/null || true
    local local_archive="${FFMPEG_ARCHIVE_DIR}/${FFMPEG_ARCHIVE_NAME}"
    if [[ -s "${local_archive}" ]]; then
        cp -- "${local_archive}" "${FFMPEG_ORIGINAL_SOFTWARE}/downloads/${FFMPEG_ARCHIVE_NAME}" || return 30
        log "staged local source archive in the original layout: ${FFMPEG_ORIGINAL_SOFTWARE}/downloads/${FFMPEG_ARCHIVE_NAME}"
    elif [[ -s "${FFMPEG_SOURCE_ARCHIVE}" ]]; then
        cp -- "${FFMPEG_SOURCE_ARCHIVE}" "${FFMPEG_ORIGINAL_SOFTWARE}/downloads/${FFMPEG_ARCHIVE_NAME}" || return 30
    fi
    log "staged original FFmpeg scripts at ${FFMPEG_WORK_SCRIPTS}"
}

build_with_original_script() {
    log 'calling original build_install.sh in the original layout'
    container_exec sh -c "export BENCH_ENV_READY='${FFMPEG_WORK_SCRIPTS}' && \
        bash '${FFMPEG_WORK_SCRIPTS}/build_install.sh'" 2>&1 | \
        tee "${RESULTS_DIR}/build.log"
    local status=${PIPESTATUS[0]}
    if [[ "${status}" -ne 0 ]]; then
        log "ERROR: original build_install.sh exited ${status}"
        return 30
    fi
    container_exec test -x "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" || {
        log "ERROR: FFmpeg binary was not installed at ${FFMPEG_INSTALL_DIR}/bin/ffmpeg"
        return 30
    }
    container_exec env LD_LIBRARY_PATH="${FFMPEG_INSTALL_DIR}/lib" \
        "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" -version >/dev/null || {
        log 'ERROR: installed FFmpeg is not runnable'
        return 30
    }
    printf '7.1.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
    log 'original build_install.sh produced the FFmpeg installation'
}

build_ffmpeg_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "7.1.1" ]] || {
        log 'ERROR: only FFmpeg 7.1.1 is supported'
        return 10
    }
    require_host_commands || return $?
    require_ffmpeg_container || return $?
    install_ffmpeg_dependencies || return $?
    stage_original_scripts || return $?
    build_with_original_script || return $?
    printf '%s\n' "${FFMPEG_CONTAINER_IMAGE}" > "${FFMPEG_CONTAINER_IMAGE_FILE}"
    log 'FFmpeg 7.1.1 is ready inside the private container (original build script)'
}
