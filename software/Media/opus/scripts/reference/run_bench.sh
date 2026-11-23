#!/usr/bin/env bash
set -euo pipefail
runner=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$runner/bootstrap_env.sh"
mkdir -p "$runner/.work"
printf 'Preparing stock fixed-point Opus; log: %s
' "$runner/.work/build.log"
if ! bash "$runner/build_install.sh" > "$runner/.work/build.log" 2>&1; then
    tail -n 30 "$runner/.work/build.log" >&2
    exit 1
fi
python3 -B "$runner/bench.py"
