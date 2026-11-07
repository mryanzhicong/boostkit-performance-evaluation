#!/usr/bin/env bash
set -euo pipefail
PERF_ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PERF_ADAPTER_DIR PERF_COMPONENT=iceberg PERF_COMPONENT_VERSION=1.5.0
SOFTWARE_VERSION="${SOFTWARE_VERSION:-$PERF_COMPONENT_VERSION}"
export SOFTWARE_VERSION
source "$PERF_ADAPTER_DIR/../spark/scripts/builders/dispatch.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/start.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/test.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/stop.sh"
build_iceberg() { build_spark; }
start_iceberg() { start_spark_runtime; }
test_iceberg() { run_spark_benchmarks; }
stop_iceberg() { stop_spark_runtime; }
