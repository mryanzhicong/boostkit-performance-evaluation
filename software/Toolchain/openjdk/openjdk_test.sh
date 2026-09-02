#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-25.0.4.1}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"
OPENJDK_SOURCE_BASE="${OPENJDK_SOURCE_BASE:-https://github.com/openjdk}"
ADOPTIUM_RELEASE_BASE="${ADOPTIUM_RELEASE_BASE:-https://github.com/adoptium/temurin25-binaries/releases/download}"
JTREG_DOWNLOAD_URL="${JTREG_DOWNLOAD_URL:-https://builds.shipilev.net/jtreg/jtreg-8.3%2B1.zip}"
OPENJDK_OFFLINE_DIR="${OPENJDK_OFFLINE_DIR:-/home/runner/software/openjdk}"
OPENJDK_BOOT_JDK_HOME="${OPENJDK_BOOT_JDK_HOME:-}"
JTREG_VERSION="${JTREG_VERSION:-8.3+1}"
JTREG_TEST_ROOTS="${JTREG_TEST_ROOTS:-test/jdk test/lib-test test/langtools test/jaxp test/hotspot/jtreg test/docs}"

JDK_HOME=""
SRC_DIR=""
BOOT_JDK_HOME=""
JTREG_HOME=""
JTREG_WORK_DIR=""
JTREG_REPORT_DIR=""
JDK_VERSION_STRING=""
OPENJDK_SOURCE_REPO=""
OPENJDK_SOURCE_TAG=""
OPENJDK_SOURCE_URL=""
OPENJDK_SOURCE_SHA256=""
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

log() {
    printf '[openjdk] %s\n' "$*"
}

configure_runtime_paths() {
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    if [[ ! "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]]; then
        log "ERROR: PERF_RUN_ID contains unsafe characters: ${PERF_RUN_ID}"
        return 10
    fi
    case "${EXPECTED_ARCH,,}" in
        x86_64|amd64)
            EXPECTED_ARCH="x86_64"
            ;;
        aarch64|arm64)
            EXPECTED_ARCH="aarch64"
            ;;
        *)
            log "ERROR: unsupported expected architecture: ${EXPECTED_ARCH}"
            return 20
            ;;
    esac
    case "$(uname -m)" in
        x86_64|amd64)
            if [[ "${EXPECTED_ARCH}" != "x86_64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is x86_64"
                return 20
            fi
            ;;
        aarch64|arm64)
            if [[ "${EXPECTED_ARCH}" != "aarch64" ]]; then
                log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is aarch64"
                return 20
            fi
            ;;
        *)
            log "ERROR: unsupported runner architecture: $(uname -m)"
            return 20
            ;;
    esac
    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    fi
    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/tmp/openjdk-perf/local-${PERF_RUN_ID}"
        STANDALONE_OWNS_WORK_DIR=1
    fi
    TMPDIR="${TMPDIR:-${PERF_WORK_DIR}/tmp}"
    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    JDK_HOME="${PERF_WORK_DIR}/jdk"
    SRC_DIR="${PERF_WORK_DIR}/openjdk-source"
    JTREG_HOME="${PERF_WORK_DIR}/jtreg"
    JTREG_WORK_DIR="${RESULTS_DIR}/jtreg-work"
    JTREG_REPORT_DIR="${RESULTS_DIR}/jtreg-report"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_RUN_ID RESULTS_DIR PERF_WORK_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR:-${PERF_WORK_DIR}/tmp}"
}

install_dependencies() {
    local required header missing=0
    for required in curl tar sha256sum python3 awk sed grep tee make gcc g++ zip unzip; do
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
    log "installing missing OpenJDK test dependencies"
    if command -v dnf >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! dnf install -y curl tar gzip coreutils python3 gawk findutils sed grep make gcc gcc-c++ zip unzip freetype-devel fontconfig-devel alsa-lib-devel cups-devel libXtst-devel libXt-devel libXrender-devel libXrandr-devel libXi-devel; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n dnf install -y curl tar gzip coreutils python3 gawk findutils sed grep make gcc gcc-c++ zip unzip freetype-devel fontconfig-devel alsa-lib-devel cups-devel libXtst-devel libXt-devel libXrender-devel libXrandr-devel libXi-devel; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    elif command -v yum >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! yum install -y curl tar gzip coreutils python3 gawk findutils sed grep make gcc gcc-c++ zip unzip freetype-devel fontconfig-devel alsa-lib-devel cups-devel libXtst-devel libXt-devel libXrender-devel libXrandr-devel libXi-devel; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n yum install -y curl tar gzip coreutils python3 gawk findutils sed grep make gcc gcc-c++ zip unzip freetype-devel fontconfig-devel alsa-lib-devel cups-devel libXtst-devel libXt-devel libXrender-devel libXrandr-devel libXi-devel; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if [[ "${EUID}" -eq 0 ]]; then
            if ! apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! apt-get install -y curl tar gzip coreutils python3 gawk findutils sed grep make g++ zip unzip libfreetype-dev libfontconfig1-dev libasound2-dev libcups2-dev libxtst-dev libxt-dev libxrender-dev libxrandr-dev libxi-dev; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if ! sudo -n apt-get update; then
                log "ERROR: failed to update APT package metadata"
                return 30
            fi
            if ! sudo -n apt-get install -y curl tar gzip coreutils python3 gawk findutils sed grep make g++ zip unzip libfreetype-dev libfontconfig1-dev libasound2-dev libcups2-dev libxtst-dev libxt-dev libxrender-dev libxrandr-dev libxi-dev; then
                log "ERROR: failed to install OpenJDK test dependencies"
                return 30
            fi
        else
            log "ERROR: root privileges are required to install OpenJDK test dependencies"
            return 30
        fi
    else
        log "ERROR: unsupported package manager; cannot install OpenJDK test dependencies"
        return 30
    fi
    for required in curl tar sha256sum python3 awk sed grep tee make gcc g++ zip unzip; do
        if ! command -v "${required}" >/dev/null 2>&1; then
            log "ERROR: required command is still missing after installation: ${required}"
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
            log "ERROR: required OpenJDK development header is still missing: ${header}"
            return 30
        fi
    done
}

prepare_openjdk_source() {
    local archive_name archive_path local_archive_path top_dir

    case "${SOFTWARE_VERSION}" in
        25.0.4.1)
            OPENJDK_SOURCE_REPO="jdk25u"
            OPENJDK_SOURCE_TAG="jdk-25.0.4.1-ga"
            ;;
        *)
            log "ERROR: no OpenJDK source tag is declared for ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
    archive_name="${OPENJDK_SOURCE_REPO}-${OPENJDK_SOURCE_TAG}.tar.gz"
    local_archive_path="${OPENJDK_OFFLINE_DIR}/${archive_name}"
    archive_path="${PERF_WORK_DIR}/${archive_name}"
    OPENJDK_SOURCE_URL="${OPENJDK_SOURCE_BASE}/${OPENJDK_SOURCE_REPO}/archive/refs/tags/${OPENJDK_SOURCE_TAG}.tar.gz"
    if [[ -f "${local_archive_path}" ]]; then
        log "using local OpenJDK GA source archive ${local_archive_path}"
        if ! cp "${local_archive_path}" "${archive_path}"; then
            log "ERROR: failed to copy local OpenJDK source archive"
            return 30
        fi
    else
        log "downloading official OpenJDK GA source ${OPENJDK_SOURCE_TAG}"
        if ! curl -fL --retry 3 --connect-timeout 30 -o "${archive_path}" "${OPENJDK_SOURCE_URL}"; then
            log "ERROR: failed to download OpenJDK GA source archive"
            return 30
        fi
    fi
    OPENJDK_SOURCE_SHA256="$(sha256sum "${archive_path}" | awk '{print $1}')"
    top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
    if [[ -z "${top_dir}" || "${top_dir}" != "${OPENJDK_SOURCE_REPO}-"* ]]; then
        log "ERROR: OpenJDK source archive has an unexpected root directory: ${top_dir}"
        return 30
    fi
    if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract the OpenJDK GA source archive"
        return 30
    fi
    if ! mv "${PERF_WORK_DIR}/${top_dir}" "${SRC_DIR}"; then
        log "ERROR: failed to place the OpenJDK source tree"
        return 30
    fi
    rm -f "${archive_path}"
    log "OpenJDK GA source is ready: ${OPENJDK_SOURCE_TAG} (${OPENJDK_SOURCE_SHA256})"
}

prepare_boot_jdk() {
    local archive_name archive_path boot_jdk_release boot_jdk_version
    local local_archive_path top_dir version

    case "${SOFTWARE_VERSION}" in
        25.0.4.1)
            boot_jdk_version="25.0.4.1"
            boot_jdk_release="jdk-25.0.4.1%2B1"
            ;;
        *)
            log "ERROR: no Temurin boot JDK is declared for OpenJDK ${SOFTWARE_VERSION}"
            return 30
            ;;
    esac
    if [[ -n "${OPENJDK_BOOT_JDK_HOME}" ]]; then
        BOOT_JDK_HOME="${OPENJDK_BOOT_JDK_HOME}"
    else
        case "${EXPECTED_ARCH}" in
            x86_64)
                archive_name="OpenJDK25U-jdk_x64_linux_hotspot_${boot_jdk_version}_1.tar.gz"
                ;;
            aarch64)
                archive_name="OpenJDK25U-jdk_aarch64_linux_hotspot_${boot_jdk_version}_1.tar.gz"
                ;;
            *)
                log "ERROR: unsupported architecture for Temurin boot JDK: ${EXPECTED_ARCH}"
                return 30
                ;;
        esac
        local_archive_path="${OPENJDK_OFFLINE_DIR}/${archive_name}"
        archive_path="${PERF_WORK_DIR}/${archive_name}"
        if [[ -f "${local_archive_path}" ]]; then
            log "using local Temurin boot JDK archive ${local_archive_path}"
            if ! cp "${local_archive_path}" "${archive_path}"; then
                log "ERROR: failed to copy local Temurin boot JDK archive"
                return 30
            fi
        else
            log "downloading Temurin ${boot_jdk_version} boot JDK for ${EXPECTED_ARCH}"
            if ! curl -fL --retry 3 --connect-timeout 30 -o "${archive_path}" \
                "${ADOPTIUM_RELEASE_BASE}/${boot_jdk_release}/${archive_name}"; then
                log "ERROR: failed to download the Temurin boot JDK archive"
                return 30
            fi
        fi
        top_dir="$(tar -tzf "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
        if [[ -z "${top_dir}" || "${top_dir}" != jdk-* ]]; then
            log "ERROR: Temurin boot JDK archive has an unexpected root directory: ${top_dir}"
            return 30
        fi
        if ! tar -xzf "${archive_path}" -C "${PERF_WORK_DIR}"; then
            log "ERROR: failed to extract the Temurin boot JDK archive"
            return 30
        fi
        if ! mv "${PERF_WORK_DIR}/${top_dir}" "${PERF_WORK_DIR}/boot-jdk"; then
            log "ERROR: failed to place the Temurin boot JDK"
            return 30
        fi
        rm -f "${archive_path}"
        BOOT_JDK_HOME="${PERF_WORK_DIR}/boot-jdk"
    fi
    if [[ ! -x "${BOOT_JDK_HOME}/bin/java" || ! -x "${BOOT_JDK_HOME}/bin/javac" ]]; then
        log "ERROR: boot JDK is missing bin/java or bin/javac: ${BOOT_JDK_HOME}"
        return 30
    fi
    version="$("${BOOT_JDK_HOME}/bin/java" -version 2>&1 | sed -n 's/^openjdk version "\([^"]*\)".*/\1/p' | head -n 1)"
    if [[ "${version}" != "${boot_jdk_version}" ]]; then
        log "ERROR: expected Temurin boot JDK ${boot_jdk_version}, found ${version:-unknown}"
        return 30
    fi
    log "using Temurin boot JDK ${version}: ${BOOT_JDK_HOME}"
}

build_openjdk_from_source() {
    local build_jdk version_line actual_version

    if prepare_boot_jdk; then
        :
    else
        return $?
    fi
    log "configuring OpenJDK ${SOFTWARE_VERSION} GA source build"
    if ! (
        cd "${SRC_DIR}"
        bash configure \
            --with-debug-level=release \
            --with-boot-jdk="${BOOT_JDK_HOME}" \
            --prefix="${JDK_HOME}" \
            --disable-warnings-as-errors \
            --disable-precompiled-headers
    ); then
        log "ERROR: OpenJDK configure failed"
        return 40
    fi
    log "building OpenJDK images from source"
    if ! make -C "${SRC_DIR}" images; then
        log "ERROR: OpenJDK source build failed"
        return 40
    fi
    build_jdk="${SRC_DIR}/build/linux-${EXPECTED_ARCH}-server-release/images/jdk"
    if [[ ! -d "${build_jdk}" ]]; then
        log "ERROR: expected source build image is missing: ${build_jdk}"
        return 40
    fi
    if ! mv "${build_jdk}" "${JDK_HOME}"; then
        log "ERROR: failed to place the source-built JDK"
        return 40
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -x "${JDK_HOME}/bin/javac" ]]; then
        log "ERROR: source-built JDK is missing bin/java or bin/javac: ${JDK_HOME}"
        return 40
    fi
    version_line="$("${JDK_HOME}/bin/java" -version 2>&1 | head -n 1)"
    actual_version="$(printf '%s\n' "${version_line}" | sed -n 's/^openjdk version "\([^"]*\)".*/\1/p')"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}-internal" ]]; then
        log "ERROR: source-built JDK reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}-internal"
        return 40
    fi
    JDK_VERSION_STRING="${version_line}"
    if ! printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"; then
        log "ERROR: failed to record the actual OpenJDK version"
        return 40
    fi
    log "source-built JDK is ready: ${JDK_VERSION_STRING}"
}

prepare_jtreg() {
    local archive_name archive_path local_archive_path top_dir

    if [[ "${JTREG_VERSION}" != "8.3+1" ]]; then
        log "ERROR: only jtreg 8.3+1 is declared, got ${JTREG_VERSION}"
        return 30
    fi
    archive_name="jtreg-8.3+1.zip"
    archive_path="${PERF_WORK_DIR}/${archive_name}"
    local_archive_path="${OPENJDK_OFFLINE_DIR}/${archive_name}"
    if [[ -f "${local_archive_path}" ]]; then
        log "using local jtreg archive ${local_archive_path}"
        if ! cp "${local_archive_path}" "${archive_path}"; then
            log "ERROR: failed to copy local jtreg archive"
            return 30
        fi
    else
        log "downloading jtreg ${JTREG_VERSION}"
        if ! curl -fL --retry 3 --connect-timeout 30 -o "${archive_path}" "${JTREG_DOWNLOAD_URL}"; then
            log "ERROR: failed to download jtreg ${JTREG_VERSION}"
            return 30
        fi
    fi
    top_dir="$(unzip -Z1 "${archive_path}" | awk -F/ 'NR == 1 {print $1}')"
    if [[ -z "${top_dir}" ]]; then
        log "ERROR: jtreg archive is empty"
        return 30
    fi
    if ! unzip -q "${archive_path}" -d "${PERF_WORK_DIR}"; then
        log "ERROR: failed to extract jtreg archive"
        return 30
    fi
    if [[ "${PERF_WORK_DIR}/${top_dir}" != "${JTREG_HOME}" ]]; then
        if ! mv "${PERF_WORK_DIR}/${top_dir}" "${JTREG_HOME}"; then
            log "ERROR: failed to place jtreg"
            return 30
        fi
    fi
    rm -f "${archive_path}"
    if [[ ! -x "${JTREG_HOME}/bin/jtreg" ]]; then
        log "ERROR: jtreg executable is missing: ${JTREG_HOME}/bin/jtreg"
        return 30
    fi
    log "jtreg ${JTREG_VERSION} is ready at ${JTREG_HOME}"
}

build_openjdk() {
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if install_dependencies; then
        :
    else
        return $?
    fi
    if [[ -e "${JDK_HOME}" || -e "${SRC_DIR}" || -e "${PERF_WORK_DIR}/boot-jdk" || -e "${JTREG_HOME}" ]]; then
        log "ERROR: build directories are not clean under ${PERF_WORK_DIR}"
        return 20
    fi
    if prepare_openjdk_source; then
        :
    else
        return $?
    fi
    if build_openjdk_from_source; then
        :
    else
        return $?
    fi
    if prepare_jtreg; then
        :
    else
        return $?
    fi
    log "OpenJDK ${SOFTWARE_VERSION} benchmark runtime is built at ${PERF_WORK_DIR}"
}

start_openjdk_runtime() {
    local test_root
    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -x "${JTREG_HOME}/bin/jtreg" ]]; then
        log "ERROR: source-built OpenJDK or jtreg is missing"
        return 40
    fi
    for test_root in ${JTREG_TEST_ROOTS}; do
        if [[ ! -d "${SRC_DIR}/${test_root}" ]]; then
            log "ERROR: jtreg test root is missing: ${test_root}"
            return 40
        fi
    done
    log "OpenJDK jtreg runtime is ready"
}

run_openjdk_benchmarks() {
    local start_seconds elapsed_seconds

    if initialize_runtime; then
        :
    else
        return $?
    fi
    if [[ ! -x "${JDK_HOME}/bin/java" || ! -x "${JTREG_HOME}/bin/jtreg" ]]; then
        log "ERROR: source-built OpenJDK or jtreg is missing"
        return 40
    fi
    mkdir -p "${JTREG_WORK_DIR}" "${JTREG_REPORT_DIR}"
    start_seconds="$(date +%s)"
    log "running jtreg ${JTREG_VERSION}: ${JTREG_TEST_ROOTS}"
    if ! (
        cd "${SRC_DIR}"
        "${JTREG_HOME}/bin/jtreg" \
            -jdk:"${JDK_HOME}" \
            -w:"${JTREG_WORK_DIR}" \
            -r:"${JTREG_REPORT_DIR}" \
            -va -ignore:quiet -jit -conc:auto -timeout:5 -tl:3590 \
            ${JTREG_TEST_ROOTS}
    ) 2>&1 | tee "${RESULTS_DIR}/jtreg-output.log"; then
        log "ERROR: jtreg test run failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/jtreg-output.log" || ! -d "${JTREG_REPORT_DIR}" ]]; then
        log "ERROR: jtreg output or report directory is missing"
        return 50
    fi
    elapsed_seconds="$(( $(date +%s) - start_seconds ))"
    export SOFTWARE_VERSION EXPECTED_ARCH JTREG_VERSION JTREG_TEST_ROOTS
    if ! python3 "${SCRIPT_DIR}/scripts/parse_benchmark.py" \
        "${RESULTS_DIR}/jtreg-output.log" \
        "${RESULTS_DIR}/benchmark_openjdk.json" \
        "${elapsed_seconds}"; then
        log "ERROR: failed to normalize jtreg results"
        return 50
    fi
    log "jtreg results written to jtreg-output.log, jtreg-report, and benchmark_openjdk.json"
}

stop_openjdk_runtime() {
    log "OpenJDK benchmark has no background service to stop"
}

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /tmp/openjdk-perf/local-* || \
          "${PERF_WORK_DIR}" == "/tmp/openjdk-perf" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        if ! rm -rf -- "${PERF_WORK_DIR}"; then
            log "ERROR: failed to clean standalone work directory: ${PERF_WORK_DIR}"
            return 70
        fi
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_openjdk_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_openjdk_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    if initialize_runtime; then
        :
    else
        return $?
    fi

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
        standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_openjdk; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}" \
                "${JDK_VERSION_STRING}" \
                --source-url="${OPENJDK_SOURCE_URL}" \
                --source-sha256="${OPENJDK_SOURCE_SHA256}" \
                --source-repo="${OPENJDK_SOURCE_REPO}" \
                --source-tag="${OPENJDK_SOURCE_TAG}" \
                --boot-jdk-home="${BOOT_JDK_HOME}" \
                --jtreg-version="${JTREG_VERSION}" \
                --test-roots="${JTREG_TEST_ROOTS}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_openjdk_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_openjdk_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_openjdk_runtime; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi
    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build the official OpenJDK GA source archive and run the declared official
jtreg regression test roots with the source-built JDK. Results default to
results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       openjdk version (default: ${SOFTWARE_VERSION})
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, RESULTS_DIR, PERF_WORK_DIR,
  OPENJDK_SOURCE_BASE, OPENJDK_OFFLINE_DIR, OPENJDK_BOOT_JDK_HOME,
  ADOPTIUM_RELEASE_BASE, JTREG_DOWNLOAD_URL, JTREG_TEST_ROOTS
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --version requires a value"
                    return 10
                fi
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --results-dir)
                if [[ "$#" -lt 2 ]]; then
                    log "ERROR: --results-dir requires a value"
                    return 10
                fi
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    if configure_runtime_paths; then
        :
    else
        return $?
    fi
    if ! mkdir -p "${RESULTS_DIR}"; then
        log "ERROR: failed to create the standalone results directory: ${RESULTS_DIR}"
        return 10
    fi
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_openjdk_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
