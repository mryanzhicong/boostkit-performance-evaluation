#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_npm_runtime() {
    initialize_runtime || return $?
    [[ -x "${NODE_BIN}" ]] || {
        log_message "ERROR: the pinned Node.js runtime is unavailable: ${NODE_BIN}"
        return 40
    }
    [[ -x "${NPM_WRAPPER}" ]] || {
        log_message "ERROR: the npm launcher is unavailable: ${NPM_WRAPPER}"
        return 40
    }
    [[ -d "${NPM_CACHE}" ]] || {
        log_message "ERROR: the private npm cache is missing: ${NPM_CACHE}"
        return 40
    }
    local cache_entries cache_content
    cache_entries="$(find "${NPM_CACHE}/_cacache/index-v5" -type f 2>/dev/null | wc -l | tr -d '[:space:]')"
    cache_content="$(find "${NPM_CACHE}/_cacache/content-v2" -type f 2>/dev/null | wc -l | tr -d '[:space:]')"
    if (( cache_entries <= 0 || cache_content <= 0 )); then
        log_message "ERROR: the private npm cache is empty (index=${cache_entries}, content=${cache_content}); the build stage must warm it"
        return 40
    fi
    local node_version npm_version
    node_version="$("${NODE_BIN}" --version)"
    if [[ "${node_version}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js ${NODE_VERSION}, found ${node_version}"
        return 40
    fi
    npm_version="$("${NODE_BIN}" "${NPM_CLI_JS}" --version 2>&1 | tail -n 1 | tr -d '[:space:]')"
    if [[ "${npm_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected npm ${SOFTWARE_VERSION}, found ${npm_version}"
        return 40
    fi
    [[ -f "${FIXTURE_METADATA}" ]] || {
        log_message "ERROR: fixture metadata is missing: ${FIXTURE_METADATA}"
        return 40
    }
    local fixture
    for fixture in "${NPM_FIXTURES[@]}"; do
        [[ -f "${FIXTURES_DIR}/${fixture}/package.json" ]] || {
            log_message "ERROR: fixture ${fixture} is missing from the work directory"
            return 40
        }
        [[ -f "${FIXTURES_DIR}/${fixture}/package-lock.json" ]] || {
            log_message "ERROR: fixture ${fixture} lockfile is missing from the work directory"
            return 40
        }
    done
    log_message "npm ${npm_version} runtime is ready on Node.js ${node_version}; offline cache ${NPM_CACHE} (index=${cache_entries}, content=${cache_content})"
    log_message "measured scenarios: ${NPM_SCENARIOS[*]}"
}
