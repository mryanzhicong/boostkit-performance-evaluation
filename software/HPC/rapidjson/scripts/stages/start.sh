#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_rapidjson_runtime() {
    rapidjson_configure_paths || return $?
    local build src label runtime_file
    build="$(rapidjson_build_dir)"
    src="$(rapidjson_source_dir)"

    check_rapidjson_container || return $?
    label="$(docker inspect --format '{{index .Config.Labels "boostkit.rapidjson.run-id"}}' "${RAPIDJSON_CONTAINER_NAME}" 2>/dev/null || true)"
    if [[ "${label}" != "${PERF_RUN_ID}" ]]; then
        log_message "ERROR: container ${RAPIDJSON_CONTAINER_NAME} has run-id label '${label}', expected '${PERF_RUN_ID}'"
        return 40
    fi

    local binary
    for binary in perftest unittest; do
        rapidjson_container_exec test -x "${build}/bin/${binary}" || {
            log_message "ERROR: benchmark executable is missing inside the container: ${build}/bin/${binary}"
            return 40
        }
    done
    [[ -s "${SCRIPT_DIR}/fixtures/${RAPIDJSON_PATCH_FILE}" ]] || {
        log_message "ERROR: the case-owned Kunpeng patch is missing: ${SCRIPT_DIR}/fixtures/${RAPIDJSON_PATCH_FILE}"
        return 40
    }
    rapidjson_container_exec test -s "${src}/bin/data/sample.json" || {
        log_message 'ERROR: bundled sample.json is missing inside the container'
        return 40
    }
    rapidjson_container_exec test -s "${src}/bin/types/paragraphs.json" || {
        log_message 'ERROR: bundled paragraphs.json is missing inside the container'
        return 40
    }
    rapidjson_container_exec bash -c '
        set -e
        sample=$(stat -c "%s" "$1")
        paragraphs=$(stat -c "%s" "$2")
        [ "${sample}" = "$3" ] || { echo "sample.json is ${sample} bytes, expected $3" >&2; exit 1; }
        [ "${paragraphs}" = "$4" ] || { echo "paragraphs.json is ${paragraphs} bytes, expected $4" >&2; exit 1; }
    ' _ "${src}/bin/data/sample.json" "${src}/bin/types/paragraphs.json" \
        "${RAPIDJSON_SAMPLE_BYTES}" "${RAPIDJSON_PARAGRAPHS_BYTES}" || {
        log_message 'ERROR: the bundled corpora do not match the pinned byte sizes'
        return 40
    }
    rapidjson_container_exec bash -c 'avail=$(df -Pk "$1" | awk "NR==2 {print \$4}"); [ "$avail" -ge 524288 ]' _ "${PERF_WORK_DIR}" || {
        log_message 'ERROR: less than 512 MiB free inside the work directory'
        return 40
    }

    runtime_file="${RESULTS_DIR}/runtime.json"
    python3 - "${runtime_file}" "$(rapidjson_arch "${EXPECTED_ARCH}")" "${RAPIDJSON_CONTAINER_NAME}" \
        "${RAPIDJSON_CONTAINER_IMAGE}" "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${PERF_REPS}" \
        "${RAPIDJSON_WARMUPS}" "${RAPIDJSON_GTEST_REPEAT}" "${RAPIDJSON_ARCH_SUFFIX:-probing}" <<'PY'
import json
import sys

(path, arch, container, image, work_dir, results_dir, reps, warmups, repeat, suffix) = sys.argv[1:]
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
    "gtest_architecture_suffix": suffix,
    "gtest_repeat": int(repeat),
    "reps": int(reps),
    "warmups": int(warmups),
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    log_message "runtime is ready: ${RAPIDJSON_CONTAINER_NAME} (perftest/unittest, corpora, patch copy and 512 MiB free space verified)"
}
