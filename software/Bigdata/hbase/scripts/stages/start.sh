#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

write_private_configs() {
    mkdir -p "${HBASE_CONF_DIR}" "${HBASE_DATA}/hdfs/name" "${HBASE_DATA}/hdfs/data" \
        "${HBASE_DATA}/wal" "${HBASE_DATA}/zk" "${HBASE_LOG_DIR}" "${PERF_WORK_DIR}/pids"
    cat > "${HBASE_CONF_DIR}/core-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>fs.defaultFS</name><value>hdfs://127.0.0.1:${HDFS_NN_PORT}</value></property>
  <property><name>hadoop.tmp.dir</name><value>${PERF_WORK_DIR}/data/hadoop-tmp</value></property>
</configuration>
EOF
    cat > "${HBASE_CONF_DIR}/hdfs-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>dfs.replication</name><value>1</value></property>
  <property><name>dfs.namenode.name.dir</name><value>file://${HBASE_DATA}/hdfs/name</value></property>
  <property><name>dfs.datanode.data.dir</name><value>file://${HBASE_DATA}/hdfs/data</value></property>
  <property><name>dfs.namenode.rpc-address</name><value>127.0.0.1:${HDFS_NN_PORT}</value></property>
  <property><name>dfs.namenode.http-address</name><value>127.0.0.1:${HDFS_NN_HTTP_PORT}</value></property>
  <property><name>dfs.datanode.address</name><value>127.0.0.1:${HDFS_DN_PORT}</value></property>
  <property><name>dfs.datanode.http.address</name><value>127.0.0.1:${HDFS_DN_HTTP_PORT}</value></property>
  <property><name>dfs.datanode.ipc.address</name><value>127.0.0.1:$((HDFS_DN_HTTP_PORT + 1))</value></property>
</configuration>
EOF
    cat > "${HBASE_CONF_DIR}/hbase-env.sh" <<EOF
export JAVA_HOME=${JDK_HOME}
export HBASE_MANAGES_ZK=false
export HBASE_LOG_DIR=${HBASE_LOG_DIR}
export HBASE_PID_DIR=${PERF_WORK_DIR}/pids
export HBASE_OPTS="-XX:+UseG1GC -XX:+ExplicitGCInvokesConcurrent"
export HBASE_MASTER_OPTS="-Xmx${HBASE_MASTER_HEAP} -Xms${HBASE_MASTER_HEAP} -XX:ActiveProcessorCount=8"
export HBASE_REGIONSERVER_OPTS="-Xmx${HBASE_RS_HEAP} -Xms${HBASE_RS_HEAP} -XX:ActiveProcessorCount=8 -XX:MaxDirectMemorySize=${HBASE_DIRECT_MEMORY}"
EOF
    cat > "${HBASE_CONF_DIR}/hbase-site.xml" <<EOF
<?xml version="1.0"?>
<configuration>
  <property><name>hbase.rootdir</name><value>hdfs://127.0.0.1:${HDFS_NN_PORT}/HBase</value></property>
  <property><name>hbase.cluster.distributed</name><value>true</value></property>
  <property><name>hbase.wal.dir</name><value>file://${HBASE_DATA}/wal</value></property>
  <property><name>hbase.unsafe.stream.capability.enforce</name><value>false</value></property>
  <property><name>hbase.zookeeper.quorum</name><value>127.0.0.1</value></property>
  <property><name>hbase.zookeeper.property.clientPort</name><value>${ZK_CLIENT_PORT}</value></property>
  <property><name>hbase.zookeeper.property.dataDir</name><value>${HBASE_DATA}/zk</value></property>
  <property><name>zookeeper.session.timeout</name><value>90000</value></property>
  <property><name>zookeeper.znode.parent</name><value>/hbase</value></property>
  <property><name>hbase.master.port</name><value>${HBASE_MASTER_PORT}</value></property>
  <property><name>hbase.master.info.port</name><value>${HBASE_MASTER_INFO_PORT}</value></property>
  <property><name>hbase.regionserver.port</name><value>${HBASE_RS_PORT}</value></property>
  <property><name>hbase.regionserver.info.port</name><value>${HBASE_RS_INFO_PORT}</value></property>
  <property><name>hbase.regionserver.handler.count</name><value>120</value></property>
  <property><name>hbase.regionserver.metahandler.count</name><value>150</value></property>
  <property><name>hbase.hstore.flusher.count</name><value>40</value></property>
  <property><name>hbase.regionserver.thread.compaction.small</name><value>5</value></property>
  <property><name>hbase.hregion.memstore.block.multiplier</name><value>8</value></property>
  <property><name>hbase.hregion.memstore.flush.size</name><value>134217728</value></property>
  <property><name>hbase.hstore.compactionThreshold</name><value>25</value></property>
  <property><name>hbase.hstore.compaction.max</name><value>10</value></property>
  <property><name>hbase.hstore.blockingStoreFiles</name><value>10000</value></property>
  <property><name>hbase.hregion.max.filesize</name><value>10737418240</value></property>
  <property><name>hbase.wal.regiongrouping.numgroups</name><value>60</value></property>
  <property><name>hbase.hlog.asyncer.number</name><value>50</value></property>
  <property><name>hbase.client.scanner.timeout.period</name><value>60000</value></property>
  <property><name>hbase.client.write.buffer</name><value>5242880</value></property>
  <property><name>hbase.bulkload.staging.dir</name><value>/apps/hbase/staging</value></property>
  <property><name>hbase.bucketcache.ioengine</name><value>offheap</value></property>
  <property><name>hbase.bucketcache.size</name><value>${HBASE_BUCKET_CACHE_MB}</value></property>
  <property><name>hbase.regionserver.global.memstore.size</name><value>0.4</value></property>
  <property><name>hbase.ipc.server.max.callqueue.size</name><value>1073741824</value></property>
</configuration>
EOF
    cp -f "${HADOOP_HOME}/etc/hadoop/log4j.properties" "${HBASE_CONF_DIR}/log4j.properties" 2>/dev/null || true
    cat > "${HBASE_CONF_DIR}/zoo.cfg" <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=${HBASE_DATA}/zk
clientPort=${ZK_CLIENT_PORT}
clientPortAddress=127.0.0.1
admin.enableServer=false
maxClientCnxns=0
4lw.commands.whitelist=mntr,ruok,stat,srvr
EOF
}

format_hdfs() {
    if [[ -d "${HBASE_DATA}/hdfs/name/current" ]]; then
        log_message 'HDFS NameNode is already formatted'
        return 0
    fi
    hbase_exec "${HADOOP_HOME}/bin/hdfs" namenode -format -force -nonInteractive >/dev/null 2>&1 || {
        log_error 'HDFS namenode format failed'; return 40;
    }
}

wait_for_hdfs() {
    local attempt
    for attempt in {1..60}; do
        if hbase_exec "${HADOOP_HOME}/bin/hdfs" dfsadmin -report >/dev/null 2>&1; then
            hbase_exec "${HADOOP_HOME}/bin/hdfs" dfsadmin -report > "${HBASE_RESULT_DIR}/hdfs_report.txt" 2>&1 || true
            return 0
        fi
        sleep 2
    done
    log_error 'HDFS did not become ready'
    return 40
}

wait_for_hbase() {
    local attempt output
    for attempt in {1..90}; do
        output="$(hbase_exec bash -c "echo status | ${HBASE_HOME}/bin/hbase shell -n" 2>/dev/null)" || true
        if grep -q 'active master' <<< "${output}" && grep -q 'servers, 0 dead' <<< "${output}"; then
            printf '%s\n' "${output}" > "${HBASE_RESULT_DIR}/hbase_status.txt"
            return 0
        fi
        sleep 2
    done
    log_error 'HBase did not become ready'
    return 40
}

start_hbase_runtime() {
    initialize_runtime || return $?
    check_container || return $?
    [[ -x "${HBASE_HOME}/bin/hbase" && -x "${HADOOP_HOME}/bin/hdfs" ]] || {
        log_error 'HBase or Hadoop distribution is missing'; return 40;
    }
    write_private_configs || return 40
    format_hdfs || return $?

    log_message "starting ZooKeeper at 127.0.0.1:${ZK_CLIENT_PORT}"
    hbase_exec "${ZK_HOME}/bin/zkServer.sh" --config "${HBASE_CONF_DIR}" start || return 40
    log_message 'starting HDFS NameNode and DataNode'
    hbase_exec "${HADOOP_HOME}/bin/hdfs" --daemon start namenode || return 40
    hbase_exec "${HADOOP_HOME}/bin/hdfs" --daemon start datanode || return 40
    wait_for_hdfs || return $?

    log_message 'starting HBase master and region server'
    hbase_exec "${HBASE_HOME}/bin/hbase-daemon.sh" start master || return 40
    hbase_exec "${HBASE_HOME}/bin/hbase-daemon.sh" start regionserver || return 40
    wait_for_hbase || return $?

    hbase_exec "${HBASE_HOME}/bin/hbase" version > "${HBASE_RESULT_DIR}/hbase_version.txt" 2>&1 || true
    log_message 'HBase is ready'
}
