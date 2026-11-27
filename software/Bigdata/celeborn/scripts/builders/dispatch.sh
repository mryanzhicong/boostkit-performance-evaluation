#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_celeborn() {
    case "${PERF_VARIANT}" in
        base)
            source "${CASE_DIR}/scripts/builders/base.sh"
            build_celeborn_base || return $?
            ;;
        optimized)
            source "${CASE_DIR}/scripts/builders/optimized.sh"
            build_celeborn_optimized || return $?
            ;;
        *) return 10 ;;
    esac
    python3 - "${RESULTS_DIR}/build_variant.json" "${PERF_VARIANT}" <<'PY'
import json
import sys

path, variant = sys.argv[1], sys.argv[2]
parameters = {
    "variant": variant,
    "scale_factor": __import__("os").environ.get("CELEBORN_SCALE_FACTOR", "3"),
    "shuffle_manager": "org.apache.spark.shuffle.celeborn.SparkShuffleManager",
    "spark": "3.5.2",
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump({"variant": variant, "parameters": parameters}, handle, indent=2, sort_keys=True)
    handle.write("\n")
PY
}
