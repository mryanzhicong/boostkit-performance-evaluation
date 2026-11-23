#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

fetch_dav1d_archive() {
    local archive_name="$1" expected_sha256="$2" url="$3"
    local local_archive="${DAV1D_ARCHIVE_DIR}/${archive_name}"
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

fetch_aom_archive() {
    local archive_name="${DAV1D_ENCODER_ARCHIVE}"
    local expected_sha256="${DAV1D_ENCODER_SHA256}"
    local local_archive="${DAV1D_ARCHIVE_DIR}/${archive_name}"
    local archive="${PERF_WORK_DIR}/${archive_name}"
    if [[ -f "${local_archive}" ]]; then
        log "using local AOM archive ${local_archive}"
        cp -- "${local_archive}" "${archive}" || return 30
    else
        log "obtaining AOM archive from ${DAV1D_LIBAVIF_REPO_URL}"
        local repo_dir="${PERF_WORK_DIR}/libavif-source"
        rm -rf -- "${repo_dir}"
        with_network_proxy git clone --depth 1 "${DAV1D_LIBAVIF_REPO_URL}" "${repo_dir}" || return 30
        [[ -f "${repo_dir}/${archive_name}" ]] || {
            log "ERROR: AOM archive is missing from the libavif repository"; return 30;
        }
        cp -- "${repo_dir}/${archive_name}" "${archive}" || return 30
    fi
    printf '%s  %s\n' "${expected_sha256}" "${archive}" | sha256sum -c - || {
        log "ERROR: AOM archive checksum mismatch: ${archive_name}"
        return 30
    }
}

install_dav1d_dependencies() {
    local -a dnf_options=()
    local -a packages=(gcc gcc-c++ make cmake python3 python3-pip pkgconf-pkg-config tar gzip xz git curl)
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        packages+=(nasm)
    fi
    log 'installing dav1d build and runtime packages inside the container'
    container_exec_root dnf "${dnf_options[@]}" install -y "${packages[@]}" || {
        log 'ERROR: container build dependencies failed'
        return 30
    }
    container_exec sh -c 'command -v gcc >/dev/null && command -v cmake >/dev/null && python3 -m pip --version >/dev/null 2>&1' || {
        log 'ERROR: container build dependencies are incomplete'
        return 30
    }
    if [[ "${EXPECTED_ARCH}" == "x86_64" ]]; then
        container_exec nasm -v >/dev/null || {
            log 'ERROR: NASM is not available inside the container'
            return 30
        }
    fi
}

install_meson_ninja() {
    local site_packages ninja_bin python_version
    container_exec mkdir -p "${DAV1D_MESON_PREFIX}" || return 30
    log "installing pinned Meson ${DAV1D_MESON_VERSION} and Ninja ${DAV1D_NINJA_VERSION} into the private prefix"
    if ! container_exec sh -c '
        set -e
        python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
            --no-warn-script-location --prefix "$1" \
            --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
            --timeout 60 "meson==1.8.5" "ninja==1.13.0"
    ' sh "${DAV1D_MESON_PREFIX}"; then
        log 'Huawei PyPI mirror failed; retrying with pypi.org'
        container_exec sh -c '
            set -e
            python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
                --no-warn-script-location --prefix "$1" \
                --index-url https://pypi.org/simple --timeout 60 "meson==1.8.5" "ninja==1.13.0"
        ' sh "${DAV1D_MESON_PREFIX}" || {
            log 'ERROR: Meson/Ninja installation failed'
            return 30
        }
    fi
    python_version="$(container_exec python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    site_packages="${DAV1D_MESON_PREFIX}/lib/python${python_version}/site-packages"
    ninja_bin="${DAV1D_MESON_PREFIX}/bin"
    [[ -d "${site_packages}" ]] || { log 'ERROR: Meson site-packages directory is missing'; return 30; }
    [[ -x "${ninja_bin}/ninja" ]] || {
        log 'ERROR: Ninja executable is missing from the private prefix'; return 30;
    }
    container_exec sh -c 'PYTHONPATH="$1" python3 -c "from importlib.metadata import version; assert version(\"meson\") == \"1.8.5\""' sh "${site_packages}" >/dev/null || {
        log 'ERROR: Meson 1.8.5 is not importable after installation'; return 30;
    }
    container_exec sh -c 'case "$("$1/ninja" --version)" in 1.13.0*) exit 0 ;; *) exit 1 ;; esac' sh "${ninja_bin}" >/dev/null || {
        log 'ERROR: Ninja 1.13.0 is not runnable after installation'; return 30;
    }
    DAV1D_MESON_SITE="${site_packages}"
    DAV1D_NINJA_BIN="${ninja_bin}"
    export DAV1D_MESON_SITE DAV1D_NINJA_BIN
}

build_dav1d_source() {
    log 'building dav1d inside the private container'
    container_exec sh -c '
        set -e
        export PYTHONPATH="$2${PYTHONPATH:+:${PYTHONPATH}}"
        export PATH="$3:${PATH}"
        cd "$1"
        python3 -m mesonbuild.mesonmain setup build \
            --prefix "$1/install" --libdir lib --buildtype release \
            -Dc_args=-ffp-contract=off -Denable_asm=true -Denable_tools=true \
            -Denable_tests=false -Dtestdata_tests=false
        python3 -m mesonbuild.mesonmain compile -C build -j "$4"
        python3 -m mesonbuild.mesonmain install -C build
    ' sh "${DAV1D_DECODER_SOURCE_DIR}" "${DAV1D_MESON_SITE}" "${DAV1D_NINJA_BIN}" "${DAV1D_BUILD_JOBS}" || {
        log 'ERROR: dav1d build failed'
        return 40
    }
}

build_aom_source() {
    log 'building AOM 3.2.0 generic C encoder inside the private container'
    if container_exec test -f "${DAV1D_ENCODER_SOURCE_DIR}/aom_dsp/arm/utils.h"; then
        log 'ERROR: AOM source contains the forbidden patched ARM helper'
        return 30
    fi
    container_exec sh -c '
        set -e
        cd "$1"
        cmake -S . -B build-generic -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
            -DAOM_TARGET_CPU=generic -DCONFIG_RUNTIME_CPU_DETECT=0 \
            -DENABLE_TESTS=OFF -DENABLE_DOCS=OFF -DENABLE_EXAMPLES=ON \
            -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
            -DCMAKE_C_FLAGS="-O2 -fno-fast-math -ffp-contract=off -fno-tree-vectorize -fPIC" \
            -DCMAKE_CXX_FLAGS="-O2 -fno-fast-math -ffp-contract=off -fno-tree-vectorize -fPIC"
        cmake --build build-generic --target aomenc aomdec --parallel "$2"
    ' sh "${DAV1D_ENCODER_SOURCE_DIR}" "${DAV1D_BUILD_JOBS}" || {
        log 'ERROR: AOM build failed'
        return 40
    }
}

resolve_dav1d_actual_version() {
    local version_output actual_version
    version_output="$(container_exec env LD_LIBRARY_PATH="${DAV1D_LIBRARY_DIR}" "${DAV1D_DECODER_BIN}" --version 2>&1 || true)"
    actual_version="$(printf '%s\n' "${version_output}" | sed -nE 's/.*dav1d[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' | head -n 1)"
    if [[ -z "${actual_version}" ]]; then
        actual_version="$(printf '%s\n' "${version_output}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)"
    fi
    if [[ -z "${actual_version}" ]]; then
        log 'ERROR: built dav1d did not report a usable version'
        printf '%s\n' "${version_output}" >&2
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: requested ${SOFTWARE_VERSION}, built dav1d reports ${actual_version}"
        return 40
    fi
    printf '%s\n' "${actual_version}"
}

build_dav1d_base() {
    initialize_runtime || return $?
    [[ "${SOFTWARE_VERSION}" == "1.5.4" ]] || {
        log 'ERROR: only dav1d 1.5.4 is supported'
        return 10
    }
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'
        return 20
    }
    require_host_commands || return $?
    [[ ! -e "${DAV1D_DECODER_SOURCE_DIR}" && ! -e "${DAV1D_ENCODER_SOURCE_DIR}" ]] || {
        log 'ERROR: source directory already exists'
        return 20
    }
    require_dav1d_container || return $?
    install_dav1d_dependencies || return $?
    install_meson_ninja || return $?
    fetch_dav1d_archive "${DAV1D_DECODER_ARCHIVE}" \
        "${DAV1D_DECODER_SHA256}" "${DAV1D_DECODER_URL}" || return $?
    fetch_aom_archive || return $?
    container_exec tar -xJf "${PERF_WORK_DIR}/${DAV1D_DECODER_ARCHIVE}" \
        -C "${DAV1D_SOURCE_ROOT}" || return 30
    container_exec mkdir -p "${DAV1D_ENCODER_SOURCE_DIR}" || return 30
    container_exec tar -xzf "${PERF_WORK_DIR}/${DAV1D_ENCODER_ARCHIVE}" \
        -C "${DAV1D_ENCODER_SOURCE_DIR}" || return 30
    container_exec test -f "${DAV1D_DECODER_SOURCE_DIR}/meson.build" || {
        log 'ERROR: dav1d source tree is incomplete'
        return 30
    }
    container_exec test -f "${DAV1D_ENCODER_SOURCE_DIR}/CMakeLists.txt" || {
        log 'ERROR: AOM source tree is incomplete'
        return 30
    }
    build_dav1d_source || return $?
    build_aom_source || return $?
    container_exec test -x "${DAV1D_DECODER_BIN}" || {
        log 'ERROR: dav1d was not built or installed'
        return 40
    }
    container_exec test -x "${DAV1D_ENCODER_BIN}" || {
        log 'ERROR: aomenc was not built'
        return 40
    }
    local actual_version
    actual_version="$(resolve_dav1d_actual_version)" || return $?
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    printf '%s\n' "${DAV1D_CONTAINER_IMAGE}" > "${DAV1D_CONTAINER_IMAGE_FILE}"
    log "dav1d ${actual_version} and aomenc 3.2.0 are ready inside ${DAV1D_CONTAINER_NAME}"
}
