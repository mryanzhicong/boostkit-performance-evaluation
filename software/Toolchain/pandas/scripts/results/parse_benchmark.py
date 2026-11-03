#!/usr/bin/env python3
"""Strictly validate the pandas sample runs and publish the result document.

The parser is the only component that declares a measurement successful.  It
re-reads every raw sample, the pinned runtime, the vendored asv snapshot and the
scenario definition, and refuses to publish anything when a single invariant is
violated: a missing sample, a timeout, a runtime-version drift, a modified
benchmark file, a wrong parameter combination, a failed correctness gate or a
sample whose duration is outside the configured budget.
"""

import hashlib
import json
import math
import os
import statistics
import sys
from pathlib import Path

EVIDENCE_PREFIX = "[pandas-bench] "
ENVIRONMENT_PREFIX = "[pandas-env] "
METRIC_UNIT_SECONDS = "s"
METRIC_UNIT_RSS = "MiB"
WARMUP_LOG = "warmup.log"
WARMUP_JSON = "warmup.json"

SCENARIO_TIMEOUTS = {
    "groupby_sort_high_cardinality": 300,
    "groupby_int64_overflow": 300,
    "merge_asof_int": 300,
}
DEFAULT_TIMEOUT = 240


class ValidationError(RuntimeError):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except FileNotFoundError as exc:
        raise ValidationError(f"missing file: {path}") from exc


def read_json(path: Path) -> dict:
    try:
        return json.loads(read_text(path))
    except json.JSONDecodeError as exc:
        raise ValidationError(f"invalid JSON in {path}: {exc}") from exc


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def scenario_timeout(scenario: str) -> int:
    return SCENARIO_TIMEOUTS.get(scenario, DEFAULT_TIMEOUT)


def load_scenarios(path: Path) -> tuple[dict, list[dict]]:
    payload = read_json(path)
    scenarios = payload.get("scenarios")
    require(isinstance(scenarios, list) and scenarios, f"{path} has no scenarios")
    seen = set()
    for entry in scenarios:
        require(isinstance(entry, dict), f"{path}: every scenario must be an object")
        scenario_id = entry.get("id")
        require(isinstance(scenario_id, str) and scenario_id, f"{path}: scenario without id")
        require(scenario_id not in seen, f"{path}: duplicated scenario {scenario_id!r}")
        seen.add(scenario_id)
        for key in ("module", "class", "method"):
            require(isinstance(entry.get(key), str) and entry[key], f"{scenario_id}: missing {key}")
        require(isinstance(entry.get("params"), list), f"{scenario_id}: params must be a list")
        require(
            isinstance(entry.get("iterations"), int) and entry["iterations"] >= 1,
            f"{scenario_id}: iterations must be a positive integer",
        )
        verification = entry.get("verification")
        require(isinstance(verification, dict), f"{scenario_id}: missing verification block")
        require(
            isinstance(verification.get("kind"), str) and verification["kind"],
            f"{scenario_id}: missing verification kind",
        )
    return payload, scenarios


def verify_asv_snapshot(asv_dir: Path, modules: list[str]) -> dict:
    manifest_path = asv_dir / "manifest.sha256"
    require(manifest_path.is_file(), f"missing vendored manifest: {manifest_path}")
    manifest_digest = sha256_file(manifest_path)
    entries = {}
    for line in read_text(manifest_path).splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        require(len(parts) == 2, f"{manifest_path}: malformed line {line!r}")
        digest, name = parts
        entries[name] = digest
    require(entries, f"{manifest_path}: empty manifest")
    for name, digest in entries.items():
        candidate = asv_dir / name
        require(candidate.is_file(), f"vendored benchmark file is missing: {name}")
        actual = sha256_file(candidate)
        require(actual == digest, f"vendored benchmark file was modified: {name}")
    for module in modules:
        relative = module.replace(".", "/") + ".py"
        require(relative in entries, f"vendored snapshot does not contain {relative}")
    return {
        "vendored_manifest_sha256": manifest_digest,
        "vendored_file_count": len(entries),
        "benchmark_modules": sorted(modules),
    }


def verify_runtime(runtime_path: Path, expected_arch: str) -> dict:
    runtime = read_json(runtime_path)
    require(runtime.get("python_implementation") == "CPython", "runtime is not CPython")
    require(runtime.get("python") == os.environ["PYTHON_VERSION"], "runtime python version drift")
    reported_runtime = runtime.get("runtime")
    require(isinstance(reported_runtime, dict) and reported_runtime, "runtime map is empty")
    for name in ("numpy", "pandas", "python-dateutil", "six"):
        require(name in reported_runtime, f"runtime does not pin {name!r}")
        require(
            isinstance(reported_runtime[name], str) and reported_runtime[name],
            f"runtime version of {name!r} must be a string",
        )
    require(reported_runtime["pandas"] == os.environ["SOFTWARE_VERSION"], "runtime pandas version drift")
    require(runtime.get("machine") == expected_arch, "runtime machine does not match the architecture")
    return runtime


def parse_environment_line(log_text: str, scenario: str) -> dict:
    lines = [line for line in log_text.splitlines() if line.startswith(ENVIRONMENT_PREFIX)]
    require(len(lines) == 1, f"{scenario}: expected exactly one environment line, found {len(lines)}")
    try:
        environment = json.loads(lines[0][len(ENVIRONMENT_PREFIX) :])
    except json.JSONDecodeError as exc:
        raise ValidationError(f"{scenario}: malformed environment line: {exc}") from exc
    require(isinstance(environment, dict), f"{scenario}: environment line is not an object")
    return environment


def parse_evidence_line(log_text: str, scenario: str) -> dict:
    lines = [line for line in log_text.splitlines() if line.startswith(EVIDENCE_PREFIX)]
    require(len(lines) == 1, f"{scenario}: expected exactly one evidence line, found {len(lines)}")
    try:
        evidence = json.loads(lines[0][len(EVIDENCE_PREFIX) :])
    except json.JSONDecodeError as exc:
        raise ValidationError(f"{scenario}: malformed evidence line: {exc}") from exc
    require(isinstance(evidence, dict), f"{scenario}: evidence line is not an object")
    return evidence


def check_evidence(evidence: dict, scenario: dict) -> None:
    scenario_id = scenario["id"]
    require(evidence.get("scenario") == scenario_id, f"{scenario_id}: evidence scenario mismatch")
    require(evidence.get("mode") == "measure", f"{scenario_id}: evidence mode is not measure")
    require(evidence.get("module") == scenario["module"], f"{scenario_id}: module mismatch")
    require(evidence.get("class") == scenario["class"], f"{scenario_id}: benchmark class mismatch")
    require(evidence.get("method") == scenario["method"], f"{scenario_id}: method mismatch")
    require(evidence.get("params") == scenario["params"], f"{scenario_id}: parameter mismatch")
    require(
        evidence.get("iterations") == scenario["iterations"],
        f"{scenario_id}: sample ran a different iteration count",
    )
    require(evidence.get("n_jobs") == 1, f"{scenario_id}: sample did not run single threaded")
    wall = evidence.get("wall_seconds")
    batch = evidence.get("batch_seconds")
    require(isinstance(wall, (int, float)) and wall > 0, f"{scenario_id}: non-positive wall time")
    require(isinstance(batch, (int, float)) and batch > 0, f"{scenario_id}: non-positive batch time")
    require(
        math.isclose(batch, evidence["iterations"] * wall, rel_tol=1e-6, abs_tol=1e-3),
        f"{scenario_id}: batch and per-call wall times disagree",
    )
    require(0.2 <= batch <= 60.0, f"{scenario_id}: batch duration {batch} out of the sanity window")
    require(
        isinstance(evidence.get("data_shape"), list) and evidence["data_shape"],
        f"{scenario_id}: sample did not report the produced data shape",
    )
    correctness = evidence.get("correctness")
    require(isinstance(correctness, dict), f"{scenario_id}: missing correctness block")
    require(correctness.get("ok") is True, f"{scenario_id}: correctness gate failed")
    require(
        correctness.get("kind") == scenario["verification"]["kind"],
        f"{scenario_id}: correctness kind mismatch",
    )
    require(
        isinstance(correctness.get("detail"), str) and correctness["detail"],
        f"{scenario_id}: correctness detail is empty",
    )
    require(evidence.get("max_rss_mib", 0) > 0, f"{scenario_id}: sample did not report peak RSS")


def validate_sample(scenario: dict, sample_path: Path, log_path: Path, runtime: dict) -> dict:
    scenario_id = scenario["id"]
    timing = read_json(sample_path)
    require(timing.get("exit_code") == 0, f"{scenario_id}: {sample_path.name} exited non-zero")
    require(timing.get("timed_out") is False, f"{scenario_id}: {sample_path.name} timed out")
    require(
        timing.get("timeout_seconds") == scenario_timeout(scenario_id),
        f"{scenario_id}: sample ran with an unexpected timeout",
    )
    wall = timing.get("wall_seconds")
    rss = timing.get("max_rss_mib")
    require(isinstance(wall, (int, float)) and wall > 0, f"{scenario_id}: bad process wall time")
    require(isinstance(rss, (int, float)) and rss > 0, f"{scenario_id}: bad peak RSS")
    require(wall <= scenario_timeout(scenario_id), f"{scenario_id}: process exceeded its timeout")

    log_text = read_text(log_path)
    require(len(log_text) > 0, f"{scenario_id}: {log_path.name} is empty")
    environment = parse_environment_line(log_text, scenario_id)
    expected_environment = {
        "python": os.environ["PYTHON_VERSION"],
        "pandas": os.environ["SOFTWARE_VERSION"],
        "numpy": runtime["runtime"]["numpy"],
        "python-dateutil": runtime["runtime"]["python-dateutil"],
    }
    for name, value in expected_environment.items():
        require(
            environment.get(name) == value,
            f"{scenario_id}: sample reports {name}={environment.get(name)!r}, expected {value!r}",
        )
    evidence = parse_evidence_line(log_text, scenario_id)
    check_evidence(evidence, scenario)
    return {
        "wall_seconds": float(evidence["wall_seconds"]),
        "batch_seconds": float(evidence["batch_seconds"]),
        "process_wall_seconds": float(wall),
        "peak_rss_mib": float(rss),
        "iterations": int(evidence["iterations"]),
        "data_shape": [int(part) for part in evidence["data_shape"]],
        "correctness": evidence["correctness"],
        "warnings": list(evidence.get("warnings") or []),
    }


def validate_warmup(scenario: dict, log_path: Path, json_path: Path) -> None:
    scenario_id = scenario["id"]
    require(log_path.is_file(), f"{scenario_id}: missing {WARMUP_LOG}")
    require(json_path.is_file(), f"{scenario_id}: missing {WARMUP_JSON}")
    timing = read_json(json_path)
    require(timing.get("exit_code") == 0, f"{scenario_id}: warm-up exited non-zero")
    require(timing.get("timed_out") is False, f"{scenario_id}: warm-up timed out")
    log_text = read_text(log_path)
    environment = parse_environment_line(log_text, f"{scenario_id}#warmup")
    require(
        environment.get("pandas") == os.environ["SOFTWARE_VERSION"],
        f"{scenario_id}: warm-up version drift",
    )
    evidence = parse_evidence_line(log_text, f"{scenario_id}#warmup")
    require(evidence.get("mode") == "measure", f"{scenario_id}: warm-up evidence mode mismatch")
    require(evidence.get("scenario") == scenario_id, f"{scenario_id}: warm-up scenario mismatch")


def describe(samples: list[dict], scenario: dict) -> dict:
    walls = [sample["wall_seconds"] for sample in samples]
    rss = [sample["peak_rss_mib"] for sample in samples]
    require(all(math.isfinite(value) for value in walls), f"{scenario['id']}: non-finite wall time")
    median = statistics.median(walls)
    require(median > 0, f"{scenario['id']}: median wall time is not positive")
    shapes = {tuple(sample["data_shape"]) for sample in samples}
    require(len(shapes) == 1, f"{scenario['id']}: samples produced different data shapes")
    return {
        "wall_seconds": {
            "samples": walls,
            "median": median,
            "mean": statistics.fmean(walls),
            "min": min(walls),
            "max": max(walls),
            "stdev": statistics.stdev(walls) if len(walls) > 1 else 0.0,
        },
        "peak_rss_mib": {
            "samples": rss,
            "median": statistics.median(rss),
            "mean": statistics.fmean(rss),
            "min": min(rss),
            "max": max(rss),
            "stdev": statistics.stdev(rss) if len(rss) > 1 else 0.0,
        },
        "data_shape": list(shapes.pop()),
        "iterations": scenario["iterations"],
        "correctness": samples[0]["correctness"],
        "warnings": sorted({item for sample in samples for item in sample["warnings"]}),
    }


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: parse_benchmark.py <runs-dir> <output.json>", file=sys.stderr)
        return 2
    runs_dir = Path(sys.argv[1]).resolve()
    output_path = Path(sys.argv[2]).resolve()

    required_env = [
        "SOFTWARE_VERSION",
        "EXPECTED_ARCH",
        "PERF_VARIANT",
        "PERF_REPS",
        "PANDAS_WARMUPS",
        "PANDAS_STATISTIC",
        "PANDAS_SCENARIOS_FILE",
        "PANDAS_ASV_DIR",
        "PANDAS_RUNTIME_VERSIONS",
        "PANDAS_ASV_TAG",
        "PANDAS_ASV_COMMIT",
        "PANDAS_ASV_REPOSITORY",
        "PANDAS_ASV_SUITE",
        "PANDAS_ASV_PROFILE",
        "PANDAS_OFFLINE_MEASUREMENT",
        "PANDAS_SDIST_SHA256",
        "PYTHON_VERSION",
        "PYTHON_SHA256",
    ]
    missing = [name for name in required_env if not os.environ.get(name)]
    if missing:
        raise ValidationError(f"missing environment variables: {', '.join(missing)}")

    reps = int(os.environ["PERF_REPS"])
    warmups = int(os.environ["PANDAS_WARMUPS"])
    require(reps >= 1, "PERF_REPS must be at least 1")
    require(warmups >= 0, "PANDAS_WARMUPS must be non-negative")
    expected_arch = os.environ["EXPECTED_ARCH"]
    require(os.environ["PANDAS_OFFLINE_MEASUREMENT"] == "true", "offline measurement must be enabled")

    scenarios_payload, scenarios = load_scenarios(Path(os.environ["PANDAS_SCENARIOS_FILE"]))
    require(scenarios_payload.get("software") == "pandas", "scenario file belongs to another software")
    require(
        scenarios_payload.get("version") == os.environ["SOFTWARE_VERSION"],
        "scenario file version does not match the requested version",
    )
    require(len(scenarios) == 9, f"expected 9 scenarios, found {len(scenarios)}")
    modules = sorted({entry["module"] for entry in scenarios})

    runtime = verify_runtime(Path(os.environ["PANDAS_RUNTIME_VERSIONS"]), expected_arch)
    asv_snapshot = verify_asv_snapshot(Path(os.environ["PANDAS_ASV_DIR"]), modules)

    expected_scenario_ids = [entry["id"] for entry in scenarios]
    actual_dirs = {path.name for path in runs_dir.iterdir() if path.is_dir()}
    require(
        actual_dirs == set(expected_scenario_ids),
        f"scenario sample directories differ: extra={sorted(actual_dirs - set(expected_scenario_ids))}, "
        f"missing={sorted(set(expected_scenario_ids) - actual_dirs)}",
    )

    results = {}
    scenario_details = {}
    metric_count = 0
    for entry in scenarios:
        scenario_id = entry["id"]
        scenario_dir = runs_dir / scenario_id
        expected_files = {f"rep{index}.log" for index in range(1, reps + 1)}
        expected_files |= {f"rep{index}.json" for index in range(1, reps + 1)}
        if warmups > 0:
            expected_files |= {WARMUP_LOG, WARMUP_JSON}
        actual_files = {path.name for path in scenario_dir.iterdir() if path.is_file()}
        require(
            actual_files == expected_files,
            f"{scenario_id}: unexpected sample files: extra={sorted(actual_files - expected_files)}, "
            f"missing={sorted(expected_files - actual_files)}",
        )
        if warmups > 0:
            validate_warmup(entry, scenario_dir / WARMUP_LOG, scenario_dir / WARMUP_JSON)
        samples = [
            validate_sample(
                entry,
                scenario_dir / f"rep{index}.json",
                scenario_dir / f"rep{index}.log",
                runtime,
            )
            for index in range(1, reps + 1)
        ]
        detail = describe(samples, entry)
        scenario_details[scenario_id] = {
            "subsystem": entry.get("subsystem", ""),
            "module": entry["module"],
            "class": entry["class"],
            "params": entry["params"],
            "method": entry["method"],
            "iterations": detail["iterations"],
            "data_shape": detail["data_shape"],
            "statistics": {
                "wall_seconds": detail["wall_seconds"],
                "peak_rss_mib": detail["peak_rss_mib"],
            },
            "correctness": detail["correctness"],
            "warnings": detail["warnings"],
        }
        for metric_name, statistics_block, unit in (
            ("wall_seconds", detail["wall_seconds"], METRIC_UNIT_SECONDS),
            ("peak_rss_mib", detail["peak_rss_mib"], METRIC_UNIT_RSS),
        ):
            key = f"{scenario_id}.{metric_name}"
            results[key] = {
                "source_name": key,
                "metric": metric_name,
                "unit": unit,
                "unit_path": "runtime.unit",
                "direction": "lower_is_better",
                "direction_path": "runtime.direction",
                "group": scenario_id,
                "group_path": "runtime.group",
                "subgroup": entry.get("subsystem", ""),
                "subgroup_path": "runtime.subgroup",
                "value": statistics_block["median"],
                "statistics": statistics_block,
            }
            metric_count += 1

    parameters = {
        "software": "pandas",
        "variant": os.environ["PERF_VARIANT"],
        "python": {
            "implementation": runtime["python_implementation"],
            "version": runtime["python"],
            "source_version": os.environ["PYTHON_VERSION"],
            "source_sha256": os.environ["PYTHON_SHA256"],
        },
        "runtime": dict(runtime["runtime"]),
        "source_distribution_sha256": os.environ["PANDAS_SDIST_SHA256"],
        "asv": {
            "repository": os.environ["PANDAS_ASV_REPOSITORY"],
            "tag": os.environ["PANDAS_ASV_TAG"],
            "tag_commit": os.environ["PANDAS_ASV_COMMIT"],
            "suite": os.environ["PANDAS_ASV_SUITE"],
            "profile": os.environ["PANDAS_ASV_PROFILE"],
            "vendored_manifest_sha256": asv_snapshot["vendored_manifest_sha256"],
            "n_jobs": 1,
        },
        "measurement": {
            "statistic": os.environ["PANDAS_STATISTIC"],
            "repetitions": reps,
            "warmups": warmups,
            "processes_per_sample": 1,
            "offline": True,
            "seed": int(scenarios_payload.get("seed", 1234)),
            "environment": {"LC_ALL": "C", "PYTHONHASHSEED": "0", "TZ": "UTC"},
            "threads": {
                "OMP_NUM_THREADS": "1",
                "OPENBLAS_NUM_THREADS": "1",
                "MKL_NUM_THREADS": "1",
                "NUMEXPR_NUM_THREADS": "1",
            },
        },
        "scenarios": {
            entry["id"]: {
                "module": entry["module"],
                "class": entry["class"],
                "params": entry["params"],
                "method": entry["method"],
                "iterations": entry["iterations"],
            }
            for entry in scenarios
        },
    }

    document = {
        "software": "pandas",
        "version": os.environ["SOFTWARE_VERSION"],
        "variant": os.environ["PERF_VARIANT"],
        "architecture": expected_arch,
        "summary": {
            "scenario_count": len(scenarios),
            "samples_per_scenario": reps,
            "warmups_per_scenario": warmups,
            "metric_count": metric_count,
            "statistic": os.environ["PANDAS_STATISTIC"],
        },
        "parameters": parameters,
        "runtime": dict(runtime["runtime"]),
        "asv_snapshot": asv_snapshot,
        "scenarios": scenario_details,
        "results": results,
    }
    require(metric_count == 2 * len(scenarios), "metric count does not match the scenario count")
    require(len(results) == metric_count, "duplicated metric names")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(document, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(
        f"[pandas] parsed {reps} sample(s) for {len(scenarios)} scenarios, "
        f"published {metric_count} metrics"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"[pandas] result validation failed: {exc}", file=sys.stderr)
        raise SystemExit(2)
