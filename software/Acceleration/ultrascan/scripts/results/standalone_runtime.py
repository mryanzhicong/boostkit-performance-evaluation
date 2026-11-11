#!/usr/bin/env python3
"""Collect environment/build evidence, validate the hsbench results and report.

The case measures exactly one number per scenario: hsbench's
``Mean throughput (overall)`` for the block-mode scan of the Intel
``pcre/snort_literals`` rule set over ``corpora/gutenberg.db``, once through
``hsbench -e`` (rules compiled on start) and once through ``hsbench -U``
(loading the universal/fat bytecode that ``hsdump`` produced).  Everything else
hsbench prints is raw evidence only, never a metric.

Three responsibilities live here:

``system`` / ``runtime``
    Snapshot the host environment around the standalone run.

``build-info``
    Read ``${PERF_WORK_DIR}/build-state.json`` (written by the build stage) and
    persist ``build_info.json``: source identity, Intel sample checksums, the
    Release ``hsbench`` and Debug ``hsdump`` builds, the generated
    ``dump/db.raw`` checksum and the container compiler.

``finalize``
    Strictly validate the ``results.json`` that ``parse_benchmark.py report``
    wrote, then merge it with status/build/environment evidence and render the
    two-row Mean throughput report.  The validator fails closed: a missing
    metric, an extra metric, a sample count mismatch, a non-positive or
    non-finite sample, or a median that does not match the samples is an error
    (exit code 70), never padded or swallowed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import platform
import re
import shlex
import statistics
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# The complete metric contract of this case: exactly these two keys, in the
# block mode, from the Mean throughput (overall) field.
METRIC_KEYS = (
    "hsbench_rules_block_mean_throughput_mbit_s",
    "hsbench_ubc_block_mean_throughput_mbit_s",
)
METRIC_KEY_RE = re.compile(r"^hsbench_(rules|ubc)_block_mean_throughput_mbit_s$")
EXPECTED_UNIT = "Mbit/s"
EXPECTED_DIRECTION = "higher_is_better"
EXPECTED_GROUP = "hsbench"
EXPECTED_SOURCE_FIELD = "Mean throughput (overall)"
EXPECTED_RULES = "pcre/snort_literals"
EXPECTED_CORPUS = "corpora/gutenberg.db"
EXPECTED_SCENARIOS = ("hsbench_rules_block", "hsbench_ubc_block")
FORBIDDEN_WORDS = ("BTL", "btl", "合成语料", "synthetic", "多核", "-march")
REL_TOL = 1e-9
# parse_benchmark.py rounds the reported median and the summary statistics to six
# decimals, so equality with the raw samples is checked with a 1e-6 absolute
# tolerance instead of requiring bit-identical floats.
ABS_TOL = 1e-6
RESULTS_FILENAME = "results.json"


def timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def command(args: list[str]) -> str:
    try:
        completed = subprocess.run(
            args,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return completed.stdout.strip() if completed.returncode == 0 else ""


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def atomic_write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)


def load_json(path: Path) -> dict[str, Any]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return payload if isinstance(payload, dict) else {}


def load_json_or_fail(path: Path, label: str) -> dict[str, Any]:
    if not path.is_file():
        raise RuntimeError(f"{label} is missing: {path}")
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"{label} is not valid JSON: {error}") from error
    if not isinstance(payload, dict):
        raise RuntimeError(f"{label} does not contain a JSON object: {path}")
    return payload


def os_pretty_name() -> str:
    try:
        lines = Path("/etc/os-release").read_text(
            encoding="utf-8", errors="replace"
        ).splitlines()
    except OSError:
        return "ERROR"
    for line in lines:
        field, separator, value = line.partition("=")
        if separator and field.strip() == "PRETTY_NAME":
            try:
                parsed = shlex.split(value, posix=True)
            except ValueError:
                return "ERROR"
            return " ".join(parsed) if parsed else "ERROR"
    return "ERROR"


def cpu_model() -> str:
    lscpu_command = [
        "/usr/bin/sudo",
        "-n",
        "/usr/bin/env",
        "LC_ALL=C",
        "/usr/bin/lscpu",
    ]
    for line in command(lscpu_command).splitlines():
        field, separator, value = line.partition(":")
        if separator and field.strip().casefold() == "model name":
            if value.strip():
                return value.strip()
    return "unknown"


def gcc_version() -> str:
    value = command(["gcc", "-dumpfullversion", "-dumpversion"])
    return value.splitlines()[0] if value else "unknown"


def glibc_version() -> str:
    value = command(["getconf", "GNU_LIBC_VERSION"])
    if value:
        return value.splitlines()[0]
    implementation, version = platform.libc_ver()
    return f"{implementation} {version}" if implementation and version else "unknown"


def collect_system_info() -> dict[str, Any]:
    return {
        "collected_at": timestamp(),
        "architecture": platform.machine(),
        "platform": os_pretty_name(),
        "kernel": platform.release(),
        "cpu_model": cpu_model(),
        "cpu_count": os.cpu_count() or 0,
        "python_version": platform.python_version(),
        "gcc_version": gcc_version(),
        "glibc_version": glibc_version(),
        "numa": command(["numactl", "--hardware"]),
    }


def collect_runtime_state() -> dict[str, Any]:
    governor = command([
        "sh",
        "-c",
        "cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null",
    ])
    return {
        "collected_at": timestamp(),
        "memory": command(["free", "-b"]),
        "cpu_governor": governor,
        "load_average": command(["sh", "-c", "cat /proc/loadavg 2>/dev/null"]),
    }


# ---------------------------------------------------------------------------
# build-state.json -> build_info.json
# ---------------------------------------------------------------------------
def copy_source(state: dict[str, Any]) -> dict[str, Any]:
    source = state.get("source")
    if not isinstance(source, dict):
        raise RuntimeError("build-state.json is missing the source identity")
    required = ("tag", "commit", "archive_sha256")
    for field in required:
        value = source.get(field)
        if not isinstance(value, str) or not value:
            raise RuntimeError(f"build-state.json source.{field} is missing")
    if not re.fullmatch(r"[0-9a-f]{40}", source["commit"]):
        raise RuntimeError(
            f"build-state.json source.commit is not a 40-hex commit: {source['commit']!r}"
        )
    if not re.fullmatch(r"[0-9a-f]{64}", source["archive_sha256"]):
        raise RuntimeError(
            "build-state.json source.archive_sha256 is not a SHA-256 value"
        )
    copied = {
        "kind": source.get("kind", ""),
        "origin": source.get("origin", ""),
        "tag": source["tag"],
        "commit": source["commit"],
        "archive_sha256": source["archive_sha256"],
    }
    return copied


def copy_samples(state: dict[str, Any]) -> dict[str, Any]:
    samples = state.get("samples")
    if not isinstance(samples, dict):
        raise RuntimeError("build-state.json is missing the Intel samples identity")
    zip_sha256 = samples.get("zip_sha256")
    if not isinstance(zip_sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", zip_sha256):
        raise RuntimeError("build-state.json samples.zip_sha256 is not a SHA-256 value")
    copied: dict[str, Any] = {
        "package": samples.get("package", "[Hyperscan] hsbench-samples"),
        "zip_sha256": zip_sha256,
    }
    for member in ("rules", "corpus"):
        entry = samples.get(member)
        if not isinstance(entry, dict):
            raise RuntimeError(f"build-state.json samples.{member} is missing")
        expected_path = EXPECTED_RULES if member == "rules" else EXPECTED_CORPUS
        if entry.get("path") != expected_path:
            raise RuntimeError(
                f"build-state.json samples.{member}.path is {entry.get('path')!r}, "
                f"expected {expected_path!r}"
            )
        member_sha = entry.get("sha256")
        if not isinstance(member_sha, str) or not re.fullmatch(r"[0-9a-f]{64}", member_sha):
            raise RuntimeError(
                f"build-state.json samples.{member}.sha256 is not a SHA-256 value"
            )
        copied[member] = {
            "path": entry["path"],
            "sha256": member_sha,
            "bytes": entry.get("bytes"),
        }
    return copied


def copy_build(state: dict[str, Any]) -> dict[str, Any]:
    build = state.get("build")
    if not isinstance(build, dict):
        raise RuntimeError("build-state.json is missing the build identity")
    release = build.get("release")
    dump = build.get("dump")
    for label, entry, build_type, target in (
        ("release", release, "Release", "hsbench"),
        ("dump", dump, "Debug", "hsdump"),
    ):
        if not isinstance(entry, dict):
            raise RuntimeError(f"build-state.json build.{label} is missing")
        if entry.get("build_type") != build_type:
            raise RuntimeError(
                f"build-state.json build.{label}.build_type is "
                f"{entry.get('build_type')!r}, expected {build_type!r}"
            )
        if entry.get("target") != target:
            raise RuntimeError(
                f"build-state.json build.{label}.target is "
                f"{entry.get('target')!r}, expected {target!r}"
            )
        if not isinstance(entry.get("binary"), str) or not entry["binary"]:
            raise RuntimeError(f"build-state.json build.{label}.binary is missing")
    if dump.get("dump_support") is not True:
        raise RuntimeError(
            "build-state.json build.dump.dump_support is not true; hsdump needs DUMP_SUPPORT"
        )
    return {
        "system": build.get("system", "cmake"),
        "release": dict(release),
        "dump": dict(dump),
    }


def copy_universal_bytecode(state: dict[str, Any]) -> dict[str, Any]:
    bytecode = state.get("universal_bytecode")
    if not isinstance(bytecode, dict):
        raise RuntimeError(
            "build-state.json is missing the universal bytecode identity (dump/db.raw)"
        )
    dump_db = bytecode.get("dump_db")
    sha256 = bytecode.get("sha256")
    if not isinstance(dump_db, str) or not dump_db:
        raise RuntimeError("build-state.json universal_bytecode.dump_db is missing")
    if not isinstance(sha256, str) or not re.fullmatch(r"[0-9a-f]{64}", sha256):
        raise RuntimeError(
            "build-state.json universal_bytecode.sha256 is not a SHA-256 value"
        )
    path = Path(dump_db)
    if path.is_file():
        actual = sha256_file(path)
        if actual != sha256:
            raise RuntimeError(
                f"dump/db.raw checksum mismatch: {actual} != {sha256}"
            )
    return {"dump_db": dump_db, "sha256": sha256}


def copy_compiler(state: dict[str, Any]) -> dict[str, Any]:
    compiler = state.get("compiler")
    if not isinstance(compiler, dict):
        raise RuntimeError("build-state.json is missing the compiler identity")
    cxx = compiler.get("cxx")
    if not isinstance(cxx, str) or not cxx.strip():
        raise RuntimeError("build-state.json compiler.cxx is missing")
    return {"cxx": cxx}


def record_build_info(
    output: Path,
    build_state: Path,
    architecture: str,
    run_id: str,
    requested_version: str | None = None,
    actual_version_file: Path | None = None,
) -> None:
    """Copy the build-stage evidence into build_info.json.

    ``build-state.json`` is written by the build stage and is the single source
    of truth for the source tag/commit, the Intel sample checksums, both cmake
    builds (Release ``hsbench``, Debug ``hsdump`` with ``DUMP_SUPPORT``), the
    generated ``dump/db.raw`` checksum and the container compiler.
    """
    state = load_json_or_fail(build_state, "build-state.json")
    if state.get("software") != "ultrascan":
        raise RuntimeError(
            f"build-state.json belongs to {state.get('software')!r}, not ultrascan"
        )
    source = copy_source(state)
    samples = copy_samples(state)
    build = copy_build(state)
    bytecode = copy_universal_bytecode(state)
    compiler = copy_compiler(state)

    state_architecture = state.get("architecture")
    if state_architecture and state_architecture != architecture:
        raise RuntimeError(
            f"build-state.json architecture is {state_architecture!r}, "
            f"expected {architecture!r}"
        )
    actual_version = state.get("actual_version")
    if not isinstance(actual_version, str) or not actual_version:
        raise RuntimeError("build-state.json actual_version is missing")
    if actual_version_file is not None and actual_version_file.is_file():
        recorded = actual_version_file.read_text(encoding="utf-8").strip()
        if recorded and recorded != actual_version:
            raise RuntimeError(
                f"actual-version.txt ({recorded}) differs from build-state.json "
                f"({actual_version})"
            )
    expected_version = requested_version or state.get("requested_version") or ""
    if expected_version and actual_version != expected_version:
        raise RuntimeError(
            f"built Ultrascan {actual_version} but requested {expected_version}"
        )

    payload: dict[str, Any] = {
        "recorded_at": timestamp(),
        "category": "Acceleration",
        "software": "ultrascan",
        "requested_version": expected_version or actual_version,
        "actual_version": actual_version,
        "architecture": architecture,
        "run_id": run_id,
        "source": source,
        "samples": samples,
        "build": build,
        "universal_bytecode": bytecode,
        "compiler": compiler,
    }
    fix = state.get("x86_64_build_fix")
    if isinstance(fix, dict):
        payload["x86_64_build_fix"] = {
            "applied": bool(fix.get("applied")),
            "cmake_lists_sha256": fix.get("cmake_lists_sha256"),
        }
    for word in FORBIDDEN_WORDS:
        if word in json.dumps(payload, ensure_ascii=False):
            raise RuntimeError(
                f"build_info.json would contain an unsupported concept: {word!r}"
            )
    atomic_write_json(output, payload)


# ---------------------------------------------------------------------------
# results.json validation contract
# ---------------------------------------------------------------------------
def require_dict(value: Any, label: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise RuntimeError(f"{label} must be a JSON object")
    return value


def require_finite_number(value: Any, label: str, *, positive: bool) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise RuntimeError(f"{label} must be a number")
    number = float(value)
    if not math.isfinite(number):
        raise RuntimeError(f"{label} must be finite")
    if positive and number <= 0:
        raise RuntimeError(f"{label} must be positive")
    return number


def require_number_list(value: Any, label: str, count: int, *, positive: bool) -> list[float]:
    if not isinstance(value, list):
        raise RuntimeError(f"{label} must be a list")
    if len(value) != count:
        raise RuntimeError(
            f"{label} has {len(value)} values, expected {count} (the sample count)"
        )
    return [
        require_finite_number(item, f"{label}[{index}]", positive=positive)
        for index, item in enumerate(value)
    ]


def validate_metric(key: str, entry: Any) -> dict[str, Any]:
    if not isinstance(key, str) or METRIC_KEY_RE.match(key) is None:
        raise RuntimeError(f"unsupported metric name: {key!r}")
    if key not in METRIC_KEYS:
        raise RuntimeError(f"metric {key} is not one of the two declared metrics")
    metric = require_dict(entry, f"metric {key}")
    if metric.get("source_name") != key:
        raise RuntimeError(
            f"metric {key} has source_name {metric.get('source_name')!r}"
        )
    if metric.get("unit") != EXPECTED_UNIT:
        raise RuntimeError(
            f"metric {key} has unit {metric.get('unit')!r}, expected {EXPECTED_UNIT}"
        )
    if metric.get("direction") != EXPECTED_DIRECTION:
        raise RuntimeError(
            f"metric {key} has direction {metric.get('direction')!r}, "
            f"expected {EXPECTED_DIRECTION}"
        )
    if metric.get("group") != EXPECTED_GROUP:
        raise RuntimeError(
            f"metric {key} has group {metric.get('group')!r}, expected {EXPECTED_GROUP}"
        )
    if metric.get("source_field") != EXPECTED_SOURCE_FIELD:
        raise RuntimeError(
            f"metric {key} has source_field {metric.get('source_field')!r}, "
            f"expected {EXPECTED_SOURCE_FIELD}"
        )
    source_benchmark = metric.get("source_benchmark")
    if not isinstance(source_benchmark, str) or not source_benchmark:
        raise RuntimeError(f"metric {key} has no source_benchmark description")
    if key == "hsbench_rules_block_mean_throughput_mbit_s":
        if "without universal bytecode" not in source_benchmark or "-e" not in source_benchmark:
            raise RuntimeError(
                f"metric {key} does not describe the '-e' (no universal bytecode) run"
            )
    else:
        if "with universal bytecode" not in source_benchmark or "-U" not in source_benchmark:
            raise RuntimeError(
                f"metric {key} does not describe the '-U' (universal bytecode) run"
            )

    samples = metric.get("samples")
    if isinstance(samples, bool) or not isinstance(samples, int) or samples < 1:
        raise RuntimeError(f"metric {key} has an invalid sample count: {samples!r}")
    sample_values = require_number_list(
        metric.get("sample_values"), f"metric {key} sample_values", samples, positive=True
    )
    value = require_finite_number(metric.get("value"), f"metric {key} value", positive=True)
    expected_median = statistics.median(sample_values)
    if not math.isclose(value, expected_median, rel_tol=REL_TOL, abs_tol=ABS_TOL):
        raise RuntimeError(
            f"metric {key} value ({value}) is not the median of its samples "
            f"({expected_median})"
        )

    summary = require_dict(metric.get("sample_summary"), f"metric {key} sample_summary")
    for field in ("median", "mean", "min", "max"):
        if field not in summary:
            raise RuntimeError(f"metric {key} sample_summary is missing {field}")
    summary_stats = {
        "median": statistics.median(sample_values),
        "mean": statistics.fmean(sample_values),
        "min": min(sample_values),
        "max": max(sample_values),
    }
    for field, expected in summary_stats.items():
        actual = require_finite_number(
            summary[field], f"metric {key} sample_summary.{field}", positive=True
        )
        if not math.isclose(actual, expected, rel_tol=REL_TOL, abs_tol=ABS_TOL):
            raise RuntimeError(
                f"metric {key} sample_summary.{field} ({actual}) does not match"
                f" the samples ({expected})"
            )

    require_number_list(
        metric.get("wall_seconds_sample_values"),
        f"metric {key} wall_seconds_sample_values",
        samples,
        positive=True,
    )
    require_number_list(
        metric.get("max_rss_kib_sample_values"),
        f"metric {key} max_rss_kib_sample_values",
        samples,
        positive=True,
    )
    return metric


def validate_benchmark_section(benchmark: dict[str, Any], measure_reps: int) -> None:
    workload = benchmark.get("workload")
    if not isinstance(workload, str) or "hsbench" not in workload:
        raise RuntimeError("results.json benchmark.workload does not describe hsbench")
    iterations = benchmark.get("iterations")
    if isinstance(iterations, bool) or not isinstance(iterations, int) or iterations != 1:
        raise RuntimeError(
            f"results.json benchmark.iterations must be 1, got {iterations!r}"
        )
    warmups = benchmark.get("warmups")
    if isinstance(warmups, bool) or not isinstance(warmups, int) or warmups < 0:
        raise RuntimeError(f"results.json benchmark.warmups is invalid: {warmups!r}")
    reps = benchmark.get("measure_reps")
    if isinstance(reps, bool) or not isinstance(reps, int) or reps < 1:
        raise RuntimeError(f"results.json benchmark.measure_reps is invalid: {reps!r}")
    if reps != measure_reps:
        raise RuntimeError(
            f"results.json benchmark.measure_reps ({reps}) differs from the "
            f"run ({measure_reps})"
        )
    samples_package = require_dict(
        benchmark.get("samples_package"), "results.json benchmark.samples_package"
    )
    if samples_package.get("rules") != EXPECTED_RULES:
        raise RuntimeError(
            "results.json benchmark.samples_package.rules is "
            f"{samples_package.get('rules')!r}, expected {EXPECTED_RULES!r}"
        )
    if samples_package.get("corpus") != EXPECTED_CORPUS:
        raise RuntimeError(
            "results.json benchmark.samples_package.corpus is "
            f"{samples_package.get('corpus')!r}, expected {EXPECTED_CORPUS!r}"
        )
    scenarios = benchmark.get("scenarios")
    if not isinstance(scenarios, list) or tuple(scenarios) != EXPECTED_SCENARIOS:
        raise RuntimeError(
            f"results.json benchmark.scenarios is {scenarios!r}, "
            f"expected {list(EXPECTED_SCENARIOS)!r}"
        )


def validate_run_payload(
    payload: dict[str, Any],
    version: str,
    architecture: str,
    run_id: str | None,
    measure_reps: int,
) -> dict[str, Any]:
    """Strictly validate the results.json written by parse_benchmark.py report."""
    if payload.get("software") != "ultrascan":
        raise RuntimeError("results.json has an invalid software identity")
    if payload.get("version") != version:
        raise RuntimeError(
            f"results.json version ({payload.get('version')!r}) differs from the "
            f"requested version ({version!r})"
        )
    if payload.get("architecture") != architecture:
        raise RuntimeError(
            f"results.json architecture ({payload.get('architecture')!r}) differs "
            f"from the runner ({architecture!r})"
        )
    recorded_run_id = payload.get("run_id")
    if run_id and recorded_run_id and recorded_run_id != run_id:
        raise RuntimeError(
            f"results.json run_id ({recorded_run_id!r}) differs from the run "
            f"({run_id!r})"
        )
    toolchain = require_dict(payload.get("toolchain"), "results.json toolchain")
    compiler = toolchain.get("compiler")
    if not isinstance(compiler, str) or not compiler.strip():
        raise RuntimeError("results.json toolchain.compiler is missing")

    results = require_dict(payload.get("results"), "results.json results")
    if len(results) != len(METRIC_KEYS):
        raise RuntimeError(
            f"results.json must contain exactly {len(METRIC_KEYS)} metrics, "
            f"found {len(results)}: {sorted(results)}"
        )
    if set(results) != set(METRIC_KEYS):
        raise RuntimeError(
            f"results.json has unexpected metric names: {sorted(results)}"
        )

    benchmark = require_dict(payload.get("benchmark"), "results.json benchmark")
    validate_benchmark_section(benchmark, measure_reps)

    metrics: dict[str, Any] = {}
    for key in METRIC_KEYS:
        metrics[key] = validate_metric(key, results[key])
    return metrics


# ---------------------------------------------------------------------------
# Report rendering
# ---------------------------------------------------------------------------
def markdown_cell(value: Any) -> str:
    if value is None or value == "":
        return "N/A"
    return str(value).replace("|", "\\|").replace("\r\n", "<br>").replace("\n", "<br>")


SCENARIO_LABELS = {
    "hsbench_rules_block_mean_throughput_mbit_s": (
        "无通用字节码（`hsbench -e pcre/snort_literals`）"
    ),
    "hsbench_ubc_block_mean_throughput_mbit_s": (
        "有通用字节码（`hsbench -U dump/db.raw`）"
    ),
}


def render_report(result: dict[str, Any]) -> str:
    lines = [
        f"# Ultrascan {result['version']} Mean Throughput 独立性能测试报告",
        "",
        f"- Run ID：`{result['run_id']}`",
        f"- 架构：`{result['architecture']}`",
        f"- 状态：`{result['status']}`",
        f"- 清理状态：`{result['cleanup_status']}`",
        "",
        "## 构建信息",
        "",
        "| 项目 | 值 |",
        "|---|---|",
    ]
    build_info = result.get("build_info", {})
    source = build_info.get("source", {}) if isinstance(build_info, dict) else {}
    samples = build_info.get("samples", {}) if isinstance(build_info, dict) else {}
    build = build_info.get("build", {}) if isinstance(build_info, dict) else {}
    bytecode = build_info.get("universal_bytecode", {}) if isinstance(build_info, dict) else {}
    compiler = build_info.get("compiler", {}) if isinstance(build_info, dict) else {}
    release = build.get("release", {}) if isinstance(build, dict) else {}
    dump = build.get("dump", {}) if isinstance(build, dict) else {}
    rules = samples.get("rules", {}) if isinstance(samples, dict) else {}
    corpus = samples.get("corpus", {}) if isinstance(samples, dict) else {}
    for label, value in (
        ("实际软件版本", build_info.get("actual_version")),
        ("源码 Tag", source.get("tag")),
        ("源码 Commit", source.get("commit")),
        ("源码归档 SHA-256", source.get("archive_sha256")),
        ("Intel 样本包 SHA-256", samples.get("zip_sha256")),
        ("规则集", rules.get("path")),
        ("规则集 SHA-256", rules.get("sha256")),
        ("语料", corpus.get("path")),
        ("语料 SHA-256", corpus.get("sha256")),
        ("Release 构建", f"{release.get('build_type')} / target {release.get('target')}"),
        ("Debug 构建", f"{dump.get('build_type')} / target {dump.get('target')} / DUMP_SUPPORT {dump.get('dump_support')}"),
        ("通用字节码 db.raw", bytecode.get("dump_db")),
        ("db.raw SHA-256", bytecode.get("sha256")),
        ("容器编译器", compiler.get("cxx")),
    ):
        lines.append(f"| {label} | {markdown_cell(value)} |")
    lines.extend(["", "## 系统信息", "", "| 项目 | 值 |", "|---|---|"])
    system_info = result.get("system_info", {})
    for label, field in (
        ("操作系统", "platform"),
        ("系统架构", "architecture"),
        ("CPU 型号", "cpu_model"),
        ("CPU 核数", "cpu_count"),
        ("内核", "kernel"),
        ("Python 版本", "python_version"),
        ("glibc 版本", "glibc_version"),
        ("NUMA", "numa"),
    ):
        lines.append(f"| {label} | {markdown_cell(system_info.get(field))} |")
    lines.extend(["", "## 负载参数", "", "| 参数 | 值 |", "|---|---|"])
    benchmark = result.get("benchmark", {})
    samples_package = benchmark.get("samples_package", {})
    for label, value in (
        ("负载", benchmark.get("workload")),
        ("规则集", samples_package.get("rules")),
        ("语料", samples_package.get("corpus")),
        ("每轮扫描次数", benchmark.get("iterations")),
        ("预热次数", benchmark.get("warmups")),
        ("独立测量次数", benchmark.get("measure_reps")),
        ("场景", ", ".join(benchmark.get("scenarios", []) or [])),
    ):
        lines.append(f"| {label} | {markdown_cell(value)} |")
    lines.extend([
        "",
        "## 性能指标",
        "",
        "| 场景 | Mean throughput (Mbit/s) |",
        "|---|---:|",
    ])
    for metric_name, metric in result.get("results", {}).items():
        label = SCENARIO_LABELS.get(metric_name, metric_name)
        lines.append(f"| {label} | {metric['value']} |")
    if result.get("error"):
        lines.extend(["", "## 错误", "", markdown_cell(result["error"])])
    lines.append("")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# finalize
# ---------------------------------------------------------------------------
def finalize(
    output_dir: Path,
    version: str,
    architecture: str,
    run_id: str,
    command_status: str,
    cleanup_status: str,
    failed_stage: str | None,
) -> int:
    payload = load_json(output_dir / RESULTS_FILENAME)
    error = ""
    metrics: dict[str, Any] = {}
    benchmark: dict[str, Any] = {}
    measure_reps = 0
    if command_status == "passed":
        try:
            if not payload:
                raise RuntimeError(f"{RESULTS_FILENAME} is missing or invalid")
            benchmark = require_dict(payload.get("benchmark"), "results.json benchmark")
            reps = benchmark.get("measure_reps")
            if isinstance(reps, int) and not isinstance(reps, bool) and reps >= 1:
                measure_reps = reps
            else:
                raise RuntimeError("results.json benchmark.measure_reps is invalid")
            metrics = validate_run_payload(
                payload, version, architecture, run_id, measure_reps
            )
        except RuntimeError as exc:
            command_status = "failed"
            failed_stage = failed_stage or "test"
            error = str(exc)
            metrics = {}
    status = "passed" if command_status == cleanup_status == "passed" else "failed"
    build_info = load_json(output_dir / "build_info.json")
    result = {
        "software": "ultrascan",
        "category": "Acceleration",
        "version": version,
        "variant": payload.get("variant", "base") if payload else "base",
        "architecture": architecture,
        "run_id": run_id,
        "generated_at": payload.get("generated_at") if payload else timestamp(),
        "toolchain": payload.get("toolchain", {}) if payload else {},
        "benchmark": benchmark if error == "" else payload.get("benchmark", {}),
        "results": metrics,
        "runs_dir": payload.get("runs_dir", "runs") if payload else "runs",
        "status": status,
        "cleanup_status": cleanup_status,
        "failed_stage": failed_stage,
        "build_info": build_info,
        "system_info": load_json(output_dir / "system_info.json"),
        "runtime_before": load_json(output_dir / "runtime_before.json"),
        "runtime_after": load_json(output_dir / "runtime_after.json"),
        "error": error or None,
    }
    # The case contract forbids any historical concept from leaking into the
    # published artefacts; fail closed instead of shipping a mixed report.
    serialized = json.dumps(result, ensure_ascii=False)
    for word in FORBIDDEN_WORDS:
        if word in serialized:
            status = "failed"
            error = "the results contain an unsupported concept"
            result["status"] = status
            result["error"] = error
            # Drop every payload-derived section so the rejected concept cannot
            # be republished inside the artefact.
            result["results"] = {}
            result["benchmark"] = {}
            result["toolchain"] = {}
            result["runs_dir"] = "runs"
            break
    atomic_write_json(output_dir / RESULTS_FILENAME, result)
    atomic_write_json(output_dir / "status.json", {
        "software": "ultrascan",
        "category": "Acceleration",
        "version": version,
        "architecture": architecture,
        "run_id": run_id,
        "status": status,
        "failed_stage": failed_stage,
        "cleanup_status": cleanup_status,
        "error": error or None,
    })
    (output_dir / "report.md").write_text(render_report(result), encoding="utf-8")
    return 70 if error else 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def add_snapshot_parsers(subparsers: Any) -> None:
    for name in ("system", "runtime"):
        parser = subparsers.add_parser(name)
        parser.add_argument("output", type=Path)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect environment/build evidence and validate the Ultrascan results.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    add_snapshot_parsers(subparsers)

    build = subparsers.add_parser("build-info")
    build.add_argument("--output", type=Path)
    build.add_argument("--build-state", type=Path)
    build.add_argument("--architecture")
    build.add_argument("--run-id")
    build.add_argument("--requested-version")
    build.add_argument("--actual-version-file", type=Path)
    # Legacy positional form: output requested_version actual_version_file architecture run_id
    build.add_argument("legacy", nargs="*")

    final = subparsers.add_parser("finalize")
    final.add_argument("output_dir", type=Path)
    final.add_argument("version")
    final.add_argument("architecture")
    final.add_argument("run_id")
    final.add_argument("command_status", choices=("passed", "failed"))
    final.add_argument("cleanup_status", choices=("passed", "failed"))
    final.add_argument("failed_stage", nargs="?", default="")

    # Unknown extras from older call sites are ignored instead of failing.
    args, _unknown = parser.parse_known_args(argv)
    return args


def resolve_build_info_arguments(args: argparse.Namespace) -> dict[str, Any]:
    legacy = list(args.legacy or [])
    output = args.output or (legacy[0] if legacy else None)
    if output is None:
        raise RuntimeError("build-info needs --output (or the legacy output argument)")
    build_state = args.build_state
    if build_state is None:
        work_dir = os.environ.get("PERF_WORK_DIR", "")
        build_state = Path(work_dir) / "build-state.json" if work_dir else None
    if build_state is None:
        raise RuntimeError("build-info needs --build-state or PERF_WORK_DIR")
    requested_version = args.requested_version or (legacy[1] if len(legacy) > 1 else None)
    actual_version_file = args.actual_version_file
    if actual_version_file is None and len(legacy) > 2 and legacy[2]:
        actual_version_file = Path(legacy[2])
    architecture = args.architecture or (legacy[3] if len(legacy) > 3 else None) \
        or os.environ.get("EXPECTED_ARCH") or platform.machine()
    run_id = args.run_id or (legacy[4] if len(legacy) > 4 else None) \
        or os.environ.get("PERF_RUN_ID", "")
    return {
        "output": Path(output),
        "build_state": Path(build_state),
        "architecture": architecture,
        "run_id": run_id,
        "requested_version": requested_version or None,
        "actual_version_file": actual_version_file,
    }


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    if args.command == "system":
        atomic_write_json(args.output, collect_system_info())
        return 0
    if args.command == "runtime":
        atomic_write_json(args.output, collect_runtime_state())
        return 0
    if args.command == "build-info":
        try:
            options = resolve_build_info_arguments(args)
            record_build_info(**options)
        except (RuntimeError, OSError, ValueError) as error:
            print(f"ERROR: {error}", file=sys.stderr)
            return 30
        return 0
    return finalize(
        args.output_dir,
        args.version,
        args.architecture,
        args.run_id,
        args.command_status,
        args.cleanup_status,
        args.failed_stage or None,
    )


if __name__ == "__main__":
    raise SystemExit(main())
