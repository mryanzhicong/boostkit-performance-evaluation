#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_lance_runtime() {
    initialize_runtime || return $?
    check_lance_container || return $?
    container_exec "${LANCE_VENV}/bin/python" -c \
        'import importlib.metadata as m, lance; from lance.torch.bench_utils import ground_truth, recall; assert m.version("pylance") == "13.0.0"' || return 40
    log 'source-built Lance runtime is ready inside the private container'
}
