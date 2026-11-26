#!/usr/bin/env bash
# Stock (unpatched) Tongsuo 8.5.0 build, entirely inside the private container.
#
#   1. the host downloads and SHA-256 verifies the pinned tag archive;
#   2. the private container installs the build toolchain (gcc, make, perl and
#      perl-Text-Template);
#   3. the archive is extracted and configured with the same feature switches the
#      upstream benchmark CI pins, then built in tree with `make -j`;
#   4. the build is gated on `apps/openssl version` reporting Tongsuo 8.5.0 and on
#      a `speed -testmode` smoke run.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_tongsuo_base() {
    initialize_runtime || return $?
    check_architecture || return $?
    tongsuo_require_host_tools || return $?

    log_message "fetching the pinned Tongsuo ${SOFTWARE_VERSION} source archive"
    tongsuo_fetch_archive || return $?

    start_tongsuo_container || return $?

    log_message "installing build dependencies inside the container"
    tongsuo_container_exec_root dnf -y --setopt=install_weak_deps=False \
        --setopt=tsflags=noscripts install "${TONGSUO_CONTAINER_DEPS[@]}" || return 30
    tongsuo_container_exec sh -c 'command -v gcc && command -v make && command -v perl' || {
        log_message "ERROR: the container toolchain is not usable after installation"
        return 30
    }

    log_message "extracting ${TONGSUO_ARCHIVE_NAME} inside the container"
    tongsuo_container_exec mkdir -p "${TONGSUO_SRC_DIR}" || return 40
    tongsuo_container_exec tar -xzf "${TONGSUO_ARCHIVE_PATH}" \
        --strip-components=1 -C "${TONGSUO_SRC_DIR}" || return 40

    log_message "configuring stock Tongsuo ${SOFTWARE_VERSION} (${TONGSUO_CONFIG_FLAGS[*]})"
    if ! tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./config "${TONGSUO_CONFIG_FLAGS[@]}" \
        > "${RESULTS_DIR}/build-configure.log" 2>&1; then
        log_message "ERROR: ./config failed; see ${RESULTS_DIR}/build-configure.log"
        tail -n 20 "${RESULTS_DIR}/build-configure.log" >&2 || true
        return 40
    fi

    log_message "building with make -j${TONGSUO_BUILD_JOBS}"
    if ! tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" make -j"${TONGSUO_BUILD_JOBS}" \
        > "${RESULTS_DIR}/build-make.log" 2>&1; then
        log_message "ERROR: make failed; see ${RESULTS_DIR}/build-make.log"
        tail -n 20 "${RESULTS_DIR}/build-make.log" >&2 || true
        return 40
    fi

    tongsuo_verify_runtime_payload || return $?
    tongsuo_container_exec_at "${TONGSUO_SRC_DIR}" ./apps/openssl version -a \
        > "${RESULTS_DIR}/openssl-version.txt" 2>&1 || return 40
    # The Framework compares actual-version.txt with the requested version, so the
    # file carries the plain version string; the full banner lives in
    # openssl-version.txt.
    write_actual_version "${SOFTWARE_VERSION}" || return $?
    write_build_variant || return $?
    log_message "stock Tongsuo ${SOFTWARE_VERSION} build completed"
}
