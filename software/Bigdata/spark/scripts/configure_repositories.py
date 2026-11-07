#!/usr/bin/env python3
"""Probe release-identical openEuler repositories from inside the task container."""
import json
import os
from pathlib import Path
import re
import socket
import urllib.request

HOSTS = ('mirrors.huaweicloud.com/openeuler', 'repo.huaweicloud.com/openeuler', 'repo.openeuler.org')
PATTERN = r'https?://(?:repo\.openeuler\.org|(?:repo|mirrors)\.huaweicloud\.com/openeuler)(?=/)'


def rewrite(text, base):
    # Preserve release paths, repository IDs, enabled flags, and signature settings.
    text = re.sub(r"(?m)^(\s*)(metalink|mirrorlist)(\s*=.*)$", r"\1# \2\3", text)
    return re.sub(PATTERN, base, text)


def configure(repo, results, arch, opener=urllib.request.urlopen):
    original = repo.read_text()
    probes, chosen = [], None
    for host in HOSTS:
        base = 'https://' + host
        url = base + '/openEuler-24.03-LTS-SP4/OS/' + arch + '/repodata/repomd.xml'
        probe = {'url': url}
        try:
            probe['addresses'] = sorted({r[4][0] for r in socket.getaddrinfo(host.split('/')[0], 443)})
            with opener(url, timeout=10) as response:
                prefix = response.read(8192)
                if response.status != 200 or b'<repomd' not in prefix:
                    raise ValueError('Repository metadata is not repomd XML')
            probe['success'] = True
            chosen = base
        except (OSError, ValueError) as error:
            probe.update(success=False, error=str(error))
        probes.append(probe)
        print('[container repository] ' + json.dumps(probe), flush=True)
        if chosen:
            break
    results.mkdir(parents=True, exist_ok=True)
    (results / 'container-repository-network.json').write_text(json.dumps({'architecture': arch, 'chosen_base': chosen, 'probes': probes}, indent=2) + '\n')
    if chosen is None:
        raise RuntimeError('No release-identical repository reachable from the private container; see container-repository-network.json')
    (results / 'openEuler.repo.original').write_text(original)
    updated = rewrite(original, chosen)
    repo.write_text(updated)
    (results / 'openEuler.repo.selected').write_text(updated)


if __name__ == '__main__':
    configure(Path('/etc/yum.repos.d/openEuler.repo'), Path(os.environ['RESULTS_DIR']), os.environ['EXPECTED_ARCH'])
