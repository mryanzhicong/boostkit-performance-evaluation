#!/usr/bin/env python3
"""Document-pinned extensions of the private Spark runtime (no host services)."""
from __future__ import annotations

import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time
import zipfile


def adapter_config() -> dict:
    root = os.environ.get("PERF_ADAPTER_DIR")
    return json.loads((Path(root) / "profile.json").read_text()) if root else {}


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def validate_asset(path: Path, spec: dict) -> None:
    algorithm = spec.get("algorithm", "sha256")
    h = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    if h.hexdigest() != spec["digest"]:
        raise ValueError(f"Extension asset checksum mismatch: {path.name}")


def prepare_assets(work: Path, results: Path, arch: str) -> dict:
    cfg = adapter_config()
    if not cfg:
        return {}
    if arch != "aarch64":
        raise ValueError("These document-pinned native adapters currently support only aarch64")
    root = Path(os.environ["PERF_ADAPTER_DIR"])
    manifest = json.loads((root / "assets.json").read_text())
    cache = Path(os.environ.get("PERF_ASSET_DIR", f"/home/runner/software/{cfg['name']}/packages"))
    dest = work / "extension-assets"
    dest.mkdir(exist_ok=True)
    records = {}
    for key, spec in manifest.items():
        relative = Path(spec["filename"])
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError("Unsafe extension asset path")
        target = dest / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists():
            source = cache / relative
            if source.is_file():
                validate_asset(source, spec)
                shutil.copyfile(source, target)
            elif spec.get("url"):
                part = target.with_name(target.name + ".part")
                subprocess.run(["curl", "-fSL", "--retry", "3", "--connect-timeout", "20",
                                "--max-time", "1800", "-o", str(part), spec["url"]], check=True)
                validate_asset(part, spec)
                part.rename(target)
            else:
                raise FileNotFoundError(f"Stage document asset at {source}; see adapter README")
        validate_asset(target, spec)
        records["extension_" + key] = spec | {"path": str(target), "sha256": sha256(target)}
    (results / "extension-sources.json").write_text(json.dumps(records, indent=2) + "\n")
    return records


def check_elf(path: Path, machine: int = 183) -> None:
    with path.open("rb") as stream:
        header = stream.read(20)
    if header[:4] != b"\x7fELF" or header[5] != 1 or int.from_bytes(header[18:20], "little") != machine:
        raise ValueError(f"Wrong native library architecture: {path}")


def validate_migration(summary: Path, tables: set[str]) -> list[dict]:
    with summary.open(newline="") as f:
        rows = list(csv.DictReader(f))
    if len(rows) != len(tables) or {r["table"] for r in rows} != tables:
        raise ValueError("Migration must contain exactly the 24 source tables")
    for row in rows:
        if row["status"] != "SUCCESS" or not row["src_count"].isdigit() or not row["tgt_count"].isdigit():
            raise ValueError(f"Unsuccessful migration: {row}")
        if int(row["src_count"]) <= 0 or int(row["src_count"]) != int(row["tgt_count"]):
            raise ValueError(f"Migration changed the row count: {row}")
    return rows


class Extension:
    def __init__(self, runtime):
        self.r = runtime
        self.cfg = adapter_config()
        self.root = Path(os.environ["PERF_ADAPTER_DIR"]) if self.cfg else None
        self.name = self.cfg.get("name", "spark")
        self.version = self.cfg.get("version", "3.5.2")
        self.scale = self.cfg.get("scale_factor", 100)
        self.kind = self.cfg.get("kind", "native")
        self.resources = {"yarn_vcores": 64, "yarn_memory_mb": 371200, "driver_cores": 8,
                          "driver_memory": "20G", "requested_executors": 200,
                          "executor_cores": 8, "executor_memory": "23g"} | self.cfg.get("resources", {})
        self.source_db = f"tpcds_bin_partitioned_decimal_orc_{self.scale}"
        self.target_db = f"tpcds_{self.name}_decimal_orc_{self.scale}"
        self.query_db = ("iceberg." if self.kind == "iceberg" else "") + self.target_db if self.kind in ("hudi", "iceberg") else self.source_db
        self.native = self.r.work / "extension-native"

    def record_disk(self, stage: str):
        filesystems = {}
        for label, path in (("work", self.r.work), ("results", self.r.results)):
            usage = shutil.disk_usage(path)
            filesystems[label] = {"path": str(path), "device": path.stat().st_dev,
                                  "total_bytes": usage.total, "used_bytes": usage.used,
                                  "free_bytes": usage.free}
        with (self.r.results / "disk-usage.jsonl").open("a") as stream:
            stream.write(json.dumps({"time_unix": time.time(), "stage": stage,
                                     "filesystems": filesystems}) + "\n")

    def disk_monitor(self, stop, stage: str):
        if not self.cfg:
            return
        while True:
            try:
                self.record_disk(stage)
            except OSError as error:
                print(f"[{self.name}] Cannot record disk usage: {error}", file=sys.stderr, flush=True)
                return
            if stop.wait(10):
                try:
                    self.record_disk(stage)
                except OSError:
                    pass
                return

    def asset(self, name: str) -> Path:
        return Path(self.r.sources["extension_" + name]["path"])

    def sql_args(self) -> list[str]:
        p = self.resources
        prefix = []
        if self.kind in ("bolt", "velox"):
            env = self.application_env()
            prefix = ["env"] + [f"{k}={env[k]}" for k in ("LD_LIBRARY_PATH", "LIBHDFS3_CONF")]
            if self.kind == "bolt":
                prefix += [f"{k}={env[k]}" for k in ("JAVA_HOME", "PATH", "TZ")]
        return prefix + ["spark-sql", "--master", "yarn", "--deploy-mode", "client", "--driver-cores", str(p["driver_cores"]),
                "--driver-memory", p["driver_memory"], "--num-executors", str(p["requested_executors"]),
                "--executor-cores", str(p["executor_cores"]), "--executor-memory", p["executor_memory"]]

    def application_env(self) -> dict:
        env = self.r.env.copy()
        if self.kind in ("bolt", "velox"):
            env["LD_LIBRARY_PATH"] = str(self.native)
            env["LIBHDFS3_CONF"] = str(self.r.work / "hdfs-client.xml")
        if self.kind == "bolt":
            env["JAVA_HOME"] = self.r.paths["application_java"]
            env["PATH"] = env["JAVA_HOME"] + "/bin:" + env.get("PATH", os.defpath)
            env["TZ"] = "Asia/Shanghai"
        return env

    def install(self):
        if not self.cfg:
            return
        from runtime import extract_tar, write_json
        r = self.r
        jars = Path(r.paths["spark"]) / "jars"
        self.native.mkdir(exist_ok=True)
        if self.kind == "bolt":
            target = r.packages / "bolt"
            target.mkdir()
            with zipfile.ZipFile(self.asset("bundle")) as z:
                for info in z.infolist():
                    path = (target / info.filename).resolve()
                    if not path.is_relative_to(target.resolve()):
                        raise ValueError("Unsafe Bolt archive member")
                z.extractall(target)
                for info in z.infolist():
                    if not info.is_dir():
                        mode = (info.external_attr >> 16) & 0o777
                        if mode:
                            (target / info.filename).chmod(mode)
            found = list(target.rglob(self.cfg["jar_filename"]))
            java = list(target.rglob("bisheng-jdk-17.0.16"))
            if len(found) != 1 or len(java) != 1:
                raise ValueError("Bolt bundle differs from document JAR/JDK; refusing substitution")
            shutil.copy2(found[0], jars / found[0].name)
            r.paths["application_java"] = str(java[0])
            releases = list(target.rglob("releases"))
            if len(releases) != 1:
                raise ValueError("Expected one Bolt releases directory")
            for path in releases[0].glob("*.so*"):
                check_elf(path)
                shutil.copy2(path, self.native / path.name)
            tz = r.packages / "tzdata2025b"
            tz.mkdir()
            # Both IANA archives have multiple top-level files; validate all paths before extraction.
            import tarfile
            for key in ("tzdata", "tzcode"):
                with tarfile.open(self.asset(key)) as tar:
                    for entry in tar.getmembers():
                        if not (tz / entry.name).resolve().is_relative_to(tz.resolve()) or not (entry.isfile() or entry.isdir()):
                            raise ValueError("Unsafe IANA archive member")
                    tar.extractall(tz)
            r.run(["make"], "tz-build.log", as_user=False, cwd=tz)
            r.run(["make", "install", "TZDIR=/usr/share/zoneinfo"], "tz-install.log", as_user=False, cwd=tz)
            if not Path("/usr/share/zoneinfo/Africa/El_Aaiun").is_file():
                raise ValueError("IANA timezone installation failed")
        elif self.kind == "celeborn":
            home = extract_tar(self.asset("server"), r.packages / "celeborn")
            r.paths["celeborn"] = str(home)
            client = home / "spark/celeborn-client-spark-3-shaded_2.12-0.5.3.jar"
            if not client.is_file():
                raise ValueError("Missing pinned Celeborn Spark client")
            shutil.copy2(client, jars / client.name)
            shutil.copy2(self.asset("bridge"), jars / self.asset("bridge").name)
            with zipfile.ZipFile(self.asset("bridge")) as z:
                if "org/apache/spark/shuffle/gluten/celeborn/CelebornShuffleManager.class" not in z.namelist():
                    raise ValueError("Gluten bridge does not contain the document ShuffleManager")
        else:
            shutil.copy2(self.asset("jar"), jars / self.asset("jar").name)
        if self.kind == "velox":
            with zipfile.ZipFile(self.asset("jar")) as z:
                for name in z.namelist():
                    if name.endswith(".so") and (name.startswith("linux/aarch64/")):
                        path = self.native / Path(name).name
                        path.write_bytes(z.read(name))
                        check_elf(path)
            if "extension_boost" in r.sources:
                boost = extract_tar(self.asset("boost"), r.packages / "boost-source")
                prefix = r.work / "boost-1.84.0"
                r.run(["bash", "bootstrap.sh", "--with-libraries=context,filesystem,program_options,regex,system,thread,atomic,chrono,date_time"],
                      "boost-bootstrap.log", as_user=False, cwd=boost)
                r.run(["./b2", "-j8", "variant=release", "link=shared", "threading=multi",
                       f"--prefix={prefix}", "install"], "boost-build.log", as_user=False, cwd=boost, timeout=7200)
                for path in (prefix / "lib").glob("libboost*.so*"):
                    check_elf(path)
                    shutil.copy2(path, self.native / path.name)
            if "extension_abseil" in r.sources:
                r.run(["dnf", "install", "-y", "cmake"], "cmake-install.log", as_user=False)
                abseil = extract_tar(self.asset("abseil"), r.packages / "abseil-source")
                build, prefix = r.work / "abseil-build", r.work / "abseil-20230802.3"
                r.run(["cmake", "-S", str(abseil), "-B", str(build), "-DCMAKE_BUILD_TYPE=Release",
                       "-DCMAKE_CXX_STANDARD=17", "-DBUILD_SHARED_LIBS=ON", "-DABSL_BUILD_TESTING=OFF",
                       "-DABSL_ENABLE_INSTALL=ON", f"-DCMAKE_INSTALL_PREFIX={prefix}",
                       "-DCMAKE_INSTALL_LIBDIR=lib"], "abseil-configure.log", as_user=False)
                r.run(["cmake", "--build", str(build), "--parallel", "8"], "abseil-build.log", as_user=False, timeout=7200)
                r.run(["cmake", "--install", str(build)], "abseil-install.log", as_user=False)
                for path in (prefix / "lib").glob("libabsl*.so*"):
                    check_elf(path)
                    shutil.copy2(path, self.native / path.name)
            for key in r.sources:
                if key.startswith("extension_lib_"):
                    path = Path(r.sources[key]["path"])
                    check_elf(path)
                    shutil.copy2(path, self.native / path.name)
        if self.kind in ("bolt", "velox"):
            if not (self.native / "libgluten.so").is_file():
                raise ValueError("Pinned native libgluten.so is missing")
            for path in sorted(self.native.glob("*.so*")):
                text = r.run(["env", f"LD_LIBRARY_PATH={self.native}", "ldd", str(path)], f"native-linkage/{path.name}.log", as_user=False)
                if "not found" in text:
                    raise ValueError(f"Unresolved native dependency: {path.name}")
        write_json(r.state, r.paths)
        write_json(r.results / "extension-installed.json", {
            "software": self.name, "version": self.version,
            "native_libraries": {p.name: sha256(p) for p in sorted(self.native.glob("*.so*"))},
            "jar_files": {p.name: sha256(p) for p in jars.glob("*.jar")
                          if p.name == self.cfg.get("jar_filename") or p.name.startswith("celeborn-client-")}})

    def configure(self, conf: dict) -> dict:
        if not self.cfg:
            return conf
        conf = conf | self.cfg["spark_conf"]
        r = self.r
        replacements = {"${native}": str(self.native), "${work}": str(r.work),
                        "${jar}": str(Path(r.paths["spark"]) / "jars" / self.cfg.get("jar_filename", "unused")),
                        "${java17}": r.paths.get("application_java", "")}
        for key, value in conf.items():
            for token, replacement in replacements.items():
                value = str(value).replace(token, replacement)
            conf[key] = value
        if self.kind in ("bolt", "velox"):
            shutil.copy2(Path(r.paths["hadoop"]) / "etc/hadoop/core-site.xml", r.work / "hdfs-client.xml")
            conf.update({"spark.driver.extraLibraryPath": str(self.native),
                         "spark.executor.extraLibraryPath": str(self.native),
                         "spark.executorEnv.LD_LIBRARY_PATH": str(self.native),
                         "spark.yarn.appMasterEnv.LD_LIBRARY_PATH": str(self.native)})
        if self.kind == "celeborn":
            home = Path(r.paths["celeborn"])
            storage = [r.work / "celeborn/shuffle1", r.work / "celeborn/shuffle2"]
            for directory in storage:
                directory.mkdir(parents=True)
            (home / "conf/celeborn-defaults.conf").write_text(
                "celeborn.master.host server1\nceleborn.master.port 9097\n"
                "celeborn.master.endpoints server1:9097\nceleborn.metrics.enabled true\n"
                "celeborn.worker.storage.dirs " + ",".join(f"{p}:disktype=SSD" for p in storage) + "\n")
            (home / "conf/celeborn-env.sh").write_text(
                f"export JAVA_HOME='{r.paths['java']}'\nexport CELEBORN_LOG_DIR='{r.logs / 'celeborn'}'\n"
                f"export CELEBORN_PID_DIR='{r.work / 'pids'}'\n"
                "export CELEBORN_MASTER_MEMORY=4g\nexport CELEBORN_WORKER_MEMORY=4g\n"
                "export CELEBORN_WORKER_OFFHEAP_MEMORY=8g\n")
        return conf

    def versions(self) -> dict:
        if not self.cfg:
            return {}
        result = {self.name: self.version, "extension_assets": json.loads((self.r.results / "extension-sources.json").read_text())}
        if self.kind == "bolt":
            result["application_java"] = self.r.run([str(Path(self.r.paths["application_java"]) / "bin/java"), "-version"], "versions/application-java.log")
            if "17.0.16" not in result["application_java"]:
                raise ValueError("Unexpected Bolt Java version")
        return result

    def start_services(self):
        if self.kind == "celeborn":
            home = Path(self.r.paths["celeborn"])
            self.r.run([str(home / "sbin/start-master.sh")], "celeborn-master-start.log")
            self.r.wait_port(9097)
            self.r.run([str(home / "sbin/start-worker.sh")], "celeborn-worker-start.log")
            # Worker registration and transferred data are checked separately; a listening Master is insufficient.
            self.r.run(["lsblk", "-o", "NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,ROTA,MODEL"], "celeborn-block-devices.log", check=False)
            devices = {str(p): p.stat().st_dev for p in (self.r.work / "celeborn").iterdir()}
            (self.r.results / "celeborn-storage.json").write_text(json.dumps(devices, indent=2) + "\n")

    def prepare_dataset(self):
        if self.kind not in ("hudi", "iceberg"):
            return
        r = self.r
        if self.kind == "hudi":
            r.env["HUDI_JAR"] = str(self.asset("jar"))
        stage = r.work / "migration"
        stage.mkdir()
        args = ["bash", str(self.root / "scripts/migrate.sh"), self.source_db, self.target_db]
        if self.kind == "hudi":
            args += ["--parallelism", "1", "--max-retries", "0", "--type", "cow"]
        r.run(args, "migration.log", cwd=stage, timeout=12 * 3600)
        summaries = list(stage.glob("migrate_*/report/summary.csv"))
        if len(summaries) != 1:
            raise ValueError("Missing migration summary")
        dataset = json.loads((r.results / "dataset.json").read_text())
        rows = validate_migration(summaries[0], set(dataset["tables"]))
        # Verify provider and actual file format, in addition to reference-script row counts.
        for table in dataset["tables"]:
            qualified = f"{self.query_db}.{table}"
            text = r.run(self.sql_args() + ["-S", "-e", f"SHOW CREATE TABLE {qualified}; DESCRIBE EXTENDED {qualified};"],
                         f"migration-validation/{table}.log", timeout=1800)
            if not re.search(r"USING\s+" + self.kind + r"\b", text, re.I) or "orc" not in text.lower():
                raise ValueError(f"Wrong target provider/file format: {qualified}")
        dataset.update(source_database=self.source_db, database=self.query_db, provider=self.kind, migration=rows)
        (r.results / "dataset.json").write_text(json.dumps(dataset, indent=2) + "\n")

    def verify_engine(self):
        if self.kind not in ("bolt", "velox", "celeborn"):
            return
        # Force a shuffled aggregation and capture the executed SQL plan before collecting timings.
        r = self.r
        text = r.run(self.sql_args() + ["--database", self.query_db, "-e",
                     "EXPLAIN FORMATTED SELECT ss_store_sk, sum(ss_net_paid) FROM store_sales GROUP BY ss_store_sk; "
                     "SELECT ss_store_sk, sum(ss_net_paid) FROM store_sales GROUP BY ss_store_sk;"],
                     "engine-verification.log", timeout=1800, env=self.application_env())
        if re.search(r"Exception|Error in query|FAILED:", text):
            raise ValueError("Extension engine smoke query failed")
        if self.kind in ("bolt", "velox") and not re.search(r"Transformer|Native.*(?:Plan|Execution)", text):
            raise ValueError("No evidence of native plan; refusing silent Spark fallback")

    def sample_services(self):
        if self.kind != "celeborn":
            return
        path = self.r.results / "celeborn-transfer.json"
        evidence = json.loads(path.read_text()) if path.exists() else {"max_live_shuffle_bytes": 0}
        size = 0
        for p in (self.r.work / "celeborn").rglob("*"):
            try:
                if p.is_file():
                    size += p.stat().st_size
            except FileNotFoundError:
                pass
        evidence["max_live_shuffle_bytes"] = max(evidence["max_live_shuffle_bytes"], size)
        path.write_text(json.dumps(evidence, indent=2) + "\n")

    def verify_results(self):
        if self.kind == "celeborn":
            self.sample_services()
            logs = "\n".join(p.read_text(errors="replace") for p in (self.r.logs / "celeborn").rglob("*.log"))
            transfer = json.loads((self.r.results / "celeborn-transfer.json").read_text())
            evidence = {"worker_registration": bool(re.search(r"register.*worker|worker.*register", logs, re.I)),
                        "max_live_shuffle_bytes": transfer["max_live_shuffle_bytes"]}
            (self.r.results / "celeborn-evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
            if not evidence["worker_registration"] or evidence["max_live_shuffle_bytes"] <= 0:
                raise ValueError("Celeborn worker registration or transferred shuffle bytes not verified")

    def collect(self):
        stage = self.r.work / "migration"
        if stage.exists():
            shutil.copytree(stage, self.r.results / "migration", dirs_exist_ok=True)
        if self.kind == "celeborn" and "celeborn" in self.r.paths:
            shutil.copytree(Path(self.r.paths["celeborn"]) / "conf", self.r.results / "effective-config/celeborn", dirs_exist_ok=True)
