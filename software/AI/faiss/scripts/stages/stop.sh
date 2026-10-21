#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_faiss_runtime() {
    log_message "Faiss CPU benchmark has no background service to stop"
}
