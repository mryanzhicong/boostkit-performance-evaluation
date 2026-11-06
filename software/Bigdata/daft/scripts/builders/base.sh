#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

install_host_dependencies() {
    local -a packages=() options=()
    local command_name package
    require_docker || return $?
    for command_name in curl sha256sum awk sed grep python3; do
        command -v "${command_name}" >/dev/null 2>&1 && continue
        case "${command_name}" in
            curl) package=curl ;; sha256sum) package=coreutils ;;
            awk) package=gawk ;; sed) package=sed ;;
            grep) package=grep ;; python3) package=python3 ;;
        esac
        packages+=("${package}")
    done
    ((${#packages[@]} == 0)) && return 0
    [[ -z "${PERF_PROXY:-}" ]] || options+=("--setopt=proxy=${PERF_PROXY}")
    log "installing missing host packages: ${packages[*]}"
    if [[ "$(id -u)" == 0 ]]; then
        dnf "${options[@]}" install -y "${packages[@]}" || return 30
    else
        sudo -n dnf "${options[@]}" install -y "${packages[@]}" || return 30
    fi
}

select_data_mode() {
    local parent="${DAFT_DATA_ROOT}/${DAFT_SF}_0/${DAFT_SF}"
    if [[ -d "${DAFT_PARQUET}" && -s "${DAFT_MANIFEST}" ]]; then
        DAFT_PREPARE_DATA=0
        log "reusing local TPC-H data: ${DAFT_PARQUET}"
    elif [[ ! -e "${DAFT_PARQUET}" && ! -e "${DAFT_MANIFEST}" &&
            ( ! -e "${parent}" || ( -d "${parent}" && -z "$(find "${parent}" -mindepth 1 -print -quit)" ) ) ]]; then
        DAFT_PREPARE_DATA=1
        log "TPC-H data are absent; they will be generated on this Runner: ${DAFT_PARQUET}"
    else
        log 'ERROR: incomplete TPC-H data or checksum manifest; refusing to overwrite partial data'
        return 30
    fi
}

prepare_daft_dataset() {
    local lock="${DAFT_DATA_ROOT}/.generate-sf${DAFT_SF}.lock" status=0 free_bytes required_bytes
    required_bytes=$((1500000000 * DAFT_SF))
    free_bytes="$(df -PB1 "${DAFT_DATA_ROOT}" | awk 'NR==2 {print $4}')"
    [[ "${free_bytes}" =~ ^[0-9]+$ ]] && (( free_bytes >= required_bytes )) || {
        log "ERROR: SF${DAFT_SF} data generation needs at least ${required_bytes} bytes free on the local data disk"; return 30;
    }
    mkdir "${lock}" || { log "ERROR: another data generation is active: ${lock}"; return 30; }
    log "generating TPC-H SF${DAFT_SF} data on this Runner with the original upstream generator"
    container_exec env DAFT_PROGRESS_BAR=0 \
        sh -c 'cd "$1" && exec "$2" -m benchmarking.tpch.data_generation --tpch_gen_folder "$3" --scale_factor "$4" --generate_parquet' \
        sh "${DAFT_SOURCE}" "${DAFT_VENV}/bin/python" "${DAFT_DATA_ROOT}" "${DAFT_SF}" \
        2>&1 | tee "${RESULTS_DIR}/data-generation.log" || status="${PIPESTATUS[0]}"
    if [[ "${status}" -eq 0 ]]; then
        python3 "${SCRIPT_DIR}/scripts/results/write_manifest.py" "${DAFT_PARQUET}" || status=40
    fi
    if [[ "${status}" -eq 0 ]]; then
        find "${DAFT_DATA_ROOT}/${DAFT_SF}_0/${DAFT_SF}" -maxdepth 1 -type f -name '*.tbl*' -delete || status=40
    fi
    rmdir -- "${lock}" || true
    [[ "${status}" -eq 0 ]] || {
        log 'ERROR: data generation failed; partial data are preserved for inspection and will not be reused'
        return 40
    }
}

build_daft_base() {
    local -a options=()
    local -a wheel_options=()
    local actual revision
    initialize_runtime || return $?
    [[ "$(normalize_arch "$(uname -m)")" == "${EXPECTED_ARCH}" ]] || {
        log 'ERROR: runner architecture differs from requested architecture'; return 20;
    }
    select_data_mode || return $?
    install_host_dependencies || return $?
    start_container || return $?
    [[ -z "${PERF_PROXY:-}" ]] || options+=("--setopt=proxy=${PERF_PROXY}")
    log 'installing Python, Git and data-generation tools inside the private openEuler container'
    docker exec --user 0 "${DAFT_CONTAINER_NAME}" dnf "${options[@]}" install -y \
        python3 python3-pip git gcc make coreutils findutils tar gzip procps-ng || return 30
    [[ "$(container_exec python3 -c 'import sys; print(sys.version_info.major, sys.version_info.minor)')" == '3 11' ]] || {
        log 'ERROR: container must provide Python 3.11 for the pinned test environment'; return 30;
    }
    [[ ! -e "${DAFT_SOURCE}" ]] || { log 'ERROR: refusing to reuse Daft source directory'; return 20; }
    log 'cloning the v0.7.2 upstream TPC-H benchmark sources inside the container'
    container_exec git -c advice.detachedHead=false clone --depth 1 --branch v0.7.2 \
        --filter=blob:none --sparse "${DAFT_SOURCE_URL}" "${DAFT_SOURCE}" || return 30
    container_exec git -C "${DAFT_SOURCE}" sparse-checkout set benchmarking || return 30
    revision="$(container_exec git -C "${DAFT_SOURCE}" rev-parse HEAD)" || return 30
    [[ "$(container_exec git -C "${DAFT_SOURCE}" tag --points-at HEAD)" == *v0.7.2* ]] || {
        log 'ERROR: upstream checkout does not point at v0.7.2'; return 30;
    }
    [[ ! -e "${DAFT_SOURCE}/daft" ]] || { log 'ERROR: source tree would shadow the installed wheel'; return 30; }
    local answers="${DAFT_SOURCE}/benchmarking/tpch/answers.py"
    if grep -q 'col("O_COMMENT").match(' "${answers}"; then
        sed -i 's/col("O_COMMENT").match(/col("O_COMMENT").regexp(/' "${answers}" || return 30
    fi
    [[ "$(grep -c 'col("O_COMMENT").regexp(' "${answers}")" == 1 ]] || {
        log 'ERROR: the documented q13 compatibility change did not apply'; return 30;
    }
    container_exec git -C "${DAFT_SOURCE}" diff -- benchmarking/tpch/answers.py > \
        "${RESULTS_DIR}/daft-source-patch.txt" || return 30
    [[ -s "${RESULTS_DIR}/daft-source-patch.txt" ]] || {
        log 'ERROR: upstream q13 compatibility patch was not recorded'; return 30;
    }
    container_exec python3 -m venv "${DAFT_VENV}" || return 30
    cp -- "${SCRIPT_DIR}/scripts/reference/requirements.txt" "${PERF_WORK_DIR}/requirements.txt" || return 30
    cp -- "${SCRIPT_DIR}/scripts/reference/tpch_driver.py" "${PERF_WORK_DIR}/tpch_driver.py" || return 30
    log 'installing the pinned official Daft wheel and benchmark dependencies inside the container'
    if [[ -d "${DAFT_WHEEL_DIR}/${EXPECTED_ARCH}" ]]; then
        wheel_options+=("--find-links=${DAFT_WHEEL_DIR}/${EXPECTED_ARCH}")
        if container_exec "${DAFT_VENV}/bin/python" -m pip install \
            --no-index "${wheel_options[@]}" --only-binary=daft \
            -r "${PERF_WORK_DIR}/requirements.txt"; then
            log 'all pinned dependencies installed from local wheels'
        else
            log 'local wheel set is incomplete; falling back to the configured PyPI mirror'
            container_exec "${DAFT_VENV}/bin/python" -m pip install \
                -i https://mirrors.huaweicloud.com/repository/pypi/simple/ "${wheel_options[@]}" \
                --only-binary=daft -r "${PERF_WORK_DIR}/requirements.txt" || return 30
        fi
    else
        container_exec "${DAFT_VENV}/bin/python" -m pip install \
            -i https://mirrors.huaweicloud.com/repository/pypi/simple/ --only-binary=daft \
            -r "${PERF_WORK_DIR}/requirements.txt" || return 30
    fi
    container_exec_clean "${DAFT_VENV}/bin/python" -m pip freeze > "${RESULTS_DIR}/pip-freeze.txt" || return 30
    actual="$(container_exec_clean "${DAFT_VENV}/bin/python" -c 'import daft; print(daft.__version__)')" || return 30
    [[ "${actual}" == "${SOFTWARE_VERSION}" ]] || {
        log "ERROR: installed Daft reports ${actual}, expected ${SOFTWARE_VERSION}"; return 30;
    }
    container_exec_clean sh -c 'cd "$1" && "$2" -c "import ray, benchmarking.tpch.answers"' \
        sh "${DAFT_SOURCE}" "${DAFT_VENV}/bin/python" || return 30
    if [[ "${DAFT_PREPARE_DATA}" == 1 ]]; then
        prepare_daft_dataset || return $?
    fi
    printf '%s\n' "${revision}" > "${PERF_WORK_DIR}/daft-source-revision.txt"
    printf '%s\n' "${revision}" > "${RESULTS_DIR}/daft-source-revision.txt"
    printf '%s\n' "${actual}" > "${PERF_ACTUAL_VERSION_FILE}"
    log "Daft ${actual} and upstream TPC-H revision ${revision} are ready"
}
