"""Checks for the official Nexmark table and two-stage workload contract."""

from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import pytest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/run_nexmark.py"
PARSER_SCRIPT = SCRIPT.parent / "results/parse_benchmark.py"
SPEC = importlib.util.spec_from_file_location("parse_benchmark", PARSER_SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

RUNNER_SPEC = importlib.util.spec_from_file_location("run_nexmark", SCRIPT)
assert RUNNER_SPEC is not None and RUNNER_SPEC.loader is not None
sys.path.insert(0, str(SCRIPT.parent))
RUNNER = importlib.util.module_from_spec(RUNNER_SPEC)
RUNNER_SPEC.loader.exec_module(RUNNER)


def test_official_result_row() -> None:
    row = "|q3 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |"
    result = MODULE.parse_result("Nexmark Results\n" + row, "q3", 10_000_000)
    assert result["time_seconds"] == 10.232
    assert result["throughput_events_per_second"] == 977_320
    assert len(MODULE.QUERIES) == 23
    assert "q6" not in MODULE.QUERIES


def test_parse_all_official_query_logs(tmp_path: Path) -> None:
    for query in MODULE.QUERIES:
        (tmp_path / f"bench-{query}.log").write_text(
            f"|{query} |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |\n",
            encoding="utf-8",
        )
    payload = MODULE.parse_benchmark(tmp_path)
    assert len(payload["measurements"]) == 23
    assert len(payload["results"]) == 46
    assert payload["parameters"]["benchmark_events"] == 10_000_000


def test_optimized_standalone_does_not_fall_back_to_base(tmp_path: Path) -> None:
    results = tmp_path / "results"
    env = dict(os.environ, PERF_WORK_DIR=str(tmp_path / "private"))
    completed = subprocess.run(
        ["bash", str(SCRIPT.parents[1] / "flink_test.sh"), "--variant", "optimized",
         "--results-dir", str(results)],
        env=env, text=True, capture_output=True, check=False, timeout=30,
    )
    assert completed.returncode == 30
    assert "optimized Flink build is not implemented" in completed.stdout
    assert not (results / "build_variant.json").exists()
    assert (results / "status.json").exists()


def test_standalone_report_uses_all_formal_metrics(tmp_path: Path) -> None:
    for query in MODULE.QUERIES:
        (tmp_path / f"bench-{query}.log").write_text(
            f"|{query} |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |\n",
            encoding="utf-8",
        )
    payload = MODULE.parse_benchmark(tmp_path)
    (tmp_path / "benchmark_flink.json").write_text(json.dumps(payload))
    (tmp_path / "build_variant.json").write_text('{"variant":"base","parameters":{"variant":"base"}}')
    (tmp_path / "build_info.json").write_text('{"actual_version":"1.16.3"}')
    report = subprocess.run(
        [sys.executable, str(SCRIPT.parent / "results/standalone_runtime.py"), "finalize",
         str(tmp_path), "1.16.3", "x86_64", "run-test", "passed", "passed"],
        capture_output=True, text=True, check=False,
    )
    assert report.returncode == 0, report.stderr
    result = json.loads((tmp_path / "results.json").read_text())
    assert result["status"] == "passed"
    assert len(result["metrics"]) == 46
    assert "### q23" in (tmp_path / "report.md").read_text()


@pytest.mark.parametrize("row", [
    "|q3 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |\n" * 2,
    "|q4 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |",
    "|q3 |9,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |",
])
def test_rejects_missing_or_ambiguous_measurements(row: str) -> None:
    with pytest.raises(ValueError):
        MODULE.parse_result(row, "q3", 10_000_000)


def test_workload_changes_only_expected_keys(tmp_path: Path) -> None:
    conf = tmp_path / "nexmark.yaml"
    conf.write_text("\n".join([
        "nexmark.workload.suite.100m.events.num: 100000000",
        "nexmark.workload.suite.100m.tps: 10000000",
        "nexmark.workload.suite.100m.warmup.duration: 120s",
        "nexmark.workload.suite.100m.warmup.events.num: 100000000",
        "nexmark.workload.suite.100m.warmup.tps: 10000000",
        "other.key: unchanged",
    ]))
    RUNNER.set_workload(conf, 10_000_000, 1_000_000)
    contents = conf.read_text()
    assert "nexmark.workload.suite.100m.events.num: 10000000" in contents
    assert "nexmark.workload.suite.100m.tps: 1000000" in contents
    assert "nexmark.workload.suite.100m.warmup.events.num: 0" in contents
    assert "other.key: unchanged" in contents


def test_maven_settings_keep_proxy_in_private_file(tmp_path: Path) -> None:
    target = tmp_path / "settings.xml"
    env = dict(os.environ, PERF_PROXY="http://user:secret@proxy.example:8080")
    subprocess.run(
        [sys.executable, str(SCRIPT.with_name("configure_maven.py")), str(target)],
        env=env, check=True,
    )
    root = ET.parse(target).getroot()
    namespace = {"m": "http://maven.apache.org/SETTINGS/1.0.0"}
    proxies = root.findall("m:proxies/m:proxy", namespace)
    assert len(proxies) == 2
    assert [proxy.findtext("m:protocol", namespaces=namespace) for proxy in proxies] == ["http", "https"]
    assert all(proxy.findtext("m:password", namespaces=namespace) == "secret" for proxy in proxies)
    assert target.stat().st_mode & 0o777 == 0o600
