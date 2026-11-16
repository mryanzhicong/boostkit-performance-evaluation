#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Start stage: prove that everything the measurement needs is present and that it
# is the pinned version, without running anything expensive.  Every check runs
# inside the private container, because that is where the measured process tree
# will run; a host-level check would prove nothing about the actual runtime.
start_react_runtime() {
    initialize_runtime || return $?
    validate_architecture || return $?
    check_react_container || return $?
    if ! react_container_exec test -x "${REACT_NODE_BIN}"; then
        log_message "ERROR: pinned Node.js runtime is unavailable inside the private container: ${REACT_NODE_BIN}"
        return 40
    fi
    local node_version yarn_release react_release react_dom_release java_release
    node_version="$(node_version_string)" || node_version=""
    if [[ "${node_version}" != "v${NODE_VERSION}" ]]; then
        log_message "ERROR: expected Node.js v${NODE_VERSION}, got: ${node_version:-<unknown>}"
        return 40
    fi
    yarn_release="$(yarn_version_string)" || yarn_release=""
    if [[ "${yarn_release}" != "${YARN_VERSION}" ]]; then
        log_message "ERROR: expected Yarn ${YARN_VERSION}, got: ${yarn_release:-<unknown>}"
        return 40
    fi
    react_release="$(react_version_string)" || react_release=""
    if [[ "${react_release}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react ${SOFTWARE_VERSION}, got: ${react_release:-<unknown>}"
        return 40
    fi
    react_dom_release="$(react_dom_version_string)" || react_dom_release=""
    if [[ "${react_dom_release}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: expected react-dom ${SOFTWARE_VERSION}, got: ${react_dom_release:-<unknown>}"
        return 40
    fi
    # The upstream rollup build runs the closure compiler, which needs Java 11+.
    java_release="$(java_major_version)" || java_release=""
    if [[ -z "${java_release}" ]] || (( java_release < 11 )); then
        log_message "ERROR: the private container needs Java 11+ for the closure compiler, got: ${java_release:-<unknown>}"
        return 40
    fi
    if ! react_container_exec test -f "${REACT_APP_DIR}/node_modules/react-dom/server.node.js" && \
        ! react_container_exec test -f "${REACT_APP_DIR}/node_modules/react-dom/server.js"; then
        log_message "ERROR: react-dom/server is missing from the installed runtime"
        return 40
    fi
    if ! react_container_exec test -f "${REACT_APP_DIR}/bench_ssr.js"; then
        log_message "ERROR: the React SSR harness is missing from the app directory"
        return 40
    fi
    if ! react_container_exec test -f "${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_SCRIPT}"; then
        log_message "ERROR: upstream React build script is missing: ${REACT_SOURCE_DIR}/${REACT_UPSTREAM_BUILD_SCRIPT}"
        return 40
    fi
    if ! react_container_exec test -d "${REACT_SOURCE_DIR}/node_modules/rollup"; then
        log_message "ERROR: upstream React build dependencies are missing (rollup not installed)"
        return 40
    fi
    log_message "React ${SOFTWARE_VERSION} runtime is ready inside the private container (Node.js ${node_version}, Yarn ${yarn_release}, react ${react_release}, react-dom ${react_dom_release}, Java ${java_release}, upstream build tree)"
    node_version="$(react_source_version_string)" || node_version=""
    log_message "upstream React source version: ${node_version:-<unknown>}"
}
