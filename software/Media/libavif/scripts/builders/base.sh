#!/usr/bin/env bash
# Stock (unpatched) AOM 3.2.0 + libavif 0.9.3 build, entirely inside the private
# openEuler container.  The reference material explicitly refuses patched
# sources, so the build does not apply any patch and the unpatched check below
# keeps that guarantee.

build_libavif_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    libavif_resolve_media || return $?
    libavif_require_host_tools || return $?

    log_message "fetching the pinned libavif ${SOFTWARE_VERSION} and AOM ${AOM_VERSION} archives"
    libavif_fetch_archives || return $?

    libavif_media_mount_args
    start_libavif_container || return $?

    log_message "installing build dependencies inside the container"
    libavif_container_exec_root dnf -y --setopt=install_weak_deps=False \
        --setopt=tsflags=noscripts install "${LIBAVIF_CONTAINER_DEPS[@]}" || return 30

    log_message "extracting both source archives inside the container"
    libavif_container_exec mkdir -p "${AOM_SRC_DIR}" "${LIBAVIF_SRC_DIR}" || return 40
    libavif_container_exec tar -xzf "${PERF_WORK_DIR}/downloads/${AOM_ARCHIVE_NAME}" \
        -C "${AOM_SRC_DIR}" || return 40
    libavif_container_exec tar -xzf "${PERF_WORK_DIR}/downloads/${LIBAVIF_ARCHIVE_NAME}" \
        --strip-components=1 -C "${LIBAVIF_SRC_DIR}" || return 40
    # The open-box material must be built unpatched: assert the known patch
    # markers are absent before configuring.
    libavif_container_exec bash -c "
        set -e
        if [ -f '${AOM_SRC_DIR}/aom_dsp/arm/utils.h' ]; then
            echo 'ERROR: AOM source looks patched (aom_dsp/arm/utils.h exists)' >&2
            exit 1
        fi
        if grep -q '#pragma omp' '${LIBAVIF_SRC_DIR}/src/reformat.c' 2>/dev/null; then
            echo 'ERROR: libavif source looks patched (reformat.c contains #pragma omp)' >&2
            exit 1
        fi
    " || return 40

    log_message "building stock AOM ${AOM_VERSION}"
    libavif_container_exec cmake -S "${AOM_SRC_DIR}" -B "${AOM_BUILD_DIR}" \
        -DCMAKE_INSTALL_PREFIX="${LIBAVIF_INSTALL_DIR}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_SHARED_LIBS=ON \
        -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF -DENABLE_DOCS=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_FLAGS="-Ofast -ffp-contract=off -fPIC" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || return 40
    # AOM 3.2.0 shares assembly output between its static and shared targets, so
    # the three targets are built explicitly in the reference order.
    libavif_container_exec cmake --build "${AOM_BUILD_DIR}" --target aom \
        --parallel "${LIBAVIF_BUILD_JOBS}" || return 40
    libavif_container_exec cmake --build "${AOM_BUILD_DIR}" --target aom_static \
        --parallel "${LIBAVIF_BUILD_JOBS}" || return 40
    libavif_container_exec cmake --build "${AOM_BUILD_DIR}" --target aom_pc \
        --parallel "${LIBAVIF_BUILD_JOBS}" || return 40
    libavif_container_exec cmake --install "${AOM_BUILD_DIR}" || return 40

    log_message "building stock libavif ${SOFTWARE_VERSION}"
    libavif_container_exec env PKG_CONFIG_PATH="${LIBAVIF_INSTALL_DIR}/lib/pkgconfig" \
        cmake -S "${LIBAVIF_SRC_DIR}" -B "${LIBAVIF_BUILD_DIR}" \
        -DCMAKE_INSTALL_PREFIX="${LIBAVIF_INSTALL_DIR}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DBUILD_SHARED_LIBS=ON \
        -DAVIF_CODEC_AOM=ON -DAVIF_CODEC_DAV1D=OFF \
        -DAVIF_CODEC_LIBGAV1=OFF -DAVIF_CODEC_RAV1E=OFF -DAVIF_CODEC_SVT=OFF \
        -DAVIF_BUILD_APPS=ON -DAVIF_BUILD_EXAMPLES=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DAOM_INCLUDE_DIR="${LIBAVIF_INSTALL_DIR}/include" \
        -DAOM_LIBRARY="${LIBAVIF_INSTALL_DIR}/lib/libaom.so" \
        -DCMAKE_C_FLAGS="-O3 -ffp-contract=off" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 || return 40
    libavif_container_exec cmake --build "${LIBAVIF_BUILD_DIR}" \
        --parallel "${LIBAVIF_BUILD_JOBS}" || return 40
    libavif_container_exec cmake --install "${LIBAVIF_BUILD_DIR}" || return 40

    libavif_verify_runtime_payload || return $?
    write_actual_version || return $?
    write_build_variant || return $?
    log_message "stock libavif ${SOFTWARE_VERSION} + AOM ${AOM_VERSION} build completed"
}
