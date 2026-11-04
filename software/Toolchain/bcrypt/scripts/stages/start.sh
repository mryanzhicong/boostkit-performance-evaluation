#!/usr/bin/env bash
#
# Start stage: prove that the pinned runtime, the staged native module and the
# recorded runtime document still agree before any sample is collected.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_bcrypt_runtime() {
    initialize_runtime || return $?
    check_bcrypt_container || return $?
    bcrypt_container_exec test -x "${NODE_BIN}" || { log_message "ERROR: Node.js runtime is missing: ${NODE_BIN}"; return 40; }
    local reported
    reported="$(bcrypt_container_exec "${NODE_BIN}" --version 2>/dev/null || true)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected node ${NODE_VERSION}, found ${reported:-unknown}"
        return 40
    fi
    [[ -s "${RUNTIME_JSON}" ]] || { log_message "ERROR: runtime record is missing: ${RUNTIME_JSON}"; return 40; }
    bcrypt_container_exec test -d "${APP_DIR}/node_modules/bcrypt" || {
        log_message "ERROR: staged bcrypt package is missing"; return 40; }
    local native_binary="${APP_DIR}/node_modules/bcrypt/prebuilds/linux-x64/bcrypt.glibc.node"
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "aarch64" ]]; then
        native_binary="${APP_DIR}/node_modules/bcrypt/prebuilds/linux-arm64/bcrypt.glibc.node"
    fi
    bcrypt_container_exec test -f "${native_binary}" || {
        log_message "ERROR: prebuilt N-API binary is missing: ${native_binary}"; return 40; }
    if [[ "$(file_sha256 "${native_binary}")" != "$(native_sha256)" ]]; then
        log_message "ERROR: prebuilt N-API binary SHA-256 mismatch"
        return 40
    fi
    local summary
    if ! summary="$(bcrypt_container_exec "${NODE_BIN}" -e "
const bcrypt = require('${APP_DIR}/node_modules/bcrypt');
const salt = bcrypt.genSaltSync(4);
if (!bcrypt.compareSync('startup-check', bcrypt.hashSync('startup-check', salt))) {
  throw new Error('compare returned false');
}
process.stdout.write(JSON.stringify({
  bcrypt: require('${APP_DIR}/node_modules/bcrypt/package.json').version,
  napi: process.versions.napi || null,
  scenarios: ${#BCRYPT_SCENARIOS[@]},
  node: process.versions.node,
}));
" 2>&1)"; then
        log_message "ERROR: the native module failed the start-stage self-check:"
        printf '%s\n' "${summary}" >&2
        return 40
    fi
    if [[ ! "${summary}" =~ \"bcrypt\":\"${SOFTWARE_VERSION}\" ]]; then
        log_message "ERROR: start-stage self-check reports an unexpected bcrypt version: ${summary}"
        return 40
    fi
    log_message "bcrypt ${SOFTWARE_VERSION} measurement runtime is ready (${summary})"
}
