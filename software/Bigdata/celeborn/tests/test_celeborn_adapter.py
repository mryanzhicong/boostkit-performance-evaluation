from pathlib import Path
import hashlib
import json
import subprocess
import sys
import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / 'spark/scripts'))
from extension import Extension
from types import SimpleNamespace

def test_document_profile_and_sql_command(monkeypatch, tmp_path):
    monkeypatch.setenv('PERF_ADAPTER_DIR', str(ROOT))
    cfg = json.loads((ROOT / 'profile.json').read_text())
    r = SimpleNamespace(work=tmp_path, env={}, paths={'application_java': '/private/java17'})
    e = Extension(r)
    args = e.sql_args()
    assert e.scale == 100 and e.source_db.endswith('_decimal_orc_100')
    assert args[args.index('--num-executors')+1] == str(cfg['resources']['requested_executors'])
    assert args[args.index('--executor-memory')+1] == cfg['resources']['executor_memory']
    assert cfg['spark_version'] == '3.5.2'
    assert cfg['resources']['driver_memory'] == '20G'
    assert cfg['spark_conf'].get('spark.shuffle.manager', '').endswith('CelebornShuffleManager') if cfg['name']=='celeborn' else True

def test_asset_lock_has_complete_digests():
    specs = json.loads((ROOT / 'assets.json').read_text())
    assert specs
    for item in specs.values():
        assert len(item['digest']) == hashlib.new(item['algorithm']).digest_size*2
        assert not Path(item['filename']).is_absolute() and '..' not in Path(item['filename']).parts
        assert not any(bad in item['filename'] for bad in ('_bak', 'runerror'))

def test_entry_usage_does_not_start_services():
    p = subprocess.run(['bash', str(ROOT / (ROOT.name+'_test.sh')), '--help'], capture_output=True, text=True)
    assert p.returncode == 0 and 'Usage:' in p.stdout

def test_shell_syntax():
    for script in ROOT.rglob('*.sh'):
        subprocess.run(['bash', '-n', str(script)], check=True)


def test_effective_configuration_has_no_unexpanded_paths(monkeypatch, tmp_path):
    monkeypatch.setenv('PERF_ADAPTER_DIR', str(ROOT))
    cfg = json.loads((ROOT / 'profile.json').read_text())
    hadoop = tmp_path / 'hadoop/etc/hadoop'
    hadoop.mkdir(parents=True)
    (hadoop / 'core-site.xml').write_text('<configuration/>')
    (tmp_path / 'celeborn/conf').mkdir(parents=True)
    r = SimpleNamespace(work=tmp_path, env={}, paths={'application_java':'/private/java17',
        'hadoop':str(tmp_path/'hadoop'), 'spark':str(tmp_path/'spark'),
        'celeborn':str(tmp_path/'celeborn'), 'java':'/private/java8'}, logs=tmp_path/'logs')
    e = Extension(r)
    actual = e.configure({'spark.sql.shuffle.partitions':'960', 'spark.default.parallelism':'960'})
    expected = {'bolt': ('23g','144'), 'celeborn': ('23g','960'), 'hudi': ('32g','100'),
                'iceberg': ('23g','800'), 'velox': ('5g','960')}[ROOT.name]
    assert e.resources['executor_memory'] == expected[0]
    assert actual['spark.sql.shuffle.partitions'] == expected[1]
    assert not any('${' in v for v in actual.values())
    assert actual['spark.sql.warehouse.dir'].startswith('hdfs://server1:9000/')
    if ROOT.name in ('bolt','velox'):
        assert actual['spark.gluten.loadLibFromJar'] == 'false'
        assert actual['spark.memory.offHeap.size'] == '35g'
        assert actual['spark.gluten.sql.columnar.backend.lib'] == ROOT.name

def test_x86_and_optimized_fail_before_services():
    import os
    adapter = ROOT / 'scripts/adapter.sh'
    for architecture, variant, expected in [('x86_64','base',20), ('aarch64','optimized',10)]:
        p = subprocess.run(['bash','-c',f'source "{adapter}"; configure_runtime_paths'],
            env=os.environ | {'EXPECTED_ARCH':architecture,'PERF_VARIANT':variant}, capture_output=True, text=True)
        assert p.returncode == expected
