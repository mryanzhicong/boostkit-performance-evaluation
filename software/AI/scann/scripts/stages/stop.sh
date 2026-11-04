#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_scann_runtime() {
    initialize_runtime || return $?
    if docker image inspect "${SCANN_IMAGE_TAG}" >/dev/null 2>&1; then
        docker image rm "${SCANN_IMAGE_TAG}" >/dev/null || {
            log 'ERROR: failed to remove the private ScaNN image'; return 70;
        }
    fi
    log 'ScaNN benchmark containers are stopped; private image tag removed'
}
