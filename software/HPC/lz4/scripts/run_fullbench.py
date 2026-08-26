#!/usr/bin/env python3
"""Run the four approved LZ4 fullbench commands and write structured results."""

from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


ITERATION_LOOPS = 3
CASES: tuple[dict[str, Any], ...] = (
    {
        "block_option": "B4",
        "block_size_bytes": 64 * 1024,
        "operation_option": "c1",
        "operation": "compression",
        "function": "LZ4_compress_default",
        "result_name": "1-LZ4_compress_default",
    },
    {
        "block_option": "B4",
        "block_size_bytes": 64 * 1024,
        "operation_option": "d4",
        "operation": "decompression",
        "function": "LZ4_decompress_safe",
        "result_name": "4-LZ4_decompress_safe",
    },
    {
        "block_option": "B7",
        "block_size_bytes": 4 * 1024 * 1024,
        "operation_option": "c1",
        "operation": "compression",
        "function": "LZ4_compress_default",
        "result_name": "1-LZ4_compress_default",
    },
    {
        "block_option": "B7",
        "block_size_bytes": 4 * 1024 * 1024,
        "operation_option": "d4",
        "operation": "decompression",
        "function": "LZ4_decompress_safe",
        "result_name": "4-LZ4_decompress_safe",
    },
)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_result(output: str, case: dict[str, Any]) -> dict[str, float | int]:
    function = re.escape(str(case["function"]))
    if case["operation"] == "compression":
        pattern = re.compile(
            rf"^\s*1-{function}\s*:\s*(\d+)\s*->\s*(\d+)\s*"
            rf"\(\s*([0-9.]+)%\),\s*([0-9.]+)\s+MB/s\s*$",
            re.MULTILINE,
        )
        matches = pattern.findall(output)
        if len(matches) != 1:
            raise RuntimeError(
                f"expected one {case['function']} compression result, found {len(matches)}"
            )
        source_size, compressed_size, compressed_percent, speed = matches[0]
        return {
            "source_size_bytes": int(source_size),
            "compressed_size_bytes": int(compressed_size),
            "compressed_percent": float(compressed_percent),
            "speed_mbs": float(speed),
        }

    pattern = re.compile(
        rf"^\s*4-{function}\s*:\s*(\d+)\s*->\s*([0-9.]+)\s+MB/s\s*$",
        re.MULTILINE,
    )
    matches = pattern.findall(output)
    if len(matches) != 1:
        raise RuntimeError(
            f"expected one {case['function']} decompression result, found {len(matches)}"
        )
    source_size, speed = matches[0]
    return {"source_size_bytes": int(source_size), "speed_mbs": float(speed)}


def display_command(case: dict[str, Any]) -> str:
    """Return the stable form of the fullbench command shown in reports."""
    return " ".join((
        "./tests/fullbench",
        "--no-prompt",
        f"-i{ITERATION_LOOPS}",
        f"-{case['block_option']}",
        f"-{case['operation_option']}",
        "silesia.tar",
    ))


def run_case(fullbench: Path, corpus: Path, case: dict[str, Any]) -> dict[str, Any]:
    command = [
        str(fullbench),
        "--no-prompt",
        f"-i{ITERATION_LOOPS}",
        f"-{case['block_option']}",
        f"-{case['operation_option']}",
        str(corpus),
    ]
    print(f"[fullbench] {' '.join(command)}", flush=True)
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=900,
        check=False,
    )
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(
            f"fullbench result {case['result_name']} with "
            f"-{case['block_option']} exited with code {completed.returncode}"
        )
    parsed = parse_result(completed.stdout, case)
    if parsed["speed_mbs"] <= 0:
        raise RuntimeError(
            f"fullbench result {case['result_name']} with "
            f"-{case['block_option']} returned a non-positive speed"
        )
    return {
        "command": command,
        "command_display": display_command(case),
        "function": case["function"],
        "operation": case["operation"],
        "block_size_bytes": case["block_size_bytes"],
        **parsed,
        "raw_output": completed.stdout,
    }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: run_fullbench.py FULLBENCH SILESIA_TAR OUTPUT", file=sys.stderr)
        return 1
    fullbench, corpus, output = map(Path, sys.argv[1:])
    if not fullbench.is_file() or not os.access(fullbench, os.X_OK):
        raise RuntimeError(f"fullbench executable is unavailable: {fullbench}")
    if not corpus.is_file() or corpus.stat().st_size == 0:
        raise RuntimeError(f"Silesia corpus is unavailable: {corpus}")

    results: dict[str, dict[str, Any]] = {}
    for case in CASES:
        metric_name = f"{case['block_option']}/{case['result_name']}"
        results[metric_name] = run_case(fullbench, corpus, case)
    payload = {
        "benchmark": "lz4_fullbench",
        "software": "lz4",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "corpus": "Silesia Corpus",
            "corpus_repository": os.environ["SILESIA_REPOSITORY_URL"],
            "corpus_commit": os.environ["SILESIA_REPOSITORY_COMMIT"],
            "corpus_size_bytes": corpus.stat().st_size,
            "corpus_sha256": sha256(corpus),
            "iteration_loops": ITERATION_LOOPS,
            "cases": [
                {
                    "block_option": case["block_option"],
                    "block_size_bytes": case["block_size_bytes"],
                    "operation_option": case["operation_option"],
                    "function": case["function"],
                }
                for case in CASES
            ],
        },
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
