#!/usr/bin/env bash
# Test stage: run the deterministic GDB workload matrix offline.
#
# For every scenario the stage performs one untimed warmup and ${GDB_REPS}
# independent, isolated measurements.  Raw evidence is kept per repetition
# (runs/<scenario>/rep<i>.{log,json}); the strict parser turns it into results.json
# only when each repetition proves it did the declared work.
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

RUN_TIMED="${SCRIPT_DIR}/scripts/run_timed.py"
PARSER="${SCRIPT_DIR}/scripts/results/parse_benchmark.py"

prepare_measurement_environment() {
    # The measurement must be offline and reproducible: private HOME (no ~/.gdbinit),
    # no debuginfod lookups, no proxy that could reach a symbol server, fixed locale
    # and time zone.
    export HOME="${GDB_PRIVATE_HOME}"
    export TMPDIR="${PERF_WORK_DIR}/tmp"
    mkdir -p "${TMPDIR}"
    export LC_ALL=C
    export LANG=C
    export TZ=UTC
    export DEBUGINFOD_URLS=""
    export DEBUGINFOD_PROGRESS=0
    export http_proxy="http://127.0.0.1:9"
    export https_proxy="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export NO_PROXY=""
    export no_proxy=""
    log_message "measurement environment prepared (private HOME=${HOME}, offline, locale C)"
}

fixture_timeout() {
    case "$1" in
        upstream_testsuite_python) printf '900\n' ;;
        breakpoint_set_200|backtrace_deep_2000) printf '600\n' ;;
        *) printf '300\n' ;;
    esac
}

# Echo the three elements of a scenario command: an optional interpreter (-1 when the
# command runs directly), the program and its arguments.  The absolute paths are
# runtime evidence only; the architecture-neutral command description lives in the
# fixture metadata and in results.json.
run_scenario_once() {
    local scenario="$1"
    local tag="$2"
    local log_path="${RUNS_DIR}/${scenario}/${tag}.log"
    local json_path="${RUNS_DIR}/${scenario}/${tag}.json"
    local timeout
    timeout="$(fixture_timeout "${scenario}")"
    mkdir -p "${RUNS_DIR}/${scenario}"

    local -a command=()
    case "${scenario}" in
        startup_version)
            command=("${GDB_BIN}" --version)
            ;;
        symbol_load_1000)
            command=("${GDB_BIN}" -batch -ex "info functions fn_00042" -ex quit symbols_1000)
            ;;
        symbol_load_50000)
            command=("${GDB_BIN}" -batch -ex "info functions fn_49975" -ex quit symbols_50000)
            ;;
        breakpoint_set_200)
            command=("${GDB_BIN}" -batch -x breakpoints.cmd symbols_50000)
            ;;
        step_500)
            command=("${GDB_BIN}" -batch -x steps.cmd steps_500)
            ;;
        info_functions_10000)
            command=(bash -c 'set -o pipefail; "$0" -batch -ex "info functions" symbols_10000 2>&1 | wc -l' "${GDB_BIN}")
            ;;
        python_eval_5000)
            command=("${GDB_BIN}" -batch -x python_eval.py symbols_50000)
            ;;
        backtrace_deep_2000)
            command=(bash -c 'set -o pipefail; "$0" -batch -ex "break crash_here" -ex run -ex bt deep_2000 2>&1 | wc -l' "${GDB_BIN}")
            ;;
        core_backtrace_2000)
            command=(bash -c 'set -o pipefail; "$0" -batch -ex bt deep_2000 deep_2000.core 2>&1 | wc -l' "${GDB_BIN}")
            ;;
        upstream_testsuite_python)
            rm -f "${GDB_TESTS_SUM}" "${GDB_BUILD_DIR}/gdb/testsuite/gdb.log"
            local tests
            tests="$(python3 - "${FIXTURE_METADATA}" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    metadata = json.load(handle)
print(" ".join(metadata["testsuite"]["tests"]))
PY
)"
            command=(make check-gdb MAKEINFO=true "RUNTESTFLAGS=${tests}")
            ;;
        *)
            fail_message "unknown scenario: ${scenario}"
            return 1
            ;;
    esac

    local -a python=(python3 "${RUN_TIMED}" --label "${scenario}/${tag}"
        --log "${log_path}" --json "${json_path}" --timeout "${timeout}"
        --count-root "${FIXTURES_DIR}" --count-suffix ".c,.h,.cmd,.py" --)

    local work_directory="${FIXTURES_DIR}"
    if [[ "${scenario}" == "upstream_testsuite_python" ]]; then
        work_directory="${GDB_BUILD_DIR}"
    fi
    (
        cd "${work_directory}" || exit 1
        "${python[@]}" "${command[@]}"
    )
}


check_measurement_inputs() {
    if [[ ! -f "${FIXTURE_METADATA}" ]]; then
        fail_message "the fixture metadata is missing: ${FIXTURE_METADATA}"
        return 40
    fi
    if ! python3 - "${FIXTURE_METADATA}" "${FIXTURES_DIR}" <<'PY'; then
import hashlib
import json
import os
import sys

metadata_path, fixtures_dir = sys.argv[1:3]
with open(metadata_path, encoding="utf-8") as handle:
    metadata = json.load(handle)


def sha256_file(path):
    digest = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


for name, recorded in metadata["fixtures_generated"].items():
    path = os.path.join(fixtures_dir, name)
    if not os.path.isfile(path):
        raise SystemExit(f"a generated fixture is missing: {path}")
    actual = sha256_file(path)
    if actual != recorded["sha256"]:
        raise SystemExit(f"the generated fixture {name} was modified before measurement")
for name in metadata["fixtures"]["binaries"]:
    path = os.path.join(fixtures_dir, name)
    if not os.path.isfile(path):
        raise SystemExit(f"a compiled fixture is missing: {path}")
core = os.path.join(fixtures_dir, metadata["fixtures"]["core_name"])
if not os.path.isfile(core) or os.path.getsize(core) <= 0:
    raise SystemExit(f"the core file is missing or empty: {core}")
print("[gdb] measurement inputs match the build-stage digests")
PY
        fail_message "the measurement inputs do not match the build-stage evidence"
        return 40
    fi
    return 0
}

run_gdb_benchmarks() {
    initialize_runtime || return $?
    validate_variant || return $?
    validate_reps || return $?

    check_measurement_inputs || return $?
    prepare_measurement_environment
    rm -rf "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scenario rep
    for scenario in "${GDB_SCENARIOS[@]}"; do
        log_message "scenario ${scenario}: warmup"
        if ! run_scenario_once "${scenario}" warmup; then
            fail_message "the warmup for scenario ${scenario} failed"
            return 50
        fi
        for ((rep = 1; rep <= GDB_REPS; rep++)); do
            log_message "scenario ${scenario}: measurement ${rep}/${GDB_REPS}"
            if ! run_scenario_once "${scenario}" "rep${rep}"; then
                fail_message "the measurement ${rep} for scenario ${scenario} failed"
                return 50
            fi
        done
    done

    log_message "parsing and validating the raw evidence"
    if ! SOFTWARE_VERSION="${SOFTWARE_VERSION}" \
        EXPECTED_ARCH="${EXPECTED_ARCH}" \
        PERF_VARIANT="${PERF_VARIANT}" \
        PERF_REPS="${GDB_REPS}" \
        GDB_FIXTURE_METADATA="${FIXTURE_METADATA}" \
        GDB_FIXTURES_DIR="${FIXTURES_DIR}" \
        python3 "${PARSER}" "${RUNS_DIR}" "${RESULTS_DIR}/results.json"; then
        fail_message "the strict parser rejected the raw evidence"
        return 60
    fi
    if [[ ! -f "${RESULTS_DIR}/results.json" ]]; then
        fail_message "the parser did not write results.json"
        return 60
    fi
    log_message "test stage finished: ${RESULTS_DIR}/results.json"
    return 0
}
