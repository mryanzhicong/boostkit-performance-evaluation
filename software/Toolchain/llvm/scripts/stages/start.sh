#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Start stage: verify the built opt/llc binaries and the IR corpus inside the
# private container, because that is where the measured tools will run.
start_llvm_runtime() {
    initialize_runtime || return $?
    check_llvm_container || return $?
    if ! llvm_container_exec test -x "${OPT_BIN}"; then
        log_message "ERROR: opt is unavailable inside the private container: ${OPT_BIN}"
        return 40
    fi
    if ! llvm_container_exec test -x "${LLC_BIN}"; then
        log_message "ERROR: llc is unavailable inside the private container: ${LLC_BIN}"
        return 40
    fi
    local version_line
    version_line="$(llvm_container_exec "${OPT_BIN}" --version 2>&1 || true)"
    if [[ -z "${version_line}" ]]; then
        log_message "ERROR: opt --version failed inside the private container"
        return 40
    fi
    if ! printf '%s\n' "${version_line}" | grep -q "LLVM version ${SOFTWARE_VERSION}"; then
        log_message "ERROR: opt does not report LLVM version ${SOFTWARE_VERSION}"
        printf '%s\n' "${version_line}" | sed -n '1,4p'
        return 40
    fi
    if ! printf '%s\n' "${version_line}" | grep -qi "${LLVM_TARGET_NAME}"; then
        log_message "WARNING: opt does not list the ${LLVM_TARGET_NAME} target in --version output"
    fi
    local module
    for module in arith.ll mem.ll branch.ll; do
        if ! llvm_container_exec test -s "${CORPUS_DIR}/${module}"; then
            log_message "ERROR: IR corpus module is missing: ${module}"
            return 40
        fi
    done
    log_message "LLVM ${SOFTWARE_VERSION} opt/llc runtime is ready inside the private container (${LLVM_TARGET_NAME} target)"
    return 0
}
