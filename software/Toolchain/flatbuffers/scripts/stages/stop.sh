#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/common.sh"

# The FlatBuffers matrix runs short, self-contained processes and starts no
# service, so stopping removes the private container (which terminates anything
# it still owns) and asserts that no temporary processes of this run are left
# behind.  The function is idempotent.
stop_flatbuffers_runtime() {
    configure_runtime_paths || return $?
    remove_flatbuffers_container || return $?
    log_message "flatbuffers runtime stop completed (private container removed)"
    return 0
}
