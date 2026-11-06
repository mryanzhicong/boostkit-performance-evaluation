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
start_celeborn() { start_spark_runtime; }
test_celeborn() { run_spark_benchmarks; }
stop_celeborn() { stop_spark_runtime; }
