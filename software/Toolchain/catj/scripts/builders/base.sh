#!/usr/bin/env bash
#
# Build stage for the catj case.
#
# The pinned Node.js archive is downloaded and SHA-256 verified on the host and
# extracted inside the task's private openEuler container; staging the vendored
# catj release, regenerating the fixed JSON inputs and running every scenario
# once as a cold-cache correctness gate all execute in that container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_catj_build_container() {
    local -a dnf_options=(--setopt=install_weak_deps=False)
    require_catj_docker || return 30
    start_catj_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message "installing the Node.js runtime and build prerequisites inside the private container"
    catj_container_exec_root dnf "${dnf_options[@]}" install -y \
        tar xz gzip coreutils findutils sed gawk grep glibc libstdc++ python3 || {
        log_message "ERROR: container build dependencies failed to install"
        return 30
    }
}

catj_node() {
    catj_container_exec "${NODE_BIN}" "$@"
}

catj_node_eval() {
    catj_container_exec "${NODE_BIN}" -e "$1"
}

install_pinned_node() {
    local tarball sha256 url candidate downloaded=0
    tarball="$(node_tarball)"
    sha256="$(node_sha256)"
    mkdir -p "${NODE_HOME}"
    candidate="${CATJ_OFFLINE_DIR}/${tarball}"
    if [[ -f "${candidate}" ]]; then
        if [[ "$(file_sha256 "${candidate}")" == "${sha256}" ]]; then
            log_message "using offline Node.js archive from the runner: ${candidate}"
            downloaded=1
        else
            log_message "ERROR: offline Node.js archive has an unexpected SHA-256: ${candidate}"
            return 30
        fi
    fi
    if [[ "${downloaded}" -eq 0 ]]; then
        local target="${TMPDIR}/${tarball}"
        while IFS= read -r url; do
            log_message "downloading Node.js ${NODE_VERSION} from ${url}"
            if curl -fsSL --retry 2 --connect-timeout 20 -o "${target}" "${url}"; then
                if [[ "$(file_sha256 "${target}")" == "${sha256}" ]]; then
                    if mkdir -p "${CATJ_OFFLINE_DIR}" 2>/dev/null && cp -f "${target}" "${candidate}" 2>/dev/null; then
                        log_message "cached the Node.js archive at ${candidate}"
                    else
                        log_message "WARNING: cannot cache the Node.js archive under ${CATJ_OFFLINE_DIR}; using ${target}"
                        candidate="${target}"
                    fi
                    downloaded=1
                    break
                fi
                log_message "WARNING: SHA-256 mismatch from ${url}, trying the next mirror"
            fi
        done < <(node_urls)
    fi
    if [[ "${downloaded}" -ne 1 ]]; then
        log_message "ERROR: no Node.js ${NODE_VERSION} archive passed SHA-256 verification; tried:"
        while IFS= read -r url; do log_message "  ${url}"; done < <(node_urls)
        return 30
    fi
    # The private container only sees the case directory, ${PERF_WORK_DIR} and
    # ${RESULTS_DIR}, so the verified archive is staged into the work directory
    # before the container extracts it.
    local archive="${PERF_WORK_DIR}/downloads/${tarball}"
    mkdir -p "${PERF_WORK_DIR}/downloads"
    if [[ "${candidate}" != "${archive}" ]]; then
        cp -f -- "${candidate}" "${archive}" || {
            log_message "ERROR: cannot stage the Node.js archive into ${PERF_WORK_DIR}"
            return 30
        }
    fi
    log_message "extracting Node.js ${NODE_VERSION} inside the private container"
    catj_container_exec rm -rf "${NODE_DIR}"
    catj_container_exec tar -xJf "${archive}" -C "${NODE_HOME}" || return 30
    if ! catj_container_exec test -x "${NODE_BIN}"; then
        log_message "ERROR: Node.js binary is missing after extraction: ${NODE_BIN}"
        return 30
    fi
    local reported
    reported="$(catj_node --version 2>/dev/null || true)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected node ${NODE_VERSION}, extracted ${reported:-unknown}"
        return 30
    fi
    log_message "Node.js ${NODE_VERSION} installed at ${NODE_DIR} and runnable inside the private container"
}

stage_application() {
    local deps="${SCRIPT_DIR}/fixtures/${DEPS_TARBALL}"
    local tarball="${SCRIPT_DIR}/fixtures/${CATJ_TARBALL}"
    local staging
    if [[ ! -f "${deps}" ]]; then
        log_message "ERROR: vendored dependency archive is missing: ${deps}"
        return 30
    fi
    if [[ "$(file_sha256 "${deps}")" != "${DEPS_SHA256}" ]]; then
        log_message "ERROR: vendored dependency archive does not match its pinned SHA-256: ${deps}"
        return 30
    fi
    if [[ ! -f "${tarball}" ]]; then
        log_message "ERROR: vendored catj tarball is missing: ${tarball}"
        return 30
    fi
    if [[ "$(file_sha256 "${tarball}")" != "${CATJ_SHA256}" ]]; then
        log_message "ERROR: vendored catj tarball does not match its pinned SHA-256: ${tarball}"
        return 30
    fi

    rm -rf "${APP_DIR}"
    mkdir -p "${APP_DIR}"
    tar -xzf "${deps}" -C "${APP_DIR}" || return 30
    staging="${TMPDIR}/catj-package"
    rm -rf "${staging}"
    mkdir -p "${staging}"
    tar -xzf "${tarball}" -C "${staging}" || return 30
    rm -rf "${APP_DIR}/node_modules/catj"
    cp -a "${staging}/package" "${APP_DIR}/node_modules/catj" || return 30
    rm -rf "${staging}"

    local package_json="${APP_DIR}/node_modules/catj/package.json"
    local cli="${APP_DIR}/node_modules/catj/catj.js"
    if [[ "$(file_sha256 "${package_json}")" != "${CATJ_PACKAGE_SHA256}" ]]; then
        log_message "ERROR: staged catj package.json differs from the pinned upstream file"
        return 30
    fi
    if [[ "$(file_sha256 "${cli}")" != "${CATJ_CLI_SHA256}" ]]; then
        log_message "ERROR: staged catj.js differs from the pinned upstream file"
        return 30
    fi

    local entry dependency expected name version actual
    for entry in "${CATJ_DEPENDENCIES[@]}"; do
        name="${entry%%=*}"
        expected="${entry#*=}"
        actual="$(catj_node_eval "process.stdout.write(require('${APP_DIR}/node_modules/${name}/package.json').version)")"
        if [[ "${actual}" != "${expected}" ]]; then
            log_message "ERROR: dependency ${name} is ${actual}, expected ${expected}"
            return 30
        fi
    done
    local catj_version
    catj_version="$(catj_node_eval "process.stdout.write(require('${package_json}').version)")"
    if [[ "${catj_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: staged catj is ${catj_version}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    printf '%s\n' "${catj_version}" >"${PERF_ACTUAL_VERSION_FILE}"
    log_message "catj ${catj_version} staged with ${#CATJ_DEPENDENCIES[@]} pinned dependencies (node ${NODE_VERSION})"
}

generate_inputs() {
    rm -rf "${INPUT_DIR}"
    mkdir -p "${INPUT_DIR}"
    log_message "generating the fixed JSON inputs inside the private container"
    if ! catj_container_exec_at "${PERF_WORK_DIR}" \
        "${NODE_BIN}" "${SCRIPT_DIR}/fixtures/generate_inputs.js" \
        --scenarios "${SCENARIOS_FILE}" --out "${INPUT_DIR}" >"${TMPDIR}/generate-inputs.log" 2>&1; then
        log_message "ERROR: JSON input generation failed"
        tail -n 20 "${TMPDIR}/generate-inputs.log" >&2 || true
        return 30
    fi
    cat "${TMPDIR}/generate-inputs.log"
    local name expected actual bytes
    while read -r name expected bytes; do
        actual="$(file_sha256 "${INPUT_DIR}/${name}")"
        if [[ "${actual}" != "${expected}" ]]; then
            log_message "ERROR: input ${name} has SHA-256 ${actual}, expected ${expected}"
            return 30
        fi
        if [[ "$(stat -c %s "${INPUT_DIR}/${name}")" != "${bytes}" ]]; then
            log_message "ERROR: input ${name} has an unexpected size"
            return 30
        fi
    done < <(python3 "${SCRIPT_DIR}/scripts/results/scenario_info.py" \
        --scenarios "${SCENARIOS_FILE}" --list-inputs)
    log_message "all JSON inputs verified against the pinned SHA-256 values"
}

prefetch_scenarios() {
    local scenario info input_file mode iterations warmup_dir
    warmup_dir="${PERF_WORK_DIR}/prefetch"
    rm -rf "${warmup_dir}"
    mkdir -p "${warmup_dir}"
    for scenario in "${CATJ_SCENARIOS[@]}"; do
        read -r input_file mode iterations < <(python3 "${SCRIPT_DIR}/scripts/results/scenario_info.py" \
            --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --fields)
        log_message "prefetching scenario ${scenario} (${mode} mode, ${iterations} call(s))"
        if [[ "${mode}" == stdin ]]; then
            # `docker exec` does not forward the host's stdin, so the input file
            # is read with a redirection inside the container.
            catj_container_exec_at "${PERF_WORK_DIR}" sh -c \
                "FORCE_COLOR=0 '${NODE_BIN}' '${APP_DIR}/node_modules/catj/catj.js' < '${INPUT_DIR}/${input_file}'" \
                >"${warmup_dir}/${scenario}.out" 2>"${warmup_dir}/${scenario}.err"
        else
            catj_container_exec_at "${PERF_WORK_DIR}" \
                env FORCE_COLOR=0 "${NODE_BIN}" "${APP_DIR}/node_modules/catj/catj.js" "${INPUT_DIR}/${input_file}" \
                >"${warmup_dir}/${scenario}.out" 2>"${warmup_dir}/${scenario}.err"
        fi
        if ! python3 "${SCRIPT_DIR}/scripts/results/verify_output.py" \
            --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" \
            --output "${warmup_dir}/${scenario}.out" >/dev/null; then
            log_message "ERROR: prefetch output verification failed for ${scenario}"
            return 30
        fi
    done
    log_message "all ${#CATJ_SCENARIOS[@]} scenarios prefetched and verified"
}

write_runtime_record() {
    catj_container_exec_at "${PERF_WORK_DIR}" \
        python3 "${SCRIPT_DIR}/scripts/results/write_runtime.py" \
        --scenarios "${SCENARIOS_FILE}" \
        --output "${RUNTIME_JSON}" \
        --node-bin "${NODE_BIN}" \
        --app-dir "${APP_DIR}" \
        --input-dir "${INPUT_DIR}" || return 30
}

write_build_variant() {
    python3 "${SCRIPT_DIR}/scripts/results/write_build_variant.py" \
        --output "${RESULTS_DIR}/build_variant.json" \
        --scenarios "${SCENARIOS_FILE}" \
        --runtime "${RUNTIME_JSON}" \
        --node-version "${NODE_VERSION}" \
        --node-sha256 "$(node_sha256)" \
        --catj-sha256 "${CATJ_SHA256}" \
        --deps-sha256 "${DEPS_SHA256}" \
        --reps "${CATJ_REPS}" \
        --warmups "${CATJ_WARMUPS}" || return 30
}

build_catj_base() {
    initialize_runtime || return $?
    validate_reps || return $?
    check_architecture || return $?
    prepare_catj_build_container || return $?
    install_pinned_node || return 30
    stage_application || return 30
    generate_inputs || return 30
    write_runtime_record || return 30
    prefetch_scenarios || return 30
    write_build_variant || return 30
    if [[ ! -s "${RESULTS_DIR}/build_variant.json" ]]; then
        log_message "ERROR: build variant metadata was not written"
        return 30
    fi
    log_message "build finished"
}
