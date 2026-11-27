#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# The optimized variant is intentionally not implemented: no upstream Celeborn
# tuning has been measured inside this single-node container yet, and silently
# falling back to the base variant would publish numbers under the wrong label.
build_celeborn_optimized() {
    log_message 'ERROR: optimized Celeborn build is not implemented; no measurement is produced'
    return 30
}
