#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PERF_COMPONENT="${PERF_COMPONENT:-spark}"
PERF_COMPONENT_VERSION="${PERF_COMPONENT_VERSION:-3.5.2}"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-$PERF_COMPONENT_VERSION}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
configure_runtime_paths() {
    [[ "$SOFTWARE_VERSION" == "$PERF_COMPONENT_VERSION" && "$PERF_VARIANT" == base ]] || {
        echo "Supported: $PERF_COMPONENT $PERF_COMPONENT_VERSION, variant base"; return 10;
    }
    case "$EXPECTED_ARCH" in arm64) EXPECTED_ARCH=aarch64 ;; amd64) EXPECTED_ARCH=x86_64 ;; esac
    [[ "$EXPECTED_ARCH" == aarch64 || "$EXPECTED_ARCH" == x86_64 ]] || return 20
    if [[ -n "${PERF_ADAPTER_DIR:-}" ]] && ! python3 -c 'import json,sys; cfg=json.load(open(sys.argv[1])); sys.exit(0 if sys.argv[2] in cfg.get("supported_architectures", ["aarch64"]) else 20)' "$PERF_ADAPTER_DIR/profile.json" "$EXPECTED_ARCH"; then
        echo "This document-pinned adapter does not support $EXPECTED_ARCH"; return 20
    fi
    PERF_RUN_ID="${PERF_RUN_ID:-local-$(date -u '+%Y%m%dT%H%M%SZ')-$$}"
    [[ "$PERF_RUN_ID" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/$PERF_COMPONENT/local-$PERF_RUN_ID}"
    [[ "$PERF_WORK_DIR" == /home/runner/boostkit-perf/$PERF_COMPONENT/* && "$PERF_WORK_DIR" != *'/../'* ]] || return 10
    RESULTS_DIR="${RESULTS_DIR:-${PERF_ADAPTER_DIR:-$SCRIPT_DIR}/results/$SOFTWARE_VERSION/$PERF_RUN_ID}"
    [[ "$RESULTS_DIR" == /* ]] || RESULTS_DIR="$(pwd -P)/$RESULTS_DIR"
    [[ "$RESULTS_DIR/" != "$PERF_WORK_DIR/"* ]] || { echo 'Results must be outside the disposable work directory'; return 10; }
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-$PERF_WORK_DIR/actual-version.txt}"
    SPARK_CONTAINER="boostkit-$PERF_COMPONENT-$EXPECTED_ARCH-$PERF_RUN_ID"
    export PERF_COMPONENT PERF_COMPONENT_VERSION SOFTWARE_VERSION EXPECTED_ARCH PERF_WORK_DIR PERF_RUN_ID RESULTS_DIR PERF_ACTUAL_VERSION_FILE
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
        -e "PERF_ADAPTER_DIR=${PERF_ADAPTER_DIR:-}" -e "PERF_COMPONENT=$PERF_COMPONENT" \
        -e "PERF_COMPONENT_VERSION=$PERF_COMPONENT_VERSION" \
        -e "BENCH_UID=$(id -u)" -e "BENCH_GID=$(id -g)" \
        "$SPARK_CONTAINER" python3 "$SCRIPT_DIR/scripts/runtime.py" "$@"
}
remove_spark_container() {
    configure_runtime_paths || return $?
    docker container inspect "$SPARK_CONTAINER" >/dev/null 2>&1 || { remove_spark_network; return $?; }
    [[ "$(docker inspect --format '{{index .Config.Labels "boostkit.spark.run-id"}}' "$SPARK_CONTAINER")" == "$PERF_RUN_ID" ]] || return 70
    local rc=0
    container_exec collect || rc=70
    docker stop --time 30 "$SPARK_CONTAINER" >/dev/null || rc=70
    docker rm "$SPARK_CONTAINER" >/dev/null || rc=70
    remove_spark_network || rc=70
    return "$rc"
}

remove_spark_network() {
    [[ -n "${PERF_ADAPTER_DIR:-}" ]] || return 0
    local network="$SPARK_CONTAINER-net"
    docker network inspect "$network" >/dev/null 2>&1 || return 0
    [[ "$(docker network inspect --format '{{index .Labels "boostkit.spark.run-id"}}' "$network")" == "$PERF_RUN_ID" ]] || return 70
    docker network rm "$network" >/dev/null || return 70
}
