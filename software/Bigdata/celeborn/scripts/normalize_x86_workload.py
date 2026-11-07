#!/usr/bin/env python3
"""Align x86 setup metadata with the pinned ARM workload, retaining its native generator."""
import hashlib
import json
import os
from pathlib import Path
import shutil


def digest(data):
    return hashlib.sha256(data).hexdigest()


def normalize(bench: Path, results: Path, reference: dict) -> dict:
    setup = bench / 'tpcds-setup.sh'
    original = setup.read_bytes()
    expected = reference['canonical_files']['tpcds-setup.sh']
    if digest(original) == expected:
        effective = original
    elif digest(original) == reference['source_setup_sha256']:
        effective = original.decode('utf-8').replace(
            'DATABASE=tpcds_bin_partitioned_varchar_', 'DATABASE=tpcds_bin_partitioned_decimal_').replace(
            '#echo "Loading constraints"', 'echo "Loading constraints"').replace(
            '#runcommand "$HIVE -f ddl-tpcds/bin_partitioned/add_constraints.sql --hivevar DB=${DATABASE}"',
            'runcommand "$HIVE -f ddl-tpcds/bin_partitioned/add_constraints.sql --hivevar DB=${DATABASE}"').encode('utf-8')
    else:
        raise ValueError('Unexpected x86 setup script; refusing an unverified modification')
    checked = {}
    for name, expected_hash in reference['canonical_files'].items():
        path = bench / name
        if not path.resolve().is_relative_to(bench.resolve()):
            raise ValueError('Invalid workload metadata path')
        content = effective if name == 'tpcds-setup.sh' else path.read_bytes()
        actual = digest(content)
        if actual != expected_hash:
            raise ValueError('Cross-architecture workload metadata mismatch: '+name)
        checked[name] = actual
    backup = results / 'workload-normalization'
    backup.mkdir(parents=True, exist_ok=True)
    if original != effective:
        shutil.copyfile(setup, backup / 'tpcds-setup.original.sh')
        temporary = setup.with_name(setup.name+'.normalized.tmp')
        temporary.write_bytes(effective)
        temporary.replace(setup)
    report = {'architecture':'x86_64','original_setup_sha256':digest(original),
              'effective_setup_sha256':digest(effective),'metadata_files':checked,
              'normalizations':['database naming','enable original ARM constraint loading'],
              'native_generator':'unchanged x86_64 generator from pinned x86 archive'}
    (results/'workload-normalization.json').write_text(json.dumps(report,indent=2)+'\n')
    return report


if __name__ == '__main__':
    if os.environ.get('EXPECTED_ARCH') != 'x86_64':
        raise ValueError('This startup adjustment is only for x86_64')
    paths=json.loads((Path(os.environ['PERF_WORK_DIR'])/'runtime.json').read_text())
    reference=json.loads((Path(__file__).resolve().parents[1]/'reference/canonical-workload.json').read_text())
    normalize(Path(paths['tpcds']),Path(os.environ['RESULTS_DIR']),reference)
