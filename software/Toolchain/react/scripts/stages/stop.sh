#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The React SSR benchmark runs inside short-lived Node.js processes; there is no
# background service to stop.  The stage still reports the recorded state so the
# framework can tell "nothing to stop" from "stop was skipped".
stop_react_runtime() {
    log_message "React SSR benchmark has no background service; nothing to stop"
}
