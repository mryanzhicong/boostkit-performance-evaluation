#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

X265_ARCHIVE_SHA256="40b1ea0453e0309f0eba934e0ddf533f8f6295966679e8894e8f1c1c8d5e1210"
FFMPEG_ARCHIVE_SHA256="e273eae00b4f833595654c1ee2b2349240e0332f9dbf3c4cadd39df9819ff052"

require_commands() {
    local required package
    local packages=() dnf_options=()
    for required in python3 make cmake gcc g++ tar curl sha256sum pkg-config getconf; do
        command -v "${required}" >/dev/null 2>&1 && continue
        case "${required}" in
            g++) package="gcc-c++" ;;
            pkg-config) package="pkgconf-pkg-config" ;;
            sha256sum|getconf) package="coreutils" ;;
            *) package="${required}" ;;
        esac
        packages+=("${package}")
    done
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == x86_64 ]] &&
       ! command -v nasm >/dev/null 2>&1; then
        packages+=(nasm)
    fi
    if ((${#packages[@]})); then
        command -v dnf >/dev/null 2>&1 || {
            log_message "ERROR: dnf is required to install missing build packages"
            return 30
        }
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        log_message "installing missing x265/FFmpeg build packages: ${packages[*]}"
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for required in python3 make cmake gcc g++ tar curl sha256sum pkg-config getconf; do
        command -v "${required}" >/dev/null 2>&1 || return 30
    done
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == x86_64 ]]; then
        command -v nasm >/dev/null 2>&1 || return 30
    fi
}

fetch_official_archive() {
    local filename="$1" url="$2" checksum="$3"
    local local_path="${X265_SOURCE_ARCHIVE_DIR}/${filename}"
    local archive="${PERF_WORK_DIR}/${filename}"
    if [[ -e "${local_path}" ]]; then
        [[ -f "${local_path}" && -s "${local_path}" ]] || {
            log_message "ERROR: local source archive is invalid: ${local_path}"
            return 30
        }
        archive="${local_path}"
        log_message "using local official archive: ${archive}"
    else
        log_message "downloading official source archive: ${filename}"
        curl --fail --location --retry 2 --output "${archive}.partial" "${url}" || return 30
        mv -- "${archive}.partial" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${checksum}" "${archive}" | sha256sum -c - || {
        log_message "ERROR: source archive SHA-256 mismatch: ${archive}"
        return 30
    }
    tar -xzf "${archive}" -C "${PERF_WORK_DIR}" || return 30
}

read_x265_version() {
    local value
    value="$("${BENCHMARK_BIN}" --version 2>&1)" || return 1
    sed -n 's/^x265 \[info\]: HEVC encoder version \([^[:space:]]*\).*$/\1/p' <<<"${value}"
}

build_x265_base() {
    local actual_version jobs ffmpeg_version nasm_version private_scripts actual_install
    local manifests=()
    initialize_runtime || return $?
    [[ "$(normalize_architecture "$(uname -m)")" == "$(normalize_architecture "${EXPECTED_ARCH}")" ]] || {
        log_message "ERROR: runner architecture differs from ${EXPECTED_ARCH}"
        return 20
    }
    [[ "${SOFTWARE_VERSION}" == "4.2" ]] || {
        log_message "ERROR: this reference build only defines x265 4.2"
        return 10
    }
    require_commands || return $?
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == x86_64 ]]; then
        nasm_version="$(nasm -v)" || return 30
        if [[ "${nasm_version}" =~ version\ ([0-9]+)\.([0-9]+) ]]; then
            (( 10#${BASH_REMATCH[1]} > 2 ||
               (10#${BASH_REMATCH[1]} == 2 && 10#${BASH_REMATCH[2]} >= 13) )) || {
                log_message "ERROR: x86_64 requires NASM 2.13 or newer"
                return 30
            }
        else
            log_message "ERROR: cannot determine NASM version: ${nasm_version}"
            return 30
        fi
    fi
    [[ ! -e "${SOURCE_DIR}" && ! -e "${FFMPEG_SOURCE_DIR}" ]] || {
        log_message "ERROR: private source directories already exist"
        return 20
    }
    fetch_official_archive "x265_4.2.tar.gz" \
        "${X265_ARCHIVE_BASE_URL}/x265_4.2.tar.gz" "${X265_ARCHIVE_SHA256}" || return $?
    fetch_official_archive "ffmpeg-7.0.1.tar.gz" \
        "https://ffmpeg.org/releases/ffmpeg-7.0.1.tar.gz" "${FFMPEG_ARCHIVE_SHA256}" || return $?
    [[ -f "${SOURCE_DIR}/source/CMakeLists.txt" && -x "${FFMPEG_SOURCE_DIR}/configure" ]] || {
        log_message "ERROR: official source trees were not extracted"
        return 30
    }
    [[ "$(<"${FFMPEG_SOURCE_DIR}/RELEASE")" == "7.0.1" ]] || return 30
    jobs="$(getconf _NPROCESSORS_ONLN)"
    (( jobs <= 16 )) || jobs=16
    private_scripts="${PERF_WORK_DIR}/reference/scripts"
    mkdir -p "${private_scripts}" || return 40
    cp -- "${SCRIPT_DIR}/scripts/reference/bench_scene.py" "${private_scripts}/bench_scene.py" || return 40
    cp -- "${SCRIPT_DIR}/scripts/reference/run.py" "${private_scripts}/run.py" || return 40
    log_message "running the reference bench_scene.py build for x265 4.2 / FFmpeg 7.0.1"
    if ! python3 "${private_scripts}/bench_scene.py" build \
        --x265-source "${SOURCE_DIR}" \
        --ffmpeg-source "${FFMPEG_SOURCE_DIR}" --jobs "${jobs}"; then
        local build_log
        for build_log in "${PERF_WORK_DIR}"/reference/software/build-*/step-*.log; do
            [[ -f "${build_log}" ]] || continue
            log_message "last 60 lines of ${build_log}"
            tail -n 60 "${build_log}" || true
        done
        return 40
    fi
    manifests=("${PERF_WORK_DIR}"/reference/software/build-*/install/build-manifest.json)
    [[ "${#manifests[@]}" -eq 1 && -f "${manifests[0]}" ]] || {
        log_message "ERROR: reference build did not produce one install manifest"
        return 40
    }
    actual_install="$(dirname "${manifests[0]}")"
    ln -s -- "${actual_install}" "${INSTALL_DIR}" || return 40
    printf '%s\n' "${INSTALL_DIR}" > "${PERF_WORK_DIR}/reference/software/current-install.txt" || return 40
    cp -- "${manifests[0]}" "${RESULTS_DIR}/x265-build-manifest.json" || return 40

    [[ -x "${BENCHMARK_BIN}" && -x "${FFMPEG_BIN}" && -x "${FFPROBE_BIN}" ]] || return 40
    actual_version="$(read_x265_version)" || return 40
    [[ "${actual_version}" == 4.2 || "${actual_version}" == 4.2+* ]] || {
        log_message "ERROR: built x265 version does not match 4.2: ${actual_version}"
        return 40
    }
    ffmpeg_version="$("${FFMPEG_BIN}" -version 2>&1)" || return 40
    [[ "${ffmpeg_version}" == *"ffmpeg version 7.0.1"* ]] || return 40
    "${FFMPEG_BIN}" -hide_banner -encoders 2>/dev/null | grep 'libx265' >/dev/null || return 40
    printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}" || return 40
    log_message "private x265 ${actual_version} / FFmpeg 7.0.1 installation is ready"
}
