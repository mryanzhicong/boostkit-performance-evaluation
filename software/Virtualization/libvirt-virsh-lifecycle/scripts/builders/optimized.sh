#!/usr/bin/env bash
# The optimized variant is not part of the adapted contract; fail loudly instead of
# silently falling back to the base build.
build_libvirt_virsh_lifecycle_optimized() {
    log 'ERROR: only the base variant is defined for libvirt-virsh-lifecycle'
    return 10
}
