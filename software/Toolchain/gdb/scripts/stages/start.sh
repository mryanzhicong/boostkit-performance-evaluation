#!/usr/bin/env bash
# Start stage: verify that the built GDB and the generated workload are present and
# self-consistent before any measurement begins.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_gdb_runtime() {
    initialize_runtime || return $?
    validate_variant || return $?
    validate_reps || return $?

    if [[ ! -x "${GDB_BIN}" ]]; then
        fail_message "the built GDB binary is missing: ${GDB_BIN}"
        return 40
    fi
    local version_line
    version_line="$("${GDB_BIN}" --version 2>/dev/null | head -n 1)"
    if ! printf '%s\n' "${version_line}" | grep -q "GNU gdb (GDB) ${SOFTWARE_VERSION}"; then
        fail_message "the built GDB does not report version ${SOFTWARE_VERSION}: ${version_line}"
        return 40
    fi
    if [[ ! -f "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        fail_message "the actual version file is missing: ${PERF_ACTUAL_VERSION_FILE}"
        return 40
    fi
    local actual
    actual="$(cat "${PERF_ACTUAL_VERSION_FILE}")"
    if [[ "${actual}" != "${SOFTWARE_VERSION}" ]]; then
        fail_message "actual GDB version ${actual} differs from requested ${SOFTWARE_VERSION}"
        return 30
    fi
    if [[ ! -f "${FIXTURE_METADATA}" ]]; then
        fail_message "the fixture metadata is missing: ${FIXTURE_METADATA}"
        return 40
    fi
    if [[ ! -d "${FIXTURES_DIR}" ]]; then
        fail_message "the generated fixture directory is missing: ${FIXTURES_DIR}"
        return 40
    fi
    local sources
    sources="$(count_fixture_sources "${FIXTURES_DIR}")"
    if [[ "${sources}" != "8" ]]; then
        fail_message "expected 8 fixture sources, found ${sources}"
        return 40
    fi
    local binary
    for binary in symbols_1000 symbols_10000 symbols_50000 steps_500 deep_2000; do
        if [[ ! -x "${FIXTURES_DIR}/${binary}" ]]; then
            fail_message "the compiled fixture is missing: ${FIXTURES_DIR}/${binary}"
            return 40
        fi
    done
    if [[ ! -s "${FIXTURES_DIR}/deep_2000.core" ]]; then
        fail_message "the generated core file is missing"
        return 40
    fi
    if [[ ! -f "${GDB_TESTS_SUM}" ]]; then
        fail_message "the baseline upstream testsuite summary is missing: ${GDB_TESTS_SUM}"
        return 40
    fi

    log_message "GDB ${SOFTWARE_VERSION} is ready at ${GDB_BIN}"
    log_message "fixtures: ${sources} sources, 5 binaries, 1 core file"
    log_message "scenarios: ${GDB_SCENARIOS[*]}"
    log_message "measurement: ${GDB_REPS} repetitions + ${GDB_WARMUPS} warmup, median statistic"
    return 0
}
