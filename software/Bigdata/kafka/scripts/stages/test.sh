#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

producer_worker() {
    local topic="$1" records="$2"
    kafka_exec "${KAFKA_HOME}/bin/kafka-producer-perf-test.sh" \
        --topic "${topic}" --num-records "${records}" \
        --record-size "${KAFKA_RECORD_SIZE}" --throughput -1 \
        --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
        --producer.config "${PERF_WORK_DIR}/conf/producer.properties"
}

consumer_worker() {
    local topic="$1" records="$2"
    kafka_exec "${KAFKA_HOME}/bin/kafka-consumer-perf-test.sh" \
        --broker-list "127.0.0.1:${KAFKA_PORT}" --topic "${topic}" \
        --fetch-size "${KAFKA_CONSUMER_FETCH_SIZE:-1048576}" \
        --threads "${KAFKA_CONSUMER_THREADS}" \
        --messages "${records}"
}

merge_producer_logs() {
    local pdir="$1" producer_log="$2" expected="$3"
    python3 - "${pdir}" "${producer_log}" "${expected}" <<'PY'
import glob, re, sys

pdir, out, expected = sys.argv[1], sys.argv[2], int(sys.argv[3])
pattern = re.compile(
    r'^(\d+) records sent,\s*([\d.]+) records/sec\s*\(([\d.]+) MB/sec\),\s*([\d.]+) ms avg latency',
    re.M,
)
rows = []
for path in sorted(glob.glob(pdir + '/part_*.log')):
    matches = pattern.findall(open(path, errors='ignore').read())
    if not matches:
        raise SystemExit('missing producer summary in ' + path)
    rows.append(tuple(float(x) for x in matches[-1]))
records = int(sum(row[0] for row in rows))
if records != expected:
    raise SystemExit(f'producer sent {records} records, expected {expected}')
rate = sum(row[1] for row in rows)
mbps = sum(row[2] for row in rows)
latency = sum(row[0] * row[3] for row in rows) / records
with open(out, 'w') as handle:
    handle.write(
        f'{records} records sent, {rate:.4f} records/sec ({mbps:.4f} MB/sec), '
        f'{latency:.2f} ms avg latency, 0.00 ms max latency, '
        '0 ms 50th, 0 ms 95th, 0 ms 99th, 0 ms 99.9th.\n'
    )
print(f'PRODUCER_TOTAL records={records} MBps={mbps:.4f}')
PY
}

merge_consumer_logs() {
    local cdir="$1" consumer_log="$2" expected="$3"
    python3 - "${cdir}" "${consumer_log}" "${expected}" <<'PY'
import csv, glob, sys

cdir, out, expected = sys.argv[1], sys.argv[2], int(sys.argv[3])
rows = []
for path in sorted(glob.glob(cdir + '/part_*.log')):
    table = [[cell.strip() for cell in row] for row in csv.reader(open(path, errors='ignore'))]
    summaries = []
    for index, columns in enumerate(table[:-1]):
        if 'MB.sec' not in columns or 'data.consumed.in.nMsg' not in columns:
            continue
        values = table[index + 1]
        if len(values) != len(columns):
            raise SystemExit('mismatched consumer CSV row in ' + path)
        record = dict(zip(columns, values))
        summaries.append(
            (
                float(record['data.consumed.in.MB']),
                float(record['MB.sec']),
                int(record['data.consumed.in.nMsg']),
            )
        )
    if len(summaries) != 1:
        raise SystemExit(f'expected one consumer summary in {path}, found {len(summaries)}')
    rows.append(summaries[0])
records = sum(row[2] for row in rows)
if records != expected:
    raise SystemExit(f'consumer received {records} records, expected {expected}')
mb = sum(row[0] for row in rows)
mbps = sum(row[1] for row in rows)
with open(out, 'w') as handle:
    handle.write(
        'start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, '
        'nMsg.sec, rebalance.time.ms, fetch.time.ms, fetch.MB.sec, fetch.nMsg.sec\n'
    )
    handle.write(
        f'merged, merged, {mb:.4f}, {mbps:.4f}, {records}, 0.0, 0, 0, 0.0, 0.0\n'
    )
print(f'CONSUMER_TOTAL records={records} MBps={mbps:.4f}')
PY
}

run_kafka_benchmark() {
    initialize_runtime || return $?
    check_container || return $?
    local available_bytes
    available_bytes="$(df -B1 --output=avail "${PERF_WORK_DIR}" | tail -n 1 | tr -d ' ')"
    [[ "${available_bytes}" =~ ^[0-9]+$ ]] && (( available_bytes >= 25000000000 )) || {
        log_message 'ERROR: Kafka benchmark requires at least 25 GB free in the private data filesystem'; return 50;
    }
    local producer_log="${RESULTS_DIR}/producer.log"
    local consumer_log="${RESULTS_DIR}/consumer.log"
    local raw="${RESULTS_DIR}/benchmark_kafka_raw.log"
    local pdir="${PERF_WORK_DIR}/producer_parts"
    local cdir="${PERF_WORK_DIR}/consumer_parts"
    local producer_procs="${KAFKA_PRODUCER_PROCS:-0}"
    (( producer_procs > 0 )) || producer_procs="${KAFKA_TOPICS}"
    if (( KAFKA_TOPICS > 1 )) && (( producer_procs != KAFKA_TOPICS )); then
        log_message "ERROR: KAFKA_PRODUCER_PROCS must equal KAFKA_TOPICS in multi-topic mode"
        return 50
    fi
    local topic i
    for (( i = 1; i <= KAFKA_TOPICS; i++ )); do
        topic="$(kafka_topic_name "${i}")"
        kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --describe \
            --bootstrap-server "127.0.0.1:${KAFKA_PORT}" --topic "${topic}" >/dev/null || return 50
    done
    rm -rf "${pdir}" "${cdir}"
    mkdir -p "${pdir}" "${cdir}"

    log_message "producer benchmark: ${KAFKA_TOPICS} topics × ${KAFKA_RECORDS_PER_TOPIC} records × ${KAFKA_RECORD_SIZE} bytes, processes=${producer_procs}"
    local -a pids=()
    if (( KAFKA_TOPICS == 1 )); then
        local base records part
        for (( i = 0; i < producer_procs; i++ )); do
            base=$(( KAFKA_RECORDS / producer_procs ))
            records="${base}"
            if (( i < KAFKA_RECORDS % producer_procs )); then
                records=$(( records + 1 ))
            fi
            producer_worker "$(kafka_topic_name 1)" "${records}" \
                > "${pdir}/part_$((i + 1)).log" 2>&1 &
            pids+=("$!")
        done
    else
        for (( i = 1; i <= KAFKA_TOPICS; i++ )); do
            producer_worker "$(kafka_topic_name "${i}")" "${KAFKA_RECORDS_PER_TOPIC}" \
                > "${pdir}/part_${i}.log" 2>&1 &
            pids+=("$!")
        done
    fi
    local failed=0
    for i in "${pids[@]}"; do
        wait "${i}" || failed=1
    done
    if (( failed != 0 )); then
        log_message 'ERROR: official Kafka producer benchmark failed'
        return 50
    fi
    merge_producer_logs "${pdir}" "${producer_log}" "${KAFKA_RECORDS}" || {
        log_message 'ERROR: Kafka producer summaries are missing or inconsistent'
        return 50
    }

    log_message "consumer benchmark: ${KAFKA_TOPICS} topics × ${KAFKA_RECORDS_PER_TOPIC} records, fetch-size=${KAFKA_CONSUMER_FETCH_SIZE:-1048576}, threads/process=${KAFKA_CONSUMER_THREADS}"
    pids=()
    for (( i = 1; i <= KAFKA_TOPICS; i++ )); do
        consumer_worker "$(kafka_topic_name "${i}")" "${KAFKA_RECORDS_PER_TOPIC}" \
            > "${cdir}/part_${i}.log" 2>&1 &
        pids+=("$!")
    done
    failed=0
    for i in "${pids[@]}"; do
        wait "${i}" || failed=1
    done
    if (( failed != 0 )); then
        log_message 'ERROR: official Kafka consumer benchmark failed'
        return 50
    fi
    merge_consumer_logs "${cdir}" "${consumer_log}" "${KAFKA_RECORDS}" || {
        log_message 'ERROR: Kafka consumer summaries are missing or inconsistent'
        return 50
    }

    {
        printf '=== producer ===\n'
        cat "${producer_log}"
        printf '\n=== consumer ===\n'
        cat "${consumer_log}"
    } > "${raw}"
    python3 "${CASE_DIR}/scripts/results/parse_benchmark.py" \
        --producer "${producer_log}" --consumer "${consumer_log}" \
        --output "${RESULTS_DIR}/benchmark_kafka.json" --expected-records "${KAFKA_RECORDS}" \
        --fetch-size "${KAFKA_CONSUMER_FETCH_SIZE:-1048576}" \
        --threads "${KAFKA_CONSUMER_THREADS}" \
        --record-size "${KAFKA_RECORD_SIZE}" \
        --partitions "${KAFKA_PARTITIONS}" \
        --topics "${KAFKA_TOPICS}" \
        --producer-processes "${producer_procs}" \
        --consumer-processes "${KAFKA_TOPICS}" || {
        log_message 'ERROR: Kafka benchmark metrics are missing or invalid'
        return 50
    }
}
