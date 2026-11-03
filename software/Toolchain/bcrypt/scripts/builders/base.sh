#!/usr/bin/env bash
#
# Build stage for the bcrypt case.
#
# Installs the pinned Node.js runtime, stages the pinned bcrypt release and the
# vendored native-module dependency tree, verifies the prebuilt N-API binary for
# the target architecture, loads the module once and prefetches every scenario.
# Everything after the host-side download/verification of the pinned archives
# runs inside this task's private openEuler container.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

require_host_transfer_commands() {
    local packages=() command_name package
    for command_name in curl sha256sum tar python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;;
            sha256sum) package=coreutils ;;
            tar) package=tar ;;
            python3) package=python3 ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    log_message "WARNING: host download tools are incomplete: ${packages[*]}; relying on the pre-placed offline archives"
    return 0
}

prepare_bcrypt_build_container() {
    local -a dnf_options=()
    require_host_transfer_commands
    require_bcrypt_docker || return 30
    start_bcrypt_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    log_message 'installing Node.js runtime prerequisites inside the private container'
    bcrypt_container_exec_root dnf "${dnf_options[@]}" install -y \
        tar xz gzip coreutils findutils glibc libstdc++ python3 || {
        log_message "ERROR: container build dependencies failed"
        return 30
    }
}

install_pinned_node() {
    local tarball sha256 url candidate downloaded=0
    tarball="$(node_tarball)"
    sha256="$(node_sha256)"
    mkdir -p "${NODE_HOME}"
    candidate="${BCRYPT_OFFLINE_DIR}/${tarball}"
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
                    if mkdir -p "${BCRYPT_OFFLINE_DIR}" 2>/dev/null && cp -f "${target}" "${candidate}" 2>/dev/null; then
                        log_message "cached the Node.js archive at ${candidate}"
                    else
                        log_message "WARNING: cannot cache the Node.js archive under ${BCRYPT_OFFLINE_DIR}; using ${target}"
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
    # The private container only mounts the task work/results directories and the
    # read-only case directory, so the verified archive is staged into the work
    # directory on the host before the container extracts it.
    local staged_archive="${PERF_WORK_DIR}/downloads/${tarball}"
    mkdir -p "${PERF_WORK_DIR}/downloads"
    if [[ "${candidate}" != "${staged_archive}" ]]; then
        cp -f "${candidate}" "${staged_archive}" || {
            log_message "ERROR: failed to stage the Node.js archive into ${PERF_WORK_DIR}"
            return 30
        }
    fi
    bcrypt_container_exec tar -xJf "${staged_archive}" -C "${NODE_HOME}" || return 30
    if ! bcrypt_container_exec test -x "${NODE_BIN}"; then
        log_message "ERROR: Node.js binary is missing after extraction: ${NODE_BIN}"
        return 30
    fi
    local reported
    reported="$(bcrypt_container_exec "${NODE_BIN}" --version 2>/dev/null || true)"
    if [[ "${reported}" != "${NODE_VERSION}" ]]; then
        log_message "ERROR: expected node ${NODE_VERSION}, extracted ${reported:-unknown}"
        return 30
    fi
    log_message "Node.js ${NODE_VERSION} installed at ${NODE_DIR} inside the private container"
}

stage_application() {
    local deps="${SCRIPT_DIR}/fixtures/${DEPS_TARBALL}"
    local tarball="${SCRIPT_DIR}/fixtures/${BCRYPT_TARBALL}"
    local staging native_file expected_native
    [[ -f "${deps}" ]] || { log_message "ERROR: vendored dependency archive is missing: ${deps}"; return 30; }
    [[ "$(file_sha256 "${deps}")" == "${DEPS_SHA256}" ]] || { log_message "ERROR: dependency archive SHA-256 mismatch"; return 30; }
    [[ -f "${tarball}" ]] || { log_message "ERROR: vendored bcrypt tarball is missing: ${tarball}"; return 30; }
    [[ "$(file_sha256 "${tarball}")" == "${BCRYPT_SHA256}" ]] || { log_message "ERROR: bcrypt tarball SHA-256 mismatch"; return 30; }

    bcrypt_container_exec rm -rf "${APP_DIR}" || return 30
    bcrypt_container_exec mkdir -p "${APP_DIR}" || return 30
    bcrypt_container_exec tar -xzf "${deps}" -C "${APP_DIR}" || return 30
    staging="${TMPDIR}/bcrypt-package"
    bcrypt_container_exec rm -rf "${staging}" || return 30
    bcrypt_container_exec mkdir -p "${staging}" || return 30
    bcrypt_container_exec tar -xzf "${tarball}" -C "${staging}" || return 30
    bcrypt_container_exec rm -rf "${APP_DIR}/node_modules/bcrypt" || return 30
    bcrypt_container_exec cp -a "${staging}/package" "${APP_DIR}/node_modules/bcrypt" || return 30
    bcrypt_container_exec rm -rf "${staging}" || return 30

    local package_dir="${APP_DIR}/node_modules/bcrypt"
    [[ "$(file_sha256 "${package_dir}/package.json")" == "${BCRYPT_PACKAGE_SHA256}" ]] || {
        log_message "ERROR: staged bcrypt package.json differs from the pinned release"; return 30; }
    [[ "$(file_sha256 "${package_dir}/bcrypt.js")" == "${BCRYPT_JS_SHA256}" ]] || {
        log_message "ERROR: staged bcrypt.js differs from the pinned release"; return 30; }
    [[ "$(file_sha256 "${package_dir}/binding.gyp")" == "${BCRYPT_BINDING_SHA256}" ]] || {
        log_message "ERROR: staged binding.gyp differs from the pinned release"; return 30; }

    expected_native="$(native_sha256)"
    native_file="${package_dir}/prebuilds/linux-x64/bcrypt.glibc.node"
    if [[ "$(normalize_architecture "${EXPECTED_ARCH}")" == "aarch64" ]]; then
        native_file="${package_dir}/prebuilds/linux-arm64/bcrypt.glibc.node"
    fi
    [[ -f "${native_file}" ]] || { log_message "ERROR: prebuilt N-API binary is missing: ${native_file}"; return 30; }
    [[ "$(file_sha256 "${native_file}")" == "${expected_native}" ]] || {
        log_message "ERROR: prebuilt N-API binary SHA-256 mismatch: ${native_file}"; return 30; }

    local entry name expected actual
    for entry in "${BCRYPT_DEPENDENCIES[@]}"; do
        name="${entry%%=*}"
        expected="${entry#*=}"
        actual="$(bcrypt_container_exec "${NODE_BIN}" -e "process.stdout.write(require('${APP_DIR}/node_modules/${name}/package.json').version)")"
        if [[ "${actual}" != "${expected}" ]]; then
            log_message "ERROR: dependency ${name} is ${actual}, expected ${expected}"
            return 30
        fi
    done
    local bcrypt_version
    bcrypt_version="$(bcrypt_container_exec "${NODE_BIN}" -e "process.stdout.write(require('${package_dir}/package.json').version)")"
    if [[ "${bcrypt_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: staged bcrypt is ${bcrypt_version}, expected ${SOFTWARE_VERSION}"
        return 30
    fi
    log_message "bcrypt ${bcrypt_version} staged with a verified prebuilt N-API binary (${native_file##*/})"
}

smoke_test_module() {
    log_message "loading the native module once (prebuild, napi ${NODE_VERSION}) inside the private container"
    local output
    if ! output="$(bcrypt_container_exec "${NODE_BIN}" -e "
const bcrypt = require('${APP_DIR}/node_modules/bcrypt');
const salt = bcrypt.genSaltSync(4);
const hash = bcrypt.hashSync('smoke-password', salt);
if (!bcrypt.compareSync('smoke-password', hash)) { throw new Error('compare returned false'); }
process.stdout.write(JSON.stringify({version: require('${APP_DIR}/node_modules/bcrypt/package.json').version, napi: process.versions.napi}));
" 2>&1)"; then
        log_message "ERROR: the native bcrypt module failed to load or hash:"
        printf '%s\n' "${output}" >&2
        return 30
    fi
    log_message "native module ready: ${output}"
    printf '%s\n' "${SOFTWARE_VERSION}" >"${PERF_ACTUAL_VERSION_FILE}"
}

prefetch_scenarios() {
    local scenario warmup_dir
    warmup_dir="${PERF_WORK_DIR}/prefetch"
    rm -rf "${warmup_dir}"
    mkdir -p "${warmup_dir}"
    for scenario in "${BCRYPT_SCENARIOS[@]}"; do
        log_message "prefetching scenario ${scenario} inside the private container"
        if ! bcrypt_container_exec "${NODE_BIN}" "${SCRIPT_DIR}/fixtures/bcrypt_runner.js" \
            --scenarios "${SCENARIOS_FILE}" --scenario "${scenario}" --mode prefetch \
            --module-dir "${APP_DIR}/node_modules" >"${warmup_dir}/${scenario}.log" 2>&1; then
            log_message "ERROR: prefetch failed for ${scenario}"
            tail -n 20 "${warmup_dir}/${scenario}.log" >&2 || true
            return 30
        fi
        if ! grep -q '^\[bcrypt-bench\] ' "${warmup_dir}/${scenario}.log"; then
            log_message "ERROR: prefetch of ${scenario} produced no evidence line"
            return 30
        fi
    done
    log_message "all ${#BCRYPT_SCENARIOS[@]} scenarios prefetched"
}

write_runtime_record() {
    # The runtime record is produced inside the container so that the recorded
    # Node.js/bcrypt versions and the machine identity describe the measured
    # environment.
    bcrypt_container_exec python3 "${SCRIPT_DIR}/scripts/results/write_runtime.py" \
        --scenarios "${SCENARIOS_FILE}" \
        --output "${RUNTIME_JSON}" \
        --node-bin "${NODE_BIN}" \
        --app-dir "${APP_DIR}" \
        --native-sha256 "$(native_sha256)" || return 30
}

write_build_variant() {
    python3 "${SCRIPT_DIR}/scripts/results/write_build_variant.py" \
        --output "${RESULTS_DIR}/build_variant.json" \
        --scenarios "${SCENARIOS_FILE}" \
        --runtime "${RUNTIME_JSON}" \
        --node-version "${NODE_VERSION}" \
        --node-sha256 "$(node_sha256)" \
        --bcrypt-sha256 "${BCRYPT_SHA256}" \
        --deps-sha256 "${DEPS_SHA256}" \
        --reps "${BCRYPT_REPS}" \
        --warmups "${BCRYPT_WARMUPS}" || return 30
}

build_bcrypt_base() {
    initialize_runtime || return $?
    prepare_bcrypt_build_container || return $?
    validate_reps || return $?
    check_architecture || return $?
    install_pinned_node || return 30
    stage_application || return 30
    smoke_test_module || return 30
    prefetch_scenarios || return 30
    write_runtime_record || return 30
    write_build_variant || return 30
    if [[ ! -s "${RESULTS_DIR}/build_variant.json" ]]; then
        log_message "ERROR: build variant metadata was not written"
        return 30
    fi
    log_message "build finished"
}