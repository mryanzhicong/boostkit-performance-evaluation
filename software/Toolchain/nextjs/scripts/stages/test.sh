#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_measurement_environment() {
    # Private HOME and cache, C locale, UTC and no telemetry: every measured
    # process gets exactly the same environment on both architectures.
    export HOME="${NEXT_PRIVATE_HOME}"
    export TZ=UTC
    export LC_ALL=C
    export LANG=C
    export NEXT_TELEMETRY_DISABLED=1
    export NODE_ENV=production
    # Closed proxies: the measurement must not depend on the network; a build that
    # tried to fetch something would fail immediately instead of silently slowing
    # down or producing a different workload.
    export HTTP_PROXY=http://127.0.0.1:9
    export HTTPS_PROXY=http://127.0.0.1:9
    export http_proxy=http://127.0.0.1:9
    export https_proxy=http://127.0.0.1:9
    export NO_PROXY="127.0.0.1,localhost"
    export no_proxy="127.0.0.1,localhost"
    export PATH="${NODE_INSTALL_DIR}/bin:${PATH}"
    return 0
}

prepare_worktree() {
    local project
    for project in "${NEXT_PROJECTS[@]}"; do
        copy_project_template "${project}" || return 50
    done
    return 0
}

# Run one untimed build to establish the state a measured scenario starts from
# (a cold build for the serve scenarios and the incremental snapshot).
run_setup_build() {
    local label="$1"
    local project="$2"
    local workdir="${PROJECTS_DIR}/${project}"
    local log_file="${RUNS_DIR}/setup-${label}.log"
    rm -rf -- "${workdir}/.next"
    log_message "setup: cold build of ${project} (untimed, log: ${log_file})"
    (
        cd "${workdir}" || exit 50
        "${NODE_BIN}" "${NEXT_BIN}" build
    ) >"${log_file}" 2>&1 || {
        fail_message "the setup build of ${project} failed; see ${log_file}"
        return 50
    }
    if [[ ! -f "${workdir}/.next/BUILD_ID" ]]; then
        fail_message "the setup build of ${project} produced no .next/BUILD_ID"
        return 50
    fi
    return 0
}

run_measured_timed() {
    local scenario="$1"
    local label="$2"
    local log_file="${RUNS_DIR}/${scenario}/${label}.log"
    local json_file="${RUNS_DIR}/${scenario}/${label}.json"
    local count_root="$3"
    local timeout="$4"
    shift 4
    # The measured command must run inside the project directory (Next.js resolves
    # ./app or ./pages from the working directory); the absolute project path is
    # evidence only and never enters the recorded parameters.
    (
        cd "${count_root}" || exit 50
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --label "${scenario}:${label}" \
            --log "${log_file}" \
            --json "${json_file}" \
            --timeout "${timeout}" \
            --count-root "${count_root}" \
            -- "$@"
    ) || return 50
    return 0
}

reset_cold_project() {
    local project="$1"
    rm -rf -- "${PROJECTS_DIR}/${project}/.next"
    if [[ -e "${PROJECTS_DIR}/${project}/.next" ]]; then
        fail_message "failed to remove the stale .next directory of ${project}"
        return 50
    fi
    return 0
}

reset_incremental_project() {
    local project="$1"
    local workdir="${PROJECTS_DIR}/${project}"
    if [[ ! -d "${workdir}/.next-cold" ]]; then
        fail_message "the incremental snapshot of ${project} is missing"
        return 50
    fi
    rm -rf -- "${workdir}/.next"
    if ! cp -a "${workdir}/.next-cold" "${workdir}/.next"; then
        fail_message "failed to restore the incremental snapshot of ${project}"
        return 50
    fi
    return 0
}

measure_build_scenario() {
    local scenario="$1"
    local project workdir directory
    project="$(scenario_project "${scenario}")" || return 10
    workdir="${PROJECTS_DIR}/${project}"
    directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}" || return 50
    printf '%s\n' "${project}" > "${directory}/project.txt"
    printf '%s\n' "$(scenario_command_text "${scenario}")" > "${directory}/command.txt"

    local label
    log_message "scenario ${scenario}: warmup"
    reset_cold_project "${project}" || return $?
    run_measured_timed "${scenario}" warmup "${workdir}" 900 \
        "${NODE_BIN}" "${NEXT_BIN}" build || return 50

    for ((i = 1; i <= NEXT_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${NEXT_REPS}"
        reset_cold_project "${project}" || return $?
        run_measured_timed "${scenario}" "rep${i}" "${workdir}" 900 \
            "${NODE_BIN}" "${NEXT_BIN}" build || return 50
    done
    log_message "scenario ${scenario} completed"
    return 0
}

measure_incremental_scenario() {
    local scenario="$1"
    local project workdir directory
    project="$(scenario_project "${scenario}")" || return 10
    workdir="${PROJECTS_DIR}/${project}"
    directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}" || return 50
    printf '%s\n' "${project}" > "${directory}/project.txt"
    printf '%s\n' "$(scenario_command_text "${scenario}")" > "${directory}/command.txt"

    reset_cold_project "${project}" || return $?
    run_setup_build "${scenario}-cold" "${project}" || return $?
    rm -rf -- "${workdir}/.next-cold"
    if ! cp -a "${workdir}/.next" "${workdir}/.next-cold"; then
        fail_message "failed to snapshot the incremental build output of ${project}"
        return 50
    fi
    log_message "scenario ${scenario}: captured the cold build snapshot"

    log_message "scenario ${scenario}: warmup"
    reset_incremental_project "${project}" || return $?
    run_measured_timed "${scenario}" warmup "${workdir}" 900 \
        "${NODE_BIN}" "${NEXT_BIN}" build || return 50

    for ((i = 1; i <= NEXT_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${NEXT_REPS}"
        reset_incremental_project "${project}" || return $?
        run_measured_timed "${scenario}" "rep${i}" "${workdir}" 900 \
            "${NODE_BIN}" "${NEXT_BIN}" build || return 50
    done
    log_message "scenario ${scenario} completed"
    return 0
}


measure_http_scenario() {
    local scenario="$1"
    local project workdir directory mode path expect requests
    project="$(scenario_project "${scenario}")" || return 10
    workdir="${PROJECTS_DIR}/${project}"
    directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}" || return 50
    printf '%s\n' "${project}" > "${directory}/project.txt"
    printf '%s\n' "$(scenario_command_text "${scenario}")" > "${directory}/command.txt"

    case "${scenario}" in
        serve_startup_1000)
            mode="startup"
            path="/"
            expect="fixture"
            requests=0
            ;;
        serve_get_100_static)
            mode="latency"
            path="/items/item-999"
            expect="item-999"
            requests="${NEXT_HTTP_REQUESTS}"
            ;;
        serve_get_100_dynamic)
            mode="latency"
            path="/dyn/item-42"
            expect="item-42"
            requests="${NEXT_HTTP_REQUESTS}"
            ;;
        *) return 10 ;;
    esac

    # The serve scenarios need a production build of the project.  It is rebuilt
    # untimed before the first repetition and stays in place for all repetitions,
    # because starting a server does not modify the build output.
    run_setup_build "${scenario}-production" "${project}" || return $?

    log_message "scenario ${scenario}: warmup"
    run_http_probe "${scenario}" warmup "${workdir}" "${mode}" "${path}" "${expect}" "${requests}" || return 50

    for ((i = 1; i <= NEXT_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${NEXT_REPS}"
        run_http_probe "${scenario}" "rep${i}" "${workdir}" "${mode}" "${path}" "${expect}" "${requests}" || return 50
    done
    log_message "scenario ${scenario} completed"
    return 0
}

run_http_probe() {
    local scenario="$1"
    local label="$2"
    local workdir="$3"
    local mode="$4"
    local path="$5"
    local expect="$6"
    local requests="$7"
    (
        cd "${workdir}" || exit 50
        python3 "${SCRIPT_DIR}/scripts/run_timed.py" \
            --label "${scenario}:${label}" \
            --log "${RUNS_DIR}/${scenario}/${label}.log" \
            --json "${RUNS_DIR}/${scenario}/${label}.json" \
            --timeout 600 \
            --count-root "${workdir}" \
            -- python3 "${SCRIPT_DIR}/scripts/results/http_probe.py" \
            --app-dir "${workdir}" \
            --next-bin "${NEXT_BIN}" \
            --node-bin "${NODE_BIN}" \
            --mode "${mode}" \
            --path "${path}" \
            --expect "${expect}" \
            --requests "${requests}" \
            --port "${NEXT_HTTP_PORT}" \
            --host "${NEXT_HTTP_HOST}"
    ) || return 50
    return 0
}

run_nextjs_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -x "${NEXT_BIN}" ]] || {
        fail_message "the Next.js CLI is unavailable: ${NEXT_BIN}"
        return 40
    }
    [[ -f "${NEXT_FIXTURE_METADATA}" ]] || {
        fail_message "fixture metadata is unavailable: ${NEXT_FIXTURE_METADATA}"
        return 40
    }
    [[ -d "${TEMPLATES_DIR}" ]] || {
        fail_message "the pristine project templates are missing"
        return 40
    }

    prepare_measurement_environment || return $?
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}" || return 50
    prepare_worktree || return $?

    # Cold production builds (the first six scenarios).  They reset .next before
    # every measured run, so each sample starts from the same state.
    local scenario
    for scenario in \
        build_static_1000 \
        build_static_3000 \
        build_dynamic_500 \
        build_routes_500; do
        measure_build_scenario "${scenario}" || return $?
    done

    # Warm incremental rebuild: one untimed cold build, its output snapshotted,
    # then every measured run starts from exactly that snapshot.
    measure_incremental_scenario build_incremental_1000 || return $?

    # Upstream example (pages router, TypeScript type check inside the build).
    measure_build_scenario build_upstream || return $?

    # Loopback request matrix (the delivery load: production build, then serial
    # HTTP GETs against 127.0.0.1).
    measure_http_scenario serve_startup_1000 || return $?
    measure_http_scenario serve_get_100_static || return $?
    measure_http_scenario serve_get_100_dynamic || return $?

    # The parser validates the artifacts the last repetition left on disk, so it
    # runs before anything is cleaned up.
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT NEXT_REPS
    export NEXT_PROJECTS_DIR="${PROJECTS_DIR}"
    export NEXT_FIXTURE_METADATA
    local parse_status=0
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || parse_status=$?
    if [[ "${parse_status}" -ne 0 ]]; then
        fail_message "the benchmark results failed validation"
        return 50
    fi
    log_message "complete Next.js matrix finished (reps=${NEXT_REPS}, scenarios=${#NEXT_SCENARIOS[@]})"
    return 0
}
