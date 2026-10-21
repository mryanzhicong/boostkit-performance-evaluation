#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_sonic_cpp_runtime() {
    log_message "sonic-cpp benchmark has no background service to stop"
}
