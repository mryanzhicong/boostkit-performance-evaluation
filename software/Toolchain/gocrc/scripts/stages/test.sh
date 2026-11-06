#!/usr/bin/env bash
# Test stage: measure the Go runtime CRC32 Castagnoli microbenchmark with the
# measured openEuler golang go1.24.6 toolchain at /home/local/golang inside the
# private container, then summarise the samples with benchstat.
#
# The bootstrap Go at /usr/local/go is never measured: it only exists because
# `make.bash` needs a working compiler to build go1.24.6 from source.
#
# The toolchain gets one warmup round and six measured rounds; the strict parser
# computes the medians, keeps every sample and fails on any deviation.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_crc32_bench() {
    local go_bin="$1" goroot="$2" workdir="$3" count="$4" output="$5"
    container_gocrc_exec_at "${workdir}" "${go_bin}" "${goroot}" test "${BENCH_PACKAGE}" \
        -run '^$' -bench "${BENCH_PATTERN}" -cpu "${BENCH_CPU}" \
        -benchtime=1s -count "${count}" > "${output}" 2>&1
}

toolchain_version() {
    gocrc_container_exec "$1" version | awk '{print $3}' | sed 's/^go//'
}

run_gocrc_benchmarks() {
    local optimized_version source_commit="" bench_file
    local workdir_results="${RESULTS_DIR}"
    initialize_runtime || return $?
    check_gocrc_container || return $?
    configure_go_environment
    bench_file="${workdir_results}/${GO_BENCH_FILE}"

    optimized_version="$(toolchain_version "${GO_OPTIMIZED_BIN}")" || {
        log_message "ERROR: cannot read the openEuler golang version"
        return 50
    }
    if [[ "${optimized_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: measured toolchain is ${optimized_version}, case version is ${SOFTWARE_VERSION}"
        return 50
    fi
    if [[ -f "${RESULTS_DIR}/source-commit.txt" ]]; then
        source_commit="$(tr -d '[:space:]' < "${RESULTS_DIR}/source-commit.txt")"
    fi

    log_message "warmup: openEuler golang ${optimized_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${WARMUP_REPS}"
    if ! run_crc32_bench "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${GO_OPTIMIZED_GOROOT}/src" \
        "${WARMUP_REPS}" "${workdir_results}/warmup-go${SOFTWARE_VERSION}.log"; then
        log_message "ERROR: the openEuler golang CRC32 warmup run failed"
        return 50
    fi
    log_message "measurement: openEuler golang ${optimized_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${MEASURE_REPS}"
    if ! run_crc32_bench "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${GO_OPTIMIZED_GOROOT}/src" \
        "${MEASURE_REPS}" "${bench_file}"; then
        log_message "ERROR: the openEuler golang CRC32 measurement run failed"
        return 50
    fi

    cat "${bench_file}" || return 50

    log_message "summarising the samples with benchstat"
    # Run benchstat from the result directory with a relative file name so the
    # report header stays short and the artifact is easy to read.
    if ! gocrc_container_exec_at "${workdir_results}" "${GO_BENCHSTAT}" \
        "${GO_BENCH_FILE}" > "${workdir_results}/benchstat.txt" 2>&1; then
        log_message "ERROR: benchstat summary failed"
        return 50
    fi
    cat "${workdir_results}/benchstat.txt" || return 50

    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --raw "${bench_file}" \
        --benchstat "${workdir_results}/benchstat.txt" \
        --output "${workdir_results}/benchmark_go.json" \
        --runs "${workdir_results}/runs" \
        --reps "${MEASURE_REPS}" \
        --warmup-reps "${WARMUP_REPS}" \
        --software-version "${SOFTWARE_VERSION}" \
        --measured-version "${optimized_version}" \
        --bootstrap-version "${GO_BOOTSTRAP_VERSION}" \
        --source-commit "${source_commit}" \
        --arch "${EXPECTED_ARCH}" \
        --run-id "${PERF_RUN_ID}" \
        --variant "${PERF_VARIANT}"; then
        log_message "ERROR: the Go CRC32 benchmark output could not be parsed"
        return 50
    fi
    log_message "measured Go CRC32 Castagnoli with openEuler golang ${optimized_version} (${PERF_VARIANT})"
}
