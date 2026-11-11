#!/usr/bin/env bash
# Stock (unpatched) libwebp 1.2.1 build, entirely inside the private container.

build_libwebp_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    libwebp_require_host_tools || return $?

    log_message "fetching the pinned libwebp ${SOFTWARE_VERSION} source archive"
    libwebp_fetch_archive || return $?

    start_libwebp_container || return $?

    log_message "installing build dependencies inside the container"
    libwebp_container_exec_root dnf -y --setopt=install_weak_deps=False \
        --setopt=tsflags=noscripts install "${LIBWEBP_CONTAINER_DEPS[@]}" || return 30

    log_message "extracting ${LIBWEBP_ARCHIVE_NAME} inside the container"
    libwebp_container_exec mkdir -p "${LIBWEBP_SRC_DIR}" || return 40
    libwebp_container_exec tar -xzf "${LIBWEBP_ARCHIVE_PATH}" \
        --strip-components=1 -C "${LIBWEBP_SRC_DIR}" || return 40

    log_message "configuring and building stock libwebp ${SOFTWARE_VERSION}"
    libwebp_container_exec cmake -S "${LIBWEBP_SRC_DIR}" -B "${LIBWEBP_BUILD_DIR}" \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_INSTALL_PREFIX="${LIBWEBP_INSTALL_DIR}" \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_C_FLAGS_RELEASE="-O3 -DNDEBUG -ffp-contract=off" \
        -DWEBP_ENABLE_SIMD=ON \
        -DWEBP_USE_THREAD=ON \
        -DWEBP_BUILD_CWEBP=ON \
        -DWEBP_BUILD_DWEBP=ON \
        -DWEBP_BUILD_ANIM_UTILS=OFF \
        -DWEBP_BUILD_GIF2WEBP=OFF \
        -DWEBP_BUILD_IMG2WEBP=OFF \
        -DWEBP_BUILD_VWEBP=OFF \
        -DWEBP_BUILD_WEBPINFO=OFF \
        -DWEBP_BUILD_WEBPMUX=OFF \
        -DWEBP_BUILD_EXTRAS=OFF || return 40
    libwebp_container_exec cmake --build "${LIBWEBP_BUILD_DIR}" \
        --parallel "${LIBWEBP_BUILD_JOBS}" || return 40
    libwebp_container_exec cmake --install "${LIBWEBP_BUILD_DIR}" || return 40

    libwebp_verify_runtime_payload || return $?
    write_actual_version || return $?
    write_build_variant || return $?
    log_message "stock libwebp ${SOFTWARE_VERSION} build completed"
}
