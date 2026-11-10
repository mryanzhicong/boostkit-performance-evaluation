#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
build_spark() {
    configure_runtime_paths || return $?
    source "$SCRIPT_DIR/scripts/builders/base.sh"
    build_spark_base || return $?
    printf '{"variant":"base","parameters":{"variant":"base"}}\n' > "$RESULTS_DIR/build_variant.json"
}
