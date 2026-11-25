#!/usr/bin/env bash
#
# Build-stage dispatcher; the Framework calls build_bcrypt for every variant.
source "$(dirname "${BASH_SOURCE[0]}")/base.sh"
source "$(dirname "${BASH_SOURCE[0]}")/optimized.sh"

build_bcrypt() {
    case "${PERF_VARIANT}" in
        base) build_bcrypt_base ;;
        optimized) build_bcrypt_optimized ;;
        *) log_message "ERROR: unsupported build variant: ${PERF_VARIANT}"; return 30 ;;
    esac
}
