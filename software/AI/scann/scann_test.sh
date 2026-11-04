#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
source "${SCRIPT_DIR}/scripts/common.sh"

usage() {
    cat <<USAGE
Usage: $(basename "$0") [--version 1.4.2] [--variant base|optimized]
       [--results-dir DIR] [--keep-workdir]

Run the pinned ann-benchmarks ScaNN 1.4.2 five-dataset matrix through the same
Framework stages used by GitHub Actions. Results are copied to --results-dir.
USAGE
}

main() {
    local destination="" keep_workdir=0 stage code=0 framework_code=0
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version|--variant|--results-dir)
                [[ $# -ge 2 ]] || { usage; return 10; }
                case "$1" in
                    --version) SOFTWARE_VERSION="$2" ;;
                    --variant) PERF_VARIANT="$2" ;;
                    --results-dir) destination="$2" ;;
                esac
                shift 2
                ;;
            --keep-workdir) keep_workdir=1; shift ;;
            -h|--help) usage; return 0 ;;
            *) usage; return 10 ;;
        esac
    done
    [[ "${SOFTWARE_VERSION}" == 1.4.2 ]] || { log 'ERROR: unsupported version'; return 10; }
    [[ "${PERF_VARIANT}" == base ]] || { log 'ERROR: optimized ScaNN build is not implemented'; return 40; }
    EXPECTED_ARCH="$(normalize_arch "${EXPECTED_ARCH}")"
    PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    local framework_work="/home/runner/boostkit-perf/scann/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}"
    local framework_output="${REPO_ROOT}/.perf-output/AI/scann/${SOFTWARE_VERSION}/${EXPECTED_ARCH}/${PERF_RUN_ID}"
    PERF_WORK_DIR="${framework_work}"
    if [[ -z "${destination}" ]]; then
        destination="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
    elif [[ "${destination}" != /* ]]; then
        destination="$(pwd -P)/${destination}"
    fi
    mkdir -p "${framework_work}/framework-deps" "${framework_output}" "${destination}"
    if ! python3 -c 'import yaml' >/dev/null 2>&1; then
        with_network_proxy python3 -m pip install --target "${framework_work}/framework-deps" \
            'PyYAML==6.0.2' || return 30
        export PYTHONPATH="${framework_work}/framework-deps${PYTHONPATH:+:${PYTHONPATH}}"
    fi
    for stage in prepare build start test; do
        if python3 "${REPO_ROOT}/framework/run_case.py" \
            --case "${SCRIPT_DIR}/case.yaml" --version "${SOFTWARE_VERSION}" \
            --architecture "${EXPECTED_ARCH}" --run-id "${PERF_RUN_ID}" --stage "${stage}"; then
            :
        else
            framework_code=$?
            break
        fi
    done
    if python3 "${REPO_ROOT}/framework/run_case.py" \
        --case "${SCRIPT_DIR}/case.yaml" --version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" --run-id "${PERF_RUN_ID}" --stage stop; then
        :
    else
        code=$?
        [[ "${framework_code}" -ne 0 ]] || framework_code="${code}"
    fi
    if python3 "${REPO_ROOT}/framework/run_case.py" \
        --case "${SCRIPT_DIR}/case.yaml" --version "${SOFTWARE_VERSION}" \
        --architecture "${EXPECTED_ARCH}" --run-id "${PERF_RUN_ID}" --stage finalize; then
        :
    else
        code=$?
        [[ "${framework_code}" -ne 0 ]] || framework_code="${code}"
    fi
    cp -a "${framework_output}/." "${destination}/" || return 70
    if [[ "${keep_workdir}" -eq 0 && -d "${framework_work}" ]]; then
        rm -rf -- "${framework_work}"
    else
        log "keeping private work directory: ${framework_work}"
    fi
    log "standalone results: ${destination}"
    return "${framework_code}"
}

main "$@"
