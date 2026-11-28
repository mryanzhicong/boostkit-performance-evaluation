#!/usr/bin/env bash
# Dispatch the build implementation selected by the variant.
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../common.sh"

build_libvirt_virsh_lifecycle() {
    initialize_runtime || return $?
    case "${PERF_VARIANT}" in
        base) build_libvirt_virsh_lifecycle_base ;;
        optimized) build_libvirt_virsh_lifecycle_optimized ;;
        *) log "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/base.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/optimized.sh"
