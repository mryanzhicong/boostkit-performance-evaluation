"""Failure-path and isolation tests for document-pinned Spark adapters."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
from types import SimpleNamespace

import pytest

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
from extension import Extension, check_elf, prepare_assets, validate_migration


def configuration(tmp_path, monkeypatch, **changes):
    root = tmp_path / "adapter"
    root.mkdir()
    cfg = {"name": "sample", "version": "1.0", "kind": "hudi", "scale_factor": 10000,
           "resources": {"requested_executors": 2, "executor_memory": "32g"}, "spark_conf": {}}
    cfg.update(changes)
    (root / "profile.json").write_text(json.dumps(cfg))
    monkeypatch.setenv("PERF_ADAPTER_DIR", str(root))
    return root


def test_pinned_asset_is_checked_before_copy(tmp_path, monkeypatch):
    root = configuration(tmp_path, monkeypatch)
    cache, work, results = [tmp_path / s for s in ("cache", "work", "results")]
    for p in (cache, work, results):
        p.mkdir()
    (cache / "test.jar").write_bytes(b"changed")
    (root / "assets.json").write_text(json.dumps({"jar": {"filename": "test.jar", "digest": "0" * 64}}))
    monkeypatch.setenv("PERF_ASSET_DIR", str(cache))
    with pytest.raises(ValueError, match="checksum"):
        prepare_assets(work, results, "aarch64")
    assert not (work / "extension-assets/test.jar").exists()


def test_offline_assets_and_architecture(tmp_path, monkeypatch):
    root = configuration(tmp_path, monkeypatch)
    cache, work, results = [tmp_path / s for s in ("cache", "work", "results")]
    for p in (cache, work, results):
        p.mkdir()
    (cache / "test.jar").write_bytes(b"fixed")
    (root / "assets.json").write_text(json.dumps({"jar": {"filename": "test.jar", "digest": hashlib.sha256(b"fixed").hexdigest()}}))
    monkeypatch.setenv("PERF_ASSET_DIR", str(cache))
    with pytest.raises(ValueError, match="aarch64"):
        prepare_assets(work, results, "x86_64")
    assert prepare_assets(work, results, "aarch64")["extension_jar"]["sha256"] == hashlib.sha256(b"fixed").hexdigest()


def test_resource_and_database_profile(tmp_path, monkeypatch):
    configuration(tmp_path, monkeypatch)
    e = Extension(SimpleNamespace(work=tmp_path))
    args = e.sql_args()
    assert args[args.index("--num-executors") + 1] == "2"
    assert args[args.index("--executor-memory") + 1] == "32g"
    assert e.source_db.endswith("decimal_orc_10000")
    assert e.query_db == "tpcds_sample_decimal_orc_10000"


@pytest.mark.parametrize("content", [
    "table,status,src_count,tgt_count\na,SUCCESS,10,9\n",
    "table,status,src_count,tgt_count\na,FAILED,10,10\n",
    "table,status,src_count,tgt_count\na,SUCCESS,10,10\na,SUCCESS,10,10\n",
    "table,status,src_count,tgt_count\na,SUCCESS,10,10\n",
])
def test_migration_rejects_loss_failures_duplicates_and_missing_tables(tmp_path, content):
    p = tmp_path / "summary.csv"
    p.write_text(content)
    with pytest.raises(ValueError):
        validate_migration(p, {"a", "b"})


def test_native_library_rejects_wrong_elf(tmp_path):
    p = tmp_path / "libtest.so"
    p.write_bytes(b"\x7fELF\x02\x01" + bytes(12) + (62).to_bytes(2, "little"))
    with pytest.raises(ValueError, match="architecture"):
        check_elf(p)


def test_extension_paths_and_network_cleanup_guard(tmp_path):
    env = os.environ | {"PERF_ADAPTER_DIR": str(tmp_path), "PERF_COMPONENT": "sample",
                        "PERF_COMPONENT_VERSION": "1.0", "SOFTWARE_VERSION": "1.0", "PERF_RUN_ID": "unit"}
    common = SCRIPTS / "common.sh"
    code = f'source "{common}"; configure_runtime_paths; '
    p = subprocess.run(["bash", "-c", code + 'echo "$SPARK_CONTAINER $PERF_WORK_DIR"'], env=env, capture_output=True, text=True)
    assert p.returncode == 0
    assert "boostkit-sample-" in p.stdout and "/boostkit-perf/sample/" in p.stdout
    p = subprocess.run(["bash", "-c", code + 'docker() { if [[ "$*" == *--format* ]]; then echo unrelated; fi; }; remove_spark_network'], env=env)
    assert p.returncode == 70
