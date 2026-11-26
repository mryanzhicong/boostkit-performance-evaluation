#!/usr/bin/env bash
# ==============================================================================
# mysql 8.0.43 optimized builder -- deploys the vendor-published BoostDB package.
# ==============================================================================
# The optimized variant measures the Kunpeng-optimized MySQL that BoostKit
# publishes for release ${MYSQL_OPTIMIZED_RELEASE} as
# BoostDB-Percona-8.0.43-34.aarch64.rpm.  That build is Percona Server 8.0.43-34
# plus the Kunpeng patch set and CFGO feedback optimisation, and the vendor ships
# binaries only, so this case cannot pin a source commit the way the other
# optimized variants do: it pins the release tag, the package name and the
# sha256 of the published package, and records the package payload it actually
# unpacked.
#
# The payload is unpacked into the same private work directory the base variant
# uses (${MYSQL_BASE_DIR}), so the container command line, the mounts, the
# server arguments and the benchmark settings stay identical between the two
# variants; the measured difference is only which MySQL distribution runs.  This
# builder changes user space only -- it never writes OS or BIOS knobs (no
# sysctl, /proc/sys, /sys, CPU governor, THP, hugepage, tuned or BIOS/MSR
# changes), so the comparison against variant=base stays out-of-the-box.  It
# therefore:
#   1. refuses any architecture the vendor does not publish a package for
#   2. installs the host tools that unpack an rpm payload (rpm2cpio, cpio, xz)
#   3. fetches the package from the local artifact cache or the published URL
#   4. verifies the sha256 and the rpm NAME/VERSION/RELEASE/ARCH of the package
#   5. unpacks its payload into ${MYSQL_BASE_DIR}
#   6. verifies the unpacked server version and records its banner and binary
#      hash in the source record every later stage reads back
#   7. writes build_variant.json with the artifact provenance
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

set -euo pipefail

mysql_optimized_require_platform() {
    if [[ "${EXPECTED_ARCH}" != "${MYSQL_OPTIMIZED_ARCH}" ]]; then
        log_message "ERROR: ${MYSQL_OPTIMIZED_ARTIFACT} is published for ${MYSQL_OPTIMIZED_ARCH} only; there is no optimized MySQL package for ${EXPECTED_ARCH}"
        return 30
    fi
    if [[ "${SOFTWARE_VERSION}" != "${MYSQL_OPTIMIZED_VERSION}" ]]; then
        log_message "ERROR: the optimized MySQL package is ${MYSQL_OPTIMIZED_VERSION}-${MYSQL_OPTIMIZED_RELEASE_NUMBER}, this case builds ${SOFTWARE_VERSION}"
        return 30
    fi
}

mysql_optimized_require_tools() {
    local command_name package
    local packages=()

    for command_name in rpm rpm2cpio cpio xz sha256sum; do
        if command -v "${command_name}" >/dev/null 2>&1; then
            continue
        fi
        case "${command_name}" in
            rpm|rpm2cpio) package="rpm" ;;
            cpio) package="cpio" ;;
            xz) package="xz" ;;
            sha256sum) package="coreutils" ;;
        esac
        log_message "missing required optimized MySQL build command: ${command_name}"
        packages+=("${package}")
    done
    if [[ "${#packages[@]}" -eq 0 ]]; then
        return 0
    fi
    if ! command -v dnf >/dev/null 2>&1; then
        log_message "ERROR: dnf is required to install the tools that unpack ${MYSQL_OPTIMIZED_ARTIFACT}"
        return 30
    fi
    local dnf_options=()
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing packages needed to unpack ${MYSQL_OPTIMIZED_ARTIFACT}: ${packages[*]}"
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
    elif command -v sudo >/dev/null 2>&1; then
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || {
            log_message "ERROR: failed to install the packages that unpack ${MYSQL_OPTIMIZED_ARTIFACT}"
            return 30
        }
    else
        log_message "ERROR: sudo is required to install the packages that unpack ${MYSQL_OPTIMIZED_ARTIFACT}"
        return 30
    fi
    for command_name in rpm rpm2cpio cpio xz sha256sum; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            log_message "ERROR: required optimized MySQL build command remains unavailable: ${command_name}"
            return 30
        fi
    done
}

# Print the package path, preferring a pre-staged artifact over a download.
mysql_optimized_fetch_artifact() {
    local artifact_path
    local root

    for root in "/home/runner/software/mysql" "${PERF_WORK_DIR}"; do
        if [[ -s "${root}/${MYSQL_OPTIMIZED_ARTIFACT}" ]]; then
            log_message "using local optimized MySQL package ${root}/${MYSQL_OPTIMIZED_ARTIFACT}" >&2
            printf '%s\n' "${root}/${MYSQL_OPTIMIZED_ARTIFACT}"
            return 0
        fi
    done

    artifact_path="${PERF_WORK_DIR}/${MYSQL_OPTIMIZED_ARTIFACT}"
    log_message "downloading ${MYSQL_OPTIMIZED_URL}" >&2
    if command -v curl >/dev/null 2>&1; then
        if ! curl -fSL --retry 3 --connect-timeout 30 -o "${artifact_path}.part" "${MYSQL_OPTIMIZED_URL}"; then
            rm -f "${artifact_path}.part"
            log_message "ERROR: failed to download ${MYSQL_OPTIMIZED_ARTIFACT}; stage it in /home/runner/software/mysql or ${PERF_WORK_DIR}" >&2
            return 30
        fi
    elif ! wget -q -O "${artifact_path}.part" "${MYSQL_OPTIMIZED_URL}"; then
        rm -f "${artifact_path}.part"
        log_message "ERROR: failed to download ${MYSQL_OPTIMIZED_ARTIFACT}" >&2
        return 30
    fi
    mv -f "${artifact_path}.part" "${artifact_path}" || return 30
    printf '%s\n' "${artifact_path}"
}

mysql_optimized_verify_artifact() {
    local artifact_path="$1"
    local actual_sha actual_metadata expected_metadata

    if [[ ! -s "${artifact_path}" ]]; then
        log_message "ERROR: optimized MySQL package is missing: ${artifact_path}"
        return 30
    fi
    actual_sha="$(sha256sum "${artifact_path}" | awk '{print $1}')" || return 30
    if [[ "${actual_sha,,}" != "${MYSQL_OPTIMIZED_SHA256}" ]]; then
        log_message "ERROR: optimized MySQL package checksum mismatch: expected ${MYSQL_OPTIMIZED_SHA256}, got ${actual_sha}"
        if [[ "${artifact_path}" == "${PERF_WORK_DIR}/"* ]]; then
            rm -f "${artifact_path}"
        fi
        return 30
    fi
    actual_metadata="$(rpm -qp --qf '%{NAME} %{VERSION} %{RELEASE} %{ARCH}' "${artifact_path}" 2>/dev/null)" || {
        log_message "ERROR: cannot read the package metadata of ${artifact_path}"
        return 30
    }
    expected_metadata="BoostDB-Percona ${MYSQL_OPTIMIZED_VERSION} ${MYSQL_OPTIMIZED_RELEASE_NUMBER} ${MYSQL_OPTIMIZED_ARCH}"
    if [[ "${actual_metadata}" != "${expected_metadata}" ]]; then
        log_message "ERROR: optimized MySQL package is ${actual_metadata}, expected ${expected_metadata}"
        return 30
    fi
    log_message "verified ${MYSQL_OPTIMIZED_ARTIFACT} (sha256 ${actual_sha:0:12}..., ${actual_metadata})"
}

mysql_optimized_extract_payload() {
    local artifact_path="$1"
    local stage_dir="${PERF_WORK_DIR}/mysql-optimized-stage"
    local payload_dir="${stage_dir}/${MYSQL_OPTIMIZED_PAYLOAD_PREFIX}"

    rm -rf "${stage_dir}"
    mkdir -p "${stage_dir}" || return 30
    log_message "unpacking the ${MYSQL_OPTIMIZED_ARTIFACT} payload"
    if ! ( cd "${stage_dir}" && rpm2cpio "${artifact_path}" | cpio -idm --quiet ); then
        rm -rf "${stage_dir}"
        log_message "ERROR: failed to unpack the ${MYSQL_OPTIMIZED_ARTIFACT} payload"
        return 40
    fi
    if [[ ! -d "${payload_dir}" ]]; then
        rm -rf "${stage_dir}"
        log_message "ERROR: the optimized MySQL package does not carry ${MYSQL_OPTIMIZED_PAYLOAD_PREFIX}"
        return 40
    fi
    rm -rf "${MYSQL_BASE_DIR}"
    if ! mv "${payload_dir}" "${MYSQL_BASE_DIR}"; then
        rm -rf "${stage_dir}"
        log_message "ERROR: cannot move the optimized MySQL payload into ${MYSQL_BASE_DIR}"
        return 40
    fi
    rm -rf "${stage_dir}"
}

mysql_optimized_write_actual_version() {
    local version="$1"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${version}" > "${PERF_ACTUAL_VERSION_FILE}"
}

# The source record is the only provenance the later stages trust: it names the
# package, its checksum, the release and the exact mysqld binary that was
# unpacked from it.
mysql_optimized_write_source_record() {
    local artifact_sha="$1" banner="$2" mysqld_sha="$3"
    local record_tmp="${MYSQL_SOURCE_RECORD}.tmp"

    mkdir -p "$(dirname "${MYSQL_SOURCE_RECORD}")" || return 30
    {
        printf 'variant=optimized\n'
        printf 'artifact=%s\n' "${MYSQL_OPTIMIZED_ARTIFACT}"
        printf 'artifact_sha256=%s\n' "${artifact_sha}"
        printf 'artifact_version=%s\n' "${MYSQL_OPTIMIZED_VERSION}"
        printf 'artifact_release=%s\n' "${MYSQL_OPTIMIZED_RELEASE_NUMBER}"
        printf 'release=%s\n' "${MYSQL_OPTIMIZED_RELEASE}"
        printf 'architecture=%s\n' "${MYSQL_OPTIMIZED_ARCH}"
        printf 'source_url=%s\n' "${MYSQL_OPTIMIZED_URL}"
        printf 'install=unpacked-rpm-payload\n'
        printf 'payload_prefix=%s\n' "${MYSQL_OPTIMIZED_PAYLOAD_PREFIX}"
        printf 'mysqld_sha256=%s\n' "${mysqld_sha}"
        printf 'mysqld_banner=%s\n' "${banner}"
        printf 'run_id=%s\n' "${PERF_RUN_ID}"
        printf 'recorded_at=%s\n' "$(TZ=UTC date '+%Y-%m-%dT%H:%M:%SZ')"
    } > "${record_tmp}" || return 30
    mv -f "${record_tmp}" "${MYSQL_SOURCE_RECORD}" || return 30
}

mysql_optimized_write_build_variant() {
    local artifact_sha="$1" banner="$2" mysqld_sha="$3" artifact_path="$4"

    python3 - "${RESULTS_DIR}/build_variant.json" "${PERF_VARIANT}" "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" "${SOFTWARE_VERSION}" "${MYSQL_OPTIMIZED_RELEASE}" \
        "${MYSQL_OPTIMIZED_URL}" "${MYSQL_OPTIMIZED_ARTIFACT}" "${artifact_sha}" \
        "${MYSQL_OPTIMIZED_RELEASE_NUMBER}" "${banner}" "${mysqld_sha}" \
        "${artifact_path}" <<'PY'
import json
import sys
from pathlib import Path

if len(sys.argv) != 14:
    raise SystemExit(f"expected 13 arguments, got {len(sys.argv) - 1}")

(
    output,
    variant,
    architecture,
    run_id,
    software_version,
    release,
    source_url,
    artifact,
    artifact_sha256,
    release_number,
    banner,
    mysqld_sha256,
    installed_from,
) = sys.argv[1:]

payload = {
    "software": "mysql",
    "version": software_version,
    "variant": variant,
    "architecture": architecture,
    "run_id": run_id,
    "release": release,
    "artifact": {
        "kind": "rpm",
        "name": artifact,
        "release_number": release_number,
        "sha256": artifact_sha256,
        "source_url": source_url,
        "installed_from": installed_from,
        "install": "unpacked-rpm-payload",
    },
    "mysqld": {
        "sha256": mysqld_sha256,
        "banner": banner,
    },
    "parameters": {
        "variant": variant,
        "artifact": artifact,
        "artifact_sha256": artifact_sha256,
        "release": release,
        "release_number": release_number,
    },
}
Path(output).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
PY
}

build_mysql_optimized() {
    local artifact_path artifact_sha banner actual_version mysqld_sha

    initialize_runtime || return $?
    mysql_optimized_require_platform || return $?
    require_mysql_tools || return $?
    mysql_optimized_require_tools || return $?
    if [[ -e "${MYSQL_BASE_DIR}/bin/mysqld" ]]; then
        log_message "ERROR: build output is not clean under ${PERF_WORK_DIR}"
        return 20
    fi

    artifact_path="$(mysql_optimized_fetch_artifact)" || return $?
    mysql_optimized_verify_artifact "${artifact_path}" || return $?
    artifact_sha="$(sha256sum "${artifact_path}" | awk '{print $1}')" || return 30
    mysql_optimized_extract_payload "${artifact_path}" || return $?

    if [[ ! -x "${MYSQLD_BIN}" || ! -x "${MYSQL_BIN}" ]]; then
        log_message "ERROR: mysqld/mysql binaries not found after unpacking ${MYSQL_OPTIMIZED_ARTIFACT}"
        return 40
    fi
    if ldd "${MYSQLD_BIN}" 2>&1 | grep -Eq 'libaio[^[:space:]]*[[:space:]]+=>[[:space:]]+not found'; then
        log_message "ERROR: libaio runtime is missing; provision it on the dedicated runner before this workflow"
        return 40
    fi
    banner="$("${MYSQLD_BIN}" --version 2>/dev/null)" || {
        log_message "ERROR: the unpacked optimized mysqld cannot report its version"
        return 40
    }
    actual_version="$(sed -nE 's/.*Ver ([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' <<< "${banner}")"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: the unpacked mysqld is ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    mysqld_sha="$(sha256sum "${MYSQLD_BIN}" | awk '{print $1}')" || return 40
    mysql_optimized_write_actual_version "${actual_version}" || return 40
    mysql_optimized_write_source_record "${artifact_sha}" "${banner}" "${mysqld_sha}" || return 30
    mysql_optimized_write_build_variant \
        "${artifact_sha}" "${banner}" "${mysqld_sha}" "${artifact_path}" || return 30
    log_message "mysqld ${actual_version} deployed from ${MYSQL_OPTIMIZED_ARTIFACT} (release ${MYSQL_OPTIMIZED_RELEASE})"
    log_message "server banner: ${banner}"
}
