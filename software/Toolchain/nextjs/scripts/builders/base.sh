#!/usr/bin/env bash
# Build stage of the Next.js performance case.
#
# Every input of the measurement is pinned here: the Node.js runtime archive, the
# Next.js release tarball (SHA-256 and the registry published SHA-512), the
# committed dependency manifest and lockfile, the deterministic project matrix and
# the upstream fixture.  Any mismatch fails the build (exit code 30) instead of
# silently measuring a different workload.

set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_commands() {
    local required=(tar xz sha256sum python3 find curl openssl)
    local missing=()
    local command_name
    for command_name in "${required[@]}"; do
        if ! command -v "${command_name}" >/dev/null 2>&1; then
            missing+=("${command_name}")
        fi
    done
    if [[ "${#missing[@]}" -gt 0 ]]; then
        fail_message "missing required commands: ${missing[*]}"
        return 30
    fi
    return 0
}

verify_sha256() {
    local path="$1"
    local expected="$2"
    local actual
    actual="$(sha256sum "${path}" | cut -d' ' -f1)"
    if [[ "${actual}" != "${expected}" ]]; then
        fail_message "SHA-256 mismatch for ${path}: expected ${expected}, got ${actual}"
        return 30
    fi
    return 0
}

verify_sha512_b64() {
    local path="$1"
    local expected="$2"
    [[ -z "${expected}" ]] && return 0
    local actual
    actual="$(openssl dgst -sha512 -binary "${path}" | openssl base64 -A)"
    if [[ "${actual}" != "${expected}" ]]; then
        fail_message "SHA-512 mismatch for ${path}: expected ${expected}, got ${actual}"
        return 30
    fi
    return 0
}

# Resolve a pinned archive: prefer the pre-placed offline copy, fall back to the
# documented download locations, always verify the checksum before using it.
materialize_asset() {
    local label="$1"
    local destination="$2"
    local sha256="$3"
    local sha512="$4"
    shift 4
    local url

    if [[ -f "${destination}" ]]; then
        if verify_sha256 "${destination}" "${sha256}" && \
            verify_sha512_b64 "${destination}" "${sha512}"; then
            log_message "verified ${label} already present at ${destination}"
            return 0
        fi
        fail_message "existing ${label} failed verification: ${destination}"
        return 30
    fi

    local directory
    directory="$(dirname "${destination}")"
    mkdir -p "${directory}" || return 30
    local temporary="${destination}.partial"
    for url in "$@"; do
        rm -f "${temporary}"
        if [[ -f "${url}" ]]; then
            log_message "copying ${label} from the pre-placed asset ${url}"
            if ! cp -f "${url}" "${temporary}"; then
                log_message "copy failed, trying the next mirror"
                continue
            fi
        else
            log_message "downloading ${label} from ${url}"
            if ! curl -g -fsSL --retry 3 --retry-delay 2 -m 1800 -o "${temporary}" "${url}"; then
                log_message "download failed, trying the next mirror"
                continue
            fi
        fi
        if verify_sha256 "${temporary}" "${sha256}" && \
            verify_sha512_b64 "${temporary}" "${sha512}"; then
            mv "${temporary}" "${destination}"
            log_message "verified and stored ${label} at ${destination}"
            return 0
        fi
        fail_message "downloaded ${label} from ${url} failed verification"
        rm -f "${temporary}"
    done
    fail_message "no verified copy of ${label} could be obtained"
    return 30
}

install_node() {
    local archive="${PERF_WORK_DIR}/assets/${NODE_TARBALL_NAME}"
    materialize_asset "Node.js ${NODE_VERSION} (${NODE_PLATFORM})" "${archive}" \
        "${NODE_SHA256}" "" "${NODE_TARBALL_URLS[@]}" || return $?
    rm -rf -- "${NODE_INSTALL_DIR}"
    mkdir -p "${NODE_INSTALL_DIR}" || return 30
    if ! tar -xJf "${archive}" -C "${NODE_INSTALL_DIR}" --strip-components=1; then
        fail_message "failed to extract ${NODE_TARBALL_NAME}"
        return 30
    fi
    local reported
    reported="$("${NODE_BIN}" --version 2>/dev/null || true)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        fail_message "the pinned Node.js runtime reports ${reported}, expected ${NODE_VERSION}"
        return 30
    fi
    if [[ ! -f "${NPM_CLI}" ]]; then
        fail_message "the Node.js archive does not contain npm at ${NPM_CLI}"
        return 30
    fi
    log_message "installed Node.js ${reported} from ${NODE_TARBALL_NAME}"
    return 0
}

check_node_engine_compatibility() {
    local reported
    reported="$("${NODE_BIN}" --version 2>/dev/null | sed 's/^v//')"
    python3 - "${reported}" "${NEXT_NODE_ENGINES}" <<'PY'
import re
import sys

version = tuple(int(part) for part in sys.argv[1].split("."))
requirements = sys.argv[2]


def check(requirement: str) -> bool:
    requirement = requirement.strip()
    if not requirement:
        return True
    match = re.match(r"^(>=|<=|>|<|=|\^|~)?\s*v?([0-9]+(?:\.[0-9]+)*)$", requirement)
    if not match:
        raise SystemExit(f"unsupported version requirement: {requirement}")
    operator = match.group(1) or "="
    target = tuple(int(part) for part in match.group(2).split("."))
    padded = target + (0,) * (3 - len(target))
    if operator == ">=":
        return version >= padded
    if operator == "<=":
        return version <= padded
    if operator == ">":
        return version > padded
    if operator == "<":
        return version < padded
    if operator == "=":
        return version == padded
    if operator == "^":
        return version >= padded and version[0] == padded[0]
    if operator == "~":
        return version >= padded and version[:2] == padded[:2]
    raise SystemExit(f"unsupported operator in requirement: {requirement}")


if not any(check(part) for part in requirements.split("||")):
    raise SystemExit(
        f"Node.js {sys.argv[1]} does not satisfy the Next.js engines.node range {requirements!r}"
    )
print(f"Node.js {sys.argv[1]} satisfies the declared engine range {requirements!r}")
PY
    if [[ "$?" -ne 0 ]]; then
        fail_message "the pinned Node.js runtime does not satisfy the Next.js engine requirement"
        return 30
    fi
    return 0
}

verify_fixtures() {
    python3 "${CASE_DIR}/scripts/fixtures/verify_fixtures.py" --case-dir "${CASE_DIR}" || {
        fail_message "the committed case fixtures are inconsistent"
        return 30
    }
    return 0
}

install_dependencies() {
    local fixture_dir="${CASE_DIR}/fixtures/dependencies"
    local manifest="${PERF_WORK_DIR}/package.json"
    local lockfile="${PERF_WORK_DIR}/package-lock.json"
    cp -f "${fixture_dir}/package.json" "${manifest}" || return 30
    cp -f "${fixture_dir}/package-lock.json" "${lockfile}" || return 30
    verify_sha256 "${manifest}" "${NEXT_DEPENDENCY_MANIFEST_SHA256}" || return $?
    verify_sha256 "${lockfile}" "${NEXT_DEPENDENCY_LOCKFILE_SHA256}" || return $?

    # The registry publishes the SHA-512 of the release tarball and the committed
    # lockfile carries it as the integrity value; verifying it proves that npm
    # installed exactly the pinned Next.js release without downloading it twice.
    python3 - "${lockfile}" "${NEXT_TARBALL_SHA512_B64}" <<'PY'
import json
import sys
from pathlib import Path

lockfile = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
expected = f"sha512-{sys.argv[2]}"
entry = lockfile.get("packages", {}).get("node_modules/next", {})
integrity = entry.get("integrity", "")
if integrity != expected:
    raise SystemExit(
        f"the lockfile pins Next.js with integrity {integrity!r}, expected {expected!r}"
    )
resolved = entry.get("resolved", "")
print(f"lockfile pins Next.js with the published integrity {integrity} ({resolved})")
PY
    if [[ "$?" -ne 0 ]]; then
        fail_message "the committed lockfile does not pin the expected Next.js tarball"
        return 30
    fi

    rm -rf -- "${NODE_MODULES_DIR}"
    export npm_config_cache="${NPM_CACHE_DIR}"
    export npm_config_registry="${NPM_REGISTRY}"
    export npm_config_audit=false
    export npm_config_fund=false
    export npm_config_update_notifier=false
    export HOME="${NEXT_PRIVATE_HOME}"
    log_message "installing the pinned dependency tree with the bundled npm (network allowed once)"
    if ! ( cd "${PERF_WORK_DIR}" && "${NODE_BIN}" "${NPM_CLI}" ci --no-audit --no-fund \
        --loglevel=error ); then
        fail_message "npm ci failed"
        return 30
    fi

    verify_installed_dependencies || return $?

    log_message "verifying that the dependency tree can be re-installed offline"
    local scratch="${PERF_WORK_DIR}/offline-verify"
    rm -rf -- "${scratch}"
    mkdir -p "${scratch}" || return 30
    cp -f "${manifest}" "${scratch}/package.json" || return 30
    cp -f "${lockfile}" "${scratch}/package-lock.json" || return 30
    if ! ( cd "${scratch}" && HTTP_PROXY=http://127.0.0.1:9 HTTPS_PROXY=http://127.0.0.1:9 \
        http_proxy=http://127.0.0.1:9 https_proxy=http://127.0.0.1:9 \
        "${NODE_BIN}" "${NPM_CLI}" ci --offline --no-audit --no-fund --loglevel=error ); then
        fail_message "the dependency tree cannot be installed offline from the private cache"
        return 30
    fi
    rm -rf -- "${scratch}"
    log_message "offline re-install of the dependency tree verified"
    return 0
}

verify_installed_dependencies() {
    local next_version react_version react_dom_version npm_version
    next_version="$("${NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${NEXT_INSTALL_DIR}/package.json" 2>/dev/null)"
    react_version="$("${NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${NODE_MODULES_DIR}/react/package.json" 2>/dev/null)"
    react_dom_version="$("${NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${NODE_MODULES_DIR}/react-dom/package.json" 2>/dev/null)"
    npm_version="$("${NODE_BIN}" "${NPM_CLI}" --version 2>/dev/null)"
    if [[ "${next_version}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "installed Next.js reports ${next_version}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    if [[ "${react_version}" != "${REACT_VERSION}" || "${react_dom_version}" != "${REACT_DOM_VERSION}" ]]; then
        fail_message "installed React ${react_version}/${react_dom_version} differs from the pinned versions"
        return 30
    fi
    if [[ ! -x "${NEXT_BIN}" ]]; then
        fail_message "the installed Next.js has no executable at ${NEXT_BIN}"
        return 30
    fi
    if [[ ! -d "${NODE_MODULES_DIR}/${SWC_PACKAGE}" ]]; then
        fail_message "the native Next.js backend ${SWC_PACKAGE} was not installed"
        return 30
    fi
    NEXT_NPM_VERSION="${npm_version}"
    export NEXT_NPM_VERSION
    log_message "installed Next.js ${next_version}, React ${react_version}, native backend ${SWC_PACKAGE}, npm ${npm_version}"
    return 0
}

record_actual_version() {
    local reported
    reported="$("${NODE_BIN}" "${NEXT_BIN}" --version 2>/dev/null | head -1 | tr -d '\r')"
    local parsed
    parsed="$(printf '%s' "${reported}" | sed -E 's/^[^0-9]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
    if [[ "${parsed}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "the compiler reports version '${parsed}' (raw: '${reported}'), expected ${SOFTWARE_VERSION}"
        return 30
    fi
    printf '%s\n' "${parsed}" > "${PERF_ACTUAL_VERSION_FILE}" || {
        fail_message "failed to write ${PERF_ACTUAL_VERSION_FILE}"
        return 30
    }
    log_message "actual Next.js version ${parsed} recorded in ${PERF_ACTUAL_VERSION_FILE}"
    return 0
}

generate_project_matrix() {
    local summary="${PERF_WORK_DIR}/projects-generated.json"
    rm -rf -- "${PROJECTS_DIR}" "${TEMPLATES_DIR}"
    mkdir -p "${PROJECTS_DIR}" "${TEMPLATES_DIR}" || return 30
    log_message "generating the deterministic project matrix (untimed)"
    python3 "${CASE_DIR}/scripts/fixtures/generate_projects.py" \
        --output "${PROJECTS_DIR}" --summary "${summary}" || {
        fail_message "the project generator failed"
        return 30
    }
    local project
    for project in "${NEXT_GENERATED_PROJECTS[@]}"; do
        if [[ ! -d "${PROJECTS_DIR}/${project}" ]]; then
            fail_message "the generator did not produce ${project}"
            return 30
        fi
        rm -rf -- "${TEMPLATES_DIR}/${project}"
        cp -a "${PROJECTS_DIR}/${project}" "${TEMPLATES_DIR}/${project}" || return 30
    done
    verify_project_matrix "${summary}" || return $?
    return 0
}

verify_project_matrix() {
    local summary="$1"
    python3 - "${CASE_DIR}/fixtures/projects.json" "${summary}" <<'PY'
import json
import sys
from pathlib import Path

expected = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))["projects"]
actual = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))["projects"]
if set(expected) != set(actual):
    raise SystemExit(f"generated projects {sorted(actual)} differ from fixtures {sorted(expected)}")
for name, entry in expected.items():
    if actual[name]["digest"] != entry["digest"]:
        raise SystemExit(f"generated project {name} has digest {actual[name]['digest']}, expected {entry['digest']}")
    if int(actual[name]["source_files"]) != int(entry["source_files"]):
        raise SystemExit(f"generated project {name} has an unexpected source file count")
print(f"verified {len(expected)} generated projects against fixtures/projects.json")
PY
    if [[ "$?" -ne 0 ]]; then
        fail_message "the generated project matrix is not the committed one"
        return 30
    fi
    return 0
}

install_upstream_fixture() {
    local source="${CASE_DIR}/fixtures/upstream"
    local target="${TEMPLATES_DIR}/upstream"
    if [[ ! -f "${source}/manifest.sha256" ]]; then
        fail_message "the upstream fixture has no manifest.sha256"
        return 30
    fi
    ( cd "${source}" && sha256sum -c --quiet manifest.sha256 ) || {
        fail_message "the upstream fixture failed its manifest verification"
        return 30
    }
    rm -rf -- "${target}"
    mkdir -p "${target}" || return 30
    if ! cp -a "${source}/." "${target}/"; then
        fail_message "failed to copy the upstream fixture"
        return 30
    fi
    rm -f "${target}/manifest.sha256"
    cp -a "${target}" "${PROJECTS_DIR}/upstream" || return 30
    log_message "installed the upstream fixture $(grep -m1 'project' "${source}/ref.txt" || true)"
    return 0
}

write_fixture_metadata() {
    python3 - "${PERF_WORK_DIR}" "${CASE_DIR}" <<'PY'
import json
import os
import sys
from pathlib import Path

workdir = Path(sys.argv[1])
case_dir = Path(sys.argv[2])
generated = json.loads((workdir / "projects-generated.json").read_text(encoding="utf-8"))
projects = generated["projects"]

def source_files(project: str) -> int:
    root = workdir / "project-templates" / project
    suffixes = {".js", ".jsx", ".ts", ".tsx", ".mjs", ".json"}
    return sum(
        1
        for path in root.rglob("*")
        if path.is_file()
        and path.suffix in suffixes
        and path.name != "next-env.d.ts"
        and "node_modules" not in path.parts
        and ".next" not in path.parts
    )

upstream_files = sum(
    1
    for path in (workdir / "project-templates" / "upstream").rglob("*")
    if path.is_file()
)
upstream_sources = source_files("upstream")

scenarios = {
    "build_static_1000": {
        "kind": "build",
        "project": "static_1000",
        "command": "next build",
        "expected_html_pages": 1005,
        "expected_source_files": source_files("static_1000"),
        "cold": True,
    },
    "build_static_3000": {
        "kind": "build",
        "project": "static_3000",
        "command": "next build",
        "expected_html_pages": 3005,
        "expected_source_files": source_files("static_3000"),
        "cold": True,
    },
    "build_dynamic_500": {
        "kind": "build",
        "project": "dynamic_500",
        "command": "next build",
        "expected_html_pages": 5,
        "expected_source_files": source_files("dynamic_500"),
        "cold": True,
        "expected_dynamic_routes": 1,
    },
    "build_routes_500": {
        "kind": "build",
        "project": "routes_500",
        "command": "next build",
        "expected_html_pages": 505,
        "expected_source_files": source_files("routes_500"),
        "cold": True,
    },
    "build_incremental_1000": {
        "kind": "build",
        "project": "static_1000",
        "command": "next build (warm .next/cache)",
        "expected_html_pages": 1005,
        "expected_source_files": source_files("static_1000"),
        "cold": False,
        "incremental": True,
    },
    "build_upstream": {
        "kind": "build",
        "project": "upstream",
        "command": "next build",
        "expected_html_pages": 9,
        "expected_source_files": upstream_sources,
        "cold": True,
        "expected_dynamic_routes": 1,
    },
    "serve_startup_1000": {
        "kind": "http",
        "project": "static_1000",
        "command": "next start + first loopback GET / (startup latency)",
        "mode": "startup",
        "path": "/",
        "expect": "fixture",
        "requests": 0,
        "expected_html_pages": 1005,
        "expected_source_files": source_files("static_1000"),
    },
    "serve_get_100_static": {
        "kind": "http",
        "project": "static_1000",
        "command": "next start + 100 serial loopback GET /items/item-999",
        "mode": "latency",
        "path": "/items/item-999",
        "expect": "item-999",
        "requests": 100,
        "expected_html_pages": 1005,
        "expected_source_files": source_files("static_1000"),
    },
    "serve_get_100_dynamic": {
        "kind": "http",
        "project": "dynamic_500",
        "command": "next start + 100 serial loopback GET /dyn/item-42",
        "mode": "latency",
        "path": "/dyn/item-42",
        "expect": "item-42",
        "requests": 100,
        "expected_html_pages": 5,
        "expected_source_files": source_files("dynamic_500"),
    },
}

metadata = {
    "software": "nextjs",
    "version": os.environ["SOFTWARE_VERSION"],
    "next_version": os.environ["SOFTWARE_VERSION"],
    "next_package": "next",
    "next_engines_node": os.environ["NEXT_NODE_ENGINES"],
    "react_version": os.environ["REACT_VERSION"],
    "react_dom_version": os.environ["REACT_DOM_VERSION"],
    "typescript_version": os.environ["TYPESCRIPT_VERSION"],
    "types_node_version": os.environ["TYPES_NODE_VERSION"],
    "types_react_version": os.environ["TYPES_REACT_VERSION"],
    "types_react_dom_version": os.environ["TYPES_REACT_DOM_VERSION"],
    "node_version": os.environ["NODE_SEMVER"],
    "node_distribution_tag": os.environ["NODE_VERSION"],
    "npm_version": os.environ.get("NEXT_NPM_VERSION", "unknown"),
    "registry": os.environ["NPM_REGISTRY"],
    "native_backend_package": os.environ["SWC_PACKAGE"],
    "next_tarball_sha256": os.environ["NEXT_TARBALL_SHA256"],
    "next_tarball_sha512_integrity": os.environ["NEXT_TARBALL_SHA512_B64"],
    "dependency_manifest_sha256": os.environ["NEXT_DEPENDENCY_MANIFEST_SHA256"],
    "dependency_lockfile_sha256": os.environ["NEXT_DEPENDENCY_LOCKFILE_SHA256"],
    "offline_install_verified": True,
    "telemetry_disabled": True,
    "build_workers": int(os.environ["NEXT_BUILD_WORKERS"]),
    "projects": projects,
    "upstream": {
        "project": "vercel/next.js examples/with-typescript",
        "tag": "v" + os.environ["SOFTWARE_VERSION"],
        "files": upstream_files,
        "source_files": upstream_sources,
        "manifest_sha256": __import__("hashlib").sha256(
            (case_dir / "fixtures" / "upstream" / "manifest.sha256").read_bytes()
        ).hexdigest(),
    },
    "measurement": {
        "repetitions": int(os.environ["NEXT_REPS"]),
        "warmups": int(os.environ["NEXT_WARMUPS"]),
        "http_requests": int(os.environ["NEXT_HTTP_REQUESTS"]),
        "http_host": os.environ["NEXT_HTTP_HOST"],
        "http_port": int(os.environ["NEXT_HTTP_PORT"]),
    },
    "scenarios": scenarios,
}
target = workdir / "fixtures-metadata.json"
target.write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")
print(f"wrote fixture metadata with {len(scenarios)} scenarios")
PY
    if [[ "$?" -ne 0 ]]; then
        fail_message "failed to write the fixture metadata"
        return 30
    fi
    return 0
}

build_nextjs_base() {
    initialize_runtime || return $?
    require_commands || return $?
    verify_fixtures || return $?
    install_node || return $?
    check_node_engine_compatibility || return $?
    install_dependencies || return $?
    record_actual_version || return $?
    generate_project_matrix || return $?
    install_upstream_fixture || return $?
    write_fixture_metadata || return $?
    log_message "base build completed: Next.js ${SOFTWARE_VERSION}, React ${REACT_VERSION}, Node.js ${NODE_VERSION}"
    return 0
}
