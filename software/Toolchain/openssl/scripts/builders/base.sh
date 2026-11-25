#!/usr/bin/env bash
# Base build: unmodified upstream OpenSSL 4.1.0, built and measured inside the
# private openEuler container.  The host only downloads and verifies the pinned
# release archive and invokes Docker.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

openssl_check_inputs() {
    local arch
    arch="$(openssl_arch "${EXPECTED_ARCH}")"
    [[ "${arch}" == "$(openssl_arch "$(uname -m)")" ]] || {
        log_message "ERROR: requested architecture ${arch} differs from host $(uname -m)"
        return 20
    }
    [[ "${SOFTWARE_VERSION}" == "4.1.0" ]] || {
        log_message "ERROR: only openssl 4.1.0 is supported, got ${SOFTWARE_VERSION}"
        return 10
    }
    [[ "$(id -u)" -ne 0 ]] || log_message 'WARNING: running as root; the container will run as root as well'
}

openssl_install_dependencies() {
    local attempt
    log_message 'installing build and test dependencies inside the private container'
    for attempt in 1 2; do
        openssl_container_exec_root dnf install -y --setopt=install_weak_deps=False \
            perl perl-Test-Simple perl-Time-HiRes make gcc gawk \
            tar gzip diffutils findutils which coreutils && return 0
        log_message "WARNING: dnf install attempt ${attempt} failed inside the private container"
        sleep 5
    done
    log_message 'ERROR: dnf install failed inside the container'
    return 30
}

openssl_unpack_sources() {
    local downloads src
    downloads="$(openssl_downloads_dir)"
    src="$(openssl_source_dir)"
    if openssl_container_exec test -e "${src}"; then
        log_message "ERROR: source directory already exists inside the work directory: ${src}"
        return 20
    fi
    openssl_container_exec tar xzf "${downloads}/${OPENSSL_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}" || return 30
    openssl_container_exec test -s "${src}/Configure" || { log_message "ERROR: missing ${src}/Configure"; return 40; }
    openssl_container_exec test -s "${src}/apps/speed.c" || { log_message "ERROR: missing ${src}/apps/speed.c"; return 40; }
    openssl_container_exec test -s "${src}/test/run_tests.pl" || { log_message "ERROR: missing ${src}/test/run_tests.pl"; return 40; }
}

# OpenSSL does not support out-of-tree builds, so Configure and make run with
# the source tree as the working directory inside the container.
openssl_configure_and_build() {
    local src prefix started
    src="$(openssl_source_dir)"
    prefix="$(openssl_install_dir)"
    started="$(date +%s)"
    log_message "configuring openssl in-tree: ./Configure no-shared --prefix=${prefix}"
    openssl_container_exec_at "${src}" ./Configure no-shared \
        --prefix="${prefix}" --openssldir="${prefix}/ssl" \
        > "${RESULTS_DIR}/configure.log" 2>&1 || {
        log_message 'ERROR: ./Configure failed'
        openssl_container_exec tail -n 40 "${RESULTS_DIR}/configure.log" || true
        return 30
    }
    log_message "configure finished in $(( $(date +%s) - started )) s"
    started="$(date +%s)"
    log_message 'building with the upstream default target flags (no -march/-mcpu/-flto)'
    openssl_container_exec_at "${src}" bash -c 'make -j"$(nproc)"' \
        > "${RESULTS_DIR}/build.log" 2>&1 || {
        log_message 'ERROR: make failed'
        openssl_container_exec tail -n 60 "${RESULTS_DIR}/build.log" || true
        return 30
    }
    log_message "make -j$(nproc) finished in $(( $(date +%s) - started )) s"
    started="$(date +%s)"
    log_message 'installing the statically linked openssl binary (make install_sw)'
    openssl_container_exec_at "${src}" make install_sw \
        > "${RESULTS_DIR}/install.log" 2>&1 || {
        log_message 'ERROR: make install_sw failed'
        openssl_container_exec tail -n 40 "${RESULTS_DIR}/install.log" || true
        return 30
    }
    log_message "make install_sw finished in $(( $(date +%s) - started )) s"
    openssl_container_exec test -x "$(openssl_bin)" || {
        log_message "ERROR: expected executable is missing: $(openssl_bin)"
        return 40
    }
}

openssl_smoke_test() {
    local log="${RESULTS_DIR}/smoke.log"
    openssl_container_exec "$(openssl_bin)" speed -mr -seconds 1 -bytes 16384 sha256 \
        > "${log}" 2> "${RESULTS_DIR}/smoke.err" || {
        log_message 'ERROR: smoke speed run failed'
        cat "${RESULTS_DIR}/smoke.err" 2>/dev/null || true
        cat "${log}" 2>/dev/null || true
        return 40
    }
    grep -q '^+F:6:sha256:' "${log}" || {
        log_message 'ERROR: smoke run did not print the expected +F:6:sha256 row'
        cat "${log}" || true
        return 40
    }
    python3 - "${log}" <<'PY'
import re
import sys

text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
rows = re.findall(r"^\+F:6:sha256:([0-9.]+)$", text, re.MULTILINE)
if len(rows) != 1:
    raise SystemExit(f"smoke check: expected exactly one +F:6:sha256 row, found {rows}")
value = float(rows[0])
if not value > 0:
    raise SystemExit(f"smoke check: non-positive throughput {value}")
print(f"smoke check: sha256 {value} B/s", file=sys.stderr)
PY
}

openssl_detect_version() {
    local src actual source_version
    src="$(openssl_source_dir)"
    actual="$(openssl_container_exec "$(openssl_bin)" version)" || return 40
    actual="$(printf '%s\n' "${actual}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
    if [[ "${actual}" != "4.1.0" ]]; then
        log_message "ERROR: built binary reports version ${actual:-<none>}, expected 4.1.0"
        return 40
    fi
    source_version="$(openssl_container_exec bash -c 'sed -n "s/^MAJOR=//p; s/^MINOR=//p; s/^PATCH=//p" "$1/VERSION.dat" | paste -sd. -' _ "${src}")" || return 40
    if [[ "${source_version}" != "4.1.0" ]]; then
        log_message "ERROR: source tree VERSION.dat reports ${source_version:-<none>}, expected 4.1.0"
        return 40
    fi
    printf '4.1.0\n' > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "verified openssl version: binary=${actual} source=${source_version}"
}

build_openssl_base() {
    local run_id="${PERF_RUN_ID}" arch downloads
    openssl_check_inputs || return $?
    arch="$(openssl_arch "${EXPECTED_ARCH}")"
    downloads="$(openssl_downloads_dir)"
    log_message "base build: openssl ${SOFTWARE_VERSION} on ${arch} (run ${run_id})"

    require_openssl_docker || return $?
    mkdir -p "${downloads}"
    : > "${downloads}/sha256sums.txt"
    openssl_fetch_archive "${OPENSSL_SOURCE_ARCHIVE}" "${OPENSSL_SOURCE_URL}" \
        "${OPENSSL_SOURCE_SHA256}" "${downloads}" || return $?
    ( cd "${downloads}" && sha256sum -c sha256sums.txt >/dev/null ) || {
        log_message 'ERROR: archive manifest verification failed'
        return 30
    }

    start_openssl_container || return $?
    trap 'remove_openssl_container || true' EXIT

    openssl_install_dependencies || return $?
    openssl_unpack_sources || return $?
    openssl_configure_and_build || return $?
    openssl_smoke_test || return $?
    openssl_detect_version || return $?
    openssl_write_build_variant base || return $?

    trap - EXIT
    log_message "base build finished; container ${OPENSSL_CONTAINER_NAME} is retained for the start/test stages"
}
