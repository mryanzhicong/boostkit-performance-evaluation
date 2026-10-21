#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

stop_bishengjdk_runtime() {
    log_message "BiSheng JDK benchmark has no background service to stop"
}
