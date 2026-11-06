#!/usr/bin/env python3
"""Host-only preflight and integrity-checked downloads. Never installs host software."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

APACHE = "https://archive.apache.org/dist/"
GITCODE = "https://gitcode.com/helloxteen_/OmniOperatorDebugAgent/releases/download/tpcds/"
JDK = "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u252-b09/"
SOURCES = {
    "spark": (APACHE + "spark/spark-3.5.2/spark-3.5.2-bin-hadoop3.tgz", "sha512",
              "ae243483c2d07dc0feade02ac681956e9577e22935e32bb4ffca4fce02243682ca71dadeff9e6566153e132b0a71c518ded2dc58d08a124679843bffd3237539"),
    "hadoop": (APACHE + "hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz", "sha256",
               "226b6cbdf769467250054b3abdf26df9f05fde44bbb82fe5d12d6993ea848f64"),
    "hive": (APACHE + "hive/hive-3.1.0/apache-hive-3.1.0-bin.tar.gz", "sha256",
             "f90b5988d4d81dafa97fa3059cfbb89ac6c8c1015b34b20f1e72902ddbb9927e"),
    "tez": (APACHE + "tez/0.10.0/apache-tez-0.10.0-bin.tar.gz", "sha512",
            "bfdd65d031bf92b078237e6653c3a918eec18641981b17461c7d1faeefcfae9c84ab3bee64622bc15f1e5c647e292e3aa0df004fd6da2cf1f85caad91b94755e"),
    "zookeeper": (APACHE + "zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz", "sha1",
                  "2a9e53f5990dfe0965834a525fbcad226bf93474"),
    "jdbc": ("https://repo.maven.apache.org/maven2/mysql/mysql-connector-java/5.1.49/mysql-connector-java-5.1.49.jar",
             "sha1", "cf76d2e4c9c3782a85c15c87bec5772b34ffd0e5"),
}
ARCH_SOURCES = {
    "aarch64": {
        "java": (JDK + "OpenJDK8U-jdk_aarch64_linux_hotspot_8u252b09.tar.gz", "sha256",
                 "536bf397d98174b376da9ed49d2f659d65c7310318d8211444f4b7ba7c15e453"),
        "tpcds": (GITCODE + "hive-testbench-hdp3-arm.zip", "sha256",
                  "11f5ea3a6a7d68fba7bca1543e1454109ced69bc134192da1d8d659e456c60de"),
    },
    "x86_64": {
        "java": (JDK + "OpenJDK8U-jdk_x64_linux_hotspot_8u252b09.tar.gz", "sha256",
                 "2b59b5282ff32bce7abba8ad6b9fde34c15a98f949ad8ae43e789bbd78fc8862"),
        "tpcds": (GITCODE + "hive-testbench-hdp3-x86.zip", "sha256",
                  "7248c0f9d3d4dfe8435cd6e8137c2023ed8008dcf9bc2d55ff7f2427699b81ee"),
    },
}

def digest(path: Path, algorithm: str = "sha256") -> str:
    h = hashlib.new(algorithm)
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()

def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False, allow_nan=False) + "\n")

def preflight(work: Path, results: Path) -> None:
    mem = {line.split(":")[0]: int(line.split()[1]) * 1024
           for line in Path("/proc/meminfo").read_text().splitlines() if line.split()[1].isdigit()}
    cpus = len(os.sched_getaffinity(0))
    available = mem["MemAvailable"]
    limit = Path("/sys/fs/cgroup/memory.max")
    if limit.exists() and limit.read_text().strip().isdigit():
        available = min(available, int(limit.read_text()))
    free = shutil.disk_usage(work).free
    from extension import adapter_config
    cfg = adapter_config()
    profile = cfg.get("resources", {})
    scale = cfg.get("scale_factor", 100)
    info = {"available_cpus": cpus, "available_memory_bytes": available,
            "free_disk_bytes": free, "yarn_vcores": 64, "yarn_memory_mb": 371200,
            "driver_cores": 8, "driver_memory": "20G", "requested_executors": 200,
            "executor_cores": 8, "executor_memory": "23g",
            "required_memory_bytes": 416 * 1024**3,
            "required_disk_bytes": 500_000_000_000 * scale // 100 * (2 if cfg.get("kind") in ("hudi", "iceberg") else 1)}
    info.update(profile)
    info["scale_factor"] = scale
    write_json(results / "preflight.json", info)
    if cpus < 64 or available < info["required_memory_bytes"] or free < info["required_disk_bytes"]:
        raise RuntimeError("Insufficient resources for the unchanged document configuration; see preflight.json")

def download(work: Path, results: Path, arch: str) -> None:
    archives = work / "downloads"
    archives.mkdir(exist_ok=True)
    records = {}
    for key, (url, algorithm, expected) in (SOURCES | ARCH_SOURCES[arch]).items():
        target = archives / url.rsplit("/", 1)[-1]
        cached = Path("/home/runner/software/spark/packages") / target.name
        if not target.exists():
            if cached.is_file() and digest(cached, algorithm) == expected:
                shutil.copyfile(cached, target)
            else:
                part = target.with_name(target.name + ".part")
                print(f"[spark] downloading {key}: {url}", flush=True)
                subprocess.run(["curl", "-fSL", "--retry", "3", "--connect-timeout", "20",
                                "--max-time", "1800", "-o", str(part), url], check=True)
                if digest(part, algorithm) != expected:
                    raise RuntimeError(f"{key}: checksum mismatch")
                part.rename(target)
        if digest(target, algorithm) != expected:
            raise RuntimeError(f"{key}: checksum mismatch")
        records[key] = {"url": url, "path": str(target), "algorithm": algorithm,
                        "expected": expected, "sha256": digest(target)}
    from extension import prepare_assets
    records.update(prepare_assets(work, results, arch))
    write_json(results / "sources.json", records)
    write_json(work / "sources.json", records)

if __name__ == "__main__":
    work, results = Path(os.environ["PERF_WORK_DIR"]), Path(os.environ["RESULTS_DIR"])
    if sys.argv[1] == "preflight":
        preflight(work, results)
    elif sys.argv[1] == "download":
        download(work, results, os.environ["EXPECTED_ARCH"])
    else:
        raise SystemExit("Unknown assets command")
