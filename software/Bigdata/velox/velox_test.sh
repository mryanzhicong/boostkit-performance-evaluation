#!/usr/bin/env bash
set -euo pipefail
ADAPTER_ENTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
    echo 'Usage: velox_test.sh --version 1.3.0 --variant base --results-dir /absolute/results'
    exit 0
fi
source "$ADAPTER_ENTRY_DIR/scripts/adapter.sh"
source "$SCRIPT_DIR/spark_test.sh"
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    if [[ "${PERF_BOUNDED:-0}" != 1 ]]; then
        exec timeout --signal=TERM --kill-after=180 24h env PERF_BOUNDED=1 bash "$0" "$@"
    fi
    main "$@"
fi
