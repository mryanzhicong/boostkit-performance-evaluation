#!/usr/bin/env python3
"""Aggregate the measured libvirt virsh lifecycle repetitions.

Every repetition writes ``reps/rep<N>.json`` with the duration of ``virsh start``,
the duration of the ``virsh console`` probe, the observed boot time and its own
status.  A repetition that did not reach the running state, did not appear in
``virsh list`` or did not reach a guest login prompt fails the case; the metrics
are never taken from a partially successful repetition.
"""

from __future__ import annotations

import json
import math
import os
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path

METRICS = ("virsh_start_ms", "virsh_console_probe_ms", "guest_boot_observed_seconds")


def load_rep(path: Path) -> dict:
    if not path.is_file():
        raise SystemExit(f"missing lifecycle repetition report: {path}")
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise SystemExit(f"invalid lifecycle repetition report: {path}")
    return payload


def number(payload: dict, key: str, where: str) -> float:
    value = payload.get(key)
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        raise SystemExit(f"{where}: {key} is not a number")
    value = float(value)
    if not math.isfinite(value) or value <= 0:
        raise SystemExit(f"{where}: {key} must be positive, found {value}")
    return value


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py RESULTS_DIR OUTPUT_JSON", file=sys.stderr)
        return 2
    results_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    reps = int(os.environ["LIBVIRT_REPS"])
    warmup = int(os.environ["LIBVIRT_WARMUP_REPS"])
    if reps - warmup < 5:
        raise SystemExit("the sampling contract requires at least five measured repetitions")
    measured = list(range(warmup + 1, reps + 1))
    if len(measured) < 5:
        raise SystemExit("fewer than five measured repetitions were collected")
    samples: dict[str, list[float]] = {metric: [] for metric in METRICS}
    flags: dict[str, list[bool]] = {
        "virsh_start_ok": [],
        "virsh_list_running_ok": [],
        "virsh_console_ok": [],
    }
    for rep in range(1, reps + 1):
        payload = load_rep(results_dir / "reps" / f"rep{rep}.json")
        where = f"repetition {rep}"
        for flag in flags:
            if not isinstance(payload.get(flag), bool):
                raise SystemExit(f"{where}: {flag} is missing from the evidence")
            if rep in measured:
                flags[flag].append(payload[flag])
        if payload.get("status") != "passed":
            raise SystemExit(f"{where}: the lifecycle sequence did not pass")
        if rep in measured:
            for metric in METRICS:
                samples[metric].append(number(payload, metric, where))
    for flag, values in flags.items():
        if not values or not all(values):
            raise SystemExit(f"the test point behind {flag} did not pass in every measured repetition")
    results = {
        "libvirt.virsh_start_ok": {
            "source_name": "virsh start reaches the running state in every measured repetition",
            "value": float(all(flags["virsh_start_ok"])),
            "unit": "bool",
            "direction": "higher_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.virsh_list_running_ok": {
            "source_name": "virsh list reports the domain as running in every measured repetition",
            "value": float(all(flags["virsh_list_running_ok"])),
            "unit": "bool",
            "direction": "higher_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.virsh_console_ok": {
            "source_name": "virsh console reaches a guest login prompt in every measured repetition",
            "value": float(all(flags["virsh_console_ok"])),
            "unit": "bool",
            "direction": "higher_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.virsh_start_ms": {
            "source_name": "virsh start time until the domain is running",
            "value": statistics.median(samples["virsh_start_ms"]),
            "unit": "ms",
            "direction": "lower_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.virsh_console_probe_ms": {
            "source_name": "time until virsh console answers with a guest login prompt",
            "value": statistics.median(samples["virsh_console_probe_ms"]),
            "unit": "ms",
            "direction": "lower_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.guest_boot_observed_seconds": {
            "source_name": "observed boot time from virsh start to the guest address",
            "value": statistics.median(samples["guest_boot_observed_seconds"]),
            "unit": "s",
            "direction": "lower_is_better",
            "group": "virsh lifecycle",
        },
        "libvirt.measured_reps": {
            "source_name": "measured repetitions",
            "value": float(len(measured)),
            "unit": "repetition",
            "direction": "neutral",
            "group": "sampling",
        },
        "libvirt.vcpus_per_vm": {
            "source_name": "vCPU of the lifecycle VM",
            "value": float(os.environ.get("LIBVIRT_VM_CORES", "4")),
            "unit": "vcpu",
            "direction": "neutral",
            "group": "topology",
        },
        "libvirt.memory_gib_per_vm": {
            "source_name": "memory of the lifecycle VM",
            "value": float(int(os.environ.get("LIBVIRT_VM_MEM_MIB", "8192")) / 1024),
            "unit": "GiB",
            "direction": "neutral",
            "group": "topology",
        },
    }
    payload = {
        "benchmark": "libvirt_virsh_lifecycle",
        "software": "libvirt-virsh-lifecycle",
        "version": os.environ.get("SOFTWARE_VERSION", "22.03-LTS-SP3"),
        "architecture": os.environ.get("EXPECTED_ARCH", ""),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "sequence": "virsh start -> virsh list -> virsh console -> virsh shutdown",
            "vm_count": int(os.environ.get("LIBVIRT_VM_COUNT", "1")),
            "vcpus_per_vm": int(os.environ.get("LIBVIRT_VM_CORES", "4")),
            "memory_mib_per_vm": int(os.environ.get("LIBVIRT_VM_MEM_MIB", "8192")),
            "execution_environment": "kvm-vm",
            "guest_os": "openEuler 22.03 LTS SP3",
            "repetitions": reps,
            "warmup_repetitions": warmup,
            "measured_repetitions": len(measured),
            "aggregation": "median across the measured repetitions",
        },
        "results": results,
    }
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(
        f"[libvirt-virsh-lifecycle] aggregated {len(results)} metrics from "
        f"{len(measured)} measured repetitions",
        flush=True,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
