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
    for architecture, variant, expected in [('x86_64','base',0), ('aarch64','base',0), ('aarch64','optimized',10), ('ppc64le','base',20)]:
        p = subprocess.run(['bash','-c',f'source "{adapter}"; configure_runtime_paths'],
            env=os.environ | {'EXPECTED_ARCH':architecture,'PERF_VARIANT':variant}, capture_output=True, text=True)
        assert p.returncode == expected


def test_java_bridge_is_deterministic_and_excludes_native_code(tmp_path):
    from io import BytesIO
    from zipfile import ZipFile
    from extension import build_java_bridge
    source=BytesIO()
    manager='org/apache/spark/shuffle/gluten/celeborn/CelebornShuffleManager.class'
    with ZipFile(source,'w') as z:
        z.writestr(manager,b'\xca\xfe\xba\xbeJava class')
        z.writestr('linux/amd64/libvelox.so',b'\x7fELFnative')
        z.writestr('META-INF/LICENSE','Apache license')
        z.writestr('META-INF/OLD.RSA',b'old signature')
    first,second=tmp_path/'one.jar',tmp_path/'two.jar'
    a=build_java_bridge(source.getvalue(),first);b=build_java_bridge(source.getvalue(),second)
    assert a['sha256']==b['sha256']
    with ZipFile(first) as z:
        assert manager in z.namelist() and 'META-INF/LICENSE' in z.namelist()
        assert not any(n.endswith(('.so','.RSA')) for n in z.namelist())

@pytest.mark.parametrize('arch',['aarch64','x86_64'])
def test_public_assets_can_be_resolved_for_each_architecture(tmp_path,monkeypatch,arch):
    from extension import prepare_assets
    monkeypatch.setenv('PERF_ADAPTER_DIR',str(ROOT))
    cfg=json.loads((ROOT/'profile.json').read_text())
    assert arch in cfg['supported_architectures']
    specs=json.loads((ROOT/'assets.json').read_text())
    assert all(item.get('url') for item in specs.values())
    assert specs['bridge_tar']['url'].startswith('https://github.com/apache/gluten/')

def test_celeborn_installs_public_bridge_without_native_or_offline_assets(tmp_path,monkeypatch):
    import runtime,extension,tarfile
    from io import BytesIO
    from zipfile import ZipFile
    monkeypatch.setenv('PERF_ADAPTER_DIR',str(ROOT))
    cfg=json.loads((ROOT/'profile.json').read_text())
    distribution=tmp_path/'celeborn';(distribution/'spark').mkdir(parents=True)
    (distribution/'spark/celeborn-client-spark-3-shaded_2.12-0.5.3.jar').write_bytes(b'client')
    jars=tmp_path/'spark/jars';jars.mkdir(parents=True)
    source=BytesIO()
    with ZipFile(source,'w') as z:
        z.writestr('org/apache/spark/shuffle/gluten/celeborn/CelebornShuffleManager.class',b'class')
        z.writestr('linux/amd64/libgluten.so',b'\x7fELFwrong arch native')
    archive=tmp_path/'bundle.tar.gz'
    with tarfile.open(archive,'w:gz') as t:
        info=tarfile.TarInfo(cfg['upstream_bridge_jar_filename']);info.size=len(source.getvalue())
        t.addfile(info,BytesIO(source.getvalue()))
    reference=tmp_path/'reference.jar'
    expected=extension.build_java_bridge(source.getvalue(),reference)['sha256']
    r=SimpleNamespace(work=tmp_path,results=tmp_path,env={},sources={'extension_bridge_tar':{'path':str(archive)},'extension_server':{'path':str(tmp_path/'server.tar.gz')}},
        paths={'spark':str(tmp_path/'spark')},packages=tmp_path/'packages',state=tmp_path/'runtime.json')
    e=Extension(r);e.cfg=cfg | {'upstream_bridge_sha256':hashlib.sha256(source.getvalue()).hexdigest(),'bridge_sha256':expected}
    monkeypatch.setattr(runtime,'extract_tar',lambda *args:distribution)
    e.install()
    assert r.paths['celeborn']==str(distribution)
    assert (jars/cfg['jar_filename']).is_file()
    assert json.loads((tmp_path/'celeborn-java-bridge.json').read_text())['sha256']==expected
    with ZipFile(jars/cfg['jar_filename']) as z:
        assert not any(n.endswith('.so') for n in z.namelist())


def test_x86_metadata_normalization_is_exact_idempotent_and_checks_schema(tmp_path):
    import runpy
    normalize=runpy.run_path(str(ROOT/'scripts/normalize_x86_workload.py'))['normalize']
    bench=tmp_path/'bench';bench.mkdir();results=tmp_path/'results';results.mkdir()
    source=('DATABASE=tpcds_bin_partitioned_varchar_${FORMAT}_${SCALE}\n'
            '#echo "Loading constraints"\n'
            '#runcommand "$HIVE -f ddl-tpcds/bin_partitioned/add_constraints.sql --hivevar DB=${DATABASE}"\n').encode()
    expected=source.replace(b'partitioned_varchar_',b'partitioned_decimal_').replace(b'#echo',b'echo').replace(b'#runcommand',b'runcommand')
    schema=b'CREATE TABLE t (n DECIMAL(7,2));'
    (bench/'tpcds-setup.sh').write_bytes(source);(bench/'schema.sql').write_bytes(schema)
    ref={'source_setup_sha256':hashlib.sha256(source).hexdigest(),'canonical_files':{'tpcds-setup.sh':hashlib.sha256(expected).hexdigest(),'schema.sql':hashlib.sha256(schema).hexdigest()}}
    normalize(bench,results,ref)
    assert (bench/'tpcds-setup.sh').read_bytes()==expected
    assert (results/'workload-normalization/tpcds-setup.original.sh').read_bytes()==source
    normalize(bench,results,ref)
    (bench/'schema.sql').write_text('changed schema')
    with pytest.raises(ValueError,match='metadata mismatch'):
        normalize(bench,results,ref)

@pytest.mark.parametrize('arch,expected',[('aarch64',['start']),('x86_64',['normalize','start'])])
def test_startup_normalization_only_runs_on_x86(tmp_path,arch,expected):
    import os
    code=f'''source "{ROOT/'scripts/adapter.sh'}"
initialize_runtime() {{ SPARK_CONTAINER=unit; }}
docker() {{ echo normalize; }}
start_spark_runtime() {{ echo start; }}
start_celeborn
'''
    p=subprocess.run(['bash','-c',code],env=os.environ|{'EXPECTED_ARCH':arch,'PERF_WORK_DIR':'/home/runner/boostkit-perf/celeborn/unit','RESULTS_DIR':str(tmp_path)},capture_output=True,text=True)
    assert p.returncode==0,p.stderr
    assert p.stdout.splitlines()==expected
