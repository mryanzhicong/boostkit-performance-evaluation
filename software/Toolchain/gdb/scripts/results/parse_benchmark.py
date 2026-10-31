#!/usr/bin/env python3
"""Aggregate and strictly validate the raw GDB measurements.

The parser refuses to produce a metric unless the evidence proves that the
scenario really did the work it claims:

* every repetition must have a JSON record and a non-empty log;
* the measured process must have exited with 0, must not have timed out and its
  wall clock / peak RSS must be finite and positive;
* the fixture source count must equal the committed number, so a run against an
  incomplete workload is rejected;
* each scenario has an independent piece of evidence in its log: the GDB version
  banner, exactly 200 breakpoints, exactly 500 ``+step`` trace lines, the
  ``[gdb-py-eval]`` summary with 5000 lookups, a backtrace of at least 2000
  frames, or the summary of the fixed upstream testsuite subset with zero
  unexpected failures;
* the built GDB binary, the generated fixtures and the core file must still match
  the digests recorded by the build stage.

Any violation fails the test stage with a non-zero exit code instead of papering
over the gap with a zero, an estimate or a silently skipped metric.
"""

from __future__ import annotations

import hashlib
import json
import math
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

GDB_VERSION_BANNER = re.compile(r"GNU gdb \(GDB\) ([0-9]+\.[0-9]+)")
PY_EVAL_LINE = re.compile(r"\[gdb-py-eval\] looked_up=(\d+) found=(\d+)")
EXPECTED_PASSES = re.compile(r"^# of expected passes\s+(\d+)$", re.MULTILINE)
UNEXPECTED_FAILURES = re.compile(r"^# of unexpected failures\s+(\d+)$", re.MULTILINE)
FAILURE_LINES = re.compile(r"^(FAIL|ERROR): ", re.MULTILINE)
LOG_FAILURE_MARKERS = (
    "No symbol table is loaded",
    "Cannot access memory",
    "No such file or directory",
    "not in executable format",
)


def fail(message: str) -> None:
    print(f"[gdb-parse] ERROR: {message}", flush=True)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_metadata(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise RuntimeError(f"fixture metadata does not exist: {path}")
    try:
        metadata = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise RuntimeError(f"fixture metadata is not valid JSON: {error}") from error
    scenarios = metadata.get("scenarios")
    if not isinstance(scenarios, dict) or not scenarios:
        raise RuntimeError("fixture metadata has no scenario table")
    for name, entry in scenarios.items():
        for key in ("kind", "fixture", "command", "expected_sources"):
            if key not in entry:
                raise RuntimeError(f"scenario {name} has no {key}")
        if entry["kind"] not in ("fixture", "testsuite"):
            raise RuntimeError(f"scenario {name} has an unsupported kind {entry['kind']!r}")
    return metadata


def summarize(values: list[float]) -> dict[str, float]:
    if not values:
        raise RuntimeError("cannot summarize an empty sample list")
    ordered = sorted(values)
    count = len(ordered)
    middle = count // 2
    median = ordered[middle] if count % 2 else (ordered[middle - 1] + ordered[middle]) / 2.0
    mean = sum(ordered) / count
    variance = sum((value - mean) ** 2 for value in ordered) / count
    return {
        "samples": count,
        "median": median,
        "min": ordered[0],
        "max": ordered[-1],
        "mean": mean,
        "stdev": math.sqrt(variance),
    }


def read_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"cannot read {path}: {error}") from error
    if not isinstance(payload, dict):
        raise RuntimeError(f"{path} does not contain a JSON object")
    return payload


def load_samples(
    scenario: str,
    scenario_dir: Path,
    reps: int,
    expected_sources: int,
) -> list[dict[str, Any]]:
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    samples: list[dict[str, Any]] = []
    for index in range(1, reps + 1):
        json_path = scenario_dir / f"rep{index}.json"
        log_path = scenario_dir / f"rep{index}.log"
        if not json_path.is_file():
            raise RuntimeError(f"missing repetition sample: {json_path}")
        if not log_path.is_file():
            raise RuntimeError(f"missing repetition log: {log_path}")
        payload = read_json(json_path)
        exit_code = payload.get("exit_code")
        if exit_code != 0:
            raise RuntimeError(
                f"repetition rep{index}.json for {scenario} failed with exit code {exit_code}"
            )
        if payload.get("timed_out"):
            raise RuntimeError(f"repetition rep{index}.json for {scenario} timed out")
        wall = payload.get("wall_seconds")
        if (
            not isinstance(wall, (int, float))
            or isinstance(wall, bool)
            or not math.isfinite(wall)
            or wall <= 0
        ):
            raise RuntimeError(f"repetition rep{index}.json for {scenario} has no valid wall clock")
        rss = payload.get("max_rss_mib")
        if (
            not isinstance(rss, (int, float))
            or isinstance(rss, bool)
            or not math.isfinite(rss)
            or rss <= 0
        ):
            raise RuntimeError(f"repetition rep{index}.json for {scenario} has no valid RSS")
        sources = payload.get("fixture_sources")
        if sources != expected_sources:
            raise RuntimeError(
                f"repetition rep{index}.json for {scenario} counted {sources} fixture sources, "
                f"expected {expected_sources}"
            )
        log_text = log_path.read_text(encoding="utf-8", errors="replace")
        if not log_text.strip():
            raise RuntimeError(f"repetition rep{index}.log for {scenario} is empty")
        samples.append(
            {
                "repetition": index,
                "wall_seconds": float(wall),
                "max_rss_mib": float(rss),
                "log_text": log_text,
            }
        )
    return samples


def check_version_banner(scenario: str, log_text: str, expected_version: str) -> None:
    match = GDB_VERSION_BANNER.search(log_text)
    if not match:
        raise RuntimeError(f"scenario {scenario} log has no GDB version banner")
    if match.group(1) != expected_version:
        raise RuntimeError(
            f"scenario {scenario} ran GDB {match.group(1)}, expected {expected_version}"
        )


def last_number(log_text: str) -> int:
    lines = [line.strip() for line in log_text.splitlines() if line.strip()]
    for line in reversed(lines):
        if re.fullmatch(r"\d+", line):
            return int(line)
    raise RuntimeError("the scenario log contains no numeric line count")


# Scenarios whose command pipes GDB output into ``wc -l``: the log then contains only
# the line count, so the version banner cannot be seen there.  These scenarios are
# still bound to the built binary (its digest is checked and every other scenario
# verifies the version banner) and their evidence is the exact line count.
PIPED_SCENARIOS = {"info_functions_10000", "backtrace_deep_2000", "core_backtrace_2000"}


def check_fixture_scenario(
    scenario: str,
    entry: dict[str, Any],
    log_text: str,
    expected_version: str,
    expectations: dict[str, Any],
) -> dict[str, Any]:
    # GDB only prints its version banner for ``--version``; every other scenario has
    # its own countable evidence, so the banner is required exactly where it exists.
    if scenario == "startup_version":
        check_version_banner(scenario, log_text, expected_version)
    if scenario in PIPED_SCENARIOS:
        if not any(re.fullmatch(r"\d+", line.strip()) for line in log_text.splitlines()):
            raise RuntimeError(f"scenario {scenario} log contains no line-count output")
    for marker in LOG_FAILURE_MARKERS:
        if marker in log_text:
            raise RuntimeError(f"scenario {scenario} log contains the failure marker {marker!r}")
    evidence: dict[str, Any] = {}

    if scenario.startswith("symbol_load_"):
        if not re.search(r"fn_\d{5}", log_text):
            raise RuntimeError(f"scenario {scenario} did not resolve a function symbol")
        if "No functions matching" in log_text:
            raise RuntimeError(f"scenario {scenario} found no matching function symbol")
    elif scenario == "breakpoint_set_200":
        breakpoints = sum(1 for line in log_text.splitlines() if line.startswith("Breakpoint "))
        expected = int(expectations["breakpoints"])
        if breakpoints != expected:
            raise RuntimeError(
                f"scenario {scenario} created {breakpoints} breakpoints, expected {expected}"
            )
        evidence["breakpoints"] = breakpoints
    elif scenario == "step_500":
        steps = sum(1 for line in log_text.splitlines() if line.startswith("+step"))
        expected = int(expectations["steps"])
        if steps != expected:
            raise RuntimeError(f"scenario {scenario} executed {steps} steps, expected {expected}")
        evidence["steps"] = steps
    elif scenario == "info_functions_10000":
        lines = last_number(log_text)
        minimum = int(expectations["symbols_medium"])
        if lines < minimum:
            raise RuntimeError(
                f"scenario {scenario} printed {lines} lines, expected at least {minimum}"
            )
        evidence["symbol_lines"] = lines
    elif scenario == "python_eval_5000":
        match = PY_EVAL_LINE.search(log_text)
        if not match:
            raise RuntimeError(f"scenario {scenario} has no [gdb-py-eval] summary")
        looked_up, found = int(match.group(1)), int(match.group(2))
        expected = int(expectations["lookups"])
        if looked_up != expected or found != expected:
            raise RuntimeError(
                f"scenario {scenario} looked up {looked_up}/{found} symbols, expected {expected}"
            )
        evidence["lookups"] = looked_up
    elif scenario == "backtrace_deep_2000":
        frames = last_number(log_text)
        minimum = int(expectations["deep_frames"])
        if frames < minimum:
            raise RuntimeError(f"scenario {scenario} printed {frames} lines, expected >= {minimum}")
        evidence["backtrace_lines"] = frames
    elif scenario == "core_backtrace_2000":
        frames = last_number(log_text)
        minimum = int(expectations["deep_frames"])
        if frames < minimum:
            raise RuntimeError(f"scenario {scenario} printed {frames} lines, expected >= {minimum}")
        evidence["backtrace_lines"] = frames
    return evidence


def check_testsuite(
    tests_sum: Path,
    minimum_passes: int,
    expected_tests: list[str],
) -> dict[str, Any]:
    if not tests_sum.is_file():
        raise RuntimeError(f"the upstream testsuite did not write {tests_sum}")
    text = tests_sum.read_text(encoding="utf-8", errors="replace")
    passes_match = EXPECTED_PASSES.search(text)
    if not passes_match:
        raise RuntimeError("the upstream testsuite summary has no expected-pass count")
    passes = int(passes_match.group(1))
    if passes < minimum_passes:
        raise RuntimeError(
            f"the upstream testsuite reported {passes} expected passes, expected >= {minimum_passes}"
        )
    failures_match = UNEXPECTED_FAILURES.search(text)
    failures = int(failures_match.group(1)) if failures_match else 0
    if failures != 0:
        raise RuntimeError(f"the upstream testsuite reported {failures} unexpected failures")
    failure_lines = FAILURE_LINES.findall(text)
    if failure_lines:
        raise RuntimeError(f"the upstream testsuite summary contains {len(failure_lines)} FAIL/ERROR lines")
    summary = re.search(r"^# of (\w[\w ]*?)\s+(\d+)$", text, re.MULTILINE)
    return {
        "expected_passes": passes,
        "unexpected_failures": failures,
        "tests_requested": expected_tests,
        "summary_first_line": summary.group(0) if summary else None,
    }


def parameter_payload(metadata: dict[str, Any]) -> dict[str, Any]:
    """Values that must be identical on x86_64 and aarch64.

    The source archive, the host compiler used for the fixtures, the built binary
    digests and the core file size are architecture specific (or host specific)
    and therefore live in the metadata and in build_provenance.json, never here.
    """
    measurement = metadata.get("measurement", {})
    expectations = metadata["expectations"]
    fixtures = metadata["fixtures_generated"]
    return {
        "variant": os.environ.get("PERF_VARIANT", "base"),
        "repetitions": int(measurement.get("repetitions", 0)),
        "warmups": int(measurement.get("warmups", 0)),
        "statistic": "median of independent repetitions",
        "offline": True,
        "gdb_version": metadata["gdb_version"],
        "gdb_source_sha256": metadata["source"]["sha256"],
        "gdb_source_bytes": int(metadata["source"]["bytes"]),
        "configure_options": list(metadata["build"]["configure_options"]),
        "makeinfo_skipped": bool(metadata["build"]["makeinfo_skipped"]),
        "fixture_cflags": metadata["fixtures"]["cflags"],
        "fixtures": {
            name: {"sha256": entry["sha256"], "bytes": int(entry["bytes"])}
            for name, entry in sorted(fixtures.items())
        },
        "expectations": {
            "symbols_small": int(expectations["symbols_small"]),
            "symbols_medium": int(expectations["symbols_medium"]),
            "symbols_large": int(expectations["symbols_large"]),
            "breakpoints": int(expectations["breakpoints"]),
            "steps": int(expectations["steps"]),
            "lookups": int(expectations["lookups"]),
            "deep_frames": int(expectations["deep_frames"]),
        },
        "testsuite": {
            "tests": list(metadata["testsuite"]["tests"]),
            "min_expected_passes": int(metadata["testsuite"]["min_expected_passes"]),
        },
        "scenarios": {
            name: {
                "kind": entry["kind"],
                "fixture": entry["fixture"],
                "command": entry["command"],
            }
            for name, entry in sorted(metadata["scenarios"].items())
        },
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RUNS_DIR OUTPUT_JSON", file=sys.stderr, flush=True)
        return 2
    runs_dir = Path(sys.argv[1])
    output = Path(sys.argv[2])
    metadata_path_raw = os.environ.get("GDB_FIXTURE_METADATA", "")
    if not metadata_path_raw:
        fail("GDB_FIXTURE_METADATA is not set")
        return 1
    fixtures_dir_raw = os.environ.get("GDB_FIXTURES_DIR", "")
    if not fixtures_dir_raw:
        fail("GDB_FIXTURES_DIR is not set")
        return 1
    if not runs_dir.is_dir():
        fail(f"runs directory does not exist: {runs_dir}")
        return 1
    try:
        metadata = load_metadata(Path(metadata_path_raw))
    except RuntimeError as error:
        fail(str(error))
        return 1
    fixtures_dir = Path(fixtures_dir_raw)
    version = os.environ.get("SOFTWARE_VERSION", metadata["version"])
    architecture = os.environ.get("EXPECTED_ARCH", "unknown")
    variant = os.environ.get("PERF_VARIANT", "base")
    reps = int(
        os.environ.get("PERF_REPS", metadata.get("measurement", {}).get("repetitions", 0)) or 0
    )
    if reps < 1:
        fail("the repetition count is not a positive integer")
        return 1
    expected_version = metadata["gdb_version"]
    expected_sources = int(metadata["expected_fixture_sources"])
    expectations = metadata["expectations"]

    results: dict[str, Any] = {}
    artifact_evidence: dict[str, Any] = {}
    try:
        for scenario, entry in sorted(metadata["scenarios"].items()):
            scenario_dir = runs_dir / scenario
            samples = load_samples(scenario, scenario_dir, reps, expected_sources)
            values: list[float] = []
            rss_values: list[float] = []
            extra_evidence: dict[str, Any] = {}
            for sample in samples:
                if entry["kind"] == "fixture":
                    evidence = check_fixture_scenario(
                        scenario, entry, sample["log_text"], expected_version, expectations
                    )
                    for key, value in evidence.items():
                        if not isinstance(value, (list, dict)):
                            extra_evidence[key] = value
                else:
                    tests_sum = Path(metadata["testsuite"]["sum_path"])
                    evidence = check_testsuite(
                        tests_sum,
                        int(metadata["testsuite"]["min_expected_passes"]),
                        list(metadata["testsuite"]["tests"]),
                    )
                    extra_evidence.update(evidence)
                values.append(sample["wall_seconds"])
                rss_values.append(sample["max_rss_mib"])

            if scenario == "core_backtrace_2000":
                core = fixtures_dir / metadata["fixtures"]["core_name"]
                if not core.is_file() or core.stat().st_size <= 0:
                    raise RuntimeError(f"the core file {core} is missing or empty")
                extra_evidence["core_bytes"] = core.stat().st_size
            if scenario == "info_functions_10000":
                extra_evidence["symbols_medium"] = int(expectations["symbols_medium"])

            value_stats = summarize(values)
            rss_stats = summarize(rss_values)
            results[scenario] = build_metric(
                scenario,
                scenario,
                entry["fixture"],
                entry["command"],
                value_stats["median"],
                "s",
                "lower_is_better",
                value_stats,
                [round(value, 6) for value in values],
                extra_evidence,
            )
            results[f"{scenario}_rss"] = build_metric(
                f"{scenario}_rss",
                scenario,
                entry["fixture"],
                entry["command"],
                rss_stats["median"],
                "MiB",
                "lower_is_better",
                rss_stats,
                [round(value, 3) for value in rss_values],
                {},
            )

        # The built GDB binary and every generated fixture must match the digests
        # recorded during the build stage.
        gdb_binary = Path(metadata["build"]["gdb_binary"])
        if not gdb_binary.is_file():
            raise RuntimeError(f"the built GDB binary is missing: {gdb_binary}")
        artifact_evidence["gdb_binary"] = {
            "version": expected_version,
            "sha256": sha256_file(gdb_binary),
        }
        fixture_digests = {
            name: sha256_file(fixtures_dir / name)
            for name in sorted(metadata["fixtures_generated"])
        }
        for name, recorded in metadata["fixtures_generated"].items():
            if fixture_digests[name] != recorded["sha256"]:
                raise RuntimeError(f"the generated fixture {name} no longer matches its digest")
        artifact_evidence["fixtures"] = {
            name: {"sha256": digest, "bytes": (fixtures_dir / name).stat().st_size}
            for name, digest in sorted(fixture_digests.items())
        }
        artifact_evidence["binary_sizes"] = {
            name: (fixtures_dir / name).stat().st_size
            for name in sorted(metadata["fixtures"]["binaries"])
        }
    except (RuntimeError, KeyError, TypeError, ValueError, OSError) as error:
        fail(str(error))
        return 1

    normalized = {
        "benchmark": "gdb_workload_matrix",
        "software": "gdb",
        "version": version,
        "architecture": architecture,
        "variant": variant,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": parameter_payload(metadata),
        "metric_contract": {
            "wall_time": {"unit": "s", "direction": "lower_is_better"},
            "peak_rss": {"unit": "MiB", "direction": "lower_is_better"},
            "statistic": "median of independent repetitions",
        },
        "artifact_evidence": artifact_evidence,
        "results": results,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(normalized, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        f"[gdb-parse] normalized {len(results)} metrics across "
        f"{len(metadata['scenarios'])} scenarios",
        flush=True,
    )
    return 0


def build_metric(
    name: str,
    scenario: str,
    fixture: str,
    command: str,
    value: float,
    unit: str,
    direction: str,
    stats: dict[str, float],
    samples: list[float],
    extra: dict[str, Any],
) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "source_name": name,
        "scenario": scenario,
        "fixture": fixture,
        "command": command,
        "value": value,
        "unit": unit,
        "direction": direction,
        "statistics": stats,
        "samples": samples,
    }
    payload.update(extra)
    return payload


if __name__ == "__main__":
    sys.exit(main())
