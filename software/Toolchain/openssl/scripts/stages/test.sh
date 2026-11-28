#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

openssl_validate_sampling() {
    if [[ ! "${PERF_REPS}" =~ ^[0-9]+$ ]] || (( PERF_REPS < 1 || PERF_REPS > 20 )); then
        log_message "ERROR: PERF_REPS must be an integer between 1 and 20, got ${PERF_REPS}"
        return 10
    fi
    if [[ ! "${OPENSSL_WARMUPS}" =~ ^[0-9]+$ ]] || (( OPENSSL_WARMUPS > 3 )); then
        log_message "ERROR: OPENSSL_WARMUPS must be an integer between 0 and 3, got ${OPENSSL_WARMUPS}"
        return 10
    fi
    if [[ ! "${OPENSSL_HARNESS_JOBS}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: OPENSSL_HARNESS_JOBS must be a positive integer, got ${OPENSSL_HARNESS_JOBS}"
        return 10
    fi
    if (( PERF_REPS < 5 )); then
        log_message "WARNING: PERF_REPS=${PERF_REPS} is below the 5-sample contract; this run only validates the pipeline"
    fi
}

# run_step <label> <stdout log> <command inside the container...>
openssl_run_step() {
    local label="$1" log="$2"
    shift 2
    local status=0 err="${log%.log}.err"
    openssl_container_exec timeout 900 "$@" > "${log}" 2> "${err}" || status=$?
    if (( status == 0 )); then
        return 0
    fi
    if (( status == 124 )); then
        log_message "ERROR: ${label} timed out after 900 s"
    else
        log_message "ERROR: ${label} failed with exit code ${status}"
    fi
    tail -n 20 "${err}" 2>/dev/null || true
    tail -n 20 "${log}" 2>/dev/null || true
    return 50
}

# Upstream full test suite inside the build tree: exit code 0, `Result: PASS`,
# no `Result: FAIL` and the main result line must be Files=402, Tests=3619.
# The extra `Result: NOTESTS` line is the FIPS no-op run and is not a failure.
openssl_run_test_suite() {
    local src log summary status=0
    src="$(openssl_source_dir)"
    log="${RESULTS_DIR}/test.log"
    summary="${RESULTS_DIR}/test_summary.json"
    log_message "running the upstream test suite: HARNESS_JOBS=${OPENSSL_HARNESS_JOBS} make test"
    openssl_container_exec_at "${src}" env HARNESS_JOBS="${OPENSSL_HARNESS_JOBS}" make test \
        > "${log}" 2>&1 || status=$?
    if (( status != 0 )); then
        log_message "ERROR: make test failed with exit code ${status}"
        tail -n 40 "${log}" 2>/dev/null || true
    fi
    python3 - "${log}" "${summary}" "${status}" "${SOFTWARE_VERSION}" \
        "$(openssl_arch "${EXPECTED_ARCH}")" "${PERF_RUN_ID}" "${OPENSSL_HARNESS_JOBS}" \
        "${OPENSSL_TEST_FILES}" "${OPENSSL_TEST_TESTS}" "${PERF_REPS}" "${OPENSSL_WARMUPS}" <<'PY'
import json
import re
import sys

(log_path, summary_path, exit_code, version, arch, run_id, harness_jobs,
 expected_files, expected_tests, reps, warmups) = sys.argv[1:]
exit_code = int(exit_code)
try:
    text = open(log_path, encoding="utf-8", errors="replace").read()
except OSError as error:
    print(f"ERROR: cannot read {log_path}: {error}", file=sys.stderr)
    raise SystemExit(60)

result_lines = re.findall(r"^Result: (\w+)$", text, re.MULTILINE)
files_lines = re.findall(r"^Files=(\d+), Tests=(\d+),\s+(\d+) wallclock secs", text, re.MULTILINE)
main = [(int(files), int(tests), int(wall)) for files, tests, wall in files_lines if int(tests) > 0]
failures = [line for line in text.splitlines() if line.startswith("Result: FAIL")]
not_ok = [line for line in text.splitlines() if line.startswith("not ok ")]
skipped = [line for line in text.splitlines() if "skipped:" in line]
external_skipped = [line for line in skipped if "No external tests in this configuration" in line]

passed = True
reasons = []
if exit_code != 0:
    passed = False
    reasons.append(f"make test exited with {exit_code}")
if result_lines.count("PASS") != 1:
    passed = False
    reasons.append(f"expected exactly one 'Result: PASS' line, found {result_lines.count('PASS')}")
if failures:
    passed = False
    reasons.append(f"found {len(failures)} 'Result: FAIL' line(s)")
if not_ok:
    passed = False
    reasons.append(f"found {len(not_ok)} failed test recipe line(s)")
if len(main) != 1:
    passed = False
    reasons.append(f"expected exactly one main 'Files=.., Tests=..' result line, found {len(main)}")
else:
    files, tests, _ = main[0]
    if files != int(expected_files) or tests != int(expected_tests):
        passed = False
        reasons.append(f"main result line is Files={files}, Tests={tests}, expected "
                       f"Files={expected_files}, Tests={expected_tests}")

payload = {
    "software": "openssl",
    "version": version,
    "architecture": arch,
    "run_id": run_id,
    "command": f"HARNESS_JOBS={harness_jobs} make test",
    "exit_code": exit_code,
    "passed": passed,
    "result_lines": result_lines,
    "main_result": (
        {"files": main[0][0], "tests": main[0][1], "wallclock_seconds": main[0][2]}
        if len(main) == 1 else None
    ),
    "notes_test_count": result_lines.count("NOTESTS"),
    "skipped_count": len(skipped),
    "external_provider_skipped": len(external_skipped),
    "failures": failures[:20] + not_ok[:20],
    "log": "test.log",
    "parameters": {
        "version": version,
        "harness_jobs": int(harness_jobs),
        "warmups": int(warmups),
        "reps": int(reps),
    },
}
with open(summary_path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
if not passed:
    for reason in reasons:
        print(f"ERROR: test suite verification failed: {reason}", file=sys.stderr)
    raise SystemExit(60)
print(f"test suite passed: Files={main[0][0]}, Tests={main[0][1]} "
      f"({main[0][2]} wallclock secs, {len(external_skipped)} external tests skipped)",
      file=sys.stderr)
PY
}

run_openssl_benchmarks() {
    openssl_configure_paths || return $?
    openssl_validate_sampling || return $?
    check_openssl_container || return $?

    local bin run_root raw_tmp scenario total i round_started suite_started
    bin="$(openssl_bin)"
    run_root="${RESULTS_DIR}/runs"
    raw_tmp="${RESULTS_DIR}/.raw-output.log.tmp"
    total=$(( OPENSSL_WARMUPS + PERF_REPS ))

    for scenario in "${OPENSSL_SCENARIOS[@]}"; do
        mkdir -p "${run_root}/${scenario}"
    done

    log_message "sampling: ${OPENSSL_WARMUPS} warmup + ${PERF_REPS} measured round(s), container ${OPENSSL_CONTAINER_NAME}"
    log_message "workload: -mr -seconds ${OPENSSL_SPEED_SECONDS} -bytes ${OPENSSL_BLOCK_BYTES} (fixed on every architecture)"
    for ((i = 0; i < total; i++)); do
        if (( i < OPENSSL_WARMUPS )); then
            log_message "round ${i}: warmup (not part of the statistics)"
        else
            log_message "round ${i}: measured sample $((i - OPENSSL_WARMUPS + 1))/${PERF_REPS}"
        fi
        round_started="$(date +%s)"
        for scenario in "${OPENSSL_SCENARIOS[@]}"; do
            # shellcheck disable=SC2086  # the argument list is intentionally split
            openssl_run_step "${scenario} round ${i}" "${run_root}/${scenario}/rep${i}.log" \
                "${bin}" speed -mr -seconds "${OPENSSL_SPEED_SECONDS}" \
                -bytes "${OPENSSL_BLOCK_BYTES}" ${OPENSSL_SCENARIO_ARGS[${scenario}]} || return 50
        done
        log_message "round ${i} finished in $(( $(date +%s) - round_started )) s (8 scenarios)"
    done

    # Aggregate every round in one segmented log.  It is moved into place as
    # the very last step of this stage because the framework streams its own
    # stage log to the same path.
    {
        for scenario in "${OPENSSL_SCENARIOS[@]}"; do
            for ((i = 0; i < total; i++)); do
                printf '\n===== %s rep%d =====\n' "${scenario}" "${i}"
                cat "${run_root}/${scenario}/rep${i}.log"
            done
        done
    } > "${raw_tmp}"

    python3 "${SCRIPT_DIR}/scripts/results/parse_speed.py" \
        --runs-dir "${run_root}" \
        --results-dir "${RESULTS_DIR}" \
        --fixtures "${SCRIPT_DIR}/fixtures/scenarios.json" \
        --warmups "${OPENSSL_WARMUPS}" \
        --reps "${PERF_REPS}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(openssl_arch "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --run-id "${PERF_RUN_ID}" || return 50

    [[ -s "${RESULTS_DIR}/speed_result.json" ]] || {
        log_message 'ERROR: the strict parser did not produce speed_result.json'
        return 60
    }

    suite_started="$(date +%s)"
    openssl_run_test_suite || return 60
    log_message "make test finished in $(( $(date +%s) - suite_started )) s"

    log_message "raw outputs collected: ${RESULTS_DIR}/raw-output.log"
    mv -f "${raw_tmp}" "${RESULTS_DIR}/raw-output.log"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_openssl_benchmarks "$@"
fi
