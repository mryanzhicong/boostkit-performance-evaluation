#!/usr/bin/env bash
# Build stage: pinned Node.js runtime, pinned TypeScript 7 compiler with its
# native backend, the deterministic project matrix and the final metadata.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

BUILD_LOG=""

require_commands() {
    local command
    for command in curl tar xz sha256sum python3 find; do
        if ! command -v "${command}" >/dev/null 2>&1; then
            log_message "ERROR: required command is missing: ${command}"
            return 30
        fi
    done
}

report_size() {
    local path="$1"
    if [[ -e "${path}" ]]; then
        printf '%s bytes\n' "$(stat -c%s "${path}")"
    else
        printf 'missing\n'
    fi
}

sha512_base64() {
    local path="$1"
    python3 - "${path}" <<'PY'
import base64
import hashlib
import sys
from pathlib import Path

digest = hashlib.sha512(Path(sys.argv[1]).read_bytes()).digest()
print(base64.b64encode(digest).decode())
PY
}

verify_checksum() {
    local label="$1" path="$2" expected_sha256="$3" expected_sha512="${4:-}"
    local actual_sha256
    actual_sha256="$(sha256sum "${path}" | cut -d' ' -f1)"
    if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
        log_message "ERROR: ${label} SHA-256 mismatch: expected ${expected_sha256}, got ${actual_sha256}"
        return 30
    fi
    if [[ -n "${expected_sha512}" ]]; then
        local actual_sha512
        actual_sha512="$(sha512_base64 "${path}")"
        if [[ "${actual_sha512}" != "${expected_sha512}" ]]; then
            log_message "ERROR: ${label} SHA-512 integrity mismatch"
            return 30
        fi
    fi
    log_message "verified ${label}: sha256=${actual_sha256}"
}

# materialize_asset LABEL SHA256 SHA512_BASE64 URL [URL...]
#
# Prefers a pre-placed asset in TS_OFFLINE_DIR (offline runners), otherwise
# downloads from the first reachable URL.  Every path is checksum verified, so a
# mirror cannot substitute different bytes.
materialize_asset() {
    local label="$1" expected_sha256="$2" expected_sha512="$3"
    shift 3
    local urls=("$@")
    local target="${PERF_WORK_DIR}/assets/${label}"
    local preplaced="${TS_OFFLINE_DIR}/${label}"
    mkdir -p "${PERF_WORK_DIR}/assets"
    if [[ -f "${preplaced}" ]]; then
        if verify_checksum "${label} (pre-placed)" "${preplaced}" "${expected_sha256}" "${expected_sha512}" 2>>"${BUILD_LOG}"; then
            cp -f "${preplaced}" "${target}"
            log_message "using pre-placed asset ${preplaced} ($(report_size "${target}"))"
            return 0
        fi
        log_message "WARNING: pre-placed ${label} failed verification; falling back to the network"
    fi
    local url
    for url in "${urls[@]}"; do
        log_message "downloading ${label} from ${url}"
        if curl -fsSL --retry 2 --connect-timeout 20 --max-time 600 -o "${target}.part" "${url}" 2>>"${BUILD_LOG}"; then
            mv -f "${target}.part" "${target}"
            if verify_checksum "${label}" "${target}" "${expected_sha256}" "${expected_sha512}" 2>>"${BUILD_LOG}"; then
                log_message "downloaded ${label} ($(report_size "${target}"))"
                return 0
            fi
            log_message "WARNING: ${label} from ${url} failed verification"
        else
            log_message "WARNING: could not download ${label} from ${url}"
        fi
    done
    log_message "ERROR: no verified copy of ${label} is available"
    return 30
}

install_node() {
    local archive="${PERF_WORK_DIR}/assets/${TARBALL_NAME}"
    materialize_asset "${TARBALL_NAME}" "${TARBALL_SHA256}" "" "${TARBALL_URLS[@]}" || return $?
    rm -rf "${NODE_HOME}"
    mkdir -p "${NODE_HOME}"
    tar -xJf "${archive}" -C "${NODE_HOME}" --strip-components=1 2>>"${BUILD_LOG}" || {
        log_message "ERROR: could not extract ${TARBALL_NAME}"
        return 30
    }
    [[ -x "${NODE_BIN}" ]] || {
        log_message "ERROR: the Node.js binary is missing after extraction: ${NODE_BIN}"
        return 30
    }
    local reported
    reported="$("${NODE_BIN}" --version)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js ${NODE_VERSION}, got ${reported}"
        return 30
    fi
    log_message "installed Node.js ${reported} from ${TARBALL_NAME}"
}

install_typescript() {
    local ts_archive="${PERF_WORK_DIR}/assets/${TS_TARBALL_NAME}"
    materialize_asset "${TS_TARBALL_NAME}" "${TS_TARBALL_SHA256}" "${TS_TARBALL_SHA512_B64}" \
        "${TS_REGISTRY}/typescript/-/${TS_TARBALL_NAME}" \
        "https://registry.npmjs.org/typescript/-/${TS_TARBALL_NAME}" || return $?
    local platform_archive="${PERF_WORK_DIR}/assets/${PLATFORM_TARBALL_NAME}"
    materialize_asset "${PLATFORM_TARBALL_NAME}" "${PLATFORM_SHA256}" "${PLATFORM_SHA512}" \
        "${PLATFORM_TARBALL_URL}" \
        "https://registry.npmjs.org/@typescript%2f${TS_PLATFORM_PACKAGE}/-/${PLATFORM_TARBALL_NAME}" || return $?
    rm -rf "${TS_HOME}"
    mkdir -p "${TS_HOME}/node_modules/typescript" "${TS_HOME}/node_modules/@typescript/${TS_PLATFORM_PACKAGE}"
    tar -xzf "${ts_archive}" -C "${TS_HOME}/node_modules/typescript" --strip-components=1 2>>"${BUILD_LOG}" || {
        log_message "ERROR: could not extract ${TS_TARBALL_NAME}"
        return 30
    }
    tar -xzf "${platform_archive}" -C "${TS_HOME}/node_modules/@typescript/${TS_PLATFORM_PACKAGE}" --strip-components=1 2>>"${BUILD_LOG}" || {
        log_message "ERROR: could not extract ${PLATFORM_TARBALL_NAME}"
        return 30
    }
    [[ -f "${TSC_JS}" ]] || {
        log_message "ERROR: the TypeScript launcher is missing: ${TSC_JS}"
        return 30
    }
    [[ -x "${TS_PLATFORM_DIR}/lib/tsc" ]] || {
        log_message "ERROR: the native compiler binary is missing: ${TS_PLATFORM_DIR}/lib/tsc"
        return 30
    }
    [[ -f "${TS_PLATFORM_DIR}/lib/lib.d.ts" ]] || {
        log_message "ERROR: the standard library declarations are missing"
        return 30
    }
    log_message "installed TypeScript ${SOFTWARE_VERSION} with native backend ${PLATFORM_NAME}"
}

check_node_engine_compatibility() {
    local engines="$1" node_semver="$2"
    python3 - "${engines}" "${node_semver}" <<'PY' 2>>"${BUILD_LOG}"
import re
import sys


def parse_version(text):
    match = re.match(r"^v?(\d+)(?:\.(\d+))?(?:\.(\d+))?", text.strip())
    if not match:
        raise SystemExit(f"cannot parse version: {text!r}")
    return tuple(int(part or 0) for part in match.groups())


def satisfy(version, comparator):
    comparator = comparator.strip()
    if comparator in {"", "*", "x"}:
        return True
    match = re.match(r"^(>=|<=|>|<|=|\^|~)?\s*(.+)$", comparator)
    if not match:
        return False
    operator = match.group(1) or "="
    target = parse_version(match.group(2))
    if operator == ">=":
        return version >= target
    if operator == ">":
        return version > target
    if operator == "<=":
        return version <= target
    if operator == "<":
        return version < target
    if operator == "=":
        return version == target
    if operator == "^":
        if target[0] > 0:
            return version >= target and version[0] == target[0]
        if target[1] > 0:
            return version >= target and version[:2] == target[:2]
        return version == target
    if operator == "~":
        return version >= target and version[:2] == target[:2]
    return False


engines = sys.argv[1]
version = parse_version(sys.argv[2])
for alternative in [chunk.strip() for chunk in engines.split("||") if chunk.strip()]:
    comparators = [part for part in re.split(r"\s+", alternative) if part]
    if all(satisfy(version, comparator) for comparator in comparators):
        print(f"Node.js {sys.argv[2]} satisfies the declared engine range {engines!r}")
        raise SystemExit(0)
raise SystemExit(
    f"Node.js {sys.argv[2]} does not satisfy the declared engine range {engines!r}"
)
PY
}

record_actual_version() {
    local reported
    reported="$("${TSC_WRAPPER}" --version 2>>"${BUILD_LOG}" | tail -n 1 | tr -d '[:space:]')"
    reported="${reported#Version}"
    if [[ -z "${reported}" ]]; then
        log_message "ERROR: the pinned compiler did not report its version"
        return 30
    fi
    if [[ "${reported}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested TypeScript ${SOFTWARE_VERSION} but the compiler reports ${reported}"
        return 30
    fi
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${reported}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "actual TypeScript version ${reported} recorded in ${PERF_ACTUAL_VERSION_FILE}"
}

generate_project_matrix() {
    rm -rf "${PROJECTS_DIR}" "${PERF_WORK_DIR}/project-templates"
    mkdir -p "${PROJECTS_DIR}" "${PERF_WORK_DIR}/project-templates"
    python3 "${SCRIPT_DIR}/scripts/fixtures/generate_projects.py" "${PROJECTS_DIR}" \
        --summary "${PROJECTS_SUMMARY}" >>"${BUILD_LOG}" 2>&1 || {
        log_message "ERROR: the deterministic project generator failed"
        return 30
    }
    local project
    for project in "${TS_PROJECTS[@]}"; do
        mkdir -p "${PERF_WORK_DIR}/project-templates/${project}"
        cp -a "${PROJECTS_DIR}/${project}/." "${PERF_WORK_DIR}/project-templates/${project}/"
    done
    log_message "generated the deterministic project matrix: ${TS_PROJECTS[*]}"
}

install_upstream_fixture() {
    local source="${SCRIPT_DIR}/fixtures/upstream"
    local target="${PROJECTS_DIR}/upstream"
    rm -rf "${target}"
    mkdir -p "${target}"
    cp -a "${source}/." "${target}/"
    ( cd "${source}" && sha256sum -c manifest.sha256 >/dev/null 2>&1 ) || {
        log_message "ERROR: the committed upstream fixture does not match its manifest"
        return 30
    }
    mkdir -p "${PERF_WORK_DIR}/project-templates/upstream"
    cp -a "${target}/." "${PERF_WORK_DIR}/project-templates/upstream/"
    log_message "installed the upstream fixture ${TS_UPSTREAM_NAME} ${TS_UPSTREAM_VERSION}"
}

verify_project_matrix() {
    python3 - "${SCRIPT_DIR}/fixtures/projects.json" "${PROJECTS_SUMMARY}" <<'PY' 2>>"${BUILD_LOG}"
import json
import sys
from pathlib import Path

committed = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
generated = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
expected = committed.get("projects", {})
actual = generated.get("projects", {})
if not expected:
    raise SystemExit("fixtures/projects.json has no project digests")
missing = sorted(set(expected) - set(actual))
if missing:
    raise SystemExit(f"generated projects are missing: {missing}")
for name, entry in sorted(expected.items()):
    if actual[name].get("digest") != entry.get("digest"):
        raise SystemExit(
            f"project {name} digest differs from the committed value: "
            f"{actual[name].get('digest')} != {entry.get('digest')}"
        )
    if actual[name].get("modules") != entry.get("modules"):
        raise SystemExit(f"project {name} module count differs from the committed value")
print(f"verified {len(expected)} generated projects against fixtures/projects.json")
PY
}

write_fixture_metadata() {
    python3 - "${FIXTURE_METADATA}" "${PROJECTS_SUMMARY}" "${SCRIPT_DIR}/fixtures/projects.json" <<'PY' 2>>"${BUILD_LOG}"
import hashlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

metadata_path = Path(sys.argv[1])
projects_summary = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
committed_path = Path(sys.argv[3])
committed = json.loads(committed_path.read_text(encoding="utf-8"))

scenario_table = {
    "check_small": {
        "project": "small",
        "fixture": "generated:small",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 100,
        "expected_files_min": 100,
        "expected_files_max": 220,
        "expected_check_time_min": 0.001,
        "expected_check_time_max": None,
        "required_artifacts": [],
    },
    "check_medium": {
        "project": "medium",
        "fixture": "generated:medium",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 1000,
        "expected_files_min": 1000,
        "expected_files_max": 1120,
        "expected_check_time_min": 0.001,
        "expected_check_time_max": None,
        "required_artifacts": [],
    },
    "check_large": {
        "project": "large",
        "fixture": "generated:large",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 5000,
        "expected_files_min": 5000,
        "expected_files_max": 5120,
        "expected_check_time_min": 0.001,
        "expected_check_time_max": None,
        "required_artifacts": [],
    },
    "check_upstream": {
        "project": "upstream",
        "fixture": "upstream:zod",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 13,
        "expected_files_min": 55,
        "expected_files_max": 120,
        "expected_check_time_min": 0.001,
        "expected_check_time_max": None,
        "required_artifacts": [],
    },
    "emit_medium": {
        "project": "emit",
        "fixture": "generated:emit",
        "command": "tsc -p tsconfig.json --extendedDiagnostics",
        "source_files": 1000,
        "expected_files_min": 1000,
        "expected_files_max": 1120,
        "expected_check_time_min": 0.001,
        "expected_check_time_max": None,
        "expected_emit_time_min": 0.001,
        "required_artifacts": [
            {"pattern": "dist/**/*.js", "min": 1000},
            {"pattern": "dist/**/*.d.ts", "min": 1000},
        ],
    },
    "incremental_warm_medium": {
        "project": "incremental",
        "fixture": "generated:incremental",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 1000,
        "expected_files_min": 1000,
        "expected_files_max": 1120,
        "expected_check_time_min": None,
        "expected_check_time_max": 0.010,
        "required_artifacts": [{"pattern": ".tsbuildinfo", "min": 1}],
    },
    "incremental_change_medium": {
        "project": "incremental",
        "fixture": "generated:incremental",
        "command": "tsc --noEmit -p tsconfig.json --extendedDiagnostics",
        "source_files": 1000,
        "expected_files_min": 1000,
        "expected_files_max": 1120,
        "expected_check_time_min": 0.020,
        "expected_check_time_max": None,
        "required_artifacts": [{"pattern": ".tsbuildinfo", "min": 1}],
    },
    "references_build": {
        "project": "references",
        "fixture": "generated:references",
        "command": "tsc --build --verbose",
        "source_files": 500,
        "expected_files_min": None,
        "expected_files_max": None,
        "expected_check_time_min": None,
        "expected_check_time_max": None,
        "required_build_lines": 2,
        "required_artifacts": [
            {"pattern": "packages/**/*.tsbuildinfo", "min": 2},
            {"pattern": "packages/lib/dist/**/*.js", "min": 200},
        ],
    },
}

upstream_manifest = committed_path.resolve().parent / "upstream" / "manifest.sha256"
upstream_manifest_sha256 = (
    hashlib.sha256(upstream_manifest.read_bytes()).hexdigest()
    if upstream_manifest.is_file()
    else "missing"
)

metadata = {
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "typescript_version": os.environ.get("SOFTWARE_VERSION", ""),
    "node_version": os.environ.get("NODE_VERSION", ""),
    "node_semver": os.environ.get("NODE_SEMVER", ""),
    "typescript_engines_node": os.environ.get("TS_NODE_ENGINES", ""),
    "native_backend": os.environ.get("PLATFORM_NAME", ""),
    "registry": os.environ.get("TS_REGISTRY", ""),
    "tarballs": {
        "typescript": {
            "sha256": os.environ.get("TS_TARBALL_SHA256", ""),
            "sha512_integrity": os.environ.get("TS_TARBALL_SHA512_B64", ""),
        },
        "native_backend": {
            "url": os.environ.get("PLATFORM_TARBALL_URL", ""),
            "sha256": os.environ.get("PLATFORM_SHA256", ""),
            "sha512_integrity": os.environ.get("PLATFORM_SHA512", ""),
        },
    },
    "projects": projects_summary.get("projects", {}),
    "upstream_project": {
        "name": os.environ.get("TS_UPSTREAM_NAME", ""),
        "version": os.environ.get("TS_UPSTREAM_VERSION", ""),
        "source": os.environ.get("TS_UPSTREAM_URL", ""),
        "tarball_sha256": os.environ.get("TS_UPSTREAM_TARBALL_SHA256", ""),
        "manifest_sha256": upstream_manifest_sha256,
        "modules": 13,
    },
    "measurement": {
        "warmups": 1,
        "repetitions": int(os.environ.get("TS_REPS", "5")),
        "statistic": "median of independent repetitions",
        "network": "disabled for every measured run (closed proxy, no package manager involved)",
    },
    "scenarios": scenario_table,
}

metadata_path.parent.mkdir(parents=True, exist_ok=True)
metadata_path.write_text(
    json.dumps(metadata, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
print(f"wrote fixture metadata with {len(scenario_table)} scenarios")
PY
}

build_typescript_base() {
    initialize_runtime || return $?
    BUILD_LOG="${BUILD_LOGS_DIR}/build.log"
    mkdir -p "${BUILD_LOGS_DIR}"
    write_tsc_wrapper
    log_message "starting the TypeScript build: ${SOFTWARE_VERSION} on ${EXPECTED_ARCH}"
    require_commands || return $?
    install_node || return $?
    install_typescript || return $?
    check_node_engine_compatibility "${TS_NODE_ENGINES}" "${NODE_SEMVER}" || {
        log_message "ERROR: the pinned Node.js runtime does not satisfy the declared engine range"
        return 30
    }
    record_actual_version || return $?
    generate_project_matrix || return $?
    verify_project_matrix || return $?
    install_upstream_fixture || return $?
    write_fixture_metadata || return $?
    log_message "base build completed: TypeScript ${SOFTWARE_VERSION}, Node.js ${NODE_VERSION}"
}
