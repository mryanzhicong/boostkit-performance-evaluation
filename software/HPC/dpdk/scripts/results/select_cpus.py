#!/usr/bin/env python3
"""Select distinct online physical CPUs on NUMA 0 (same socket), respecting Cpus_allowed_list."""

from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path


def parse_cpu_list(spec: str) -> set[int]:
    allowed: set[int] = set()
    for part in spec.strip().split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            start_s, end_s = part.split("-", 1)
            allowed.update(range(int(start_s), int(end_s) + 1))
        else:
            allowed.add(int(part))
    return allowed


def read_allowed_cpus(status_path: Path = Path("/proc/self/status")) -> set[int] | None:
    if not status_path.is_file():
        return None
    for line in status_path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("Cpus_allowed_list:"):
            return parse_cpu_list(line.split(":", 1)[1])
    return None


def select_numa0_physical_cpus(
    lscpu_text: str,
    allowed_cpus: set[int] | None,
    min_cores: int = 2,
) -> dict:
    # lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE outputs comma-separated rows; lines starting with '#' are comments.
    # Group by (socket, node) -> list of first online logical CPU per unique physical CORE.
    by_socket_numa0: dict[int, list[tuple[int, int]]] = {}
    seen_phys: set[tuple[int, int]] = set()
    for raw_line in lscpu_text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        parts = [p.strip() for p in line.split(",")]
        if len(parts) < 4:
            continue
        cpu_s, core_s, socket_s, node_s = parts[:4]
        online_s = parts[4] if len(parts) >= 5 else "Y"
        if online_s and online_s.upper() not in {"Y", "YES", "1"}:
            continue
        if not (cpu_s.isdigit() and core_s.isdigit()):
            continue
        cpu = int(cpu_s)
        core = int(core_s)
        socket = int(socket_s) if socket_s.isdigit() else 0
        node = int(node_s) if node_s.isdigit() else 0
        if allowed_cpus is not None and cpu not in allowed_cpus:
            continue
        if node != 0:
            continue
        phys_key = (socket, core)
        if phys_key in seen_phys:
            continue
        seen_phys.add(phys_key)
        by_socket_numa0.setdefault(socket, []).append((cpu, core))

    # Pick socket on NUMA 0 with the most distinct physical cores (tie-break: lowest socket id).
    chosen_socket = None
    chosen_pairs: list[tuple[int, int]] = []
    for socket in sorted(by_socket_numa0):
        pairs = sorted(by_socket_numa0[socket], key=lambda item: item[0])
        if len(pairs) > len(chosen_pairs):
            chosen_socket = socket
            chosen_pairs = pairs

    if len(chosen_pairs) < min_cores:
        raise ValueError(
            f"need at least {min_cores} distinct online physical cores on NUMA 0 "
            f"(same socket), found {len(chosen_pairs)}"
        )

    cpus = [cpu for cpu, _core in chosen_pairs]
    # Prefer skipping CPU 0 for housekeeping when enough physical cores are available.
    non_zero = [cpu for cpu in cpus if cpu != 0]
    selected = non_zero[:min_cores] if len(non_zero) >= min_cores else cpus[:min_cores]

    payload = {
        "numa_node": 0,
        "socket_id": chosen_socket,
        "bench_cpu": str(selected[0]),
        "selected_cpus": selected,
        "available_numa0_physical_cores": len(chosen_pairs),
    }
    if len(selected) >= 2:
        payload["bench_pair"] = f"{selected[0]},{selected[1]}"
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--min-cores", type=int, default=2)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    lscpu_out = subprocess.check_output(
        ["lscpu", "-p=CPU,CORE,SOCKET,NODE,ONLINE"],
        text=True,
    )
    allowed = read_allowed_cpus()
    selection = select_numa0_physical_cpus(lscpu_out, allowed, min_cores=args.min_cores)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(selection, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
