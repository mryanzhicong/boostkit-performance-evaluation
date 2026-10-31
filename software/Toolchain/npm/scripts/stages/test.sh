#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

declare -ga SCENARIO_ARGV=()

scenario_command() {
    case "$1" in
        ci_clean_small|ci_clean_medium|ci_clean_large|ci_upstream)
            # npm ci always removes node_modules first, so every repetition is a
            # clean install of the committed lockfile from the private cache.
            SCENARIO_ARGV=(
                "${NPM_WRAPPER}" ci --offline --no-audit --no-fund --ignore-scripts
            )
            ;;
        install_resolve_small|install_noop_medium|install_add_dep_medium)
            SCENARIO_ARGV=(
                "${NPM_WRAPPER}" install --offline --no-audit --no-fund --ignore-scripts
            )
            ;;
        query_prod_medium)
            # A read-only traversal of the complete installed tree.  `npm ls
            # --all` is not used as a measured command because real projects
            # legitimately carry peer-dependency mismatches and npm then exits
            # non-zero (ELSPROBLEMS); the parser must never mask a non-zero exit,
            # so the traversal is expressed with the query command, which walks
            # the same tree and completes cleanly.
            SCENARIO_ARGV=("${NPM_WRAPPER}" query --offline ".prod")
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
            --timeout 1800 \
            --label "${scenario}/${label}" \
            --count-root "${count_root}" \
            -- "$@"
    )
}

add_extra_dependency_to_fixture() {
    local fixture="$1"
    python3 - "${FIXTURES_DIR}/${fixture}/package.json" \
        "${NPM_EXTRA_DEP_NAME}" "${NPM_EXTRA_DEP_VERSION}" <<'PY'
import json
import sys

path, name, version = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as handle:
    package = json.load(handle)
package.setdefault("dependencies", {})[name] = version
with open(path, "w", encoding="utf-8") as handle:
    json.dump(package, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
PY
}

restore_installed_tree() {
    local fixture="$1"
    local target="${FIXTURES_DIR}/${fixture}"
    rm -rf -- "${target}/node_modules"
    cp -a -- "${INSTALLED_TEMPLATE}" "${target}/node_modules" || {
        log_message "ERROR: could not restore the installed baseline tree"
        return 50
    }
    cp -a -- "${SCRIPT_DIR}/fixtures/${fixture}/package.json" "${target}/package.json"
    cp -a -- "${SCRIPT_DIR}/fixtures/${fixture}/package-lock.json" "${target}/package-lock.json"
    normalize_fixture_lockfile "${target}/package-lock.json" || return 50
}

reset_scenario_state() {
    local scenario="$1" fixture
    fixture="$(scenario_fixture "${scenario}")" || return 10
    case "${scenario}" in
        ci_clean_small|ci_clean_medium|ci_clean_large|ci_upstream)
            prepare_fixture_clean "${fixture}" || return 50
            ;;
        install_resolve_small)
            # No lockfile: npm must resolve the whole tree from the cached
            # packuments, which is the resolver path rather than the ci path.
            prepare_fixture_clean "${fixture}" || return 50
            rm -f -- "${FIXTURES_DIR}/${fixture}/package-lock.json"
            ;;
        install_noop_medium|query_prod_medium)
            restore_installed_tree "${fixture}" || return 50
            ;;
        install_add_dep_medium)
            restore_installed_tree "${fixture}" || return 50
            add_extra_dependency_to_fixture "${fixture}" || return 50
            ;;
        *)
            log_message "ERROR: unknown scenario: ${scenario}"
            return 10
            ;;
    esac
}

prepare_installed_template() {
    local log_file="${RUNS_DIR}/_prepare/medium-installed-template.log"
    mkdir -p "$(dirname "${log_file}")"
    prepare_fixture_clean medium || return 50
    log_message "preparing the installed baseline tree for the medium fixture (untimed)"
    if ! (
        cd "${FIXTURES_DIR}/medium" || exit 1
        "${NPM_WRAPPER}" ci --offline --no-audit --no-fund --ignore-scripts
    ) >>"${log_file}" 2>&1; then
        log_message "ERROR: could not prepare the installed baseline tree"
        tail -n 20 "${log_file}" >&2 || true
        return 50
    fi
    rm -rf -- "${INSTALLED_TEMPLATE}"
    mkdir -p "$(dirname "${INSTALLED_TEMPLATE}")"
    cp -a -- "${FIXTURES_DIR}/medium/node_modules" "${INSTALLED_TEMPLATE}" || {
        log_message "ERROR: could not copy the installed baseline tree"
        return 50
    }
    rm -rf -- "${FIXTURES_DIR}/medium/node_modules"
    log_message "installed baseline tree is ready with $(count_installed_packages "${INSTALLED_TEMPLATE}") packages"
}

measure_scenario() {
    local scenario="$1"
    local fixture workdir count_root directory i
    fixture="$(scenario_fixture "${scenario}")" || return 10
    workdir="${FIXTURES_DIR}/${fixture}"
    count_root="${workdir}/node_modules"
    directory="${RUNS_DIR}/${scenario}"
    mkdir -p "${directory}"
    scenario_command "${scenario}" || return 10
    # The recorded command is the workload description, not a local path: the
    # npm wrapper lives under an architecture and run specific work directory, so
    # a verbatim command line would make the cross-architecture parameter
    # signature differ for reasons that have nothing to do with the workload.
    local command_text="${SCENARIO_ARGV[*]}"
    command_text="${command_text/"${NPM_WRAPPER}"/npm}"
    printf '%s\n' "${command_text}" > "${directory}/command.txt"

    log_message "scenario ${scenario}: warmup"
    reset_scenario_state "${scenario}" || return $?
    run_timed_command "${scenario}" warmup "${workdir}" "${count_root}" \
        "${SCENARIO_ARGV[@]}" || return 50

    for ((i = 1; i <= NPM_REPS; i++)); do
        log_message "scenario ${scenario}: rep ${i}/${NPM_REPS}"
        reset_scenario_state "${scenario}" || return $?
        run_timed_command "${scenario}" "rep${i}" "${workdir}" "${count_root}" \
            "${SCENARIO_ARGV[@]}" || return 50
    done
    log_message "scenario ${scenario} completed"
}

run_npm_benchmarks() {
    initialize_runtime || return $?
    validate_reps || return $?
    [[ -x "${NPM_WRAPPER}" ]] || {
        log_message "ERROR: the npm launcher is unavailable: ${NPM_WRAPPER}"
        return 40
    }
    [[ -f "${FIXTURE_METADATA}" ]] || {
        log_message "ERROR: fixture metadata is unavailable: ${FIXTURE_METADATA}"
        return 40
    }
    rm -rf -- "${RUNS_DIR}"
    mkdir -p "${RUNS_DIR}"
    prepare_installed_template || return $?

    local scenario fixture
    for scenario in "${NPM_SCENARIOS[@]}"; do
        measure_scenario "${scenario}" || return $?
    done

    for fixture in "${NPM_FIXTURES[@]}"; do
        rm -rf -- "${FIXTURES_DIR}/${fixture}/node_modules"
        prepare_fixture_clean "${fixture}" || return 50
    done
    rm -rf -- "${INSTALLED_TEMPLATE}"

    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT
    export NPM_FIXTURE_METADATA="${FIXTURE_METADATA}"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RUNS_DIR}" "${RESULTS_DIR}/results.json" || return $?
    log_message "complete npm matrix finished (reps=${NPM_REPS}, scenarios=${#NPM_SCENARIOS[@]})"
}
