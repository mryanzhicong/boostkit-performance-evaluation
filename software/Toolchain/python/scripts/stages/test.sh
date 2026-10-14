#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_python_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${PYTHON_BIN}" ]] || {
        log_message "ERROR: CPython interpreter is unavailable: ${PYTHON_BIN}"
        return 40
    }
    mkdir -p "${BENCH_WORK_DIR}" "${RESULTS_DIR}"
    log_message "installing pyperformance ${PYPERFORMANCE_VERSION} into the private CPython"
    log_message "running the official pyperformance default benchmark suite"
    (
        cd "${BENCH_WORK_DIR}"
        export PIP_NO_CACHE_DIR=1
        export PIP_DISABLE_PIP_VERSION_CHECK=1
        # Benchmark virtual environments need the same package source and proxy.
        export PIP_INDEX_URL="${PYPI_INDEX_URL}"
        export PIP_TRUSTED_HOST="${PYPI_TRUSTED_HOST}"
        "${PYTHON_BIN}" -m pip install --no-cache-dir \
            --index-url "${PYPI_INDEX_URL}" \
            --trusted-host "${PYPI_TRUSTED_HOST}" \
            "pyperformance==${PYPERFORMANCE_VERSION}" || exit 50
        "${PYTHON_BIN}" -m pyperformance run \
            --warmup "${PYPERFORMANCE_WARMUP}" \
            --inherit-environ \
                PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY \
            -o "${RESULTS_DIR}/benchmark.json" || exit 50
    ) || {
        log_message "ERROR: official pyperformance run failed"
        return 50
    }
    [[ -s "${RESULTS_DIR}/benchmark.json" ]] || {
        log_message "ERROR: official pyperformance output is empty: ${RESULTS_DIR}/benchmark.json"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH PYPERFORMANCE_VERSION
    export PYPERFORMANCE_WARMUP CONFIGURE_OPTIONS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark.json" \
        "${RESULTS_DIR}/benchmark_python.json" || {
        log_message "ERROR: failed to normalize official pyperformance results"
        return 50
    }
    log_message "pyperformance results written to benchmark.json and benchmark_python.json"
}
