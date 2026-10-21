#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_protobuf_runtime() {
    log_message "protobuf benchmark has no background service to stop"
}
