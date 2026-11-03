#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Host-side prerequisites are limited to Docker plus the download/verification
# tools; every compiler, test program and workload runs in the container.
require_host_transfer_commands() {
    local packages=() command_name package
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;;
            sha256sum) package=coreutils ;;
            tar) package=tar ;;
            python3) package=python3 ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    log_message "WARNING: host download tools are incomplete: ${packages[*]}; relying on the pre-placed offline asset"
    return 0
}

prepare_expat_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_expat_docker || return 30
    start_expat_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing expat build dependencies inside the private container'
    expat_container_exec_root dnf "${dnf_options[@]}" --setopt=install_weak_deps=False install -y \
        gcc gcc-c++ make tar xz gzip diffutils coreutils findutils sed gawk grep \
        util-linux file glibc-devel binutils python3 || {
        log_message "ERROR: container build dependencies failed"
        return 30
    }
}

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
# pre-placed offline asset, then try the mirror list.  Every path is verified
# against the same SHA-256.
materialize_source() {
    local destination="${EXPAT_SOURCE_ARCHIVE}"
    local offline="${EXPAT_OFFLINE_DIR}/${EXPAT_SOURCE_NAME}"
    mkdir -p "$(dirname "${destination}")"
    if [[ -f "${destination}" ]]; then
        if verify_sha256 "${destination}" "${EXPAT_SOURCE_SHA256}"; then
            return 0
        fi
        log_message "discarding corrupted cached archive: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
        if verify_sha256 "${destination}" "${EXPAT_SOURCE_SHA256}"; then
            return 0
        fi
        log_message "ERROR: pre-placed offline asset is not the official archive: ${offline}"
        rm -f -- "${destination}"
        return 30
    fi
    if ! download_asset "${destination}" "${EXPAT_SOURCE_URLS[@]}"; then
        log_message "ERROR: could not obtain ${EXPAT_SOURCE_NAME}"
        log_message "tried: ${EXPAT_SOURCE_URLS[*]}"
        log_message "hint: pre-place the archive in ${EXPAT_OFFLINE_DIR}/ or set PERF_EXPAT_OFFLINE_DIR"
        return 30
    fi
    verify_sha256 "${destination}" "${EXPAT_SOURCE_SHA256}"
}

install_source() {
    local marker="${EXPAT_SRC_DIR}/.expat-source-version"
    if expat_container_exec test -f "${marker}" && \
        expat_container_exec test -x "${EXPAT_SRC_DIR}/configure"; then
        if [[ "$(<"${marker}")" == "${EXPAT_VERSION}" ]]; then
            log_message "reusing extracted expat ${EXPAT_VERSION} sources at ${EXPAT_SRC_DIR}"
            return 0
        fi
    fi
    materialize_source || return $?
    rm -rf -- "${EXPAT_SRC_DIR}"
    mkdir -p "${EXPAT_SRC_DIR}"
    log_message "extracting ${EXPAT_SOURCE_NAME} to ${EXPAT_SRC_DIR} inside the private container"
    expat_container_exec tar -xJf "${EXPAT_SOURCE_ARCHIVE}" -C "${EXPAT_SRC_DIR}" --strip-components=1 || {
        log_message "ERROR: failed to extract the expat source archive"
        return 30
    }
    if ! expat_container_exec test -x "${EXPAT_SRC_DIR}/configure" || \
        ! expat_container_exec test -f "${EXPAT_SRC_DIR}/Makefile.in"; then
        log_message "ERROR: extracted expat sources have an unexpected layout (no configure/Makefile.in)"
        return 30
    fi
    if ! expat_container_exec test -d "${EXPAT_SRC_DIR}/xmlwf" || \
        ! expat_container_exec test -f "${EXPAT_SRC_DIR}/tests/runtests.c" || \
        ! expat_container_exec test -f "${EXPAT_SRC_DIR}/tests/benchmark/benchmark.c"; then
        log_message "ERROR: upstream xmlwf/tests/benchmark sources are missing from the release archive"
        return 30
    fi
    printf '%s\n' "${EXPAT_VERSION}" > "${marker}"
}

flush_failure_log() {
    local log_file="$1" scenario="$2" label="$3" exit_code="$4"
    report_failure_tail "${log_file}" "${scenario}" "${label}" "${exit_code}"
}

configure_and_build_expat() {
    local log="${PERF_WORK_DIR}/build.log"
    log_message "configuring expat ${EXPAT_VERSION} inside the private container (static library, xmlwf and upstream tests)"
    if ! expat_container_exec_at "${EXPAT_SRC_DIR}" \
        env "CFLAGS=-O2 -pipe" \
        ./configure \
            --prefix="${EXPAT_PREFIX}" \
            --disable-shared --enable-static \
            --without-docbook --without-examples >"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "configure" 30
        return 30
    fi
    log_message "building expat, xmlwf and the upstream test programs with -j${EXPAT_JOBS} inside the private container"
    if ! expat_container_exec_at "${EXPAT_SRC_DIR}" make -j "${EXPAT_JOBS}" >>"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "make" 30
        return 30
    fi
    local binary
    for binary in "${EXPAT_XMLWF}" "${EXPAT_BENCHMARK}"; do
        if ! expat_container_exec test -x "${binary}"; then
            log_message "ERROR: expected build artifact is missing: ${binary}"
            return 30
        fi
    done
}

# Build and execute the upstream test suite once as a build-stage smoke test.
# The suite prints a pinned summary that must be present, so a broken build or a
# missing test corpus can never be mistaken for a successful one later.
verify_upstream_suite() {
    local log="${PERF_WORK_DIR}/check.log"
    log_message "running the upstream test suite once (make check) inside the private container"
    if ! expat_container_exec_at "${EXPAT_SRC_DIR}" make -j "${EXPAT_JOBS}" check >"${log}" 2>&1; then
        flush_failure_log "${log}" "build" "make-check" 30
        return 30
    fi
    if ! expat_container_exec test -x "${EXPAT_RUNTESTS}"; then
        log_message "ERROR: upstream runtests binary was not produced by make check: ${EXPAT_RUNTESTS}"
        return 30
    fi
    if ! grep -q "PASS: runtests" "${log}"; then
        log_message "ERROR: the automake test harness did not report PASS for runtests"
        flush_failure_log "${log}" "build" "runtests-harness" 30
        return 30
    fi
    # automake redirects the driver's stdout into tests/runtests.log; that file
    # carries the pinned check count and is part of the build-stage contract.
    local runtests_log="${EXPAT_SRC_DIR}/tests/runtests.log"
    if [[ ! -s "${runtests_log}" ]]; then
        log_message "ERROR: upstream runtests did not produce its log: ${runtests_log}"
        return 30
    fi
    if ! grep -q "Checks: ${EXPAT_RUNTESTS_CHECKS}, Failed: 0" "${runtests_log}"; then
        log_message "ERROR: upstream runtests summary is missing or does not match the pinned check count"
        flush_failure_log "${runtests_log}" "build" "runtests-summary" 30
        return 30
    fi
    log_message "upstream test suite passed: ${EXPAT_RUNTESTS_CHECKS} checks, 0 failed"
}

record_actual_version() {
    local version_line decoded
    if ! version_line="$(expat_version_string)"; then
        log_message "ERROR: failed to execute ${EXPAT_XMLWF} --version"
        return 40
    fi
    if ! decoded="$(decode_expat_version "${version_line}")"; then
        log_message "ERROR: could not decode the expat version from: ${version_line}"
        return 40
    fi
    if [[ "${decoded}" != "${EXPAT_VERSION}" ]]; then
        log_message "ERROR: requested expat ${EXPAT_VERSION} but built ${decoded}"
        return 40
    fi
    EXPAT_VERSION_STRING="${version_line}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${decoded}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual expat version: ${decoded}"
    log_message "runtime: ${version_line}"
    log_message "C compiler: $(compiler_identity)"
}

generate_corpora() {
    log_message "generating deterministic XML corpora inside the private container"
    expat_container_exec python3 "${SCRIPT_DIR}/scripts/generate_corpus.py" \
        --output "${EXPAT_CORPUS_DIR}" \
        --benchmark-iterations "${EXPAT_BENCH_ITERATIONS}" \
        --benchmark-buffer "${EXPAT_BENCH_BUFFER}" || return 30
    if [[ ! -s "${EXPAT_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest was not generated: ${EXPAT_CORPUS_MANIFEST}"
        return 30
    fi
}

# Build-stage self-checks: a broken parser, corpus or upstream benchmark must
# surface here with exit code 30 instead of during the timed test stage.
smoke_check_runtime() {
    local corpora="${EXPAT_CORPUS_DIR}"
    local log="${PERF_WORK_DIR}/smoke.log"
    : >"${log}"
    log_message "smoke check: xmlwf parses the wide corpus inside the private container"
    if ! expat_container_exec "${EXPAT_XMLWF}" -t "${corpora}/wide.xml" >>"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "xmlwf-wide" 30
        return 30
    fi
    log_message "smoke check: xmlwf with namespace processing and external DTD"
    if ! expat_container_exec "${EXPAT_XMLWF}" -n -t "${corpora}/namespaced.xml" >>"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "xmlwf-namespaced" 30
        return 30
    fi
    if ! expat_container_exec_at "${corpora}" "${EXPAT_XMLWF}" -p -t dtd_ext.xml >>"${log}" 2>&1; then
        flush_failure_log "${log}" "smoke" "xmlwf-external-dtd" 30
        return 30
    fi
    log_message "smoke check: upstream benchmark driver"
    if ! expat_container_exec_at "${corpora}" \
        "${EXPAT_BENCHMARK}" wide.xml "${EXPAT_BENCH_BUFFER}" 2 >"${log}.bench" 2>&1; then
        flush_failure_log "${log}.bench" "smoke" "benchmark" 30
        return 30
    fi
    if ! grep -q "Average time per loop:" "${log}.bench"; then
        log_message "ERROR: upstream benchmark did not print its timing summary"
        flush_failure_log "${log}.bench" "smoke" "benchmark-summary" 30
        return 30
    fi
    rm -f -- "${log}" "${log}.bench"
    log_message "smoke checks passed"
}

build_expat_base() {
    initialize_runtime || return $?
    prepare_expat_build_container || return $?
    install_source || return $?
    configure_and_build_expat || return $?
    verify_upstream_suite || return $?
    record_actual_version || return $?
    generate_corpora || return $?
    smoke_check_runtime || return $?
    log_message "base build completed: expat ${EXPAT_VERSION}, $(compiler_identity), -j${EXPAT_JOBS}"
}
