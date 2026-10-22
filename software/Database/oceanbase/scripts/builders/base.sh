#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# ---------------------------------------------------------------------------
# 依赖安装（仅 build 阶段使用）
# ---------------------------------------------------------------------------
install_oceanbase_dependencies() {
    local command_name package actual_version
    local -a packages=() dnf_options=() oceanbase_repo=()

    for command_name in python3 mysql git make gcc openssl autoreconf automake libtoolize pkg-config mysql_config; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            mysql) package=mariadb ;;
            autoreconf) package=autoconf ;;
            automake) package=automake ;;
            libtoolize) package=libtool ;;
            pkg-config) package=pkgconf-pkg-config ;;
            mysql_config) package=mariadb-connector-c-devel ;;
            *) package="${command_name}" ;;
        esac
        packages+=("${package}")
    done
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if [[ "${#packages[@]}" -gt 0 ]]; then
        log_message "installing missing test dependencies: ${packages[*]}"
        if [[ "${EUID}" -eq 0 ]]; then
            dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        else
            sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}" || return 30
        fi
    fi
    actual_version="$(obd --version 2>/dev/null || true)"
    if [[ "${actual_version}" != *"${OBD_VERSION}"* ]]; then
        oceanbase_repo=(
            "--repofrompath=oceanbase-official,https://mirrors.oceanbase.com/community/stable/el/8/$(uname -m)/"
            --setopt=oceanbase-official.gpgcheck=0
        )
        log_message "installing OceanBase Deployer ${OBD_VERSION} from the official repository without changing system repo files"
        if [[ "${EUID}" -eq 0 ]]; then
            dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" install -y ob-deploy-4.6.0-16.el8 || return 30
        else
            sudo -n dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" install -y ob-deploy-4.6.0-16.el8 || return 30
        fi
    fi
    actual_version="$(obd --version 2>/dev/null || true)"
    [[ "${actual_version}" == *"${OBD_VERSION}"* ]] || {
        log_message "ERROR: expected obd ${OBD_VERSION}, found ${actual_version:-unavailable}"
        return 30
    }
}

prepare_sysbench() {
    local source_dir="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20"
    local actual_version actual_commit

    if [[ -x "${SYSBENCH_BIN}" ]]; then
        actual_version="$("${SYSBENCH_BIN}" --version 2>&1)"
        [[ "${actual_version}" == "sysbench ${SYSBENCH_VERSION}"* ]] && return 0
    fi
    mkdir -p "$(dirname "${source_dir}")"
    if [[ -e "${source_dir}" ]]; then
        log_message "reusing private Sysbench source directory: ${source_dir}"
    else
        log_message "cloning upstream Sysbench ${SYSBENCH_VERSION} into the private work directory"
        git clone --quiet --depth 1 --branch "${SYSBENCH_VERSION}" \
            https://github.com/akopytov/sysbench.git "${source_dir}" || return 30
    fi
    actual_commit="$(git -C "${source_dir}" rev-parse --short=7 HEAD 2>/dev/null || true)"
    if [[ "${actual_commit}" != ebf1c90 ]]; then
        log_message "ERROR: Sysbench tag resolved to ${actual_commit}, expected ebf1c90"
        return 30
    fi
    (
        cd "${source_dir}"
        ./autogen.sh
        ./configure --with-mysql
        make -j"$(getconf _NPROCESSORS_ONLN)"
    ) || return 30
    actual_version="$("${SYSBENCH_BIN}" --version 2>&1)"
    if [[ "${actual_version}" != "sysbench ${SYSBENCH_VERSION}"* ]]; then
        log_message "ERROR: expected Sysbench ${SYSBENCH_VERSION}, found ${actual_version}"
        return 30
    fi
    for actual_commit in read_only insert read_write write_only; do
        [[ -f "${SYSBENCH_LUA_DIR}/oltp_${actual_commit}.lua" ]] || {
            log_message "ERROR: missing Sysbench workload script: oltp_${actual_commit}.lua"
            return 30
        }
    done
}

prepare_oceanbase_packages() {
    local architecture observer_rpm proxy_rpm
    local -a dnf_options=() oceanbase_repo=()

    architecture="$(uname -m)"
    observer_rpm="${OB_PACKAGE_DIR}/oceanbase-ce-${SOFTWARE_VERSION}-${OBSERVER_RPM_RELEASE}.el8.${architecture}.rpm"
    proxy_rpm="${OB_PACKAGE_DIR}/obproxy-ce-${OB_PROXY_VERSION}-${OBPROXY_RPM_RELEASE}.el8.${architecture}.rpm"
    mkdir -p "${OB_PACKAGE_DIR}"
    if [[ ! -s "${observer_rpm}" || ! -s "${proxy_rpm}" ]]; then
        [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
        if ! dnf download --help >/dev/null 2>&1; then
            log_message 'installing dnf-plugins-core for verified RPM downloads'
            if [[ "${EUID}" -eq 0 ]]; then
                dnf "${dnf_options[@]}" install -y dnf-plugins-core || return 30
            else
                sudo -n dnf "${dnf_options[@]}" install -y dnf-plugins-core || return 30
            fi
        fi
        oceanbase_repo=(
            "--repofrompath=oceanbase-official,https://mirrors.oceanbase.com/community/stable/el/8/${architecture}/"
            --disablerepo='*' --enablerepo=oceanbase-official
        )
        log_message "downloading official OceanBase ${SOFTWARE_VERSION} and OBProxy ${OB_PROXY_VERSION} RPMs"
        dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" download \
            "--destdir=${OB_PACKAGE_DIR}" \
            "oceanbase-ce-${SOFTWARE_VERSION}-${OBSERVER_RPM_RELEASE}.el8" \
            "obproxy-ce-${OB_PROXY_VERSION}-${OBPROXY_RPM_RELEASE}.el8" || return 30
    fi
    if [[ ! -s "${observer_rpm}" || ! -s "${proxy_rpm}" ]]; then
        log_message 'ERROR: expected OceanBase or OBProxy RPM is missing after download'
        return 30
    fi
    obd mirror clone "${observer_rpm}" -f || return 30
    obd mirror clone "${proxy_rpm}" -f || return 30
    obd mirror disable remote || return 30
}

# ---------------------------------------------------------------------------
# 部署前校验（仅 build 阶段使用）
# ---------------------------------------------------------------------------
check_deployment_disk_space() {
    local available_bytes required_bytes

    available_bytes="$(df -B1 --output=avail -- "${PERF_WORK_DIR}" | awk 'NR == 2 { print $1 }')" || {
        log_message "ERROR: could not check free disk space at ${PERF_WORK_DIR}"
        return 40
    }
    if [[ ! "${available_bytes}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: invalid free disk space at ${PERF_WORK_DIR}: ${available_bytes:-unknown}"
        return 40
    fi
    # Both fixed-size files share the private deployment filesystem.
    required_bytes=$(( (${OB_DATAFILE_SIZE%G} + ${OB_LOG_DISK_SIZE%G} + 32) * 1024 * 1024 * 1024 ))
    if (( available_bytes < required_bytes )); then
        log_message "ERROR: ${PERF_WORK_DIR} has ${available_bytes} free bytes; deployment needs at least ${required_bytes} bytes for the ${OB_DATAFILE_SIZE} data file, ${OB_LOG_DISK_SIZE} log disk and other files"
        return 40
    fi
    log_message "deployment filesystem has ${available_bytes} free bytes"
}

configure_sys_tenant_memory() {
    local memory_bytes

    log_message "setting sys tenant memory to ${OB_SYS_TENANT_MEMORY}"
    if ! ob_mysql -e "ALTER RESOURCE UNIT sys_unit_config MEMORY_SIZE='${OB_SYS_TENANT_MEMORY}'"; then
        log_message 'ERROR: could not increase the sys tenant memory quota'
        return 40
    fi
    memory_bytes="$(ob_mysql -N -s -e \
        "SELECT MEMORY_SIZE FROM oceanbase.DBA_OB_UNIT_CONFIGS WHERE NAME = 'sys_unit_config'" 2>/dev/null)" || {
        log_message 'ERROR: could not verify the sys tenant memory quota'
        return 40
    }
    if [[ "${memory_bytes}" != "$((16 * 1024 * 1024 * 1024))" ]]; then
        log_message "ERROR: sys tenant memory quota is ${memory_bytes:-unknown} bytes, expected 17179869184"
        return 40
    fi
}

check_test_tenant_memory() {
    local available_bytes required_bytes

    available_bytes="$(ob_mysql -N -s -e \
        "SELECT MIN(MEM_CAPACITY - MEM_ASSIGNED) FROM oceanbase.GV\$OB_SERVERS WHERE SVR_IP = '${OB_HOST}'" \
        2>/dev/null)" || {
        log_message 'ERROR: could not query observer memory available for the test tenant'
        return 40
    }
    available_bytes="$(printf '%s' "${available_bytes}" | tr -d '\r\n\t')"
    if [[ ! "${available_bytes}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: invalid observer memory availability: ${available_bytes:-unknown}"
        return 40
    fi
    required_bytes=$(( ${OB_TEST_TENANT_MEMORY%G} * 1024 * 1024 * 1024 ))
    if (( available_bytes < required_bytes )); then
        log_message "ERROR: test tenant needs ${OB_TEST_TENANT_MEMORY}, observer has only ${available_bytes} available bytes"
        return 40
    fi
    log_message "observer has ${available_bytes} bytes available for the ${OB_TEST_TENANT_MEMORY} test tenant"
}

check_observer_data_disk() {
    local capacity_bytes required_bytes

    capacity_bytes="$(ob_mysql -N -s -e \
        "SELECT MIN(DATA_DISK_CAPACITY) FROM oceanbase.GV\$OB_SERVERS WHERE SVR_IP = '${OB_HOST}'" \
        2>/dev/null)" || {
        log_message 'ERROR: could not query observer data disk capacity'
        return 40
    }
    capacity_bytes="$(printf '%s' "${capacity_bytes}" | tr -d '\r\n\t')"
    if [[ ! "${capacity_bytes}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: invalid observer data disk capacity: ${capacity_bytes:-unknown}"
        return 40
    fi
    required_bytes=$(( ${OB_DATAFILE_SIZE%G} * 1024 * 1024 * 1024 ))
    if (( capacity_bytes < required_bytes )); then
        log_message "ERROR: observer data disk capacity is ${capacity_bytes} bytes, expected at least ${required_bytes} bytes"
        return 40
    fi
    log_message "observer data disk capacity is ${capacity_bytes} bytes (expected at least ${required_bytes})"
}

check_test_tenant_log_disk() {
    local available_bytes required_bytes

    available_bytes="$(ob_mysql -N -s -e \
        "SELECT MIN(LOG_DISK_CAPACITY - LOG_DISK_ASSIGNED) FROM oceanbase.GV\$OB_SERVERS WHERE SVR_IP = '${OB_HOST}'" \
        2>/dev/null)" || {
        log_message 'ERROR: could not query observer log disk available for the test tenant'
        return 40
    }
    available_bytes="$(printf '%s' "${available_bytes}" | tr -d '\r\n\t')"
    if [[ ! "${available_bytes}" =~ ^[0-9]+$ ]]; then
        log_message "ERROR: invalid observer log disk availability: ${available_bytes:-unknown}"
        return 40
    fi
    # OceanBase defaults a tenant's log disk quota to three times its memory.
    required_bytes=$(( ${OB_TEST_TENANT_MEMORY%G} * 3 * 1024 * 1024 * 1024 ))
    if (( available_bytes < required_bytes )); then
        log_message "ERROR: test tenant needs ${required_bytes} log disk bytes, observer has only ${available_bytes} available bytes"
        return 40
    fi
    log_message "observer has ${available_bytes} log disk bytes available for the test tenant (needs ${required_bytes})"
}

collect_deployment_diagnostics() {
    local deploy_log="$1" trace_id log_file
    local trace_output="${PERF_WORK_DIR}/obd-trace.log"
    local obshell_output="${RESULTS_DIR}/obshell-diagnostic.log"

    trace_id="$(grep -oE 'Trace ID: [0-9a-f-]{36}' "${deploy_log}" | tail -n 1 | cut -d ' ' -f 3 || true)"
    if [[ -n "${trace_id}" ]]; then
        if obd display-trace "${trace_id}" > "${trace_output}" 2>&1; then
            tail -n 1000 "${trace_output}" | redact_diagnostic > "${RESULTS_DIR}/obd-trace.log"
        else
            tail -n 1000 "${trace_output}" | redact_diagnostic > "${RESULTS_DIR}/obd-trace.log"
            log_message "WARN: obd display-trace failed for ${trace_id}; partial output was saved"
        fi
    else
        log_message 'WARN: no OBD trace ID found in deployment output'
    fi

    : > "${obshell_output}"
    while IFS= read -r -d '' log_file; do
        printf '\n== %s ==\n' "${log_file#"${OB_DEPLOY_HOME}/"}" >> "${obshell_output}"
        tail -n 300 "${log_file}" | redact_diagnostic >> "${obshell_output}"
    done < <(find "${OB_DEPLOY_HOME}" -type f -path '*/log_obshell/*' -name '*.log' -print0 2>/dev/null)
    [[ -s "${obshell_output}" ]] || rm -f -- "${obshell_output}"
    log_message "deployment diagnostics saved under ${RESULTS_DIR}"
}

capture_proxy_connection_error() {
    local connection_output="${RESULTS_DIR}/obproxy-connection-error.log"
    if proxy_mysql -N -e 'SELECT 1' > "${PERF_WORK_DIR}/proxy-check.log" 2>&1; then
        return 0
    fi
    redact_diagnostic < "${PERF_WORK_DIR}/proxy-check.log" > "${connection_output}"
    log_message "OBProxy connection error: $(tr '\n' ' ' < "${connection_output}")"
    return 1
}

# ---------------------------------------------------------------------------
# 阶段 1：build - 部署 OceanBase observer
# ---------------------------------------------------------------------------
build_oceanbase_base() {
    local runner_architecture actual_version proxy_info attempt deploy_log tenant_log tenant_count

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log_message "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    check_deployment_disk_space || return $?
    install_oceanbase_dependencies || return $?
    prepare_sysbench || return $?
    prepare_oceanbase_packages || return $?

    if (echo > "/dev/tcp/${OB_HOST}/${OB_PORT}") 2>/dev/null ||
       (echo > "/dev/tcp/${OB_HOST}/${OB_PROXY_PORT}") 2>/dev/null; then
        log_message "ERROR: an observer or proxy port is already in use; refusing to touch a pre-existing service"
        return 20
    fi

    log_message "deploying upstream OceanBase ${SOFTWARE_VERSION} with OBProxy ${OB_PROXY_VERSION} via private obd demo"
    mkdir -p "${OBD_HOME}" "${OB_DEPLOY_HOME}"
    if [[ ! -s "${OB_ROOT_PASSWORD_FILE}" ]]; then
        (umask 077; openssl rand -hex 24 > "${OB_ROOT_PASSWORD_FILE}") || return 40
    fi
    deploy_log="${PERF_WORK_DIR}/obd-deploy.log"
    if ! obd demo -c oceanbase-ce,obproxy-ce \
            "--oceanbase-ce.version=${SOFTWARE_VERSION}" \
            "--oceanbase-ce.root_password=$(< "${OB_ROOT_PASSWORD_FILE}")" \
            "--oceanbase-ce.memory_limit=${OB_MEMORY_LIMIT}" \
            "--oceanbase-ce.system_memory=${OB_SYSTEM_MEMORY}" \
            "--oceanbase-ce.datafile_size=${OB_DATAFILE_SIZE}" \
            "--oceanbase-ce.log_disk_size=${OB_LOG_DISK_SIZE}" \
            "--obproxy-ce.version=${OB_PROXY_VERSION}" \
            "--obproxy-ce.proxy_mem_limited=${OB_PROXY_MEMORY_LIMIT}" \
            "--oceanbase-ce.mysql_port=${OB_PORT}" \
            "--oceanbase-ce.rpc_port=${OB_RPC_PORT}" \
            "--obproxy-ce.listen_port=${OB_PROXY_PORT}" \
            "--obproxy-ce.prometheus_listen_port=${OB_PROXY_METRICS_PORT}" \
            "--home_path=${OB_DEPLOY_HOME}" 2>&1 | tee "${deploy_log}" | redact_diagnostic; then
        collect_deployment_diagnostics "${deploy_log}"
        log_message "ERROR: obd demo deployment failed"
        return 40
    fi

    log_message "waiting for the OceanBase observer to become ready"
    for attempt in {1..120}; do
        if check_observer_ready; then
            log_message "observer ready on ${OB_HOST}:${OB_PORT} (after ${attempt} checks)"
            break
        fi
        sleep 3
    done
    if ! check_observer_ready; then
        log_message "ERROR: observer did not become ready on ${OB_HOST}:${OB_PORT}"
        return 40
    fi

    actual_version="$(query_observer_version)"
    actual_version="$(printf '%s' "${actual_version}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log_message "ERROR: deployed observer reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    check_observer_data_disk || return $?
    configure_sys_tenant_memory || return $?
    check_test_tenant_memory || return $?
    check_test_tenant_log_disk || return $?
    log_message "creating MySQL-mode test tenant with ${OB_TEST_TENANT_MEMORY} memory"
    tenant_log="${PERF_WORK_DIR}/tenant-create.log"
    if ! obd cluster tenant create demo -n test \
            "--memory-size=${OB_TEST_TENANT_MEMORY}" 2>&1 | tee "${tenant_log}" | redact_diagnostic; then
        redact_diagnostic < "${tenant_log}" > "${RESULTS_DIR}/tenant-create.log"
        log_message 'ERROR: OBD could not create the test tenant'
        return 40
    fi
    tenant_count="$(ob_mysql -N -s -e \
        "SELECT COUNT(*) FROM oceanbase.DBA_OB_TENANTS WHERE TENANT_NAME = 'test' AND TENANT_TYPE = 'USER' AND COMPATIBILITY_MODE = 'MYSQL'" 2>/dev/null || true)"
    if [[ "${tenant_count}" != 1 ]]; then
        log_message "ERROR: expected one MySQL-mode test tenant, found ${tenant_count:-unknown}"
        return 40
    fi
    for attempt in {1..60}; do
        check_proxy_ready && break
        sleep 3
    done
    if ! check_proxy_ready; then
        capture_proxy_connection_error || true
        collect_deployment_diagnostics "${deploy_log}"
        log_message "ERROR: test tenant is not reachable through OBProxy on ${OB_HOST}:${OB_PROXY_PORT}"
        return 40
    fi
    proxy_info="$(proxy_sys_mysql -N -e 'SHOW PROXYINFO BINARY' 2>/dev/null || true)"
    if [[ "${proxy_info}" != *"${OB_PROXY_VERSION%.*}"* ]]; then
        log_message "ERROR: cannot verify OBProxy ${OB_PROXY_VERSION} from SHOW PROXYINFO BINARY"
        return 40
    fi

    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log_message "OceanBase ${actual_version} and OBProxy ${OB_PROXY_VERSION} deployed"
}
