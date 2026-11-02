#!/usr/bin/env bash
#
# The optimized variant is reserved for a future tuned build (for example a
# cost-preserving faster hash implementation or a tuned libuv thread pool).  It
# must fail instead of producing a misleading build_variant.json.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_bcrypt_optimized() {
    log_message "ERROR: the optimized bcrypt variant is reserved; only the base variant is implemented"
    log_message "a reserved variant must fail instead of producing a misleading build_variant.json"
    return 30
}
