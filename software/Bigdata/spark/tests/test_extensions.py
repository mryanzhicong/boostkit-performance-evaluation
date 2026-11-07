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
    with pytest.raises(ValueError, match="architecture"):
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
                        "PERF_COMPONENT_VERSION": "1.0", "SOFTWARE_VERSION": "1.0", "PERF_RUN_ID": "unit", "EXPECTED_ARCH": "aarch64"}
    (tmp_path / "profile.json").write_text('{"supported_architectures":["aarch64"]}')
    common = SCRIPTS / "common.sh"
    code = f'source "{common}"; configure_runtime_paths; '
    p = subprocess.run(["bash", "-c", code + 'echo "$SPARK_CONTAINER $PERF_WORK_DIR"'], env=env, capture_output=True, text=True)
    assert p.returncode == 0
    assert "boostkit-sample-" in p.stdout and "/boostkit-perf/sample/" in p.stdout
    p = subprocess.run(["bash", "-c", code + 'docker() { if [[ "$*" == *--format* ]]; then echo unrelated; fi; }; remove_spark_network'], env=env)
    assert p.returncode == 70

@pytest.mark.parametrize('adapter,cpus,should_fail', [(True,64,False),(True,63,True),(False,64,True)])
def test_disk_observational_for_adapters_but_cpu_guard_remains(tmp_path, monkeypatch, adapter, cpus, should_fail):
    import assets
    if adapter:
        configuration(tmp_path, monkeypatch, scale_factor=100)
    else:
        monkeypatch.delenv('PERF_ADAPTER_DIR', raising=False)
    original_read, original_exists = Path.read_text, Path.exists
    monkeypatch.setattr(Path, 'read_text', lambda p, *a, **kw: 'MemAvailable: 1073741824 kB\n' if str(p)=='/proc/meminfo' else original_read(p,*a,**kw))
    monkeypatch.setattr(Path, 'exists', lambda p: False if str(p)=='/sys/fs/cgroup/memory.max' else original_exists(p))
    monkeypatch.setattr(os, 'sched_getaffinity', lambda _: set(range(cpus)), raising=False)
    monkeypatch.setattr(assets.shutil, 'disk_usage', lambda _: SimpleNamespace(total=1000,used=999,free=1))
    if should_fail:
        with pytest.raises(RuntimeError,match='Insufficient resources'):
            assets.preflight(tmp_path,tmp_path)
    else:
        assets.preflight(tmp_path,tmp_path)
    info=json.loads((tmp_path/'preflight.json').read_text())
    assert info['free_disk_bytes']==1
    assert info['disk_check_policy']==('record_only' if adapter else 'required_minimum')
    assert info['required_disk_bytes'] is None if adapter else info['required_disk_bytes']==500_000_000_000


def test_disk_monitor_records_both_filesystems_without_interfering(tmp_path,monkeypatch):
    import threading
    configuration(tmp_path,monkeypatch,scale_factor=100)
    r=SimpleNamespace(work=tmp_path,results=tmp_path)
    stop=threading.Event();stop.set()
    Extension(r).disk_monitor(stop,'test')
    rows=[json.loads(s) for s in (tmp_path/'disk-usage.jsonl').read_text().splitlines()]
    assert len(rows)==2
    assert all(row['stage']=='test' for row in rows)
    assert set(rows[0]['filesystems'])=={'work','results'}
    assert rows[0]['filesystems']['work']['free_bytes']>=0


def test_disk_monitor_survives_full_log_filesystem(tmp_path,monkeypatch,capsys):
    import errno,threading
    configuration(tmp_path,monkeypatch,scale_factor=100)
    e=Extension(SimpleNamespace(work=tmp_path,results=tmp_path))
    def full(_): raise OSError(errno.ENOSPC,'No space left on device')
    monkeypatch.setattr(e,'record_disk',full)
    e.disk_monitor(threading.Event(),'start')
    assert 'No space left' in capsys.readouterr().err


def test_download_fallback_keeps_checksum_and_rejects_corrupt_mirror(tmp_path,monkeypatch):
    import assets
    good=b'fixed official bytes';expected=hashlib.sha256(good).hexdigest();calls=[]
    target=tmp_path/'spark.tgz'
    def curl(args,check):
        calls.append(args[-1]);Path(args[args.index('-o')+1]).write_bytes(b'corrupt' if len(calls)==1 else good)
    monkeypatch.setattr(assets.subprocess,'run',curl)
    url='https://archive.apache.org/dist/spark/spark-3.5.2/file.tgz'
    assert assets.fetch_verified(target,url,'sha256',expected)==url
    assert len(calls)==2 and calls[0].startswith('https://mirrors.huaweicloud.com/apache/')
    assert target.read_bytes()==good
    assert not target.with_name('spark.tgz.part').exists()
