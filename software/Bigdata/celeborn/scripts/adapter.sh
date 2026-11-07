#!/usr/bin/env bash
set -euo pipefail
PERF_ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PERF_ADAPTER_DIR PERF_COMPONENT=celeborn PERF_COMPONENT_VERSION=0.5.3
SOFTWARE_VERSION="${SOFTWARE_VERSION:-$PERF_COMPONENT_VERSION}"
export SOFTWARE_VERSION
source "$PERF_ADAPTER_DIR/../spark/scripts/builders/dispatch.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/start.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/test.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/stop.sh"
build_celeborn() { build_spark; }
start_celeborn() {
    if [[ "$EXPECTED_ARCH" == x86_64 || "$EXPECTED_ARCH" == amd64 ]]; then
        initialize_runtime || return $?
        docker exec -e "PERF_WORK_DIR=$PERF_WORK_DIR" -e "RESULTS_DIR=$RESULTS_DIR" \
            -e "EXPECTED_ARCH=$EXPECTED_ARCH" "$SPARK_CONTAINER" \
            python3 "$PERF_ADAPTER_DIR/scripts/normalize_x86_workload.py" || return 40
    fi
    start_spark_runtime
}
test_celeborn() { run_spark_benchmarks; }
stop_celeborn() { stop_spark_runtime; }
