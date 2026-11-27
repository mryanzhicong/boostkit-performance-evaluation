#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
source "$(dirname "${BASH_SOURCE[0]}")/start.sh"

write_workload_manifest() {
    if [[ -s "${WORKLOAD_MANIFEST}" ]]; then
        return 0
    fi
    mkdir -p "${WORKLOAD_DIR}" || return 30
    ( cd "${CASE_DIR}/scripts/workload" && python3 - \
        "${WORKLOAD_MANIFEST}" "${DDL_FILE}" "${STATEMENT_DIR}" "${CELEBORN_SCALE_FACTOR}" "${CELEBORN_QUERY_COUNT}" <<'PY'
import json
import sys
from pathlib import Path

import tpcds

manifest_path, ddl_path, statement_dir, scale_factor, query_count = sys.argv[1:]
tables = tpcds.load_tables(Path(ddl_path))
statements = tpcds.statement_files(Path(statement_dir))[: int(query_count)]
if len(statements) != int(query_count):
    raise SystemExit(f"ERROR: expected {query_count} pinned statements, found {len(statements)}")
payload = {
    "scale_factor": float(scale_factor),
    "tpcds_kit_commit": "1b7fb7529edae091684201fab142d956d6afd881",
    "tables": [
        {"name": table.name, "columns": [name for name, _ in table.columns]}
        for table in tables
    ],
    "statements": [
        {"name": path.name, "sha256": tpcds.file_digest(path)} for path in statements
    ],
}
Path(manifest_path).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
    ) || { log_message 'ERROR: cannot write the pinned workload manifest'; return 30; }
    log_message "pinned workload manifest covers $(python3 -c 'import json,sys;print(len(json.load(open(sys.argv[1]))["statements"]))' "${WORKLOAD_MANIFEST}") statements"
}

write_dataset_summary() {
    python3 - "${RESULTS_DIR}/dataset.json" "${DATA_DIR}" "${CELEBORN_SCALE_FACTOR}" "${WORKLOAD_MANIFEST}" <<'PY'
import json
import re
import sys
from pathlib import Path

target, data_dir, scale, manifest_path = sys.argv[1], Path(sys.argv[2]), sys.argv[3], Path(sys.argv[4])
manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
pattern = re.compile(r"^(?P<table>[a-z_]+?)(?:_\d+_\d+)?\.dat(?:\.\d+)?$")
files = {}
for path in data_dir.iterdir():
    match = pattern.match(path.name)
    if not match:
        continue
    files.setdefault(match.group("table"), []).append(path)
tables = []
for table in manifest["tables"]:
    name = table["name"]
    matched = files.get(name, [])
    if not matched:
        raise SystemExit(f"ERROR: no generated data files for {name}")
    tables.append({"name": name, "files": len(matched), "bytes": sum(p.stat().st_size for p in matched)})
payload = {"scale_factor": float(scale), "path": str(data_dir),
           "files": sum(len(value) for value in files.values()),
           "total_bytes": sum(p.stat().st_size for value in files.values() for p in value),
           "tables": tables}
Path(target).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
}

generate_dataset() {
    local marker="${DATA_DIR}/.complete"
    if [[ -s "${marker}" ]] && grep -qx "scale_factor=${CELEBORN_SCALE_FACTOR}" "${marker}"; then
        log_message "reusing the TPC-DS data set already generated at ${DATA_DIR}"
        write_dataset_summary || return 50
        return 0
    fi
    local parallel="${CELEBORN_PARALLEL_GENERATORS}"
    if [[ -z "${parallel}" ]]; then
        parallel="$(container_cpu_count)"
        (( parallel > 16 )) && parallel=16
        # dsdgen needs at least two children when it is asked to split the data.
        (( parallel < 2 )) && parallel=2
    fi
    mkdir -p "${DATA_DIR}" "${RESULTS_DIR}/generator-logs" || return 50
    log_message "generating TPC-DS SF${CELEBORN_SCALE_FACTOR} data with ${parallel} parallel generators"
    local index failed=0
    local -a generator_pids=()
    for (( index = 1; index <= parallel; index++ )); do
        celeborn_container_exec_at "${TPCDS_KIT_HOME}/tools" bash -lc \
            "./dsdgen -DIR '${DATA_DIR}' -SCALE '${CELEBORN_SCALE_FACTOR}' -TERMINATE N -PARALLEL ${parallel} -CHILD ${index} -QUIET Y" \
            >"${RESULTS_DIR}/generator-logs/child-${index}.log" 2>&1 &
        generator_pids+=("$!")
    done
    for index in "${generator_pids[@]}"; do
        wait "${index}" || failed=1
    done
    (( failed == 0 )) || { log_message 'ERROR: the TPC-DS data generator failed'; return 50; }
    printf 'scale_factor=%s\nparallel=%s\n' "${CELEBORN_SCALE_FACTOR}" "${parallel}" > "${marker}"
    write_dataset_summary || return 50
    log_message "TPC-DS data set is ready: $(du -sh "${DATA_DIR}" | cut -f1)"
}

spark_submit() {
    local log_file="$1"
    shift
    local driver_memory
    driver_memory="$(spark_driver_memory)" || return 50
    celeborn_container_exec bash -lc "
        set -o pipefail
        cd '${SPARK_HOME}'
        ./bin/spark-submit \
            --master 'local[*]' \
            --driver-memory '${driver_memory}' \
            --conf spark.ui.enabled=false \
            --conf spark.sql.warehouse.dir='${WAREHOUSE_DIR}' \
            --conf spark.sql.catalogImplementation=hive \
            --conf spark.hadoop.javax.jdo.option.ConnectionURL='jdbc:derby:;databaseName=${METASTORE_DIR}/metastore_db;create=true' \
            --conf spark.sql.session.timeZone=UTC \
            \"\$@\"
    " bash "$@" >"${log_file}" 2>&1
}

ensure_warehouse() {
    local marker="${METASTORE_DIR}/.complete"
    if [[ -s "${marker}" ]]; then
        log_message 'reusing the loaded ORC warehouse'
        return 0
    fi
    mkdir -p "${WAREHOUSE_DIR}" "${METASTORE_DIR}" || return 50
    log_message 'loading the generated text files into flat ORC tables'
    spark_submit "${RESULTS_DIR}/warehouse-load.log" \
        "${CASE_DIR}/scripts/workload/load_tables.py" \
        --ddl "${DDL_FILE}" \
        --data-dir "${DATA_DIR}" \
        --warehouse "${WAREHOUSE_DIR}" \
        --metastore "${METASTORE_DIR}" \
        --scale-factor "${CELEBORN_SCALE_FACTOR}" \
        --summary "${RESULTS_DIR}/warehouse-load.json" || {
        log_message 'ERROR: loading the TPC-DS ORC tables failed; see warehouse-load.log'; return 50;
    }
    printf 'scale_factor=%s\n' "${CELEBORN_SCALE_FACTOR}" > "${marker}"
}

record_disk_usage() {
    local stage="$1"
    python3 - "${RESULTS_DIR}/disk-usage.jsonl" "${stage}" "${PERF_WORK_DIR}" <<'PY'
import json
import os
import shutil
import sys
import time

path, stage, work_dir = sys.argv[1], sys.argv[2], sys.argv[3]
usage = shutil.disk_usage(work_dir)
with open(path, "a", encoding="utf-8") as handle:
    handle.write(json.dumps({
        "stage": stage,
        "epoch_seconds": int(time.time()),
        "total_bytes": usage.total,
        "used_bytes": usage.used,
        "free_bytes": usage.free,
    }, sort_keys=True) + "\n")
PY
}

sample_shuffle_bytes() {
    local app_id="$1"
    [[ -n "${app_id}" ]] || { printf '0\n'; return 0; }
    celeborn_container_exec bash -lc "
        total=0
        for dir in '${CELEBORN_STORAGE_DIR_1}' '${CELEBORN_STORAGE_DIR_2}'; do
            if [ -d \"\$dir/celeborn-worker/shuffle_data/${app_id}\" ]; then
                size=\$(du -sb \"\$dir/celeborn-worker/shuffle_data/${app_id}\" | cut -f1)
                total=\$((total + size))
            fi
        done
        printf '%s\n' \"\$total\"
    " || printf '0\n'
}

spark_log_excerpt() {
    # The complete Spark log stays in runs/sample<N>/spark.log; the raw log only
    # keeps the error lines and the tail so the preserved artefact stays small.
    local log="$1" sample="$2"
    printf '\n--- sample%s ---\n' "${sample}"
    if [[ ! -s "${log}" ]]; then
        printf '(no spark log output)\n'
        return 0
    fi
    local errors
    errors="$(grep -iE 'error|exception' "${log}" | tail -n 20 | cut -c1-400 || true)"
    if [[ -n "${errors}" ]]; then
        printf 'error lines:\n%s\n' "${errors}"
    fi
    printf 'last 120 lines:\n'
    tail -n 120 "${log}" | cut -c1-400
}

run_one_sample() {
    local sample="$1"
    local sample_dir="${RESULTS_DIR}/runs/sample${sample}"
    mkdir -p "${sample_dir}" || return 50
    log_message "sample ${sample}/${PERF_REPS}: running ${CELEBORN_QUERY_COUNT} statements through Celeborn"
    record_disk_usage "sample${sample}-begin"
    local driver_memory
    driver_memory="$(spark_driver_memory)" || return 50
    celeborn_container_exec bash -lc "
        set -o pipefail
        cd '${SPARK_HOME}'
        ./bin/spark-submit \
            --master 'local[*]' \
            --driver-memory '${driver_memory}' \
            --jars '${CELEBORN_CLIENT_JAR}' \
            --conf spark.shuffle.manager='${CELEBORN_SHUFFLE_MANAGER}' \
            --conf spark.celeborn.master.endpoints='${CELEBORN_CLIENT_ENDPOINTS}' \
            --conf spark.shuffle.service.enabled=false \
            --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
            --conf spark.dynamicAllocation.enabled=false \
            --conf spark.ui.enabled=false \
            --conf spark.sql.warehouse.dir='${WAREHOUSE_DIR}' \
            --conf spark.sql.catalogImplementation=hive \
            --conf spark.hadoop.javax.jdo.option.ConnectionURL='jdbc:derby:;databaseName=${METASTORE_DIR}/metastore_db;create=true' \
            --conf spark.sql.session.timeZone=UTC \
            --conf spark.sql.shuffle.partitions=${CELEBORN_SHUFFLE_PARTITIONS} \
            --conf spark.sql.adaptive.enabled=false \
            '${CASE_DIR}/scripts/workload/run_queries.py' \
            --manifest '${WORKLOAD_MANIFEST}' \
            --query-dir '${STATEMENT_DIR}' \
            --warehouse '${WAREHOUSE_DIR}' \
            --metastore '${METASTORE_DIR}' \
            --sample ${sample} \
            --out '${sample_dir}/queries.jsonl' \
            --shuffle-partitions ${CELEBORN_SHUFFLE_PARTITIONS} \
            --shuffle-dirs '${CELEBORN_STORAGE_DIR_1},${CELEBORN_STORAGE_DIR_2}'
    " >"${sample_dir}/spark.log" 2>&1 || {
        log_message "ERROR: sample ${sample} failed; see $(basename "${sample_dir}")/spark.log"
        return 50
    }
    local app_id shuffle_bytes
    app_id="$(python3 -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as handle:
    for line in handle:
        record = json.loads(line)
        if record.get("record") == "application":
            print(record.get("application_id") or "")
            break
' "${sample_dir}/queries.jsonl")"
    if ! shuffle_bytes="$(python3 -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as handle:
    for line in handle:
        record = json.loads(line)
        if record.get("record") == "shuffle_usage":
            print(int(record["bytes"]))
            break
    else:
        raise SystemExit(2)
' "${sample_dir}/queries.jsonl")"; then
        log_message "ERROR: sample ${sample} did not report the Celeborn storage usage"
        return 50
    fi
    local storage_after
    storage_after="$(sample_shuffle_bytes "${app_id}")"
    python3 - "${sample_dir}/shuffle.json" "${sample}" "${app_id}" "${shuffle_bytes}" "${storage_after}" <<'PY'
import json
import sys

target, sample, app_id, shuffle_bytes, storage_after = sys.argv[1:]
with open(target, "w", encoding="utf-8") as handle:
    json.dump({"sample": int(sample), "application_id": app_id,
               "shuffle_bytes": int(shuffle_bytes),
               "storage_bytes_after_stop": int(storage_after)},
              handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
    if (( shuffle_bytes <= 0 )); then
        log_message "ERROR: Celeborn stored no shuffle bytes for sample ${sample} (application ${app_id})"
        return 50
    fi
    record_disk_usage "sample${sample}-end"
    log_message "sample ${sample} wrote ${shuffle_bytes} shuffle bytes through Celeborn"
}

run_celeborn_benchmark() {
    initialize_runtime || return $?
    check_celeborn_container || return 40
    check_celeborn_services || return $?
    record_disk_usage 'test-begin'
    write_workload_manifest || return $?
    generate_dataset || return $?
    ensure_warehouse || return $?
    local sample
    for (( sample = 1; sample <= PERF_REPS; sample++ )); do
        run_one_sample "${sample}" || return $?
    done
    record_disk_usage 'test-end'
    python3 - "${RESULTS_DIR}" "${PERF_REPS}" "${CELEBORN_SCALE_FACTOR}" "${WORKLOAD_MANIFEST}" <<'PY'
import json
import statistics
import sys
from pathlib import Path

results_dir, samples, scale, manifest = Path(sys.argv[1]), int(sys.argv[2]), sys.argv[3], Path(sys.argv[4])
measured = []
for sample in range(2, samples + 1):
    payload = json.loads((results_dir / "runs" / f"sample{sample}" / "shuffle.json").read_text(encoding="utf-8"))
    measured.append(payload["shuffle_bytes"])
if not measured:
    raise SystemExit("ERROR: no measured sample reported shuffle bytes")
# A retried stage makes one round store more shuffle data than the others, so the
# round median is reported instead of the mean; the per-round values stay visible.
median_bytes = int(statistics.median(measured))
print(median_bytes)
Path(results_dir / "shuffle-summary.json").write_text(
    json.dumps(
        {
            "per_sample_bytes": measured,
            "median_measured_bytes": median_bytes,
            "max_measured_bytes": max(measured),
            "min_measured_bytes": min(measured),
        },
        indent=2,
        sort_keys=True,
    )
    + "\n",
    encoding="utf-8",
)
PY
    local shuffle_bytes
    shuffle_bytes="$(python3 -c '
import json, sys
print(json.load(open(sys.argv[1], encoding="utf-8"))["median_measured_bytes"])
' "${RESULTS_DIR}/shuffle-summary.json")"
    {
        printf '=== Celeborn service state ===\n'
        cat "${RESULTS_DIR}/service-state.json"
        printf '\n=== workload manifest ===\n'
        cat "${WORKLOAD_MANIFEST}"
        printf '\n=== dataset ===\n'
        cat "${RESULTS_DIR}/dataset.json"
        printf '\n=== warehouse load ===\n'
        cat "${RESULTS_DIR}/warehouse-load.json"
        printf '\n=== per-sample shuffle evidence ===\n'
        for (( sample = 1; sample <= PERF_REPS; sample++ )); do
            cat "${RESULTS_DIR}/runs/sample${sample}/shuffle.json"
        done
        printf '\n=== per-sample statement records ===\n'
        for (( sample = 1; sample <= PERF_REPS; sample++ )); do
            printf '\n--- sample%s ---\n' "${sample}"
            cat "${RESULTS_DIR}/runs/sample${sample}/queries.jsonl"
        done
        printf '\n=== spark log excerpts ===\n'
        for (( sample = 1; sample <= PERF_REPS; sample++ )); do
            spark_log_excerpt "${RESULTS_DIR}/runs/sample${sample}/spark.log" "${sample}"
        done
    } >"${RESULTS_DIR}/benchmark_celeborn_raw.log"
    log_message "parsing ${PERF_REPS} samples (1 warm-up, ${PERF_REPS}-1 measured) at SF${CELEBORN_SCALE_FACTOR}"
    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --results-dir "${RESULTS_DIR}" \
        --manifest "${WORKLOAD_MANIFEST}" \
        --samples "${PERF_REPS}" \
        --scale-factor "${CELEBORN_SCALE_FACTOR}" \
        --shuffle-bytes "${shuffle_bytes}" \
        --output "${RESULTS_DIR}/benchmark_celeborn.json" || {
        log_message 'ERROR: the Celeborn benchmark metrics are missing or invalid'
        return 50
    }
}
