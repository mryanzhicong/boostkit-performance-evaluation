#!/usr/bin/env bash
set -euo pipefail
PERF_ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PERF_ADAPTER_DIR PERF_COMPONENT=velox PERF_COMPONENT_VERSION=1.3.0
SOFTWARE_VERSION="${SOFTWARE_VERSION:-$PERF_COMPONENT_VERSION}"
export SOFTWARE_VERSION
source "$PERF_ADAPTER_DIR/../spark/scripts/builders/dispatch.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/start.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/test.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/stop.sh"
build_velox() { build_spark; }
start_velox() { start_spark_runtime; }
test_velox() { run_spark_benchmarks; }
stop_velox() { stop_spark_runtime; }
