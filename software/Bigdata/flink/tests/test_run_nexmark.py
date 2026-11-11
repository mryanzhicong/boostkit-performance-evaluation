"""Checks for every official Nexmark result column and the two-stage workload."""

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
    assert result["events"] == 10_000_000
    assert result["cores"] == 15.17
    assert result["time_seconds"] == 10.232
    assert result["core_seconds"] == 155.247
    assert result["throughput_events_per_second"] == 977_320
    assert result["throughput_per_core_events_per_second"] == 64_420
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
    assert len(payload["results"]) == 138
    assert set(payload["results"]) == {
        f"{query}/{name}" for query in MODULE.QUERIES
        for name, _, _ in MODULE.METRIC_SPECS
    }
    assert payload["results"]["q3/cores"]["direction"] == "neutral"
    assert payload["results"]["q3/core_seconds"]["unit"] == "core*s"
    assert payload["results"]["q3/throughput_per_core"]["direction"] == "higher_is_better"
    assert payload["parameters"]["benchmark_events"] == 10_000_000
    assert payload["parameters"]["checkpoint_interval"] == 180_000


def test_all_result_columns_reach_cross_architecture_report(tmp_path: Path) -> None:
    for query in MODULE.QUERIES:
        (tmp_path / f"bench-{query}.log").write_text(
            f"|{query} |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |\n",
            encoding="utf-8",
        )
    payload = MODULE.parse_benchmark(tmp_path)
    sys.path.insert(0, str(SCRIPT.parents[4] / "framework"))
    from generate_comparison import compare_pair
    from reporting import render_comparison

    base = {
        "category": "Bigdata", "software": "flink", "version": "1.16.3",
        "parameters": payload["parameters"], "metrics": payload["results"],
    }
    comparison = compare_pair(
        dict(base, architecture="x86_64"), dict(base, architecture="aarch64")
    )
    assert len(comparison["metrics"]) == 138
    assert comparison["metrics"]["q3/events"]["relative_performance"] is None
    report = render_comparison(comparison)
    for field in ("events", "cores", "time", "core_seconds", "throughput",
                  "throughput_per_core"):
        assert f"q3/{field}" in report


def test_jdk_and_checkpoint_match_ten_million_event_runbook() -> None:
    case_dir = SCRIPT.parents[1]
    common = (case_dir / "scripts/common.sh").read_text(encoding="utf-8")
    build = (case_dir / "scripts/builders/base.sh").read_text(encoding="utf-8")
    assert 'BISHENG_JDK_RELEASE="8u472-b11"' in common
    assert "prepare_bisheng_jdk || return $?" in build
    assert "execution.checkpointing.interval: 180000" in build
    assert "java-11-openjdk-devel" not in build


def test_cpu_sender_reads_the_same_nexmark_config_as_queries() -> None:
    start = (SCRIPT.parents[1] / "scripts/stages/start.sh").read_text(encoding="utf-8")
    assert 'NEXMARK_CONF_DIR="${NEXMARK_HOME}/conf" "${JAVA_HOME}/bin/java"' in start


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
    assert len(result["metrics"]) == 138
    report_text = (tmp_path / "report.md").read_text()
    assert "### q23" in report_text
    assert "| Events Num |" in report_text
    assert "| Cores * Time(s) |" in report_text
    assert "| Throughput/Cores |" in report_text


@pytest.mark.parametrize("row", [
    "|q3 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |\n" * 2,
    "|q4 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |",
    "|q3 |9,000,000 |15.17 |10.232 |155.247 |977.32 K/s |64.42 K/s |",
    "|q3 |10,000,000 |0 |202.042 |0.000 |49.49 K/s |9.22 E/s |",
    "|q3 |10,000,000 |15.17 |10.232 |bad |977.32 K/s |64.42 K/s |",
    "|q3 |10,000,000 |15.17 |10.232 |155.247 |977.32 K/s |bad |",
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


def test_wait_idle_does_not_fail_after_previous_180_second_limit(monkeypatch: pytest.MonkeyPatch) -> None:
    checks = 0
    elapsed = 0

    def overview(_port: int, _endpoint: str) -> dict[str, int]:
        nonlocal checks
        checks += 1
        if checks <= 100:
            return {"jobs-running": 1, "slots-available": 0}
        return {"jobs-running": 0, "slots-available": RUNNER.SLOTS}

    def advance(seconds: int) -> None:
        nonlocal elapsed
        elapsed += seconds

    monkeypatch.setattr(RUNNER, "rest_json", overview)
    monkeypatch.setattr(RUNNER.time, "monotonic", lambda: elapsed)
    monkeypatch.setattr(RUNNER.time, "sleep", advance)
    RUNNER.wait_idle(8081)
    assert checks == 101
    assert elapsed == 200


def test_first_warmup_requires_cpu_metrics(tmp_path: Path) -> None:
    log = tmp_path / "metric-client.log"
    log.write_text("Can't connect to metric server. Skip to report metric for this round.\n")
    with pytest.raises(RuntimeError, match="produced no TaskManager metrics"):
        RUNNER.require_cpu_metrics(log)
    log.write_text('Report CPU metric: [{"pid":123,"cpuCores":0.5}]\n')
    RUNNER.require_cpu_metrics(log)


def test_job_timeout_keeps_flink_within_self_hosted_five_day_limit() -> None:
    import yaml

    case = yaml.safe_load((SCRIPT.parents[1] / "case.yaml").read_text(encoding="utf-8"))
    assert case["execution"]["timeout_minutes"] == 7000
    assert case["execution"]["timeout_minutes"] + 30 < 5 * 24 * 60


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
