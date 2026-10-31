#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_measured_command() {
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout "${LUA_RUN_TIMEOUT_SECONDS}" \
            -- "$@"
    )
}

validate_compiled_bytecode() {
    local scenario="$1" label="$2" output="$3"
    local directory="${RUNS_DIR}/${scenario}"
    local log_file="${directory}/${label}.log"
    local validation_file="${directory}/${label}.validation.log"
    local status=0
    "${LUA_BIN}" "${output}" > "${validation_file}" 2>&1 || status=$?
    cat "${validation_file}" >> "${log_file}"
    if [[ "${status}" -ne 0 ]]; then
        log_message "ERROR: compiled bytecode failed to load or validate: ${output}"
        return 50
    fi
    if ! grep -q 'checksum=' "${validation_file}"; then
        log_message "ERROR: compiled bytecode validation produced no checksum: ${output}"
        return 50
    fi
}

run_scenario_repetition() {
    local scenario="$1" runner="$2" target="$3" scale="$4" label="$5"
    case "${runner}" in
        lua_script)
            run_measured_command "${scenario}" "${label}" "${PERF_WORK_DIR}" \
                "${LUA_BIN}" "${SCRIPT_DIR}/benchmarks/${target}" "${scale}" || return $?
            ;;
        official_test_suite)
            run_measured_command "${scenario}" "${label}" "${LUA_TESTS_DIR}" \
                "${LUA_BIN}" -e "_U=true" all.lua || return $?
            ;;
        luac_compile)
            local output="${PERF_WORK_DIR}/luac-output/${scenario}-${label}.luac"
            mkdir -p "${PERF_WORK_DIR}/luac-output"
            run_measured_command "${scenario}" "${label}" "${PERF_WORK_DIR}" \
                "${LUAC_BIN}" -o "${output}" \
                "${LUA_GENERATED_DIR}"/module_*.lua "${LUA_GENERATED_DIR}/main.lua" || return $?
            validate_compiled_bytecode "${scenario}" "${label}" "${output}" || return $?
            ;;
        *)
            log_message "ERROR: unsupported runner in ${LUA_SCENARIOS_FILE}: ${runner}"
            return 50
            ;;
    esac
}

run_lua_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -x "${LUA_BIN}" && -x "${LUAC_BIN}" ]] || {
        log_message "ERROR: built lua/luac interpreter is unavailable under ${LUA_SRC_DIR}"
        return 40
    }
    [[ -f "${LUA_SCENARIOS_FILE}" ]] || {
        log_message "ERROR: workload matrix manifest is missing: ${LUA_SCENARIOS_FILE}"
        return 50
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scenario dimension runner target scale check expected tolerance workload
    local scenario_total=0 rep
    while IFS='|' read -r scenario dimension runner target scale check expected tolerance workload; do
        [[ -z "${scenario}" || "${scenario}" == \#* ]] && continue
        log_message "scenario ${scenario} (${dimension}/${runner}): warmup"
        run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" warmup || return $?
        for ((rep = 1; rep <= LUA_REPS; rep++)); do
            log_message "scenario ${scenario}: rep ${rep}/${LUA_REPS}"
            run_scenario_repetition "${scenario}" "${runner}" "${target}" "${scale}" "rep${rep}" || return $?
        done
        scenario_total=$((scenario_total + 1))
    done < "${LUA_SCENARIOS_FILE}"

    if [[ "${scenario_total}" -lt 1 ]]; then
        log_message "ERROR: workload matrix manifest contains no scenarios"
        return 50
    fi

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT LUA_REPS
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" \
        "${LUA_SCENARIOS_FILE}" || return $?
    log_message "complete Lua workload matrix finished: ${scenario_total} scenarios, reps=${LUA_REPS} (warmup 1, offline measurement)"
}
