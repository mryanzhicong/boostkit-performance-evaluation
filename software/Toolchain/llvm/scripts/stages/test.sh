#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Every measured opt/llc invocation and the pipeline script run inside the private
# container.  ``run_timed_command`` forwards the fixed measurement environment
# (C locale, UTC, closed proxies) through ``llvm_container_measure_at`` because
# docker exec does not inherit the caller's environment, and the timing wrapper
# stays a direct parent of the measured tool so the docker exec overhead never
# enters a measurement window.  The strict parser stays on the host.
run_timed_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    llvm_container_measure_at "${workdir}" python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
        --scenario "${scenario}" \
        --json "${directory}/${label}.json" \
        --log "${directory}/${label}.log" \
        --timeout 1800 \
        -- "$@" || return 50
    return 0
}

scenario_output_dir() {
    local scenario="$1"
    printf '%s\n' "${PERF_WORK_DIR}/out/${scenario}"
}

prepare_output_dir() {
    local scenario="$1" output
    output="$(scenario_output_dir "${scenario}")"
    rm -rf -- "${output}"
    mkdir -p "${output}"
    printf '%s\n' "${output}"
}

verify_output() {
    local scenario="$1" file="$2"
    if ! llvm_container_exec test -s "${file}"; then
        log_message "ERROR: scenario ${scenario} did not produce a non-empty output: ${file}"
        return 50
    fi
    return 0
}

measure_opt() {
    local scenario="$1" module="$2"
    shift 2
    local -a flags=("$@")
    local output i
    output="$(prepare_output_dir "${scenario}")"
    log_message "scenario ${scenario}: warmup"
    output="$(prepare_output_dir "${scenario}")"
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" \
        "${OPT_BIN}" "${flags[@]}" -S -o "${output}/${module}.opt.ll" \
        "${CORPUS_DIR}/${module}" || return $?
    verify_output "${scenario}" "${output}/${module}.opt.ll" || return $?
    for ((i = 1; i <= LLVM_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${LLVM_REPS}"
        output="$(prepare_output_dir "${scenario}")"
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" \
            "${OPT_BIN}" "${flags[@]}" -S -o "${output}/${module}.opt.ll" \
            "${CORPUS_DIR}/${module}" || return $?
    done
    log_message "scenario ${scenario} completed (${LLVM_REPS} repetitions)"
}

measure_llc() {
    local scenario="$1" module="$2" level="$3"
    local output i
    log_message "scenario ${scenario}: warmup"
    output="$(prepare_output_dir "${scenario}")"
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" \
        "${LLC_BIN}" "${level}" -o "${output}/${module}.s" \
        "${CORPUS_DIR}/${module}" || return $?
    verify_output "${scenario}" "${output}/${module}.s" || return $?
    for ((i = 1; i <= LLVM_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${LLVM_REPS}"
        output="$(prepare_output_dir "${scenario}")"
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" \
            "${LLC_BIN}" "${level}" -o "${output}/${module}.s" \
            "${CORPUS_DIR}/${module}" || return $?
    done
    log_message "scenario ${scenario} completed (${LLVM_REPS} repetitions)"
}

pipeline_script() {
    local script="${PERF_WORK_DIR}/pipeline_o2_arith.sh"
    cat >"${script}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
output="\${1}"
"${OPT_BIN}" -O2 -S -o "\${output}/arith.opt.ll" "${CORPUS_DIR}/arith.ll"
"${LLC_BIN}" -O2 -o "\${output}/arith.s" "\${output}/arith.opt.ll"
EOF
    chmod +x "${script}"
    printf '%s\n' "${script}"
}

measure_pipeline() {
    local scenario="pipeline_o2_arith"
    local script output i
    script="$(pipeline_script)"
    log_message "scenario ${scenario}: warmup"
    output="$(prepare_output_dir "${scenario}")"
    run_timed_command "${scenario}" warmup "${PERF_WORK_DIR}" bash "${script}" "${output}" || return $?
    verify_output "${scenario}" "${output}/arith.s" || return $?
    for ((i = 1; i <= LLVM_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${LLVM_REPS}"
        output="$(prepare_output_dir "${scenario}")"
        run_timed_command "${scenario}" "rep${i}" "${PERF_WORK_DIR}" bash "${script}" "${output}" || return $?
    done
    log_message "scenario ${scenario} completed (${LLVM_REPS} repetitions)"
}

run_llvm_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_llvm_container || return $?
    if ! llvm_container_exec test -x "${OPT_BIN}"; then
        log_message "ERROR: opt is unavailable inside the private container: ${OPT_BIN}"
        return 40
    fi
    if ! llvm_container_exec test -x "${LLC_BIN}"; then
        log_message "ERROR: llc is unavailable inside the private container: ${LLC_BIN}"
        return 40
    fi
    local module
    for module in arith.ll mem.ll branch.ll; do
        if ! llvm_container_exec test -s "${CORPUS_DIR}/${module}"; then
            log_message "ERROR: IR corpus module is missing: ${module}"
            return 40
        fi
    done
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    scenario_metadata_payload "${RUNS_DIR}/scenario_meta.json" || return $?

    measure_opt opt_o0_arith arith.ll -O0 || return $?
    measure_opt opt_o2_arith arith.ll -O2 || return $?
    measure_opt opt_o3_arith arith.ll -O3 || return $?
    measure_opt opt_multi_pass_arith arith.ll \
        -passes='default<O2>,loop-vectorize,instcombine,gvn,simplifycfg' || return $?
    measure_opt opt_o2_mem mem.ll -O2 || return $?
    measure_opt opt_o2_branch branch.ll -O2 || return $?
    measure_llc llc_o0_arith arith.ll -O0 || return $?
    measure_llc llc_o2_arith arith.ll -O2 || return $?
    measure_pipeline || return $?

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete LLVM opt/llc pipeline matrix finished (reps=${LLVM_REPS}, private container)"
}
