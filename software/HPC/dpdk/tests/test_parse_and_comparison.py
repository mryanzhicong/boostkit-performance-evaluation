"""Validate DPDK 26.11.0 log parsing, CPU selection, ticks->ns conversion, and dual-arch comparison."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
CASE_DIR = Path(__file__).resolve().parents[1]
PARSER_PATH = CASE_DIR / "scripts/results/parse_benchmark.py"
SELECT_PATH = CASE_DIR / "scripts/results/select_cpus.py"
RUNTIME_PATH = CASE_DIR / "scripts/results/standalone_runtime.py"

if str(REPO_ROOT / "framework") not in sys.path:
    sys.path.insert(0, str(REPO_ROOT / "framework"))

import build_info  # noqa: E402
import catalog  # noqa: E402
import context as fw_context  # noqa: E402
import generate_comparison  # noqa: E402
import normalize_results  # noqa: E402
import reporting  # noqa: E402


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


PARSER = _load("dpdk_parse_benchmark", PARSER_PATH)
SELECT = _load("dpdk_select_cpus", SELECT_PATH)
STANDALONE = _load("dpdk_standalone_runtime", RUNTIME_PATH)

SOURCE_MD5 = "061ed6050c8d0e6c407ce0b270dd39c3"
SOURCE_SHA = "b" * 64


def generate_hash_log(base_ticks: int, fbk_ticks: float) -> str:
    lines = ["EAL: Detected CPU lcores: 1"]
    outer_blocks = [
        ("Without locks in the code", "ALL ELEMENTS IN PRIMARY LOCATION"),
        (None, "ELEMENTS IN PRIMARY OR SECONDARY LOCATION"),
        ("With locks in the code", "ALL ELEMENTS IN PRIMARY LOCATION"),
        (None, "ELEMENTS IN PRIMARY OR SECONDARY LOCATION"),
        ("EXTENDABLE BUCKETS PERFORMANCE", None),
    ]
    for lock_hdr, loc_hdr in outer_blocks:
        if lock_hdr:
            lines.append(lock_hdr)
        if loc_hdr:
            lines.append(loc_hdr)
        lines.append("Measuring performance, please wait....")
        lines.append("Results (in CPU cycles/operation)")
        lines.append("-----------------------------------")
        for data_hdr in ("Operations without data", "Operations with 8-byte data"):
            lines.append(data_hdr)
            for pre_hdr in ("Without pre-computed hash values", "With pre-computed hash values"):
                lines.append(pre_hdr)
                lines.append(f"{'Keysize':<18}{'Add':<18}{'Lookup':<18}{'Lookup_bulk':<18}{'Delete':<18}")
                for ks in PARSER.HASH_KEY_SIZES:
                    lines.append(
                        f"{ks:<18}{base_ticks:<18}{base_ticks + 2:<18}{base_ticks + 1:<18}{base_ticks + 3:<18}"
                    )
    lines.append("*** FBK Hash function performance test results ***")
    lines.append(f"Number of ticks per lookup = {fbk_ticks:g}")
    lines.append("Test OK")
    return "\n".join(lines) + "\n"


def generate_ring_log(base_cycles: float, base_count: int) -> str:
    lines = ["EAL: Detected CPU lcores: 2"]
    for api in ("legacy APIs", "elem APIs (size:16B)"):
        lines.append("### Testing single element enq/deq ###")
        lines.append(f"{api} - SP/SC - single - cycles per elem: {base_cycles:.3f}")
        lines.append(f"{api} - MP/MC - single - cycles per elem: {base_cycles + 1.0:.3f}")
        lines.append("### Testing burst enq/deq ###")
        for mode in ("SP/SC", "MP/MC"):
            for bsz in PARSER.RING_BULK_SIZES:
                lines.append(f"{api} - {mode} - burst (n:{bsz:<3}) - cycles per elem: {base_cycles + 0.5:.3f}")
        lines.append("### Testing bulk enq/deq ###")
        for mode in ("SP/SC", "MP/MC"):
            for bsz in PARSER.RING_BULK_SIZES:
                lines.append(f"{api} - {mode} - bulk (n:{bsz:<3}) - cycles per elem: {base_cycles + 0.4:.3f}")
        lines.append("### Testing empty bulk deq ###")
        lines.append(f"{api} - SP/SC - bulk (n:8  ) - cycles per elem: {base_cycles * 0.5:.3f}")
        lines.append(f"{api} - MP/MC - bulk (n:8  ) - cycles per elem: {base_cycles * 0.6:.3f}")
        for mode in ("SP/SC", "MP/MC"):
            lines.append("### Testing using two physical cores ###")
            for bsz in PARSER.RING_BULK_SIZES:
                lines.append(f"{api} - {mode} - bulk (n:{bsz:<3}) - cycles per elem: {base_cycles + 2.0:.3f}")
        lines.append("### Testing using all worker nodes ###")
        for bsz in PARSER.RING_BULK_SIZES:
            lines.append(f"Bulk enq/dequeue count on size {bsz}")
            lines.append(f"Core [2] count = {base_count}")
            lines.append(f"Core [3] count = {base_count}")
            lines.append(f"Total count (size: {bsz}): {base_count * 2}")

    lines.append("### Testing compression gain ###")
    for hdr, elem_sz in (
        ("### Testing zero copy ###", 8),
        ("### Testing zero copy with compression (16b) ###", 4),
        ("### Testing zero copy with compression (32b) ###", 4),
    ):
        lines.append(hdr)
        for bsz in PARSER.RING_BULK_SIZES:
            lines.append(
                f"elem APIs (size:{elem_sz:2d}B) - burst zero copy (n:{bsz:<3}) - cycles per elem: {base_cycles + 1.5:.3f}"
            )
    lines.append("### Potential gain from compression (16-bit offsets) ###")
    for bsz in PARSER.RING_BULK_SIZES:
        lines.append(f"Gain of  12.5% for burst of {bsz:<3} elems")
    lines.append("Test OK")
    return "\n".join(lines) + "\n"


def generate_memcpy_log(rte_ticks: int, std_ticks: int, *, zero_small: bool = False) -> str:
    lines = [
        "** rte_memcpy() - memcpy perf. tests (C = compile-time constant) **",
        "======= ================= ================= ================= =================",
        "   Size   Cache to cache     Cache to mem      Mem to cache        Mem to mem",
        "(bytes)          (ticks)          (ticks)           (ticks)           (ticks)",
        "------- ----------------- ----------------- ----------------- -----------------",
    ]
    for align_hdr in (
        "================================= 16B aligned =================================",
        "================================== Unaligned ==================================",
    ):
        lines.append(align_hdr)
        for sz in PARSER.MEMCPY_VAR_SIZES:
            if zero_small and sz <= 16:
                cell = "  0 -  0(  nan%) "
            else:
                cell = f"{rte_ticks:3d} -{std_ticks:3d}(-10.00%) "
            lines.append(f"{sz:7d}" + cell * 4)
        lines.append("------- ----------------- ----------------- ----------------- -----------------")
        for sz in PARSER.MEMCPY_CONST_SIZES:
            cell = f"{rte_ticks:3d} -{std_ticks:3d}(-10.00%) "
            lines.append(f"C{sz:6d}" + cell * 4)
    lines.extend(
        [
            "======= ================= ================= ================= =================",
            "Test Execution Time (seconds):",
            "Aligned variable copy size   =   12.345",
            "Aligned constant copy size   =    1.234",
            "Unaligned variable copy size =   13.456",
            "Unaligned constant copy size =    1.345",
            "Test OK",
        ]
    )
    return "\n".join(lines) + "\n"


def generate_mempool_log(cache_line_burst: int, base_rate: int) -> str:
    lines = ["EAL: Detected CPU lcores: 1"]
    bulk_max = (cache_line_burst, 32, 64, 128, 256, 512)
    bulk_gp = (1, 4, cache_line_burst, 32, 64, 128, 256, 512)
    keep_tab = (32, 128, 512, 2048, 8192, 32768)
    modes = [
        ("start performance test (using ring_mp_mc, without cache)", 0),
        ("start performance test (using ring_mp_mc, with cache)", 512),
        ("start performance test (using ring_mp_mc, with user-owned cache)", 512),
    ]
    for hdr, cache in modes:
        lines.append(hdr)
        for keep in keep_tab:
            for mb in bulk_max:
                if keep < mb:
                    continue
                lines.append(
                    f"mempool_autotest cache={cache} cores=1 n_keep={keep:5d} "
                    f"n_max_bulk={mb:3d} rate_persec={base_rate:10d}"
                )
        for keep in keep_tab:
            for gb in bulk_gp:
                for pb in bulk_gp:
                    if keep < gb or keep < pb:
                        continue
                    lines.append(
                        f"mempool_autotest cache={cache} cores=1 n_keep={keep:5d} "
                        f"n_get_bulk={gb:3d} n_put_bulk={pb:3d} constant_n=0 rate_persec={base_rate:10d}"
                    )
                    if gb == pb:
                        lines.append(
                            f"mempool_autotest cache={cache} cores=1 n_keep={keep:5d} "
                            f"n_get_bulk={gb:3d} n_put_bulk={pb:3d} constant_n=1 rate_persec={base_rate + 1000:10d}"
                        )
    lines.append("Test OK")
    return "\n".join(lines) + "\n"


def populate_logs(
    logs_dir: Path,
    *,
    hash_ticks: tuple[int, int, int],
    ring_cycles: tuple[float, float, float],
    ring_count: int,
    memcpy_ticks: tuple[int, int],
    zero_small_memcpy: bool,
    cache_line_burst: int,
    mempool_rate: int,
) -> None:
    logs_dir.mkdir(parents=True, exist_ok=True)
    (logs_dir / "hash-warmup.log").write_text(generate_hash_log(hash_ticks[0], 10.0), encoding="utf-8")
    for idx, ticks in enumerate(hash_ticks, start=1):
        (logs_dir / f"hash-run{idx}.log").write_text(
            generate_hash_log(ticks, float(ticks) + 0.5), encoding="utf-8"
        )
    (logs_dir / "ring-warmup.log").write_text(generate_ring_log(ring_cycles[0], ring_count), encoding="utf-8")
    for idx, cyc in enumerate(ring_cycles, start=1):
        (logs_dir / f"ring-run{idx}.log").write_text(
            generate_ring_log(cyc, ring_count + idx * 100), encoding="utf-8"
        )
    (logs_dir / "memcpy-1core.log").write_text(
        generate_memcpy_log(memcpy_ticks[0], memcpy_ticks[1], zero_small=zero_small_memcpy),
        encoding="utf-8",
    )
    (logs_dir / "mempool-1core.log").write_text(
        generate_mempool_log(cache_line_burst, mempool_rate), encoding="utf-8"
    )


def test_select_cpus_skips_smt_sibling_and_respects_allowed_list() -> None:
    lscpu_smt = "\n".join(
        [
            "# CPU,CORE,SOCKET,NODE,ONLINE",
            "0,0,0,0,Y",
            "1,0,0,0,Y",  # SMT sibling of CPU 0
            "2,1,0,0,Y",
            "3,1,0,0,Y",  # SMT sibling of CPU 2
            "4,2,0,0,Y",
            "5,3,1,1,Y",  # NUMA 1
        ]
    )
    sel = SELECT.select_numa0_physical_cpus(lscpu_smt, allowed_cpus={0, 1, 2, 3, 4, 5}, min_cores=2)
    assert sel["numa_node"] == 0
    assert sel["bench_cpu"] == "2"
    assert sel["bench_pair"] == "2,4"
    assert sel["available_numa0_physical_cores"] == 3

    # Restrict allowed CPUs to only 1 physical core on NUMA 0 -> must fail
    with pytest.raises(ValueError, match="at least 2"):
        SELECT.select_numa0_physical_cpus(lscpu_smt, allowed_cpus={0, 1, 5}, min_cores=2)


def test_parser_computes_median_and_converts_ticks_to_ns(tmp_path: Path) -> None:
    logs_dir = tmp_path / "logs"
    # ARM64 100 MHz: 1 tick == 10 ns. Hash runs have ticks 10, 14, 12 -> median 12 ticks == 120.0 ns!
    populate_logs(
        logs_dir,
        hash_ticks=(10, 14, 12),
        ring_cycles=(2.0, 4.0, 3.0),
        ring_count=100_000,
        memcpy_ticks=(9, 10),
        zero_small_memcpy=True,
        cache_line_burst=16,
        mempool_rate=500_000_000,
    )
    parsed = PARSER.parse_all_benchmarks(
        logs_dir=logs_dir,
        tsc_hz=100_000_000,
        source_md5=SOURCE_MD5,
        source_sha256=SOURCE_SHA,
        cache_line_size=128,
        cpu_selection={"numa_node": 0, "bench_cpu": "2", "bench_pair": "2,3"},
        mem_mb=4096,
    )
    counts = parsed["runtime_context"]["metric_counts"]
    assert counts["hash_perf_autotest"] == 801
    assert counts["ring_perf_autotest"] == 93
    assert counts["memcpy_perf_autotest"] == 1156
    assert counts["mempool_perf_autotest_1core"] == 1140
    assert counts["total"] == 3190

    h_item = parsed["results"]["hash/nolock/primary/nodata/nohash/key_13B/add"]
    assert h_item["value"] == 120.0
    assert h_item["unit"] == "ns/op"
    assert h_item["direction"] == "lower_is_better"
    assert parsed["runtime_context"]["hash_repeats"]["hash/nolock/primary/nodata/nohash/key_13B/add"] == {
        "raw_ticks": [10.0, 14.0, 12.0],
        "min_ns": 100.0,
        "max_ns": 140.0,
    }

    r_item = parsed["results"]["ring/legacy/single/spsc/n_1"]
    assert r_item["value"] == 30.0
    assert r_item["unit"] == "ns/elem"

    m_zero = parsed["results"]["memcpy/aligned/variable/1B/cache_to_cache/rte_memcpy"]
    assert m_zero["value"] == 0.0
    assert m_zero["unit"] == "ns"


def test_parser_rejects_failed_or_incomplete_logs(tmp_path: Path) -> None:
    logs_dir = tmp_path / "logs"
    populate_logs(
        logs_dir,
        hash_ticks=(10, 12, 11),
        ring_cycles=(2.0, 2.5, 2.2),
        ring_count=100_000,
        memcpy_ticks=(9, 10),
        zero_small_memcpy=False,
        cache_line_burst=8,
        mempool_rate=500_000_000,
    )
    (logs_dir / "hash-run2.log").write_text("Test Failed\n", encoding="utf-8")
    with pytest.raises(ValueError, match="Test Failed"):
        PARSER.parse_all_benchmarks(
            logs_dir=logs_dir,
            tsc_hz=2_000_000_000,
            source_md5=SOURCE_MD5,
            source_sha256=SOURCE_SHA,
            cache_line_size=64,
            cpu_selection={"numa_node": 0, "bench_cpu": "2", "bench_pair": "2,3"},
            mem_mb=4096,
        )


def test_dual_architecture_normalization_and_comparison_pair_cleanly(tmp_path: Path) -> None:
    """Preflight Framework normalize + compare_pair + render_summary across x86_64 (2.3GHz, 64B CL) & aarch64 (100MHz, 128B CL)."""
    case, errors = catalog.validate_case(CASE_DIR / "case.yaml", REPO_ROOT)
    assert errors == []
    assert case is not None

    normalized_by_arch = {}
    arch_specs = [
        ("x86_64", 2_300_000_000, 64, 8, (115, 120, 118), (46.0, 48.0, 47.0), 120_000, (18, 20), False, 620_000_000, {"numa_node": 0, "bench_cpu": "2", "bench_pair": "2,4"}),
        ("aarch64", 100_000_000, 128, 16, (5, 6, 5), (2.1, 2.3, 2.2), 135_000, (1, 1), True, 710_000_000, {"numa_node": 0, "bench_cpu": "1", "bench_pair": "1,2"}),
    ]
    for arch, tsc_hz, cl, cl_burst, h_ticks, r_cyc, r_cnt, m_ticks, z_small, mp_rate, cpu_sel in arch_specs:
        work_dir = tmp_path / "work" / arch
        out_dir = tmp_path / "out" / arch
        work_dir.mkdir(parents=True)
        out_dir.mkdir(parents=True)
        ctx = fw_context.RunContext(
            root=REPO_ROOT,
            case_path=CASE_DIR / "case.yaml",
            case=case,
            category="HPC",
            software="dpdk",
            version="26.11.0",
            architecture=arch,
            run_id=f"preflight-{arch}",
            work_dir=work_dir,
            output_dir=out_dir,
        )
        (work_dir / "actual-version.txt").write_text("26.11.0\n", encoding="utf-8")
        build_info.record_build_info(ctx)
        (out_dir / "build_variant.json").write_text(
            json.dumps({"variant": "base", "parameters": {"variant": "base"}}) + "\n",
            encoding="utf-8",
        )
        (out_dir / "smoke.log").write_text(
            f"EAL: TSC frequency is ~{tsc_hz // 1000} KHz\nDPDK 26.11.0\nTest OK\n",
            encoding="utf-8",
        )
        logs_dir = out_dir / "logs"
        populate_logs(
            logs_dir,
            hash_ticks=h_ticks,
            ring_cycles=r_cyc,
            ring_count=r_cnt,
            memcpy_ticks=m_ticks,
            zero_small_memcpy=z_small,
            cache_line_burst=cl_burst,
            mempool_rate=mp_rate,
        )
        parsed = PARSER.parse_all_benchmarks(
            logs_dir=logs_dir,
            tsc_hz=tsc_hz,
            source_md5=SOURCE_MD5,
            source_sha256=SOURCE_SHA,
            cache_line_size=cl,
            cpu_selection=cpu_sel,
            mem_mb=4096,
        )
        (out_dir / "benchmark_dpdk.json").write_text(json.dumps(parsed), encoding="utf-8")
        normalized = normalize_results.normalize(ctx, command_status="passed")
        assert normalized["status"] == "passed"
        normalized_by_arch[arch] = normalized

    compared = generate_comparison.compare_pair(
        normalized_by_arch["x86_64"], normalized_by_arch["aarch64"]
    )
    assert compared["software"] == "dpdk"
    assert compared["version"] == "26.11.0"
    h_cmp = compared["metrics"]["hash/nolock/primary/nodata/nohash/key_13B/add"]
    assert h_cmp["unit"] == "ns/op"
    assert h_cmp["direction"] == "lower_is_better"
    assert h_cmp["x86_64"] == round(118 * 1e9 / 2_300_000_000, 6)
    assert h_cmp["aarch64"] == 50.0
    assert h_cmp["relative_performance"] is not None

    # Shared mempool bulk=32 pairs 1:1 across both architectures
    mp_shared = compared["metrics"]["mempool/ring_mp_mc/with_cache/cache_512/keep_512/get_32_put_32_const_0"]
    assert mp_shared["x86_64"] == 620_000_000
    assert mp_shared["aarch64"] == 710_000_000

    summary = generate_comparison.build_summary(list(normalized_by_arch.values()), [compared])
    md = reporting.render_summary(summary, [compared], detail=False)
    assert "dpdk" in md
    assert "26.11.0" in md

    # Also verify standalone finalize
    rc = STANDALONE.finalize(
        tmp_path / "out" / "x86_64", "26.11.0", "x86_64", "standalone-1", "passed", "passed", ""
    )
    assert rc == 0
    assert len(json.loads((tmp_path / "out" / "x86_64" / "results.json").read_text())["metrics"]) == 3190
