#!/usr/bin/env python3
"""Download signed distro RPMs in a disposable client; install only in runtime."""
import configparser
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.request
from configure_repositories import configure

PACKAGES = ['python3', 'mariadb-server', 'mariadb', 'procps-ng', 'util-linux', 'coreutils',
            'findutils', 'tar', 'gzip', 'unzip', 'hostname', 'shadow', 'libaio', 'openssl-libs',
            'zlib', 'snappy', 'which', 'make', 'gcc', 'gcc-c++', 'binutils', 'lz4', 'zstd',
            'numactl-libs', 'libatomic', 'libstdc++', 'libicu', 'double-conversion', 'libsodium',
            'libevent', 'xz-libs', 'bzip2']
DNF = ['dnf', '--setopt=timeout=20', '--setopt=retries=2']


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def fetch(work, results, arch):
    repo = Path('/etc/yum.repos.d/openEuler.repo')
    configure(repo, results / 'dependency-fetch-network', arch)
    dest = work / 'dependency-rpms'
    dest.mkdir(exist_ok=True)
    subprocess.run(DNF + ['install', '-y', '--downloadonly', '--downloaddir=' + str(dest)] + PACKAGES, check=True)
    packages = sorted(dest.glob('*.rpm'))
    if not packages:
        raise RuntimeError('Dependency fetch produced no RPMs')
    keys = work / 'dependency-keys'
    keys.mkdir(exist_ok=True)
    config = configparser.ConfigParser(interpolation=None)
    config.read(repo)
    urls = sorted({url for section in config.values() if section.get('enabled', '1') != '0'
                   for url in section.get('gpgkey', '').split()})
    key_files = []
    for i, template in enumerate(urls):
        url = template.replace('${basearch}', arch).replace('$basearch', arch)
        if '$' in url:
            raise ValueError('Unexpanded repository key URL: ' + url)
        target = keys / ('key-' + str(i) + '.asc')
        with urllib.request.urlopen(url, timeout=30) as response:
            target.write_bytes(response.read())
        subprocess.run(['rpm', '--import', str(target)], check=True)
        key_files.append(target)
    if not key_files:
        raise RuntimeError('No distro signing keys exported')
    # Verify signatures before handoff; the runtime also verifies its local transaction.
    subprocess.run(['rpmkeys', '--checksig', *map(str, packages)], check=True)
    manifest = {'architecture': arch, 'transport': 'disposable download-only container with host networking',
                'runtime_network': 'private bridge',
                'rpms': [{'name': p.name, 'sha256': digest(p)} for p in packages],
                'keys': [{'name': p.name, 'sha256': digest(p)} for p in key_files]}
    (results / 'system-dependency-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')


def offline(work, results, arch):
    manifest = json.loads((results / 'system-dependency-manifest.json').read_text())
    if manifest['architecture'] != arch:
        raise ValueError('Wrong offline RPM architecture')
    paths = {}
    for group, directory in (('rpms', 'dependency-rpms'), ('keys', 'dependency-keys')):
        paths[group] = []
        for entry in manifest[group]:
            if Path(entry['name']).name != entry['name']:
                raise ValueError('Unsafe offline dependency path')
            path = work / directory / entry['name']
            if digest(path) != entry['sha256']:
                raise ValueError('Offline dependency checksum mismatch: ' + path.name)
            paths[group].append(str(path))
        if not paths[group]:
            raise ValueError('Empty offline dependency manifest: ' + group)
    for key in paths['keys']:
        subprocess.run(['rpm', '--import', key], check=True)
    subprocess.run(DNF + ['--disablerepo=*', '--setopt=localpkg_gpgcheck=1', 'install', '-y'] + paths['rpms'], check=True)
    subprocess.run(['rpm', '-q', *PACKAGES], check=True)


if __name__ == '__main__':
    stage = sys.argv[1]
    if stage == 'online':
        subprocess.run(DNF + ['install', '-y'] + PACKAGES, check=True)
    elif stage in ('fetch', 'offline'):
        work, results, arch = Path(os.environ['PERF_WORK_DIR']), Path(os.environ['RESULTS_DIR']), os.environ['EXPECTED_ARCH']
        {'fetch': fetch, 'offline': offline}[stage](work, results, arch)
    else:
        raise SystemExit('Unknown dependency stage')
