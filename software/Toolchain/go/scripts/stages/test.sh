#!/usr/bin/env bash
# Test stage: measure the Go runtime CRC32 Castagnoli microbenchmark with both
# toolchains inside the private container, then compare the two result sets with
# benchstat (installed during the build stage).
#
#   official  Go ${SOFTWARE_VERSION}      at /usr/local/go
#   optimized openEuler golang ${GO_OPTIMIZED_VERSION} at /home/local/golang
#
# Each toolchain gets one warmup round and five measured rounds; the strict
# parser computes the medians, keeps every sample and fails on any deviation.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_crc32_bench() {
    local go_bin="$1" goroot="$2" workdir="$3" count="$4" output="$5"
    container_go_exec_at "${workdir}" "${go_bin}" "${goroot}" test "${BENCH_PACKAGE}" \
        -run '^$' -bench "${BENCH_PATTERN}" -cpu "${BENCH_CPU}" \
        -benchtime=1s -count "${count}" > "${output}" 2>&1
}

toolchain_version() {
    go_container_exec "$1" version | awk '{print $3}' | sed 's/^go//'
}

run_go_benchmarks() {
    local official_version optimized_version source_commit=""
    local workdir_results="${RESULTS_DIR}"
    initialize_runtime || return $?
    check_go_container || return $?
    configure_go_environment

    official_version="$(toolchain_version "${GO_BIN}")" || {
        log_message "ERROR: cannot read the official Go version"
        return 50
    }
    optimized_version="$(toolchain_version "${GO_OPTIMIZED_BIN}")" || {
        log_message "ERROR: cannot read the openEuler golang version"
        return 50
    }
    if [[ "${official_version}" != "${SOFTWARE_VERSION}" || "${optimized_version}" != "${GO_OPTIMIZED_VERSION}" ]]; then
        log_message "ERROR: unexpected toolchains: official=${official_version}, optimized=${optimized_version}"
        return 50
    fi
    if [[ -f "${RESULTS_DIR}/source-commit.txt" ]]; then
        source_commit="$(tr -d '[:space:]' < "${RESULTS_DIR}/source-commit.txt")"
    fi

    log_message "warmup: official Go ${official_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${WARMUP_REPS}"
    if ! run_crc32_bench "${GO_BIN}" "${GO_OFFICIAL_GOROOT}" "${GO_OFFICIAL_GOROOT}/src" \
        "${WARMUP_REPS}" "${workdir_results}/warmup-official.log"; then
        log_message "ERROR: the official Go CRC32 warmup run failed"
        return 50
    fi
    log_message "measurement: official Go ${official_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${MEASURE_REPS}"
    if ! run_crc32_bench "${GO_BIN}" "${GO_OFFICIAL_GOROOT}" "${GO_OFFICIAL_GOROOT}/src" \
        "${MEASURE_REPS}" "${workdir_results}/benchmark_official.txt"; then
        log_message "ERROR: the official Go CRC32 measurement run failed"
        return 50
    fi

    log_message "warmup: openEuler golang ${optimized_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${WARMUP_REPS}"
    if ! run_crc32_bench "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${GO_OPTIMIZED_GOROOT}/src" \
        "${WARMUP_REPS}" "${workdir_results}/warmup-optimized.log"; then
        log_message "ERROR: the openEuler golang CRC32 warmup run failed"
        return 50
    fi
    log_message "measurement: openEuler golang ${optimized_version} go test ${BENCH_PACKAGE} -bench '${BENCH_PATTERN}' -cpu ${BENCH_CPU} -count ${MEASURE_REPS}"
    if ! run_crc32_bench "${GO_OPTIMIZED_BIN}" "${GO_OPTIMIZED_GOROOT}" "${GO_OPTIMIZED_GOROOT}/src" \
        "${MEASURE_REPS}" "${workdir_results}/benchmark_optimized.txt"; then
        log_message "ERROR: the openEuler golang CRC32 measurement run failed"
        return 50
    fi

    cat "${workdir_results}/benchmark_official.txt" || return 50
    cat "${workdir_results}/benchmark_optimized.txt" || return 50

    log_message "comparing both result sets with benchstat"
    # Run benchstat from the result directory with relative file names so the
    # report header stays short and the artifact is easy to read.
    if ! go_container_exec_at "${workdir_results}" "${GO_BENCHSTAT}" \
        benchmark_official.txt benchmark_optimized.txt > "${workdir_results}/benchstat.txt" 2>&1; then
        log_message "ERROR: benchstat comparison failed"
        return 50
    fi
    cat "${workdir_results}/benchstat.txt" || return 50

    if ! python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        --official-raw "${workdir_results}/benchmark_official.txt" \
        --optimized-raw "${workdir_results}/benchmark_optimized.txt" \
        --benchstat "${workdir_results}/benchstat.txt" \
        --output "${workdir_results}/benchmark_go.json" \
        --runs "${workdir_results}/runs" \
        --reps "${MEASURE_REPS}" \
        --warmup-reps "${WARMUP_REPS}" \
        --software-version "${SOFTWARE_VERSION}" \
        --official-version "${official_version}" \
        --optimized-version "${optimized_version}" \
        --source-commit "${source_commit}" \
        --arch "${EXPECTED_ARCH}" \
        --run-id "${PERF_RUN_ID}" \
        --variant "${PERF_VARIANT}"; then
        log_message "ERROR: the Go CRC32 benchmark output could not be parsed"
        return 50
    fi
    log_message "measured Go CRC32 Castagnoli with official ${official_version} and openEuler golang ${optimized_version} (${PERF_VARIANT})"
}
