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
    kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --describe \
        --bootstrap-server "127.0.0.1:${KAFKA_PORT}" --topic test_topic_kafka >/dev/null || return 50
    log_message "producer benchmark: ${KAFKA_RECORDS} records × ${KAFKA_RECORD_SIZE} bytes"
    if ! kafka_exec "${KAFKA_HOME}/bin/kafka-producer-perf-test.sh" \
        --topic test_topic_kafka --num-records "${KAFKA_RECORDS}" \
        --record-size "${KAFKA_RECORD_SIZE}" --throughput -1 \
        --producer-props "bootstrap.servers=127.0.0.1:${KAFKA_PORT}" \
        --producer.config "${PERF_WORK_DIR}/conf/producer.properties" 2>&1 | tee "${producer_log}"; then
        log_message 'ERROR: official Kafka producer benchmark failed'
        return 50
    fi
    log_message "consumer benchmark: ${KAFKA_RECORDS} records"
    if ! kafka_exec "${KAFKA_HOME}/bin/kafka-consumer-perf-test.sh" \
        --broker-list "127.0.0.1:${KAFKA_PORT}" --topic test_topic_kafka \
        --fetch-size 1024 --messages "${KAFKA_RECORDS}" 2>&1 | tee "${consumer_log}"; then
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
        --output "${RESULTS_DIR}/benchmark_kafka.json" --expected-records "${KAFKA_RECORDS}" || {
        log_message 'ERROR: Kafka benchmark metrics are missing or invalid'
        return 50
    }
}
