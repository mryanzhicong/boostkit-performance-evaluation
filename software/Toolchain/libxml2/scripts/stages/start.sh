#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_libxml2_runtime() {
    initialize_runtime || return $?
    check_libxml2_container || return $?
    local binary
    for binary in "${LIBXML2_XMLLINT}" "${LIBXML2_RUNTEST}" "${LIBXML2_RUNSUITE}"; do
        if ! libxml2_container_exec test -x "${binary}"; then
            log_message "ERROR: libxml2 build artifact is unavailable: ${binary}"
            return 40
        fi
    done
    local version_line encoded decoded=""
    version_line="$(libxml2_version_string 2>/dev/null)" || version_line=""
    encoded="$(printf '%s\n' "${version_line}" | awk '{print $NF}')"
    if [[ -n "${encoded}" ]] && decoded="$(decode_libxml2_version "${encoded}")"; then
        :
    fi
    if [[ "${decoded}" != "${LIBXML2_VERSION}" ]]; then
        log_message "ERROR: expected libxml2 ${LIBXML2_VERSION}, found ${decoded:-unknown}"
        return 40
    fi
    if [[ ! -s "${LIBXML2_CORPUS_MANIFEST}" ]]; then
        log_message "ERROR: corpus manifest is missing: ${LIBXML2_CORPUS_MANIFEST}"
        return 40
    fi
    local corpus
    for corpus in "${LIBXML2_CORPORA[@]}"; do
        if [[ ! -s "${LIBXML2_CORPUS_DIR}/${corpus}.xml" ]]; then
            log_message "ERROR: generated corpus is missing: ${corpus}.xml"
            return 40
        fi
    done
    if [[ ! -d "${LIBXML2_SRC_DIR}/test" || ! -d "${LIBXML2_SRC_DIR}/result" ]]; then
        log_message "ERROR: upstream test data directories are missing under ${LIBXML2_SRC_DIR}"
        return 40
    fi
    log_message "libxml2 ${decoded} runtime is ready (compiler: $(compiler_identity), corpora: ${#LIBXML2_CORPORA[@]}, reps: ${LIBXML2_REPS})"
}
