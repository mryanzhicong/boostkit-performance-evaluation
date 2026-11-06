from __future__ import annotations
import importlib.util
import json
from pathlib import Path
import sys
import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/results"))
from parse_benchmark import parse_log, query_names, summarize, verify_queries

def records():
    return [{"query": q, "round": r, "phase": "warmup" if r == 0 else "measurement",
             "status": "passed", "exit_code": 0, "query_time_seconds": [100., 5., 2., 3.][r],
             "row_count": 0} for q in query_names() for r in range(4)]

def test_all_queries_and_warmup_exclusion():
    result = summarize(records(), {}, {"resource_profile": {}, "spark_conf": {}})
    assert len(result["results"]) == 103
    assert all(m["value"] == 3.0 and m["samples"] == [5., 2., 3.] for m in result["results"].values())
    assert "q14a/query_time" in result["results"] and "q14b/query_time" in result["results"]

@pytest.mark.parametrize("change", ["missing", "duplicate", "failed", "nonfinite", "wrong_phase", "unknown", "missing_warmup"])
def test_incomplete_and_invalid_sets_fail(change):
    rows = records()
    if change == "missing": rows.pop()
    if change == "duplicate": rows.append(rows[0].copy())
    if change == "failed": rows[0]["status"] = "failed"
    if change == "nonfinite": rows[1]["query_time_seconds"] = float("nan")
    if change == "wrong_phase": rows[1]["phase"] = "warmup"
    if change == "unknown": rows[0]["query"] = "q999.sql"
    if change == "missing_warmup": rows = [r for r in rows if r["round"]]
    with pytest.raises(ValueError):
        summarize(rows, {}, {"resource_profile": {}, "spark_conf": {}})

def test_spark_cli_timing_and_empty_results():
    assert parse_log("Time taken: 1.25 seconds, Fetched 100 row(s)", 0) == (1.25, 100)
    assert parse_log("Time taken: 0.03 seconds", 0) == (.03, 0)

@pytest.mark.parametrize("text,code", [
    ("Time taken: 1 seconds\nError in query: broken", 0),
    ("Time taken: 1 seconds\nAnalysisException", 0),
    ("Time taken: 1 seconds", 124), ("nothing", 0),
    ("Time taken: 1 seconds\nTime taken: 2 seconds", 0),
    ("Time taken: 0 seconds", 0),
])
def test_failed_or_ambiguous_logs(text, code):
    with pytest.raises(ValueError): parse_log(text, code)

def test_query_manifest_rejects_missing_or_changed_sql(tmp_path):
    import hashlib
    manifest = {}
    for q in query_names():
        (tmp_path / q).write_text("select 1")
        manifest[q] = hashlib.sha256(b"select 1").hexdigest()
    assert len(verify_queries(tmp_path, manifest)) == 103
    (tmp_path / "q1.sql").write_text("select 2")
    with pytest.raises(ValueError, match="checksum"): verify_queries(tmp_path, manifest)
    (tmp_path / "q1.sql").unlink()
    with pytest.raises(ValueError, match="103"): verify_queries(tmp_path, manifest)

def test_document_resources_are_preserved():
    spec = importlib.util.spec_from_file_location("spark_runtime", ROOT / "scripts/runtime.py")
    runtime = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(runtime)
    doc = json.loads((ROOT / "scripts/reference/document-config.json").read_text())
    assert doc["yarn-site"]["yarn.nodemanager.resource.cpu-vcores"] == "64"
    assert doc["yarn-site"]["yarn.nodemanager.resource.memory-mb"] == "371200"
    assert runtime.PROFILE["requested_executors"] == 200
    assert runtime.PROFILE["executor_cores"] == 8 and runtime.PROFILE["executor_memory"] == "23g"
    assert runtime.SPARK_CONF["spark.sql.shuffle.partitions"] == "960"

def load_runtime():
    spec = importlib.util.spec_from_file_location("spark_runtime", ROOT / "scripts/runtime.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def test_generated_configs_preserve_resources_and_hive_client(tmp_path):
    from xml.etree import ElementTree as ET
    module = load_runtime()
    r = object.__new__(module.Runtime)
    r.work, r.results, r.logs = tmp_path / "work", tmp_path / "results", tmp_path / "logs"
    r.user, r.env = "bench", {}
    r.paths = {n: str(tmp_path / "packages" / n) for n in ("java", "hadoop", "hive", "spark", "tez", "zookeeper")}
    for name, relative in (("hadoop", "etc/hadoop"), ("spark", "conf"), ("zookeeper", "conf")):
        (Path(r.paths[name]) / relative).mkdir(parents=True)
    r.work.mkdir(); r.results.mkdir()
    r.configure()
    yarn = ET.parse(Path(r.paths["hadoop"]) / "etc/hadoop/yarn-site.xml")
    props = {p.findtext("name"): p.findtext("value") for p in yarn.findall("property")}
    assert props["yarn.nodemanager.resource.memory-mb"] == "371200"
    assert props["yarn.scheduler.maximum-allocation-vcores"] == "64"
    assert props["yarn.nodemanager.local-dirs"] == str(r.work / "hdfs/yarn/local")
    spark = (Path(r.paths["spark"]) / "conf/spark-defaults.conf").read_text()
    assert "spark.sql.hive.metastore.version 3.1.0" in spark
    assert "spark.sql.hive.metastore.jars path" in spark
    assert "spark.sql.shuffle.partitions 960" in spark
    assert "/usr/local/hadoop" not in (Path(r.paths["hadoop"]) / "etc/hadoop/mapred-site.xml").read_text()

def test_timeout_preserves_failure_and_stops_later_queries(tmp_path, monkeypatch):
    import subprocess
    import signal
    module = load_runtime()
    r = object.__new__(module.Runtime)
    r.results, r.home, r.env = tmp_path, tmp_path, {}
    r.paths = {"tpcds": str(tmp_path)}
    r.command = lambda args: args
    r.allocation_monitor = lambda stop, samples: None
    (tmp_path / "runtime-context.json").write_text('{"resource_profile":{},"spark_conf":{}}')
    monkeypatch.setattr(module, "verify_queries", lambda *args: ["q1.sql", "q2.sql"])
    killed = []
    monkeypatch.setattr(module.os, "killpg", lambda pid, sig: killed.append((pid, sig)))
    class Process:
        pid = 123
        def __init__(self, *args, **kwargs): self.calls = 0
        def wait(self, timeout=None):
            self.calls += 1
            if self.calls == 1: raise subprocess.TimeoutExpired("spark-sql", timeout)
            return 0
    monkeypatch.setattr(module.subprocess, "Popen", Process)
    with pytest.raises(ValueError, match="exit 124"): r.test()
    rows = [json.loads(line) for line in (tmp_path / "timings.jsonl").read_text().splitlines()]
    assert len(rows) == 1 and rows[0]["query"] == "q1.sql"
    assert rows[0]["status"] == "failed" and rows[0]["exit_code"] == 124
    assert killed == [(123, signal.SIGTERM)]
    assert not (tmp_path / "benchmark_spark.json").exists()

def test_release_sources_and_query_lock():
    spec = importlib.util.spec_from_file_location("spark_assets", ROOT / "scripts/assets.py")
    assets = importlib.util.module_from_spec(spec); spec.loader.exec_module(assets)
    import hashlib
    for url, algorithm, expected in [*assets.SOURCES.values(),
                                    *assets.ARCH_SOURCES["aarch64"].values(),
                                    *assets.ARCH_SOURCES["x86_64"].values()]:
        assert len(expected) == hashlib.new(algorithm).digest_size * 2
    assert assets.ARCH_SOURCES["aarch64"]["tpcds"][2] == "11f5ea3a6a7d68fba7bca1543e1454109ced69bc134192da1d8d659e456c60de"
    manifest = json.loads((ROOT / "scripts/reference/queries.sha256.json").read_text())
    assert set(manifest) == set(query_names())
