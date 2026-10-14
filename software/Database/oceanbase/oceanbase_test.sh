#!/usr/bin/env bash
#
# oceanbase_test.sh - OceanBase 性能评估适配脚本（openEuler BoostKit 性能评估框架）。
#
# 实现四个阶段的 shell 函数，供框架（command_adapter）按阶段调用：
#   build_oceanbase         准备 Sysbench，部署 observer 和 OBProxy
#   start_oceanbase_service 确认 observer 和 OBProxy 服务可用
#   run_oceanbase_benchmarks 通过 OBProxy 执行 Sysbench 基准测试
#   stop_oceanbase_service  停止本次任务的 OceanBase 集群
#
# 同时支持脱离项目根目录的独立执行（source 本文件不会运行任何内容）：
#   ./oceanbase_test.sh [--version 4.2.5.6] [--results-dir DIR] [--keep-workdir]
#
# 部署说明：OceanBase 属于“部署服务型”软件（区别于源码编译型，如 RocksDB），
# build 阶段使用 OceanBase Deployer（obd）的 demo 命令在任务私有目录内部署单机
# 演示集群，并通过独立端口与独立 OBD_HOME 保证任务隔离；start/test 阶段通过
# mysql 协议经 OBProxy 连接 test 租户执行 Sysbench OLTP 测试。

set -euo pipefail

# ---------------------------------------------------------------------------
# 公共变量（可被框架环境变量覆盖）
# ---------------------------------------------------------------------------
SOFTWARE_NAME="${SOFTWARE_NAME:-oceanbase}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.2.5.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
EXPECTED_ARCH="${EXPECTED_ARCH/x86_64/x86_64}"
EXPECTED_ARCH="${EXPECTED_ARCH/amd64/x86_64}"
EXPECTED_ARCH="${EXPECTED_ARCH/aarch64/aarch64}"
EXPECTED_ARCH="${EXPECTED_ARCH/arm64/aarch64}"

PERF_RUN_ID="${PERF_RUN_ID:-local-$(date +%Y%m%d-%H%M%S)}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

# OceanBase 运行/连接配置
OB_HOST="127.0.0.1"
OB_PORT="${OB_PORT:-}"
OB_RPC_PORT="${OB_RPC_PORT:-}"
OB_PROXY_PORT="${OB_PROXY_PORT:-}"
OB_PROXY_METRICS_PORT="${OB_PROXY_METRICS_PORT:-}"
OB_DB="obtest"
OB_PROXY_VERSION="4.3.6.1"
OBD_VERSION="4.6.0"
OBSERVER_RPM_RELEASE="106000022025082510"
OBPROXY_RPM_RELEASE="2"
OB_USER="root@test#demo"
OB_MEMORY_LIMIT="64G"
OB_SYSTEM_MEMORY="8G"
OB_SYS_TENANT_MEMORY="16G"
OB_TEST_TENANT_MEMORY="32G"
OB_PROXY_MEMORY_LIMIT="8G"

# 基准测试参数
SYSBENCH_VERSION="1.0.20"

# 部署相关路径
OB_DEPLOY_HOME=""
OBD_HOME=""
OB_ROOT_PASSWORD_FILE=""
OB_PACKAGE_DIR=""
SYSBENCH_BIN=""
SYSBENCH_LUA_DIR=""

# 独立执行状态标记
STANDALONE_OWNS_WORK_DIR=0
STANDALONE_KEEP_WORK_DIR=0
STANDALONE_STOP_DONE=0
STANDALONE_CLEANUP_DONE=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    printf '%s\n' "[oceanbase] $*"
}

# ---------------------------------------------------------------------------
# 路径与运行时配置
# ---------------------------------------------------------------------------
configure_runtime_paths() {
    local normalized_run_id
    normalized_run_id="$(printf '%s' "${PERF_RUN_ID}" | tr -c 'A-Za-z0-9._-' '_')"

    if [[ -z "${RESULTS_DIR}" ]]; then
        RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${normalized_run_id}"
    fi

    if [[ -z "${PERF_WORK_DIR}" ]]; then
        PERF_WORK_DIR="/home/runner/boostkit-perf/oceanbase/local-${normalized_run_id}"
        STANDALONE_OWNS_WORK_DIR=1
    fi

    if [[ -z "${PERF_ACTUAL_VERSION_FILE}" ]]; then
        PERF_ACTUAL_VERSION_FILE="${RESULTS_DIR}/actual-version.txt"
    fi
    TMPDIR="${PERF_WORK_DIR}/tmp"
    OB_DEPLOY_HOME="${PERF_WORK_DIR}/ob"
    OBD_HOME="${PERF_WORK_DIR}/obd-meta"
    OB_ROOT_PASSWORD_FILE="${PERF_WORK_DIR}/ob-root-password"
    OB_PACKAGE_DIR="${PERF_WORK_DIR}/packages"
    SYSBENCH_BIN="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/sysbench"
    SYSBENCH_LUA_DIR="${PERF_WORK_DIR}/sysbench-tools/sysbench-1.0.20/src/lua"

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH OB_PROXY_VERSION OBD_HOME TMPDIR
    export SYSBENCH_BIN SYSBENCH_LUA_DIR
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
            log 'installing dnf-plugins-core for verified RPM downloads'
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
        log "downloading official OceanBase ${SOFTWARE_VERSION} and OBProxy ${OB_PROXY_VERSION} RPMs"
        dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" download \
            "--destdir=${OB_PACKAGE_DIR}" \
            "oceanbase-ce-${SOFTWARE_VERSION}-${OBSERVER_RPM_RELEASE}.el8" \
            "obproxy-ce-${OB_PROXY_VERSION}-${OBPROXY_RPM_RELEASE}.el8" || return 30
    fi
    if [[ ! -s "${observer_rpm}" || ! -s "${proxy_rpm}" ]]; then
        log 'ERROR: expected OceanBase or OBProxy RPM is missing after download'
        return 30
    fi
    obd mirror clone "${observer_rpm}" -f || return 30
    obd mirror clone "${proxy_rpm}" -f || return 30
    obd mirror disable remote || return 30
}

compute_oceanbase_ports() {
    local checksum
    if [[ -z "${OB_PORT}" ]]; then
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        OB_PORT="$((20000 + ${checksum%% *} % 20000))"
        if (( OB_PORT < 1024 || OB_PORT > 65535 )); then
            log "ERROR: derived invalid port ${OB_PORT}"
            return 20
        fi
    fi
    if [[ -z "${OB_RPC_PORT}" ]]; then
        OB_RPC_PORT="$((OB_PORT + 10000))"
        if (( OB_RPC_PORT < 1024 || OB_RPC_PORT > 65535 )); then
            log "ERROR: derived invalid rpc port ${OB_RPC_PORT}"
            return 20
        fi
    fi
    if [[ -z "${OB_PROXY_PORT}" ]]; then
        OB_PROXY_PORT="$((OB_PORT + 20000))"
    fi
    if [[ -z "${OB_PROXY_METRICS_PORT}" ]]; then
        OB_PROXY_METRICS_PORT="$((OB_PROXY_PORT + 1))"
    fi
    if (( OB_PROXY_PORT < 1024 || OB_PROXY_METRICS_PORT > 65535 ||
          OB_PORT == OB_RPC_PORT || OB_PORT == OB_PROXY_PORT ||
          OB_RPC_PORT == OB_PROXY_PORT )); then
        log "ERROR: invalid or overlapping OceanBase/OBProxy ports"
        return 20
    fi
}

initialize_runtime() {
    local daemon_socket socket_bytes
    configure_runtime_paths || return $?
    compute_oceanbase_ports || return $?
    daemon_socket="${OB_DEPLOY_HOME}/oceanbase-ce/run/daemon.sock"
    socket_bytes="$(LC_ALL=C printf '%s' "${daemon_socket}" | wc -c)"
    if (( socket_bytes >= 108 )); then
        log "ERROR: obshell Unix socket path is ${socket_bytes} bytes (maximum 107): ${daemon_socket}"
        return 20
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# ---------------------------------------------------------------------------
# 数据库操作辅助函数
# ---------------------------------------------------------------------------
ob_mysql() {
    [[ -s "${OB_ROOT_PASSWORD_FILE}" ]] || return 1
    MYSQL_PWD="$(< "${OB_ROOT_PASSWORD_FILE}")" \
        mysql --protocol=tcp "-h${OB_HOST}" "-P${OB_PORT}" -uroot@sys "$@"
}

proxy_mysql() {
    mysql --protocol=tcp "-h${OB_HOST}" "-P${OB_PROXY_PORT}" "-u${OB_USER}" "$@"
}

proxy_sys_mysql() {
    [[ -s "${OB_ROOT_PASSWORD_FILE}" ]] || return 1
    MYSQL_PWD="$(< "${OB_ROOT_PASSWORD_FILE}")" \
        mysql --protocol=tcp "-h${OB_HOST}" "-P${OB_PROXY_PORT}" -uroot@sys#demo "$@"
}

check_observer_ready() {
    ob_mysql -N -e "SELECT 1" >/dev/null 2>&1
}

query_observer_version() {
    local value
    value="$(ob_mysql -N -s -e "SELECT version()" 2>/dev/null || true)"
    printf '%s' "${value}" | tr -d '\r\n\t'
}

configure_sys_tenant_memory() {
    local memory_bytes

    log "setting sys tenant memory to ${OB_SYS_TENANT_MEMORY}"
    if ! ob_mysql -e "ALTER RESOURCE UNIT sys_unit_config MEMORY_SIZE='${OB_SYS_TENANT_MEMORY}'"; then
        log 'ERROR: could not increase the sys tenant memory quota'
        return 40
    fi
    memory_bytes="$(ob_mysql -N -s -e \
        "SELECT MEMORY_SIZE FROM oceanbase.DBA_OB_UNIT_CONFIGS WHERE NAME = 'sys_unit_config'" 2>/dev/null)" || {
        log 'ERROR: could not verify the sys tenant memory quota'
        return 40
    }
    if [[ "${memory_bytes}" != "$((16 * 1024 * 1024 * 1024))" ]]; then
        log "ERROR: sys tenant memory quota is ${memory_bytes:-unknown} bytes, expected 17179869184"
        return 40
    fi
}

check_test_tenant_memory() {
    local available_bytes required_bytes

    available_bytes="$(ob_mysql -N -s -e \
        "SELECT MIN(MEM_CAPACITY - MEM_ASSIGNED) FROM oceanbase.GV\$OB_SERVERS WHERE SVR_IP = '${OB_HOST}'" \
        2>/dev/null)" || {
        log 'ERROR: could not query observer memory available for the test tenant'
        return 40
    }
    available_bytes="$(printf '%s' "${available_bytes}" | tr -d '\r\n\t')"
    if [[ ! "${available_bytes}" =~ ^[0-9]+$ ]]; then
        log "ERROR: invalid observer memory availability: ${available_bytes:-unknown}"
        return 40
    fi
    required_bytes=$(( ${OB_TEST_TENANT_MEMORY%G} * 1024 * 1024 * 1024 ))
    if (( available_bytes < required_bytes )); then
        log "ERROR: test tenant needs ${OB_TEST_TENANT_MEMORY}, observer has only ${available_bytes} available bytes"
        return 40
    fi
    log "observer has ${available_bytes} bytes available for the ${OB_TEST_TENANT_MEMORY} test tenant"
}

check_proxy_ready() {
    proxy_mysql -N -e 'SELECT 1' >/dev/null 2>&1
}

redact_diagnostic() {
    local root_password=""
    local -a filters=()
    if [[ -s "${OB_ROOT_PASSWORD_FILE}" ]]; then
        root_password="$(< "${OB_ROOT_PASSWORD_FILE}")"
        filters+=(-e "s/${root_password}/[REDACTED]/g")
    fi
    filters+=(
        -e "s/-p'[^']*'/-p'[REDACTED]'/g"
        -e 's/([Pp]assword[[:space:]]*[:=][[:space:]]*)[^[:space:]]+/\1[REDACTED]/g'
    )
    sed -E "${filters[@]}"
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
            log "WARN: obd display-trace failed for ${trace_id}; partial output was saved"
        fi
    else
        log 'WARN: no OBD trace ID found in deployment output'
    fi

    : > "${obshell_output}"
    while IFS= read -r -d '' log_file; do
        printf '\n== %s ==\n' "${log_file#"${OB_DEPLOY_HOME}/"}" >> "${obshell_output}"
        tail -n 300 "${log_file}" | redact_diagnostic >> "${obshell_output}"
    done < <(find "${OB_DEPLOY_HOME}" -type f -path '*/log_obshell/*' -name '*.log' -print0 2>/dev/null)
    [[ -s "${obshell_output}" ]] || rm -f -- "${obshell_output}"
    log "deployment diagnostics saved under ${RESULTS_DIR}"
}

collect_service_diagnostics() {
    local service source output log_file relative count
    for service in oceanbase-ce obproxy-ce; do
        source="${OB_DEPLOY_HOME}/${service}"
        [[ -d "${source}" ]] || continue
        output="${RESULTS_DIR}/${service}-diagnostic.log"
        : > "${output}"
        count=0
        while IFS= read -r -d '' log_file; do
            relative="${log_file#"${source}/"}"
            case "/${relative}" in
                */log/*|*/logs/*|*/log_obproxy/*|*/log_obshell/*) ;;
                *) continue ;;
            esac
            case "${relative}" in
                *.gz|*.zip|*.zst|*.lz4) continue ;;
                *.log|*.log.*|*.wf|*.trace|*.trace.*) ;;
                *) continue ;;
            esac
            printf '\n== %s ==\n' "${relative}" >> "${output}"
            tail -n 300 "${log_file}" | redact_diagnostic >> "${output}" || return 1
            count=$((count + 1))
        done < <(find "${source}" -type f -print0 2>/dev/null)
        if (( count == 0 )); then
            rm -f -- "${output}"
        else
            log "saved ${count} ${service} service logs to ${output}"
        fi
    done
}

capture_proxy_connection_error() {
    local connection_output="${RESULTS_DIR}/obproxy-connection-error.log"
    if proxy_mysql -N -e 'SELECT 1' > "${PERF_WORK_DIR}/proxy-check.log" 2>&1; then
        return 0
    fi
    redact_diagnostic < "${PERF_WORK_DIR}/proxy-check.log" > "${connection_output}"
    log "OBProxy connection error: $(tr '\n' ' ' < "${connection_output}")"
    return 1
}

# ---------------------------------------------------------------------------
# 依赖安装
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
        log "installing missing test dependencies: ${packages[*]}"
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
        log "installing OceanBase Deployer ${OBD_VERSION} from the official repository without changing system repo files"
        if [[ "${EUID}" -eq 0 ]]; then
            dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" install -y ob-deploy-4.6.0-16.el8 || return 30
        else
            sudo -n dnf "${dnf_options[@]}" "${oceanbase_repo[@]}" install -y ob-deploy-4.6.0-16.el8 || return 30
        fi
    fi
    actual_version="$(obd --version 2>/dev/null || true)"
    [[ "${actual_version}" == *"${OBD_VERSION}"* ]] || {
        log "ERROR: expected obd ${OBD_VERSION}, found ${actual_version:-unavailable}"
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
        log "reusing private Sysbench source directory: ${source_dir}"
    else
        log "cloning upstream Sysbench ${SYSBENCH_VERSION} into the private work directory"
        git clone --quiet --depth 1 --branch "${SYSBENCH_VERSION}" \
            https://github.com/akopytov/sysbench.git "${source_dir}" || return 30
    fi
    actual_commit="$(git -C "${source_dir}" rev-parse --short=7 HEAD 2>/dev/null || true)"
    if [[ "${actual_commit}" != ebf1c90 ]]; then
        log "ERROR: Sysbench tag resolved to ${actual_commit}, expected ebf1c90"
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
        log "ERROR: expected Sysbench ${SYSBENCH_VERSION}, found ${actual_version}"
        return 30
    fi
    for actual_commit in read_only insert read_write write_only; do
        [[ -f "${SYSBENCH_LUA_DIR}/oltp_${actual_commit}.lua" ]] || {
            log "ERROR: missing Sysbench workload script: oltp_${actual_commit}.lua"
            return 30
        }
    done
}

# ---------------------------------------------------------------------------
# 阶段 1：build - 部署 OceanBase observer
# ---------------------------------------------------------------------------
build_oceanbase() {
    local runner_architecture actual_version proxy_info attempt deploy_log tenant_log tenant_count

    initialize_runtime || return $?
    runner_architecture="$(uname -m)"
    if [[ "${runner_architecture}" != "${EXPECTED_ARCH}" ]]; then
        log "ERROR: expected architecture ${EXPECTED_ARCH}, runner is ${runner_architecture}"
        return 20
    fi
    install_oceanbase_dependencies || return $?
    prepare_sysbench || return $?
    prepare_oceanbase_packages || return $?

    if (echo > "/dev/tcp/${OB_HOST}/${OB_PORT}") 2>/dev/null ||
       (echo > "/dev/tcp/${OB_HOST}/${OB_PROXY_PORT}") 2>/dev/null; then
        log "ERROR: an observer or proxy port is already in use; refusing to touch a pre-existing service"
        return 20
    fi

    log "deploying upstream OceanBase ${SOFTWARE_VERSION} with OBProxy ${OB_PROXY_VERSION} via private obd demo"
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
            "--obproxy-ce.version=${OB_PROXY_VERSION}" \
            "--obproxy-ce.proxy_mem_limited=${OB_PROXY_MEMORY_LIMIT}" \
            "--oceanbase-ce.mysql_port=${OB_PORT}" \
            "--oceanbase-ce.rpc_port=${OB_RPC_PORT}" \
            "--obproxy-ce.listen_port=${OB_PROXY_PORT}" \
            "--obproxy-ce.prometheus_listen_port=${OB_PROXY_METRICS_PORT}" \
            "--home_path=${OB_DEPLOY_HOME}" 2>&1 | tee "${deploy_log}" | redact_diagnostic; then
        collect_deployment_diagnostics "${deploy_log}"
        log "ERROR: obd demo deployment failed"
        return 40
    fi

    log "waiting for the OceanBase observer to become ready"
    for attempt in {1..120}; do
        if check_observer_ready; then
            log "observer ready on ${OB_HOST}:${OB_PORT} (after ${attempt} checks)"
            break
        fi
        sleep 3
    done
    if ! check_observer_ready; then
        log "ERROR: observer did not become ready on ${OB_HOST}:${OB_PORT}"
        return 40
    fi

    actual_version="$(query_observer_version)"
    actual_version="$(printf '%s' "${actual_version}" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)"
    if [[ "${actual_version}" != "${SOFTWARE_VERSION}" ]]; then
        log "ERROR: deployed observer reports ${actual_version:-unknown}, expected ${SOFTWARE_VERSION}"
        return 40
    fi
    configure_sys_tenant_memory || return $?
    check_test_tenant_memory || return $?
    log "creating MySQL-mode test tenant with ${OB_TEST_TENANT_MEMORY} memory"
    tenant_log="${PERF_WORK_DIR}/tenant-create.log"
    if ! obd cluster tenant create demo -n test \
            "--memory-size=${OB_TEST_TENANT_MEMORY}" 2>&1 | tee "${tenant_log}" | redact_diagnostic; then
        redact_diagnostic < "${tenant_log}" > "${RESULTS_DIR}/tenant-create.log"
        log 'ERROR: OBD could not create the test tenant'
        return 40
    fi
    tenant_count="$(ob_mysql -N -s -e \
        "SELECT COUNT(*) FROM oceanbase.DBA_OB_TENANTS WHERE TENANT_NAME = 'test' AND TENANT_TYPE = 'USER' AND COMPATIBILITY_MODE = 'MYSQL'" 2>/dev/null || true)"
    if [[ "${tenant_count}" != 1 ]]; then
        log "ERROR: expected one MySQL-mode test tenant, found ${tenant_count:-unknown}"
        return 40
    fi
    for attempt in {1..60}; do
        check_proxy_ready && break
        sleep 3
    done
    if ! check_proxy_ready; then
        capture_proxy_connection_error || true
        collect_deployment_diagnostics "${deploy_log}"
        log "ERROR: test tenant is not reachable through OBProxy on ${OB_HOST}:${OB_PROXY_PORT}"
        return 40
    fi
    proxy_info="$(proxy_sys_mysql -N -e 'SHOW PROXYINFO BINARY' 2>/dev/null || true)"
    if [[ "${proxy_info}" != *"${OB_PROXY_VERSION%.*}"* ]]; then
        log "ERROR: cannot verify OBProxy ${OB_PROXY_VERSION} from SHOW PROXYINFO BINARY"
        return 40
    fi

    mkdir -p "$(dirname "${PERF_ACTUAL_VERSION_FILE}")"
    printf '%s\n' "${actual_version}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "OceanBase ${actual_version} and OBProxy ${OB_PROXY_VERSION} deployed"
}

# ---------------------------------------------------------------------------
# 阶段 2：start - 确认服务可用
# ---------------------------------------------------------------------------
start_oceanbase_service() {
    initialize_runtime || return $?
    if ! check_observer_ready; then
        log "ERROR: OceanBase observer is not reachable on ${OB_HOST}:${OB_PORT}"
        return 40
    fi
    if ! check_proxy_ready; then
        log "ERROR: OBProxy test tenant is not reachable on ${OB_HOST}:${OB_PROXY_PORT}"
        return 40
    fi
    log "OceanBase observer and OBProxy are ready on ${OB_HOST}:${OB_PROXY_PORT}"
    return 0
}

# ---------------------------------------------------------------------------
# 阶段 3：test - 执行基准测试并聚合结果
# ---------------------------------------------------------------------------
run_oceanbase_benchmarks() {
    initialize_runtime || return $?
    if ! check_proxy_ready; then
        log "ERROR: OBProxy test tenant is not reachable on ${OB_HOST}:${OB_PROXY_PORT}"
        return 50
    fi
    if [[ ! -x "${SYSBENCH_BIN}" || ! -f "${SYSBENCH_LUA_DIR}/oltp_insert.lua" ]]; then
        log 'ERROR: private Sysbench 1.0.20 build is missing'
        return 50
    fi
    if ! proxy_mysql -e "CREATE DATABASE IF NOT EXISTS ${OB_DB}"; then
        log "ERROR: could not create benchmark database ${OB_DB} in test tenant"
        return 50
    fi
    log 'running selected Sysbench matrix through OBProxy: 4 workloads x 3 thread levels'
    python3 "${SCRIPT_DIR}/scripts/benchmark_ob.py" \
        --host "${OB_HOST}" --port "${OB_PROXY_PORT}" \
        --user "${OB_USER}" --database "${OB_DB}" \
        --results-dir "${RESULTS_DIR}" || {
        log 'ERROR: OceanBase Sysbench benchmark failed'
        return 50
    }
    log "Sysbench results written to ${RESULTS_DIR}"
}

# ---------------------------------------------------------------------------
# 阶段 4：stop - 销毁集群并清理资源
# ---------------------------------------------------------------------------
stop_oceanbase_service() {
    initialize_runtime || return $?
    if [[ "${OB_DEPLOY_HOME}" != "${PERF_WORK_DIR}/ob" ||
          "${PERF_WORK_DIR}" == / || -z "${PERF_WORK_DIR}" ]]; then
        log "ERROR: refusing to clean unexpected OceanBase deployment path: ${OB_DEPLOY_HOME}"
        return 70
    fi
    collect_service_diagnostics || log 'WARN: could not save all observer/OBProxy service logs'
    if command -v obd >/dev/null 2>&1; then
        export OBD_HOME
        if ! obd cluster destroy demo -f --confirm; then
            log "WARN: obd cluster destroy reported an error; continuing with cleanup"
        fi
        if obd cluster list 2>/dev/null |
            grep -Eq '^\|[[:space:]]*demo[[:space:]]*\|.*\|[[:space:]]*configured[[:space:]]*\|'; then
            obd cluster prune-config demo --confirm ||
                log "WARN: failed to prune the configured-only demo record"
        fi
    else
        log "obd unavailable; skipping cluster teardown"
    fi
    rm -rf -- "${OB_DEPLOY_HOME}"
    log "OceanBase observer removed from ${OB_DEPLOY_HOME}"
}

# ---------------------------------------------------------------------------
# 独立执行
# ---------------------------------------------------------------------------
cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/oceanbase/local-* || "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/oceanbase" ]]; then
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}" || return 70
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_oceanbase_service
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_oceanbase_standalone() {
    local stage_status=0 failed_stage="" cleanup_status="passed"

    initialize_runtime || return $?
    trap 'emergency_standalone_cleanup' EXIT

    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" system "${RESULTS_DIR}/system_info.json" \
        || { stage_status=$?; failed_stage="prepare"; }
    if [[ "${stage_status}" -eq 0 ]]; then
        python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_before.json" \
            || { stage_status=$?; failed_stage="prepare"; }
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        build_oceanbase || { stage_status=$?; failed_stage="build"; }
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" build-info \
            "${RESULTS_DIR}/build_info.json" "${SOFTWARE_VERSION}" "${PERF_ACTUAL_VERSION_FILE}" \
            "${EXPECTED_ARCH}" "${PERF_RUN_ID}" || { stage_status=$?; failed_stage="build"; }
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        start_oceanbase_service || { stage_status=$?; failed_stage="start"; }
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        run_oceanbase_benchmarks || { stage_status=$?; failed_stage="test"; }
    fi

    stop_oceanbase_service || cleanup_status="failed"
    STANDALONE_STOP_DONE=1
    python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" runtime "${RESULTS_DIR}/runtime_after.json" \
        || cleanup_status="failed"
    if [[ "${stage_status}" -eq 0 ]]; then
        python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" finalize \
            "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" \
            passed "${cleanup_status}" "" || stage_status=$?
    else
        python3 "${SCRIPT_DIR}/scripts/standalone_runtime.py" finalize \
            "${RESULTS_DIR}" "${SOFTWARE_VERSION}" "${EXPECTED_ARCH}" "${PERF_RUN_ID}" \
            failed "${cleanup_status}" "${failed_stage}" || true
    fi

    cleanup_standalone_workdir || stage_status=$?
    STANDALONE_CLEANUP_DONE=1
    trap - EXIT

    return "${stage_status}"
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                SOFTWARE_VERSION="$2"; shift 2 ;;
            --results-dir)
                RESULTS_DIR="$2"; shift 2 ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1; shift ;;
            -h|--help)
                printf 'Usage: %s [--version VERSION] [--results-dir DIR] [--keep-workdir]\n' "$(basename "$0")"
                return 0 ;;
            *)
                log "ERROR: unsupported option: $1"
                return 10 ;;
        esac
    done
    run_oceanbase_standalone
}

# 受保护的独立执行入口：仅当被直接执行时才进入 main；被 framework source 时
# 仅定义函数，不执行任何入口逻辑。
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
