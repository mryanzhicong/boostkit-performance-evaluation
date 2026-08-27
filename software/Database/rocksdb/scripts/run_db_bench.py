#!/usr/bin/env python3
"""Run the portable open-source equivalent of database_blue RocksDB cases."""

from __future__ import annotations

import json
import math
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


RESULT_LINE = re.compile(
    r"(?m)^(fillseq|overwrite|readrandom|readrandomwriterandom)\s*:\s*"
    r"([0-9]+(?:\.[0-9]+)?)\s+micros/op\s+"
    r"([0-9]+(?:\.[0-9]+)?)\s+ops/sec"
)
METRICS = (
    ("micros/op", "micros/op", "lower_is_better"),
    ("ops/sec", "ops/sec", "higher_is_better"),
)
FORMAL_WORKLOADS = ("overwrite", "readrandom", "readrandomwriterandom")


@dataclass(frozen=True)
class Profile:
    key_size: int
    value_size: int

    @property
    def name(self) -> str:
        return f"{self.key_size}B key / {self.value_size}B value"

    @property
    def directory_name(self) -> str:
        return f"key-{self.key_size}B-value-{self.value_size}B"


def required_positive_integer(name: str) -> int:
    value = os.environ.get(name, "")
    try:
        parsed = int(value)
    except ValueError as error:
        raise RuntimeError(f"{name} must be a positive integer, got {value!r}") from error
    if parsed <= 0:
        raise RuntimeError(f"{name} must be a positive integer, got {value!r}")
    return parsed


def parse_profiles() -> tuple[Profile, ...]:
    raw_profiles = os.environ.get("ROCKSDB_BENCH_PROFILES", "")
    profiles: list[Profile] = []
    for raw_profile in raw_profiles.split(","):
        key_size, separator, value_size = raw_profile.strip().partition(":")
        if not separator:
            raise RuntimeError(
                "ROCKSDB_BENCH_PROFILES must use KEY_SIZE:VALUE_SIZE entries separated by commas"
            )
        try:
            profile = Profile(int(key_size), int(value_size))
        except ValueError as error:
            raise RuntimeError(f"invalid RocksDB KV profile: {raw_profile!r}") from error
        if profile.key_size <= 0 or profile.value_size <= 0:
            raise RuntimeError(f"invalid RocksDB KV profile: {raw_profile!r}")
        profiles.append(profile)
    if not profiles or len(set(profiles)) != len(profiles):
        raise RuntimeError("ROCKSDB_BENCH_PROFILES must contain non-duplicate profiles")
    return tuple(profiles)


def build_command(
    binary: Path,
    database: Path,
    report_file: Path,
    workload: str,
    profile: Profile,
    threads: int,
    duration: int,
    number: int,
    readwrite_percent: int,
    cache_size: int,
) -> list[str]:
    """Build database_blue's documented open-source db_bench command shape."""
    arguments = [
        str(binary),
        f"--db={database}",
        f"--wal_dir={database}",
        f"--benchmarks={workload},stats",
        "--statistics=1",
        "--histogram=1",
        "--perf_level=5",
        f"--num={number}",
        f"--key_size={profile.key_size}",
        f"--value_size={profile.value_size}",
        f"--threads={threads}",
        "--initial_auto_readahead_size=16384",
        "--max_auto_readahead_size=65536",
        "--block_size=32768",
        "--level0_file_num_compaction_trigger=2",
        "--compaction_readahead_size=524288",
        "--level0_slowdown_writes_trigger=36",
        "--level0_stop_writes_trigger=48",
        "--write_buffer_size=134217728",
        "--target_file_size_base=134217728",
        "--max_bytes_for_level_base=536870912",
        "--use_direct_reads=true",
        "--use_direct_writes=true",
        "--bloom_bits=10",
        "--compression_type=none",
        "--batch_size=32",
        "--stats_interval_seconds=1",
        "--stats_per_interval=1",
        "--report_interval_seconds=1",
        f"--report_file={report_file}",
        f"--use_existing_db={str(workload != 'fillseq').lower()}",
        f"--duration={duration}",
        "--use_direct_io_for_flush_and_compaction=true",
        "--max_background_flushes=1",
        "--max_background_compactions=2",
        "--pin_l0_filter_and_index_blocks_in_cache=true",
        "--cache_index_and_filter_blocks=true",
        f"--cache_size={cache_size}",
        "--sync=false",
    ]
    if workload == "readrandomwriterandom":
        arguments.append(f"--readwritepercent={readwrite_percent}")
    return arguments


def parse_result(output: str, workload: str) -> dict[str, float]:
    matches = [match for match in RESULT_LINE.finditer(output) if match.group(1) == workload]
    if len(matches) != 1:
        raise RuntimeError(
            f"db_bench {workload} must produce exactly one result line, found {len(matches)}"
        )
    result = {"micros/op": float(matches[0].group(2)), "ops/sec": float(matches[0].group(3))}
    if any(not math.isfinite(value) or value <= 0 for value in result.values()):
        raise RuntimeError(f"db_bench {workload} produced an invalid metric")
    return result


def run_command(command: list[str], raw_log: object, description: str) -> str:
    command_text = " ".join(command)
    print(f"[rocksdb-benchmark] {description}", flush=True)
    print(f"[rocksdb-benchmark] {command_text}", flush=True)
    raw_log.write(f"$ {command_text}\n")
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=129_600,
        check=False,
    )
    raw_log.write(completed.stdout + "\n")
    raw_log.flush()
    print(completed.stdout, end="", flush=True)
    if completed.returncode:
        raise RuntimeError(f"{description} exited with code {completed.returncode}")
    return completed.stdout


def add_metrics(
    results: dict[str, dict[str, object]],
    group: str,
    scenario: str,
    values: dict[str, float],
) -> None:
    for field, unit, direction in METRICS:
        name = f"{group}: {scenario} {field}"
        if name in results:
            raise RuntimeError(f"duplicate normalized metric: {name}")
        results[name] = {
            "source_name": name,
            "source_field": field,
            "group": group,
            "value": values[field],
            "unit": unit,
            "direction": direction,
        }


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: run_db_bench.py DB_BENCH RESULTS RAW_LOG", file=sys.stderr)
        return 2
    binary, results_path, raw_path = map(Path, sys.argv[1:])
    database_root = Path(os.environ["ROCKSDB_BENCH_DATA_DIR"])
    profiles = parse_profiles()
    number = required_positive_integer("ROCKSDB_BENCH_NUM")
    duration = required_positive_integer("ROCKSDB_BENCH_DURATION_SECONDS")
    readwrite_percent = required_positive_integer("ROCKSDB_BENCH_READWRITE_PERCENT")
    cache_size = required_positive_integer("ROCKSDB_BENCH_CACHE_SIZE_BYTES")
    if not binary.is_file() or not os.access(binary, os.X_OK):
        raise RuntimeError(f"db_bench executable is unavailable: {binary}")
    if not 0 < readwrite_percent < 100:
        raise RuntimeError("ROCKSDB_BENCH_READWRITE_PERCENT must be between 1 and 99")

    raw_path.parent.mkdir(parents=True, exist_ok=True)
    results: dict[str, dict[str, object]] = {}
    with raw_path.open("w", encoding="utf-8") as raw_log:
        for profile in profiles:
            profile_directory = database_root / profile.directory_name
            shutil.rmtree(profile_directory, ignore_errors=True)
            profile_directory.mkdir(parents=True, exist_ok=True)
            report_file = profile_directory / "db_bench_qps.log"

            fillseq = build_command(
                binary, profile_directory, report_file, "fillseq", profile, 1, 0,
                number, readwrite_percent, cache_size,
            )
            fillseq_output = run_command(fillseq, raw_log, f"{profile.name}: pre_fillseq")
            add_metrics(results, profile.name, "pre_fillseq 1 threads", parse_result(fillseq_output, "fillseq"))

            pre_overwrite = build_command(
                binary, profile_directory, report_file, "overwrite", profile, 1, 0,
                number, readwrite_percent, cache_size,
            )
            pre_overwrite_output = run_command(
                pre_overwrite, raw_log, f"{profile.name}: pre_overwrite"
            )
            add_metrics(
                results, profile.name, "pre_overwrite 1 threads",
                parse_result(pre_overwrite_output, "overwrite"),
            )

            for workload in FORMAL_WORKLOADS:
                for threads in (1, 16):
                    command = build_command(
                        binary, profile_directory, report_file, workload, profile, threads, duration,
                        number, readwrite_percent, cache_size,
                    )
                    scenario = f"{workload} {threads} threads"
                    output = run_command(command, raw_log, f"{profile.name}: {scenario}")
                    add_metrics(results, profile.name, scenario, parse_result(output, workload))
            shutil.rmtree(profile_directory)

    expected_metric_count = len(profiles) * 8 * len(METRICS)
    if len(results) != expected_metric_count:
        raise RuntimeError(
            f"database_blue scenario set is incomplete: expected {expected_metric_count} metrics, got {len(results)}"
        )
    payload = {
        "benchmark": "rocksdb_db_bench_database_blue_open_source_baseline",
        "software": "rocksdb",
        "version": os.environ["SOFTWARE_VERSION"],
        "architecture": os.environ["EXPECTED_ARCH"],
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "profiles": [profile.name for profile in profiles],
            "num": number,
            "duration_seconds": duration,
            "readwrite_percent": readwrite_percent,
            "cache_size_bytes": cache_size,
            "compression_type": "none",
            "use_direct_reads": True,
            "use_direct_writes": True,
            "use_direct_io_for_flush_and_compaction": True,
        },
        "results": results,
    }
    results_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"[rocksdb-benchmark] normalized {len(results)} database_blue baseline metrics", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
