#!/usr/bin/env python3
"""Run the official hsbench scenario matrix and write structured results."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

RUN_TIMEOUT_SECONDS = 7200

# The official hsbench overall throughput output line.  The printf uses
# the ' locale thousands separator (inactive in the C locale); the
# parser accepts both comma-separated and plain digit forms.
THROUGHPUT_LINE = re.compile(
    r"^Mean throughput \(overall\):\s*([\d,]+(?:\.\d+)?)\s*Mbit/sec",
    re.MULTILINE,
)

# The official scan modes: hsbench's default streaming scan and the -N
# block mode.
MODES: tuple[tuple[str, str], ...] = (
    ("streaming", ""),
    ("block", "-N"),
)


def thread_flag(threads: int) -> list[str]:
    """hsbench -T: one benchmark thread per listed CPU (0..N-1)."""
    return ["-T", f"0-{threads - 1}"] if threads > 1 else ["-T", "0"]


def parse_throughput(output: str, scenario: str) -> float:
    matches = THROUGHPUT_LINE.findall(output)
    if len(matches) != 1:
        raise RuntimeError(
            f"scenario {scenario} produced {len(matches)} overall throughput lines, expected 1"
        )
    value = float(matches[0].replace(",", ""))
    if value <= 0:
        raise RuntimeError(f"scenario {scenario} reported a non-positive throughput: {value}")
    return value


def run_scenario(
    hsbench: Path,
    patterns: Path,
    corpus: Path,
    mode: str,
    mode_flag: str,
    threads: int,
    repeats: int,
) -> dict[str, Any]:
    scenario = f"{mode}_t{threads}"
    command = [
        str(hsbench),
        "-e", str(patterns),
        "-c", str(corpus),
        *thread_flag(threads),
        "-n", str(repeats),
    ]
    if mode_flag:
        command.append(mode_flag)
    print(f"[hsbench] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=RUN_TIMEOUT_SECONDS,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"hsbench scenario {scenario} exited with code {completed.returncode}")
    throughput = parse_throughput(completed.stdout, scenario)
    print(
        f"[hsbench] {scenario}: {throughput:.2f} Mbit/sec",
        flush=True,
    )
    return {
        "mode": mode,
        "threads": threads,
        "repeats": repeats,
        "value": throughput,
        "raw_output": completed.stdout,
    }


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "usage: run_hsbench.py HSBENCH PATTERNS CORPUS OUTPUT",
            file=sys.stderr,
        )
        return 1
    hsbench, patterns, corpus, output = (Path(arg) for arg in sys.argv[1:5])
    for required in (hsbench, patterns, corpus):
        if not required.is_file():
            raise RuntimeError(f"required input is unavailable: {required}")
    if not os.access(hsbench, os.X_OK):
        raise RuntimeError(f"hsbench is not executable: {hsbench}")

    repeats = int(os.environ.get("HYPERSCAN_REPETITIONS", "20"))
    if repeats < 1:
        raise RuntimeError("HYPERSCAN_REPETITIONS must be a positive integer")

    ladder = [
        int(value)
        for value in os.environ.get("HYPERSCAN_THREADS_LADDER", "1 4 16").split()
    ]
    if not ladder:
        raise RuntimeError("HYPERSCAN_THREADS_LADDER is empty")

    results: dict[str, dict[str, Any]] = {}
    for mode, mode_flag in MODES:
        for threads in ladder:
            scenario = f"{mode}_t{threads}"
            results[scenario] = run_scenario(
                hsbench, patterns, corpus, mode, mode_flag, threads, repeats
            )

    payload = {
        "benchmark": "hyperscan_hsbench",
        "software": "hyperscan",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "source_repository": os.environ.get("HYPERSCAN_SOURCE_URL", ""),
            "source_tag": f"v{os.environ['SOFTWARE_VERSION']}",
            "tool": "official tools/hsbench",
            "modes": [mode for mode, _ in MODES],
            "thread_ladder": ladder,
            "repeats": repeats,
            "patterns_file": "fixed 50-expression set (src/patterns)",
            "corpus": "source-tree text set via the official corpus db schema",
            "metric": "Mean throughput (overall) in Mbit/sec, higher is better",
        },
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[hsbench] {len(results)} scenarios completed", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
