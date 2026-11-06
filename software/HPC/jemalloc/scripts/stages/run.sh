#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_jemalloc_benchmarks() {
    bash "${SCRIPT_DIR}/scripts/stages/test.sh"
}
