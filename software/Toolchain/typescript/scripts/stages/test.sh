#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

declare -ga SCENARIO_ARGV=()

scenario_command() {
    case "$1" in
        check_small|check_medium|check_large|check_upstream)
            # Full type check of the whole program, no output files: the
            # dominant cost of a real TypeScript project in CI.
            SCENARIO_ARGV=("${TSC_WRAPPER}" --noEmit -p tsconfig.json --extendedDiagnostics)
            ;;
        emit_medium)
            # Full type check plus JavaScript, declaration and source map emit.
            SCENARIO_ARGV=("${TSC_WRAPPER}" -p tsconfig.json --extendedDiagnostics)
            ;;
        incremental_warm_medium|incremental_change_medium)
            # Re-check against the build info written by the untimed cold build
            # of the reset step; the warm run must re-check nothing, the change
            # run must re-check the mutated file and its dependents.
            SCENARIO_ARGV=("${TSC_WRAPPER}" --noEmit -p tsconfig.json --extendedDiagnostics)
            ;;
        references_build)
            # Composite build of a library package and an application package
            # that consumes it through project references.
            SCENARIO_ARGV=("${TSC_WRAPPER}" --build --verbose)
            ;;
        *)
            log_message "ERROR: unknown scenario: $1"
            return 10
            ;;
    esac
}

run_timed_command() {
    local scenario="$1" label="$2" workdir="$3" count_root="$4"
    shift 4
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/${label}.json" \
            --log "${directory}/${label}.log" \
            --timeout 900 \
            --label "${scenario}/${label}" \
            --count-root "${count_root}" \
            -- "$@"
    )
}

run_setup_command() {
    # Untimed preparation of the state a scenario measures.  Its log is kept as
    # evidence next to the samples so that a warm run can always be traced back
    # to the cold build that created its build info.
    local scenario="$1" label="$2" workdir="$3"
    shift 3
    local directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    (
        cd "${workdir}" || exit 1
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --json "${directory}/setup-${label}.json" \
            --log "${directory}/setup-${label}.log" \
            --timeout 900 \
            --label "${scenario}/setup-${label}" \
            -- "$@"
    ) >/dev/null 2>&1 || true
}

mutate_incremental_source() {
    local workdir="$1"
    python3 - "${workdir}/${TS_INCREMENTAL_MUTATION_FILE}" \
        "${TS_INCREMENTAL_MUTATION_FROM}" "${TS_INCREMENTAL_MUTATION_TO}" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
old, new = sys.argv[2], sys.argv[3]
text = path.read_text(encoding="utf-8")
if old not in text:
    raise SystemExit(f"the mutation target {old!r} is missing from {path}")
path.write_text(text.replace(old, new, 1), encoding="utf-8")
PY
}

reset_scenario_state() {
    local scenario="$1" project label="${2:-warmup}"
    project="$(scenario_project "${scenario}")" || return 10
    # Every repetition starts from the pristine template: no build info, no
    # emitted output and no mutated source may leak from a previous run.
    copy_project_template "${project}" || {
        log_message "ERROR: could not reset project ${project}"
        return 50
    }
    local workdir="${PROJECTS_DIR}/${project}"
    case "${scenario}" in
        incremental_warm_medium)
            run_setup_command "${scenario}" "${label}-cold" "${workdir}" \
                "${TSC_WRAPPER}" --noEmit -p tsconfig.json
            [[ -f "${workdir}/.tsbuildinfo" ]] || {
                log_message "ERROR: the cold build did not write the incremental build info of ${scenario}"
                return 50
            }
            ;;
        incremental_change_medium)
            run_setup_command "${scenario}" "${label}-cold" "${workdir}" \
                "${TSC_WRAPPER}" --noEmit -p tsconfig.json
            [[ -f "${workdir}/.tsbuildinfo" ]] || {
                log_message "ERROR: the cold build did not write the incremental build info of ${scenario}"
                return 50
            }
            mutate_incremental_source "${workdir}" || {
                log_message "ERROR: could not apply the deterministic source change of ${scenario}"
                return 50
            }
            ;;
        *)
            ;;
    esac
}

measure_scenario() {
    local scenario="$1"
    local project workdir count_root directory i
    project="$(scenario_project "${scenario}")" || return 10
    workdir="${PROJECTS_DIR}/${project}"
    count_root="${workdir}"
    directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    scenario_command "${scenario}" || return 10
    # The recorded command is the workload description, not a local path: the
    # wrapper lives under an architecture and run specific work directory, so a
    # verbatim command line would make the cross-architecture parameter
    # signature differ for reasons that have nothing to do with the workload.
    local command_text="${SCENARIO_ARGV[*]}"
    command_text="${command_text/"${TSC_WRAPPER}"/tsc}"
    printf '%s\n' "${command_text}" > "${directory}/command.txt"
    printf '%s\n' "${project}" > "${directory}/project.txt"

    log_message "scenario ${scenario}: warmup"
    reset_scenario_state "${scenario}" warmup || return $?
    run_timed_command "${scenario}" warmup "${workdir}" "${count_root}" \
        "${SCENARIO_ARGV[@]}" || return 50

    for ((i = 1; i <= TS_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${TS_REPS}"
        reset_scenario_state "${scenario}" "rep${i}" || return $?
        run_timed_command "${scenario}" "rep${i}" "${workdir}" "${count_root}" \
            "${SCENARIO_ARGV[@]}" || return 50
    done
    log_message "scenario ${scenario} completed"
}

run_typescript_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -f "${TSC_JS}" ]] || {
        log_message "ERROR: the TypeScript launcher is unavailable: ${TSC_JS}"
        return 40
    }
    [[ -x "${TSC_WRAPPER}" ]] || {
        log_message "ERROR: the measured tsc wrapper is unavailable: ${TSC_WRAPPER}"
        return 40
    }
    [[ -d "${PERF_WORK_DIR}/project-templates" ]] || {
        log_message "ERROR: the pristine project templates are missing"
        return 40
    }
    [[ -f "${FIXTURE_METADATA}" ]] || {
        log_message "ERROR: fixture metadata is unavailable: ${FIXTURE_METADATA}"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"

    local scenario
    for scenario in "${TS_SCENARIOS[@]}"; do
        measure_scenario "${scenario}" || return $?
    done

    # The parser validates the artifacts the last repetition of every scenario
    # left on disk, so the work tree may only be restored afterwards.
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export TS_PROJECTS_DIR="${PROJECTS_DIR}"
    export TS_FIXTURE_METADATA="${FIXTURE_METADATA}"
    local parse_status=0
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || parse_status=$?
    local project
    for project in "${TS_PROJECTS[@]}" upstream; do
        copy_project_template "${project}" || return 50
    done
    [[ "${parse_status}" -eq 0 ]] || return "${parse_status}"
    log_message "complete TypeScript matrix finished (reps=${TS_REPS}, scenarios=${#TS_SCENARIOS[@]})"
}
