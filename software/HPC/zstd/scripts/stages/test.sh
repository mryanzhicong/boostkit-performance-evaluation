#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_silesia_corpus() {
    if [[ -e "${SILESIA_LOCAL_PATH}" ]]; then
        [[ -r "${SILESIA_LOCAL_PATH}" ]] || {
            log "ERROR: local Silesia corpus is unreadable: ${SILESIA_LOCAL_PATH}"
            return 40
        }
        SILESIA_FILE="${SILESIA_LOCAL_PATH}"
        log "using local Silesia corpus ${SILESIA_FILE}"
    else
        SILESIA_FILE="${PERF_WORK_DIR}/silesia.tar"
        if [[ ! -f "${SILESIA_FILE}" ]]; then
            log "downloading Silesia corpus from ${SILESIA_URL}"
            curl -fL --retry 3 --connect-timeout 30 \
                -o "${SILESIA_FILE}.part" "${SILESIA_URL}" || {
                log "ERROR: failed to download the Silesia corpus"
                return 40
            }
            mv "${SILESIA_FILE}.part" "${SILESIA_FILE}" || return 40
        fi
    fi
    printf '%s  %s\n' "${SILESIA_SHA256}" "${SILESIA_FILE}" | sha256sum -c - || {
        log "ERROR: Silesia corpus checksum mismatch"
        return 40
    }
}

run_zstd_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${BENCHMARK_BIN}" ]] || {
        log "ERROR: lzbench executable is unavailable"
        return 40
    }
    prepare_silesia_corpus || return 40
    export SOFTWARE_VERSION EXPECTED_ARCH
    python3 "${SCRIPT_DIR}/scripts/results/run_lzbench.py" \
        "${BENCHMARK_BIN}" "${SILESIA_FILE}" \
        "${RESULTS_DIR}/benchmark_lzbench.txt" \
        "${RESULTS_DIR}/benchmark_zstd.json" || return 50
}
