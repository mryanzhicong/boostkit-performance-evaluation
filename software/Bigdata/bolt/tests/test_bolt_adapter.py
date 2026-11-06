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
    assert e.scale == 10000 and e.source_db.endswith('_decimal_orc_10000')
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
        assert not any(bad in item['filename'] for bad in ('_bak', 'runerror', '_slow'))

def test_entry_usage_does_not_start_services():
    p = subprocess.run(['bash', str(ROOT / (ROOT.name+'_test.sh')), '--help'], capture_output=True, text=True)
    assert p.returncode == 0 and 'Usage:' in p.stdout

def test_shell_syntax():
    for script in ROOT.rglob('*.sh'):
        subprocess.run(['bash', '-n', str(script)], check=True)
