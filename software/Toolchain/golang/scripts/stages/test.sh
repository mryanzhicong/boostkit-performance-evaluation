#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

copy_bent_module_cache() {
    local source="${BENT_MODULE_CACHE_DIR}/cache/download"
    local destination="${GO_RUNTIME_DIR}/go-mod-cache/cache/download"

    if [[ ! -e "${source}" ]]; then
        log_message "local Bent module cache is unavailable; missing modules will use GOPROXY"
        return 0
    fi
    if [[ ! -d "${source}" ]]; then
        log_message "ERROR: local Bent module cache is not a directory: ${source}"
        return 50
    fi
    mkdir -p "${destination}" || return 50
    if ! cp -R "${source}/." "${destination}/"; then
        log_message "ERROR: failed to copy local Bent module cache from ${source}"
        return 50
    fi
    log_message "copied local Bent module cache from ${source}; missing modules will use GOPROXY"
}

run_official_bent_benchmarks() {
    local bent_dir bent_binary module_cache processor_count
    local -a stdout_files

    bent_dir="${GO_RUNTIME_DIR}/bent"
    module_cache="${GOMODCACHE:-${GO_RUNTIME_DIR}/go-mod-cache}"
    rm -rf -- "${bent_dir}"
    mkdir -p "${bent_dir}" || return 50
    copy_bent_module_cache || return 50
    if ! python3 "${SCRIPT_DIR}/scripts/prefetch_bent_modules.py" \
        --go "${GO_BIN}" --suites "${SCRIPT_DIR}/scripts/suites.toml" --work-dir "${bent_dir}" \
        --module-cache "${module_cache}" --bent-version "${BENT_MODULE_VERSION}"; then
        log_message "ERROR: failed to prepare Bent modules"
        return 50
    fi
    # The cache was checked with Bent's actual go-get requests.  Use it as a
    # file proxy so tag/deprecation lookups cannot unexpectedly hit the network.
    export GOPROXY="file://${module_cache}/cache/download"
    export GOSUMDB=off
    log_message "installing official Bent with go install"
    "${GO_BIN}" install "golang.org/x/benchmarks/cmd/bent@${BENT_MODULE_VERSION}" || return 50
    bent_binary="${GOPATH}/bin/bent"
    if [[ ! -x "${bent_binary}" ]]; then
        log_message "ERROR: go install did not create Bent: ${bent_binary}"
        return 50
    fi
    # Bent prepares its own scripts and Dockerfile with -I.  Replace its
    # default workload with the selected, version-pinned guide workload.
    if ! (
        cd "${bent_dir}"
        "${bent_binary}" -I
    ); then
        log_message "ERROR: Bent initialization failed"
        return 50
    fi
    if ! cp "${SCRIPT_DIR}/scripts/suites.toml" "${bent_dir}/suites.toml" || \
       ! cp "${SCRIPT_DIR}/scripts/benchmarks.toml" "${bent_dir}/benchmarks.toml"; then
        log_message "ERROR: cannot prepare the selected Bent benchmark configuration"
        return 50
    fi
    processor_count="$(nproc)"
    if [[ ! "${processor_count}" =~ ^[1-9][0-9]*$ ]]; then
        log_message "ERROR: nproc returned an invalid processor count: ${processor_count}"
        return 50
    fi
    if ! printf '[[Configurations]]\n  Name = "Baseline"\n  RunEnv = ["GOGC=100", "GOMAXPROCS=%s"]\n  Root = "%s"\n' \
        "${processor_count}" "${GO_INSTALL_DIR}" > "${bent_dir}/configurations.toml"; then
        log_message "ERROR: cannot write Bent Baseline configuration"
        return 50
    fi
    if ! cp "${bent_dir}/suites.toml" "${RESULTS_DIR}/suites.toml" || \
       ! cp "${bent_dir}/benchmarks.toml" "${RESULTS_DIR}/benchmarks.toml" || \
       ! cp "${bent_dir}/configurations.toml" "${RESULTS_DIR}/configurations.toml"; then
        log_message "ERROR: cannot preserve the selected Bent configurations"
        return 50
    fi
    log_message "running selected upstream Bent benchmarks: bent -B benchmarks.toml -C configurations.toml -N 15"
    if ! (
        cd "${bent_dir}"
        "${bent_binary}" -B benchmarks.toml -C configurations.toml -N 15 -L .bent-stamps.log
    ); then
        return 50
    fi
    shopt -s nullglob
    stdout_files=("${bent_dir}"/bench/*.Baseline.stdout)
    shopt -u nullglob
    if [[ "${#stdout_files[@]}" -ne 1 || ! -s "${stdout_files[0]:-}" ]]; then
        log_message "ERROR: expected exactly one nonempty Baseline Bent stdout file, found ${#stdout_files[@]}"
        return 50
    fi
    if ! cp "${stdout_files[0]}" "${RESULTS_DIR}/benchmark_go_bench.txt"; then
        log_message "ERROR: cannot preserve Bent's original benchmark stdout"
        return 50
    fi
}

run_golang_benchmarks() {
    initialize_runtime || return $?
    configure_go_environment
    verify_golang_binary || return $?
    log_message "running 20 selected Bent benchmarks with upstream Go ${SOFTWARE_VERSION}"
    if ! (
        run_official_bent_benchmarks
    ) 2>&1 | tee "${RESULTS_DIR}/bent-run.log"; then
        log_message "ERROR: official Bent benchmark failed"
        return 50
    fi
    if [[ ! -s "${RESULTS_DIR}/benchmark_go_bench.txt" ]]; then
        log_message "ERROR: official Go benchmark output is empty"
        return 50
    fi
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_go_bench.txt" \
        "${RESULTS_DIR}/benchmark_golang.json" || return 50
}
