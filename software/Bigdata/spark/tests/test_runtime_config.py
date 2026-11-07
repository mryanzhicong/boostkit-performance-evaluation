from __future__ import annotations
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import runtime as runtime_module


def make_runtime(tmp_path):
    runtime = runtime_module.Runtime.__new__(runtime_module.Runtime)
    runtime.work = tmp_path / "work"
    runtime.results = tmp_path / "results"
    runtime.home = runtime.work / "home"
    runtime.logs = runtime.work / "logs"
    for path in (runtime.work, runtime.results, runtime.home, runtime.logs):
        path.mkdir(parents=True)
    runtime.uid = runtime.gid = 1000
    runtime.user = "bench"
    packages = {}
    for name in ("java", "hadoop", "hive", "spark", "tez", "zookeeper"):
        package = tmp_path / "packages" / name
        (package / "etc/hadoop").mkdir(parents=True)
        (package / "conf").mkdir()
        (package / "bin").mkdir()
        packages[name] = str(package)
    packages["tpcds"] = str(tmp_path / "testbench")
    runtime.paths = packages
    runtime.env = {"JAVA_HOME": packages["java"], "PATH": "/usr/bin:/bin"}
    runtime.extension = SimpleNamespace(configure=lambda conf: conf, install=lambda: None,
                                        resources={}, name="celeborn", version="0.5.3",
                                        scale=100, cfg={})
    return runtime


def test_yarn_site_overrides_timeline_store(tmp_path):
    runtime = make_runtime(tmp_path)
    runtime.configure()
    yarn_site = (Path(runtime.paths["hadoop"]) / "etc/hadoop/yarn-site.xml").read_text()
    assert "yarn.timeline-service.store-class" in yarn_site
    assert "org.apache.hadoop.yarn.server.timeline.MemoryTimelineStore" in yarn_site


def test_hadoop_env_does_not_pin_hadoop_classpath(tmp_path):
    runtime = make_runtime(tmp_path)
    runtime.env |= {"JAVA_HOME": "/opt/java", "TEZ_CONF_DIR": "/opt/tez/conf",
                    "HADOOP_CLASSPATH": "/opt/tez/*", "HADOOP_MAPRED_HOME": "/opt/hadoop"}
    runtime.configure()
    env_text = (Path(runtime.paths["hadoop"]) / "etc/hadoop/hadoop-env.sh").read_text()
    assert "export JAVA_HOME='/opt/java'" in env_text
    assert "export TEZ_CONF_DIR='/opt/tez/conf'" in env_text
    assert "export HADOOP_MAPRED_HOME=" in env_text
    # Hive's launcher prepends its jars to HADOOP_CLASSPATH; a value written to
    # hadoop-env.sh would replace it and break schematool/metastore classloading.
    assert "HADOOP_CLASSPATH" not in env_text


def test_tez_site_uses_cluster_hadoop_libraries(tmp_path):
    runtime = make_runtime(tmp_path)
    runtime.configure()
    tez_site = (Path(runtime.paths["tez"]) / "conf/tez-site.xml").read_text()
    assert "tez.use.cluster.hadoop-libs" in tez_site
    assert ">true<" in tez_site


def test_strip_tez_hadoop_jars_keeps_tez_jars(tmp_path):
    lib = tmp_path / "tez/lib"
    lib.mkdir(parents=True)
    for name in ("hadoop-hdfs-client-3.1.3.jar", "hadoop-mapreduce-client-core-3.1.3.jar",
                 "tez-api-0.10.0.jar", "tez-dag-0.10.0.jar"):
        (lib / name).write_text("")
    removed = runtime_module.strip_tez_hadoop_jars(tmp_path / "tez")
    assert removed == ["hadoop-hdfs-client-3.1.3.jar", "hadoop-mapreduce-client-core-3.1.3.jar"]
    assert sorted(p.name for p in lib.iterdir()) == ["tez-api-0.10.0.jar", "tez-dag-0.10.0.jar"]
    assert runtime_module.strip_tez_hadoop_jars(tmp_path / "tez") == []


def test_hive_keeps_its_own_guava(tmp_path):
    lib = tmp_path / "hive/lib"
    lib.mkdir(parents=True)
    (lib / "guava-19.0.jar").write_text("")
    (lib / "jersey-guava-2.25.1.jar").write_text("")
    assert runtime_module.hive_guava_jar(tmp_path / "hive").name == "guava-19.0.jar"
    (lib / "guava-11.0.2.jar").write_text("")
    with pytest.raises(RuntimeError):
        runtime_module.hive_guava_jar(tmp_path / "hive")


def test_collect_yarn_logs_copies_container_logs(tmp_path):
    runtime = make_runtime(tmp_path)
    runtime.collect_yarn_logs()
    assert not (runtime.results / "yarn-logs").exists()
    container = runtime.work / "hdfs/yarn/log/application_1/container_1"
    container.mkdir(parents=True)
    (container / "container_1_stdout").write_text("AM log")
    runtime.collect_yarn_logs()
    assert (runtime.results / "yarn-logs/application_1/container_1/container_1_stdout").read_text() == "AM log"


def test_collect_yarn_logs_fetches_aggregated_application_logs(tmp_path):
    runtime = make_runtime(tmp_path)
    (runtime.results / "hive-tez-smoke.log").write_text(
        "Application application_1794041753670_0002 failed 2 times")
    fetched = []

    def fake_run(args, log, **kwargs):
        fetched.append(list(args))
        path = runtime.results / log
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("aggregated AM log")
        return "aggregated AM log"

    runtime.run = fake_run
    runtime.collect_yarn_logs()
    assert fetched == [["yarn", "logs", "-applicationId", "application_1794041753670_0002"]]
    assert (runtime.results / "yarn-logs/application_1794041753670_0002.log").read_text() == "aggregated AM log"


def test_mysql_bootstrap_uses_mysql_owned_tmpdir(tmp_path, monkeypatch):
    runtime = make_runtime(tmp_path)
    calls = []
    monkeypatch.setattr(runtime_module.subprocess, "run",
                        lambda args, **kwargs: calls.append((args, kwargs)) or subprocess.CompletedProcess(args, 0))
    runtime.run = Mock(return_value="")
    runtime.background = Mock()
    runtime.wait_port = Mock()

    runtime.bootstrap_mysql()

    mysql = runtime.work / "mysql"
    tmp = mysql / "tmp"
    assert tmp.is_dir()
    chown = [args for args, _ in calls if args[0] == "chown"]
    assert chown and chown[0][:3] == ["chown", "-R", "mysql:mysql"]
    assert chown[0][3] == str(mysql)
    install = runtime.run.call_args_list[0]
    assert f"--datadir={mysql}" in install.args[0]
    assert f"--tmpdir={tmp}" in install.args[0]
    assert install.kwargs["env"]["TMPDIR"] == str(tmp)
    server = runtime.background.call_args_list[0]
    assert f"--tmpdir={tmp}" in server.args[0]
    assert server.kwargs["env"]["TMPDIR"] == str(tmp)
    runtime.wait_port.assert_called_once_with(3306)


def test_failed_bootstrap_copies_mariadb_error_log(tmp_path, monkeypatch):
    runtime = make_runtime(tmp_path)
    source = tmp_path / "mariadb.log"
    source.write_text("InnoDB: Unable to create temporary file; errno: 13\n")
    monkeypatch.setattr(runtime_module, "MARIADB_ERROR_LOG", source)
    monkeypatch.setattr(runtime_module.subprocess, "run",
                        lambda args, **kwargs: subprocess.CompletedProcess(args, 0))
    runtime.run = Mock(side_effect=RuntimeError("mysql-init.log: exit 1"))
    runtime.background = Mock()
    runtime.wait_port = Mock()

    with pytest.raises(RuntimeError):
        runtime.bootstrap_mysql()

    assert "errno: 13" in (runtime.results / "mysql-init-details.log").read_text()
    assert runtime.background.call_count == 0
