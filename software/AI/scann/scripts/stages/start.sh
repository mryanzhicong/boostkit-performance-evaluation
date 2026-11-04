#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_scann_runtime() {
    initialize_runtime || return $?
    [[ -x "${ANN_VENV}/bin/python" && -f "${ANN_ROOT}/run.py" ]] || {
        log 'ERROR: ann-benchmarks coordinator is unavailable'; return 40;
    }
    verify_scann_image || return 40
    log 'ann-benchmarks coordinator and ScaNN 1.4.2 image are ready'
}
