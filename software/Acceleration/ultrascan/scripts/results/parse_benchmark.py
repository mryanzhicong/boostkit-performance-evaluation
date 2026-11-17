#!/usr/bin/env python3
"""Measure and normalize the Ultrascan hsbench block-mode matrix.

The case keeps the two documented reference scenarios and adds the seven
rule/corpus combinations from the 2026-11-16 data set::

    hsbench -e <dataset>/<rule> -c <dataset>/<corpus> -N -n <iterations> \
            [-G <greybox overrides>]

``drive``
    Container-side timing driver.  It runs one warm-up plus every declared
    repetition of each scenario, records the raw hsbench stdout, wall time and
    peak RSS, and refuses to continue after the first failed sample.

``report``
    Host-side strict parser.  It validates the recorded runs against the
    dataset manifest (rule expression count, corpus bytes/blocks), checks that
    repetitions agree on every invariant, and writes one metric per scenario:
    the ``Mean throughput (overall)`` value in Mbit/s.

The parser never pads missing samples and never falls back to a synthetic
corpus.  A missing sample, extra sample, non-zero exit, timeout, changed corpus
or an inconsistent match count fails the test stage (exit code 50).
"""

from __future__ import annotations

import argparse
import json
import math
import os
import re
import shutil
import statistics
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

HSBENCH_INFO_RE = re.compile(
    r"^Hyperscan info:\s+Version:\s+(\S+)"
    r"(?:\s+Features:.*?)?\s+Mode:\s+(BLOCK|STREAM|VECTORED)\s*$",
    re.MULTILINE,
)
EXPRESSION_RE = re.compile(r"^Expression count:\s+([0-9]+)\s*$", re.MULTILINE)
BYTECODE_RE = re.compile(r"^Bytecode size:\s+([0-9]+) bytes\s*$", re.MULTILINE)
COMPILE_RE = re.compile(r"^Compile time:\s+([0-9.]+) seconds\s*$", re.MULTILINE)
CORPUS_RE = re.compile(
    r"^Corpus size:\s+([0-9]+) bytes \(([0-9]+) blocks\)\s*$", re.MULTILINE
)
MATCHES_RE = re.compile(
    r"^Matches per iteration:\s+([0-9]+) \(([0-9.]+) matches/kilobyte\)\s*$",
    re.MULTILINE,
)
MEAN_TPUT_RE = re.compile(
    r"^Mean throughput \(overall\):\s+([0-9.]+) Mbit/sec\s*$", re.MULTILINE
)
MAX_TPUT_RE = re.compile(
    r"^Max throughput \(per core\):\s+([0-9.]+) Mbit/sec\s*$", re.MULTILINE
)
FAT_LOAD_RE = re.compile(r"^Loading FAT database from:\s+(\S.*)$", re.MULTILINE)
RSS_RE = re.compile(r"Maximum resident set size \(kbytes\):\s*([0-9]+)")

CASE_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SCENARIOS = CASE_ROOT / "benchmark" / "scenarios.json"
MEASUREMENT_TIMEOUT = int(os.environ.get("PERF_ULTRASCAN_MEASUREMENT_TIMEOUT", "3600"))
GROUP = "hsbench"
METRIC_SUFFIX = "mean_throughput_mbit_s"
METRIC_UNIT = "Mbit/s"
ARCHITECTURES = {"x86_64", "aarch64"}


def fail(message: str) -> None:
    print(f"[ultrascan-parse] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def utc_timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except OSError as error:
        raise RuntimeError(f"cannot read {path}: {error}") from error
    except json.JSONDecodeError as error:
        raise RuntimeError(f"invalid JSON in {path}: {error}") from error


def hsbench_environment() -> dict[str, str]:
    environment = dict(os.environ)
    environment.update({"LC_ALL": "C", "LANG": "C", "TZ": "UTC"})
    return environment


# ---------------------------------------------------------------------------
# Scenario and dataset metadata
# ---------------------------------------------------------------------------
def load_scenarios(path: Path) -> list[dict[str, Any]]:
    payload = load_json(path)
    groups = []
    for group in ("legacy", "matrix"):
        entries = payload.get(group)
        if not isinstance(entries, list):
            raise RuntimeError(f"{path}: '{group}' must be a list")
        groups.extend(entries)
    scenarios: list[dict[str, Any]] = []
    seen: set[str] = set()
    for raw in groups:
        if not isinstance(raw, dict):
            raise RuntimeError(f"{path}: every scenario must be an object")
        key = raw.get("key")
        if not isinstance(key, str) or not re.fullmatch(r"[a-z0-9_]+", key):
            raise RuntimeError(f"{path}: invalid scenario key: {key!r}")
        if key in seen:
            raise RuntimeError(f"{path}: duplicate scenario key: {key}")
        seen.add(key)
        mode = raw.get("mode")
        if mode not in {"rules", "ubc"}:
            raise RuntimeError(f"{path}: {key} has invalid mode {mode!r}")
        rule = raw.get("rule")
        corpus = raw.get("corpus")
        if not isinstance(rule, str) or not isinstance(corpus, str):
            raise RuntimeError(f"{path}: {key} needs rule and corpus")
        iterations = raw.get("iterations")
        if not isinstance(iterations, int) or iterations < 1:
            raise RuntimeError(f"{path}: {key} has invalid iterations {iterations!r}")
        greybox = raw.get("greybox", "")
        if not isinstance(greybox, str):
            raise RuntimeError(f"{path}: {key} has invalid greybox")
        if mode == "ubc" and greybox:
            raise RuntimeError(f"{path}: {key} cannot combine -U and -G")
        scenario = {
            "key": key,
            "mode": mode,
            "rule": rule,
            "corpus": corpus,
            "iterations": iterations,
            "greybox": greybox,
            "source": raw.get("source", ""),
        }
        scenarios.append(scenario)
    if not scenarios:
        raise RuntimeError(f"{path}: no scenarios declared")
    return scenarios


def load_dataset_manifest(path: Path) -> dict[str, Any]:
    payload = load_json(path)
    if payload.get("schema") != 1:
        raise RuntimeError(f"{path}: unsupported dataset manifest schema")
    files = payload.get("files")
    if not isinstance(files, dict) or not files:
        raise RuntimeError(f"{path}: dataset manifest has no files")
    return payload


def corpus_metadata(manifest: dict[str, Any], corpus: str) -> dict[str, int]:
    entry = manifest["files"].get(corpus)
    if not isinstance(entry, dict) or entry.get("kind") != "corpus":
        raise RuntimeError(f"dataset manifest has no corpus entry for {corpus!r}")
    try:
        return {
            "corpus_bytes": int(entry["corpus_bytes"]),
            "corpus_blocks": int(entry["corpus_blocks"]),
        }
    except (KeyError, TypeError, ValueError) as error:
        raise RuntimeError(f"dataset manifest has invalid corpus stats for {corpus!r}") from error


def rule_metadata(manifest: dict[str, Any], rule: str) -> dict[str, int]:
    entry = manifest["files"].get(rule)
    if not isinstance(entry, dict) or entry.get("kind") != "rules":
        raise RuntimeError(f"dataset manifest has no rules entry for {rule!r}")
    try:
        return {"expressions": int(entry["expressions"])}
    except (KeyError, TypeError, ValueError) as error:
        raise RuntimeError(f"dataset manifest has invalid rule stats for {rule!r}") from error


def select_scenarios(scenarios: list[dict[str, Any]], only: list[str]) -> list[dict[str, Any]]:
    if not only:
        return scenarios
    by_key = {scenario["key"]: scenario for scenario in scenarios}
    selected = []
    for key in only:
        if key not in by_key:
            raise RuntimeError(f"unknown scenario selected: {key}")
        selected.append(by_key[key])
    return selected


def metric_name(scenario: dict[str, Any]) -> str:
    return f"{scenario['key']}_{METRIC_SUFFIX}"


# ---------------------------------------------------------------------------
# Container-side timing driver
# ---------------------------------------------------------------------------
def build_command(
    hsbench: Path,
    dataset_root: Path,
    dump_db: Path,
    scenario: dict[str, Any],
) -> list[str]:
    if scenario["mode"] == "rules":
        command = [str(hsbench), "-e", str(dataset_root / scenario["rule"])]
    else:
        command = [str(hsbench), "-U", str(dump_db)]
    command.extend(
        [
            "-c",
            str(dataset_root / scenario["corpus"]),
            "-N",
            "-n",
            str(scenario["iterations"]),
        ]
    )
    if scenario["mode"] == "rules" and scenario["greybox"]:
        command.extend(["-G", scenario["greybox"]])
    return command


def run_one(command: list[str], log_path: Path, timing_path: Path) -> dict[str, Any]:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    timing_path.parent.mkdir(parents=True, exist_ok=True)
    timed = ["/usr/bin/time", "-v", "-o", str(timing_path), *command]
    started = time.monotonic()
    timed_out = False
    try:
        completed = subprocess.run(
            timed,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=MEASUREMENT_TIMEOUT,
            check=False,
            env=hsbench_environment(),
        )
        exit_code = completed.returncode
        output = completed.stdout
    except subprocess.TimeoutExpired as error:
        timed_out = True
        exit_code = None
        raw = error.stdout or ""
        output = raw if isinstance(raw, str) else raw.decode("utf-8", "replace")
    wall_seconds = time.monotonic() - started
    log_path.write_text(f"$ {' '.join(command)}\n\n{output}", encoding="utf-8")
    max_rss_kib = 0
    if timing_path.is_file():
        match = RSS_RE.search(timing_path.read_text(encoding="utf-8", errors="replace"))
        if match is not None:
            max_rss_kib = int(match.group(1))
    timing_path.unlink(missing_ok=True)
    return {
        "command": command,
        "exit_code": exit_code,
        "timed_out": timed_out,
        "wall_seconds": round(wall_seconds, 6),
        "max_rss_kib": max_rss_kib,
    }


def drive(args: argparse.Namespace) -> int:
    hsbench = args.hsbench.resolve()
    dataset_root = args.dataset_root.resolve()
    dump_db = args.dump_db.resolve()
    runs_dir = args.runs_dir.resolve()
    if args.reps < 1:
        raise RuntimeError("--reps must be at least 1")
    if args.warmups < 1:
        raise RuntimeError("--warmups must be at least 1")
    scenarios = select_scenarios(
        load_scenarios(args.scenarios), args.scenario
    )
    manifest = load_dataset_manifest(args.dataset_manifest)
    for scenario in scenarios:
        rule_path = dataset_root / scenario["rule"]
        corpus_path = dataset_root / scenario["corpus"]
        if not rule_path.is_file():
            raise RuntimeError(f"missing rule file: {rule_path}")
        if not corpus_path.is_file():
            raise RuntimeError(f"missing corpus: {corpus_path}")
        if scenario["mode"] == "ubc" and not dump_db.is_file():
            raise RuntimeError(f"missing universal bytecode database: {dump_db}")
        corpus_metadata(manifest, scenario["corpus"])
        rule_metadata(manifest, scenario["rule"])

    labels = [f"warmup{index}" for index in range(1, args.warmups + 1)]
    labels += [f"rep{index}" for index in range(1, args.reps + 1)]
    # A reused results directory must not keep samples from an earlier run: the
    # strict host parser only reads the expected labels, so stale files would be
    # silently ignored and two different measurements could be reported as one.
    if runs_dir.exists():
        shutil.rmtree(runs_dir)
    runs_dir.mkdir(parents=True, exist_ok=True)
    for scenario in scenarios:
        scenario_dir = runs_dir / scenario["key"]
        command = build_command(hsbench, dataset_root, dump_db, scenario)
        for label in labels:
            log_path = scenario_dir / f"{label}.log"
            evidence = run_one(command, log_path, scenario_dir / f".{label}.time")
            evidence["scenario"] = scenario
            write_json(scenario_dir / f"{label}.json", evidence)
            if evidence["timed_out"] or evidence["exit_code"] != 0:
                raise RuntimeError(
                    f"{scenario['key']} {label} failed: exit={evidence['exit_code']} "
                    f"timed_out={evidence['timed_out']}"
                )
            print(f"[ultrascan] {scenario['key']} {label}: recorded", flush=True)
    print(
        f"[ultrascan] recorded {len(scenarios)} scenarios x "
        f"({args.warmups} warmup + {args.reps} repetitions)",
        flush=True,
    )
    return 0


# ---------------------------------------------------------------------------
# Host-side strict parser
# ---------------------------------------------------------------------------
def one_match(pattern: re.Pattern[str], text: str, label: str) -> re.Match[str]:
    matches = list(pattern.finditer(text))
    if len(matches) != 1:
        raise RuntimeError(f"expected exactly one '{label}' line, found {len(matches)}")
    return matches[0]


def parse_run(
    log_path: Path,
    evidence_path: Path,
    scenario: dict[str, Any],
    manifest: dict[str, Any],
    version: str,
) -> dict[str, Any]:
    try:
        output = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as error:
        raise RuntimeError(f"cannot read {log_path}: {error}") from error
    evidence = load_json(evidence_path)
    if evidence.get("timed_out"):
        raise RuntimeError(f"{log_path.name}: the measured process timed out")
    if evidence.get("exit_code") != 0:
        raise RuntimeError(
            f"{log_path.name}: hsbench exited with {evidence.get('exit_code')!r}"
        )
    for marker in ("Error:", "ERROR:", "Fatal error"):
        if marker in output:
            raise RuntimeError(f"{log_path.name}: hsbench reported {marker!r}")

    info = one_match(HSBENCH_INFO_RE, output, "Hyperscan info")
    if info.group(1) != version:
        raise RuntimeError(
            f"{log_path.name}: hsbench reports version {info.group(1)}, "
            f"expected {version}"
        )
    if info.group(2) != "BLOCK":
        raise RuntimeError(
            f"{log_path.name}: hsbench ran in {info.group(2)} mode, expected BLOCK"
        )

    expected_corpus = corpus_metadata(manifest, scenario["corpus"])
    expected_rule = rule_metadata(manifest, scenario["rule"])
    corpus = one_match(CORPUS_RE, output, "Corpus size")
    corpus_bytes, corpus_blocks = int(corpus.group(1)), int(corpus.group(2))
    if (
        corpus_bytes != expected_corpus["corpus_bytes"]
        or corpus_blocks != expected_corpus["corpus_blocks"]
    ):
        raise RuntimeError(
            f"{log_path.name}: corpus is {corpus_bytes} bytes / {corpus_blocks} "
            f"blocks, expected {expected_corpus['corpus_bytes']} / "
            f"{expected_corpus['corpus_blocks']}"
        )
    matches = one_match(MATCHES_RE, output, "Matches per iteration")
    bytecode = one_match(BYTECODE_RE, output, "Bytecode size")
    throughput = one_match(MEAN_TPUT_RE, output, "Mean throughput (overall)")
    max_throughput = one_match(MAX_TPUT_RE, output, "Max throughput (per core)")
    mean_throughput = float(throughput.group(1))
    if not math.isfinite(mean_throughput) or mean_throughput <= 0:
        raise RuntimeError(f"{log_path.name}: non-positive Mean throughput")
    if float(max_throughput.group(1)) < mean_throughput:
        raise RuntimeError(
            f"{log_path.name}: per-core maximum throughput is below the mean"
        )
    expressions = one_match(EXPRESSION_RE, output, "Expression count")
    expression_count = int(expressions.group(1))
    compile_time = float(one_match(COMPILE_RE, output, "Compile time").group(1))

    if scenario["mode"] == "rules":
        if expression_count != expected_rule["expressions"]:
            raise RuntimeError(
                f"{log_path.name}: compiled {expression_count} expressions, "
                f"expected {expected_rule['expressions']}"
            )
        if compile_time < 0:
            raise RuntimeError(
                f"{log_path.name}: rule compilation time is negative"
            )
        if FAT_LOAD_RE.search(output):
            raise RuntimeError(
                f"{log_path.name}: rules mode unexpectedly loaded a serialized database"
            )
    else:
        if expression_count != 0:
            raise RuntimeError(
                f"{log_path.name}: universal-bytecode mode reports "
                f"{expression_count} compiled expressions, expected 0"
            )
        if compile_time != 0:
            raise RuntimeError(
                f"{log_path.name}: universal-bytecode mode reports a compile time"
            )
        fat = one_match(FAT_LOAD_RE, output, "Loading FAT database from")
        if Path(fat.group(1)).resolve() != Path(evidence["command"][2]).resolve():
            raise RuntimeError(
                f"{log_path.name}: loaded {fat.group(1)!r}, "
                f"expected the recorded database"
            )

    rss_kib = int(evidence.get("max_rss_kib") or 0)
    wall_seconds = float(evidence.get("wall_seconds") or 0)
    if rss_kib <= 0 or wall_seconds <= 0:
        raise RuntimeError(f"{log_path.name}: invalid wall time or peak RSS")
    return {
        "mean_throughput_mbit_s": mean_throughput,
        "wall_seconds": wall_seconds,
        "max_rss_kib": rss_kib,
        "expression_count": expression_count,
        "bytecode_bytes": int(bytecode.group(1)),
        "corpus_bytes": corpus_bytes,
        "corpus_blocks": corpus_blocks,
        "matches_per_iteration": int(matches.group(1)),
    }


def parse_scenario(
    runs_dir: Path,
    scenario: dict[str, Any],
    manifest: dict[str, Any],
    warmups: int,
    reps: int,
    version: str,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    scenario_dir = runs_dir / scenario["key"]
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    warmup_labels = [f"warmup{index}" for index in range(1, warmups + 1)]
    rep_labels = [f"rep{index}" for index in range(1, reps + 1)]
    expected = {
        f"{label}.{suffix}"
        for label in warmup_labels + rep_labels
        for suffix in ("log", "json")
    }
    observed = {path.name for path in scenario_dir.iterdir() if path.is_file()}
    if observed != expected:
        missing = sorted(expected - observed)
        extra = sorted(observed - expected)
        raise RuntimeError(
            f"{scenario['key']} run files do not match the declared samples: "
            f"missing={missing} extra={extra}"
        )
    measured = [
        parse_run(
            scenario_dir / f"{label}.log",
            scenario_dir / f"{label}.json",
            scenario,
            manifest,
            version,
        )
        for label in rep_labels
    ]
    for label in warmup_labels:
        parse_run(
            scenario_dir / f"{label}.log",
            scenario_dir / f"{label}.json",
            scenario,
            manifest,
            version,
        )
    for field in (
        "expression_count",
        "bytecode_bytes",
        "corpus_bytes",
        "corpus_blocks",
        "matches_per_iteration",
    ):
        values = {item[field] for item in measured}
        if len(values) != 1:
            raise RuntimeError(
                f"{scenario['key']} repetitions disagree on {field}: {sorted(values)}"
            )
    consistency = {
        field: measured[0][field]
        for field in (
            "expression_count",
            "bytecode_bytes",
            "corpus_bytes",
            "corpus_blocks",
            "matches_per_iteration",
        )
    }
    return measured, consistency


def summarize(values: list[float]) -> dict[str, float]:
    return {
        "median": round(float(statistics.median(values)), 6),
        "mean": round(float(statistics.fmean(values)), 6),
        "min": round(float(min(values)), 6),
        "max": round(float(max(values)), 6),
    }


def report(args: argparse.Namespace) -> int:
    runs_dir = args.runs_dir.resolve()
    if args.reps < 1 or args.warmups < 1:
        raise RuntimeError("--warmups and --reps must both be at least 1")
    version = args.version
    if args.architecture not in ARCHITECTURES:
        raise RuntimeError(f"unsupported architecture: {args.architecture}")
    scenarios = select_scenarios(
        load_scenarios(args.scenarios), args.scenario
    )
    manifest = load_dataset_manifest(args.dataset_manifest)
    results: dict[str, Any] = {}
    consistency_by_scenario: dict[str, Any] = {}
    raw_sections: list[str] = []
    for scenario in scenarios:
        measured, consistency = parse_scenario(
            runs_dir, scenario, manifest, args.warmups, args.reps, version
        )
        consistency_by_scenario[scenario["key"]] = consistency
        values = [item["mean_throughput_mbit_s"] for item in measured]
        name = metric_name(scenario)
        results[name] = {
            "source_name": name,
            "source_benchmark": scenario["source"],
            "source_field": "Mean throughput (overall)",
            "value": round(float(statistics.median(values)), 6),
            "unit": METRIC_UNIT,
            "direction": "higher_is_better",
            "samples": len(values),
            "sample_values": values,
            "sample_summary": summarize(values),
            "wall_seconds_sample_values": [
                item["wall_seconds"] for item in measured
            ],
            "max_rss_kib_sample_values": [
                item["max_rss_kib"] for item in measured
            ],
            "group": GROUP,
        }
        for label in [f"warmup{index}" for index in range(1, args.warmups + 1)]:
            raw_sections.append(
                (runs_dir / scenario["key"] / f"{label}.log").read_text(
                    encoding="utf-8", errors="replace"
                )
            )
        for label in [f"rep{index}" for index in range(1, args.reps + 1)]:
            raw_sections.append(
                (runs_dir / scenario["key"] / f"{label}.log").read_text(
                    encoding="utf-8", errors="replace"
                )
            )

    # The legacy pair must remain the same workload: same corpus statistics,
    # bytecode size and match count.  The matrix rows have no such pair.
    reference_pairs: dict[tuple[str, str], str] = {}
    for scenario in scenarios:
        reference_pairs.setdefault(
            (scenario["rule"], scenario["corpus"]), scenario["key"]
        )
    for (rule, corpus), first_key in reference_pairs.items():
        keys = [
            scenario["key"]
            for scenario in scenarios
            if scenario["rule"] == rule and scenario["corpus"] == corpus
        ]
        if len(keys) < 2:
            continue
        first = consistency_by_scenario[first_key]
        for key in keys[1:]:
            for field in (
                "bytecode_bytes",
                "corpus_bytes",
                "corpus_blocks",
                "matches_per_iteration",
            ):
                if first[field] != consistency_by_scenario[key][field]:
                    raise RuntimeError(
                        f"{first_key} and {key} disagree on {field}: "
                        f"{first[field]} != {consistency_by_scenario[key][field]}"
                    )

    payload = {
        "software": "ultrascan",
        "version": version,
        "variant": args.variant,
        "architecture": args.architecture,
        "run_id": args.run_id,
        "generated_at": utc_timestamp(),
        "toolchain": {"compiler": args.compiler},
        "dataset": {
            "root": manifest.get("root"),
            "source_zip": manifest.get("source_zip"),
            "source_zip_sha256": manifest.get("source_zip_sha256"),
            "files": manifest.get("files"),
        },
        "benchmark": {
            "workload": (
                "Ultrascan hsbench block-mode rule/corpus matrix; each metric is "
                "the Mean throughput (overall) of one scenario"
            ),
            "warmups": args.warmups,
            "measure_reps": args.reps,
            "scenarios": [
                {
                    "key": scenario["key"],
                    "mode": scenario["mode"],
                    "rule": scenario["rule"],
                    "corpus": scenario["corpus"],
                    "iterations": scenario["iterations"],
                    "greybox": scenario["greybox"],
                }
                for scenario in scenarios
            ],
        },
        "results": results,
        "runs_dir": "runs",
    }
    write_json(args.output, payload)
    args.raw_output.parent.mkdir(parents=True, exist_ok=True)
    args.raw_output.write_text(
        "\n\n".join(section.rstrip() for section in raw_sections) + "\n",
        encoding="utf-8",
    )
    for name, item in results.items():
        print(
            f"{name}: {item['value']:.2f} Mbit/s "
            f"({item['samples']} samples, min {item['sample_summary']['min']:.2f}, "
            f"max {item['sample_summary']['max']:.2f})"
        )
    print(f"wrote {args.output}: {len(results)} hsbench metrics")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    drive_parser = subparsers.add_parser("drive")
    drive_parser.add_argument("--hsbench", required=True, type=Path)
    drive_parser.add_argument("--dataset-root", required=True, type=Path)
    drive_parser.add_argument("--dump-db", required=True, type=Path)
    drive_parser.add_argument("--dataset-manifest", required=True, type=Path)
    drive_parser.add_argument("--runs-dir", required=True, type=Path)
    drive_parser.add_argument("--warmups", required=True, type=int)
    drive_parser.add_argument("--reps", required=True, type=int)
    drive_parser.add_argument("--scenarios", type=Path, default=DEFAULT_SCENARIOS)
    drive_parser.add_argument("--scenario", action="append", default=[])
    drive_parser.add_argument("--output", type=Path, default=None)

    report_parser = subparsers.add_parser("report")
    report_parser.add_argument("--runs-dir", required=True, type=Path)
    report_parser.add_argument("--raw-output", required=True, type=Path)
    report_parser.add_argument("--output", required=True, type=Path)
    report_parser.add_argument("--dataset-manifest", required=True, type=Path)
    report_parser.add_argument("--scenarios", type=Path, default=DEFAULT_SCENARIOS)
    report_parser.add_argument("--scenario", action="append", default=[])
    report_parser.add_argument("--version", required=True)
    report_parser.add_argument("--architecture", required=True)
    report_parser.add_argument("--variant", default="base")
    report_parser.add_argument("--run-id", default="")
    report_parser.add_argument("--compiler", default="unknown")
    report_parser.add_argument("--warmups", required=True, type=int)
    report_parser.add_argument("--reps", required=True, type=int)

    args = parser.parse_args()
    try:
        if args.command == "drive":
            return drive(args)
        return report(args)
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        print(f"[ultrascan-parse] ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
