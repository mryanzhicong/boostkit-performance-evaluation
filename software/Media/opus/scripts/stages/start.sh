#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_opus_runtime() {
    initialize_runtime || return $?
    check_opus_container || return $?
    container_exec test -f "${OPUS_WORK_SCRIPTS}/bench.py" || {
        log 'ERROR: original bench.py is not staged; run the build stage first'
        return 40
    }
    container_exec test -x "${OPUS_DEMO}" || {
        log "ERROR: opus_demo is missing: ${OPUS_DEMO}"
        return 40
    }
    if container_exec test -f "${OPUS_WORK_SCRIPTS}/.work/audio/${OPUS_AUDIO_NAME}.wav"; then
        log 'local Opus speech sample is staged'
    else
        log 'local Opus speech sample is absent; original bench.py will download it'
    fi
    log 'original Opus scripts and fixed-point opus_demo are ready'
}
