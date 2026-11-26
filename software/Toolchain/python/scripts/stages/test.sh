#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_python_benchmarks_base() {
    mkdir -p "${BENCH_WORK_DIR}" "${RESULTS_DIR}"
    log_message "installing pyperformance ${PYPERFORMANCE_VERSION} into the private CPython"
    log_message "running the official pyperformance default benchmark suite on native CPython"
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

run_python_benchmarks_optimized() {
    local network_inherit bench_inherit venv_dir venv_cfg venv_python
    local -a venv_dirs=()

    python_load_expected_source || return $?
    python_apply_measurement_environment || return $?
    mkdir -p "${BENCH_WORK_DIR}" "${RESULTS_DIR}"
    log_message "installing pyperformance ${PYPERFORMANCE_VERSION} into the private CPython"
    log_message "running the official pyperformance default benchmark suite with CinderX ${PYTHON_EXPECTED_COMMIT:0:8}"

    network_inherit="PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY"
    bench_inherit="$(python_measurement_inherit_environ)"

    (
        cd "${BENCH_WORK_DIR}" || exit 50
        export PIP_NO_CACHE_DIR=1
        export PIP_DISABLE_PIP_VERSION_CHECK=1
        export PIP_INDEX_URL="${PYPI_INDEX_URL}"
        export PIP_TRUSTED_HOST="${PYPI_TRUSTED_HOST}"

        "${PYTHON_BIN}" -m pip install --no-cache-dir \
            --index-url "${PYPI_INDEX_URL}" \
            --trusted-host "${PYPI_TRUSTED_HOST}" \
            "pyperformance==${PYPERFORMANCE_VERSION}" || exit 50

        # pyperformance always reuses the venv named after the interpreter it
        # runs from. Create it explicitly, then let the benchmark workers see
        # the private CPython's site-packages so the installed CinderX is used.
        rm -rf venv
        "${PYTHON_BIN}" -m pyperformance venv create \
            --inherit-environ "${network_inherit}" || exit 50

        mapfile -t venv_dirs < <(find venv -mindepth 1 -maxdepth 1 -type d -print)
        if [[ "${#venv_dirs[@]}" -ne 1 ]]; then
            log_message "ERROR: expected exactly one pyperformance venv, found ${#venv_dirs[@]}"
            exit 50
        fi
        venv_dir="${venv_dirs[0]}"
        venv_cfg="${venv_dir}/pyvenv.cfg"
        if [[ ! -f "${venv_cfg}" ]]; then
            log_message "ERROR: pyperformance venv has no pyvenv.cfg: ${venv_cfg}"
            exit 50
        fi
        if grep -q '^include-system-site-packages' "${venv_cfg}"; then
            sed -i 's/^include-system-site-packages.*/include-system-site-packages = true/' "${venv_cfg}"
        else
            printf 'include-system-site-packages = true\n' >> "${venv_cfg}"
        fi
        if ! grep -qx 'include-system-site-packages = true' "${venv_cfg}"; then
            log_message "ERROR: could not enable system site-packages in ${venv_cfg}"
            exit 50
        fi

        venv_python="${venv_dir}/bin/python"
        if [[ ! -x "${venv_python}" ]]; then
            log_message "ERROR: pyperformance venv interpreter is missing: ${venv_python}"
            exit 50
        fi
        CINDERX_PLUGIN_ENABLE="${CINDERX_PLUGIN_ENV}" \
        PYTHONJITAUTO="${CINDERX_PYTHONJITAUTO}" \
            "${venv_python}" -c '
import cinderx
import cinderx.jit as jit

if not cinderx.is_initialized():
    raise SystemExit(f"CinderX is not initialized in the benchmark venv: {cinderx.get_import_error()}")
if not jit.is_available():
    raise SystemExit("CinderX JIT native APIs are not available in the benchmark venv")
if not jit.is_enabled():
    raise SystemExit("CinderX JIT is not enabled in the benchmark venv")
' || exit 50

        CINDERX_PLUGIN_ENABLE="${CINDERX_PLUGIN_ENV}" \
        PYTHONJITAUTO="${CINDERX_PYTHONJITAUTO}" \
            "${PYTHON_BIN}" -m pyperformance run \
            --warmup "${PYPERFORMANCE_WARMUP}" \
            --inherit-environ "${bench_inherit}" \
            -o "${RESULTS_DIR}/benchmark.json" || exit 50
    ) || {
        log_message "ERROR: optimized pyperformance run failed"
        return 50
    }

    [[ -s "${RESULTS_DIR}/benchmark.json" ]] || {
        log_message "ERROR: official pyperformance output is empty: ${RESULTS_DIR}/benchmark.json"
        return 50
    }
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PYPERFORMANCE_VERSION
    export PYPERFORMANCE_WARMUP CONFIGURE_OPTIONS
    export PYTHON_EXPECTED_COMMIT PYTHON_EXPECTED_BRANCH PYTHON_EXPECTED_TREE
    export PYTHON_EXPECTED_PARENT PYTHON_EXPECTED_PARENT_TREE PYTHON_EXPECTED_RANGE
    export CINDERX_REPOSITORY CINDERX_REF CINDERX_BUILD_TYPE
    export CINDERX_ENABLE_PGO CINDERX_ENABLE_LTO
    export CINDERX_PLUGIN_ENABLE PYTHONJITAUTO
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark.json" \
        "${RESULTS_DIR}/benchmark_python.json" || {
        log_message "ERROR: failed to normalize official pyperformance results"
        return 50
    }
    log_message "pyperformance results written to benchmark.json and benchmark_python.json"
}

run_python_benchmarks() {
    initialize_runtime || return $?
    [[ -x "${PYTHON_BIN}" ]] || {
        log_message "ERROR: CPython interpreter is unavailable: ${PYTHON_BIN}"
        return 40
    }
    case "${PERF_VARIANT}" in
        base) run_python_benchmarks_base ;;
        optimized) run_python_benchmarks_optimized ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}
