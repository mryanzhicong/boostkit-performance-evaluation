#!/usr/bin/env bash
set -euo pipefail
SRC_DB="$1"
TGT_DB="$2"
ONLY_TABLE="${3:-}"
SPARK_SQL_BIN="spark-sql"
########################################
# 可调参数
########################################
PARALLELISM=1
MAX_RETRIES=0
RETRY_WAIT_SECONDS=10
DROP_TARGET_TABLE=true
########################################
# 工作目录
########################################
RUN_ID=$(date +%Y%m%d%H%M%S)
WORKDIR="./migrate_${SRC_DB}_to_${TGT_DB}_${RUN_ID}"
mkdir -p "${WORKDIR}"/{ddl,desc,cols,sql,logs,status,meta,report}
SUMMARY_FILE="${WORKDIR}/report/summary.csv"
echo "table,status,retries,src_count,tgt_count,partition_rewritten,message" > "${SUMMARY_FILE}"
########################################
# 通用函数
########################################
run_sparksql() {
  "${SPARK_SQL_BIN}" \
    --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.iceberg=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.iceberg.type=hive \
    --conf spark.sql.catalog.iceberg.uri=thrift://server1:9083 \
    --master yarn \
    --deploy-mode client \
    --driver-cores 8 \
    --driver-memory 20G \
    --num-executors 2 \
    --executor-cores 8 \
    --executor-memory 23g \
    --conf spark.executor.extraJavaOptions='-XX:+UseG1GC -XX:ActiveProcessorCount=8' \
    --conf spark.task.cpus=1 \
    --conf spark.sql.orc.impl=native \
    --conf spark.sql.autoBroadcastJoinThreshold=100M \
    --conf spark.default.parallelism=800 \
    --conf spark.sql.shuffle.partitions=800 \
    --conf spark.sql.adaptive.enabled=true \
    --conf spark.sql.adaptive.join.enabled=true \
    --conf spark.sql.adaptive.skewedJoin.enabled=true \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.network.timeout=600 \
    --conf spark.sql.broadcastTimeout=600 \
    --conf spark.locality.wait=0 \
    --conf spark.sql.sources.parallelPartitionDiscovery.parallelism=60 \
    --conf spark.sql.parquet.datetimeRebaseModeInRead=LEGACY \
    --conf spark.sql.parquet.datetimeRebaseModeInWrite=LEGACY \
    --conf spark.sql.parquet.int96RebaseModeInRead=LEGACY \
    --conf spark.sql.parquet.int96RebaseModeInWrite=LEGACY \
    -S -e "$1"
}
run_sparksql_file() {
  "${SPARK_SQL_BIN}" \
    --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.iceberg=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.iceberg.type=hive \
    --conf spark.sql.catalog.iceberg.uri=thrift://server1:9083 \
    --master yarn \
    --deploy-mode client \
    --driver-cores 8 \
    --driver-memory 20G \
    --num-executors 2 \
    --executor-cores 8 \
    --executor-memory 23g \
    --conf spark.executor.extraJavaOptions='-XX:+UseG1GC -XX:ActiveProcessorCount=8' \
    --conf spark.task.cpus=1 \
    --conf spark.sql.orc.impl=native \
    --conf spark.sql.autoBroadcastJoinThreshold=100M \
    --conf spark.default.parallelism=800 \
    --conf spark.sql.shuffle.partitions=800 \
    --conf spark.sql.adaptive.enabled=true \
    --conf spark.sql.adaptive.join.enabled=true \
    --conf spark.sql.adaptive.skewedJoin.enabled=true \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.network.timeout=600 \
    --conf spark.sql.broadcastTimeout=600 \
    --conf spark.locality.wait=0 \
    --conf spark.sql.sources.parallelPartitionDiscovery.parallelism=60 \
    --conf spark.sql.parquet.datetimeRebaseModeInRead=LEGACY \
    --conf spark.sql.parquet.datetimeRebaseModeInWrite=LEGACY \
    --conf spark.sql.parquet.int96RebaseModeInRead=LEGACY \
    --conf spark.sql.parquet.int96RebaseModeInWrite=LEGACY \
    -S -f "$1"
}
log() {
  echo "[$(date '+%F %T')] $*"
}
wait_for_slot() {
  while true; do
    running_jobs=$(jobs -rp | wc -l | tr -d ' ')
    if [ "${running_jobs}" -lt "${PARALLELISM}" ]; then
      break
    fi
    sleep 2
  done
}
########################################
# 从 DESCRIBE 生成列定义
########################################
describe_to_cols_file() {
  local full_table="$1"
  local out_file="$2"
  run_sparksql "DESCRIBE ${full_table}" 2>/dev/null | awk '
    BEGIN { first=1 }
    /^[[:space:]]*$/ { next }
    /^#/ { exit }
    $1 == "col_name" { next }
    $1 == "NULL" { next }
    $1 == "Part" { next }
    $1 == "partition" { next }
    {
      col=$1
      typ=$2
      if (col == "" || typ == "") next
      gsub(/`/, "", col)
      if (seen[col] == 1) next
      seen[col] = 1
      if (first == 1) {
        printf "  %s %s", col, typ
        first=0
      } else {
        printf ",\n  %s %s", col, typ
      }
    }
    END { printf "\n" }
  ' > "${out_file}"
}
########################################
# 从 DESCRIBE 生成 SELECT 列清单
########################################
describe_to_select_cols_file() {
  local full_table="$1"
  local out_file="$2"
  run_sparksql "DESCRIBE ${full_table}" 2>/dev/null | awk '
    BEGIN { first=1 }
    /^[[:space:]]*$/ { next }
    /^#/ { exit }
    $1 == "col_name" { next }
    $1 == "NULL" { next }
    $1 == "Part" { next }
    $1 == "partition" { next }
    {
      col=$1
      if (col == "") next
      gsub(/`/, "", col)
      if (seen[col] == 1) next
      seen[col] = 1
      if (first == 1) {
        printf "%s", col
        first=0
      } else {
        printf ", %s", col
      }
    }
    END { printf "\n" }
  ' > "${out_file}"
}
########################################
# 从 SHOW CREATE TABLE 提取 Hive 原分区列
########################################
extract_partition_cols() {
  local ddl_file="$1"
  local out_file="$2"
  awk '
    BEGIN { capture=0; buf="" }
    {
      line=$0
      if (toupper(line) ~ /PARTITIONED BY/) {
        capture=1
      }
      if (capture == 1) {
        buf = buf " " line
        if (index(line, ")") > 0) {
          capture=0
        }
      }
    }
    END {
      gsub(/\n/, " ", buf)
      if (buf == "") {
        print ""
        exit
      }
      sub(/^.*[Pp][Aa][Rr][Tt][Ii][Tt][Ii][Oo][Nn][Ee][Dd][[:space:]]+[Bb][Yy][[:space:]]*\(/, "", buf)
      sub(/\).*/, "", buf)
      n=split(buf, arr, ",")
      out=""
      for (i=1; i<=n; i++) {
        x=arr[i]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", x)
        gsub(/`/, "", x)
        split(x, y, /[[:space:]]+/)
        col=y[1]
        if (col != "") {
          if (out != "") out = out ", "
          out = out col
        }
      }
      print out
    }
  ' "${ddl_file}" > "${out_file}"
}
########################################
# 从 DESCRIBE 生成列类型映射: col<TAB>type
########################################
describe_to_coltype_map_file() {
  local full_table="$1"
  local out_file="$2"
  run_sparksql "DESCRIBE ${full_table}" 2>/dev/null | awk '
    /^[[:space:]]*$/ { next }
    /^#/ { exit }
    $1 == "col_name" { next }
    $1 == "NULL" { next }
    $1 == "Part" { next }
    $1 == "partition" { next }
    {
      col=$1
      typ=$2
      if (col == "" || typ == "") next
      gsub(/`/, "", col)
      if (seen[col] == 1) next
      seen[col] = 1
      print col "\t" tolower(typ)
    }
  ' > "${out_file}"
}
########################################
# Hive 分区列 -> Iceberg 分区表达式
# 不做 bucket 改写，直接使用原分区列
########################################
build_iceberg_partition_exprs() {
  local part_cols_file="$1"
  local out_file="$2"
  awk '
    {
      line=$0
      n=split(line, arr, ",")
      out=""
      for (i=1; i<=n; i++) {
        col=arr[i]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", col)
        if (col == "") continue
        if (out != "") out = out ", "
        out = out col
      }
      print out
    }
  ' "${part_cols_file}" > "${out_file}"
}
########################################
# 输出分区日志
########################################
log_partition_details() {
  local part_cols_file="$1"
  local coltype_map_file="$2"
  local iceberg_part_file="$3"
  local log_file="$4"
  awk '
    BEGIN { FS="\t" }
    NR==FNR {
      coltype[$1]=$2
      next
    }
    {
      line=$0
      n=split(line, arr, ",")
      src_cols=""
      type_desc=""
      for (i=1; i<=n; i++) {
        col=arr[i]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", col)
        if (col == "") continue
        typ=tolower(coltype[col])
        if (src_cols != "") src_cols = src_cols ", "
        src_cols = src_cols col
        if (type_desc != "") type_desc = type_desc ", "
        type_desc = type_desc col "=" typ
      }
      print "source partition cols      : " (src_cols == "" ? "none" : src_cols)
      print "source partition col types : " (type_desc == "" ? "none" : type_desc)
      print "partition rewrite          : disabled"
    }
  ' "${coltype_map_file}" "${part_cols_file}" >> "${log_file}"
  if [ -s "${iceberg_part_file}" ]; then
    echo "final iceberg partition    : $(cat "${iceberg_part_file}")" >> "${log_file}"
  else
    echo "final iceberg partition    : none" >> "${log_file}"
  fi
}
########################################
# 单表处理
########################################
process_one_table() {
  local TBL="$1"
  local FULL_SRC_TABLE="spark_catalog.${SRC_DB}.${TBL}"
  local FULL_TGT_TABLE="iceberg.${TGT_DB}.${TBL}"
  local DDL_FILE="${WORKDIR}/ddl/${TBL}.ddl.sql"
  local DESC_FILE="${WORKDIR}/desc/${TBL}.describe.txt"
  local COLS_FILE="${WORKDIR}/cols/${TBL}.cols.sql"
  local SELECT_COLS_FILE="${WORKDIR}/cols/${TBL}.select_cols.sql"
  local PART_COLS_FILE="${WORKDIR}/cols/${TBL}.part_cols.sql"
  local COLTYPE_MAP_FILE="${WORKDIR}/cols/${TBL}.coltypes.tsv"
  local ICEBERG_PART_FILE="${WORKDIR}/cols/${TBL}.iceberg_part.sql"
  local SQL_FILE="${WORKDIR}/sql/${TBL}.sql"
  local LOG_FILE="${WORKDIR}/logs/${TBL}.log"
  local STATUS_FILE="${WORKDIR}/status/${TBL}.status.csv"
  local final_status="FAILED"
  local final_src_count=""
  local final_tgt_count=""
  local final_partition_rewritten="NO"
  local final_message="unknown"
  local final_retries=0
  local attempt=1
  while [ "${attempt}" -le $((MAX_RETRIES + 1)) ]; do
    local retries=$((attempt - 1))
    local status="SUCCESS"
    local src_count=""
    local tgt_count=""
    local message=""
    local partition_rewritten="NO"
    local pc=""
    echo "[$(date '+%F %T')] table=${TBL}, attempt=${attempt}/$((MAX_RETRIES + 1))" > "${LOG_FILE}"
    echo "[$(date '+%F %T')] source table: ${FULL_SRC_TABLE}" >> "${LOG_FILE}"
    echo "[$(date '+%F %T')] target table: ${FULL_TGT_TABLE}" >> "${LOG_FILE}"
    if ! run_sparksql "DESCRIBE ${FULL_SRC_TABLE}" > "${DESC_FILE}" 2>> "${LOG_FILE}"; then
      status="FAILED"
      message="describe source table failed"
    fi
    if [ "${status}" = "SUCCESS" ]; then
      if ! run_sparksql "SHOW CREATE TABLE ${FULL_SRC_TABLE}" > "${DDL_FILE}" 2>> "${LOG_FILE}"; then
        status="FAILED"
        message="show create table failed"
      fi
    fi
    if [ "${status}" = "SUCCESS" ]; then
      describe_to_cols_file "${FULL_SRC_TABLE}" "${COLS_FILE}"
      if [ ! -s "${COLS_FILE}" ]; then
        status="FAILED"
        message="build cols file failed"
      fi
    fi
    if [ "${status}" = "SUCCESS" ]; then
      describe_to_select_cols_file "${FULL_SRC_TABLE}" "${SELECT_COLS_FILE}"
      if [ ! -s "${SELECT_COLS_FILE}" ]; then
        status="FAILED"
        message="build select cols file failed"
      fi
    fi
    if [ "${status}" = "SUCCESS" ]; then
      extract_partition_cols "${DDL_FILE}" "${PART_COLS_FILE}"
      describe_to_coltype_map_file "${FULL_SRC_TABLE}" "${COLTYPE_MAP_FILE}"
      build_iceberg_partition_exprs "${PART_COLS_FILE}" "${ICEBERG_PART_FILE}"
      echo "[$(date '+%F %T')] partition analysis begin" >> "${LOG_FILE}"
      log_partition_details "${PART_COLS_FILE}" "${COLTYPE_MAP_FILE}" "${ICEBERG_PART_FILE}" "${LOG_FILE}"
      echo "[$(date '+%F %T')] partition analysis end" >> "${LOG_FILE}"
      partition_rewritten="NO"
    fi
    if [ "${status}" = "SUCCESS" ]; then
      if [ "${DROP_TARGET_TABLE}" = "true" ]; then
        echo "DROP TABLE IF EXISTS ${FULL_TGT_TABLE};" > "${SQL_FILE}"
      else
        : > "${SQL_FILE}"
      fi
      echo "CREATE TABLE ${FULL_TGT_TABLE} (" >> "${SQL_FILE}"
      cat "${COLS_FILE}" >> "${SQL_FILE}"
      echo ")" >> "${SQL_FILE}"
      echo "USING iceberg" >> "${SQL_FILE}"
      if [ -s "${ICEBERG_PART_FILE}" ]; then
        pc=$(cat "${ICEBERG_PART_FILE}")
        if [ -n "${pc}" ]; then
          printf 'PARTITIONED BY (%s)\n' "${pc}" >> "${SQL_FILE}"
        fi
      fi
      echo "TBLPROPERTIES ('write.format.default'='orc');" >> "${SQL_FILE}"
      echo "" >> "${SQL_FILE}"
      echo "INSERT INTO ${FULL_TGT_TABLE}" >> "${SQL_FILE}"
      printf 'SELECT %s\n' "$(cat "${SELECT_COLS_FILE}")" >> "${SQL_FILE}"
      echo "FROM ${FULL_SRC_TABLE};" >> "${SQL_FILE}"
      echo "[$(date '+%F %T')] generated migrate sql file: ${SQL_FILE}" >> "${LOG_FILE}"
      echo "[$(date '+%F %T')] generated create/insert sql begin" >> "${LOG_FILE}"
      cat "${SQL_FILE}" >> "${LOG_FILE}"
      echo "[$(date '+%F %T')] generated create/insert sql end" >> "${LOG_FILE}"
    fi
    if [ "${status}" = "SUCCESS" ]; then
      echo "[$(date '+%F %T')] execute migrate sql begin" >> "${LOG_FILE}"
      if ! run_sparksql_file "${SQL_FILE}" >> "${LOG_FILE}" 2>&1; then
        status="FAILED"
        message="execute migrate sql failed"
      else
        echo "[$(date '+%F %T')] execute migrate sql success" >> "${LOG_FILE}"
      fi
    fi
    if [ "${status}" = "SUCCESS" ]; then
      src_count=$(run_sparksql "SELECT COUNT(*) FROM ${FULL_SRC_TABLE}" 2>> "${LOG_FILE}" | tail -1 | tr -d '[:space:]' || true)
      tgt_count=$(run_sparksql "SELECT COUNT(*) FROM ${FULL_TGT_TABLE}" 2>> "${LOG_FILE}" | tail -1 | tr -d '[:space:]' || true)
      echo "[$(date '+%F %T')] src_count=${src_count}" >> "${LOG_FILE}"
      echo "[$(date '+%F %T')] tgt_count=${tgt_count}" >> "${LOG_FILE}"
      if [ -z "${src_count}" ] || [ -z "${tgt_count}" ]; then
        status="FAILED"
        message="count verify failed"
      elif [ "${src_count}" != "${tgt_count}" ]; then
        status="FAILED"
        message="count mismatch: src=${src_count}; tgt=${tgt_count}"
      else
        message="ok"
      fi
    fi
    final_status="${status}"
    final_src_count="${src_count}"
    final_tgt_count="${tgt_count}"
    final_partition_rewritten="${partition_rewritten}"
    final_message="${message}"
    final_retries="${retries}"
    if [ "${status}" = "SUCCESS" ]; then
      break
    fi
    if [ "${attempt}" -le "${MAX_RETRIES}" ]; then
      echo "[$(date '+%F %T')] retry after ${RETRY_WAIT_SECONDS}s, reason=${message}" >> "${LOG_FILE}"
      sleep "${RETRY_WAIT_SECONDS}"
    fi
    attempt=$((attempt + 1))
  done
  echo "${TBL},${final_status},${final_retries},${final_src_count},${final_tgt_count},${final_partition_rewritten},${final_message}" > "${STATUS_FILE}"
}
########################################
# 创建目标库
########################################
log "create target db iceberg.${TGT_DB}"
run_sparksql "CREATE DATABASE IF NOT EXISTS iceberg.${TGT_DB}" > "${WORKDIR}/logs/create_db.log" 2>&1
########################################
# 列出源表 / 指定单表
########################################
if [ -n "${ONLY_TABLE}" ]; then
  log "single table mode: ${ONLY_TABLE}"
  printf '%s\n' "${ONLY_TABLE}" > "${WORKDIR}/meta/tables.list"
else
  log "list tables from spark_catalog.${SRC_DB}"
  run_sparksql "SHOW TABLES IN spark_catalog.${SRC_DB}" \
    | awk 'NF >= 1 && $1 != "tableName" {print $1}' \
    > "${WORKDIR}/meta/tables.list"
fi
TABLE_COUNT=$(wc -l < "${WORKDIR}/meta/tables.list" | tr -d ' ')
log "Tables to process: ${TABLE_COUNT}"
log "Parallelism      : ${PARALLELISM}"
log "Max retries      : ${MAX_RETRIES}"
log "String-like partition bucket rewrite: disabled"
if [ "${TABLE_COUNT}" -eq 0 ]; then
  log "No tables found, exit."
  exit 0
fi
########################################
# 并发处理
########################################
while read -r TBL; do
  [ -z "${TBL}" ] && continue
  wait_for_slot
  process_one_table "${TBL}" &
done < "${WORKDIR}/meta/tables.list"
wait
########################################
# 汇总结果
########################################
for f in "${WORKDIR}"/status/*.status.csv; do
  if [ -f "${f}" ]; then
    cat "${f}" >> "${SUMMARY_FILE}"
  fi
done
SUCCESS_CNT=$(awk -F',' 'NR>1 && $2=="SUCCESS" {c++} END{print c+0}' "${SUMMARY_FILE}")
FAIL_CNT=$(awk -F',' 'NR>1 && $2!="SUCCESS" {c++} END{print c+0}' "${SUMMARY_FILE}")
REWRITE_CNT=$(awk -F',' 'NR>1 && $6=="YES" {c++} END{print c+0}' "${SUMMARY_FILE}")
log "========================================"
log "finished"
log "success tables        : ${SUCCESS_CNT}"
log "failed  tables        : ${FAIL_CNT}"
log "rewritten partitions  : ${REWRITE_CNT}"
log "summary file          : ${SUMMARY_FILE}"
log "workdir               : ${WORKDIR}"
log "========================================"
awk -F',' 'NR>1 && $2!="SUCCESS" {print $1","$7}' "${SUMMARY_FILE}" > "${WORKDIR}/report/failed_tables.csv" || true
awk -F',' 'NR>1 && $6=="YES" {print $1","$6","$7}' "${SUMMARY_FILE}" > "${WORKDIR}/report/rewritten_partition_tables.csv" || true
log "failed list           : ${WORKDIR}/report/failed_tables.csv"
log "rewritten list        : ${WORKDIR}/report/rewritten_partition_tables.csv"
