#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_ultrascan_benchmarks() {
    initialize_runtime || return $?
    check_ultrascan_container || return $?
    verify_measurement_inputs || return 40

    # Fixed conditions: the aarch64 runner locale otherwise prints grouped
    # digits ("Expression count: 3,116") and breaks every numeric regex.
    export LC_ALL=C
    export LANG=C
    export TZ=UTC

    # The container-side driver owns every measured hsbench process, so Docker
    # management overhead never lands in a measurement window.  It only records
    # the raw hsbench output plus wall time and peak RSS; the numeric validation
    # and the single Mean-throughput metric are produced on the host below.
    log "running the two documented hsbench scenarios inside the private container: warmups=${ULTRASCAN_WARMUPS} reps=${ULTRASCAN_REPS} iterations=${ULTRASCAN_ITERATIONS} locale=C"
    ultrascan_container_exec_at "${PERF_WORK_DIR}" \
        env LC_ALL=C LANG=C TZ=UTC \
        python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" drive \
        --hsbench "${HSBENCH_BIN}" \
        --samples-root "${SAMPLES_ROOT}" \
        --dump-db "${DUMP_DB}" \
        --runs-dir "${RESULTS_DIR}/runs" \
        --warmups "${ULTRASCAN_WARMUPS}" \
        --reps "${ULTRASCAN_REPS}" || {
        log "ERROR: the container-side hsbench timing driver failed"
        return 50
    }

    local compiler
    compiler="$(python3 -c \
        'import json,sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["compiler"]["cxx"])' \
        "${BUILD_STATE_FILE}")" || {
        log "ERROR: cannot read the compiler identity from the build state"
        return 50
    }

    # Strict parser: runs on the host, reads the recorded runs and rejects any
    # missing sample, non-zero exit code or inconsistent measurement.  It keeps
    # only the Mean throughput of each scenario.
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" report \
        --runs-dir "${RESULTS_DIR}/runs" \
        --raw-output "${RESULTS_DIR}/benchmark_hsbench.txt" \
        --output "${RESULTS_DIR}/results.json" \
        --version "${SOFTWARE_VERSION}" \
        --architecture "$(normalize_arch "${EXPECTED_ARCH}")" \
        --variant "${PERF_VARIANT}" \
        --run-id "${PERF_RUN_ID}" \
        --compiler "${compiler}" \
        --warmups "${ULTRASCAN_WARMUPS}" \
        --reps "${ULTRASCAN_REPS}" || {
        log "ERROR: hsbench result parsing failed"
        return 50
    }
}
