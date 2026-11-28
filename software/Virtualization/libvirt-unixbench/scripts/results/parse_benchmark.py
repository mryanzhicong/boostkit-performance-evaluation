#!/usr/bin/env python3
"""Aggregate the official UnixBench 6.0.1 system index of a libvirt VM fleet.

Every repetition runs ``./Run -c <copies>`` inside every reference VM, so one
report per VM and repetition lands in ``runs/rep<N>/vm<M>.log``.  The parser is
strict: a report must be a complete official system-index run of the requested
copy count, every one of the twelve index tests must be present, and a missing or
partial report fails the whole case instead of being zero filled.
"""

from __future__ import annotations

import json
import math
import os
import re
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

TESTS = (
    ("Dhrystone 2 using register variables", "dhrystone2"),
    ("Double-Precision Whetstone", "whetstone_double"),
    ("Execl Throughput", "execl"),
    ("File Copy 1024 bufsize 2000 maxblocks", "file_copy_1024"),
    ("File Copy 256 bufsize 500 maxblocks", "file_copy_256"),
    ("File Copy 4096 bufsize 8000 maxblocks", "file_copy_4096"),
    ("Pipe Throughput", "pipe_throughput"),
    ("Pipe-based Context Switching", "pipe_context_switch"),
    ("Process Creation", "process_creation"),
    ("System Call Overhead", "syscall_overhead"),
    ("Shell Scripts (1 concurrent)", "shell_scripts_1"),
    ("Shell Scripts (8 concurrent)", "shell_scripts_8"),
)
NUMBER = r"(?:\d+(?:\.\d*)?|\.\d+)"
VERSION = re.compile(r"BYTE UNIX Benchmarks \(Version (6\.0\.1)\)")
PASS = re.compile(r"^\s*(\d+) CPUs? in system; running (\d+) parallel cop(?:y|ies) of tests$")
RAW = re.compile(rf"^(.+?)\s+({NUMBER})\s+(\S+)\s+\(({NUMBER}) s, (\d+) samples\)$")
INDEX = re.compile(rf"^(.+?)\s+({NUMBER})\s+({NUMBER})\s+({NUMBER})$")
SCORE = re.compile(rf"^System Benchmarks Index Score\s+({NUMBER})$")


def positive(text: str) -> float:
    value = float(text)
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"non-positive or non-finite UnixBench measurement: {text}")
    return value


def parse_report(report: str, copies: int, vm_index: int, rep: int) -> dict[str, float]:
    where = f"repetition {rep} VM {vm_index}"
    if not VERSION.search(report):
        raise ValueError(f"{where}: not an official UnixBench 6.0.1 report")
    segments = re.split(r"(?=^Benchmark Run: )", report, flags=re.MULTILINE)
    passes = [part for part in segments if part.startswith("Benchmark Run: ")]
    if len(passes) != 1:
        raise ValueError(f"{where}: ./Run -c {copies} must print exactly one pass, found {len(passes)}")
    part = passes[0]
    lines = part.splitlines()
    pass_matches = [match for line in lines if (match := PASS.match(line.strip()))]
    if len(pass_matches) != 1:
        raise ValueError(f"{where}: the pass line does not identify one CPU and copy count")
    system_cpus, run_copies = (int(value) for value in pass_matches[0].groups())
    if run_copies != copies:
        raise ValueError(f"{where}: expected {copies} parallel copies, found {run_copies}")
    if system_cpus != copies:
        raise ValueError(f"{where}: the guest reports {system_cpus} CPUs but runs {run_copies} copies")
    if "System Benchmarks Partial Index" in part or "(Partial Only)" in part:
        raise ValueError(f"{where}: UnixBench produced only a partial index")
    if "System Benchmarks Index Values" not in part:
        raise ValueError(f"{where}: the complete system-index table is missing")
    raw: dict[str, float] = {}
    indexed: dict[str, tuple[float, float]] = {}
    in_index = False
    for line in lines:
        stripped = line.strip()
        if line.startswith("System Benchmarks Index Values"):
            in_index = True
            continue
        if not in_index:
            match = RAW.match(stripped)
            if match:
                label = match.group(1)
                if label in raw:
                    raise ValueError(f"{where}: duplicate raw result: {label}")
                raw[label] = positive(match.group(2))
        else:
            match = INDEX.match(stripped)
            if match and match.group(1) in {name for name, _ in TESTS}:
                label, baseline, value, index = match.groups()
                if label in indexed:
                    raise ValueError(f"{where}: duplicate index result: {label}")
                positive(baseline)
                indexed[label] = (positive(value), positive(index))
    expected = {name for name, _ in TESTS}
    if set(raw) != expected:
        raise ValueError(f"{where}: raw results incomplete: missing {sorted(expected - set(raw))}")
    if set(indexed) != expected:
        raise ValueError(f"{where}: index results incomplete: missing {sorted(expected - set(indexed))}")
    for label in expected:
        raw_value = raw[label]
        indexed_value, _ = indexed[label]
        if abs(raw_value - indexed_value) > max(0.11, raw_value * 0.000001):
            raise ValueError(f"{where}: raw and indexed scores disagree for {label}")
    scores = [positive(match.group(1)) for line in lines if (match := SCORE.match(line.strip()))]
    if len(scores) != 1:
        raise ValueError(f"{where}: the complete system index score is missing")
    return {
        "index_score": scores[0],
        **{slug: indexed[label][1] for label, slug in TESTS},
    }


def median(values: list[float]) -> float:
    return float(statistics.median(values))


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: parse_benchmark.py RUNS_DIR OUTPUT_JSON PER_VM_JSON",
            file=sys.stderr,
        )
        return 2
    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    per_vm_path = Path(sys.argv[3])
    reps = int(os.environ["LIBVIRT_REPS"])
    warmup = int(os.environ["LIBVIRT_WARMUP_REPS"])
    vm_count = int(os.environ["LIBVIRT_VM_COUNT"])
    copies = int(os.environ["LIBVIRT_COPIES"])
    if reps - warmup < 5:
        raise SystemExit("the sampling contract requires at least five measured repetitions")
    per_vm: dict[str, dict[str, dict[str, float]]] = {}
    for rep in range(1, reps + 1):
        for vm in range(vm_count):
            path = runs_dir / f"rep{rep}" / f"vm{vm}.log"
            if not path.is_file():
                raise SystemExit(f"missing benchmark report: {path}")
            per_vm.setdefault(str(rep), {})[str(vm)] = parse_report(
                path.read_text(encoding="utf-8", errors="replace"), copies, vm, rep
            )
    measured = [str(rep) for rep in range(warmup + 1, reps + 1)]
    if len(measured) < 5:
        raise SystemExit("fewer than five measured repetitions were collected")
    metrics = ["index_score", *[slug for _, slug in TESTS]]
    results: dict[str, dict] = {}
    all_values: dict[str, list[float]] = {metric: [] for metric in metrics}
    for metric in metrics:
        rep_medians: list[float] = []
        for rep in measured:
            values = [per_vm[rep][str(vm)][metric] for vm in range(vm_count)]
            all_values[metric].extend(values)
            rep_medians.append(median(values))
        results[metric] = median(rep_medians)
    payload_results: dict[str, dict] = {
        "unixbench.index_score": {
            "source_name": "System Benchmarks Index Score",
            "value": results["index_score"],
            "unit": "index",
            "direction": "higher_is_better",
            "group": f"{copies} copies",
        },
        "unixbench.index_score_min": {
            "source_name": "lowest System Benchmarks Index Score of any VM and measured repetition",
            "value": min(all_values["index_score"]),
            "unit": "index",
            "direction": "higher_is_better",
            "group": f"{copies} copies",
        },
        "unixbench.index_score_max": {
            "source_name": "highest System Benchmarks Index Score of any VM and measured repetition",
            "value": max(all_values["index_score"]),
            "unit": "index",
            "direction": "higher_is_better",
            "group": f"{copies} copies",
        },
        "libvirt.vm_count": {
            "source_name": "reference VMs measured in parallel",
            "value": float(vm_count),
            "unit": "vm",
            "direction": "neutral",
            "group": "topology",
        },
        "libvirt.vcpus_per_vm": {
            "source_name": "vCPU per reference VM",
            "value": float(copies),
            "unit": "vcpu",
            "direction": "neutral",
            "group": "topology",
        },
        "libvirt.measured_reps": {
            "source_name": "measured repetitions",
            "value": float(len(measured)),
            "unit": "repetition",
            "direction": "neutral",
            "group": "topology",
        },
        "libvirt.total_benchmark_runs": {
            "source_name": "official ./Run invocations behind the medians",
            "value": float(len(measured) * vm_count),
            "unit": "run",
            "direction": "neutral",
            "group": "topology",
        },
    }
    for label, slug in TESTS:
        payload_results[f"unixbench.{slug}.index"] = {
            "source_name": f"{label} — index",
            "value": results[slug],
            "unit": "index",
            "direction": "higher_is_better",
            "group": f"{copies} copies",
        }
    payload = {
        "benchmark": "libvirt_unixbench_system_index",
        "software": "libvirt-unixbench",
        "version": os.environ.get("SOFTWARE_VERSION", "6.0.1"),
        "architecture": os.environ.get("EXPECTED_ARCH", ""),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "command": f"./Run -c {copies}",
            "copies_per_vm": copies,
            "vm_count": vm_count,
            "vcpus_per_vm": copies,
            "memory_mib_per_vm": int(os.environ.get("LIBVIRT_VM_MEM_MIB", "8192")),
            "execution_environment": "kvm-vm-fleet",
            "guest_os": "openEuler 24.03 LTS SP4",
            "repetitions": reps,
            "warmup_repetitions": warmup,
            "measured_repetitions": len(measured),
            "aggregation": "median across VMs of each measured repetition, then median across repetitions",
        },
        "results": payload_results,
    }
    per_vm_payload = {
        "copies_per_vm": copies,
        "vm_count": vm_count,
        "repetitions": reps,
        "warmup_repetitions": warmup,
        "measured_repetitions": len(measured),
        "per_vm": per_vm,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    per_vm_path.write_text(json.dumps(per_vm_payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"[libvirt-unixbench] aggregated {len(payload_results)} metrics from "
        f"{len(measured)} measured repetitions x {vm_count} VMs",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
