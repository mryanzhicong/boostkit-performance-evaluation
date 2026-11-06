#!/usr/bin/env python3
"""Measure and normalize the Ultrascan hsbench "Mean throughput" benchmark.

The measured content is the upstream hsbench procedure documented for Ultrascan
5.8.0, executed twice inside the private openEuler container on the Intel
``hsbench-samples`` package:

``hsbench_rules_block``
    Compile the pattern set for every run and scan the corpus in block mode::

        hsbench -e <samples>/pcre/snort_literals \
                -c <samples>/corpora/gutenberg.db -N -n 1

``hsbench_ubc_block``
    Load the universal bytecode database produced by ``hsdump -N -U`` and scan
    the same corpus in block mode::

        hsbench -U <dump>/dump/db.raw \
                -c <samples>/corpora/gutenberg.db -N -n 1

``drive``
    Container-side timing driver: run one warm-up plus every declared
    repetition of both scenarios inside the container and record the raw hsbench
    output plus wall time and peak RSS for every run.

``report``
    Host-side strict parser: validate the recorded runs, keep the only metric the
    benchmark contract asks for (the ``Mean throughput (overall)`` value of each
    scenario, Mbit/s) and write the normalized ``results.json``.

The parser is strict: a missing sample, extra sample, non-zero exit, timeout, a
changed corpus size or a match count that differs between the two scenarios
fails the test stage (exit code 50) instead of being padded or ignored.
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
    r"^Hyperscan info:\s+Version:\s+(\S+)\s+Mode:\s+(BLOCK|STREAM|VECTORED)\s*$",
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

# Pinned measurement inputs (see scripts/common.sh).
EXPECTED_LITERAL_EXPRESSIONS = 3116
EXPECTED_CORPUS_BYTES = 6701044
EXPECTED_CORPUS_BLOCKS = 3280
RULES_RELATIVE = "pcre/snort_literals"
CORPUS_RELATIVE = "corpora/gutenberg.db"
# One hsbench sample scans a ~7 MB corpus in a few milliseconds after a ~0.3 s
# rule compile, so 300 s is already a 1000x margin; a longer bound would only let
# a hung measurement burn the stage budget before it is reported as a failure.
MEASUREMENT_TIMEOUT = 300

SCENARIOS = (
    {
        "key": "hsbench_rules_block",
        "source": "without universal bytecode (-e pcre/snort_literals)",
        "mode": "rules",
    },
    {
        "key": "hsbench_ubc_block",
        "source": "with universal bytecode (-U dump/db.raw)",
        "mode": "ubc",
    },
)
GROUP = "hsbench"
METRIC_SUFFIX = "mean_throughput_mbit_s"
METRIC_UNIT = "Mbit/s"


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
# Container-side timing driver
# ---------------------------------------------------------------------------
def build_command(
    hsbench: Path, samples_root: Path, dump_db: Path, scenario: dict[str, str]
) -> list[str]:
    if scenario["mode"] == "rules":
        command = [str(hsbench), "-e", str(samples_root / RULES_RELATIVE)]
    else:
        command = [str(hsbench), "-U", str(dump_db)]
    command.extend([
        "-c", str(samples_root / CORPUS_RELATIVE),
        "-N", "-n", str(MEASUREMENT_ITERATIONS),
    ])
    return command


def run_one(
    command: list[str], log_path: Path, timing_path: Path
) -> dict[str, Any]:
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
    samples_root = args.samples_root.resolve()
    dump_db = args.dump_db.resolve()
    runs_dir = args.runs_dir.resolve()
    if args.reps < 1:
        raise RuntimeError("--reps must be at least 1")
    if args.warmups < 1:
        raise RuntimeError("--warmups must be at least 1")
    for path in (hsbench, samples_root / RULES_RELATIVE,
                 samples_root / CORPUS_RELATIVE, dump_db):
        if not path.exists():
            raise RuntimeError(f"missing measurement input: {path}")

    labels = [f"warmup{index}" for index in range(1, args.warmups + 1)]
    labels += [f"rep{index}" for index in range(1, args.reps + 1)]
    # The driver owns the runs directory for this measurement.  A reused results
    # directory must not keep samples from an earlier run: the strict host parser
    # only reads the expected labels, so leftover files would be silently ignored
    # and two different measurements could be reported as one.
    if runs_dir.exists():
        shutil.rmtree(runs_dir)
    runs_dir.mkdir(parents=True, exist_ok=True)
    for scenario in SCENARIOS:
        scenario_dir = runs_dir / scenario["key"]
        command = build_command(hsbench, samples_root, dump_db, scenario)
        for label in labels:
            log_path = scenario_dir / f"{label}.log"
            evidence = run_one(command, log_path, scenario_dir / f".{label}.time")
            write_json(scenario_dir / f"{label}.json", evidence)
            if evidence["timed_out"] or evidence["exit_code"] != 0:
                raise RuntimeError(
                    f"{scenario['key']} {label} failed: exit={evidence['exit_code']} "
                    f"timed_out={evidence['timed_out']}"
                )
            print(f"[ultrascan] {scenario['key']} {label}: recorded", flush=True)
    print(
        f"[ultrascan] recorded {len(SCENARIOS)} scenarios x "
        f"({args.warmups} warmup + {args.reps} repetitions) with -n {MEASUREMENT_ITERATIONS}",
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
    log_path: Path, evidence_path: Path, scenario: dict[str, str], version: str
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

    corpus = one_match(CORPUS_RE, output, "Corpus size")
    corpus_bytes, corpus_blocks = int(corpus.group(1)), int(corpus.group(2))
    if corpus_bytes != EXPECTED_CORPUS_BYTES or corpus_blocks != EXPECTED_CORPUS_BLOCKS:
        raise RuntimeError(
            f"{log_path.name}: corpus is {corpus_bytes} bytes / {corpus_blocks} "
            f"blocks, expected {EXPECTED_CORPUS_BYTES} / {EXPECTED_CORPUS_BLOCKS}"
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
        if expression_count != EXPECTED_LITERAL_EXPRESSIONS:
            raise RuntimeError(
                f"{log_path.name}: compiled {expression_count} expressions, "
                f"expected {EXPECTED_LITERAL_EXPRESSIONS}"
            )
        if compile_time <= 0:
            raise RuntimeError(
                f"{log_path.name}: rule compilation took no measured time"
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
    runs_dir: Path, scenario: dict[str, str], warmups: int, reps: int, version: str
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    scenario_dir = runs_dir / scenario["key"]
    if not scenario_dir.is_dir():
        raise RuntimeError(f"missing scenario directory: {scenario_dir}")
    warmup_labels = [f"warmup{index}" for index in range(1, warmups + 1)]
    rep_labels = [f"rep{index}" for index in range(1, reps + 1)]
    expected = {f"{label}.{suffix}" for label in warmup_labels + rep_labels
                for suffix in ("log", "json")}
    observed = {path.name for path in scenario_dir.iterdir() if path.is_file()}
    if observed != expected:
        missing = sorted(expected - observed)
        extra = sorted(observed - expected)
        raise RuntimeError(
            f"{scenario['key']} run files do not match the declared samples: "
            f"missing={missing} extra={extra}"
        )
    measured = [
        parse_run(scenario_dir / f"{label}.log", scenario_dir / f"{label}.json",
                  scenario, version)
        for label in rep_labels
    ]
    for label in warmup_labels:
        parse_run(scenario_dir / f"{label}.log", scenario_dir / f"{label}.json",
                  scenario, version)
    for field in ("expression_count", "bytecode_bytes", "corpus_bytes",
                  "corpus_blocks", "matches_per_iteration"):
        values = {item[field] for item in measured}
        if len(values) != 1:
            raise RuntimeError(
                f"{scenario['key']} repetitions disagree on {field}: {sorted(values)}"
            )
    consistency = {field: measured[0][field] for field in
                   ("expression_count", "bytecode_bytes", "corpus_bytes",
                    "corpus_blocks", "matches_per_iteration")}
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
    results: dict[str, Any] = {}
    consistency_by_scenario: dict[str, Any] = {}
    raw_sections: list[str] = []
    for scenario in SCENARIOS:
        measured, consistency = parse_scenario(
            runs_dir, scenario, args.warmups, args.reps, version
        )
        consistency_by_scenario[scenario["key"]] = consistency
        values = [item["mean_throughput_mbit_s"] for item in measured]
        name = f"{scenario['key']}_{METRIC_SUFFIX}"
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
            "wall_seconds_sample_values": [item["wall_seconds"] for item in measured],
            "max_rss_kib_sample_values": [item["max_rss_kib"] for item in measured],
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

    rules = consistency_by_scenario["hsbench_rules_block"]
    ubc = consistency_by_scenario["hsbench_ubc_block"]
    for field in ("bytecode_bytes", "corpus_bytes", "corpus_blocks",
                  "matches_per_iteration"):
        if rules[field] != ubc[field]:
            raise RuntimeError(
                f"the two scenarios disagree on {field}: "
                f"{rules[field]} != {ubc[field]}"
            )

    payload = {
        "software": "ultrascan",
        "version": version,
        "variant": args.variant,
        "architecture": args.architecture,
        "run_id": args.run_id,
        "generated_at": utc_timestamp(),
        "toolchain": {"compiler": args.compiler},
        "benchmark": {
            "workload": "upstream hsbench block-mode scan of pcre/snort_literals "
                        "over corpora/gutenberg.db (Mean throughput)",
            "iterations": MEASUREMENT_ITERATIONS,
            "warmups": args.warmups,
            "measure_reps": args.reps,
            "samples_package": {
                "rules": RULES_RELATIVE,
                "corpus": CORPUS_RELATIVE,
            },
            "scenarios": [scenario["key"] for scenario in SCENARIOS],
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
    drive_parser.add_argument("--samples-root", required=True, type=Path)
    drive_parser.add_argument("--dump-db", required=True, type=Path)
    drive_parser.add_argument("--runs-dir", required=True, type=Path)
    drive_parser.add_argument("--warmups", required=True, type=int)
    drive_parser.add_argument("--reps", required=True, type=int)

    report_parser = subparsers.add_parser("report")
    report_parser.add_argument("--runs-dir", required=True, type=Path)
    report_parser.add_argument("--raw-output", required=True, type=Path)
    report_parser.add_argument("--output", required=True, type=Path)
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


MEASUREMENT_ITERATIONS = 1


if __name__ == "__main__":
    raise SystemExit(main())
