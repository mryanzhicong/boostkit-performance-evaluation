#!/usr/bin/env bash
# Ultrascan 5.8.0 Mean throughput 独立运行入口。
#
# 口径：Intel Hyperscan hsbench-samples 的固定规则集 pcre/snort_literals +
# 固定语料 corpora/gutenberg.db，block 模式、单线程、每次测量扫一遍语料
# （-N -n 1），只统计 hsbench 的 `Mean throughput (overall)`（Mbit/s）：
#
#   1) 无通用字节码：hsbench -e <samples>/pcre/snort_literals \
#                              -c <samples>/corpora/gutenberg.db -N -n 1
#   2) 有通用字节码：hsdump -N -U 先生成 dump/db.raw，再
#                     hsbench -U <dump>/dump/db.raw \
#                             -c <samples>/corpora/gutenberg.db -N -n 1
#
# 宿主只负责下载并校验 hsbench-samples.zip；解包/成员校验、Release 构建
# hsbench、Debug 构建 hsdump（DUMP_SUPPORT）、生成 db.raw、1 次预热 + N 次
# 独立测量全部在任务专属的 openEuler 24.03 LTS SP4 容器内完成，严格解析留在
# 宿主。每个场景取 N 次独立测量的中位数。
#
# 退出码：0 成功；10 参数非法；20 架构/环境不符；30 下载/构建失败；
#         40 运行前检查失败；50 测量/解析失败；60 清理失败；70 结果校验失败。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

standalone_runtime() {
    python3 "${SCRIPT_DIR}/scripts/results/standalone_runtime.py" "$@"
}

cleanup_standalone_workdir() {
    if [[ "${STANDALONE_KEEP_WORK_DIR}" -eq 1 ]]; then
        log "keeping standalone work directory: ${PERF_WORK_DIR}"
        return 0
    fi
    if [[ "${STANDALONE_OWNS_WORK_DIR}" -ne 1 ]]; then
        log "external work directory was not removed: ${PERF_WORK_DIR}"
        return 0
    fi
    [[ "${PERF_WORK_DIR}" == /home/runner/boostkit-perf/ultrascan/local-* && \
       "${PERF_WORK_DIR}" != "/home/runner/boostkit-perf/ultrascan" ]] || {
        log "ERROR: refusing to clean unexpected work directory: ${PERF_WORK_DIR}"
        return 60
    }
    if [[ -d "${PERF_WORK_DIR}" ]]; then
        rm -rf -- "${PERF_WORK_DIR}" || {
            log "ERROR: failed to remove the work directory"
            return 60
        }
    fi
    log "cleaned standalone work directory: ${PERF_WORK_DIR}"
}

emergency_standalone_cleanup() {
    set +e
    if [[ "${STANDALONE_STOP_DONE}" -ne 1 ]]; then
        stop_ultrascan_runtime
    fi
    if [[ "${STANDALONE_CLEANUP_DONE}" -ne 1 ]]; then
        cleanup_standalone_workdir
    fi
}

run_ultrascan_standalone() {
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
        if build_ultrascan; then
            if ! standalone_runtime build-info \
                --output "${RESULTS_DIR}/build_info.json" \
                --build-state "${BUILD_STATE_FILE}" \
                --requested-version "${SOFTWARE_VERSION}" \
                --actual-version-file "${PERF_ACTUAL_VERSION_FILE}" \
                --architecture "$(normalize_arch "${EXPECTED_ARCH}")" \
                --run-id "${PERF_RUN_ID}"; then
                stage_status=30
                failed_stage="build"
            fi
        else
            stage_status=$?
            failed_stage="build"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if start_ultrascan_runtime; then
            :
        else
            stage_status=$?
            failed_stage="start"
        fi
    fi

    if [[ "${stage_status}" -eq 0 ]]; then
        if run_ultrascan_benchmarks; then
            :
        else
            stage_status=$?
            failed_stage="test"
        fi
    fi

    if ! stop_ultrascan_runtime; then
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
        "$(normalize_arch "${EXPECTED_ARCH}")" \
        "${PERF_RUN_ID}" \
        "${command_status}" \
        "${cleanup_status}" \
        "${failed_stage}"; then
        :
    else
        finalize_status=$?
    fi

    if [[ "${stage_status}" -ne 0 ]]; then
        trap - EXIT
        return "${stage_status}"
    fi
    if [[ "${cleanup_status}" != "passed" ]]; then
        trap - EXIT
        return 60
    fi
    trap - EXIT
    return "${finalize_status}"
}

usage() {
    cat <<USAGE
Usage: $(basename "$0") [OPTIONS]

Build Ultrascan ${SOFTWARE_VERSION} inside the private openEuler container, build
hsbench (Release) and hsdump (Debug, DUMP_SUPPORT), generate the universal
bytecode dump/db.raw with hsdump, then measure the one metric this case reports:
hsbench's Mean throughput (overall) in Mbit/s, block mode, single thread, one
scan per measurement (-N -n 1), over the Intel hsbench-samples inputs
(pcre/snort_literals + corpora/gutenberg.db):

  without universal bytecode:
    hsbench -e <samples>/pcre/snort_literals -c <samples>/corpora/gutenberg.db -N -n 1
  with universal bytecode:
    hsdump -N -U ...   # writes <dump>/dump/db.raw
    hsbench -U <dump>/dump/db.raw -c <samples>/corpora/gutenberg.db -N -n 1

Each scenario runs PERF_ULTRASCAN_WARMUPS warmups and PERF_REPS measured
repetitions; the reported value is the median of the measured repetitions.

Options:
  --version VERSION       Ultrascan version (default: ${SOFTWARE_VERSION})
  --variant VARIANT       base only; optimized is reserved and fails with 30
  --results-dir DIR       Persistent result directory
  --keep-workdir          Keep the isolated work directory for debugging
  -h, --help              Show this help

Environment overrides:
  SOFTWARE_VERSION, EXPECTED_ARCH, PERF_VARIANT, PERF_RUN_ID, RESULTS_DIR,
  PERF_WORK_DIR, PERF_REPS, PERF_ULTRASCAN_WARMUPS,
  PERF_ULTRASCAN_BUILD_JOBS, PERF_ULTRASCAN_OFFLINE_DIR,
  PERF_ULTRASCAN_GIT_URL, PERF_ULTRASCAN_GIT_URLS, PERF_PROXY

Exit codes:
  0   success
  10  invalid command line
  20  architecture/environment mismatch
  30  download, sample verification or build failure
  40  pre-run check failure (hsbench/hsdump/db.raw/samples/container)
  50  measurement or strict parsing failure
  60  container or work-directory cleanup failure
  70  result validation/report failure
USAGE
}

main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --version)
                [[ "$#" -ge 2 ]] || { log "ERROR: --version requires a value"; return 10; }
                SOFTWARE_VERSION="$2"
                shift 2
                ;;
            --variant)
                [[ "$#" -ge 2 ]] || { log "ERROR: --variant requires a value"; return 10; }
                PERF_VARIANT="$2"
                shift 2
                ;;
            --results-dir)
                [[ "$#" -ge 2 ]] || { log "ERROR: --results-dir requires a value"; return 10; }
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
                log "ERROR: unsupported option: $1"
                usage
                return 10
                ;;
        esac
    done

    validate_variant || return $?
    configure_runtime_paths || return $?
    mkdir -p "${RESULTS_DIR}" || return $?
    : > "${RESULTS_DIR}/results.log"
    local pipeline_status=0
    set +e
    run_ultrascan_standalone 2>&1 | tee -a "${RESULTS_DIR}/results.log"
    pipeline_status="${PIPESTATUS[0]}"
    set -e
    log "standalone results: ${RESULTS_DIR}"
    return "${pipeline_status}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
