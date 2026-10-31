#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Start stage: prove that everything the measurement needs is present and that it
# is the pinned version, without running anything expensive.
start_nextjs_runtime() {
    initialize_runtime || return $?
    local arch
    arch="$(normalize_architecture)" || return 40

    [[ -x "${NODE_BIN}" ]] || {
        fail_message "the pinned Node.js runtime is missing at ${NODE_BIN}"
        return 40
    }
    [[ -x "${NEXT_BIN}" ]] || {
        fail_message "the pinned Next.js CLI is missing at ${NEXT_BIN}"
        return 40
    }
    [[ -d "${NODE_MODULES_DIR}/${SWC_PACKAGE}" ]] || {
        fail_message "the native Next.js backend ${SWC_PACKAGE} is missing"
        return 40
    }
    [[ -f "${NEXT_FIXTURE_METADATA}" ]] || {
        fail_message "the fixture metadata is missing: ${NEXT_FIXTURE_METADATA}"
        return 40
    }
    [[ -f "${PERF_ACTUAL_VERSION_FILE}" ]] || {
        fail_message "actual-version.txt is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 40
    }

    local node_version next_version actual
    node_version="$("${NODE_BIN}" --version 2>/dev/null)"
    next_version="$("${NODE_BIN}" -e 'process.stdout.write(require(process.argv[1]).version)' \
        "${NEXT_INSTALL_DIR}/package.json" 2>/dev/null)"
    actual="$(tr -d '[:space:]' < "${PERF_ACTUAL_VERSION_FILE}")"
    if [[ "${node_version}" != "${NODE_VERSION}" ]]; then
        fail_message "the runtime reports Node.js ${node_version}, expected ${NODE_VERSION}"
        return 40
    fi
    if [[ "${next_version}" != "${SOFTWARE_VERSION}" || "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "Next.js ${next_version} / recorded ${actual} differ from ${SOFTWARE_VERSION}"
        return 40
    fi

    python3 - "${NEXT_FIXTURE_METADATA}" <<'PY'
import json
import sys
from pathlib import Path

metadata = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
scenarios = metadata.get("scenarios")
projects = metadata.get("projects")
if not isinstance(scenarios, dict) or len(scenarios) != 9:
    raise SystemExit("fixture metadata does not describe the nine scenarios")
if not isinstance(projects, dict) or len(projects) != 4:
    raise SystemExit("fixture metadata does not describe the generated projects")
for name, entry in scenarios.items():
    if not entry.get("project") or not entry.get("command"):
        raise SystemExit(f"scenario {name} is incomplete")
for name, entry in projects.items():
    if not entry.get("digest") or int(entry.get("source_files", 0)) <= 0:
        raise SystemExit(f"project {name} is incomplete")
PY
    if [[ "$?" -ne 0 ]]; then
        fail_message "the fixture metadata is inconsistent"
        return 40
    fi

    local project
    for project in "${NEXT_PROJECTS[@]}"; do
        [[ -d "${TEMPLATES_DIR}/${project}" ]] || {
            fail_message "the project template ${project} is missing"
            return 40
        }
        [[ -d "${PROJECTS_DIR}/${project}" ]] || {
            fail_message "the project ${project} is missing"
            return 40
        }
    done

    local upstream_sources
    upstream_sources="$(count_project_sources "${PROJECTS_DIR}/upstream")"
    if [[ "${upstream_sources}" -le 0 ]]; then
        fail_message "the upstream fixture has no source files"
        return 40
    fi

    log_message "Next.js ${SOFTWARE_VERSION} runtime is ready on Node.js ${node_version}; native backend ${SWC_PACKAGE}"
    log_message "measured scenarios: ${NEXT_SCENARIOS[*]}"
    return 0
}
