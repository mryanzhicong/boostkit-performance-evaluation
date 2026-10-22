#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# 公共变量（可被框架环境变量覆盖）
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="${SOFTWARE_NAME:-oceanbase}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-4.2.5.6}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
EXPECTED_ARCH="${EXPECTED_ARCH/x86_64/x86_64}"
EXPECTED_ARCH="${EXPECTED_ARCH/amd64/x86_64}"
EXPECTED_ARCH="${EXPECTED_ARCH/aarch64/aarch64}"
EXPECTED_ARCH="${EXPECTED_ARCH/arm64/aarch64}"

PERF_VARIANT="${PERF_VARIANT:-base}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
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
OB_DATAFILE_SIZE="512G"
OB_LOG_DISK_SIZE="128G"
OB_SYS_TENANT_MEMORY="16G"
OB_TEST_TENANT_MEMORY="32G"
OB_PROXY_MEMORY_LIMIT="8G"

# 基准测试参数
SYSBENCH_VERSION="1.0.20"

# 部署相关路径（在 configure_runtime_paths 中赋值）
OB_DEPLOY_HOME=""
OBD_HOME=""
OB_ROOT_PASSWORD_FILE=""
OB_PACKAGE_DIR=""
SYSBENCH_BIN=""
SYSBENCH_LUA_DIR=""

# 独立执行状态标记
STANDALONE_OWNS_WORK_DIR="${STANDALONE_OWNS_WORK_DIR:-0}"
STANDALONE_KEEP_WORK_DIR="${STANDALONE_KEEP_WORK_DIR:-0}"
STANDALONE_STOP_DONE="${STANDALONE_STOP_DONE:-0}"
STANDALONE_CLEANUP_DONE="${STANDALONE_CLEANUP_DONE:-0}"

log_message() {
    printf '[oceanbase] [%s] %s\n' "$(TZ=UTC-8 date '+%F %T')" "$*"
}

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) log_message "ERROR: invalid build variant: ${PERF_VARIANT}"; return 10 ;;
    esac
}

# ---------------------------------------------------------------------------
# 路径与运行时配置
# ---------------------------------------------------------------------------
configure_runtime_paths() {
    validate_variant || return $?
    local normalized_run_id
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    normalized_run_id="$(printf '%s' "${PERF_RUN_ID}" | tr -c 'A-Za-z0-9._-' '_')"

    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${normalized_run_id}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${normalized_run_id}"
        fi
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

    export SOFTWARE_NAME SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT OB_PROXY_VERSION OBD_HOME TMPDIR
    export SYSBENCH_BIN SYSBENCH_LUA_DIR
}

compute_oceanbase_ports() {
    local checksum
    if [[ -z "${OB_PORT}" ]]; then
        checksum="$(printf '%s' "${PERF_RUN_ID}" | cksum)"
        OB_PORT="$((20000 + ${checksum%% *} % 20000))"
        if (( OB_PORT < 1024 || OB_PORT > 65535 )); then
            log_message "ERROR: derived invalid port ${OB_PORT}"
            return 20
        fi
    fi
    if [[ -z "${OB_RPC_PORT}" ]]; then
        OB_RPC_PORT="$((OB_PORT + 10000))"
        if (( OB_RPC_PORT < 1024 || OB_RPC_PORT > 65535 )); then
            log_message "ERROR: derived invalid rpc port ${OB_RPC_PORT}"
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
        log_message "ERROR: invalid or overlapping OceanBase/OBProxy ports"
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
        log_message "ERROR: obshell Unix socket path is ${socket_bytes} bytes (maximum 107): ${daemon_socket}"
        return 20
    fi
    mkdir -p "${RESULTS_DIR}" "${PERF_WORK_DIR}" "${TMPDIR}"
}

# ---------------------------------------------------------------------------
# 数据库操作辅助函数（build/start/test/stop 阶段共用，必须保留在 common.sh）
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
            log_message "saved ${count} ${service} service logs to ${output}"
        fi
    done
}
