#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_dependencies() {
    local required header missing=0
    for required in curl tar sha256sum cmp python3 awk sed grep tee make gcc g++ find autoconf zip unzip; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            missing=1
        fi
    done
    for header in \
        /usr/include/alsa/asoundlib.h \
        /usr/include/fontconfig/fontconfig.h \
        /usr/include/freetype2/ft2build.h \
        /usr/include/cups/cups.h \
        /usr/include/X11/extensions/shape.h \
        /usr/include/X11/extensions/Xrender.h \
        /usr/include/X11/extensions/Xrandr.h \
        /usr/include/X11/extensions/XTest.h \
        /usr/include/X11/extensions/XInput2.h \
        /usr/include/X11/Intrinsic.h; do
        if [[ ! -f "${header}" ]]; then
            missing=1
        fi
    done
    if [[ "${missing}" -eq 0 ]]; then
        return 0
    fi
    log_message "installing missing BiSheng JDK build dependencies"
    local package_manager_options=()
    [[ -z "${PERF_PROXY:-}" ]] || package_manager_options+=("--setopt=proxy=${PERF_PROXY}")
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install BiSheng JDK build dependencies"
        return 30
    fi
    local install_command=(dnf)
    if [[ "${EUID}" -ne 0 ]]; then
        if ! command -v sudo >/dev/null 2>&1; then
            log_message "ERROR: root privileges are required to install BiSheng JDK build dependencies"
            return 30
        fi
        install_command=(sudo -n dnf)
    fi
    if ! "${install_command[@]}" "${package_manager_options[@]}" install -y \
        curl tar gzip coreutils python3 gawk findutils sed grep make gcc gcc-c++ \
        autoconf zip unzip \
        freetype-devel fontconfig-devel alsa-lib-devel cups-devel \
        libXtst-devel libXt-devel libXrender-devel libXrandr-devel libXi-devel; then
        log_message "ERROR: failed to install BiSheng JDK build dependencies"
        return 30
    fi
    for required in curl tar sha256sum cmp python3 awk sed grep tee make gcc g++ find autoconf zip unzip; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still missing after installation: ${required}"
            return 30
        fi
    done
    for header in \
        /usr/include/alsa/asoundlib.h \
        /usr/include/fontconfig/fontconfig.h \
        /usr/include/freetype2/ft2build.h \
        /usr/include/cups/cups.h \
        /usr/include/X11/extensions/shape.h \
        /usr/include/X11/extensions/Xrender.h \
        /usr/include/X11/extensions/Xrandr.h \
        /usr/include/X11/extensions/XTest.h \
        /usr/include/X11/extensions/XInput2.h \
        /usr/include/X11/Intrinsic.h; do
        if [[ ! -f "${header}" ]]; then
            log_message "ERROR: required BiSheng JDK development header is still missing: ${header}"
            return 30
        fi
    done
}

prepare_bishengjdk_source() {
    local archive_name archive_path local_archive_path top_dir

    case "${SOFTWARE_VERSION}" in
        21.0.9)
            BISHENGJDK_SOURCE_REPO="bishengjdk-21"
            BISHENGJDK_SOURCE_TAG="jdk-21.0.9-ga-b011"
            ;;
        *)
            log_message "ERROR: no BiSheng JDK source tag is declared for ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
    archive_name="${BISHENGJDK_SOURCE_REPO}-${BISHENGJDK_SOURCE_TAG}.tar.gz"
    local_archive_path="${BISHENGJDK_OFFLINE_DIR}/${archive_name}"
    archive_path="${PERF_WORK_DIR}/${archive_name}"
    BISHENGJDK_SOURCE_URL="${BISHENGJDK_SOURCE_BASE}/${BISHENGJDK_SOURCE_REPO}/archive/refs/tags/${BISHENGJDK_SOURCE_TAG}.tar.gz"
    if [[ -f "${local_archive_path}" ]]; then
        log_message "using local BiSheng JDK GA source archive ${local_archive_path}"
        if ! cp "${local_archive_path}" "${archive_path}"; then
            log_message "ERROR: failed to copy local BiSheng JDK source archive"
            return 30
        fi
    else
        log_message "downloading BiSheng JDK GA source ${BISHENGJDK_SOURCE_TAG}"
        if ! curl -fL --retry 3 --connect-timeout 30 -o "${archive_path}" "${BISHENGJDK_SOURCE_URL}"; then
            log_message "ERROR: failed to download BiSheng JDK GA source archive"
            return 30
        fi
    fi
    BISHENGJDK_SOURCE_SHA256="$(sha256sum "${archive_path}" | awk '{print $1}')"
    top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
    if [[ -z "${top_dir}" || "${top_dir}" != "${BISHENGJDK_SOURCE_REPO}-"* ]]; then
        log_message "ERROR: BiSheng JDK source archive has an unexpected root directory: ${top_dir}"
        return 30
    fi
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log_message "ERROR: failed to extract the BiSheng JDK GA source archive"
        return 30
    fi
    if ! mv "${PERF_WORK_DIR}/${top_dir}" "${SRC_DIR}"; then
        log_message "ERROR: failed to place the BiSheng JDK source tree"
        return 30
    fi
    rm -f "${archive_path}"
    if [[ ! -f "${SRC_DIR}/test/micro/org/openjdk/bench/vm/compiler/FloatingScalarVectorAbsDiff.java" ]]; then
        log_message "ERROR: BiSheng JDK source is missing ${JMH_BENCHMARK}"
        return 30
    fi
    log_message "BiSheng JDK GA source is ready: ${BISHENGJDK_SOURCE_TAG} (${BISHENGJDK_SOURCE_SHA256})"
}

prepare_boot_jdk() {
    local archive_name archive_path boot_jdk_release boot_jdk_version
    local local_archive_path top_dir version

    case "${SOFTWARE_VERSION}" in
        21.0.9)
            boot_jdk_version="21.0.9"
            boot_jdk_release="jdk-21.0.9%2B10"
            ;;
        *)
            log_message "ERROR: no Temurin boot JDK is declared for BiSheng JDK ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
    if [[ -n "${BISHENGJDK_BOOT_JDK_HOME}" ]]; then
        BOOT_JDK_HOME="${BISHENGJDK_BOOT_JDK_HOME}"
    else
        case "${EXPECTED_ARCH}" in
            x86_64)
                archive_name="OpenJDK21U-jdk_x64_linux_hotspot_${boot_jdk_version}_10.tar.gz"
                ;;
            aarch64)
                archive_name="OpenJDK21U-jdk_aarch64_linux_hotspot_${boot_jdk_version}_10.tar.gz"
                ;;
            *)
                log_message "ERROR: unsupported architecture for Temurin boot JDK: ${EXPECTED_ARCH}"
                return 30
                ;;
        esac
        local_archive_path="${BISHENGJDK_OFFLINE_DIR}/${archive_name}"
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        if [[ -f "${local_archive_path}" ]]; then
            log_message "using local Temurin boot JDK archive ${local_archive_path}"
            if ! cp "${local_archive_path}" "${archive_path}"; then
                log_message "ERROR: failed to copy local Temurin boot JDK archive"
                return 30
            fi
        else
            log_message "downloading Temurin ${boot_jdk_version} boot JDK for ${EXPECTED_ARCH}"
            if ! curl -fL --retry 3 --connect-timeout 30 -o "${archive_path}" \
                "${ADOPTIUM_RELEASE_BASE}/${boot_jdk_release}/${archive_name}"; then
                log_message "ERROR: failed to download the Temurin boot JDK archive"
                return 30
            fi
        fi
        top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
        if [[ -z "${top_dir}" || "${top_dir}" != jdk-* ]]; then
            log_message "ERROR: Temurin boot JDK archive has an unexpected root directory: ${top_dir}"
            return 30
        fi
        if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
            log_message "ERROR: failed to extract the Temurin boot JDK archive"
            return 30
        fi
        if ! mv "${PERF_WORK_DIR}/${top_dir}" "${PERF_WORK_DIR}/boot-jdk"; then
            log_message "ERROR: failed to place the Temurin boot JDK"
            return 30
        fi
        rm -f "${archive_path}"
        BOOT_JDK_HOME="${PERF_WORK_DIR}/boot-jdk"
    fi
    if [[ ! -x "${BOOT_JDK_HOME}/bin/java" || ! -x "${BOOT_JDK_HOME}/bin/javac" ]]; then
        log_message "ERROR: boot JDK is missing bin/java or bin/javac: ${BOOT_JDK_HOME}"
        return 30
    fi
    version="$("${BOOT_JDK_HOME}/bin/java" -version 2>&1 | sed -n 's/^openjdk version "\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ "${version}" != "${boot_jdk_version}" ]]; then
        log_message "ERROR: expected Temurin boot JDK ${boot_jdk_version}, found ${version:-unknown}"
        return 30
    fi
    log_message "using Temurin boot JDK ${version}: ${BOOT_JDK_HOME}"
}

build_bishengjdk_from_source() {
    local build_jdk version_line actual_version

    if prepare_boot_jdk; then
        :
    else
        return $?
    fi
    if ! (
        cd "${SRC_DIR}"
        MAVEN_MIRROR="${BISHENGJDK_MAVEN_MIRROR}" sh make/devkit/createJMHBundle.sh
    ); then
        log_message "ERROR: failed to prepare the official JMH bundle"
        return 30
    fi
    local jar
    for jar in commons-math3-3.6.1 jopt-simple-5.0.4 jmh-core-1.37 jmh-generator-annprocess-1.37; do
        if [[ ! -s "${SRC_DIR}/build/jmh/jars/${jar}.jar" ]]; then
            log_message "ERROR: JMH dependency is missing: ${jar}.jar"
            return 30
        fi
    done
    log_message "configuring BiSheng JDK ${SOFTWARE_VERSION} GA source build with JMH"
    if ! (
        cd "${SRC_DIR}"
        bash configure \
            --with-debug-level=release \
            --with-boot-jdk="${BOOT_JDK_HOME}" \
            --with-jmh=build/jmh/jars \
            --with-jvm-variants=server \
            --prefix="${JDK_HOME}" \
            --disable-warnings-as-errors \
            --disable-precompiled-headers
    ); then
        log_message "ERROR: BiSheng JDK configure failed"
        return 40
    fi
    log_message "building BiSheng JDK images from source"
    if ! make -C "${SRC_DIR}" images; then
        log_message "ERROR: BiSheng JDK source build failed"
        return 40
    fi
    build_jdk="${SRC_DIR}/build/${BUILD_CONF}/images/jdk"
    if [[ ! -d "${build_jdk}" ]]; then
        log_message "ERROR: expected source build image is missing: ${build_jdk}"
        return 40
    fi
    if ! ln -s "${build_jdk}" "${JDK_HOME}"; then
        log_message "ERROR: failed to link the source-built JDK image"
        return 40
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -x "${JDK_HOME}/bin/javac" ]]; then
        log_message "ERROR: source-built JDK is missing bin/java or bin/javac: ${JDK_HOME}"
        return 40
    fi
    version_line="$("${JDK_HOME}/bin/java" -version 2>&1 | head -n 1)"
    actual_version="$(printf '%s\n' "${version_line}" | sed -n 's/^openjdk version "\([^"]*\)".*/\1/p')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}-internal" ]]; then
        log_message "ERROR: source-built JDK reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}-internal"
        return 40
    fi
    JDK_VERSION_STRING="${version_line}"
    # Framework uses this file to match the requested GA release.  The full
    # source-build identifier (for example, 21.0.9-internal) remains in
    # JDK_VERSION_STRING and is recorded in build_info.json.
    if ! printf '%s\n' "${SOFTWARE_VERSION}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log_message "ERROR: failed to record the BiSheng JDK release version"
        return 40
    fi
    log_message "source-built BiSheng JDK is ready: ${JDK_VERSION_STRING}"
}

build_bishengjdk_base() {
    initialize_runtime || return $?
    install_dependencies || return $?
    if [[ -e "${JDK_HOME}" || -e "${SRC_DIR}" || -e "${PERF_WORK_DIR}/boot-jdk" ]]; then
        log_message "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    prepare_bishengjdk_source || return $?
    build_bishengjdk_from_source || return $?
    log_message "BiSheng JDK ${SOFTWARE_VERSION} JMH runtime is built at ${PERF_WORK_DIR}"
}
