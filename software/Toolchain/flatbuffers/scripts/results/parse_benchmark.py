#!/usr/bin/env python3
"""Normalize the raw FlatBuffers evidence into ``results.json``.

The script is intentionally strict: every scenario must have exactly
``--repetitions`` measured repetitions plus one warm-up, each with a timing JSON
and a captured log, every log must carry the fixed correctness markers of its
scenario, and every value must be finite and strictly positive.  A missing
sample is a hard failure (the caller turns it into test-stage exit code 50); no
value is invented, estimated or zero-padded.

Two families of evidence are handled:

* the case-owned multi-scale driver (``scripts/bench/driver.cpp``), which
  reports the number of elements, iterations and encoded bytes it actually
  processed together with the deterministic checksum; and
* the upstream benchmark object (``benchmarks/cpp/flatbuffers/fb_bench.cpp``),
  which the case runner drives in batches and which must report
  ``checksum_ok=1`` for every batch.
"""

from __future__ import annotations

import argparse
import json
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

MIB = 1024.0 * 1024.0

# scenario -> (task, mode, elements, iterations)
DRIVER_SCENARIOS: dict[str, tuple[str, str, int, int]] = {
    "builder_1k": ("builder_accessor", "build", 1000, 100000),
    "accessor_1k": ("builder_accessor", "access", 1000, 100000),
    "builder_accessor_1k": ("builder_accessor", "merged", 1000, 100000),
    "builder_accessor_10k": ("builder_accessor", "merged", 10000, 10000),
    "builder_accessor_100k": ("builder_accessor", "merged", 100000, 1000),
    "builder_accessor_1m": ("builder_accessor", "merged", 1000000, 100),
}
UPSTREAM_SCENARIO = "upstream_bench_encode_use"
UPSTREAM_TASK = "upstream_benchmark"
UPSTREAM_EXPECTED_CHECKSUM = -7035620705617902304
UPSTREAM_ITERATIONS = 10000

WALL_UNIT = "s"
RSS_UNIT = "MiB"
MBPS_UNIT = "MiB/s"
ELEM_UNIT = "elem/s"
ITER_UNIT = "iter/s"

LOWER = "lower_is_better"
HIGHER = "higher_is_better"


class EvidenceError(RuntimeError):
    """Raised when a raw evidence file is missing or inconsistent."""


def read_json(path: Path) -> dict:
    if not path.is_file():
        raise EvidenceError(f"missing timing JSON: {path}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise EvidenceError(f"invalid JSON in {path}: {exc}") from exc


def read_log(path: Path) -> str:
    if not path.is_file():
        raise EvidenceError(f"missing captured log: {path}")
    return path.read_text(encoding="utf-8", errors="replace")


def parse_fields(log_text: str, scenario: str) -> dict[str, str]:
    fields: dict[str, str] = {}
    for line in log_text.splitlines():
        if "[fb-bench]" not in line:
            continue
        for token in line.split():
            if "=" in token:
                key, value = token.split("=", 1)
                fields[key] = value
    if not fields:
        raise EvidenceError(f"{scenario}: log does not contain a [fb-bench] summary line")
    return fields


def positive_int(fields: dict[str, str], key: str, scenario: str) -> int:
    value = fields.get(key)
    if value is None:
        raise EvidenceError(f"{scenario}: summary line has no {key}")
    try:
        parsed = int(value)
    except ValueError as exc:
        raise EvidenceError(f"{scenario}: {key}={value!r} is not an integer") from exc
    if parsed <= 0:
        raise EvidenceError(f"{scenario}: {key}={parsed} is not positive")
    return parsed


def load_repetitions(runs_dir: Path, scenario: str, repetitions: int) -> tuple[list[dict], list[str]]:
    scenario_dir = runs_dir / scenario
    warmup_json = scenario_dir / "warmup.json"
    warmup_log = scenario_dir / "warmup.log"
    if not warmup_log.is_file():
        raise EvidenceError(f"{scenario}: missing warm-up log {warmup_log}")
    warmup_timing = read_json(warmup_json)
    if warmup_timing.get("exit_code") != 0:
        raise EvidenceError(
            f"{scenario}: warm-up exited with {warmup_timing.get('exit_code')}"
        )
    logs: list[str] = [warmup_log.read_text(encoding="utf-8", errors="replace")]
    samples: list[dict] = []
    for index in range(1, repetitions + 1):
        json_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        timing = read_json(json_path)
        log_text = read_log(log_path)
        logs.append(log_text)
        if timing.get("exit_code") != 0:
            raise EvidenceError(
                f"{scenario}: rep{index} exited with {timing.get('exit_code')}"
            )
        wall = timing.get("wall_seconds")
        rss = timing.get("max_rss_mib")
        if not isinstance(wall, (int, float)) or wall <= 0:
            raise EvidenceError(f"{scenario}: rep{index} has an invalid wall time: {wall!r}")
        if not isinstance(rss, (int, float)) or rss <= 0:
            raise EvidenceError(f"{scenario}: rep{index} has an invalid peak RSS: {rss!r}")
        samples.append(
            {
                "wall_seconds": float(wall),
                "max_rss_mib": float(rss),
                "log": log_text,
            }
        )
    return samples, logs


def median(values: list[float]) -> float:
    return float(statistics.median(values))


def metric(
    scenario: str, task: str, name: str, value: float, unit: str, direction: str, samples: list[float]
) -> dict:
    return {
        "scenario": scenario,
        "task": task,
        "source_name": name,
        "value": value,
        "unit": unit,
        "direction": direction,
        "samples": samples,
    }


def normalize(scenario: str, repetitions: int, runs_dir: Path, upstream_batches: int) -> tuple[dict, list[str]]:
    samples, logs = load_repetitions(runs_dir, scenario, repetitions)
    metrics: dict[str, dict] = {}
    if scenario == UPSTREAM_SCENARIO:
        fields = parse_fields(samples[0]["log"], scenario)
        if fields.get("mode") != "upstream":
            raise EvidenceError(f"{scenario}: summary mode is {fields.get('mode')!r}, expected 'upstream'")
        batches = positive_int(fields, "batches", scenario)
        iterations = positive_int(fields, "iterations", scenario)
        if batches != upstream_batches:
            raise EvidenceError(f"{scenario}: batches={batches}, expected {upstream_batches}")
        if iterations != UPSTREAM_ITERATIONS:
            raise EvidenceError(f"{scenario}: iterations={iterations}, expected {UPSTREAM_ITERATIONS}")
        if fields.get("checksum_ok") != "1":
            raise EvidenceError(f"{scenario}: checksum_ok is {fields.get('checksum_ok')!r}")
        pinned = int(fields.get("per_batch_checksum", "0"))
        if pinned != UPSTREAM_EXPECTED_CHECKSUM:
            raise EvidenceError(
                f"{scenario}: per_batch_checksum={pinned}, expected {UPSTREAM_EXPECTED_CHECKSUM}"
            )
        for index, sample in enumerate(samples, start=1):
            fields = parse_fields(sample["log"], scenario)
            if fields.get("checksum_ok") != "1":
                raise EvidenceError(f"{scenario}: rep{index} checksum_ok is {fields.get('checksum_ok')!r}")
            encoded = positive_int(fields, "encoded_bytes", scenario)
            sample["encoded_bytes"] = encoded
            sample["operation_count"] = batches * iterations
        walls = [s["wall_seconds"] for s in samples]
        rss = [s["max_rss_mib"] for s in samples]
        mbps = [s["encoded_bytes"] / s["wall_seconds"] / MIB for s in samples]
        iter_s = [s["operation_count"] / s["wall_seconds"] for s in samples]
        tasks = UPSTREAM_TASK
        metrics[scenario] = metric(scenario, tasks, scenario, median(walls), WALL_UNIT, LOWER, walls)
        metrics[f"{scenario}_rss"] = metric(scenario, tasks, f"{scenario}_rss", median(rss), RSS_UNIT, LOWER, rss)
        metrics[f"{scenario}_mbs"] = metric(scenario, tasks, f"{scenario}_mbs", median(mbps), MBPS_UNIT, HIGHER, mbps)
        metrics[f"{scenario}_iter_s"] = metric(
            scenario, tasks, f"{scenario}_iter_s", median(iter_s), ITER_UNIT, HIGHER, iter_s
        )
        return metrics, logs

    try:
        task, mode, elements, iterations = DRIVER_SCENARIOS[scenario]
    except KeyError as exc:
        raise EvidenceError(f"unknown scenario in runs directory: {scenario}") from exc
    expected_checksum = 0 if mode == "build" else elements * (elements - 1) // 2 * iterations
    for index, sample in enumerate(samples, start=1):
        fields = parse_fields(sample["log"], scenario)
        label = f"rep{index}"
        if fields.get("mode") != mode:
            raise EvidenceError(f"{scenario}: {label} mode is {fields.get('mode')!r}, expected {mode!r}")
        if int(fields.get("elements", "0")) != elements:
            raise EvidenceError(f"{scenario}: {label} elements is {fields.get('elements')!r}, expected {elements}")
        if int(fields.get("iterations", "0")) != iterations:
            raise EvidenceError(
                f"{scenario}: {label} iterations is {fields.get('iterations')!r}, expected {iterations}"
            )
        if int(fields.get("expected", "0")) != expected_checksum:
            raise EvidenceError(
                f"{scenario}: {label} expected checksum is {fields.get('expected')!r}, expected {expected_checksum}"
            )
        if int(fields.get("checksum", "0")) != expected_checksum:
            raise EvidenceError(
                f"{scenario}: {label} checksum is {fields.get('checksum')!r}, expected {expected_checksum}"
            )
        encoded = positive_int(fields, "encoded_bytes", scenario)
        sample["encoded_bytes"] = encoded
        sample["operation_count"] = elements * iterations
    walls = [s["wall_seconds"] for s in samples]
    rss = [s["max_rss_mib"] for s in samples]
    mbps = [s["encoded_bytes"] / s["wall_seconds"] / MIB for s in samples]
    elem_s = [s["operation_count"] / s["wall_seconds"] for s in samples]
    metrics[scenario] = metric(scenario, task, scenario, median(walls), WALL_UNIT, LOWER, walls)
    metrics[f"{scenario}_rss"] = metric(scenario, task, f"{scenario}_rss", median(rss), RSS_UNIT, LOWER, rss)
    metrics[f"{scenario}_mbs"] = metric(scenario, task, f"{scenario}_mbs", median(mbps), MBPS_UNIT, HIGHER, mbps)
    metrics[f"{scenario}_elem_s"] = metric(
        scenario, task, f"{scenario}_elem_s", median(elem_s), ELEM_UNIT, HIGHER, elem_s
    )
    return metrics, logs


def build_payload(
    runs_dir: Path,
    repetitions: int,
    upstream_batches: int,
    actual_version: str,
) -> tuple[dict, list[str]]:
    expected = sorted(list(DRIVER_SCENARIOS) + [UPSTREAM_SCENARIO])
    present = sorted(p.name for p in runs_dir.iterdir() if p.is_dir()) if runs_dir.is_dir() else []
    missing = [name for name in expected if name not in present]
    if missing:
        raise EvidenceError(f"scenario directories missing from {runs_dir}: {missing}")
    unexpected = [name for name in present if name not in expected]
    if unexpected:
        raise EvidenceError(f"unexpected scenario directories in {runs_dir}: {unexpected}")

    results: dict[str, dict] = {}
    logs: list[str] = []
    scenarios: dict[str, dict] = {}
    for scenario in expected:
        metrics, scenario_logs = normalize(scenario, repetitions, runs_dir, upstream_batches)
        results.update(metrics)
        logs.extend(scenario_logs)
        if scenario == UPSTREAM_SCENARIO:
            scenarios[scenario] = {
                "task": UPSTREAM_TASK,
                "batches": upstream_batches,
                "iterations": UPSTREAM_ITERATIONS,
                "expected_checksum": UPSTREAM_EXPECTED_CHECKSUM,
                "repetitions": repetitions,
            }
        else:
            task, mode, elements, iterations = DRIVER_SCENARIOS[scenario]
            scenarios[scenario] = {
                "task": task,
                "mode": mode,
                "elements": elements,
                "iterations": iterations,
                "expected_checksum": 0 if mode == "build" else elements * (elements - 1) // 2 * iterations,
                "repetitions": repetitions,
            }

    payload = {
        "software": "flatbuffers",
        "version": actual_version,
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "repetitions": repetitions,
            "warmups": 1,
            "offline": False,
            "upstream_batches": upstream_batches,
            "upstream_iterations": UPSTREAM_ITERATIONS,
            "scenarios": scenarios,
        },
        "results": results,
    }
    return payload, logs


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--raw-output", required=True, type=Path)
    parser.add_argument("--actual-version-file", required=True, type=Path)
    parser.add_argument("--repetitions", required=True, type=int)
    parser.add_argument("--upstream-batches", required=True, type=int)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        if not args.actual_version_file.is_file():
            raise EvidenceError(f"missing actual-version file: {args.actual_version_file}")
        actual_version = args.actual_version_file.read_text(encoding="utf-8").strip()
        if not actual_version:
            raise EvidenceError("actual-version file is empty")
        payload, logs = build_payload(
            args.runs_dir, args.repetitions, args.upstream_batches, actual_version
        )
    except EvidenceError as exc:
        print(f"[flatbuffers-parse] ERROR: {exc}", file=sys.stderr, flush=True)
        return 50

    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(f".{args.output.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(args.output)

    args.raw_output.parent.mkdir(parents=True, exist_ok=True)
    args.raw_output.write_text("\n".join(logs) + "\n", encoding="utf-8")

    print(
        f"[flatbuffers-parse] normalized {len(payload['results'])} metrics across "
        f"{len(payload['parameters']['scenarios'])} scenarios",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
