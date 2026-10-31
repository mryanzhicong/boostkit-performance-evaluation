#!/usr/bin/env bash
# Build stage for the GDB performance case.
#
# The stage installs the build prerequisites, fetches and verifies the pinned GDB
# 18.1 source archive, builds an isolated GDB, generates the deterministic workload
# (C fixtures, GDB command files, Python script, core file) and validates the fixed
# upstream testsuite subset once without timing.  Everything the measurement stage
# needs is written to ${FIXTURE_METADATA}; architecture specific facts (host
# compiler version, built binary digests, core size, build wall clock) stay out of
# the metric parameters and are kept as provenance evidence.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "${SCRIPT_DIR}/scripts/builders/base_helpers.sh"
source "${SCRIPT_DIR}/scripts/fixtures/workload.sh"

build_gdb_base() {
    local started_at
    initialize_runtime || return $?
    validate_reps || return $?
    started_at="$(date +%s)"
    log_message "build stage for GDB ${SOFTWARE_VERSION} (${EXPECTED_ARCH}, variant ${PERF_VARIANT})"

    install_build_dependencies || return $?
    fetch_gdb_source || return $?
    extract_gdb_source || return $?
    configure_and_build_gdb || return $?
    record_actual_version || return $?
    generate_workload || return $?
    compile_fixture_binaries || return $?
    generate_core_file || return $?
    run_baseline_testsuite || return $?
    write_fixture_metadata "$(( $(date +%s) - started_at ))" || return $?
    record_build_info base || return $?

    write_build_variant_metadata base || return $?
    log_message "GDB ${SOFTWARE_VERSION} build stage finished in $(( $(date +%s) - started_at ))s"
}


