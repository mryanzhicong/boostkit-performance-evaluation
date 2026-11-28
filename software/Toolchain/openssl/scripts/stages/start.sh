#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_openssl_runtime() {
    openssl_configure_paths || return $?
    local bin src
    bin="$(openssl_bin)"
    src="$(openssl_source_dir)"

    check_openssl_container || return $?

    openssl_container_exec test -x "${bin}" || {
        log_message "ERROR: openssl binary is missing inside the container: ${bin}"
        return 40
    }
    openssl_container_exec test -s "${src}/configdata.pm" || {
        log_message 'ERROR: configdata.pm is missing inside the container build tree'
        return 40
    }
    openssl_container_exec test -f "${src}/test/run_tests.pl" || {
        log_message 'ERROR: the upstream test suite (test/run_tests.pl) is missing inside the container'
        return 40
    }
    openssl_container_exec test -d "${src}/test/recipes" || {
        log_message 'ERROR: the upstream test recipes are missing inside the container'
        return 40
    }
    openssl_container_exec bash -c 'avail=$(df -Pk "$1" | awk "NR==2 {print \$4}"); [ "$avail" -ge 1048576 ]' _ "${PERF_WORK_DIR}" || {
        log_message 'ERROR: less than 1 GiB free inside the work directory'
        return 40
    }

    python3 - "${RESULTS_DIR}/runtime.json" "$(openssl_arch "${EXPECTED_ARCH}")" \
        "${OPENSSL_CONTAINER_NAME}" "${OPENSSL_CONTAINER_IMAGE:-unknown}" \
        "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${PERF_REPS}" "${OPENSSL_WARMUPS}" \
        "${OPENSSL_SPEED_SECONDS}" "${OPENSSL_BLOCK_BYTES}" "${OPENSSL_HARNESS_JOBS}" <<'PY'
import json
import sys

(path, arch, container, image, work_dir, results_dir, reps, warmups, seconds,
 block_bytes, harness_jobs) = sys.argv[1:]
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
    "speed_seconds": int(seconds),
    "block_bytes": int(block_bytes),
    "harness_jobs": int(harness_jobs),
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, ensure_ascii=False, indent=2)
    handle.write("\n")
PY
    log_message "runtime is ready: ${OPENSSL_CONTAINER_NAME} (binary, build tree, test suite and 1 GiB free space verified)"
}
