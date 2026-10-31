#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

package_for_command() {
    case "$1" in
        awk) printf 'gawk\n' ;;
        sha256sum|basename|dirname|nproc|stat|cp|mv|rm) printf 'coreutils\n' ;;
        python3) printf 'python3\n' ;;
        xz) printf 'xz\n' ;;
        *) printf '%s\n' "$1" ;;
    esac
}

require_commands() {
    local missing=() packages=() cmd
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    (( ${#missing[@]} == 0 )) && return 0
    log_message "missing commands: ${missing[*]}"
    if command -v dnf >/dev/null 2>&1; then
        for cmd in "${missing[@]}"; do
            packages+=("$(package_for_command "${cmd}")")
        done
        local dnf_options=()
        [[ -n "${PERF_PROXY:-}" ]] && dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    for cmd in "${missing[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            log_message "ERROR: required command is still unavailable: ${cmd}"
            return 30
        fi
    done
}

verify_checksum() {
    local file="$1" algorithm="$2" expected="$3" actual
    case "${algorithm}" in
        sha256)
            actual="$(sha256sum "${file}" | awk '{print $1}')"
            ;;
        sha512-base64)
            actual="$(python3 -c 'import base64, hashlib, sys
digest = hashlib.sha512()
with open(sys.argv[1], "rb") as handle:
    for chunk in iter(lambda: handle.read(1 << 20), b""):
        digest.update(chunk)
print(base64.b64encode(digest.digest()).decode())' "${file}")"
            ;;
        *)
            log_message "ERROR: unsupported checksum algorithm: ${algorithm}"
            return 30
            ;;
    esac
    if [[ "${actual}" != "${expected}" ]]; then
        log_message "ERROR: ${algorithm} mismatch for ${file}"
        log_message "  expected: ${expected}"
        log_message "  actual:   ${actual}"
        return 30
    fi
    log_message "verified ${algorithm} $(basename "${file}")"
}

# Prefer the pre-placed offline copy, otherwise download from the first working
# source.  Every path ends in the pinned checksum, so a compromised or partial
# mirror cannot silently replace the artifact.
materialize_asset() {
    local name="$1" algorithm="$2" expected="$3" destination="$4"
    shift 4
    local offline="${NPM_OFFLINE_DIR}/${name}"
    local url ok=0
    mkdir -p "$(dirname "${destination}")" "${NPM_OFFLINE_DIR}"
    if [[ -f "${destination}" ]]; then
        if verify_checksum "${destination}" "${algorithm}" "${expected}" 2>/dev/null; then
            log_message "reusing verified asset: ${destination}"
            return 0
        fi
        log_message "discarding corrupted cached asset: ${destination}"
        rm -f -- "${destination}"
    fi
    if [[ -f "${offline}" ]]; then
        log_message "using pre-placed offline asset: ${offline}"
        cp -- "${offline}" "${destination}"
        verify_checksum "${destination}" "${algorithm}" "${expected}"
        return $?
    fi
    for url in "$@"; do
        log_message "downloading ${url}"
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 30 \
            -o "${destination}.part" "${url}"; then
            mv -- "${destination}.part" "${destination}"
            ok=1
            break
        fi
        log_message "WARNING: download source failed, trying the next one: ${url}"
        rm -f -- "${destination}.part"
    done
    if (( ok == 0 )); then
        log_message "ERROR: every download source failed for ${name}"
        log_message "HINT: pre-place ${name} in ${NPM_OFFLINE_DIR} or restore network access"
        return 30
    fi
    verify_checksum "${destination}" "${algorithm}" "${expected}"
}

install_node() {
    if [[ -x "${NODE_BIN}" ]]; then
        local installed
        installed="$("${NODE_BIN}" --version 2>/dev/null || true)"
        if [[ "${installed}" == "${NODE_VERSION}" ]]; then
            log_message "reusing Node.js ${installed} at ${NODE_HOME}"
            return 0
        fi
        log_message "removing unexpected Node.js ${installed} at ${NODE_HOME}"
        rm -rf -- "${NODE_HOME}"
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${TARBALL_NAME}"
    materialize_asset "${TARBALL_NAME}" sha256 "${TARBALL_SHA256}" "${tarball}" \
        "${TARBALL_URLS[@]}" || return $?
    mkdir -p "${NODE_HOME}"
    log_message "extracting Node.js ${NODE_VERSION} to ${NODE_HOME}"
    tar -xJf "${tarball}" -C "${NODE_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the Node.js archive"
        return 30
    }
    [[ -x "${NODE_BIN}" ]] || {
        log_message "ERROR: extracted Node.js archive does not contain bin/node"
        return 30
    }
    local installed
    installed="$("${NODE_BIN}" --version)"
    if [[ "${installed}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: requested Node.js ${NODE_VERSION} but extracted ${installed}"
        return 30
    fi
}

install_npm() {
    if [[ -f "${NPM_CLI_JS}" ]]; then
        local installed
        installed="$("${NODE_BIN}" "${NPM_CLI_JS}" --version 2>/dev/null || true)"
        if [[ "${installed}" == "${SOFTWARE_VERSION}" ]]; then
            log_message "reusing npm ${installed} at ${NPM_HOME}"
            return 0
        fi
        log_message "removing unexpected npm ${installed} at ${NPM_HOME}"
        rm -rf -- "${NPM_HOME}"
    fi
    local tarball="${PERF_WORK_DIR}/downloads/${NPM_TARBALL_NAME}"
    materialize_asset "${NPM_TARBALL_NAME}" sha256 "${NPM_TARBALL_SHA256}" "${tarball}" \
        "${NPM_TARBALL_MIRROR_URL}" "${NPM_TARBALL_OFFICIAL_URL}" || return $?
    verify_checksum "${tarball}" sha512-base64 "${NPM_TARBALL_SHA512_B64}" || {
        log_message "ERROR: npm tarball does not match the registry-published integrity"
        return 30
    }
    mkdir -p "${NPM_HOME}"
    log_message "extracting ${NPM_TARBALL_NAME} to ${NPM_HOME}"
    tar -xzf "${tarball}" -C "${NPM_HOME}" --strip-components=1 || {
        log_message "ERROR: failed to extract the npm archive"
        return 30
    }
    [[ -f "${NPM_CLI_JS}" ]] || {
        log_message "ERROR: extracted npm archive does not contain bin/npm-cli.js"
        return 30
    }
    chmod +x "${NPM_CLI_JS}" 2>/dev/null || true
    local installed
    installed="$("${NODE_BIN}" "${NPM_CLI_JS}" --version 2>&1)" || {
        log_message "ERROR: npm did not start on the pinned Node.js runtime"
        printf '%s\n' "${installed}" >&2
        return 40
    }
    if [[ "${installed}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested npm ${SOFTWARE_VERSION} but installed ${installed}"
        return 40
    fi
}

check_node_engine_compatibility() {
    python3 - "${NODE_SEMVER}" "${NPM_HOME}/package.json" <<'PY'
import json
import sys


def parse(version):
    parts = []
    for piece in version.split("."):
        digits = "".join(character for character in piece if character.isdigit())
        parts.append(int(digits) if digits else 0)
    return tuple(parts[:3])


def satisfies(version, spec):
    for alternative in spec.split("||"):
        alternative = alternative.strip()
        if not alternative:
            continue
        if alternative.startswith("^"):
            base = parse(alternative[1:])
            if version[0] == base[0] and version >= base:
                return True
        elif alternative.startswith(">="):
            if version >= parse(alternative[2:]):
                return True
        elif alternative == "*":
            return True
    return False


node = parse(sys.argv[1])
with open(sys.argv[2], encoding="utf-8") as handle:
    package = json.load(handle)
spec = package.get("engines", {}).get("node", "")
if not spec:
    print("[npm] ERROR: the npm package manifest declares no engines.node")
    raise SystemExit(1)
if not satisfies(node, spec):
    print(
        f"[npm] ERROR: Node.js {'.'.join(str(part) for part in node)} does not satisfy "
        f"npm engines.node {spec}"
    )
    raise SystemExit(1)
print(f"[npm] Node.js {'.'.join(str(part) for part in node)} satisfies npm engines.node {spec}")
PY
}

record_actual_version() {
    local node_version npm_version
    node_version="$("${NODE_BIN}" --version 2>&1)" || {
        log_message "ERROR: failed to execute ${NODE_BIN} --version"
        return 40
    }
    if [[ "${node_version}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js ${NODE_VERSION}, found ${node_version}"
        return 40
    fi
    npm_version="$("${NODE_BIN}" "${NPM_CLI_JS}" --version 2>&1)" || {
        log_message "ERROR: failed to execute npm --version"
        return 40
    }
    npm_version="$(printf '%s\n' "${npm_version}" | tail -n 1 | tr -d '[:space:]')"
    if [[ "${npm_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: requested npm ${SOFTWARE_VERSION} but it reports ${npm_version}"
        return 40
    fi
    NODE_VERSION_STRING="${node_version}"
    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${npm_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "recorded actual npm version: ${npm_version}"
    log_message "runtime: Node.js ${node_version} (npm engines ${NPM_NODE_ENGINES}), npm ${npm_version}"
}


install_fixtures() {
    local manifest="${SCRIPT_DIR}/fixtures/checksums.sha256"
    [[ -f "${manifest}" ]] || {
        log_message "ERROR: committed fixture checksum manifest is missing: ${manifest}"
        return 30
    }
    rm -rf -- "${FIXTURES_DIR}"
    mkdir -p "${FIXTURES_DIR}"
    local fixture
    for fixture in "${NPM_FIXTURES[@]}"; do
        [[ -d "${SCRIPT_DIR}/fixtures/${fixture}" ]] || {
            log_message "ERROR: committed fixture is missing: fixtures/${fixture}"
            return 30
        }
        cp -a -- "${SCRIPT_DIR}/fixtures/${fixture}" "${FIXTURES_DIR}/${fixture}"
    done
    log_message "verifying committed fixture lockfiles against fixtures/checksums.sha256"
    if ! ( cd "${FIXTURES_DIR}" && sha256sum -c "${manifest}" ); then
        log_message "ERROR: a committed fixture does not match its recorded checksum"
        return 30
    fi
    python3 "${SCRIPT_DIR}/scripts/verify_fixtures.py" "${FIXTURES_DIR}" || {
        log_message "ERROR: fixture validation failed"
        return 30
    }
}

materialize_preplaced_cache() {
    local archive="${NPM_OFFLINE_DIR}/npm-cache.tar.gz"
    local directory="${NPM_OFFLINE_DIR}/npm-cache"
    mkdir -p "${NPM_CACHE}"
    if [[ -d "${directory}" ]]; then
        log_message "using pre-placed npm cache directory: ${directory}"
        cp -a -- "${directory}/." "${NPM_CACHE}/" || return 30
        return 0
    fi
    if [[ -f "${archive}" ]]; then
        local sidecar="${archive}.sha256" expected
        if [[ ! -f "${sidecar}" ]]; then
            log_message "ERROR: pre-placed cache archive requires ${sidecar} with its SHA-256"
            return 30
        fi
        expected="$(awk 'NR == 1 {print $1}' "${sidecar}")"
        verify_checksum "${archive}" sha256 "${expected}" || return 30
        log_message "extracting pre-placed npm cache: ${archive}"
        tar -xzf "${archive}" -C "${NPM_CACHE}" || {
            log_message "ERROR: failed to extract the pre-placed npm cache"
            return 30
        }
        return 0
    fi
    return 1
}

npm_ci_network() {
    # A single registry is used on purpose: the cached tarball entries are keyed
    # by the request URL, so the warm-up registry must be the one the effective
    # lockfile points at.  Registries that answer tarball requests with a
    # redirect (for example a mirror serving files from a CDN) are therefore not
    # usable here - see the README troubleshooting table.
    local workdir="$1" log_file="$2"
    log_message "npm ci via ${NPM_REGISTRY}: ${workdir}"
    (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" ci --registry="${NPM_REGISTRY}" \
            --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1 || {
        log_message "ERROR: npm ci failed while warming the cache; see ${log_file}"
        tail -n 20 "${log_file}" >&2 || true
        log_message "HINT: set PERF_NPM_REGISTRY to a mirror that serves tarballs directly, or pre-place a warmed cache in ${NPM_OFFLINE_DIR}"
        return 30
    }
}

warm_fixture_cache() {
    local fixture="$1"
    local workdir="${FIXTURES_DIR}/${fixture}"
    local log_file="${BUILD_LOGS_DIR}/warm-${fixture}.log"
    mkdir -p "$(dirname "${log_file}")"
    prepare_fixture_clean "${fixture}" || return 30
    log_message "warming the private npm cache with fixture ${fixture} (network allowed, untimed)"
    npm_ci_network "${workdir}" "${log_file}" || return 30
    local count
    count="$(count_installed_packages "${workdir}/node_modules")"
    if (( count <= 0 )); then
        log_message "ERROR: fixture ${fixture} installed no packages"
        return 30
    fi
    printf '%s\n' "${count}" > "${PERF_WORK_DIR}/cache-warm/${fixture}.packages"
    log_message "fixture ${fixture}: ${count} installed packages (cache warmed)"
}

verify_fixture_offline() {
    local fixture="$1" expected="$2"
    local workdir="${FIXTURES_DIR}/${fixture}"
    local log_file="${BUILD_LOGS_DIR}/offline-${fixture}.log"
    prepare_fixture_clean "${fixture}" || return 30
    log_message "verifying offline install of fixture ${fixture} (no network allowed)"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" ci --offline --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: fixture ${fixture} cannot be installed offline from the warmed cache"
        tail -n 20 "${log_file}" >&2 || true
        return 30
    fi
    local count
    count="$(count_installed_packages "${workdir}/node_modules")"
    rm -rf -- "${workdir}/node_modules"
    if [[ "${count}" != "${expected}" ]]; then
        log_message "ERROR: fixture ${fixture} installed ${count} packages offline, expected ${expected}"
        return 30
    fi
    log_message "fixture ${fixture}: verified offline install with ${count} packages"
}

warm_resolution_cache() {
    local workdir="${SCRATCH_DIR}/resolution-small"
    local log_file="${BUILD_LOGS_DIR}/warm-resolution.log"
    local source="${SCRIPT_DIR}/fixtures/small/package.json"
    mkdir -p "${workdir}" "$(dirname "${log_file}")"
    rm -rf -- "${workdir:?}/node_modules" "${workdir}/package-lock.json"
    cp -a -- "${source}" "${workdir}/package.json"
    log_message "warming packument metadata for lockfile-free resolution (network allowed, untimed)"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" install --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: could not warm the cache for the lockfile-free resolution scenario"
        tail -n 20 "${log_file}" >&2 || true
        return 30
    fi
    local count
    count="$(count_installed_packages "${workdir}/node_modules")"
    rm -rf -- "${workdir}/node_modules" "${workdir}/package-lock.json"
    printf '%s\n' "${count}" > "${PERF_WORK_DIR}/cache-warm/resolution-small.packages"
    log_message "resolution warmup installed ${count} packages; entry can now resolve offline"
}

verify_resolution_offline() {
    local expected="$1"
    local workdir="${SCRATCH_DIR}/resolution-verify"
    local log_file="${BUILD_LOGS_DIR}/offline-resolution.log"
    mkdir -p "${workdir}"
    rm -rf -- "${workdir:?}/node_modules" "${workdir}/package-lock.json"
    cp -a -- "${SCRIPT_DIR}/fixtures/small/package.json" "${workdir}/package.json"
    log_message "verifying the lockfile-free resolution scenario offline"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" install --offline --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: the lockfile-free resolution scenario cannot run offline"
        tail -n 20 "${log_file}" >&2 || true
        return 30
    fi
    local count
    count="$(count_installed_packages "${workdir}/node_modules")"
    if [[ "${count}" != "${expected}" ]]; then
        log_message "ERROR: offline resolution installed ${count} packages, warm resolution installed ${expected}"
        return 30
    fi
    log_message "lockfile-free resolution verified offline with ${count} packages"
}

warm_extra_dependency() {
    # The measured incremental scenario installs one new dependency into the
    # already installed medium tree.  npm re-resolves peer dependencies while
    # doing so, which requests packuments for packages that are already on disk,
    # so the warm-up has to replay the exact measured path (baseline ci, edit
    # package.json, install) instead of fetching the extra tarball alone.
    local workdir="${SCRATCH_DIR}/extra-dep"
    local log_file="${BUILD_LOGS_DIR}/warm-extra-dep.log"
    mkdir -p "${workdir}" "$(dirname "${log_file}")"
    rm -rf -- "${workdir:?}/node_modules"
    cp -a -- "${SCRIPT_DIR}/fixtures/medium/package.json" "${workdir}/package.json"
    cp -a -- "${SCRIPT_DIR}/fixtures/medium/package-lock.json" "${workdir}/package-lock.json"
    normalize_fixture_lockfile "${workdir}/package-lock.json" || return 30
    log_message "warming the private cache for the incremental add-dependency scenario (network allowed, untimed)"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" ci --no-audit --no-fund --ignore-scripts &&
            python3 - "${workdir}/package.json" "${NPM_EXTRA_DEP_NAME}" "${NPM_EXTRA_DEP_VERSION}" <<'PY' &&
import json
import sys

path, name, version = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as handle:
    package = json.load(handle)
package.setdefault("dependencies", {})[name] = version
with open(path, "w", encoding="utf-8") as handle:
    json.dump(package, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
PY
            "${NPM_WRAPPER}" install --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: could not warm the cache for the incremental add-dependency scenario"
        tail -n 20 "${log_file}" >&2 || true
        return 30
    fi
    rm -rf -- "${workdir}/node_modules"
}

verify_add_dependency_offline() {
    local baseline="$1"
    local workdir="${SCRATCH_DIR}/add-dependency-verify"
    local log_file="${BUILD_LOGS_DIR}/offline-add-dependency.log"
    mkdir -p "${workdir}" "$(dirname "${log_file}")"
    rm -rf -- "${workdir:?}/node_modules"
    cp -a -- "${FIXTURES_DIR}/medium/package.json" "${workdir}/package.json"
    cp -a -- "${FIXTURES_DIR}/medium/package-lock.json" "${workdir}/package-lock.json"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" ci --offline --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: could not build the baseline install for the add-dependency scenario"
        return 30
    fi
    python3 - "${workdir}/package.json" "${NPM_EXTRA_DEP_NAME}" "${NPM_EXTRA_DEP_VERSION}" <<'PY'
import json
import sys

path, name, version = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as handle:
    package = json.load(handle)
package.setdefault("dependencies", {})[name] = version
with open(path, "w", encoding="utf-8") as handle:
    json.dump(package, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
PY
    log_message "verifying the incremental add-dependency scenario offline"
    if ! (
        cd "${workdir}" || exit 1
        "${NPM_WRAPPER}" install --offline --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: the incremental add-dependency scenario cannot run offline"
        tail -n 20 "${log_file}" >&2 || true
        return 30
    fi
    local count
    count="$(count_installed_packages "${workdir}/node_modules")"
    rm -rf -- "${workdir}/node_modules"
    if (( count <= baseline )); then
        log_message "ERROR: adding ${NPM_EXTRA_DEP} did not install any extra package (${count} <= ${baseline})"
        return 30
    fi
    printf '%s\n' "${count}" > "${PERF_WORK_DIR}/cache-warm/add-dependency.packages"
    log_message "incremental add-dependency verified offline: ${count} packages (baseline ${baseline})"
}

write_fixture_metadata() {
    local upstream_ref="" upstream_direct=""
    if [[ -f "${SCRIPT_DIR}/fixtures/upstream/ref.txt" ]]; then
        upstream_ref="$(head -n 1 "${SCRIPT_DIR}/fixtures/upstream/ref.txt")"
    fi
    python3 - "${FIXTURE_METADATA}" "${NODE_VERSION}" "${SOFTWARE_VERSION}" \
        "${NPM_REGISTRY}" "${NPM_EXTRA_DEP}" "${upstream_ref}" \
        "${PERF_WORK_DIR}/cache-warm" "${FIXTURES_DIR}" "${NPM_NODE_ENGINES}" \
        "${SCRIPT_DIR}/fixtures" <<'PY'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

(
    output,
    node_version,
    npm_version,
    registry,
    extra_dependency,
    upstream_ref,
    counters_dir,
    fixtures_dir,
    npm_engines_node,
    committed_dir,
) = sys.argv[1:11]

counters = Path(counters_dir)
fixtures = Path(fixtures_dir)
committed = Path(committed_dir)


def counter(name: str) -> int:
    path = counters / f"{name}.packages"
    if not path.is_file():
        raise SystemExit(f"[npm] ERROR: missing package counter: {path}")
    text = path.read_text(encoding="utf-8").strip()
    if not text.isdigit() or int(text) <= 0:
        raise SystemExit(f"[npm] ERROR: invalid package counter in {path}: {text!r}")
    return int(text)


scenarios = {
    "ci_clean_small": ("small", counter("small")),
    "ci_clean_medium": ("medium", counter("medium")),
    "ci_clean_large": ("large", counter("large")),
    "ci_upstream": ("upstream", counter("upstream")),
    "install_resolve_small": ("small", counter("resolution-small")),
    "install_noop_medium": ("medium", counter("medium")),
    "install_add_dep_medium": ("medium", counter("add-dependency")),
    "query_prod_medium": ("medium", counter("medium")),
}

import hashlib

fixture_rows = {}
for name in ("small", "medium", "large", "upstream"):
    package_path = fixtures / name / "package.json"
    lock_path = fixtures / name / "package-lock.json"
    if not package_path.is_file() or not lock_path.is_file():
        raise SystemExit(f"[npm] ERROR: fixture {name} is incomplete")
    package = json.loads(package_path.read_text(encoding="utf-8"))
    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    fixture_rows[name] = {
        "installed_packages": counter(name),
        "direct_dependencies": len(package.get("dependencies", {}))
        + len(package.get("devDependencies", {})),
        "lockfile_version": lock.get("lockfileVersion"),
        "lockfile_packages": max(len(lock.get("packages", {})) - 1, 0),
        "lockfile_sha256": hashlib.sha256(lock_path.read_bytes()).hexdigest(),
        "committed_lockfile_sha256": hashlib.sha256(
            (committed / name / "package-lock.json").read_bytes()
        ).hexdigest(),
        "registry_origin": registry,
    }

payload = {
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "node_version": node_version,
    "npm_version": npm_version,
    "npm_engines_node": npm_engines_node,
    "registry": registry,
    "cache_layout": "explicit --cache under PERF_WORK_DIR/npm-cache (no ~/.npm)",
    "offline_measurements": True,
    "extra_dependency": extra_dependency,
    "upstream_project": upstream_ref or "unknown",
    "fixtures": fixture_rows,
    "scenarios": {
        name: {"fixture": fixture, "expected_packages": packages}
        for name, (fixture, packages) in scenarios.items()
    },
}
Path(output).write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"[npm] wrote fixture metadata with {len(scenarios)} scenarios")
PY
}

build_npm_base() {
    initialize_runtime || return $?
    require_commands curl tar xz gzip sha256sum awk python3 find || return $?
    mkdir -p "${NPM_CACHE}" "${PERF_WORK_DIR}/cache-warm" "${BUILD_LOGS_DIR}"
    install_node || return $?
    install_npm || return $?
    check_node_engine_compatibility || return $?
    record_actual_version || return $?
    write_npm_wrapper
    install_fixtures || return $?

    local fixture count
    if materialize_preplaced_cache; then
        log_message "pre-placed npm cache is in use; skipping network cache warming"
        for fixture in "${NPM_FIXTURES[@]}"; do
            prepare_fixture_clean "${fixture}"
            log_message "recomputing installed package count offline for fixture ${fixture}"
            if ! (
                cd "${FIXTURES_DIR}/${fixture}" || exit 1
                "${NPM_WRAPPER}" ci --offline --no-audit --no-fund --ignore-scripts
            ) >>"${BUILD_LOGS_DIR}/offline-${fixture}.log" 2>&1; then
                log_message "ERROR: the pre-placed cache cannot install fixture ${fixture} offline"
                return 30
            fi
            count="$(count_installed_packages "${FIXTURES_DIR}/${fixture}/node_modules")"
            rm -rf -- "${FIXTURES_DIR}/${fixture}/node_modules"
            if (( count <= 0 )); then
                log_message "ERROR: fixture ${fixture} installed no packages from the pre-placed cache"
                return 30
            fi
            printf '%s\n' "${count}" > "${PERF_WORK_DIR}/cache-warm/${fixture}.packages"
        done
        warm_extra_dependency || return $?
        log_message "computing offline package counters for the resolution scenarios"
        prepare_fixture_clean small
        rm -rf -- "${SCRATCH_DIR}/resolution-small"
        mkdir -p "${SCRATCH_DIR}/resolution-small"
        cp -a -- "${SCRIPT_DIR}/fixtures/small/package.json" "${SCRATCH_DIR}/resolution-small/package.json"
        if ! (
            cd "${SCRATCH_DIR}/resolution-small" || exit 1
            "${NPM_WRAPPER}" install --offline --no-audit --no-fund --ignore-scripts
        ) >>"${BUILD_LOGS_DIR}/offline-resolution.log" 2>&1; then
            log_message "ERROR: the pre-placed cache cannot resolve the small fixture offline"
            return 30
        fi
        count="$(count_installed_packages "${SCRATCH_DIR}/resolution-small/node_modules")"
        rm -rf -- "${SCRATCH_DIR}/resolution-small/node_modules"
        printf '%s\n' "${count}" > "${PERF_WORK_DIR}/cache-warm/resolution-small.packages"
    else
        for fixture in "${NPM_FIXTURES[@]}"; do
            warm_fixture_cache "${fixture}" || return $?
        done
        warm_resolution_cache || return $?
        warm_extra_dependency || return $?
    fi

    local small_count medium_count
    for fixture in "${NPM_FIXTURES[@]}"; do
        count="$(cat "${PERF_WORK_DIR}/cache-warm/${fixture}.packages")"
        verify_fixture_offline "${fixture}" "${count}" || return $?
    done
    small_count="$(cat "${PERF_WORK_DIR}/cache-warm/resolution-small.packages")"
    verify_resolution_offline "${small_count}" || return $?
    medium_count="$(cat "${PERF_WORK_DIR}/cache-warm/medium.packages")"
    verify_add_dependency_offline "${medium_count}" || return $?
    write_fixture_metadata || return 30
    log_message "base build completed: Node.js ${NODE_VERSION}, npm ${SOFTWARE_VERSION}, private cache ${NPM_CACHE}"
}
