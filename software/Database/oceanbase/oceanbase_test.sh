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
#   ./oceanbase_test.sh [--version 4.2.5.6] [--variant base] [--results-dir DIR] [--keep-workdir]
#
# 部署说明：OceanBase 属于“部署服务型”软件（区别于源码编译型，如 RocksDB），
# build 阶段使用 OceanBase Deployer（obd）的 demo 命令在任务私有目录内部署单机
# 演示集群，并通过独立端口与独立 OBD_HOME 保证任务隔离；start/test 阶段通过
# mysql 协议经 OBProxy 连接 test 租户执行 Sysbench OLTP 测试。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"
}

# ---------------------------------------------------------------------------
# 独立执行
# ---------------------------------------------------------------------------
cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log_message "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log_message "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${PERF_WORK_DIR}" != /home/runner/boostkit-perf/oceanbase/local-* || "${PERF_WORK_DIR}" == "/home/runner/boostkit-perf/oceanbase" ]]; then
        log_message "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 70
    fi
    rm -rf -- "${PERF_WORK_DIR}" || return 70
    log_message "cleaned standalone work directory: ${PERF_WORK_DIR}"
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
    local stage_status=0 failed_stage="" cleanup_status="passed" finalize_status=0
    local command_status="passed"

    configure_runtime_paths || return $?
    STANDALONE_STOP_DONE=0
    STANDALONE_CLEANUP_DONE=0
    trap emergency_standalone_cleanup EXIT
    initialize_runtime || return $?

    if standalone_runtime system "${RESULTS_DIR}/system_info.json" && \
       standalone_runtime runtime "${RESULTS_DIR}/runtime_before.json"; then
        :
    else
        stage_status=$?
        failed_stage="prepare"
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if build_oceanbase; then
            if standalone_runtime build-info \
                "${RESULTS_DIR}/build_info.json" \
                "${SOFTWARE_VERSION}" \
                "${PERF_ACTUAL_VERSION_FILE}" \
                "${EXPECTED_ARCH}" \
                "${PERF_RUN_ID}"; then
                :
            else
                stage_status=$?
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if start_oceanbase_service; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi
    if [[ "${stage_status}" -eq 0 ]]; then
        if run_oceanbase_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_oceanbase_service; then
        cleanup_status="failed"
    fi
    STANDALONE_STOP_DONE=1
    if ! standalone_runtime runtime "${RESULTS_DIR}/runtime_after.json"; then
        cleanup_status="failed"
    fi
    if ! cleanup_standalone_workdir; then
        cleanup_status="failed"
    fi
    STANDALONE_CLEANUP_DONE=1

    if [[ "${stage_status}" -ne 0 ]]; then
        command_status="failed"
    fi
    if standalone_runtime finalize \
        "${RESULTS_DIR}" \
        "${SOFTWARE_VERSION}" \
        "${EXPECTED_ARCH}" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        finalize_status=0
    else
        finalize_status=$?
    fi

    trap - EXIT
    if [[ "${stage_status}" -ne 0 ]]; then
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        return 70
    fi
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Deploy OceanBase with OBProxy via a private obd demo cluster and run the
Sysbench matrix through OBProxy as a standalone performance evaluation. The
optimized build is reserved and fails until its implementation is supplied.
Results default to results/<version>/<run-id>/ inside this directory.

Options:
  --version VERSION       OceanBase version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base or optimized (default: base)
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, RESULTS_DIR, PERF_WORK_DIR,
  OB_PORT, OB_RPC_PORT, OB_PROXY_PORT, OB_PROXY_METRICS_PORT
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log_message "ERROR: --results-dir requires a value"; return 10; }
                RESULTS_DIR="$2"
                shift 2
                ;;
            --keep-workdir)
                STANDALONE_KEEP_WORK_DIR=1
                shift
                ;;
            -h|--help)
                usage
                return 0
                ;;
            *)
                log_message "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    validate_variant || return $?
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return 10
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_oceanbase_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log_message "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

# 受保护的独立执行入口：仅当被直接执行时才进入 main；被 framework source 时
# 仅定义函数，不执行任何入口逻辑。
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
