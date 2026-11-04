#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

prepare_sift_dataset() {
    local archive="${PERF_WORK_DIR}/sift.tar.gz"
    local local_archive="${LANCE_DATA_ARCHIVE_DIR}/sift.tar.gz"
    if [[ -s "${local_archive}" ]]; then
        log "using local SIFT-1M archive: ${local_archive}"
        cp -- "${local_archive}" "${archive}" || return 50
    elif [[ -s "${archive}" ]]; then
        log "using cached SIFT-1M archive: ${archive}"
    else
        log 'downloading TexMex SIFT-1M archive'
        if ! with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
            -o "${archive}.part" https://corpus-texmex.irisa.fr/sift.tar.gz; then
            with_network_proxy curl -fSL --retry 3 --connect-timeout 30 \
                -o "${archive}.part" ftp://ftp.irisa.fr/local/texmex/corpus/sift.tar.gz || return 50
        fi
        mv -- "${archive}.part" "${archive}" || return 50
    fi
    python3 "${SCRIPT_DIR}/scripts/results/check_sift_archive.py" "${archive}" || return 50
    container_exec tar -xzf "${archive}" -C "${LANCE_DATA_DIR}" || return 50
    local base="${LANCE_DATA_DIR}/sift/sift_base.fvecs"
    local query="${LANCE_DATA_DIR}/sift/sift_query.fvecs"
    [[ -s "${base}" && -s "${query}" ]] || { log 'ERROR: SIFT vectors are missing'; return 50; }
    cp -- "${SCRIPT_DIR}/scripts/results/prepare_sift.py" "${PERF_WORK_DIR}/prepare_sift.py" || return 50
    log 'converting the official SIFT-1M base and 1000 query vectors to Lance datasets'
    container_exec "${LANCE_VENV}/bin/python" "${PERF_WORK_DIR}/prepare_sift.py" \
        "${LANCE_DATA_DIR}/sift" "${LANCE_DATA_DIR}" || return 50
}

run_lance_benchmarks() {
    local benchmark_dir raw_log status=0 base_sha query_sha
    initialize_runtime || return $?
    check_lance_container || return $?
    [[ ! -e "${RESULTS_DIR}/benchmark_sift.csv" ]] || {
        log 'ERROR: refusing to overwrite an existing benchmark CSV'; return 50;
    }
    prepare_sift_dataset || return $?
    benchmark_dir="${LANCE_SOURCE_DIR}/benchmarks/sift"
    raw_log="${RESULTS_DIR}/benchmark_sift.log"
    : > "${raw_log}"
    log 'building the official IVF-PQ index: 256 partitions, 16 subvectors'
    container_exec sh -c 'cd "$1" && "$2" index.py "$3" -i 256 -p 16 -c vector' sh \
        "${benchmark_dir}" "${LANCE_VENV}/bin/python" "${LANCE_DATA_DIR}/sift1m.lance" \
        2>&1 | tee -a "${raw_log}" || status="${PIPESTATUS[0]}"
    [[ "${status}" -eq 0 ]] || { log 'ERROR: upstream SIFT index creation failed'; return 50; }
    log 'running upstream metrics.py for all 42 nprobes/refine-factor scenarios'
    container_exec sh -c 'cd "$1" && "$2" metrics.py "$3" "$4" -i 256 -p 16 -s 1000 -q "$5" -k 1' sh \
        "${benchmark_dir}" "${LANCE_VENV}/bin/python" \
        "${LANCE_DATA_DIR}/sift1m.lance" "${RESULTS_DIR}/benchmark_sift.csv" \
        "${LANCE_DATA_DIR}/sift_query.lance" \
        2>&1 | tee -a "${raw_log}" || status="${PIPESTATUS[0]}"
    [[ "${status}" -eq 0 ]] || { log 'ERROR: upstream SIFT metrics run failed'; return 50; }
    base_sha="$(sha256sum "${LANCE_DATA_DIR}/sift/sift_base.fvecs")"
    query_sha="$(sha256sum "${LANCE_DATA_DIR}/sift/sift_query.fvecs")"
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_sift.csv" "${RESULTS_DIR}/benchmark_lance.json" \
        "${base_sha%% *}" "${query_sha%% *}" || return 50
    log 'normalized all 42 official SIFT scenarios (recall@1 and mean query time)'
}
