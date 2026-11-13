#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

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
    local procs="${KAFKA_PRODUCER_PROCS:-1}"
    local threads="${KAFKA_CONSUMER_THREADS:-8}"
    kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --describe \
        --bootstrap-server "127.0.0.1:${KAFKA_PORT}" --topic test_topic_kafka >/dev/null || return 50
    log_message "producer benchmark: ${KAFKA_RECORDS} records × ${KAFKA_RECORD_SIZE} bytes, processes=${procs}"
    if (( procs <= 1 )); then
        if ! kafka_exec "${KAFKA_HOME}/bin/kafka-producer-perf-test.sh" \
            --topic test_topic_kafka --num-records "${KAFKA_RECORDS}" \
            --record-size "${KAFKA_RECORD_SIZE}" --throughput -1 \
            --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
            --producer.config "${PERF_WORK_DIR}/conf/producer.properties" 2>&1 | tee "${producer_log}"; then
            log_message 'ERROR: official Kafka producer benchmark failed'
            return 50
        fi
    else
        local pdir="${PERF_WORK_DIR}/producer_parts"
        rm -rf "${pdir}"
        mkdir -p "${pdir}"
        local -a pids=()
        local i records
        for (( i = 0; i < procs; i++ )); do
            records=$(( KAFKA_RECORDS / procs ))
            if (( i < KAFKA_RECORDS % procs )); then
                records=$(( records + 1 ))
            fi
            kafka_exec "${KAFKA_HOME}/bin/kafka-producer-perf-test.sh" \
                --topic test_topic_kafka --num-records "${records}" \
                --record-size "${KAFKA_RECORD_SIZE}" --throughput -1 \
                --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
                --producer.config "${PERF_WORK_DIR}/conf/producer.properties" \
                > "${pdir}/part_${i}.log" 2>&1 &
            pids+=("$!")
        done
        local failed=0
        for i in "${pids[@]}"; do
            wait "${i}" || failed=1
        done
        if (( failed != 0 )); then
            log_message 'ERROR: official Kafka producer benchmark failed'
            return 50
        fi
        python3 - "${pdir}" "${producer_log}" "${KAFKA_RECORDS}" <<'PY'
import glob, re, sys
pdir, out, expected = sys.argv[1], sys.argv[2], int(sys.argv[3])
pattern = re.compile(
    r'^(\d+) records sent,\s*([\d.]+) records/sec\s*\(([\d.]+) MB/sec\),\s*([\d.]+) ms avg latency',
    re.M,
)
rows = []
for path in sorted(glob.glob(pdir + '/part_*.log')):
    text = open(path, errors='ignore').read()
    matches = pattern.findall(text)
    if not matches:
        raise SystemExit('missing producer summary in ' + path)
    rows.append(tuple(float(x) for x in matches[-1]))
records = int(sum(row[0] for row in rows))
if records != expected:
    raise SystemExit(f'producer sent {records}, expected {expected}')
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
    fi
    log_message "consumer benchmark: ${KAFKA_RECORDS} records, fetch-size=${KAFKA_CONSUMER_FETCH_SIZE:-1048576}, threads=${threads}"
    if ! kafka_exec "${KAFKA_HOME}/bin/kafka-consumer-perf-test.sh" \
        --broker-list "127.0.0.1:${KAFKA_PORT}" --topic test_topic_kafka \
        --fetch-size "${KAFKA_CONSUMER_FETCH_SIZE:-1048576}" \
        --threads "${threads}" \
        --messages "${KAFKA_RECORDS}" 2>&1 | tee "${consumer_log}"; then
        log_message 'ERROR: official Kafka consumer benchmark failed'
        return 50
    fi
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
        --threads "${threads}" \
        --record-size "${KAFKA_RECORD_SIZE}" \
        --partitions "${KAFKA_PARTITIONS}" \
        --producer-processes "${procs}" || {
        log_message 'ERROR: Kafka benchmark metrics are missing or invalid'
        return 50
    }
}
