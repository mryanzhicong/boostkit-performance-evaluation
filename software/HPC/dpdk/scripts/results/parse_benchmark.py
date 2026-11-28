#!/usr/bin/env python3
"""Parse DPDK 26.11.0 CPU autotest logs, convert ticks to ns, and compute medians."""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
from pathlib import Path
from typing import Any


HASH_KEY_SIZES = (4, 8, 16, 32, 48, 64, 9, 13, 37, 40)
HASH_OPS = ("add", "lookup", "lookup_bulk", "delete")
RING_BULK_SIZES = (8, 32, 64, 128, 256)
MEMCPY_VAR_SIZES = (
    1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 15, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128,
    129, 191, 192, 193, 255, 256, 257, 319, 320, 321, 383, 384, 385, 447, 448,
    449, 511, 512, 513, 767, 768, 769, 1023, 1024, 1025, 1518, 1522, 1536, 1600,
    2048, 2560, 3072, 3584, 4096, 4608, 5120, 5632, 6144, 6656, 7168, 7680, 8192,
)
MEMCPY_CONST_SIZES = (6, 64, 128, 192, 256, 512, 768, 1024, 1536)
MEMCPY_SCENARIOS = ("cache_to_cache", "cache_to_mem", "mem_to_cache", "mem_to_mem")
MEMCPY_EXEC_MAP = {
    "Aligned variable copy size": "aligned_variable",
    "Aligned constant copy size": "aligned_constant",
    "Unaligned variable copy size": "unaligned_variable",
    "Unaligned constant copy size": "unaligned_constant",
}

EXPECTED_HASH_METRICS = 5 * 4 * len(HASH_KEY_SIZES) * len(HASH_OPS) + 1  # 801
EXPECTED_RING_METRICS = 39 + 39 + 15  # 93
EXPECTED_MEMCPY_METRICS = (
    2 * (len(MEMCPY_VAR_SIZES) + len(MEMCPY_CONST_SIZES)) * len(MEMCPY_SCENARIOS) * 2
    + len(MEMCPY_EXEC_MAP)
)  # 1156
EXPECTED_MEMPOOL_PER_MODE = 380  # 30 random max_bulk + 350 fixed get/put bulk
EXPECTED_MEMPOOL_MIN_MODES = 3  # without_cache, with_cache, with_user_owned_cache

RING_CYCLES_RE = re.compile(
    r"^(legacy APIs|elem APIs \(size:\s*(\d+)B\))"
    r"(?:\s*-\s*(default enqueue/dequeue|SP/SC|MP/MC))?"
    r"\s*-\s*(single|bulk \(n:(\d+)\s*\)|burst \(n:(\d+)\s*\)|burst zero copy \(n:(\d+)\s*\))"
    r"\s*-\s*cycles per elem:\s*([0-9]+(?:\.[0-9]+)?)$"
)
RING_TOTAL_RE = re.compile(r"^Total count \(size:\s*(\d+)\):\s*(\d+)$")
MEMCPY_CELL_RE = re.compile(r"(\d+)\s*-\s*(\d+)\s*\(([^)]+%)\)")
MEMCPY_ROW_RE = re.compile(r"^(C)?\s*(\d+)\s+(.*)$")
MEMCPY_EXEC_RE = re.compile(r"^([A-Za-z ]+?)\s*=\s*([0-9]+(?:\.[0-9]+)?)$")
MEMPOOL_SECTION_RE = re.compile(
    r"^start performance test (?:for (\S+)|\(using ([^,]+),)\s*(without cache|with cache|with user-owned cache)\)?$"
)
MEMPOOL_MAX_RE = re.compile(
    r"^mempool_autotest\s+cache=(\d+)\s+cores=(\d+)\s+n_keep=\s*(\d+)\s+"
    r"n_max_bulk=\s*(\d+)\s+rate_persec=\s*(\d+)$"
)
MEMPOOL_FIXED_RE = re.compile(
    r"^mempool_autotest\s+cache=(\d+)\s+cores=(\d+)\s+n_keep=\s*(\d+)\s+"
    r"n_get_bulk=\s*(\d+)\s+n_put_bulk=\s*(\d+)\s+constant_n=(\d+)\s+rate_persec=\s*(\d+)$"
)


def require_complete_log(path: Path) -> str:
    if not path.is_file():
        raise ValueError(f"missing required log file: {path}")
    text = path.read_text(encoding="utf-8", errors="replace")
    if "Test Failed" in text:
        raise ValueError(f"log reports Test Failed: {path.name}")
    if "Test OK" not in text:
        raise ValueError(f"log missing Test OK completion marker: {path.name}")
    return text


def ticks_to_ns(ticks: float, tsc_hz: int) -> float:
    if not math.isfinite(ticks) or ticks < 0:
        raise ValueError(f"invalid ticks value: {ticks}")
    return round(ticks * 1_000_000_000.0 / float(tsc_hz), 6)


def parse_hash_log(text: str) -> dict[str, tuple[float, str]]:
    """Return {metric_name: (raw_ticks, subgroup)} from a single hash_perf_autotest log."""
    lock_mode: str | None = None
    loc_mode: str | None = None
    data_mode: str | None = None
    prehash_mode: str | None = None
    in_table = False
    entries: dict[str, tuple[float, str]] = {}

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line == "Without locks in the code":
            lock_mode, loc_mode, in_table = "nolock", None, False
        elif line == "With locks in the code":
            lock_mode, loc_mode, in_table = "lock", None, False
        elif line == "ALL ELEMENTS IN PRIMARY LOCATION":
            loc_mode, in_table = "primary", False
        elif line == "ELEMENTS IN PRIMARY OR SECONDARY LOCATION":
            loc_mode, in_table = "primary_or_secondary", False
        elif line == "EXTENDABLE BUCKETS PERFORMANCE":
            lock_mode, loc_mode, in_table = "ext_buckets", "primary_or_secondary", False
        elif line == "Operations without data":
            data_mode, in_table = "nodata", False
        elif line == "Operations with 8-byte data":
            data_mode, in_table = "data8", False
        elif line == "Without pre-computed hash values":
            prehash_mode, in_table = "nohash", False
        elif line == "With pre-computed hash values":
            prehash_mode, in_table = "prehash", False
        elif line.startswith("Keysize") and "Lookup_bulk" in line:
            if None in (lock_mode, loc_mode, data_mode, prehash_mode):
                raise ValueError("hash table header appeared before section context")
            in_table = True
        elif line.startswith("Number of ticks per lookup ="):
            in_table = False
            value = float(line.split("=", 1)[1].strip())
            if not math.isfinite(value) or value < 0:
                raise ValueError(f"invalid FBK hash ticks: {value}")
            key = "hash/fbk/lookup"
            if key in entries:
                raise ValueError(f"duplicate hash metric: {key}")
            entries[key] = (value, "fbk")
        elif in_table:
            parts = line.split()
            if len(parts) == 5 and all(p.isdigit() for p in parts):
                ks = int(parts[0])
                if ks not in HASH_KEY_SIZES:
                    raise ValueError(f"unexpected hash key size: {ks}")
                subgroup = f"{lock_mode}/{loc_mode}/{data_mode}/{prehash_mode}"
                for op_name, raw_val in zip(HASH_OPS, parts[1:], strict=True):
                    metric_name = f"hash/{subgroup}/key_{ks}B/{op_name}"
                    if metric_name in entries:
                        raise ValueError(f"duplicate hash metric: {metric_name}")
                    entries[metric_name] = (float(int(raw_val)), subgroup)
            else:
                in_table = False

    if len(entries) != EXPECTED_HASH_METRICS:
        raise ValueError(
            f"hash_perf_autotest expected {EXPECTED_HASH_METRICS} metrics, got {len(entries)}"
        )
    return entries


def parse_ring_log(text: str) -> dict[str, tuple[float, str, str]]:
    """Return {metric_name: (raw_value, unit_kind, subgroup)} where unit_kind is 'ticks' or 'ops_100ms'."""
    section: str | None = None
    active_esize = "legacy"
    entries: dict[str, tuple[float, str, str]] = {}

    section_headers = {
        "### Testing single element enq/deq ###": "single",
        "### Testing burst enq/deq ###": "burst",
        "### Testing bulk enq/deq ###": "bulk",
        "### Testing empty bulk deq ###": "empty_bulk_deq",
        "### Testing using two physical cores ###": "two_physical_cores",
        "### Testing using all worker nodes ###": "all_worker_nodes",
        "### Testing zero copy ###": "zc",
        "### Testing zero copy with compression (16b) ###": "zc_comp_16b",
        "### Testing zero copy with compression (32b) ###": "zc_comp_32b",
    }

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line in section_headers:
            section = section_headers[line]
            continue
        if line.startswith("### Potential gain from compression"):
            section = "compression_gain"
            continue

        m = RING_CYCLES_RE.match(line)
        if m:
            if section is None:
                raise ValueError(f"ring metric appeared outside section: {line}")
            api_raw, elem_bytes, thread_mode, op_raw, bulk_n, burst_n, zc_n, val_s = m.groups()
            esize_label = "legacy" if api_raw == "legacy APIs" else f"elem_{elem_bytes}B"
            if section in {"single", "burst", "bulk", "empty_bulk_deq", "two_physical_cores"}:
                active_esize = esize_label
            val = float(val_s)
            if not math.isfinite(val) or val < 0:
                raise ValueError(f"invalid ring cycles value: {line}")

            if section in {"zc", "zc_comp_16b", "zc_comp_32b"}:
                subgroup = f"compression/{section}"
                metric_name = f"ring/{subgroup}/n_{zc_n}"
            else:
                mode_tag = {
                    "SP/SC": "spsc",
                    "MP/MC": "mpmc",
                    "default enqueue/dequeue": "default",
                }.get(thread_mode or "", "default")
                size_val = bulk_n or burst_n or zc_n
                size_tag = "n_1" if op_raw == "single" else f"n_{size_val}"
                subgroup = f"{esize_label}/{section}"
                metric_name = f"ring/{subgroup}/{mode_tag}/{size_tag}"

            if metric_name in entries:
                raise ValueError(f"duplicate ring metric: {metric_name}")
            entries[metric_name] = (val, "ticks", subgroup)
            continue

        if section == "all_worker_nodes":
            tm = RING_TOTAL_RE.match(line)
            if tm:
                sz, count_s = int(tm.group(1)), int(tm.group(2))
                if sz not in RING_BULK_SIZES or count_s <= 0:
                    raise ValueError(f"invalid ring all_worker_nodes line: {line}")
                subgroup = f"{active_esize}/all_worker_nodes"
                metric_name = f"ring/{subgroup}/n_{sz}"
                if metric_name in entries:
                    raise ValueError(f"duplicate ring metric: {metric_name}")
                entries[metric_name] = (float(count_s), "ops_100ms", subgroup)

    if len(entries) != EXPECTED_RING_METRICS:
        raise ValueError(
            f"ring_perf_autotest expected {EXPECTED_RING_METRICS} metrics, got {len(entries)}"
        )
    return entries


def parse_memcpy_log(text: str, tsc_hz: int) -> tuple[dict[str, dict[str, Any]], dict[str, Any]]:
    align: str | None = None
    in_exec_time = False
    results: dict[str, dict[str, Any]] = {}
    raw_ticks: dict[str, list[float]] = {}
    alignment_unit: int | None = None

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        aligned_hdr = re.match(r"^=+\s*(\d+)B\s+aligned\s*=+$", line)
        if aligned_hdr:
            align = "aligned"
            alignment_unit = int(aligned_hdr.group(1))
            continue
        if re.match(r"^=+\s*Unaligned\s*=+$", line):
            align = "unaligned"
            continue
        if line == "Test Execution Time (seconds):":
            align = None
            in_exec_time = True
            continue
        if in_exec_time:
            em = MEMCPY_EXEC_RE.match(line)
            if em and em.group(1).strip() in MEMCPY_EXEC_MAP:
                slug = MEMCPY_EXEC_MAP[em.group(1).strip()]
                sec = float(em.group(2))
                if not math.isfinite(sec) or sec <= 0:
                    raise ValueError(f"invalid memcpy execution time: {line}")
                metric_name = f"memcpy/execution_time/{slug}"
                if metric_name in results:
                    raise ValueError(f"duplicate memcpy metric: {metric_name}")
                results[metric_name] = {
                    "value": round(sec, 6),
                    "unit": "s",
                    "direction": "lower_is_better",
                    "group": "memcpy_perf_autotest",
                    "subgroup": "execution_time",
                }
            continue
        if align is not None:
            rm = MEMCPY_ROW_RE.match(line)
            if not rm:
                continue
            is_const, size_s, rest = rm.groups()
            cells = MEMCPY_CELL_RE.findall(rest)
            if len(cells) != 4:
                continue
            size = int(size_s)
            kind = "constant" if is_const else "variable"
            valid_sizes = MEMCPY_CONST_SIZES if is_const else MEMCPY_VAR_SIZES
            if size not in valid_sizes:
                raise ValueError(f"unexpected memcpy {kind} size: {size}")
            subgroup = f"{align}/{kind}"
            for scenario, (rte_s, std_s, _pct) in zip(MEMCPY_SCENARIOS, cells, strict=True):
                rte_ticks = float(int(rte_s))
                std_ticks = float(int(std_s))
                rte_key = f"memcpy/{subgroup}/{size}B/{scenario}/rte_memcpy"
                std_key = f"memcpy/{subgroup}/{size}B/{scenario}/glibc_memcpy"
                if rte_key in results or std_key in results:
                    raise ValueError(f"duplicate memcpy metric for {align}/{kind}/{size}B/{scenario}")
                results[rte_key] = {
                    "value": ticks_to_ns(rte_ticks, tsc_hz),
                    "unit": "ns",
                    "direction": "lower_is_better",
                    "group": "memcpy_perf_autotest",
                    "subgroup": subgroup,
                }
                results[std_key] = {
                    "value": ticks_to_ns(std_ticks, tsc_hz),
                    "unit": "ns",
                    "direction": "lower_is_better",
                    "group": "memcpy_perf_autotest",
                    "subgroup": subgroup,
                }
                raw_ticks[f"{align}/{kind}/{size}B/{scenario}"] = [rte_ticks, std_ticks]

    if len(results) != EXPECTED_MEMCPY_METRICS:
        raise ValueError(
            f"memcpy_perf_autotest expected {EXPECTED_MEMCPY_METRICS} metrics, got {len(results)}"
        )
    return results, {"alignment_unit_bytes": alignment_unit, "raw_ticks_sample_count": len(raw_ticks)}


def parse_mempool_log(text: str) -> tuple[dict[str, dict[str, Any]], dict[str, Any]]:
    handler: str | None = None
    mode: str | None = None
    mode_counts: dict[str, int] = {}
    results: dict[str, dict[str, Any]] = {}

    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        sm = MEMPOOL_SECTION_RE.match(line)
        if sm:
            handler = (sm.group(1) or sm.group(2) or "").strip()
            mode = sm.group(3).strip().replace(" ", "_").replace("-", "_")
            mode_counts.setdefault(f"{handler}/{mode}", 0)
            continue

        mm = MEMPOOL_MAX_RE.match(line)
        if mm:
            if not handler or not mode:
                raise ValueError(f"mempool row outside section: {line}")
            cache, cores, n_keep, n_max_bulk, rate = (int(v) for v in mm.groups())
            if cores != 1 or rate <= 0:
                raise ValueError(f"invalid mempool 1core row: {line}")
            subgroup = f"{handler}/{mode}"
            metric_name = f"mempool/{subgroup}/cache_{cache}/keep_{n_keep}/max_bulk_{n_max_bulk}"
            if metric_name in results:
                raise ValueError(f"duplicate mempool metric: {metric_name}")
            results[metric_name] = {
                "value": rate,
                "unit": "ops/s",
                "direction": "higher_is_better",
                "group": "mempool_perf_autotest_1core",
                "subgroup": subgroup,
            }
            mode_counts[subgroup] = mode_counts.get(subgroup, 0) + 1
            continue

        fm = MEMPOOL_FIXED_RE.match(line)
        if fm:
            if not handler or not mode:
                raise ValueError(f"mempool row outside section: {line}")
            cache, cores, n_keep, n_get, n_put, const_n, rate = (int(v) for v in fm.groups())
            if cores != 1 or rate <= 0:
                raise ValueError(f"invalid mempool 1core row: {line}")
            subgroup = f"{handler}/{mode}"
            metric_name = (
                f"mempool/{subgroup}/cache_{cache}/keep_{n_keep}/"
                f"get_{n_get}_put_{n_put}_const_{const_n}"
            )
            if metric_name in results:
                raise ValueError(f"duplicate mempool metric: {metric_name}")
            results[metric_name] = {
                "value": rate,
                "unit": "ops/s",
                "direction": "higher_is_better",
                "group": "mempool_perf_autotest_1core",
                "subgroup": subgroup,
            }
            mode_counts[subgroup] = mode_counts.get(subgroup, 0) + 1

    if len(mode_counts) < EXPECTED_MEMPOOL_MIN_MODES:
        raise ValueError(
            f"mempool_perf_autotest_1core expected at least {EXPECTED_MEMPOOL_MIN_MODES} modes, "
            f"got {list(mode_counts)}"
        )
    for subgroup, count in mode_counts.items():
        if count != EXPECTED_MEMPOOL_PER_MODE:
            raise ValueError(
                f"mempool mode {subgroup} expected {EXPECTED_MEMPOOL_PER_MODE} rows, got {count}"
            )
    return results, {"modes": mode_counts}


def aggregate_repeats(
    runs: list[dict[str, tuple[float, str]]],
    tsc_hz: int,
    group: str,
    unit: str,
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    keys = list(runs[0])
    for idx, run in enumerate(runs[1:], start=2):
        if list(run) != keys:
            raise ValueError(f"{group} run {idx} metric keys differ from run 1")
    results: dict[str, dict[str, Any]] = {}
    repeat_stats: dict[str, dict[str, Any]] = {}
    for key in keys:
        subgroup = runs[0][key][1]
        raw_vals = [run[key][0] for run in runs]
        ns_vals = [ticks_to_ns(v, tsc_hz) for v in raw_vals]
        results[key] = {
            "value": round(float(statistics.median(ns_vals)), 6),
            "unit": unit,
            "direction": "lower_is_better",
            "group": group,
            "subgroup": subgroup,
        }
        repeat_stats[key] = {
            "raw_ticks": raw_vals,
            "min_ns": min(ns_vals),
            "max_ns": max(ns_vals),
        }
    return results, repeat_stats


def aggregate_ring_repeats(
    runs: list[dict[str, tuple[float, str, str]]],
    tsc_hz: int,
) -> tuple[dict[str, dict[str, Any]], dict[str, dict[str, Any]]]:
    keys = list(runs[0])
    for idx, run in enumerate(runs[1:], start=2):
        if list(run) != keys:
            raise ValueError(f"ring_perf_autotest run {idx} metric keys differ from run 1")
    results: dict[str, dict[str, Any]] = {}
    repeat_stats: dict[str, dict[str, Any]] = {}
    for key in keys:
        unit_kind = runs[0][key][1]
        subgroup = runs[0][key][2]
        raw_vals = [run[key][0] for run in runs]
        if unit_kind == "ticks":
            conv_vals = [ticks_to_ns(v, tsc_hz) for v in raw_vals]
            results[key] = {
                "value": round(float(statistics.median(conv_vals)), 6),
                "unit": "ns/elem",
                "direction": "lower_is_better",
                "group": "ring_perf_autotest",
                "subgroup": subgroup,
            }
            repeat_stats[key] = {
                "raw_ticks": raw_vals,
                "min_ns": min(conv_vals),
                "max_ns": max(conv_vals),
            }
        else:
            results[key] = {
                "value": round(float(statistics.median(raw_vals)), 6),
                "unit": "ops/100ms",
                "direction": "higher_is_better",
                "group": "ring_perf_autotest",
                "subgroup": subgroup,
            }
            repeat_stats[key] = {
                "raw_counts": raw_vals,
                "min": min(raw_vals),
                "max": max(raw_vals),
            }
    return results, repeat_stats


def parse_all_benchmarks(
    *,
    logs_dir: Path,
    tsc_hz: int,
    source_md5: str,
    source_sha256: str,
    cache_line_size: int,
    cpu_selection: dict[str, Any],
    mem_mb: int,
) -> dict[str, Any]:
    if tsc_hz <= 0:
        raise ValueError(f"invalid tsc_hz: {tsc_hz}")
    md5 = source_md5.strip().lower()
    sha = source_sha256.strip().lower()
    if len(md5) != 32 or any(c not in "0123456789abcdef" for c in md5):
        raise ValueError(f"invalid source MD5: {source_md5!r}")
    if len(sha) != 64 or any(c not in "0123456789abcdef" for c in sha):
        raise ValueError(f"invalid source SHA-256: {source_sha256!r}")

    # Verify warmup logs completed cleanly (not included in metrics)
    require_complete_log(logs_dir / "hash-warmup.log")
    require_complete_log(logs_dir / "ring-warmup.log")

    hash_runs = [parse_hash_log(require_complete_log(logs_dir / f"hash-run{i}.log")) for i in (1, 2, 3)]
    ring_runs = [parse_ring_log(require_complete_log(logs_dir / f"ring-run{i}.log")) for i in (1, 2, 3)]
    memcpy_text = require_complete_log(logs_dir / "memcpy-1core.log")
    mempool_text = require_complete_log(logs_dir / "mempool-1core.log")

    hash_results, hash_repeats = aggregate_repeats(hash_runs, tsc_hz, "hash_perf_autotest", "ns/op")
    ring_results, ring_repeats = aggregate_ring_repeats(ring_runs, tsc_hz)
    memcpy_results, memcpy_meta = parse_memcpy_log(memcpy_text, tsc_hz)
    mempool_results, mempool_meta = parse_mempool_log(mempool_text)

    combined_results: dict[str, dict[str, Any]] = {}
    for block in (hash_results, ring_results, memcpy_results, mempool_results):
        for name, item in block.items():
            if name in combined_results:
                raise ValueError(f"duplicate metric across suites: {name}")
            combined_results[name] = item

    return {
        "parameters": {
            "build_platform": "generic",
            "build_type": "release",
            "default_library": "static",
            "dpdk_version": "26.11.0",
            "eal_mem_mb": mem_mb,
            "eal_memory_mode": "no-huge",
            "eal_pci_mode": "no-pci",
            "hash_cores": 1,
            "hash_formal_runs": 3,
            "hash_warmup_runs": 1,
            "memcpy_cores": 1,
            "memcpy_formal_runs": 1,
            "mempool_cores": 1,
            "mempool_formal_runs": 1,
            "numa_membind": "disabled",
            "ring_cores": 2,
            "ring_formal_runs": 3,
            "ring_warmup_runs": 1,
            "source_archive": "dpdk-26.11.tar.xz",
            "source_md5": md5,
            "source_sha256": sha,
            "suites": [
                "hash_perf_autotest",
                "ring_perf_autotest",
                "memcpy_perf_autotest",
                "mempool_perf_autotest_1core",
            ],
            "ticks_conversion": "ns = ticks * 1e9 / rte_get_tsc_hz",
        },
        "runtime_context": {
            "cpu_selection": cpu_selection,
            "tsc_hz": tsc_hz,
            "rte_cache_line_size": cache_line_size,
            "memcpy_meta": memcpy_meta,
            "mempool_meta": mempool_meta,
            "metric_counts": {
                "hash_perf_autotest": len(hash_results),
                "ring_perf_autotest": len(ring_results),
                "memcpy_perf_autotest": len(memcpy_results),
                "mempool_perf_autotest_1core": len(mempool_results),
                "total": len(combined_results),
            },
            "hash_repeats": hash_repeats,
            "ring_repeats": ring_repeats,
        },
        "results": combined_results,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--logs-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--tsc-hz", type=int, required=True)
    parser.add_argument("--source-md5", required=True)
    parser.add_argument("--source-sha256", required=True)
    parser.add_argument("--cache-line-size", type=int, required=True)
    parser.add_argument("--cpu-selection", type=Path, required=True)
    parser.add_argument("--mem-mb", type=int, default=4096)
    args = parser.parse_args()

    cpu_selection = json.loads(args.cpu_selection.read_text(encoding="utf-8"))
    payload = parse_all_benchmarks(
        logs_dir=args.logs_dir,
        tsc_hz=args.tsc_hz,
        source_md5=args.source_md5,
        source_sha256=args.source_sha256,
        cache_line_size=args.cache_line_size,
        cpu_selection=cpu_selection,
        mem_mb=args.mem_mb,
    )
    args.output.write_text(
        json.dumps(payload, indent=2, sort_keys=True, allow_nan=False) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
