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
    for command_name in gcc make python3 pkg-config curl tar; do
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

prepare_ffmpeg_source() {
    local local_archive="${FFMPEG_ARCHIVE_DIR}/${FFMPEG_ARCHIVE_NAME}"
    if [[ -s "${local_archive}" ]]; then
        FFMPEG_SOURCE_ARCHIVE="${local_archive}"
        log "using local FFmpeg source archive: ${FFMPEG_SOURCE_ARCHIVE}"
    elif [[ ! -s "${FFMPEG_SOURCE_ARCHIVE}" ]]; then
        log "downloading FFmpeg ${SOFTWARE_VERSION} from ${FFMPEG_SOURCE_URL}"
        with_network_proxy curl -fL --retry 3 --connect-timeout 30 \
            -o "${FFMPEG_SOURCE_ARCHIVE}.part" "${FFMPEG_SOURCE_URL}" || return 30
        mv -- "${FFMPEG_SOURCE_ARCHIVE}.part" "${FFMPEG_SOURCE_ARCHIVE}" || return 30
    fi
    printf '%s  %s\n' "${FFMPEG_ARCHIVE_SHA256}" "${FFMPEG_SOURCE_ARCHIVE}" | sha256sum -c - || {
        log 'ERROR: FFmpeg source archive checksum mismatch'
        return 30
    }
    sha256sum "${FFMPEG_SOURCE_ARCHIVE}" > "${FFMPEG_SOURCE_ARCHIVE_SHA256_FILE}"
    if [[ ! -f "${FFMPEG_SOURCE_DIR}/configure" ]]; then
        log 'extracting FFmpeg source'
        rm -rf "${FFMPEG_SOURCE_DIR}"
        mkdir -p "${FFMPEG_SOURCE_DIR}"
        tar -xzf "${FFMPEG_SOURCE_ARCHIVE}" --strip-components=1 -C "${FFMPEG_SOURCE_DIR}" || return 30
    fi
    [[ -x "${FFMPEG_SOURCE_DIR}/configure" ]] || {
        log 'ERROR: FFmpeg configure script is missing after extraction'
        return 30
    }
}

build_ffmpeg_from_source() {
    log 'configuring and building stock FFmpeg 7.1.1 inside the container'
    container_exec sh -c "cd '${FFMPEG_SOURCE_DIR}' && \
        ./configure --prefix='${FFMPEG_INSTALL_DIR}' --enable-shared \
        --disable-debug --disable-doc --disable-autodetect --disable-everything \
        --enable-ffmpeg --enable-ffprobe \
        --enable-protocol=file,pipe --enable-demuxer=rawvideo \
        --enable-decoder=rawvideo --enable-encoder=rawvideo \
        --enable-muxer=rawvideo,hash \
        --enable-filter=scale,format,null,psnr,setpts --enable-swscale \
        --extra-cflags='-O3 -ffp-contract=off' --extra-ldflags='-Wl,-O3' && \
        make -j8 && make install" || return 30
    container_exec test -x "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" || {
        log 'ERROR: FFmpeg binary was not installed'
        return 30
    }
    local version
    version="$(container_exec env LD_LIBRARY_PATH="${FFMPEG_INSTALL_DIR}/lib" \
        "${FFMPEG_INSTALL_DIR}/bin/ffmpeg" -version | head -n 1)" || return 30
    log "built ${version}"
    printf '7.1.1\n' > "${PERF_ACTUAL_VERSION_FILE}"
}

build_ffmpeg_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "7.1.1" ]] || {
        log 'ERROR: only FFmpeg 7.1.1 is supported'
        return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_host_commands || return $?
    require_ffmpeg_container || return $?
    install_ffmpeg_dependencies || return $?
    prepare_ffmpeg_source || return $?
    build_ffmpeg_from_source || return $?
    printf '%s\n' "${FFMPEG_CONTAINER_IMAGE}" > "${FFMPEG_CONTAINER_IMAGE_FILE}"
    log 'FFmpeg 7.1.1 is ready inside the private container'
}
