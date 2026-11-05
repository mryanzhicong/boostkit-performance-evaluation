#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-3.5.2}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
configure_runtime_paths() {
    [[ "$SOFTWARE_VERSION" == 3.5.2 && "$PERF_VARIANT" == base ]] || {
        echo 'Spark supports only version 3.5.2, variant base'; return 10;
    }
    case "$EXPECTED_ARCH" in arm64) EXPECTED_ARCH=aarch64 ;; amd64) EXPECTED_ARCH=x86_64 ;; esac
    [[ "$EXPECTED_ARCH" == aarch64 || "$EXPECTED_ARCH" == x86_64 ]] || return 20
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "$PERF_RUN_ID" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/spark/local-$PERF_RUN_ID}"
    [[ "$PERF_WORK_DIR" == /home/runner/boostkit-perf/spark/* && "$PERF_WORK_DIR" != *'/../'* ]] || return 10
    RESULTS_DIR="${RESULTS_DIR:-$SCRIPT_DIR/results/$SOFTWARE_VERSION/$PERF_RUN_ID}"
    [[ "$RESULTS_DIR" == /* ]] || RESULTS_DIR="$(pwd -P)/$RESULTS_DIR"
    [[ "$RESULTS_DIR/" != "$PERF_WORK_DIR/"* ]] || { echo 'Results must be outside the disposable work directory'; return 10; }
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-$PERF_WORK_DIR/actual-version.txt}"
    SPARK_CONTAINER="boostkit-spark-$EXPECTED_ARCH-$PERF_RUN_ID"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_WORK_DIR PERF_RUN_ID RESULTS_DIR PERF_ACTUAL_VERSION_FILE
}
initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "$PERF_WORK_DIR" "$RESULTS_DIR"
}
validate_image_architecture() {
    case "$EXPECTED_ARCH:$1" in aarch64:arm64|x86_64:amd64) return 0 ;; *) return 30 ;; esac
}
container_exec() {
    docker exec -e "PERF_WORK_DIR=$PERF_WORK_DIR" -e "RESULTS_DIR=$RESULTS_DIR" \
        -e "EXPECTED_ARCH=$EXPECTED_ARCH" -e "PERF_ACTUAL_VERSION_FILE=$PERF_ACTUAL_VERSION_FILE" \
        -e "BENCH_UID=$(id -u)" -e "BENCH_GID=$(id -g)" \
        "$SPARK_CONTAINER" python3 "$SCRIPT_DIR/scripts/runtime.py" "$@"
}
remove_spark_container() {
    configure_runtime_paths || return $?
    docker container inspect "$SPARK_CONTAINER" >/dev/null 2>&1 || return 0
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.spark.run-id"}}' "$SPARK_CONTAINER")" == "$PERF_RUN_ID" ]] || return 70
    local rc=0
    container_exec collect || rc=70
    docker stop --time 30 "$SPARK_CONTAINER" >/dev/null || rc=70
    docker rm "$SPARK_CONTAINER" >/dev/null || rc=70
    return "$rc"
}
