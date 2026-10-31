#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_typescript_runtime() {
    initialize_runtime || return $?
    [[ -x "${NODE_BIN}" ]] || {
        log_message "ERROR: the pinned Node.js runtime is unavailable: ${NODE_BIN}"
        return 40
    }
    [[ -f "${TSC_JS}" ]] || {
        log_message "ERROR: the TypeScript launcher is unavailable: ${TSC_JS}"
        return 40
    }
    [[ -x "${TSC_WRAPPER}" ]] || {
        log_message "ERROR: the measured tsc wrapper is unavailable: ${TSC_WRAPPER}"
        return 40
    }
    [[ -x "${TS_PLATFORM_DIR}/lib/tsc" ]] || {
        log_message "ERROR: the native compiler backend is unavailable: ${TS_PLATFORM_DIR}/lib/tsc"
        return 40
    }
    [[ -f "${FIXTURE_METADATA}" ]] || {
        log_message "ERROR: fixture metadata is missing: ${FIXTURE_METADATA}"
        return 40
    }
    local node_version ts_version
    node_version="$("${NODE_BIN}" --version)"
    if [[ "${node_version}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js ${NODE_VERSION}, found ${node_version}"
        return 40
    fi
    ts_version="$("${TSC_WRAPPER}" --version 2>&1 | tail -n 1 | tr -d '[:space:]')"
    ts_version="${ts_version#Version}"
    if [[ "${ts_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected TypeScript ${SOFTWARE_VERSION}, found ${ts_version}"
        return 40
    fi
    local project
    for project in "${TS_PROJECTS[@]}" upstream; do
        [[ -d "${PROJECTS_DIR}/${project}" ]] || {
            log_message "ERROR: project ${project} is missing from the work directory"
            return 40
        }
        [[ -f "${PERF_WORK_DIR}/project-templates/${project}/tsconfig.json" ]] || {
            log_message "ERROR: the pristine template of project ${project} is missing"
            return 40
        }
    done
    local upstream_files
    upstream_files="$(find "${PROJECTS_DIR}/upstream/src" -type f -name '*.ts' 2>/dev/null | wc -l | tr -d '[:space:]')"
    if (( upstream_files <= 0 )); then
        log_message "ERROR: the upstream fixture has no sources"
        return 40
    fi
    log_message "TypeScript ${ts_version} runtime is ready on Node.js ${node_version}; native backend $(basename "${TS_PLATFORM_DIR}")"
    log_message "measured scenarios: ${TS_SCENARIOS[*]} (${#TS_SCENARIOS[@]} scenarios, ${TS_REPS} repetitions + 1 warmup each)"
}
