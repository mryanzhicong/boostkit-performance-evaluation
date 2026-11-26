#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_expat_runtime() {
    initialize_runtime || return $?
    check_expat_container || return $?
    local binary
    for binary in "${EXPAT_XMLWF}" "${EXPAT_RUNTESTS}" "${EXPAT_BENCHMARK}"; do
        if ! expat_container_exec test -x "${binary}"; then
            log_message "ERROR: expat build artifact is unavailable: ${binary}"
            return 40
        fi
    done
    local version_line decoded=""
    version_line="$(expat_version_string 2>/dev/null)" || version_line=""
    if [[ -n "${version_line}" ]] && decoded="$(decode_expat_version "${version_line}")"; then
        :
    fi
    if [[ "${decoded}" != "${EXPAT_VERSION}" ]]; then
        log_message "ERROR: expected expat ${EXPAT_VERSION}, found ${decoded:-unknown}"
        return 40
    fi
    if [[ ! -s "${EXPAT_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest is missing: ${EXPAT_CORPUS_MANIFEST}"
        return 40
    fi
    local corpus
    for corpus in "${EXPAT_CORPORA[@]}"; do
        if ! expat_container_exec test -s "${EXPAT_CORPUS_DIR}/${corpus}.xml"; then
            log_message "ERROR: generated corpus is missing: ${corpus}.xml"
            return 40
        fi
    done
    if ! expat_container_exec test -s "${EXPAT_CORPUS_DIR}/external.dtd"; then
        log_message "ERROR: external DTD corpus is missing: ${EXPAT_CORPUS_DIR}/external.dtd"
        return 40
    fi
    log_message "expat ${decoded} runtime is ready inside the private container (compiler: $(compiler_identity), corpora: ${#EXPAT_CORPORA[@]}, reps: ${EXPAT_REPS})"
}
