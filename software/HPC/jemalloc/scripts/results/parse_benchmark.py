#!/usr/bin/env python3
"""Extract the final summaries printed by the supplied malloc_benchmark binary."""

import argparse
import json
import math
import re
from pathlib import Path

SUMMARY = re.compile(
    r"^Mode:\s*(\d+),\s*Time:\s*([\d.]+) seconds,\s*"
    r"Average RSS:\s*([\d.]+) GB,\s*Max RSS:\s*([\d.]+) GB\.\s*"
    r"Average speed:\s*([\d.]+),\s*Max speed:\s*([\d.]+)\.\s*$",
    re.MULTILINE,
)


def parse_mode(path: Path, expected_mode: int) -> list[dict]:
    summaries = SUMMARY.findall(path.read_text(encoding="utf-8"))
    if len(summaries) != 1:
        raise ValueError(f"{path}: expected exactly one completed benchmark summary, found {len(summaries)}")
    mode_text, seconds, average_rss, max_rss, average_speed, max_speed = summaries[0]
    if int(mode_text) != expected_mode:
        raise ValueError(f"{path}: expected mode {expected_mode}, got {mode_text}")
    values = {
        "elapsed_seconds": float(seconds),
        "average_rss_gb": float(average_rss),
        "max_rss_gb": float(max_rss),
        "average_speed": float(average_speed),
        "max_speed": float(max_speed),
    }
    if not all(math.isfinite(value) and value >= 0 for value in values.values()):
        raise ValueError(f"{path}: summary contains a non-finite or negative value")
    if values["elapsed_seconds"] <= 0 or values["average_speed"] <= 0:
        raise ValueError(f"{path}: benchmark did not report a positive elapsed time and speed")
    units = {"elapsed_seconds": "s", "average_rss_gb": "GB", "max_rss_gb": "GB",
             "average_speed": "score", "max_speed": "score"}
    directions = {"elapsed_seconds": "lower_is_better", "average_rss_gb": "lower_is_better",
                  "max_rss_gb": "lower_is_better", "average_speed": "higher_is_better",
                  "max_speed": "higher_is_better"}
    return [
        {"name": f"mode_{expected_mode}/{name}", "group": f"mode_{expected_mode}",
         "value": value, "unit": units[name], "direction": directions[name]}
        for name, value in values.items()
    ]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--threads", type=int, required=True)
    parser.add_argument("--binary-sha256", required=True)
    args = parser.parse_args()
    if args.threads <= 0:
        parser.error("threads must be positive")
    results = {}
    for mode in (0, 1, 2):
        for metric in parse_mode(args.results_dir / f"benchmark_mode_{mode}.log", mode):
            name = metric.pop("name")
            if name in results:
                raise ValueError(f"duplicate benchmark metric: {name}")
            results[name] = metric
    output = {
        "parameters": {"threads": args.threads, "affinity": 0, "modes": [0, 1, 2]},
        "benchmark_binary_sha256": args.binary_sha256,
        "results": results,
    }
    (args.results_dir / "benchmark_jemalloc.json").write_text(
        json.dumps(output, indent=2, ensure_ascii=False) + "\n", encoding="utf-8"
    )


if __name__ == "__main__":
    main()
