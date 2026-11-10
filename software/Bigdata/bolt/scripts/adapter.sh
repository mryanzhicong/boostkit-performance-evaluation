#!/usr/bin/env bash
set -euo pipefail
PERF_ADAPTER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PERF_ADAPTER_DIR PERF_COMPONENT=bolt PERF_COMPONENT_VERSION=1.0.0-SNAPSHOT
SOFTWARE_VERSION="${SOFTWARE_VERSION:-$PERF_COMPONENT_VERSION}"
export SOFTWARE_VERSION
source "$PERF_ADAPTER_DIR/../spark/scripts/builders/dispatch.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/start.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/test.sh"
source "$PERF_ADAPTER_DIR/../spark/scripts/stages/stop.sh"
build_bolt() { build_spark; }
start_bolt() { start_spark_runtime; }
test_bolt() { run_spark_benchmarks; }
stop_bolt() { stop_spark_runtime; }
