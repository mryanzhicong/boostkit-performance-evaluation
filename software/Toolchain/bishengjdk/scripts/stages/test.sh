#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_bishengjdk_benchmarks() {
    local result_root result_file benchmark_source benchmark_copy
    local -a result_files

    initialize_runtime || return $?
    if [[ ! -x "${JDK_HOME}/bin/java" || \
          ! -s "${SRC_DIR}/build/jmh/jars/jmh-core-${JMH_VERSION}.jar" ]]; then
        log_message "ERROR: source-built BiSheng JDK or JMH bundle is missing"
        return 40
    fi
    benchmark_source="${SRC_DIR}/test/micro/org/openjdk/bench/vm/compiler/FloatingScalarVectorAbsDiff.java"
    benchmark_copy="${JMH_SOURCE_DIR}/org/openjdk/bench/vm/compiler/FloatingScalarVectorAbsDiff.java"
    if [[ ! -f "${benchmark_source}" ]]; then
        log_message "ERROR: official JMH benchmark source is missing: ${benchmark_source}"
        return 50
    fi
    mkdir -p "$(dirname "${benchmark_copy}")"
    if ! cp -- "${benchmark_source}" "${benchmark_copy}" || ! cmp -s -- "${benchmark_source}" "${benchmark_copy}"; then
        log_message 'ERROR: failed to stage an unchanged copy of the official JMH benchmark'
        return 50
    fi
    result_root="${SRC_DIR}/build/${BUILD_CONF}/test-results"
    log_message "running ${JMH_BENCHMARK} with JMH ${JMH_VERSION}; count=${JMH_COUNT}, threads=1, no CPU affinity"
    if ! (
        cd "${SRC_DIR}"
        printf '[bishengjdk] compiling only the official benchmark from %s\n' "${JMH_SOURCE_DIR}"
        make test CONF="${BUILD_CONF}" \
            MICROBENCHMARK_SRC="${JMH_SOURCE_DIR}" \
            TEST="micro:${JMH_BENCHMARK}" \
            MICRO="FORK=3;WARMUP_ITER=4;WARMUP_TIME=2;ITER=4;TIME=2;RESULTS_FORMAT=json;OPTIONS=-t 1 -p count=${JMH_COUNT}"
    ) 2>&1 | tee "${RESULTS_DIR}/jmh-output.log"; then
        log_message "ERROR: JMH test run failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/jmh-output.log" || ! -d "${result_root}" ]]; then
        log_message "ERROR: JMH output or test-results directory is missing"
        return 50
    fi
    mapfile -d '' -t result_files < <(find "${result_root}" -type f -name jmh-result.json -print0)
    if [[ "${#result_files[@]}" -ne 1 || ! -s "${result_files[0]:-}" ]]; then
        log_message "ERROR: expected exactly one nonempty JMH JSON result under ${result_root}"
        return 50
    fi
    result_file="${result_files[0]}"
    cp "${result_file}" "${RESULTS_DIR}/jmh-result.json"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT JMH_BENCHMARK JMH_COUNT JMH_VERSION BUILD_CONF
    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/jmh-result.json" \
        "${RESULTS_DIR}/benchmark_bishengjdk.json"; then
        log_message "ERROR: failed to normalize JMH results"
        return 50
    fi
    log_message "JMH results written to jmh-output.log, jmh-result.json, and benchmark_bishengjdk.json"
}
