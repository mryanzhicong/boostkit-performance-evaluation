#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc|stat|head|tail) printf 'coreutils\n' ;;
        cc) printf 'gcc\n' ;;
        make) printf 'make\n' ;;
        xz) printf 'xz\n' ;;
        tar) printf 'tar\n' ;;
        curl) printf 'curl\n' ;;
        python3) printf 'python3\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

# dnf (Runner) and apt-get (developer workstation) branches, each followed by a
# hard self-check: a missing command must fail the build stage, never be
# discovered later inside a timed measurement.
require_commands() {
    local missing=() packages=() cmd
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    (( ${#missing[@]} == 0 )) && return 0
    log_message "missing commands: ${missing[*]}"
    for cmd in "${missing[@]}"; do
        packages+=("$(package_for_command "${cmd}")")
    done
    if command -v dnf >/dev/null 2>&1; then
        local dnf_options=()
        [[ -n "${PERF_PROXY:-}" ]] && dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        local apt_options=()
        [[ -n "${PERF_PROXY:-}" ]] && apt_options+=(
            "-o" "Acquire::http::Proxy=${PERF_PROXY}"
            "-o" "Acquire::https::Proxy=${PERF_PROXY}"
        )
        DEBIAN_FRONTEND=noninteractive apt-get "${apt_options[@]}" update -y || return 30
        DEBIAN_FRONTEND=noninteractive apt-get "${apt_options[@]}" install -y --no-install-recommends \
            "${packages[@]}" || return 30
    else
        log_message "ERROR: no supported package manager (dnf/apt-get) is available"
        return 30
    fi
    for cmd in "${missing[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still unavailable: ${cmd}"
            return 30
        fi
    done
}

verify_sha256() {
    local file="$1" expected="$2" actual
    actual="$(sha256sum "${file}" | awk '{print $1}')"
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: sha256 mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified sha256 $(basename "${file}")"
}

# Try every candidate URL in order.  A slow-but-progressing transfer is allowed
# to finish; a stalled one is aborted by the speed limit so the next mirror is
# tried quickly.
download_asset() {
    local destination="$1"
    shift
    local urls=("$@")
    local url
    for url in "${urls[@]}"; do
        log_message "downloading ${url}"
        if curl -fL --retry 3 --retry-all-errors --retry-delay 2 \
            --connect-timeout 20 --speed-limit 1024 --speed-time 120 \
            -o "${destination}.part" "${url}"; then
            mv -- "${destination}.part" "${destination}"
            return 0
        fi
        rm -f -- "${destination}.part"
        log_message "download failed: ${url}"
    done
    return 30
}

# Resolve the pinned source archive: re-use a verified copy, prefer the
# pre-placed offline asset, then try the official host and its byte-identical
# mirrors.  Every path is verified against the same SHA-256.
materialize_source() {
    local destination="${LIBXML2_SOURCE_ARCHIVE}"
    local offline="${LIBXML2_OFFLINE_DIR}/${LIBXML2_SOURCE_NAME}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        if verify_sha256 "${destination}" "${LIBXML2_SOURCE_SHA256}"; then
            return 0
        fi
        log_message "discarding corrupted cached archive: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
        if verify_sha256 "${destination}" "${LIBXML2_SOURCE_SHA256}"; then
            return 0
        fi
        log_message "ERROR: pre-placed offline asset is not the official archive: ${offline}"
        rm -f -- "${destination}"
        return 30
    fi
    if ! download_asset "${destination}" "${LIBXML2_SOURCE_URLS[@]}"; then
        log_message "ERROR: could not obtain ${LIBXML2_SOURCE_NAME}"
        log_message "tried: ${LIBXML2_SOURCE_URLS[*]}"
        log_message "hint: pre-place the archive in ${LIBXML2_OFFLINE_DIR}/ or set PERF_LIBXML2_OFFLINE_DIR"
        return 30
    fi
    verify_sha256 "${destination}" "${LIBXML2_SOURCE_SHA256}"
}

install_source() {
    local marker="${LIBXML2_SRC_DIR}/.libxml2-source-version"
    if [[ -f "${marker}" && -x "${LIBXML2_SRC_DIR}/configure" ]]; then
        if [[ "$(<"${marker}")" == "${LIBXML2_VERSION}" ]]; then
            log_message "reusing extracted libxml2 ${LIBXML2_VERSION} sources at ${LIBXML2_SRC_DIR}"
            return 0
        fi
    fi
    materialize_source || return $?
    rm -rf -- "${LIBXML2_SRC_DIR}"
    mkdir -p "${LIBXML2_SRC_DIR}"
    log_message "extracting ${LIBXML2_SOURCE_NAME} to ${LIBXML2_SRC_DIR}"
    libxml2_container_exec tar -xJf "${LIBXML2_SOURCE_ARCHIVE}" -C "${LIBXML2_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the libxml2 source archive"
        return 30
    }
    if [[ ! -x "${LIBXML2_SRC_DIR}/configure" || ! -f "${LIBXML2_SRC_DIR}/Makefile.in" ]]; then
        log_message "ERROR: extracted libxml2 sources have an unexpected layout (no configure/Makefile.in)"
        return 30
    fi
    if [[ ! -d "${LIBXML2_SRC_DIR}/test" || ! -d "${LIBXML2_SRC_DIR}/result" ]]; then
        log_message "ERROR: upstream test data directories (test/, result/) are missing from the source release"
        return 30
    fi
    printf '%s\n' "${LIBXML2_VERSION}" > "${marker}"
}

flush_failure_log() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    report_failure_tail "${log_file}" "${scenario}" "${label}" "${exit_code}"
}

# The host keeps only the download/verification tools; the compiler, make and
# the whole build live in the private container.
require_host_transfer_commands() {
    local command_name
    for command_name in curl tar xz gzip sha256sum awk sed; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            log_message "ERROR: required host command is unavailable: ${command_name}"
            return 30
        }
    done
}

prepare_libxml2_build_container() {
    require_libxml2_docker || return 30
    start_libxml2_container || return $?
    if ! libxml2_container_exec_root dnf --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar xz gzip diffutils findutils coreutils \
        sed gawk grep util-linux file binutils glibc-devel python3 \
        >"${PERF_WORK_DIR}/container-packages.log" 2>&1; then
        log_message "ERROR: failed to install the container build packages"
        tail -n 40 -- "${PERF_WORK_DIR}/container-packages.log" | while IFS= read -r line; do log_message "  ${line}"; done
        return 30
    fi
    log_message "container build packages are installed"
}

configure_and_build_libxml2() {
    local log="${PERF_WORK_DIR}/build.log"
    log_message "configuring libxml2 ${LIBXML2_VERSION} (static, no python/zlib/iconv/icu)"
    if ! libxml2_container_exec_at "${LIBXML2_SRC_DIR}" \
        env CFLAGS="-O2 -pipe" ./configure \
            --prefix="${LIBXML2_PREFIX}" \
            --disable-shared --enable-static \
            --without-python --without-zlib --without-iconv --without-icu \
            --disable-dependency-tracking \
        >"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "configure" 30
        return 30
    fi
    log_message "building libxml2 and the upstream test drivers with -j${LIBXML2_JOBS}"
    if ! libxml2_container_exec_at "${LIBXML2_SRC_DIR}" make -j "${LIBXML2_JOBS}" \
        >>"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "make" 30
        return 30
    fi
    if ! libxml2_container_exec_at "${LIBXML2_SRC_DIR}" make -j "${LIBXML2_JOBS}" runtest runsuite \
        >>"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "make-test-drivers" 30
        return 30
    fi
    local binary
    for binary in "${LIBXML2_XMLLINT}" "${LIBXML2_RUNTEST}" "${LIBXML2_RUNSUITE}"; do
        if ! libxml2_container_exec test -x "${binary}"; then
            log_message "ERROR: expected build artifact is missing: ${binary}"
            return 30
        fi
    done
}

record_actual_version() {
    local version_line encoded decoded
    if ! version_line="$(libxml2_version_string)"; then
        log_message "ERROR: failed to execute ${LIBXML2_XMLLINT} --version"
        return 40
    fi
    encoded="$(printf '%s\n' "${version_line}" | awk '{print $NF}')"
    if ! decoded="$(decode_libxml2_version "${encoded}")"; then
        log_message "ERROR: could not decode the libxml2 version from: ${version_line}"
        return 40
    fi
    if [[ "${decoded}" != "${LIBXML2_VERSION}" ]]; then
        log_message "ERROR: requested libxml2 ${LIBXML2_VERSION} but built ${decoded}"
        return 40
    fi
    LIBXML2_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${decoded}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual libxml2 version: ${decoded}"
    log_message "runtime: ${version_line}"
    log_message "C compiler: $(compiler_identity)"
}

generate_corpora() {
    log_message "generating deterministic XML corpora"
    libxml2_container_exec python3 "${SCRIPT_DIR}/scripts/generate_corpus.py" \
        --output "${LIBXML2_CORPUS_DIR}" \
        --repeat-iterations "${LIBXML2_REPEAT_ITERATIONS}" || return 30
    if [[ ! -s "${LIBXML2_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest was not generated: ${LIBXML2_CORPUS_MANIFEST}"
        return 30
    fi
}

# Build-stage self-checks: a broken parser, corpus or upstream test driver must
# surface here with exit code 30 instead of during the timed test stage.
smoke_check_runtime() {
    local wide="${LIBXML2_CORPUS_DIR}/wide.xml"
    local dtd="${LIBXML2_CORPUS_DIR}/dtd.xml"
    local log="${PERF_WORK_DIR}/smoke.log"
    local expected count
    : >"${log}"
    log_message "smoke check: parse the wide corpus"
    if ! libxml2_container_exec "${LIBXML2_XMLLINT}" --noout --nonet "${wide}" >>"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "parse-wide" 30
        return 30
    fi
    log_message "smoke check: DTD validation of the dtd corpus"
    if ! libxml2_container_exec "${LIBXML2_XMLLINT}" --valid --noout --nonet "${dtd}" >>"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "dtd-validation" 30
        return 30
    fi
    log_message "smoke check: XPath count over the wide corpus"
    count="$(libxml2_container_exec_at "${PERF_WORK_DIR}" "${LIBXML2_XMLLINT}" --xpath 'count(//item)' --nonet "${wide}" 2>>"${log}")" || count=""
    expected="${LIBXML2_XPATH_ITEM_TOTAL}"
    if [[ "${count}" != "${expected}" ]]; then
        log_message "ERROR: XPath count returned '${count}', expected '${expected}'"
        flush_failure_log "${log}" "smoke" "xpath" 30
        return 30
    fi
    log_message "smoke check: upstream runtest driver"
    if ! libxml2_container_exec_at "${LIBXML2_SRC_DIR}" "${LIBXML2_RUNTEST}" \
        >"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "runtest" 30
        return 30
    fi
    if ! grep -q "Total ${LIBXML2_RUNTEST_TOTAL} tests, no errors" "${log}"; then
        log_message "ERROR: upstream runtest summary is missing or does not match the pinned total"
        flush_failure_log "${log}" "smoke" "runtest-summary" 30
        return 30
    fi
    log_message "smoke check: upstream runsuite driver"
    if ! libxml2_container_exec_at "${LIBXML2_SRC_DIR}" "${LIBXML2_RUNSUITE}" \
        >"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "runsuite" 30
        return 30
    fi
    if ! grep -q "Total ${LIBXML2_RUNSUITE_TOTAL} tests, no errors" "${log}"; then
        log_message "ERROR: upstream runsuite summary is missing or does not match the pinned total"
        flush_failure_log "${log}" "smoke" "runsuite-summary" 30
        return 30
    fi
    rm -f -- "${log}"
    log_message "smoke checks passed"
}

build_libxml2_base() {
    initialize_runtime || return $?
    require_host_transfer_commands || return $?
    prepare_libxml2_build_container || return $?
    install_source || return $?
    configure_and_build_libxml2 || return $?
    record_actual_version || return $?
    generate_corpora || return $?
    smoke_check_runtime || return $?
    log_message "base build completed: libxml2 ${LIBXML2_VERSION}, $(compiler_identity), -j${LIBXML2_JOBS}"
}
