#!/usr/bin/env bash
set -uo pipefail
if [ -z "${BASH_VERSION:-}" ]; then
  echo "ERROR: please run this script with bash, not sh"
  exit 1
fi
usage() {
  cat <<'EOF'
Usage:
  bash hivespark2hudi.sh source_db target_db [table_name] [options]
Examples:
  bash hivespark2hudi.sh src_db tgt_db
  bash hivespark2hudi.sh src_db tgt_db table1
  bash hivespark2hudi.sh src_db tgt_db --debug-table table1
  bash hivespark2hudi.sh src_db tgt_db table1 --partition-mode safe
  bash hivespark2hudi.sh src_db tgt_db table1 --no-partition
Options:
  --debug-table, -d          only migrate one table
  --dry-run                  only print sql, do not execute
  --overwrite                drop target table before create
  --no-drop                  do not drop target table
  --parallelism N            parallel table migration count
  --max-retries N            max retries for each table
  --retry-wait-seconds N     retry wait seconds
  --primary-key COL          source pk column, default: first business column
  --precombine-field COL     source precombine column, default: same as primaryKey
  --type cow|mor             hudi table type, default: cow
  --no-partition             target hudi table without partition
  --partition-mode MODE      raw|safe, default: safe
  --map-null-default STR     replacement for null map key/value, default: __NULL__
EOF
}
########################################
# 基础函数
########################################
clean_value() {
  printf '%s' "${1:-}" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
trim() {
  printf '%s' "${1:-}" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}
normalize_dtype() {
  printf '%s' "${1:-}" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | sed 's/[[:space:]]//g'
}
qi() {
  printf '`%s`' "$1"
}
csv_escape() {
  local s="${1:-}"
  s="${s//\"/\"\"}"
  printf '"%s"' "${s}"
}
sql_literal() {
  printf "'%s'" "$(printf '%s' "${1:-}" | sed "s/'/''/g")"
}
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}
########################################
# 参数处理
########################################
if [ $# -lt 2 ]; then
  usage
  exit 1
fi
SRC_DB="$(clean_value "${1:-}")"
TGT_DB="$(clean_value "${2:-}")"
shift 2
export HUDI_JAR="${HUDI_JAR:-./hudi-spark3.5-bundle_2.12-0.15.0.jar}"
PARALLELISM="$(clean_value "${PARALLELISM:-10}")"
MAX_RETRIES="$(clean_value "${MAX_RETRIES:-1}")"
RETRY_WAIT_SECONDS="$(clean_value "${RETRY_WAIT_SECONDS:-10}")"
DROP_TARGET_TABLE="$(clean_value "${DROP_TARGET_TABLE:-true}")"
TABLE_TYPE="$(clean_value "${TABLE_TYPE:-cow}")"
PRIMARY_KEY="$(clean_value "${PRIMARY_KEY:-}")"
PRECOMBINE_FIELD="$(clean_value "${PRECOMBINE_FIELD:-}")"
PARTITION_MODE="$(clean_value "${PARTITION_MODE:-safe}")"
MAP_NULL_DEFAULT="$(clean_value "${MAP_NULL_DEFAULT:-__NULL__}")"
ONLY_TABLE=""
DRY_RUN=0
NO_PARTITION=0
AUTO_SAFE_KEY=1
NONPK_FALLBACK=1
while [ $# -gt 0 ]; do
  case "$1" in
    --debug-table|-d)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      ONLY_TABLE="$(clean_value "${2:-}")"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --overwrite)
      DROP_TARGET_TABLE="true"
      shift
      ;;
    --no-drop)
      DROP_TARGET_TABLE="false"
      shift
      ;;
    --parallelism)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      PARALLELISM="$(clean_value "${2:-}")"
      shift 2
      ;;
    --max-retries)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      MAX_RETRIES="$(clean_value "${2:-}")"
      shift 2
      ;;
    --retry-wait-seconds)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      RETRY_WAIT_SECONDS="$(clean_value "${2:-}")"
      shift 2
      ;;
    --primary-key)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      PRIMARY_KEY="$(clean_value "${2:-}")"
      shift 2
      ;;
    --precombine-field)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      PRECOMBINE_FIELD="$(clean_value "${2:-}")"
      shift 2
      ;;
    --type)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      TABLE_TYPE="$(clean_value "${2:-}")"
      shift 2
      ;;
    --partition-mode)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      PARTITION_MODE="$(clean_value "${2:-}")"
      shift 2
      ;;
    --map-null-default)
      [ $# -ge 2 ] || { echo "ERROR: $1 requires value"; exit 1; }
      MAP_NULL_DEFAULT="$(clean_value "${2:-}")"
      shift 2
      ;;
    --no-partition)
      NO_PARTITION=1
      shift
      ;;
    --auto-safe-key)
      AUTO_SAFE_KEY=1
      shift
      ;;
    --nonpk-fallback)
      NONPK_FALLBACK=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -z "${ONLY_TABLE}" ]; then
        ONLY_TABLE="$(clean_value "$1")"
        shift
      else
        echo "Unknown argument: $1"
        usage
        exit 1
      fi
      ;;
  esac
done
case "${TABLE_TYPE}" in
  cow|mor) ;;
  *)
    echo "ERROR: --type only supports cow or mor: ${TABLE_TYPE}"
    exit 1
    ;;
esac
case "${DROP_TARGET_TABLE}" in
  true|false) ;;
  *)
    echo "ERROR: DROP_TARGET_TABLE only supports true or false: ${DROP_TARGET_TABLE}"
    exit 1
    ;;
esac
case "${PARTITION_MODE}" in
  raw|safe) ;;
  *)
    echo "ERROR: --partition-mode only supports raw|safe: ${PARTITION_MODE}"
    exit 1
    ;;
esac
if ! echo "${PARALLELISM}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR: PARALLELISM must be integer"
  exit 1
fi
if ! echo "${MAX_RETRIES}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR: MAX_RETRIES must be integer"
  exit 1
fi
if ! echo "${RETRY_WAIT_SECONDS}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR: RETRY_WAIT_SECONDS must be integer"
  exit 1
fi
if [ "${PARALLELISM}" -lt 1 ]; then
  echo "ERROR: PARALLELISM must be >= 1"
  exit 1
fi
if [ ! -f "${HUDI_JAR}" ]; then
  echo "ERROR: HUDI_JAR not found: ${HUDI_JAR}"
  exit 1
fi
########################################
# 工作目录
########################################
RUN_ID="$(date +%Y%m%d%H%M%S)"
WORKDIR="./migrate_${SRC_DB}_to_${TGT_DB}_${RUN_ID}"
mkdir -p "${WORKDIR}"/{ddl,desc,cols,sql,logs,status,meta,report}
SUMMARY_FILE="${WORKDIR}/report/summary.csv"
echo "table,status,retries,src_count,tgt_count,decimal_rewritten,primary_key,precombine_field,message" > "${SUMMARY_FILE}"
MAP_NULL_DEFAULT_SQL="$(sql_literal "${MAP_NULL_DEFAULT}")"
########################################
# Spark SQL 命令
########################################
SPARK_SQL_CMD=(
  spark-sql
  --master yarn
  --deploy-mode client
  --driver-cores 8
  --driver-memory 20G
  --num-executors 2
  --executor-cores 8
  --executor-memory 32g
  --conf "spark.executor.extraJavaOptions=-XX:+UseG1GC -XX:ActiveProcessorCount=8"
  --conf "spark.task.cpus=1"
  --conf "spark.sql.orc.impl=native"
  --conf "spark.sql.autoBroadcastJoinThreshold=100M"
  --conf "spark.default.parallelism=100"
  --conf "spark.sql.shuffle.partitions=100"
  --conf "spark.sql.adaptive.enabled=true"
  --conf "spark.sql.adaptive.join.enabled=true"
  --conf "spark.sql.adaptive.skewedJoin.enabled=true"
  --conf "spark.serializer=org.apache.spark.serializer.KryoSerializer"
  --conf "spark.network.timeout=600"
  --conf "spark.sql.broadcastTimeout=600"
  --conf "spark.locality.wait=0"
  --conf "spark.sql.sources.parallelPartitionDiscovery.parallelism=60"
  --jars "${HUDI_JAR}"
  --conf "spark.sql.extensions=org.apache.spark.sql.hudi.HoodieSparkSessionExtension"
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.hudi.catalog.HoodieCatalog"
  --conf "spark.hadoop.hoodie.metadata.enable=false"
  --conf "hoodie.datasource.write.partitionpath.urlencode=true"
  --conf "hoodie.datasource.write.hive_style_partitioning=true"
  --conf "spark.sql.hive.convertMetastoreOrc=false"
  --conf "spark.sql.hive.convertMetastoreParquet=false"
  --conf "spark.sql.parquet.datetimeRebaseModeInRead=LEGACY"
  --conf "spark.sql.parquet.datetimeRebaseModeInWrite=LEGACY"
  --conf "spark.sql.parquet.int96RebaseModeInRead=LEGACY"
  --conf "spark.sql.parquet.int96RebaseModeInWrite=LEGACY"
)
run_sparksql() {
  local sql="$1"
  "${SPARK_SQL_CMD[@]}" -S -e "${sql}"
}
run_sparksql_file() {
  local sql_file="$1"
  "${SPARK_SQL_CMD[@]}" -S -f "${sql_file}"
}
wait_for_slot() {
  while true; do
    local running=""
    running="$(jobs -rp | wc -l | tr -d ' ')"
    if [ "${running}" -lt "${PARALLELISM}" ]; then
      break
    fi
    sleep 1
  done
}
get_count() {
  local db="$1"
  local tbl="$2"
  local result=""
  local rc=0
  result="$(run_sparksql "SELECT COUNT(*) FROM $(qi "${db}").$(qi "${tbl}");" 2>/dev/null)"
  rc=$?
  if [ ${rc} -ne 0 ]; then
    echo ""
    return 0
  fi
  echo "${result}" | grep -Eo '[0-9]+' | tail -1 | tr -d ' '
}
########################################
# 元数据
########################################
list_source_tables() {
  local out_file="$1"
  run_sparksql "SHOW TABLES IN $(qi "${SRC_DB}");" \
    > "${WORKDIR}/meta/show_tables.raw" \
    2> "${WORKDIR}/logs/show_tables.err"
  local rc=$?
  if [ ${rc} -ne 0 ]; then
    log "ERROR: show tables failed, see ${WORKDIR}/logs/show_tables.err"
    return 1
  fi
  awk '
    BEGIN { IGNORECASE = 1 }
    /tableName/ { next }
    /namespace/ { next }
    /database/  { next }
    NF >= 3 {
      if ($3 != "true") print $2
      next
    }
    NF == 2 {
      if ($2 != "true") print $1
      next
    }
    NF == 1 {
      print $1
      next
    }
  ' "${WORKDIR}/meta/show_tables.raw" \
    | sed '/^$/d' \
    | grep -E '^[A-Za-z_][A-Za-z0-9_]*$' \
    | sort -u \
    > "${out_file}" || true
  return 0
}
get_source_format() {
  local tbl="$1"
  local desc_file="${WORKDIR}/desc/${tbl}.formatted.desc"
  local err_file="${WORKDIR}/logs/${tbl}.formatted.err"
  if [ ! -f "${desc_file}" ]; then
    run_sparksql "DESCRIBE FORMATTED $(qi "${SRC_DB}").$(qi "${tbl}");" > "${desc_file}" 2> "${err_file}"
    local rc=$?
    if [ ${rc} -ne 0 ]; then
      echo ""
      return 1
    fi
  fi
  if grep -Eiq 'orcinputformat|[^a-z]orc[^a-z]|serialization library.*orc|provider.*orc|inputformat.*orc|outputformat.*orc|hoodie.table.base.file.format.*orc' "${desc_file}"; then
    echo "ORC"
    return 0
  fi
  if grep -Eiq 'parquetinputformat|[^a-z]parquet[^a-z]|serialization library.*parquet|provider.*parquet|inputformat.*parquet|outputformat.*parquet|hoodie.table.base.file.format.*parquet' "${desc_file}"; then
    echo "PARQUET"
    return 0
  fi
  echo ""
  return 0
}
parse_table_columns() {
  local tbl="$1"
  local desc_file="$2"
  local cols_file="$3"
  local desc_err_file="${WORKDIR}/logs/${tbl}.describe.err"
  run_sparksql "DESCRIBE $(qi "${SRC_DB}").$(qi "${tbl}");" > "${desc_file}" 2> "${desc_err_file}"
  local rc=$?
  if [ ${rc} -ne 0 ]; then
    echo "ERROR: DESCRIBE failed for ${SRC_DB}.${tbl}, see ${desc_err_file}"
    return 1
  fi
  awk '
    BEGIN {
      in_partition = 0
      n = 0
    }
    {
      col = $1
      dtype = $2
      if (col == "") next
      if ($0 ~ /^[[:space:]]*# Partition Information/) {
        in_partition = 1
        next
      }
      if (col ~ /^#/) next
      if (col == "col_name") next
      if (dtype == "data_type") next
      if (dtype == "") next
      if (col ~ /^_hoodie_/) next
      if (col !~ /^[A-Za-z_][A-Za-z0-9_]*$/) next
      dtype_l = tolower(dtype)
      if (dtype_l !~ /^(tinyint|smallint|int|integer|bigint|float|double|boolean|string|binary|date|timestamp|timestamp_ntz|decimal|varchar|char|array|map|struct)/) next
      if (!(col in seen)) {
        n++
        order[n] = col
        typ[col] = dtype
        seen[col] = 1
      }
      if (in_partition == 1) {
        part[col] = 1
      }
    }
    END {
      for (i = 1; i <= n; i++) {
        c = order[i]
        p = (c in part) ? 1 : 0
        print c "\t" typ[c] "\t" p
      }
    }
  ' "${desc_file}" > "${cols_file}"
  if [ ! -s "${cols_file}" ]; then
    echo "ERROR: no business columns parsed for ${SRC_DB}.${tbl}"
    return 1
  fi
  return 0
}
column_exists_in_cols_file() {
  local cols_file="$1"
  local col_name="$2"
  awk -F'\t' -v c="${col_name}" '$1==c {found=1} END{exit(found?0:1)}' "${cols_file}"
}
get_col_dtype_from_cols_file() {
  local cols_file="$1"
  local col_name="$2"
  awk -F'\t' -v c="${col_name}" '$1==c {print $2; exit}' "${cols_file}"
}
is_safe_hudi_key_dtype() {
  local dtype="$1"
  local d=""
  d="$(normalize_dtype "${dtype}")"
  # 明确允许的标量类型
  case "${d}" in
    tinyint|smallint|int|integer|bigint|float|double|boolean|date|timestamp|timestamp_ntz|string)
      return 0
      ;;
  esac
  # char(...)
  if [ "${d#char(}" != "${d}" ] && [ "${d%)}" != "${d}" ]; then
    return 0
  fi
  # varchar(...)
  if [ "${d#varchar(}" != "${d}" ] && [ "${d%)}" != "${d}" ]; then
    return 0
  fi
  # decimal(...)
  if [ "${d#decimal(}" != "${d}" ] && [ "${d%)}" != "${d}" ]; then
    return 0
  fi
  # 其它类型一律视为不安全：array/map/struct/binary 等
  return 1
}
find_first_non_null_key() {
  local tbl="$1"
  local cols_file="$2"
  local col=""
  local dtype=""
  local is_partition=""
  local sql=""
  local result=""
  local bad_cnt=""
  while IFS=$'\t' read -r col dtype is_partition; do
    col="$(trim "${col}")"
    dtype="$(trim "${dtype}")"
    [ -z "${col}" ] && continue
    [ -z "${dtype}" ] && continue
    # 只从可作为 Hudi key 的标量类型里挑选
    if ! is_safe_hudi_key_dtype "${dtype}"; then
      continue
    fi
    sql="
      SELECT COUNT(*)
      FROM $(qi "${SRC_DB}").$(qi "${tbl}")
      WHERE $(qi "${col}") IS NULL
         OR TRIM(CAST($(qi "${col}") AS STRING)) = ''
         OR LOWER(TRIM(CAST($(qi "${col}") AS STRING))) = 'null'
    "
    result="$(run_sparksql "${sql}" 2>/dev/null || true)"
    bad_cnt="$(printf '%s\n' "${result}" | grep -Eo '[0-9]+' | tail -1)"
    if [ -n "${bad_cnt}" ] && [ "${bad_cnt}" = "0" ]; then
      echo "${col}"
      return 0
    fi
  done < "${cols_file}"
  return 1
}
resolve_hudi_keys() {
  local tbl="$1"
  local cols_file="$2"
  local key_file="$3"
  local first_col=""
  local detected_safe_col=""
  local effective_pk=""
  local effective_precombine=""
  local pk_dtype=""
  local pre_dtype=""
  first_col="$(awk -F'\t' 'NR==1 {print $1; exit}' "${cols_file}")"
  if [ -z "${first_col}" ]; then
    echo "ERROR: cannot resolve first business column from ${cols_file}"
    return 1
  fi
  # 1. primaryKey
  if [ -n "${PRIMARY_KEY}" ]; then
    if ! column_exists_in_cols_file "${cols_file}" "${PRIMARY_KEY}"; then
      echo "ERROR: primaryKey column not found in source columns: ${PRIMARY_KEY}"
      return 1
    fi
    pk_dtype="$(get_col_dtype_from_cols_file "${cols_file}" "${PRIMARY_KEY}")"
    if ! is_safe_hudi_key_dtype "${pk_dtype}"; then
      echo "ERROR: explicit primaryKey uses unsupported complex/non-scalar type: ${PRIMARY_KEY} (${pk_dtype})"
      return 1
    fi
    effective_pk="${PRIMARY_KEY}"
  else
    if [ "${AUTO_SAFE_KEY}" -eq 1 ]; then
      detected_safe_col="$(find_first_non_null_key "${tbl}" "${cols_file}" || true)"
      if [ -n "${detected_safe_col}" ]; then
        effective_pk="${detected_safe_col}"
        log "INFO: auto-safe-key selected primaryKey=${effective_pk} for ${SRC_DB}.${tbl}"
      else
        if [ "${NONPK_FALLBACK}" -eq 1 ]; then
          effective_pk=""
          log "WARN: no non-null scalar key found, fallback to NON-PK table for ${SRC_DB}.${tbl}"
        else
          effective_pk="${first_col}"
          log "WARN: no non-null scalar key found, fallback to first column=${effective_pk} for ${SRC_DB}.${tbl}"
        fi
      fi
    else
      effective_pk="${first_col}"
    fi
  fi
  # 2. preCombineField
  if [ -n "${effective_pk}" ]; then
    if [ -n "${PRECOMBINE_FIELD}" ]; then
      if ! column_exists_in_cols_file "${cols_file}" "${PRECOMBINE_FIELD}"; then
        echo "ERROR: preCombineField column not found in source columns: ${PRECOMBINE_FIELD}"
        return 1
      fi
      pre_dtype="$(get_col_dtype_from_cols_file "${cols_file}" "${PRECOMBINE_FIELD}")"
      if ! is_safe_hudi_key_dtype "${pre_dtype}"; then
        echo "ERROR: explicit preCombineField uses unsupported complex/non-scalar type: ${PRECOMBINE_FIELD} (${pre_dtype})"
        return 1
      fi
      effective_precombine="${PRECOMBINE_FIELD}"
    else
      effective_precombine="${effective_pk}"
    fi
  else
    # NON-PK fallback 时，不再设置 preCombineField
    effective_precombine=""
  fi
  echo "${effective_pk}|${effective_precombine}" > "${key_file}"
  return 0
}
########################################
# decimal 改写函数 + 启动自检
########################################
get_orc_decimal_rewrite_dtype() {
  local dtype="$1"
  local d=""
  local inner=""
  local p=""
  local s=""
  d="$(printf '%s' "${dtype}" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  if [ "${d#decimal(}" = "${d}" ]; then
    printf '%s\n' "${dtype}"
    return 0
  fi
  if [ "${d%)}" = "${d}" ]; then
    printf '%s\n' "${dtype}"
    return 0
  fi
  inner="${d#decimal(}"
  inner="${inner%)}"
  case "${inner}" in
    *,*)
      p="${inner%%,*}"
      s="${inner##*,}"
      ;;
    *)
      p="${inner}"
      s="0"
      ;;
  esac
  case "${p}" in
    ''|*[!0-9]*)
      printf '%s\n' "${dtype}"
      return 0
      ;;
  esac
  case "${s}" in
    ''|*[!0-9]*)
      printf '%s\n' "${dtype}"
      return 0
      ;;
  esac
  if [ "${p}" -lt 10 ]; then
    printf 'decimal(10,%s)\n' "${s}"
  else
    printf '%s\n' "${d}"
  fi
}
self_test_decimal_rewrite() {
  local a="" b="" c="" d="" e=""
  a="$(get_orc_decimal_rewrite_dtype 'decimal(7,0)')"
  b="$(get_orc_decimal_rewrite_dtype 'decimal(7,2)')"
  c="$(get_orc_decimal_rewrite_dtype 'decimal(8,0)')"
  d="$(get_orc_decimal_rewrite_dtype 'decimal(8,2)')"
  e="$(get_orc_decimal_rewrite_dtype 'decimal(11,2)')"
  if [ "${a}" != "decimal(10,0)" ] || \
     [ "${b}" != "decimal(10,2)" ] || \
     [ "${c}" != "decimal(10,0)" ] || \
     [ "${d}" != "decimal(10,2)" ] || \
     [ "${e}" != "decimal(11,2)" ]; then
    echo "ERROR: decimal rewrite self test failed"
    echo "  decimal(7,0)  -> ${a}"
    echo "  decimal(7,2)  -> ${b}"
    echo "  decimal(8,0)  -> ${c}"
    echo "  decimal(8,2)  -> ${d}"
    echo "  decimal(11,2) -> ${e}"
    exit 1
  fi
}
########################################
# map / partition
########################################
is_map_type() {
  local dtype=""
  dtype="$(normalize_dtype "${1:-}")"
  case "${dtype}" in
    map\<*,*\>) return 0 ;;
    *) return 1 ;;
  esac
}
get_hudi_map_target_dtype() {
  echo "map<string,string>"
}
get_hudi_map_select_expr() {
  local col="$1"
  local qcol=""
  qcol="$(qi "${col}")"
  echo "map_from_entries(transform(map_entries(${qcol}), x -> named_struct('key', coalesce(cast(x.key as string), ${MAP_NULL_DEFAULT_SQL}), 'value', coalesce(cast(x.value as string), ${MAP_NULL_DEFAULT_SQL})))) AS ${qcol}"
}
is_safe_hudi_partition_dtype() {
  local dtype=""
  dtype="$(normalize_dtype "${1:-}")"
  case "${dtype}" in
    tinyint|smallint|int|integer|bigint|date)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
########################################
# 生成 SQL
########################################
generate_hudi_sql() {
  local tbl="$1"
  local base_format="$2"
  local sql_file="$3"
  local decimal_rewrite_file="${WORKDIR}/meta/${tbl}.decimal_rewritten"
  local key_file="${WORKDIR}/meta/${tbl}.hudi_keys"
  local meta_file="${WORKDIR}/meta/${tbl}.meta"
  local desc_file="${WORKDIR}/desc/${tbl}.desc"
  local cols_file="${WORKDIR}/cols/${tbl}.cols"
  local src_full=""
  local tgt_full=""
  local effective_pk=""
  local effective_precombine=""
  local idx=0
  local last_idx=0
  local col=""
  local dtype=""
  local is_partition=""
  local original_dtype=""
  local final_dtype=""
  local select_expr=""
  local qcol=""
  local decimal_rewrite_dtype=""
  local -a col_defs
  local -a select_exprs
  local -a partition_cols
  echo "NO" > "${decimal_rewrite_file}"
  src_full="$(qi "${SRC_DB}").$(qi "${tbl}")"
  tgt_full="$(qi "${TGT_DB}").$(qi "${tbl}")"
  # 特殊表：current_values_table
  # 不直接迁移 created_date / created_time，避免 Spark 默认值列解析触发 HoodieCatalog 问题
  if [ "${tbl}" = "current_values_table" ]; then
    parse_table_columns "${tbl}" "${desc_file}" "${cols_file}" || return 1
    resolve_hudi_keys "${tbl}" "${cols_file}" "${key_file}" || return 1
    effective_pk="$(cut -d'|' -f1 "${key_file}")"
    effective_precombine="$(cut -d'|' -f2 "${key_file}")"
    {
      echo "CREATE DATABASE IF NOT EXISTS $(qi "${TGT_DB}");"
      echo ""
      if [ "${DROP_TARGET_TABLE}" = "true" ]; then
        echo "DROP TABLE IF EXISTS ${tgt_full};"
        echo ""
      fi
      echo "CREATE TABLE IF NOT EXISTS ${tgt_full} ("
      echo "  \`id\` int,"
      echo "  \`created_date\` date,"
      echo "  \`created_time\` timestamp"
      echo ")"
      echo "USING hudi"
      echo "TBLPROPERTIES ("
      echo "  type = '${TABLE_TYPE}',"
      if [ -n "${effective_pk}" ]; then
        echo "  primaryKey = '${effective_pk}',"
      fi
      if [ -n "${effective_precombine}" ]; then
        echo "  preCombineField = '${effective_precombine}',"
      fi
      echo "  'hoodie.metadata.enable' = 'false',"
      echo "  'hoodie.table.base.file.format' = '${base_format}'"
      echo ");"
      echo ""
      if [ "${base_format}" = "PARQUET" ]; then
        echo "SET spark.sql.hive.convertMetastoreParquet=true;"
        echo "SET hoodie.spark.sql.insert.into.operation=bulk_insert;"
        echo "SET hoodie.bulkinsert.shuffle.parallelism=64;"
        echo "SET hoodie.bulkinsert.sort.mode=PARTITION_PATH_REPARTITION_AND_SORT;"
        echo ""
      fi
      echo "INSERT INTO ${tgt_full}"
      echo "SELECT"
      echo "  \`id\`,"
      echo "  current_date() AS \`created_date\`,"
      echo "  current_timestamp() AS \`created_time\`"
      echo "FROM ${src_full};"
    } > "${sql_file}"
    {
      echo "table=${tbl}"
      echo "source_format=${base_format}"
      echo "primary_key=${effective_pk}"
      echo "precombine_field=${effective_precombine}"
      echo "partition_mode=${PARTITION_MODE}"
      echo "no_partition=${NO_PARTITION}"
      echo "partition_count=0"
    } > "${meta_file}"
    log "INFO: special-case SQL generated for ${tbl}"
    log "resolved primaryKey      : ${effective_pk}"
    log "resolved preCombineField : ${effective_precombine}"
    log "sql file                 : ${sql_file}"
    return 0
  fi
  parse_table_columns "${tbl}" "${desc_file}" "${cols_file}" || return 1
  resolve_hudi_keys "${tbl}" "${cols_file}" "${key_file}" || return 1
  effective_pk="$(cut -d'|' -f1 "${key_file}")"
  effective_precombine="$(cut -d'|' -f2 "${key_file}")"
  if [ -z "${effective_pk}" ]; then
    log "WARN: building NON-PK Hudi table for ${SRC_DB}.${tbl}"
  fi
  col_defs=()
  select_exprs=()
  partition_cols=()
  while IFS=$'\t' read -r col dtype is_partition; do
    col="$(trim "${col}")"
    dtype="$(trim "${dtype}")"
    is_partition="$(trim "${is_partition}")"
    [ -z "${col}" ] && continue
    [ -z "${dtype}" ] && continue
    original_dtype="${dtype}"
    final_dtype="${dtype}"
    qcol="$(qi "${col}")"
    select_expr="${qcol}"
    decimal_rewrite_dtype=""
    if [ "${base_format}" = "ORC" ]; then
      decimal_rewrite_dtype="$(get_orc_decimal_rewrite_dtype "${dtype}")"
      if [ "${decimal_rewrite_dtype}" != "${dtype}" ]; then
        final_dtype="${decimal_rewrite_dtype}"
        select_expr="CAST(${qcol} AS ${final_dtype}) AS ${qcol}"
        echo "YES" > "${decimal_rewrite_file}"
        log "INFO: ${SRC_DB}.${tbl}.${col} decimal adjusted for ORC Hudi: ${dtype} -> ${final_dtype}"
      fi
    fi
    if is_map_type "${original_dtype}"; then
      final_dtype="$(get_hudi_map_target_dtype)"
      select_expr="$(get_hudi_map_select_expr "${col}")"
      if [ "${final_dtype}" != "${original_dtype}" ]; then
        log "WARN: ${SRC_DB}.${tbl}.${col} type rewritten for Hudi compatibility: ${original_dtype} -> ${final_dtype}"
      fi
    fi
    col_defs+=("$(qi "${col}") ${final_dtype}")
    select_exprs+=("${select_expr}")
    if [ "${NO_PARTITION}" -eq 0 ] && [ "${is_partition}" = "1" ]; then
      case "${PARTITION_MODE}" in
        raw)
          partition_cols+=("$(qi "${col}")")
          ;;
        safe)
          if is_safe_hudi_partition_dtype "${final_dtype}"; then
            partition_cols+=("$(qi "${col}")")
          else
            log "WARN: ${SRC_DB}.${tbl}.${col} skipped from Hudi partition columns due to unsafe dtype/value risk: ${final_dtype}"
          fi
          ;;
      esac
    fi
  done < "${cols_file}"
  if [ "${#col_defs[@]}" -eq 0 ]; then
    echo "ERROR: cannot parse business columns from ${SRC_DB}.${tbl}"
    return 1
  fi
  {
    echo "CREATE DATABASE IF NOT EXISTS $(qi "${TGT_DB}");"
    echo ""
    if [ "${DROP_TARGET_TABLE}" = "true" ]; then
      echo "DROP TABLE IF EXISTS ${tgt_full};"
      echo ""
    fi
    echo "CREATE TABLE IF NOT EXISTS ${tgt_full} ("
    last_idx="$((${#col_defs[@]} - 1))"
    for ((idx=0; idx<${#col_defs[@]}; idx++)); do
      if [ "${idx}" -eq "${last_idx}" ]; then        echo "  ${col_defs[$idx]}"
      else
        echo "  ${col_defs[$idx]},"
      fi
    done
    echo ")"
    echo "USING hudi"
    if [ "${NO_PARTITION}" -eq 0 ] && [ "${#partition_cols[@]}" -gt 0 ]; then
      printf "PARTITIONED BY ("
      last_idx="$((${#partition_cols[@]} - 1))"
      for ((idx=0; idx<${#partition_cols[@]}; idx++)); do
        if [ "${idx}" -eq "${last_idx}" ]; then
          printf "%s" "${partition_cols[$idx]}"
        else
          printf "%s, " "${partition_cols[$idx]}"
        fi
      done
      printf ")\n"
    fi
    echo "TBLPROPERTIES ("
    echo "  type = '${TABLE_TYPE}',"
    if [ -n "${effective_pk}" ]; then
	   echo "  primaryKey = '${effective_pk}',"
    fi
    if [ -n "${effective_precombine}" ]; then
	  echo "  preCombineField = '${effective_precombine}',"
    fi
    echo "  'hoodie.metadata.enable' = 'false',"
    echo "  'hoodie.table.base.file.format' = '${base_format}'"
    echo ");"
    echo ""
    if [ "${base_format}" = "PARQUET" ]; then
      echo "SET hoodie.spark.sql.insert.into.operation=bulk_insert;"
      echo "SET spark.sql.hive.convertMetastoreParquet=true;"
      echo ""
    fi
    if [ "${tbl}" = "web_sales" ] || [ "${tbl}" = "catalog_returns" ] || [ "${tbl}" = "catalog_sales" ] || [ "${tbl}" = "current_values_table" ] || [ "${tbl}" = "store_returns" ] || [ "${tbl}" = "store_sales" ] || [ "${tbl}" = "web_returns" ]; then
      echo "SET hoodie.bulkinsert.shuffle.parallelism=64;"
      echo "SET hoodie.bulkinsert.sort.mode=PARTITION_PATH_REPARTITION_AND_SORT;"
      echo ""
    fi
    echo "INSERT INTO ${tgt_full}"
    echo "SELECT"
    last_idx="$((${#select_exprs[@]} - 1))"
    for ((idx=0; idx<${#select_exprs[@]}; idx++)); do
      if [ "${idx}" -eq "${last_idx}" ]; then
        echo "  ${select_exprs[$idx]}"
      else
        echo "  ${select_exprs[$idx]},"
      fi
    done
    echo "FROM ${src_full};"
  } > "${sql_file}"
  # ORC DDL 强校验：不允许 decimal<10
  if [ "${base_format}" = "ORC" ]; then
    if grep -En '^[[:space:]]*`[^`]+` decimal$([1-9]),[0-9]+$' "${sql_file}" >/dev/null 2>&1 \
      || grep -En '^[[:space:]]*`[^`]+` decimal$([1-9])$' "${sql_file}" >/dev/null 2>&1; then
      log "ERROR: ORC table still contains decimal precision < 10 in generated DDL: ${sql_file}"
      grep -En '^[[:space:]]*`[^`]+` decimal$([1-9]),[0-9]+$|^[[:space:]]*`[^`]+` decimal$([1-9])$' "${sql_file}" || true
      return 1
    fi
  fi
  {
    echo "table=${tbl}"
    echo "source_format=${base_format}"
    echo "primary_key=${effective_pk}"
    echo "precombine_field=${effective_precombine}"
    echo "partition_mode=${PARTITION_MODE}"
    echo "no_partition=${NO_PARTITION}"
    echo "partition_count=${#partition_cols[@]}"
  } > "${meta_file}"
  log "resolved primaryKey      : ${effective_pk}"
  log "resolved preCombineField : ${effective_precombine}"
  log "sql file                 : ${sql_file}"
  return 0
}
########################################
# 执行 / 错误处理
########################################
migrate_one_attempt() {
  local tbl="$1"
  local sql_file="${WORKDIR}/sql/${tbl}.sql"
  local fmt=""
  fmt="$(get_source_format "${tbl}")"
  if [ -z "${fmt}" ]; then
    log "ERROR: unsupported source format, only ORC/PARQUET supported: ${SRC_DB}.${tbl}"
    return 2
  fi
  log "source format: ${fmt}"
  if [ "${fmt}" != "ORC" ] && [ "${fmt}" != "PARQUET" ]; then
    log "ERROR: unsupported format: ${fmt}"
    return 2
  fi
  generate_hudi_sql "${tbl}" "${fmt}" "${sql_file}" || return 3
  if [ "${DRY_RUN}" -eq 1 ]; then
    log "dry-run mode, SQL generated only"
    cat "${sql_file}"
    return 0
  fi
  log "execute spark-sql start"
  run_sparksql_file "${sql_file}" > "${WORKDIR}/logs/${tbl}.execute.out" 2> "${WORKDIR}/logs/${tbl}.execute.err"
  local rc=$?
  if [ ${rc} -ne 0 ]; then
    log "execute spark-sql failed, rc=${rc}, see ${WORKDIR}/logs/${tbl}.execute.err"
    return ${rc}
  fi
  log "execute spark-sql success"
  return 0
}
extract_error_message() {
  local tbl="$1"
  local msg=""
  local err1="${WORKDIR}/logs/${tbl}.execute.err"
  local err2="${WORKDIR}/logs/${tbl}.formatted.err"
  local err3="${WORKDIR}/logs/${tbl}.describe.err"
  if [ -s "${err1}" ]; then
    msg="$(tail -80 "${err1}" | grep -E 'AnalysisException|ParseException|Exception|Error|ERROR|FAILED|IncompatibleSchemaException|Ordering value is null|not a valid DFS filename|IllegalArgumentException|precision [0-9]+ is out of range' | tail -1)"
  fi
  if [ -z "${msg}" ] && [ -s "${err2}" ]; then
    msg="$(tail -80 "${err2}" | grep -E 'AnalysisException|ParseException|Exception|Error|ERROR|FAILED' | tail -1)"
  fi
  if [ -z "${msg}" ] && [ -s "${err3}" ]; then
    msg="$(tail -80 "${err3}" | grep -E 'AnalysisException|ParseException|Exception|Error|ERROR|FAILED' | tail -1)"
  fi
  msg="$(trim "${msg}")"
  echo "${msg}"
}
process_one_table() {
  local tbl="$1"
  local table_log="${WORKDIR}/logs/${tbl}.log"
  local status_file="${WORKDIR}/status/${tbl}.status.csv"
  (
    exec > >(tee -a "${table_log}") 2>&1
    local status="FAILED"
    local message=""
    local retries=0
    local attempt=0
    local src_count=""
    local tgt_count=""
    local decimal_rewritten="NO"
    local effective_pk=""
    local effective_precombine=""
    local decimal_rewrite_file="${WORKDIR}/meta/${tbl}.decimal_rewritten"
    local key_file="${WORKDIR}/meta/${tbl}.hudi_keys"
    log "----------------------------------------"
    log "table start: ${SRC_DB}.${tbl} -> ${TGT_DB}.${tbl}"
    log "----------------------------------------"
    src_count="$(get_count "${SRC_DB}" "${tbl}")"
    log "source count: ${src_count:-UNKNOWN}"
    while [ ${attempt} -le ${MAX_RETRIES} ]; do
      attempt=$((attempt + 1))
      retries=$((attempt - 1))
      log "attempt ${attempt}/$((MAX_RETRIES + 1)) for table ${tbl}"
      migrate_one_attempt "${tbl}"
      local rc=$?
      if [ -f "${decimal_rewrite_file}" ]; then
        decimal_rewritten="$(cat "${decimal_rewrite_file}")"
      fi
      if [ -f "${key_file}" ]; then
        effective_pk="$(cut -d'|' -f1 "${key_file}")"
        effective_precombine="$(cut -d'|' -f2 "${key_file}")"
      fi
      if [ ${rc} -eq 0 ]; then
        status="SUCCESS"
        message="OK"
        break
      fi
      status="FAILED"
      message="$(extract_error_message "${tbl}")"
      if [ -z "${message}" ]; then
        message="migrate failed rc=${rc}"
      fi
      if [ ${attempt} -le ${MAX_RETRIES} ]; then
        log "table ${tbl} failed, retry after ${RETRY_WAIT_SECONDS}s, rc=${rc}"
        sleep "${RETRY_WAIT_SECONDS}"
      else
        log "table ${tbl} failed, no more retries, rc=${rc}"
      fi
    done
    if [ "${status}" = "SUCCESS" ] && [ "${DRY_RUN}" -eq 0 ]; then
      tgt_count="$(get_count "${TGT_DB}" "${tbl}")"
      log "target count: ${tgt_count:-UNKNOWN}"
      if [ -n "${src_count}" ] && [ -n "${tgt_count}" ] && [ "${src_count}" != "${tgt_count}" ]; then
        message="count mismatch: src=${src_count}, tgt=${tgt_count}"
      fi
    fi
    {
      printf '%s,%s,%s,%s,%s,%s,%s,%s,' \
        "${tbl}" \
        "${status}" \
        "${retries}" \
        "${src_count}" \
        "${tgt_count}" \
        "${decimal_rewritten}" \
        "${effective_pk}" \
        "${effective_precombine}"
      csv_escape "${message}"
      printf '\n'
    } > "${status_file}"
    log "table finished: ${tbl}, status=${status}, retries=${retries}, decimal_rewritten=${decimal_rewritten}"
    log "message: ${message}"
    exit 0
  )
}
########################################
# 启动
########################################
self_test_decimal_rewrite
log "========================================"
log "start migrate ${SRC_DB} -> ${TGT_DB}"
log "workdir=${WORKDIR}"
log "dry_run=${DRY_RUN}, partition_mode=${PARTITION_MODE}, no_partition=${NO_PARTITION}"
log "========================================"
run_sparksql "CREATE DATABASE IF NOT EXISTS $(qi "${TGT_DB}");" > "${WORKDIR}/logs/create_db.log" 2>&1
CREATE_DB_RC=$?
if [ ${CREATE_DB_RC} -ne 0 ]; then
  log "ERROR: create target db failed, see ${WORKDIR}/logs/create_db.log"
  exit 1
fi
if [ -n "${ONLY_TABLE}" ]; then
  printf '%s\n' "${ONLY_TABLE}" > "${WORKDIR}/meta/tables.list"
else
 list_source_tables "${WORKDIR}/meta/tables.list" || exit 1
fi
TABLE_COUNT="$(wc -l < "${WORKDIR}/meta/tables.list" | tr -d ' ')"
log "tables to process=${TABLE_COUNT}"
log "Auto safe key              : ${AUTO_SAFE_KEY}"
log "Non-PK fallback            : ${NONPK_FALLBACK}"
if [ "${TABLE_COUNT}" -eq 0 ]; then
  log "No tables found, exit."
  exit 0
fi
while read -r TBL; do
  TBL="$(clean_value "${TBL}")"
  [ -z "${TBL}" ] && continue
  wait_for_slot
  log "submit table: ${TBL}"
  process_one_table "${TBL}" &
done < "${WORKDIR}/meta/tables.list"
wait
for f in "${WORKDIR}"/status/*.status.csv; do
  if [ -f "${f}" ]; then
    cat "${f}" >> "${SUMMARY_FILE}"
  fi
done
SUCCESS_CNT="$(awk -F',' 'NR>1 && $2=="SUCCESS" {c++} END{print c+0}' "${SUMMARY_FILE}")"
FAIL_CNT="$(awk -F',' 'NR>1 && $2!="SUCCESS" {c++} END{print c+0}' "${SUMMARY_FILE}")"
REWRITE_CNT="$(awk -F',' 'NR>1 && $6=="YES" {c++} END{print c+0}' "${SUMMARY_FILE}")"
log "finished, success=${SUCCESS_CNT}, failed=${FAIL_CNT}, decimal_rewritten=${REWRITE_CNT}"
log "summary=${SUMMARY_FILE}"
awk -F',' 'NR>1 && $2!="SUCCESS" {print $1","$9}' "${SUMMARY_FILE}" > "${WORKDIR}/report/failed_tables.csv" || true
awk -F',' 'NR>1 && $6=="YES" {print $1","$6","$7","$8}' "${SUMMARY_FILE}" > "${WORKDIR}/report/decimal_rewritten_tables.csv" || true
