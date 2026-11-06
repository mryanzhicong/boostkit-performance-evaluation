#!/usr/bin/env bash
# Prepare the measurement environment for the shared test payload.
#
# The dedicated Runner has no hugetlbfs reservation, so the start stage probes
# a small ordered list of DPDK hugepage/memory profiles with a one second
# bdevperf smoke run and persists the first working profile to
# PERF_WORK_DIR/runtime.json.  The test stage reuses that exact
# profile, which keeps every measurement on identical runtime parameters.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

# Architecture-dependent: aarch64 systems page in more memory per reactor
# thread, so the larger ordinary-page arena is tried first there.
spdk_runtime_candidates() {
    case "$(normalize_architecture "${EXPECTED_ARCH}")" in
        x86_64)
            printf '%s\n' "--no-huge -s 512"
            printf '%s\n' "--no-huge -s 1024"
            ;;
        aarch64)
            printf '%s\n' "--no-huge -s 1024"
            printf '%s\n' "--no-huge -s 512"
            ;;
        *)
            return 20
            ;;
    esac
    # Last resort: the runner may have 2 MiB hugepages configured instead.
    printf '%s\n' "-s 512"
}

write_smoke_configs() {
    local smoke_dir="${PERF_WORK_DIR}/smoke" bdev_count="${1:-1}"
    mkdir -p "${smoke_dir}"
    python3 - "${smoke_dir}" "${bdev_count}" <<'PYEOF'
import json
import sys
from pathlib import Path

smoke_dir = Path(sys.argv[1])
bdev_count = int(sys.argv[2])
blocks = 32768  # 16 MiB of 512 byte blocks per Malloc bdev
config = {
    "subsystems": [
        {
            "subsystem": "bdev",
            "config": [
                {
                    "method": "bdev_malloc_create",
                    "params": {
                        "name": f"Malloc{index}",
                        "block_size": 512,
                        "num_blocks": blocks,
                    },
                }
                for index in range(bdev_count)
            ],
        }
    ]
}
(smoke_dir / "bdev.conf.json").write_text(
    json.dumps(config, indent=2) + "\n", encoding="utf-8"
)
jobs = ["[global]", "rw=randread", "bs=4096", "iodepth=8", "", "[smoke]", "filename=Malloc0", ""]
(smoke_dir / "jobs.ini").write_text("\n".join(jobs), encoding="utf-8")
PYEOF
}

# The bdevperf summary prints " Total ... : <IOPS> <MiB/s> ..." rows.  The
# summary line starts with a carriage return (bdevperf redraws it), so strip
# '\r' before splitting; log lines such as "Total cores available" are not
# matched because their first remaining field is not a number.
parse_total_iops() {
    awk '
        {
            line = $0
            gsub(/\r/, "", line)
            if (line !~ /^[[:space:]]*Total[[:space:]]*:/) next
            sub(/^[[:space:]]*Total[[:space:]]*:[[:space:]]*/, "", line)
            split(line, fields, /[[:space:]]+/)
            if (fields[1] ~ /^[0-9]+(\.[0-9]+)?$/) value = fields[1]
        }
        END { if (value != "") print value }
    '
}

resolve_runtime_profile() {
    local smoke_dir="${PERF_WORK_DIR}/smoke"
    local smoke_log="${RESULTS_DIR}/smoke-test.log"
    local candidate candidate_label candidate_eal output status iops attempt_log=()
    : > "${smoke_log}"
    write_smoke_configs 1 || return 20
    while IFS= read -r candidate; do
        [[ -n "${candidate}" ]] || continue
        read -r -a candidate_eal <<< "${candidate}"
        candidate_label="$(printf '%s' "${candidate// /_}" | tr -d '-')"
        attempt_log+=("${candidate}")
        log_message "probing DPDK runtime profile inside the private container: ${candidate}"
        printf '\n### probe: %s\n' "${candidate}" >> "${smoke_log}"
        set +e
        # The probe and the measured matrix both run inside the container, so the
        # profile that is recorded here is the one the test stage can actually use.
        # `timeout` is executed inside the container: it cannot wrap a shell
        # function, so the exec helper goes first.
        output="$(spdk_container_exec_at "${smoke_dir}" \
            timeout --kill-after=15 120 "${BDEVPERF_BIN}" -m 0x1 \
            -c "${smoke_dir}/bdev.conf.json" -j "${smoke_dir}/jobs.ini" \
            -t 1 -l -H "${candidate_eal[@]}" 2>&1)"
        status=$?
        set -e
        printf '%s\n' "${output}" >> "${smoke_log}"
        if [[ "${status}" -ne 0 ]]; then
            log_message "profile '${candidate}' failed with exit code ${status}"
            continue
        fi
        iops="$(printf '%s\n' "${output}" | parse_total_iops)"
        if [[ -z "${iops}" ]] || ! awk -v value="${iops}" 'BEGIN { exit !(value + 0 > 0) }'; then
            log_message "profile '${candidate}' produced no usable result"
            continue
        fi
        log_message "profile '${candidate}' works (smoke IOPS ${iops})"
        python3 - "${RUNTIME_PROFILE_FILE}" "${candidate_label}" "${candidate}" \
            "${iops}" "$(hugepage_snapshot_json)" "${smoke_log}" <<'PYEOF'
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

(output, label, eal_args, smoke_iops, hugepages, smoke_log) = sys.argv[1:]
payload = {
    "resolved_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "profile": label,
    "eal_args": eal_args.split(),
    "bdevperf_args": ["-H"],
    "hugepages": json.loads(hugepages),
    "smoke": {
        "duration_seconds": 1,
        "iops": float(smoke_iops),
        "log": smoke_log,
    },
    "offline": True,
}
path = Path(output)
path.parent.mkdir(parents=True, exist_ok=True)
temporary = path.with_name(path.name + ".tmp")
temporary.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
temporary.replace(path)
PYEOF
        return 0
    done < <(spdk_runtime_candidates)
    log_message "ERROR: no DPDK runtime profile worked; see ${smoke_log}"
    local attempted
    for attempted in "${attempt_log[@]}"; do
        log_message "  attempted: ${attempted}"
    done
    return 20
}

start_spdk_runtime() {
    initialize_runtime || return $?
    check_spdk_container || return 20
    spdk_container_exec test -x "${BDEVPERF_BIN}" || {
        log_message "ERROR: bdevperf is missing in the container; run the build stage first (${BDEVPERF_BIN})"
        return 20
    }
    if [[ ! -s "${BUILD_META_FILE}" ]]; then
        log_message "ERROR: build metadata is missing; run the build stage first"
        return 20
    fi
    local cpu_count
    cpu_count="$(spdk_container_exec nproc 2>/dev/null || true)"
    if [[ ! "${cpu_count}" =~ ^[0-9]+$ ]] || (( cpu_count < 4 )); then
        log_message "ERROR: the multi-bdev scenarios need at least 4 CPUs in the container, found ${cpu_count:-unknown}"
        return 20
    fi
    resolve_runtime_profile || return 20
    log_message "runtime profile ready: $(< "${RUNTIME_PROFILE_FILE}")"
}
