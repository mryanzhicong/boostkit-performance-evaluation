#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_simdjson_runtime() {
    simdjson_configure_paths || return $?
    local build src data_dir target runtime_file
    build="$(simdjson_build_dir)"
    src="$(simdjson_source_dir)"
    data_dir="$(simdjson_data_dir)"

    check_simdjson_container || return $?

    for target in "${SIMDJSON_TARGETS[@]}"; do
        simdjson_container_exec test -x "${build}/${target}" || {
            log_message "ERROR: benchmark executable is missing inside the container: ${build}/${target}"
            return 40
        }
    done
    simdjson_container_exec test -s "${src}/jsonexamples/twitter.json" || {
        log_message 'ERROR: bundled twitter.json is missing inside the container'
        return 40
    }
    simdjson_container_exec test -s "${src}/jsonexamples/citm_catalog.json" || {
        log_message 'ERROR: bundled citm_catalog.json is missing inside the container'
        return 40
    }
    simdjson_container_exec test -s "${src}/jsonexamples/amazon_cellphones.ndjson" || {
        log_message 'ERROR: bundled amazon_cellphones.ndjson is missing inside the container'
        return 40
    }
    simdjson_container_exec test -s "${data_dir}/gsoc-2018.json" || {
        log_message "ERROR: official corpus is missing inside the container: ${data_dir}/gsoc-2018.json"
        return 40
    }
    simdjson_container_exec test -s "${data_dir}/numbers.json" || {
        log_message "ERROR: official corpus is missing inside the container: ${data_dir}/numbers.json"
        return 40
    }
    simdjson_container_exec bash -c 'avail=$(df -Pk "$1" | awk "NR==2 {print \$4}"); [ "$avail" -ge 524288 ]' _ "${PERF_WORK_DIR}" || {
        log_message 'ERROR: less than 512 MiB free inside the work directory'
        return 40
    }

    runtime_file="${RESULTS_DIR}/runtime.json"
    python3 - "${runtime_file}" "$(simdjson_arch "${EXPECTED_ARCH}")" "${SIMDJSON_CONTAINER_NAME}" "${SIMDJSON_CONTAINER_IMAGE}" "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${PERF_REPS}" "${SIMDJSON_WARMUPS}" <<'PY'
import json
import sys

path, arch, container, image, work_dir, results_dir, reps, warmups = sys.argv[1:]
payload = {
    "architecture": arch,
    "container": container,
    "container_image": image,
    "network": "host",
    "cpu_quota": "unlimited",
    "memory_quota": "unlimited",
    "numa_policy": "unlimited",
    "work_dir": work_dir,
    "results_dir": results_dir,
    "reps": int(reps),
    "warmups": int(warmups),
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    log_message "runtime is ready: ${SIMDJSON_CONTAINER_NAME} (5 benchmark executables, corpus and 512 MiB free space verified)"
}
