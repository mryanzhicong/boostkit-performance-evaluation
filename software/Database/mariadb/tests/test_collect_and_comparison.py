"""Validate MariaDB Sysbench collection, standalone report, and dual-arch matrix comparison."""

from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
CASE_DIR = Path(__file__).resolve().parents[1]
COLLECTOR_PATH = CASE_DIR / "scripts/results/collect_sysbench.py"
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


COLLECTOR = _load("mariadb_collect_sysbench", COLLECTOR_PATH)
STANDALONE = _load("mariadb_standalone_runtime", RUNTIME_PATH)


def sample_sysbench_log(tps: float, qps: float, p95: float) -> str:
    return (
        "SQL statistics:\n"
        "    queries performed:\n"
        "        read:                            100000\n"
        "        write:                           0\n"
        "        other:                           20000\n"
        "        total:                           120000\n"
        f"    transactions:                        60000  ({tps:.2f} per sec.)\n"
        f"    queries:                             120000 ({qps:.2f} per sec.)\n"
        "    ignored errors:                      0      (0.00 per sec.)\n"
        "    reconnects:                          0      (0.00 per sec.)\n"
        "\n"
        "Latency (ms):\n"
        "         min:                                    0.42\n"
        "         avg:                                    1.20\n"
        "         max:                                   12.50\n"
        f"         95th percentile:                       {p95:.2f}\n"
        "         sum:                                72000.00\n"
    )


def populate_runs(runs_dir: Path, scale: float = 1.0) -> None:
    runs_dir.mkdir(parents=True, exist_ok=True)
    for scenario in ("read_only", "read_write", "write_only"):
        (runs_dir / f"warmup-{scenario}.log").write_text(
            sample_sysbench_log(999.0, 9999.0, 5.0), encoding="utf-8"
        )
        for threads in (1, 32, 128, 256):
            tps = (1000.0 + threads * 10.0) * scale
            qps = tps * 16.0
            p95 = max(0.5, 20.0 / scale)
            (runs_dir / f"run-{scenario}-threads{threads}.log").write_text(
                sample_sysbench_log(tps, qps, p95), encoding="utf-8"
            )


def test_collect_all_36_metrics_and_ignore_warmups(tmp_path: Path) -> None:
    runs_dir = tmp_path / "sysbench-runs"
    populate_runs(runs_dir)
    results = COLLECTOR.collect(runs_dir)
    assert len(results) == 36
    sample = results["sysbench read_only --threads=256: TPS"]
    assert sample["scenario"] == "read_only"
    assert sample["threads"] == 256
    assert sample["source_field"] == "TPS"
    assert sample["unit"] == "transactions/s"
    assert sample["direction"] == "higher_is_better"


def test_collect_rejects_missing_or_fatal_run(tmp_path: Path) -> None:
    runs_dir = tmp_path / "sysbench-runs"
    populate_runs(runs_dir)
    (runs_dir / "run-write_only-threads256.log").unlink()
    with pytest.raises(ValueError, match="missing 1 Sysbench runs"):
        COLLECTOR.collect(runs_dir)

    populate_runs(runs_dir)
    target = runs_dir / "run-read_write-threads128.log"
    target.write_text(target.read_text(encoding="utf-8") + "FATAL: connection lost\n", encoding="utf-8")
    with pytest.raises(ValueError, match="FATAL"):
        COLLECTOR.collect(runs_dir)


def test_dual_architecture_matrix_normalization_and_comparison(tmp_path: Path) -> None:
    case, errors = catalog.validate_case(CASE_DIR / "case.yaml", REPO_ROOT)
    assert errors == []
    assert case is not None

    normalized_by_arch = {}
    for arch, scale in (("x86_64", 1.0), ("aarch64", 1.15)):
        work_dir = tmp_path / "work" / arch
        out_dir = tmp_path / "out" / arch
        work_dir.mkdir(parents=True)
        out_dir.mkdir(parents=True)
        ctx = fw_context.RunContext(
            root=REPO_ROOT,
            case_path=CASE_DIR / "case.yaml",
            case=case,
            category="Database",
            software="mariadb",
            version="11.8.10",
            architecture=arch,
            run_id=f"preflight-{arch}",
            work_dir=work_dir,
            output_dir=out_dir,
        )
        (work_dir / "actual-version.txt").write_text("11.8.10\n", encoding="utf-8")
        build_info.record_build_info(ctx)
        (out_dir / "build_variant.json").write_text(
            json.dumps({"variant": "base", "parameters": {"variant": "base"}}) + "\n",
            encoding="utf-8",
        )
        (out_dir / "sysbench_raw.log").write_text("# raw sysbench log\n", encoding="utf-8")
        runs_dir = out_dir / "sysbench-runs"
        populate_runs(runs_dir, scale=scale)

        env = os.environ.copy()
        env.update({"SOFTWARE_VERSION": "11.8.10", "EXPECTED_ARCH": arch, "PERF_VARIANT": "base"})
        proc = subprocess.run(
            [sys.executable, str(COLLECTOR_PATH), str(runs_dir), str(out_dir / "results.json")],
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )
        assert proc.returncode == 0, proc.stderr
        normalized = normalize_results.normalize(ctx, command_status="passed")
        assert normalized["status"] == "passed"
        assert len(normalized["metrics"]) == 36
        normalized_by_arch[arch] = normalized

    compared = generate_comparison.compare_pair(
        normalized_by_arch["x86_64"], normalized_by_arch["aarch64"]
    )
    assert compared["software"] == "mariadb"
    assert compared["version"] == "11.8.10"
    assert len(compared["metrics"]) == 36
    tps = compared["metrics"]["sysbench read_only --threads=256: TPS"]
    assert tps["relative_performance"] == 1.15
    assert tps["matrix"]["group"] == "read_only"
    assert tps["matrix"]["row"] == 256
    assert tps["matrix"]["column"] == "TPS"

    summary = generate_comparison.build_summary(list(normalized_by_arch.values()), [compared])
    md = reporting.render_summary(summary, [compared])
    assert "mariadb" in md
    assert "read_only" in md
    assert "P95 latency" in md

    rc = STANDALONE.finalize(
        tmp_path / "out" / "x86_64", "11.8.10", "x86_64", "standalone-1", "passed", "passed", ""
    )
    assert rc == 0
    assert len(json.loads((tmp_path / "out" / "x86_64" / "results.json").read_text())["metrics"]) == 36
