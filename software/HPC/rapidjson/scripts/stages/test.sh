#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

rapidjson_validate_sampling() {
    if [[ ! "${PERF_REPS}" =~ ^[0-9]+$ ]] || (( PERF_REPS < 5 || PERF_REPS > 20 )); then
        log_message "ERROR: PERF_REPS must be an integer between 5 and 20: the sampling contract requires at least 5 measured rounds, got ${PERF_REPS}"
        return 10
    fi
    if [[ ! "${RAPIDJSON_WARMUPS}" =~ ^[0-9]+$ ]] || (( RAPIDJSON_WARMUPS < 1 || RAPIDJSON_WARMUPS > 3 )); then
        log_message "ERROR: RAPIDJSON_WARMUPS must be an integer between 1 and 3, got ${RAPIDJSON_WARMUPS}"
        return 10
    fi
    if [[ "${RAPIDJSON_GTEST_REPEAT}" != "5" ]]; then
        log_message "ERROR: --gtest_repeat is fixed at 5 by the metric formula, got ${RAPIDJSON_GTEST_REPEAT}"
        return 10
    fi
}

rapidjson_check_corpora() {
    local src
    src="$(rapidjson_source_dir)"
    rapidjson_container_exec bash -c '
        set -e
        sample=$(stat -c "%s" "$1")
        paragraphs=$(stat -c "%s" "$2")
        [ "${sample}" = "$3" ] || { echo "sample.json is ${sample} bytes, expected $3" >&2; exit 1; }
        [ "${paragraphs}" = "$4" ] || { echo "paragraphs.json is ${paragraphs} bytes, expected $4" >&2; exit 1; }
    ' _ "${src}/bin/data/sample.json" "${src}/bin/types/paragraphs.json" \
        "${RAPIDJSON_SAMPLE_BYTES}" "${RAPIDJSON_PARAGRAPHS_BYTES}" || {
        log_message 'ERROR: the bundled corpora do not match the pinned byte sizes'
        return 40
    }
}

# One measured process per scenario and round: five in-process gtest iterations
# of the same case, with stdout, stderr and the gtest XML kept side by side.
rapidjson_benchmark_once() {
    local scenario="$1" case_name="$2" rep="$3"
    local filter out src build status
    filter="$(rapidjson_gtest_filter "${case_name}")"
    out="${RESULTS_DIR}/runs/${scenario}/rep${rep}"
    src="$(rapidjson_source_dir)"
    build="$(rapidjson_build_dir)"
    mkdir -p "${RESULTS_DIR}/runs/${scenario}" || return 50
    if rapidjson_container_exec_at "${src}/bin" timeout 600 \
        "${build}/bin/perftest" \
        --gtest_filter="${filter}" \
        --gtest_repeat=5 \
        --gtest_output=xml:"${out}.xml" > "${out}.log" 2> "${out}.err"; then
        return 0
    else
        status=$?
    fi
    if (( status == 124 )); then
        log_message "ERROR: ${scenario} rep${rep} timed out after 600 s"
    else
        log_message "ERROR: ${scenario} rep${rep} failed with exit code ${status}"
    fi
    tail -n 20 "${out}.err" 2>/dev/null || true
    tail -n 20 "${out}.log" 2>/dev/null || true
    return 50
}

rapidjson_verify_result_json() {
    python3 - "${RESULTS_DIR}/perftest_result.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    data = json.load(handle)
results = data.get("results")
if not isinstance(results, dict) or len(results) != 16:
    raise SystemExit("perftest_result.json must contain exactly 16 metrics")
for name, item in results.items():
    if item.get("unit") not in {"ns/op", "GB/s"}:
        raise SystemExit(f"metric {name} has an unexpected unit: {item.get('unit')}")
    expected = "lower_is_better" if item["unit"] == "ns/op" else "higher_is_better"
    if item.get("direction") != expected:
        raise SystemExit(f"metric {name} has an unexpected direction: {item.get('direction')}")
print("verified 16 metrics in perftest_result.json", file=sys.stderr)
PY
}

# The validation step reruns the upstream unit test suite; it is evidence for the
# optimized patch only and never feeds the metrics.
rapidjson_run_unittest() {
    local build src log xml status summary
    build="$(rapidjson_build_dir)"
    src="$(rapidjson_source_dir)"
    log="${RESULTS_DIR}/unittest.log"
    xml="${RESULTS_DIR}/unittest.xml"
    log_message 'validation: running the upstream unittest suite'
    rm -f -- "${xml}"
    if rapidjson_container_exec_at "${src}/bin" timeout 1800 \
        "${build}/bin/unittest" --gtest_output=xml:"${xml}" > "${log}" 2>&1; then
        status=0
    else
        status=$?
    fi
    if (( status != 0 )); then
        log_message "ERROR: unittest exited with code ${status}"
        tail -n 40 "${log}" 2>/dev/null || true
        return 60
    fi
    if grep -q '\[  FAILED  \]' "${log}"; then
        log_message 'ERROR: unittest reported failed cases'
        tail -n 40 "${log}" 2>/dev/null || true
        return 60
    fi
    summary="$(grep -m1 -E '^\[==========\] [0-9]+ tests? from [0-9]+ test suites? ran\.' "${log}" || true)"
    if [[ -z "${summary}" ]]; then
        log_message 'ERROR: unittest did not print its summary line'
        return 60
    fi
    if ! grep -q '\[  PASSED  \]' "${log}"; then
        log_message 'ERROR: unittest did not report a PASSED summary'
        return 60
    fi
    log_message "unittest: ${summary}"
    if rapidjson_container_exec_at "${build}" timeout 1800 \
        ctest --test-dir "${build}" -R unittest --output-on-failure >> "${log}" 2>&1; then
        log_message 'ctest -R unittest passed'
    else
        log_message 'ERROR: ctest -R unittest failed'
        return 60
    fi
}

run_rapidjson_benchmarks() {
    rapidjson_configure_paths || return $?
    rapidjson_validate_sampling || return $?
    check_rapidjson_container || return $?

    local build src run_root total i index scenario
    build="$(rapidjson_build_dir)"
    src="$(rapidjson_source_dir)"
    run_root="${RESULTS_DIR}/runs"
    total=$(( RAPIDJSON_WARMUPS + PERF_REPS ))

    rapidjson_check_corpora || return $?
    for scenario in "${RAPIDJSON_SCENARIOS[@]}"; do
        mkdir -p "${run_root}/${scenario}" || return 50
    done

    log_message "sampling: ${RAPIDJSON_WARMUPS} warmup + ${PERF_REPS} measured round(s) of ${#RAPIDJSON_SCENARIOS[@]} scenarios, container ${RAPIDJSON_CONTAINER_NAME}, cwd ${src}/bin"
    for ((i = 0; i < total; i++)); do
        if (( i < RAPIDJSON_WARMUPS )); then
            log_message "round ${i}: warmup (excluded from the metrics)"
        else
            log_message "round ${i}: measured sample $((i - RAPIDJSON_WARMUPS + 1))/${PERF_REPS}"
        fi
        for index in "${!RAPIDJSON_SCENARIOS[@]}"; do
            scenario="${RAPIDJSON_SCENARIOS[index]}"
            rapidjson_benchmark_once "${scenario}" "${RAPIDJSON_SCENARIO_CASES[index]}" "${i}" || return 50
        done
    done

    {
        for scenario in "${RAPIDJSON_SCENARIOS[@]}"; do
            for ((i = 0; i < total; i++)); do
                printf '\n===== %s rep%d =====\n' "${scenario}" "${i}"
                cat "${run_root}/${scenario}/rep${i}.log" 2>/dev/null || true
            done
        done
    } > "${RESULTS_DIR}/raw-output.log"
    log_message "raw outputs collected: ${RESULTS_DIR}/raw-output.log"

    python3 "${SCRIPT_DIR}/scripts/results/parse_perftest.py" \
        --runs-dir "${run_root}" \
        --results-dir "${RESULTS_DIR}" \
        --fixtures "${SCRIPT_DIR}/fixtures/scenarios.json" \
        --warmups "${RAPIDJSON_WARMUPS}" \
        --reps "${PERF_REPS}" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(rapidjson_arch "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --run-id "${PERF_RUN_ID}" || return 50

    [[ -s "${RESULTS_DIR}/perftest_result.json" ]] || {
        log_message 'ERROR: the strict parser did not produce perftest_result.json'
        return 60
    }
    rapidjson_verify_result_json || return 60
    rapidjson_run_unittest || return 60
    log_message "test stage finished: ${RESULTS_DIR}/perftest_result.json (${RAPIDJSON_WARMUPS} warmup + ${PERF_REPS} measured rounds, 16 metrics)"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_rapidjson_benchmarks "$@"
fi
