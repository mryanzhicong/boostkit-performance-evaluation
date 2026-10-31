#!/usr/bin/env bash
# Build helpers for the GDB case: prerequisites, source archive, configure/make/install.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ---------------------------------------------------------- prerequisites -----
# The complete build needs a C/C++ toolchain, make, the GMP/MPFR development
# packages (GDB is linked with system GMP/MPFR, see GDB_CONFIGURE_OPTIONS), the
# Python development headers (the GDB Python API is part of the measured workload)
# and DejaGnu's ``runtest`` for the fixed upstream testsuite subset.  On the
# validated runner the packages are already present; on a clean image the stage
# installs them with the distribution package manager.  Installing prerequisites is
# part of the build stage, so the measurement stage never needs network access.
install_build_dependencies() {
    local required_commands=(gcc g++ make python3 tar xz sha256sum curl runtest)
    local missing_commands=()
    local command_name

    for command_name in "${required_commands[@]}"; do
        if ! command -v "${command_name}" >/dev/null 2>&1 && \
           ! [[ -x "/usr/bin/${command_name}" ]]; then
            missing_commands+=("${command_name}")
        fi
    done

    local need_gmp=0 need_mpfr=0 need_python_headers=0
    printf '#include <gmp.h>\nint main(void) { return 0; }\n' | \
        gcc -x c - -lgmp -o /tmp/gdb-gmp-probe.$$ >/dev/null 2>&1 || need_gmp=1
    printf '#include <mpfr.h>\nint main(void) { return 0; }\n' | \
        gcc -x c - -lmpfr -o /tmp/gdb-mpfr-probe.$$ >/dev/null 2>&1 || need_mpfr=1
    rm -f /tmp/gdb-gmp-probe.$$ /tmp/gdb-mpfr-probe.$$
    python3 - <<'PY' >/dev/null 2>&1 || need_python_headers=1
import os
import sysconfig
include = sysconfig.get_paths()["include"]
raise SystemExit(0 if os.path.exists(os.path.join(include, "Python.h")) else 1)
PY

    if [[ ${#missing_commands[@]} -eq 0 && ${need_gmp} -eq 0 && ${need_mpfr} -eq 0 && ${need_python_headers} -eq 0 ]]; then
        log_message "build prerequisites are already available"
        return 0
    fi

    local packages
    local install_command
    if command -v dnf >/dev/null 2>&1; then
        packages=(gcc gcc-c++ make tar xz coreutils curl python3 python3-devel
                  gmp-devel mpfr-devel dejagnu texinfo findutils)
        install_command=(dnf install -y)
        [[ "$(id -u)" -ne 0 ]] && install_command=(sudo -n dnf install -y)
    elif command -v apt-get >/dev/null 2>&1; then
        packages=(gcc g++ make tar xz coreutils curl python3 python3-dev
                  libgmp-dev libmpfr-dev dejagnu texinfo findutils)
        install_command=(apt-get install -y)
        [[ "$(id -u)" -ne 0 ]] && install_command=(sudo -n apt-get install -y)
    else
        fail_message "neither dnf nor apt-get is available to install the GDB build prerequisites"
        return 30
    fi
    log_message "installing build prerequisites: ${packages[*]}"
    if ! "${install_command[@]}" "${packages[@]}" > "${PERF_WORK_DIR}/build-prerequisites.log" 2>&1; then
        fail_message "failed to install the GDB build prerequisites (see build-prerequisites.log)"
        return 30
    fi

    for command_name in "${required_commands[@]}"; do
        command -v "${command_name}" >/dev/null 2>&1 || {
            fail_message "required build command is still missing after installation: ${command_name}"
            return 30
        }
    done
    printf '#include <gmp.h>\nint main(void) { return 0; }\n' | \
        gcc -x c - -lgmp -o /tmp/gdb-gmp-probe.$$ || {
        fail_message "the GMP development files are unavailable after installation"
        return 30
    }
    printf '#include <mpfr.h>\nint main(void) { return 0; }\n' | \
        gcc -x c - -lmpfr -o /tmp/gdb-mpfr-probe.$$ || {
        fail_message "the MPFR development files are unavailable after installation"
        return 30
    }
    rm -f /tmp/gdb-gmp-probe.$$ /tmp/gdb-mpfr-probe.$$
    python3 - <<'PY' || {
import os
import sysconfig
raise SystemExit(0 if os.path.exists(os.path.join(sysconfig.get_paths()["include"], "Python.h")) else 1)
PY
        fail_message "the Python development headers are unavailable after installation"
        return 30
    }
    log_message "build prerequisites are ready"
    return 0
}

# ---------------------------------------------------------------- source ------
fetch_gdb_source() {
    local candidate actual_sha256 actual_size
    local -a urls=("${GDB_SOURCE_URLS[@]}")
    mkdir -p "${GDB_WORK_ASSETS}"

    if [[ -f "${GDB_SOURCE_ARCHIVE}" ]]; then
        fail_message "the source archive already exists, the build directory is not clean: ${GDB_SOURCE_ARCHIVE}"
        return 20
    fi

    for candidate in "${urls[@]}"; do
        if [[ "${candidate}" == http://* || "${candidate}" == https://* ]]; then
            log_message "downloading GDB ${SOFTWARE_VERSION} source archive from ${candidate}"
            if curl -g -fsSL --retry 3 --connect-timeout 30 --max-time 900 \
                -o "${GDB_SOURCE_ARCHIVE}" "${candidate}"; then
                break
            fi
            rm -f "${GDB_SOURCE_ARCHIVE}"
        else
            if [[ -f "${candidate}" ]]; then
                log_message "using pre-placed GDB source archive ${candidate}"
                cp "${candidate}" "${GDB_SOURCE_ARCHIVE}" || {
                    fail_message "failed to copy the pre-placed source archive"
                    return 30
                }
                break
            fi
        fi
    done
    if [[ ! -f "${GDB_SOURCE_ARCHIVE}" ]]; then
        fail_message "could not obtain the GDB ${SOFTWARE_VERSION} source archive from any configured source"
        return 30
    fi

    actual_sha256="$(sha256sum "${GDB_SOURCE_ARCHIVE}" | awk '{print $1}')"
    actual_size="$(stat -c%s "${GDB_SOURCE_ARCHIVE}")"
    if [[ "${actual_sha256}" != "${GDB_SOURCE_SHA256}" ]]; then
        fail_message "GDB source archive checksum mismatch"
        fail_message "expected: ${GDB_SOURCE_SHA256}"
        fail_message "actual:   ${actual_sha256}"
        return 30
    fi
    if [[ "${actual_size}" != "${GDB_SOURCE_SIZE}" ]]; then
        fail_message "GDB source archive size mismatch: expected ${GDB_SOURCE_SIZE}, got ${actual_size}"
        return 30
    fi
    log_message "verified GDB source archive (sha256 ${actual_sha256})"

    # The detached signature is kept next to the archive so the origin of the
    # pinned checksum can be audited later; GDB's signing key is not part of the
    # image, so the signature itself is recorded but not cryptographically checked.
    if [[ ! -f "${GDB_SOURCE_SIGNATURE}" ]]; then
        local sig_url
        for sig_url in \
            "https://mirrors.tuna.tsinghua.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz.sig" \
            "https://mirrors.ustc.edu.cn/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz.sig" \
            "https://ftp.gnu.org/gnu/gdb/gdb-${SOFTWARE_VERSION}.tar.xz.sig"; do
            if curl -g -fsSL --retry 2 --connect-timeout 20 --max-time 120 \
                -o "${GDB_SOURCE_SIGNATURE}" "${sig_url}"; then
                log_message "saved detached GPG signature from ${sig_url}"
                break
            fi
            rm -f "${GDB_SOURCE_SIGNATURE}"
        done
    fi
    return 0
}

extract_gdb_source() {
    if [[ -e "${GDB_SRC_DIR}" ]]; then
        fail_message "the extracted source directory already exists: ${GDB_SRC_DIR}"
        return 20
    fi
    log_message "extracting the verified GDB source archive"
    if ! tar -xJf "${GDB_SOURCE_ARCHIVE}" -C "${PERF_WORK_DIR}"; then
        fail_message "failed to extract the GDB source archive"
        return 40
    fi
    if [[ ! -d "${PERF_WORK_DIR}/gdb-${SOFTWARE_VERSION}" ]]; then
        fail_message "the source archive did not create gdb-${SOFTWARE_VERSION}"
        return 40
    fi
    if ! grep -q "${SOFTWARE_VERSION}" "${PERF_WORK_DIR}/gdb-${SOFTWARE_VERSION}/gdb/version.in" 2>/dev/null; then
        fail_message "the extracted source tree is not GDB ${SOFTWARE_VERSION}"
        return 40
    fi
    mv "${PERF_WORK_DIR}/gdb-${SOFTWARE_VERSION}" "${GDB_SRC_DIR}" || {
        fail_message "failed to place the extracted GDB source tree"
        return 40
    }
    return 0
}

configure_and_build_gdb() {
    local configure_started make_started install_started
    if [[ -e "${GDB_BUILD_DIR}" || -e "${GDB_INSTALL_DIR}" ]]; then
        fail_message "build or installation directory already exists (not a clean build)"
        return 20
    fi
    mkdir -p "${GDB_BUILD_DIR}"
    log_message "configuring GDB ${SOFTWARE_VERSION} (isolated prefix ${GDB_INSTALL_DIR})"
    configure_started="$(date +%s)"
    if ! (
        cd "${GDB_BUILD_DIR}" || exit 1
        MAKEINFO=true "${GDB_SRC_DIR}/configure" \
            --prefix="${GDB_INSTALL_DIR}" \
            --with-python=python3 \
            "${GDB_CONFIGURE_OPTIONS[@]}"
    ) > "${PERF_WORK_DIR}/gdb-configure.log" 2>&1; then
        fail_message "GDB configure failed (see gdb-configure.log)"
        return 40
    fi
    local configure_seconds=$(( $(date +%s) - configure_started ))

    log_message "building GDB ${SOFTWARE_VERSION} with make -j${GDB_BUILD_JOBS} (MAKEINFO=true)"
    make_started="$(date +%s)"
    if ! (
        cd "${GDB_BUILD_DIR}" || exit 1
        make -j"${GDB_BUILD_JOBS}" MAKEINFO=true
    ) > "${PERF_WORK_DIR}/gdb-make.log" 2>&1; then
        fail_message "GDB build failed (see gdb-make.log)"
        return 40
    fi
    local make_seconds=$(( $(date +%s) - make_started ))

    log_message "installing GDB into ${GDB_INSTALL_DIR}"
    install_started="$(date +%s)"
    if ! (
        cd "${GDB_BUILD_DIR}" || exit 1
        make install MAKEINFO=true
    ) > "${PERF_WORK_DIR}/gdb-install.log" 2>&1; then
        fail_message "GDB installation failed (see gdb-install.log)"
        return 40
    fi
    local install_seconds=$(( $(date +%s) - install_started ))

    if [[ ! -x "${GDB_BIN}" ]]; then
        fail_message "the built GDB binary is missing: ${GDB_BIN}"
        return 40
    fi
    if ! "${GDB_BIN}" --version | head -n 1 | grep -q "GNU gdb (GDB) ${SOFTWARE_VERSION}"; then
        fail_message "the built GDB does not report version ${SOFTWARE_VERSION}"
        return 40
    fi
    GDB_BUILD_SECONDS=$(( configure_seconds + make_seconds + install_seconds ))
    GDB_CONFIGURE_SECONDS="${configure_seconds}"
    GDB_MAKE_SECONDS="${make_seconds}"
    GDB_INSTALL_SECONDS="${install_seconds}"
    log_message "built GDB ${SOFTWARE_VERSION} in ${GDB_BUILD_SECONDS}s (configure ${configure_seconds}s, make ${make_seconds}s, install ${install_seconds}s)"
    export GDB_BUILD_SECONDS GDB_CONFIGURE_SECONDS GDB_MAKE_SECONDS GDB_INSTALL_SECONDS
    return 0
}

record_actual_version() {
    local version_output actual_version
    if ! version_output="$("${GDB_BIN}" --version 2>/dev/null | head -n 1)"; then
        fail_message "the built GDB cannot report its version"
        return 40
    fi
    actual_version="$(printf '%s\n' "${version_output}" | sed -n 's/^GNU gdb (GDB) \([0-9][0-9.]*\).*/\1/p')"
    if [[ -z "${actual_version}" ]]; then
        fail_message "could not parse the GDB version from: ${version_output}"
        return 40
    fi
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "the built GDB reports ${actual_version}, requested ${SOFTWARE_VERSION}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    GDB_VERSION_STRING="${version_output}"
    export GDB_VERSION_STRING
    log_message "actual GDB version ${actual_version} recorded"
    return 0
}

record_build_info() {
    local variant="$1"
    local python_version cc_version
    cc_version="$(gcc --version 2>/dev/null | head -n 1)"
    python_version="$(python3 --version 2>/dev/null)"
    local sig_sha256=""
    if [[ -f "${GDB_SOURCE_SIGNATURE}" ]]; then
        sig_sha256="$(sha256sum "${GDB_SOURCE_SIGNATURE}" | awk '{print $1}')"
    fi
    if ! python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" build-info \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${PERF_ACTUAL_VERSION_FILE}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${GDB_SOURCE_SHA256}" \
        "${GDB_SOURCE_SIZE}" \
        "${GDB_BUILD_SECONDS:-0}" \
        "${cc_version}" \
        "${python_version}" \
        "${sig_sha256}"; then
        fail_message "failed to write build_info.json / build_provenance.json"
        return 60
    fi
    return 0
}

write_build_variant_metadata() {
    log_message "build variant ${PERF_VARIANT}: recording build_variant.json"
    python3 - "${RESULTS_DIR}/build_variant.json" "${PERF_VARIANT}" \
        "${SOFTWARE_VERSION}" "${GDB_SOURCE_SHA256}" "${GDB_BUILD_SECONDS:-0}" <<'PY'
import json
import sys
from datetime import datetime, timezone

output, variant, version, source_sha256, build_seconds = sys.argv[1:6]
payload = {
    "variant": variant,
    "software": "gdb",
    "version": version,
    "source": "official GNU release tarball, checksum pinned and verified",
    "source_sha256": source_sha256,
    "build_mode": "source build with an isolated prefix",
    "build_seconds": int(float(build_seconds)),
    "recorded_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
}
with open(output, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")
PY
    return $?
}
