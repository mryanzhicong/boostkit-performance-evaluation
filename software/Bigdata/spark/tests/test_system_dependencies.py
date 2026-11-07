import hashlib
import importlib.util
import json
from pathlib import Path
import sys
from unittest.mock import patch
import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
spec = importlib.util.spec_from_file_location('system_dependencies', ROOT / 'scripts/system_dependencies.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


def fixture_manifest(tmp_path):
    manifest = {'architecture': 'x86_64'}
    for key, folder, name in [('rpms','dependency-rpms','a.rpm'), ('keys','dependency-keys','key.asc')]:
        dest = tmp_path / folder
        dest.mkdir()
        (dest / name).write_bytes(b'fixed')
        manifest[key] = [{'name': name, 'sha256': hashlib.sha256(b'fixed').hexdigest()}]
    (tmp_path / 'system-dependency-manifest.json').write_text(json.dumps(manifest))
    return manifest


def test_offline_install_verifies_files_and_enforces_local_signature_checks(tmp_path):
    fixture_manifest(tmp_path)
    with patch.object(m.subprocess, 'run') as run:
        m.offline(tmp_path, tmp_path, 'x86_64')
    commands = [c.args[0] for c in run.call_args_list]
    assert commands[0][:2] == ['rpm','--import']
    assert '--disablerepo=*' in commands[1]
    assert '--setopt=localpkg_gpgcheck=1' in commands[1]
    assert 'zstd' in m.PACKAGES and 'zstd-libs' not in m.PACKAGES


@pytest.mark.parametrize('bad', ['arch','checksum','traversal','empty'])
def test_bad_offline_manifests_rejected_before_any_install(tmp_path, bad):
    manifest = fixture_manifest(tmp_path)
    if bad == 'arch': manifest['architecture'] = 'aarch64'
    if bad == 'checksum': manifest['rpms'][0]['sha256'] = 'wrong'
    if bad == 'traversal': manifest['rpms'][0]['name'] = '../a.rpm'
    if bad == 'empty': manifest['rpms'] = []
    (tmp_path / 'system-dependency-manifest.json').write_text(json.dumps(manifest))
    with patch.object(m.subprocess, 'run') as run, pytest.raises(ValueError):
        m.offline(tmp_path, tmp_path, 'x86_64')
    run.assert_not_called()


def test_online_entry_needs_no_task_environment():
    import os
    import runpy
    with patch.dict(os.environ, {}, clear=True), patch.object(sys, 'argv', ['system_dependencies.py','online']), patch.object(m.subprocess, 'run') as run:
        runpy.run_path(str(ROOT / 'scripts/system_dependencies.py'), run_name='__main__')
    assert run.call_args.args[0][:1] == ['dnf']
    assert '--downloadonly' not in run.call_args.args[0]
