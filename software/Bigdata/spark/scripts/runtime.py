#!/usr/bin/env python3
"""Private-container deployment and TPC-DS execution, without host administration."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import pwd
import re
import shutil
import signal
import socket
import subprocess
import sys
import tarfile
import threading
import time
import urllib.request
from xml.etree import ElementTree as ET
import zipfile

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent / "results"))
from parse_benchmark import parse_log, summarize, verify_queries
from extension import Extension

REFERENCE = Path(__file__).parent / "reference"
SPARK_CONF = {
    "spark.executor.extraJavaOptions": "-XX:+UseG1GC -XX:ActiveProcessorCount=8",
    "spark.task.cpus": "1", "spark.sql.orc.impl": "native",
    "spark.sql.autoBroadcastJoinThreshold": "100M",
    "spark.default.parallelism": "960", "spark.sql.shuffle.partitions": "960",
    "spark.sql.adaptive.enabled": "true", "spark.sql.adaptive.join.enabled": "true",
    "spark.sql.adaptive.skewedJoin.enabled": "true",
    "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
    "spark.network.timeout": "600", "spark.sql.broadcastTimeout": "600",
    "spark.locality.wait": "0", "spark.sql.sources.parallelPartitionDiscovery.parallelism": "60",
}
PROFILE = {"yarn_vcores": 64, "yarn_memory_mb": 371200, "driver_cores": 8,
           "driver_memory": "20G", "requested_executors": 200,
           "executor_cores": 8, "executor_memory": "23g"}
MARIADB_ERROR_LOG = Path("/var/log/mariadb/mariadb.log")
TPCDS_TABLES = ("call_center", "catalog_page", "catalog_returns", "catalog_sales", "customer",
                "customer_address", "customer_demographics", "date_dim", "household_demographics",
                "income_band", "inventory", "item", "promotion", "reason", "ship_mode", "store",
                "store_returns", "store_sales", "time_dim", "warehouse", "web_page", "web_returns",
                "web_sales", "web_site")
# Settings written into hadoop-env.sh so daemons and command-line clients see
# them. HADOOP_CLASSPATH is intentionally absent: Hive's launcher prepends its
# own classpath to HADOOP_CLASSPATH and then starts hadoop, whose shell sources
# hadoop-env.sh again; a value written there would replace that classpath with
# the Tez entries only, so hive tools (schematool, metastore, CLI) would miss
# the hive-beeline and hive-* jars.
HADOOP_ENV_EXPORT_KEYS = ("JAVA_HOME", "TEZ_CONF_DIR", "HADOOP_MAPRED_HOME")

def hadoop_env_exports(env: dict) -> str:
    return "\n".join(f"export {k}='{v}'" for k, v in env.items() if k in HADOOP_ENV_EXPORT_KEYS)

def strip_tez_hadoop_jars(tez: Path) -> list[str]:
    # Tez 0.10.0 bundles Hadoop 3.1.3 client jars. Hive prepends HADOOP_CLASSPATH
    # to hadoop's own classpath, so those old jars shadow Hadoop 3.2.0 and Hive's
    # metastore fails with NoSuchMethodError on Configuration.getTimeDuration;
    # the cluster libraries are used instead (tez.use.cluster.hadoop-libs).
    removed = []
    for stale in sorted((tez / "lib").glob("hadoop-*.jar")):
        stale.unlink()
        removed.append(stale.name)
    return removed

def hive_guava_jar(hive: Path) -> Path:
    jars = sorted((hive / "lib").glob("guava-*.jar"))
    if len(jars) != 1:
        raise RuntimeError("Ambiguous Hive Guava dependency")
    return jars[0]

def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n")

def xml_config(path: Path, properties: dict) -> None:
    root = ET.Element("configuration")
    for name, value in properties.items():
        prop = ET.SubElement(root, "property")
        ET.SubElement(prop, "name").text = name
        ET.SubElement(prop, "value").text = str(value)
    path.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(root).write(path, encoding="utf-8", xml_declaration=True)

def extract_tar(archive: Path, destination: Path) -> Path:
    destination.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive) as tar:
        for m in tar.getmembers():
            target = (destination / m.name).resolve()
            if not target.is_relative_to(destination.resolve()) or m.isdev():
                raise ValueError("Unsafe archive entry")
            if m.issym() or m.islnk():
                link = (target.parent if m.issym() else destination) / m.linkname
                if not link.resolve().is_relative_to(destination.resolve()):
                    raise ValueError("Unsafe archive link")
        tar.extractall(destination)
    children = list(destination.iterdir())
    if len(children) != 1 or not children[0].is_dir():
        raise ValueError(f"Expected one distribution directory in {archive.name}")
    return children[0]

class Runtime:
    def __init__(self):
        self.work = Path(os.environ["PERF_WORK_DIR"])
        self.results = Path(os.environ["RESULTS_DIR"])
        self.uid, self.gid = int(os.environ["BENCH_UID"]), int(os.environ["BENCH_GID"])
        self.packages = self.work / "packages"
        self.state = self.work / "runtime.json"
        self.home = self.work / "home"
        self.logs = self.work / "logs"
        self.sources = json.loads((self.work / "sources.json").read_text())
        self.paths = json.loads(self.state.read_text()) if self.state.exists() else {}
        self.user = self.paths.get("user", "bench")
        self.env = os.environ.copy()
        self.env.update({"HOME": str(self.home), "LANG": "C.UTF-8", "LC_ALL": "C.UTF-8",
                         "NO_PROXY": "localhost,127.0.0.1,server1", "no_proxy": "localhost,127.0.0.1,server1"})
        self.env.pop("JAVA_TOOL_OPTIONS", None)
        self.extension = Extension(self)
        if self.paths:
            self.environment()

    def environment(self):
        for name in ("java", "hadoop", "hive", "spark", "tez"):
            self.env[{"java": "JAVA_HOME"}.get(name, name.upper() + "_HOME")] = self.paths[name]
        self.env["PATH"] = ":".join(str(Path(self.paths[n]) / "bin") for n in ("java", "hadoop", "hive", "spark")) + ":/usr/bin:/bin:/usr/sbin"
        self.env["HADOOP_CONF_DIR"] = str(Path(self.paths["hadoop"]) / "etc/hadoop")
        self.env["HIVE_CONF_DIR"] = str(Path(self.paths["hive"]) / "conf")
        self.env["TEZ_CONF_DIR"] = str(Path(self.paths["tez"]) / "conf")
        self.env["HADOOP_CLASSPATH"] = self.env["TEZ_CONF_DIR"] + ":" + self.paths["tez"] + "/*:" + self.paths["tez"] + "/lib/*"
        for name in ("HADOOP_LOG_DIR", "YARN_LOG_DIR"):
            self.env[name] = str(self.logs / "hadoop")
        self.env["YARN_PID_DIR"] = str(self.work / "pids")
        self.env["HADOOP_PID_DIR"] = str(self.work / "pids")
        self.env["ZOO_LOG_DIR"] = str(self.logs / "zookeeper")
        self.env["HIVE_LOG_DIR"] = str(self.logs / "hive")
        self.env["SPARK_LOG_DIR"] = str(self.logs / "spark")
        self.env["SPARK_PID_DIR"] = str(self.work / "pids")
        self.env["TMPDIR"] = str(self.work / "tmp")

    def command(self, args: list[str], as_user: bool = True) -> list[str]:
        return ["runuser", "-u", self.user, "--", "prlimit", "--nofile=1048576:1048576", "--", *map(str, args)] if as_user else list(map(str, args))

    def run(self, args, log: str, *, as_user=True, timeout=1800, input=None, cwd=None, check=True, env=None):
        path = self.results / log
        path.parent.mkdir(parents=True, exist_ok=True)
        print("[spark]", log, " ".join(map(str, args[:4])), flush=True)
        with path.open("a") as out:
            proc = subprocess.run(self.command(args, as_user), env=env or self.env,
                                  cwd=cwd or self.home, input=input, text=True,
                                  stdout=out, stderr=subprocess.STDOUT, timeout=timeout)
        if proc.returncode and check:
            print(path.read_text(errors="replace")[-6000:], flush=True)
            raise RuntimeError(f"{log}: exit {proc.returncode}")
        return path.read_text(errors="replace")

    def background(self, args, log: str, as_user=True, env=None):
        path = self.logs / log
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a") as out:
            p = subprocess.Popen(self.command(args, as_user), env=env or self.env, cwd=self.home,
                                 stdout=out, stderr=subprocess.STDOUT, start_new_session=True)
        with (self.work / "services.jsonl").open("a") as f:
            f.write(json.dumps({"pid": p.pid, "log": str(path)}) + "\n")

    def wait_port(self, port: int):
        deadline = time.monotonic() + 600
        while time.monotonic() < deadline:
            try:
                with socket.create_connection(("server1", port), timeout=2):
                    return
            except OSError:
                time.sleep(2)
        raise RuntimeError(f"Service on port {port} did not become ready")

    def install(self):
        self.home.mkdir(parents=True, exist_ok=True)
        self.logs.mkdir(exist_ok=True)
        try:
            self.user = pwd.getpwuid(self.uid).pw_name
        except KeyError:
            if subprocess.run(["getent", "group", str(self.gid)], stdout=subprocess.DEVNULL).returncode:
                subprocess.run(["groupadd", "-g", str(self.gid), "bench"], check=True)
            subprocess.run(["useradd", "-u", str(self.uid), "-g", str(self.gid),
                            "-M", "-d", str(self.home), "-s", "/bin/bash", "bench"], check=True)
            self.user = "bench"
        self.paths["user"] = self.user
        for name in ("java", "spark", "hadoop", "hive", "tez", "zookeeper"):
            self.paths[name] = str(extract_tar(Path(self.sources[name]["path"]), self.packages / name))
        tez_hadoop_jars = strip_tez_hadoop_jars(Path(self.paths["tez"]))
        self.paths["tpcds"] = str(self.work / "testbench")
        bench = Path(self.paths["tpcds"])
        bench.mkdir()
        with zipfile.ZipFile(self.sources["tpcds"]["path"]) as z:
            for name in z.namelist():
                parts = Path(name).parts[1:]
                if not parts or parts[0] not in ("tpcds-gen", "settings", "ddl-tpcds", "spark-queries-tpcds", "tpcds-setup.sh"):
                    continue
                if ".." in parts:
                    raise ValueError("Unsafe testbench entry")
                dest = bench.joinpath(*parts)
                if name.endswith("/"):
                    dest.mkdir(parents=True, exist_ok=True)
                else:
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_bytes(z.read(name))
        # ZIP permissions are not portable; only the validated native generator needs execution.
        for name in ("dsdgen", "dsqgen"):
            for binary in bench.rglob(name):
                binary.chmod(0o755)
                header = binary.read_bytes()[:20]
                machine = 183 if os.environ["EXPECTED_ARCH"] == "aarch64" else 62
                if header[:4] != b"\x7fELF" or int.from_bytes(header[18:20], "little") != machine:
                    raise RuntimeError(f"Wrong native generator architecture: {binary}")
        verify_queries(bench / "spark-queries-tpcds", json.loads((REFERENCE / "queries.sha256.json").read_text()))
        self.environment()
        hive, hadoop, spark = (Path(self.paths[n]) for n in ("hive", "hadoop", "spark"))
        jdbc = Path(self.sources["jdbc"]["path"])
        for folder in (hive / "lib", spark / "jars"):
            shutil.copy2(jdbc, folder / jdbc.name)
        # Hive 3.1.0 ships Guava 19 and Hadoop 3.2.0 ships Guava 11.0.2. Keep
        # Hive's own jar: Calcite 1.16 (Hive's planner) requires
        # ImmutableSortedMap to implement NavigableMap, which Guava 11 lacks.
        guava = hive_guava_jar(hive)
        snappy = "hadoop-bundled"
        if os.environ["EXPECTED_ARCH"] == "aarch64":
            # Tez writes its AM payload with snappy-java, and Hadoop 3.2.0's
            # snappy-java 1.0.4.1 has no Linux/aarch64 native library. The Tez
            # archive comes first on the AM classpath, so a newer jar there wins.
            jar = Path(self.sources["snappy_java"]["path"])
            shutil.copy2(jar, Path(self.paths["tez"]) / jar.name)
            snappy = jar.name
        write_json(self.state, self.paths)
        self.extension.install()
        self.configure()
        subprocess.run(["chown", "-R", f"{self.uid}:{self.gid}", str(self.work), str(self.results)], check=True)
        versions = {}
        for name, args, expected in (
            ("java", ["java", "-version"], "1.8.0_252"),
            ("hadoop", ["hadoop", "version"], "Hadoop 3.2.0"),
            ("spark", ["spark-submit", "--version"], "3.5.2"),
            ("hive", ["hive", "--version"], "3.1.0"),
            ("mariadb", ["mariadb", "--version"], "MariaDB"),
        ):
            text = self.run(args, f"versions/{name}.log")
            if expected not in text:
                raise RuntimeError(f"Unexpected installed {name} version")
            versions[name] = text
        versions.update({"zookeeper": "3.4.6", "tez": "0.10.0", "jdbc": "5.1.49",
                         "hive_guava": guava.name, "snappy_java": snappy,
                         "tez_bundled_hadoop_jars_removed": tez_hadoop_jars})
        versions.update(self.extension.versions())
        write_json(self.results / "versions.json", versions)
        self.run(["rpm", "-qa"], "rpm-packages.txt")
        self.run(["python3", "-c", "import resource,json,sys; limits=resource.getrlimit(resource.RLIMIT_NOFILE); "
                  "print(json.dumps({'nofile_soft':limits[0],'nofile_hard':limits[1]})); "
                  "sys.exit(0 if limits[0]>=1048576 else 70)"],
                 "process-limits.json")
        Path(os.environ["PERF_ACTUAL_VERSION_FILE"]).write_text(self.extension.version + "\n")

    def configure(self):
        doc = json.loads((REFERENCE / "document-config.json").read_text())
        hadoop = Path(self.paths["hadoop"])
        hconf = hadoop / "etc/hadoop"
        for component, props in doc.items():
            if component == "tez-site":
                continue
            fixed = {}
            for k, v in props.items():
                v = v.replace("/usr/local/hadoop", str(hadoop))
                v = v.replace("/home/hadoop_tmp_dir", str(self.work / "hadoop-tmp"))
                v = v.replace("/data/data1/hadoop", str(self.work / "hdfs"))
                k = k.replace("hadoop.proxyuser.root.", f"hadoop.proxyuser.{self.user}.")
                fixed[k] = v
            if component == "hdfs-site":
                fixed["dfs.namenode.http-address"] = "server1:50070"
                fixed["dfs.namenode.checkpoint.dir"] = str(self.work / "hdfs/checkpoint")
                fixed["dfs.journalnode.edits.dir"] = str(self.work / "hdfs/journal")
            if component == "yarn-site":
                fixed["yarn.nodemanager.env-whitelist"] = "JAVA_HOME,HADOOP_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME,PATH,LANG,TZ"
                # Hadoop 3.2.0's default LeveldbTimelineStore needs a bundled native
                # leveldbjni library that does not exist for aarch64; the in-memory
                # store needs no native code, works on both architectures and is
                # sufficient because the case never queries application history.
                fixed["yarn.timeline-service.store-class"] = "org.apache.hadoop.yarn.server.timeline.MemoryTimelineStore"
            xml_config(hconf / f"{component}.xml", fixed)
        for name in ("hadoop", "yarn"):
            with (hconf / f"{name}-env.sh").open("a") as f:
                f.write(f"\nexport JAVA_HOME='{self.paths['java']}'\n")
                f.write(f"export HADOOP_LOG_DIR='{self.logs / 'hadoop'}'\n")
                f.write(f"export YARN_LOG_DIR='{self.logs / 'hadoop'}'\n")
        hive_props = {
            "javax.jdo.option.ConnectionURL": "jdbc:mysql://server1:3306/hive?createDatabaseIfNotExist=true&useSSL=false",
            "javax.jdo.option.ConnectionDriverName": "com.mysql.jdbc.Driver",
            "javax.jdo.option.ConnectionUserName": "hive",
            "javax.jdo.option.ConnectionPassword": "isolated-container-only",
            "hive.metastore.uris": "thrift://server1:9083",
            "hive.metastore.warehouse.dir": "/user/hive/warehouse",
            "hive.exec.local.scratchdir": str(self.work / "hive-tmp"),
            "hive.downloaded.resources.dir": str(self.work / "hive-resources"),
            "hive.querylog.location": str(self.logs / "hive"),
            "hive.server2.logging.operation.log.location": str(self.logs / "hive/operations"),
            "hive.tez.exec.print.summary": "true", "hive.tez.container.size": "10240",
            "hive.exec.dynamic.partition.mode": "nonstrict",
            "hive.exec.max.dynamic.partitions": "100000",
            "hive.exec.max.dynamic.partitions.pernode": "100000",
            "hive.exec.max.created.files": "1000000", "hive.execution.engine": "tez",
            "hive.zookeeper.quorum": "server1:2181",
            "hive.server2.thrift.bind.host": "server1",
            "hive.server2.enable.doAs": "false",
            "hive.server2.support.dynamic.service.discovery": "false",
        }
        xml_config(Path(self.paths["hive"]) / "conf/hive-site.xml", hive_props)
        hive_conf = Path(self.paths["hive"]) / "conf"
        log_template = hive_conf / "hive-log4j2.properties.template"
        if log_template.exists():
            log_config = re.sub(r"(?m)^property\.hive\.log\.dir\s*=.*$",
                                f"property.hive.log.dir = {self.logs / 'hive'}",
                                log_template.read_text())
            (hive_conf / "hive-log4j2.properties").write_text(log_config)
        tez_conf = Path(self.paths["tez"]) / "conf/tez-site.xml"
        # The bundled Hadoop jars are removed from tez/lib, so the AM and its
        # containers must take the cluster's Hadoop 3.2.0 libraries.
        xml_config(tez_conf, doc["tez-site"] | {"tez.use.cluster.hadoop-libs": "true"})
        zkdir = self.work / "zookeeper-data"
        zkdir.mkdir()
        (zkdir / "myid").write_text("1\n")
        (Path(self.paths["zookeeper"]) / "conf/zoo.cfg").write_text(
            f"tickTime=2000\ninitLimit=10\nsyncLimit=5\ndataDir={zkdir}\nclientPort=2181\nserver.1=server1:2888:3888\n")
        self.env["JMXDISABLE"] = "true"
        for p in (self.work / "tmp", self.work / "pids", self.logs / "hadoop",
                  self.work / "hive-tmp", self.work / "hive-resources", self.logs / "hive"):
            p.mkdir(parents=True, exist_ok=True)
        self.env["HADOOP_MAPRED_HOME"] = self.paths["hadoop"]
        # Pass the documented shell settings into MapReduce task environments.
        env_lines = hadoop_env_exports(self.env)
        with (hconf / "hadoop-env.sh").open("a") as f:
            f.write("\n" + env_lines + "\n")
        conf = SPARK_CONF | {
            "spark.master": "yarn", "spark.eventLog.enabled": "true",
            "spark.eventLog.dir": "hdfs://server1:9000/spark2-history",
            "spark.eventLog.compress": "true",
            "spark.history.fs.logDirectory": "hdfs://server1:9000/spark2-history",
            "spark.sql.hive.metastore.version": "3.1.0", "spark.sql.hive.metastore.jars": "path",
        }
        dirs = [Path(self.paths["hive"]) / "lib/*"]
        dirs += [hadoop / f"share/hadoop/{n}/{s}" for n in ("common", "hdfs", "mapreduce", "yarn") for s in ("*", "lib/*")]
        conf["spark.sql.hive.metastore.jars.path"] = ",".join("file://" + str(p) for p in dirs)
        sconf = Path(self.paths["spark"]) / "conf"
        conf = self.extension.configure(conf)
        (sconf / "spark-defaults.conf").write_text("".join(f"{k} {v}\n" for k, v in conf.items()))
        for n in ("core-site.xml", "hdfs-site.xml"):
            shutil.copy2(hconf / n, sconf / n)
        # Spark's Hive client uses an isolated dependency loader, not its bundled 2.3.9 client.
        xml_config(sconf / "hive-site.xml", {"hive.metastore.uris": "thrift://server1:9083"})
        write_json(self.results / "runtime-context.json",
                   {"resource_profile": self.extension.resources, "spark_conf": conf,
                    "software": self.extension.name, "version": self.extension.version,
                    "scale_factor": self.extension.scale,
                    "container_network": "private bridge" if self.extension.cfg else "bridge",
                    "container_resource_limits": "none", "hadoop_user": self.user})

    def wait_yarn(self):
        # The HTTP UI becomes reachable before the application-client RPC listener.
        for port in (8088, 8031, 8030, 8032):
            self.wait_port(port)
        deadline = time.monotonic() + 600
        while True:
            try:
                text = self.run(["yarn", "node", "-list"], "yarn-nodes.log", timeout=30)
            except subprocess.TimeoutExpired:
                if time.monotonic() >= deadline:
                    raise RuntimeError("YARN NodeManager readiness timed out")
                time.sleep(3)
                continue
            if re.search(r"Total Nodes:\s*[1-9]", text):
                return
            if time.monotonic() >= deadline:
                raise RuntimeError("YARN NodeManager did not register")
            time.sleep(3)

    def collect_mariadb_log(self) -> None:
        # bootstrap wrapper only writes a generic hint; the real reason lives here.
        if MARIADB_ERROR_LOG.exists():
            destination = self.results / "mysql-init-details.log"
            destination.write_text(MARIADB_ERROR_LOG.read_text(errors="replace")[-20000:])
            print("[spark]", destination.name, "captured", flush=True)

    def collect_yarn_logs(self, logs=("hive-tez-smoke.log",), limit: int = 50 * 1024 * 1024) -> None:
        # A failed Tez AM only explains itself in the container stdout log. The
        # NodeManager keeps that under the work tree, but log aggregation enabled
        # by the reference yarn-site deletes it as soon as the application ends,
        # so also pull the aggregated copy out of HDFS while it still exists.
        source = self.work / "hdfs/yarn/log"
        if source.is_dir():
            destination = self.results / "yarn-logs"
            copied = 0
            for path in sorted(source.rglob("*")):
                if not path.is_file():
                    continue
                copied += path.stat().st_size
                if copied > limit:
                    break
                target = destination / path.relative_to(source)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, target)
        applications = set()
        for name in logs:
            path = self.results / name
            if path.exists():
                applications.update(re.findall(r"application_\d+_\d+", path.read_text(errors="replace")))
        for application in sorted(applications)[-4:]:
            target = self.results / "yarn-logs" / f"{application}.log"
            for _ in range(6):
                self.run(["yarn", "logs", "-applicationId", application],
                         f"yarn-logs/{application}.log", check=False, timeout=600)
                if target.exists() and target.stat().st_size:
                    break
                time.sleep(5)
        if (self.results / "yarn-logs").exists():
            print("[spark]", "yarn-logs", "captured", flush=True)

    def generate_tpcds_text(self) -> None:
        # tpcds-setup.sh runs GenTable, whose map tasks start the prebuilt dsdgen
        # binary out of a localized jar archive; in this container that child dies
        # with SIGSEGV (exit 139) while the very same binary succeeds when started
        # directly. Produce the identical text chunks ourselves, upload them where
        # the external text tables look, and let tpcds-setup.sh only load them.
        scale = int(self.extension.scale)
        tools = Path(self.paths["tpcds"]) / "tpcds-gen/target/tools"
        local = self.work / "tpcds-generate" / str(scale)
        script = self.work / "tpcds-generate.sh"
        target = f"/tmp/tpcds-generate/{scale}"
        lines = [
            "#!/bin/bash",
            "set -u",
            f"TOOLS='{tools}'",
            f"OUT='{local}'",
            f"TARGET='{target}'",
            f"SCALE={scale}",
            f"PARALLEL={scale}",
            "run_child() {",
            '  local table="$1" child="$2"',
            '  mkdir -p "$OUT/$table"',
            '  ( cd "$TOOLS" && ./dsdgen -dir "$OUT/$table" -table "$table" -force Y '
            '-scale "$SCALE" -parallel "$PARALLEL" -child "$child" >/dev/null 2>&1 ) '
            '|| echo "$table $child" >> "$OUT/.failures"',
            "}",
            "export -f run_child",
            "export TOOLS OUT SCALE PARALLEL",
            'rm -f "$OUT/.failures"',
            'hdfs dfs -mkdir -p "$TARGET"',
            "for table in " + " ".join(TPCDS_TABLES) + "; do",
            '  seq 1 "$PARALLEL" | xargs -P 64 -I{} bash -c \'run_child "$1" "$2"\' _ "$table" {}',
            '  if [ -s "$OUT/.failures" ]; then',
            '    echo "dsdgen failures:"; cat "$OUT/.failures"; exit 1',
            "  fi",
            '  hdfs dfs -put -f "$OUT/$table" "$TARGET/" || exit 1',
            '  rm -rf "$OUT/$table"',
            "done",
            'hdfs dfs -ls "$TARGET"',
            f'echo "TPC-DS text data generation complete."',
        ]
        script.write_text("\n".join(lines) + "\n")
        script.chmod(0o755)
        subprocess.run(["chown", f"{self.uid}:{self.gid}", str(script)], check=True)
        self.run(["bash", str(script)], "data-generation.log", timeout=12 * 3600)

    def bootstrap_mysql(self) -> None:
        # TMPDIR points at a runner-owned directory but mariadbd runs as the mysql
        # user; without an explicit mysql-owned --tmpdir InnoDB cannot create its
        # bootstrap temp files (EACCES) and the system-table install aborts.
        mysql = self.work / "mysql"
        tmp = mysql / "tmp"
        mysql.mkdir(exist_ok=True)
        tmp.mkdir(exist_ok=True)
        subprocess.run(["chown", "-R", "mysql:mysql", str(mysql)], check=True)
        env = self.env | {"TMPDIR": str(tmp)}
        try:
            self.run(["mariadb-install-db", "--user=mysql", f"--datadir={mysql}",
                      f"--tmpdir={tmp}"], "mysql-init.log", as_user=False, env=env)
        except RuntimeError:
            self.collect_mariadb_log()
            raise
        self.background(["mariadbd", "--user=mysql", f"--datadir={mysql}",
                         f"--tmpdir={tmp}", f"--socket={mysql}/mysql.sock",
                         f"--pid-file={mysql}/mysql.pid",
                         "--bind-address=0.0.0.0", "--skip-name-resolve"],
                        "mariadb/server.log", as_user=False, env=env)
        self.wait_port(3306)
        self.run(["mariadb", "--protocol=socket", f"--socket={mysql}/mysql.sock", "-u", "root"],
                 "mysql-schema.log", as_user=False, env=env, input=
                 "CREATE DATABASE hive; CREATE USER 'hive'@'%' IDENTIFIED BY 'isolated-container-only'; "
                 "GRANT ALL ON hive.* TO 'hive'@'%'; FLUSH PRIVILEGES;\n")

    def start(self):
        self.env["HADOOP_MAPRED_HOME"] = self.paths["hadoop"]
        self.env["JMXDISABLE"] = "true"
        self.background([str(Path(self.paths["zookeeper"]) / "bin/zkServer.sh"), "start-foreground"], "zookeeper/server.log")
        self.wait_port(2181)
        for n in ("namenode", "datanode", "secondarynamenode", "journalnode"):
            if n == "namenode":
                self.run(["hdfs", "namenode", "-format", "-nonInteractive"], "hdfs-format.log")
            self.run(["hdfs", "--daemon", "start", n], f"start-{n}.log")
        self.wait_port(9000)
        self.run(["hdfs", "dfsadmin", "-safemode", "wait"], "hdfs-ready.log", timeout=600)
        for n in ("resourcemanager", "nodemanager", "timelineserver"):
            self.run(["yarn", "--daemon", "start", n], f"start-{n}.log")
        self.wait_yarn()
        self.bootstrap_mysql()
        self.run(["schematool", "-dbType", "mysql", "-initSchema"], "hive-schema.log")
        self.background(["hive", "--service", "metastore", "-p", "9083"], "hive/metastore.log")
        self.wait_port(9083)
        self.background(["hive", "--service", "hiveserver2"], "hive/hiveserver2.log")
        self.wait_port(10000)
        tez = self.work / "tez.tar.gz"
        with tarfile.open(tez, "w:gz") as tar:
            for p in Path(self.paths["tez"]).iterdir():
                tar.add(p, arcname=p.name)
        self.run(["hdfs", "dfs", "-mkdir", "-p", "/apps/tez", "/tmp", "/user/hive/warehouse", "/spark2-history"],
                 "hdfs-directories.log")
        self.run(["hdfs", "dfs", "-chmod", "1777", "/tmp"], "hdfs-permissions.log")
        self.run(["hdfs", "dfs", "-put", str(tez), "/apps/tez/tez.tar.gz"], "tez-upload.log")
        smoke = "set hive.execution.engine=tez; create table student(id int,name string); insert into student values(1,'zhangsan'),(2,'lisi'); select * from student order by id; drop table student;"
        try:
            text = self.run(["beeline", "-u", "jdbc:hive2://server1:10000", "-n", self.user,
                             "--showHeader=false", "--outputformat=tsv2", "-e", smoke], "hive-tez-smoke.log", timeout=1800)
        except RuntimeError:
            self.collect_yarn_logs()
            raise
        if "zhangsan" not in text or "lisi" not in text or re.search(r"Error:|FAILED:", text):
            raise RuntimeError("Hive-on-Tez functional verification failed")
        self.extension.start_services()
        self.generate_tpcds_text()
        self.run(["bash", "tpcds-setup.sh", str(self.extension.scale)], "data-generation.log", timeout=12 * 3600,
                 cwd=Path(self.paths["tpcds"]))

        db = self.extension.source_db
        tables = self.run(["hive", "-S", "--database", db, "-e", "show tables;"], "tables.log")
        expected = set(TPCDS_TABLES)
        found = {line.strip() for line in tables.splitlines()} & expected
        if found != expected:
            raise RuntimeError(f"Incomplete 24-table dataset: missing {expected-found}")
        checks = {}
        for t in sorted(expected):
            ddl = self.run(["hive", "-S", "--database", db, "-e", f"show create table {t};"], f"ddl/{t}.sql")
            if "OrcInputFormat" not in ddl and "ORC" not in ddl.upper():
                raise RuntimeError(f"{t} is not an ORC table")
            counts = self.run(["hive", "-S", "--database", db, "-e", f"select count(*) from {t};"],
                              f"table-counts/{t}.log", timeout=1800)
            numbers = re.findall(r"(?m)^([0-9]+)\s*$", counts)
            if not numbers or int(numbers[-1]) <= 0:
                raise RuntimeError(f"Missing or empty table count: {t}")
            checks[t] = int(numbers[-1])
        self.run(["hdfs", "dfs", "-ls", "-R", f"/user/hive/warehouse/{db}.db"], "data-files.log")
        write_json(self.results / "dataset.json", {"scale_factor": self.extension.scale, "database": db, "format": "orc",
                   "schema": "decimal", "table_count": 24, "tables": sorted(expected), "row_count_logs": checks,
                   "data_files_sha256": hashlib.sha256((self.results / "data-files.log").read_bytes()).hexdigest()})
        self.run(["hadoop", "checknative", "-a"], "native-libraries.log", check=False)
        self.run(["hdfs", "dfsadmin", "-report"], "hdfs-report.log")
        self.run(["yarn", "node", "-list", "-all"], "yarn-ready.log")
        self.extension.prepare_dataset()
        self.extension.verify_engine()
        print(f"[{self.extension.name}] SF{self.extension.scale} stack and 24 tables ready", flush=True)

    def allocation_monitor(self, stop: threading.Event, samples: list):
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        while not stop.is_set():
            try:
                self.extension.sample_services()
                with opener.open("http://server1:8088/ws/v1/cluster/apps?states=RUNNING&applicationTypes=SPARK", timeout=2) as response:
                    apps = json.load(response).get("apps") or {}
                    for app in apps.get("app", []):
                        if app.get("name", "").startswith("spark-tpcds-"):
                            samples.append({"app_id": app["id"], "running_containers": app.get("runningContainers"),
                                            "allocated_mb": app.get("allocatedMB"),
                                            "allocated_vcores": app.get("allocatedVCores"), "time": time.time()})
            except (OSError, ValueError):
                pass
            stop.wait(2)

    def test(self):
        manifest = json.loads((REFERENCE / "queries.sha256.json").read_text())
        folder = Path(self.paths["tpcds"]) / "spark-queries-tpcds"
        queries = verify_queries(folder, manifest)
        runtime = json.loads((self.results / "runtime-context.json").read_text())
        raw = self.results / f"benchmark_{self.extension.name}_raw.log"
        timings = self.results / "timings.jsonl"
        if timings.exists():
            raise RuntimeError("Refusing to overwrite measurement records")
        records, allocations = [], []
        raw.write_text(f"{self.extension.name} {self.extension.version}, Spark 3.5.2, TPC-DS SF{self.extension.scale}, 103 SQL files; 1 warmup + 3 measurement rounds\n")
        for round_id in range(4):
            for name in queries:
                log = self.results / "queries" / f"round-{round_id}" / (name + ".log")
                log.parent.mkdir(parents=True, exist_ok=True)
                args = self.extension.sql_args() + ["--name", f"spark-tpcds-r{round_id}-{name}",
                        "--database", self.extension.query_db, "-f", str(folder / name)]
                print(f"[spark] round={round_id} query={name}", flush=True)
                row = {"query": name, "round": round_id, "phase": "warmup" if round_id == 0 else "measurement",
                       "command": args, "status": "failed"}
                done = threading.Event()
                samples = []
                thread = threading.Thread(target=self.allocation_monitor, args=(done, samples), daemon=True)
                thread.start()
                started = time.monotonic()
                try:
                    with log.open("w") as f:
                        proc = subprocess.Popen(self.command(args), env=self.extension.application_env(), cwd=self.home,
                                                stdout=f, stderr=subprocess.STDOUT, start_new_session=True)
                        try:
                            code = proc.wait(timeout=1800)
                        except subprocess.TimeoutExpired:
                            os.killpg(proc.pid, signal.SIGTERM)
                            try:
                                proc.wait(timeout=10)
                            except subprocess.TimeoutExpired:
                                os.killpg(proc.pid, signal.SIGKILL)
                                proc.wait()
                            code = 124
                    row["exit_code"] = code
                    row["process_wall_seconds"] = time.monotonic() - started
                    text = log.read_text(errors="replace")
                    with raw.open("a") as f:
                        f.write(f"\n===== round={round_id} query={name} exit={code} =====\n" + text)
                    seconds, rows = parse_log(text, code)
                    row.update(status="passed", query_time_seconds=seconds, row_count=rows)
                except Exception as e:
                    row["error"] = str(e)
                    raise
                finally:
                    done.set()
                    thread.join(timeout=4)
                    row.setdefault("process_wall_seconds", time.monotonic() - started)
                    row["allocation_samples"] = samples
                    allocations.extend(samples)
                    with timings.open("a") as f:
                        f.write(json.dumps(row, allow_nan=False) + "\n")
                    records.append(row)
        runtime["allocation_samples"] = allocations
        runtime["actual_executors_max"] = max((max(0, s["running_containers"] - 1)
                                              for s in allocations if isinstance(s["running_containers"], int)), default=None)
        write_json(self.results / "runtime-context.json", runtime)
        self.extension.verify_results()
        write_json(self.results / f"benchmark_{self.extension.name}.json", summarize(records, manifest, runtime))

    def collect(self):
        # Only this container is disposable; Docker stop below terminates every remaining daemon.
        try:
            if self.paths:
                try:
                    self.run(["hdfs", "dfs", "-get", "/spark2-history", str(self.results / "spark-events")],
                             "collect-events.log", timeout=90)
                except Exception:
                    pass
                for component, folder in (("hadoop", "etc/hadoop"), ("hive", "conf"), ("spark", "conf"), ("tez", "conf"), ("zookeeper", "conf")):
                    src = Path(self.paths[component]) / folder
                    if src.exists():
                        shutil.copytree(src, self.results / "effective-config" / component, dirs_exist_ok=True)
            self.extension.collect()
            if self.logs.exists():
                shutil.copytree(self.logs, self.results / "services", dirs_exist_ok=True)
            for path in (self.results / "effective-config").rglob("hive-site.xml"):
                text = path.read_text()
                path.write_text(text.replace("isolated-container-only", "[container-local credential redacted]"))
        finally:
            subprocess.run(["chown", "-R", f"{self.uid}:{self.gid}", str(self.work), str(self.results)], check=True)

if __name__ == "__main__":
    try:
        runtime = Runtime()
        disk_stop = threading.Event()
        disk_thread = threading.Thread(target=runtime.extension.disk_monitor,
                                       args=(disk_stop, sys.argv[1]), daemon=True)
        disk_thread.start()
        try:
            getattr(runtime, sys.argv[1])()
        finally:
            disk_stop.set()
            disk_thread.join(timeout=5)
    except Exception as error:
        print(f"[spark] ERROR: {error}", file=sys.stderr, flush=True)
        raise
