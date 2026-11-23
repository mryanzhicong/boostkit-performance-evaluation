#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_private_configs() {
    mkdir -p "${PERF_WORK_DIR}/conf" "${PERF_WORK_DIR}/data/zookeeper" "${PERF_WORK_DIR}/data/kafka" "${PERF_WORK_DIR}/logs"
    cat > "${PERF_WORK_DIR}/conf/zookeeper.properties" <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=${PERF_WORK_DIR}/data/zookeeper
clientPort=${ZOOKEEPER_PORT}
clientPortAddress=127.0.0.1
admin.enableServer=false
EOF
    cat > "${PERF_WORK_DIR}/conf/server.properties" <<EOF
broker.id=0
listeners=PLAINTEXT://127.0.0.1:${KAFKA_PORT}
advertised.listeners=PLAINTEXT://127.0.0.1:${KAFKA_PORT}
log.dirs=${PERF_WORK_DIR}/data/kafka
zookeeper.connect=127.0.0.1:${ZOOKEEPER_PORT}
num.partitions=${KAFKA_PARTITIONS_PER_TOPIC}
default.replication.factor=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
group.initial.rebalance.delay.ms=0
auto.create.topics.enable=false
delete.topic.enable=true
num.io.threads=${KAFKA_NUM_IO_THREADS:-32}
num.network.threads=${KAFKA_NUM_NETWORK_THREADS:-32}
EOF
    cat > "${PERF_WORK_DIR}/conf/producer.properties" <<EOF
acks=all
linger.ms=500
batch.size=65536
max.request.size=1073741824
buffer.memory=134217728
retries=0
key.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
socket.send.buffer.bytes=524288
socket.receive.buffer.bytes=524288
EOF
}

wait_for_zookeeper() {
    local attempt
    for attempt in {1..60}; do
        if kafka_exec bash -c "echo ruok > /dev/tcp/127.0.0.1/${ZOOKEEPER_PORT}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
    done
    log_message 'ERROR: ZooKeeper did not become ready'
    return 40
}

wait_for_kafka() {
    local attempt
    for attempt in {1..90}; do
        if kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --list --bootstrap-server "127.0.0.1:${KAFKA_PORT}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    log_message 'ERROR: Kafka broker did not become ready'
    return 40
}

start_kafka_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${KAFKA_HOME}/bin/kafka-server-start.sh" && -x "${ZOOKEEPER_HOME}/bin/zkServer.sh" ]] || {
        log_message 'ERROR: official Kafka or ZooKeeper distribution is missing'; return 40;
    }
    if kafka_exec bash -c "echo > /dev/tcp/127.0.0.1/${ZOOKEEPER_PORT}" >/dev/null 2>&1 || \
       kafka_exec bash -c "echo > /dev/tcp/127.0.0.1/${KAFKA_PORT}" >/dev/null 2>&1; then
        log_message 'ERROR: task Kafka or ZooKeeper port is already in use'
        return 40
    fi
    write_private_configs || return 40
    log_message "starting private ZooKeeper 3.6.2 at 127.0.0.1:${ZOOKEEPER_PORT}"
    docker exec -e "ZOO_LOG_DIR=${PERF_WORK_DIR}/logs" "${KAFKA_CONTAINER_NAME}" \
        "${ZOOKEEPER_HOME}/bin/zkServer.sh" start "${PERF_WORK_DIR}/conf/zookeeper.properties" || return 40
    wait_for_zookeeper || return $?
    log_message "starting Kafka ${SOFTWARE_VERSION} at 127.0.0.1:${KAFKA_PORT}"
    docker exec -e "LOG_DIR=${PERF_WORK_DIR}/logs" \
        -e "KAFKA_HEAP_OPTS=${KAFKA_BROKER_HEAP_OPTS:--Xmx128G -Xms128G}" \
        "${KAFKA_CONTAINER_NAME}" \
        "${KAFKA_HOME}/bin/kafka-server-start.sh" -daemon "${PERF_WORK_DIR}/conf/server.properties" || return 40
    wait_for_kafka || return $?
    local topic i
    for (( i = 1; i <= KAFKA_TOPICS; i++ )); do
        topic="$(kafka_topic_name "${i}")"
        kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --delete \
            --bootstrap-server "127.0.0.1:${KAFKA_PORT}" --topic "${topic}" >/dev/null 2>&1 || true
    done
    sleep 2
    for (( i = 1; i <= KAFKA_TOPICS; i++ )); do
        topic="$(kafka_topic_name "${i}")"
        kafka_exec "${KAFKA_HOME}/bin/kafka-topics.sh" --create \
            --bootstrap-server "127.0.0.1:${KAFKA_PORT}" --replication-factor 1 \
            --partitions "${KAFKA_PARTITIONS_PER_TOPIC}" --topic "${topic}" || return 40
    done
    log_message "private Kafka topics are ready: ${KAFKA_TOPICS} topics × ${KAFKA_PARTITIONS_PER_TOPIC} partitions"
}
