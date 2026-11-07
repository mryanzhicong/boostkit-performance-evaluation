import importlib.util
import json
from pathlib import Path
from unittest.mock import patch
import pytest

spec = importlib.util.spec_from_file_location('configure_repositories', Path(__file__).resolve().parents[1] / 'scripts/configure_repositories.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)


def test_repo_rewrite_preserves_release_and_signature_checks():
    text = '[OS]\nbaseurl=https://repo.openeuler.org/openEuler-24.03-LTS-SP4/OS/$basearch/\ngpgcheck=1\ngpgkey=https://repo.openeuler.org/openEuler-24.03-LTS-SP4/OS/$basearch/RPM-GPG-KEY-openEuler\n'
    result = m.rewrite(text, 'https://mirrors.huaweicloud.com/openeuler')
    assert 'LTS-SP4/OS/$basearch/' in result
    assert 'gpgcheck=1' in result
    assert result.count('https://mirrors.huaweicloud.com/openeuler/') == 2
    assert m.rewrite('https://example.com/repository', 'https://other') == 'https://example.com/repository'


def test_container_probe_fallback_and_evidence(tmp_path):
    repo = tmp_path / 'openEuler.repo'
    repo.write_text('baseurl=https://repo.openeuler.org/openEuler-24.03-LTS-SP4/OS/$basearch/')
    class Response:
        status = 200
        def __enter__(self): return self
        def __exit__(self, *args): pass
        def read(self, size): return b'<?xml version="1.0"?><repomd xmlns="x">'
    def opener(url, timeout):
        if 'mirrors.huaweicloud' in url:
            raise TimeoutError('unreachable')
        return Response()
    with patch.object(m.socket, 'getaddrinfo', return_value=[]):
        m.configure(repo, tmp_path / 'results', 'x86_64', opener)
    evidence = json.loads((tmp_path / 'results/container-repository-network.json').read_text())
    assert evidence['chosen_base'] == 'https://repo.huaweicloud.com/openeuler'
    assert len(evidence['probes']) == 2
    assert 'repo.huaweicloud.com/openeuler/' in repo.read_text()
    assert (tmp_path / 'results/openEuler.repo.original').read_text().startswith('baseurl=https://repo.openeuler.org/')


def test_unreachable_sources_fail_without_changing_configuration(tmp_path):
    repo = tmp_path / 'openEuler.repo'
    repo.write_text('unchanged')
    def fail(*args, **kwargs): raise TimeoutError('offline')
    with patch.object(m.socket, 'getaddrinfo', return_value=[]), pytest.raises(RuntimeError, match='No release-identical'):
        m.configure(repo, tmp_path / 'results', 'aarch64', fail)
    assert repo.read_text() == 'unchanged'
    evidence = json.loads((tmp_path / 'results/container-repository-network.json').read_text())
    assert len(evidence['probes']) == 3 and evidence['chosen_base'] is None
