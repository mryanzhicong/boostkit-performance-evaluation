#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_react_runtime() {
    initialize_runtime || return $?
    validate_architecture || return $?
    if [[ ! -x "${REACT_NODE_BIN}" ]]; then
        log_message "ERROR: pinned Node.js runtime is unavailable: ${REACT_NODE_BIN}"
        return 20
    fi
    local node_version yarn_release react_release react_dom_release
    node_version="$(node_version_string)" || node_version=""
    if [[ "${node_version}" != "v${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js v${NODE_VERSION}, got: ${node_version:-<unknown>}"
        return 20
    fi
    yarn_release="$(yarn_version_string)" || yarn_release=""
    if [[ "${yarn_release}" != "${YARN_VERSION}" ]]; then
        log_message "ERROR: expected Yarn ${YARN_VERSION}, got: ${yarn_release:-<unknown>}"
        return 20
    fi
    react_release="$(react_version_string)" || react_release=""
    if [[ "${react_release}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react ${SOFTWARE_VERSION}, got: ${react_release:-<unknown>}"
        return 20
    fi
    react_dom_release="$(react_dom_version_string)" || react_dom_release=""
    if [[ "${react_dom_release}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react-dom ${SOFTWARE_VERSION}, got: ${react_dom_release:-<unknown>}"
        return 20
    fi
    if [[ ! -f "${REACT_APP_DIR}/node_modules/react-dom/server.node.js" && \
          ! -f "${REACT_APP_DIR}/node_modules/react-dom/server.js" ]]; then
        log_message "ERROR: react-dom/server is missing from the installed runtime"
        return 20
    fi
    if [[ ! -f "${REACT_APP_DIR}/bench_ssr.js" ]]; then
        log_message "ERROR: the React SSR harness is missing from the app directory"
        return 20
    fi
    if [[ ! -f "${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_SCRIPT}" ]]; then
        log_message "ERROR: upstream React build script is missing: ${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_SCRIPT}"
        return 20
    fi
    if [[ ! -d "${REACT_SOURCE_DIR}/node_modules/rollup" ]]; then
        log_message "ERROR: upstream React build dependencies are missing (rollup not installed)"
        return 20
    fi
    log_message "React ${SOFTWARE_VERSION} runtime is ready (Node.js ${node_version}, Yarn ${yarn_release}, react ${react_release}, react-dom ${react_dom_release}, upstream build tree)"
    node_version="$(react_source_version_string)" || node_version=""
    log_message "upstream React source version: ${node_version:-<unknown>}"
}
