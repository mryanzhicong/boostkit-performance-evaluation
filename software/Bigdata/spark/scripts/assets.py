#!/usr/bin/env python3
"""Host-only preflight and integrity-checked downloads. Never installs host software."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
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

def source_urls(url: str) -> list[str]:
    # Only these already-public release publishers may use URL mirrors; never forward private URLs or credentials.
    public_releases = ("https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/",
                       "https://github.com/apache/gluten/releases/download/")
    if url.startswith(public_releases) and "?" not in url and "#" not in url:
        return ["https://ghfast.top/" + url, "https://ghproxy.net/" + url, url]
    if url.startswith(APACHE):
        return ["https://mirrors.huaweicloud.com/apache/" + url[len(APACHE):], url]
    prefix = "https://repo.maven.apache.org/maven2/"
    if url.startswith(prefix):
        return ["https://mirrors.huaweicloud.com/repository/maven/" + url[len(prefix):], url]
    return [url]


def fetch_verified(target: Path, url: str, algorithm: str, expected: str) -> str:
    errors = []
    part = target.with_name(target.name + ".part")
    for candidate in source_urls(url):
        part.unlink(missing_ok=True)
        print(f"[download] {candidate}", flush=True)
        try:
            subprocess.run(["curl", "-fSL", "--retry", "1", "--connect-timeout", "20",
                            "--max-time", "1800", "--speed-limit", "1024", "--speed-time", "60",
                            "-o", str(part), candidate], check=True)
            if digest(part, algorithm) != expected:
                raise ValueError("checksum mismatch")
            part.replace(target)
            return candidate
        except (OSError, ValueError, subprocess.CalledProcessError) as error:
            errors.append(f"{candidate}: {error}")
            print(f"[download] failed; trying next verified source: {error}", flush=True)
    part.unlink(missing_ok=True)
    raise RuntimeError("All fixed-content download sources failed: " + "; ".join(errors))


def cache_asset(target: Path, algorithm: str, expected: str) -> None:
    cache = Path("/home/runner/software/boostkit-download-cache") / algorithm / expected / target.name
    try:
        cache.parent.mkdir(parents=True, exist_ok=True)
        if cache.exists() and digest(cache, algorithm) == expected:
            return
        with tempfile.NamedTemporaryFile(dir=cache.parent, prefix="download-", delete=False) as stream:
            temporary = Path(stream.name)
        try:
            shutil.copyfile(target, temporary)
            temporary.replace(cache)
        finally:
            temporary.unlink(missing_ok=True)
    except OSError as error:
        print(f"[download] cache unavailable; verified work copy retained: {error}", flush=True)


def preflight(work: Path, results: Path) -> None:
    mem = {line.split(":")[0]: int(line.split()[1]) * 1024
           for line in Path("/proc/meminfo").read_text().splitlines() if line.split()[1].isdigit()}
    cpus = len(os.sched_getaffinity(0))
    available = mem["MemAvailable"]
    limit = Path("/sys/fs/cgroup/memory.max")
    if limit.exists() and limit.read_text().strip().isdigit():
        available = min(available, int(limit.read_text()))
    disk = shutil.disk_usage(work)
    result_disk = shutil.disk_usage(results)
    free = disk.free
    from extension import adapter_config
    cfg = adapter_config()
    profile = cfg.get("resources", {})
    scale = cfg.get("scale_factor", 100)
    info = {"available_cpus": cpus, "available_memory_bytes": available,
            "free_disk_bytes": free, "yarn_vcores": 64, "yarn_memory_mb": 371200,
            "driver_cores": 8, "driver_memory": "20G", "requested_executors": 200,
            "executor_cores": 8, "executor_memory": "23g",
            "required_memory_bytes": 416 * 1024**3,
            "required_disk_bytes": None if cfg else 500_000_000_000,
            "disk_check_policy": "record_only" if cfg else "required_minimum",
            "work_filesystem_total_bytes": disk.total,
            "results_filesystem_free_bytes": result_disk.free,
            "results_filesystem_total_bytes": result_disk.total}
    info.update(profile)
    info["scale_factor"] = scale
    write_json(results / "preflight.json", info)
    if cfg:
        print(f"[{cfg['name']}] Disk space recorded only: work={free} bytes, results={result_disk.free} bytes; no minimum enforced", flush=True)
    disk_insufficient = info["required_disk_bytes"] is not None and free < info["required_disk_bytes"]
    if cpus < 64 or available < info["required_memory_bytes"] or disk_insufficient:
        raise RuntimeError("Insufficient resources for the unchanged document configuration; see preflight.json")

def download(work: Path, results: Path, arch: str) -> None:
    archives = work / "downloads"
    archives.mkdir(exist_ok=True)
    records = {}
    for key, (url, algorithm, expected) in (SOURCES | ARCH_SOURCES[arch]).items():
        target = archives / url.rsplit("/", 1)[-1]
        caches = [Path("/home/runner/software/spark/packages") / target.name,
                  Path("/home/runner/software/boostkit-download-cache") / algorithm / expected / target.name]
        actual_url = None
        if not target.exists():
            cached = next((p for p in caches if p.is_file() and digest(p, algorithm) == expected), None)
            if cached:
                shutil.copyfile(cached, target)
            else:
                actual_url = fetch_verified(target, url, algorithm, expected)
        if digest(target, algorithm) != expected:
            raise RuntimeError(f"{key}: checksum mismatch")
        cache_asset(target, algorithm, expected)
        records[key] = {"url": url, "download_url": actual_url, "path": str(target), "algorithm": algorithm,
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
