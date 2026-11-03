#!/usr/bin/env bash
# Optimized variant entry point.
#
# There is no honest "optimized" variant for this workload: the measured quantity is
# the cost of GDB's debug-information and breakpoint handling, and building GDB with
# a higher -O level would change the debugger's own code generation without changing
# the debug information of the measured programs.  A different -O level is therefore
# not a legitimate optimization of the workload; the case reports the variant as
# unsupported instead of measuring two arbitrary compiler flags and presenting one as
# an optimization.  The framework treats exit code 30 as "variant unavailable" and
# must not see a build_variant.json from this stage.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_gdb_optimized() {
    log_message "optimized variant is not supported for the GDB workload"
    log_message "reason: this case measures debugger debug-info/breakpoint processing;"
    log_message "        a local -O level change of GDB itself is not a workload optimization."
    log_message "        The base variant already builds the official GDB ${SOFTWARE_VERSION}"
    log_message "        release with its upstream default CFLAGS (-g -O2)."
    fail_message "requested variant '${PERF_VARIANT}' is not available for this case (exit 30)"
    return 30
}
