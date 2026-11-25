#!/usr/bin/env python3
"""Strictly validate the bcrypt samples and publish the result document.

The parser is the only component that declares a measurement successful.  It
re-reads every sample log, the runtime record and the staged native module, and
refuses to publish anything when one invariant is violated: a missing sample, a
runtime or package drift, a modified native binary, a different scenario
parameter combination, a failed correctness gate or an inconsistent timing.
"""

import hashlib
import json
import math
import os
import statistics
import subprocess
import sys
from pathlib import Path

ENVIRONMENT_PREFIX = "[bcrypt-env] "
EVIDENCE_PREFIX = "[bcrypt-bench] "
METRIC_UNIT_MS = "ms"
METRIC_UNIT_RATE = "op/s"
METRIC_UNIT_RSS = "MiB"

SCENARIO_TIMEOUTS = {"hash_sync_cost12": 300, "compare_async_cost12": 300}
DEFAULT_TIMEOUT = 180


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
    require(isinstance(payload.get("password"), str) and payload["password"], f"{path} has no password")
    seen = set()
    for entry in scenarios:
        require(isinstance(entry, dict), f"{path}: every scenario must be an object")
        scenario_id = entry.get("id")
        require(isinstance(scenario_id, str) and scenario_id, f"{path}: scenario without id")
        require(scenario_id not in seen, f"{path}: duplicated scenario {scenario_id!r}")
        seen.add(scenario_id)
        require(entry.get("op") in ("hash", "compare"), f"{scenario_id}: invalid operation")
        require(entry.get("api") in ("sync", "async"), f"{scenario_id}: invalid API")
        require(isinstance(entry.get("cost"), int) and 4 <= entry["cost"] <= 15, f"{scenario_id}: invalid cost")
        require(isinstance(entry.get("ops"), int) and entry["ops"] >= 1, f"{scenario_id}: invalid op count")
    return payload, scenarios


def verify_runtime(runtime_path: Path, scenarios_payload: dict, expected_arch: str) -> dict:
    runtime = read_json(runtime_path)
    app_dir = Path(os.environ["BCRYPT_APP_DIR"]) / "node_modules" / "bcrypt"
    require(runtime.get("suite") == scenarios_payload["suite"], "runtime suite drift")
    require(runtime.get("machine") == expected_arch, "runtime machine does not match the architecture")
    require(runtime.get("scenarios") == [item["id"] for item in scenarios_payload["scenarios"]], "runtime scenario drift")
    node_reported = subprocess.run(
        [os.environ["BCRYPT_NODE_BIN"], "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    require(node_reported == os.environ["NODE_VERSION"], "runtime node version drift")
    require(runtime["node"]["version"] == node_reported, "runtime record node version drift")
    require(runtime["bcrypt"]["version"] == os.environ["SOFTWARE_VERSION"], "runtime bcrypt version drift")
    require(runtime["bcrypt"]["native"]["sha256"] == os.environ["BCRYPT_NATIVE_SHA256"], "native binary record drift")
    native = app_dir / runtime["bcrypt"]["native"]["binary"]
    require(native.is_file(), f"native binary is missing: {native}")
    require(sha256_file(native) == runtime["bcrypt"]["native"]["sha256"], "native binary was modified")
    for name, digest in runtime["bcrypt"]["files"].items():
        candidate = app_dir / name
        require(candidate.is_file(), f"staged bcrypt file is missing: {candidate}")
        require(sha256_file(candidate) == digest, f"staged bcrypt file was modified: {name}")
    for name in ("node-addon-api", "node-gyp-build"):
        require(name in runtime.get("dependencies", {}), f"runtime does not pin dependency {name}")
        require(isinstance(runtime["dependencies"][name].get("version"), str), f"dependency {name} has no version")
    return runtime


def parse_lines(log_text: str, scenario_id: str) -> tuple[dict, dict]:
    environment_lines = [line for line in log_text.splitlines() if line.startswith(ENVIRONMENT_PREFIX)]
    evidence_lines = [line for line in log_text.splitlines() if line.startswith(EVIDENCE_PREFIX)]
    require(len(environment_lines) == 1, f"{scenario_id}: expected one environment line")
    require(len(evidence_lines) == 1, f"{scenario_id}: expected one evidence line")
    try:
        environment = json.loads(environment_lines[0][len(ENVIRONMENT_PREFIX):])
        evidence = json.loads(evidence_lines[0][len(EVIDENCE_PREFIX):])
    except json.JSONDecodeError as exc:
        raise ValidationError(f"{scenario_id}: malformed evidence line: {exc}") from exc
    require(isinstance(environment, dict) and isinstance(evidence, dict), f"{scenario_id}: evidence is not an object")
    return environment, evidence


def validate_sample(scenario: dict, log_path: Path) -> dict:
    scenario_id = scenario["id"]
    log_text = read_text(log_path)
    require(log_text, f"{scenario_id}: {log_path.name} is empty")
    environment, evidence = parse_lines(log_text, scenario_id)
    expected_node = os.environ["NODE_VERSION"]
    sample_node = environment.get("node")
    require(sample_node in (expected_node, expected_node.lstrip("v")), f"{scenario_id}: node version drift in sample")
    require(environment.get("bcrypt") == os.environ["SOFTWARE_VERSION"], f"{scenario_id}: bcrypt version drift in sample")
    require(evidence.get("scenario") == scenario["id"], f"{scenario_id}: scenario id mismatch in sample")
    for key in ("op", "api", "cost", "ops"):
        require(evidence.get(key) == scenario[key], f"{scenario_id}: {key} mismatch in sample")
    require(evidence.get("mode") == "measure", f"{scenario_id}: sample mode is not measure")
    operations = scenario["ops"]
    per_operation = evidence.get("per_operation_seconds")
    require(isinstance(per_operation, list) and len(per_operation) == operations, f"{scenario_id}: per-operation list")
    require(all(isinstance(value, (int, float)) and value > 0 for value in per_operation), f"{scenario_id}: bad op duration")
    total = evidence.get("total_seconds")
    require(isinstance(total, (int, float)) and total > 0, f"{scenario_id}: non-positive total duration")
    require(math.isclose(total, sum(per_operation), rel_tol=1e-6, abs_tol=1e-3), f"{scenario_id}: per-operation sum mismatch")
    batch = evidence.get("batch_seconds")
    require(isinstance(batch, (int, float)) and batch > 0, f"{scenario_id}: non-positive batch duration")
    require(batch + 1e-3 >= total, f"{scenario_id}: batch duration is shorter than the operation sum")
    ms_per_op = evidence.get("ms_per_op")
    require(isinstance(ms_per_op, (int, float)) and ms_per_op > 0, f"{scenario_id}: non-positive ms/op")
    require(math.isclose(ms_per_op, total * 1000.0 / operations, rel_tol=1e-6), f"{scenario_id}: ms/op mismatch")
    ops_per_second = evidence.get("ops_per_second")
    require(isinstance(ops_per_second, (int, float)) and ops_per_second > 0, f"{scenario_id}: non-positive throughput")
    require(math.isclose(ops_per_second, operations / total, rel_tol=1e-6), f"{scenario_id}: throughput mismatch")
    correctness = evidence.get("correctness")
    require(isinstance(correctness, dict) and correctness.get("ok") is True, f"{scenario_id}: correctness gate failed")
    require(isinstance(correctness.get("detail"), str) and correctness["detail"], f"{scenario_id}: empty correctness detail")
    rss = evidence.get("max_rss_mib")
    require(isinstance(rss, (int, float)) and rss > 0, f"{scenario_id}: non-positive peak RSS")
    return {
        "ms_per_op": float(ms_per_op),
        "ops_per_second": float(ops_per_second),
        "peak_rss_mib": float(rss),
        "per_operation_seconds": per_operation,
        "salt_seconds": float(evidence.get("salt_seconds") or 0.0),
        "correctness": correctness,
    }


def statistics_block(values: list[float]) -> dict:
    require(all(math.isfinite(value) for value in values), "non-finite sample value")
    median = statistics.median(values)
    require(median > 0, "median is not positive")
    return {
        "samples": values,
        "median": median,
        "mean": statistics.fmean(values),
        "min": min(values),
        "max": max(values),
        "stdev": statistics.stdev(values) if len(values) > 1 else 0.0,
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
        "BCRYPT_WARMUPS",
        "BCRYPT_STATISTIC",
        "BCRYPT_SCENARIOS_FILE",
        "BCRYPT_RUNTIME_JSON",
        "BCRYPT_APP_DIR",
        "BCRYPT_NODE_BIN",
        "BCRYPT_OFFLINE_MEASUREMENT",
        "BCRYPT_TARBALL_SHA256",
        "BCRYPT_DEPS_SHA256",
        "BCRYPT_NATIVE_SHA256",
        "NODE_VERSION",
        "NODE_ARCHIVE_SHA256",
    ]
    missing = [name for name in required_env if not os.environ.get(name)]
    if missing:
        raise ValidationError(f"missing environment variables: {', '.join(missing)}")

    reps = int(os.environ["PERF_REPS"])
    warmups = int(os.environ["BCRYPT_WARMUPS"])
    require(reps >= 1, "PERF_REPS must be at least 1")
    require(warmups >= 0, "BCRYPT_WARMUPS must be non-negative")
    expected_arch = os.environ["EXPECTED_ARCH"]
    require(os.environ["BCRYPT_OFFLINE_MEASUREMENT"] == "true", "offline measurement must be enabled")

    scenarios_payload, scenarios = load_scenarios(Path(os.environ["BCRYPT_SCENARIOS_FILE"]))
    require(scenarios_payload.get("software") == "bcrypt", "scenario file belongs to another software")
    require(
        scenarios_payload.get("version") == os.environ["SOFTWARE_VERSION"],
        "scenario file version does not match the requested version",
    )
    require(len(scenarios) == 6, f"expected 6 scenarios, found {len(scenarios)}")
    runtime = verify_runtime(Path(os.environ["BCRYPT_RUNTIME_JSON"]), scenarios_payload, expected_arch)

    expected_ids = [entry["id"] for entry in scenarios]
    actual_dirs = {path.name for path in runs_dir.iterdir() if path.is_dir()}
    require(
        actual_dirs == set(expected_ids),
        f"scenario sample directories differ: extra={sorted(actual_dirs - set(expected_ids))}, "
        f"missing={sorted(set(expected_ids) - actual_dirs)}",
    )

    results = {}
    scenario_details = {}
    metric_count = 0
    for entry in scenarios:
        scenario_id = entry["id"]
        scenario_dir = runs_dir / scenario_id
        expected_files = {f"rep{index}.log" for index in range(1, reps + 1)}
        if warmups > 0:
            expected_files |= {"warmup.log"}
        actual_files = {path.name for path in scenario_dir.iterdir() if path.is_file()}
        require(
            actual_files == expected_files,
            f"{scenario_id}: unexpected sample files: extra={sorted(actual_files - expected_files)}, "
            f"missing={sorted(expected_files - actual_files)}",
        )
        if warmups > 0:
            _, warmup_evidence = parse_lines(read_text(scenario_dir / "warmup.log"), f"{scenario_id}#warmup")
            require(warmup_evidence.get("mode") == "prefetch", f"{scenario_id}: warm-up mode mismatch")
            require(warmup_evidence.get("scenario") == scenario_id, f"{scenario_id}: warm-up scenario mismatch")
        samples = [validate_sample(entry, scenario_dir / f"rep{index}.log") for index in range(1, reps + 1)]
        ms_values = [sample["ms_per_op"] for sample in samples]
        rate_values = [sample["ops_per_second"] for sample in samples]
        rss_values = [sample["peak_rss_mib"] for sample in samples]
        require(
            len({sample["correctness"]["detail"] for sample in samples}) >= 1,
            f"{scenario_id}: samples reported no correctness detail",
        )
        scenario_details[scenario_id] = {
            "op": entry["op"],
            "api": entry["api"],
            "cost": entry["cost"],
            "operations_per_sample": entry["ops"],
            "statistics": {
                "ms_per_op": statistics_block(ms_values),
                "ops_per_second": statistics_block(rate_values),
                "peak_rss_mib": statistics_block(rss_values),
            },
            "correctness": samples[0]["correctness"],
        }
        for metric_name, values, unit, direction in (
            ("ms_per_op", ms_values, METRIC_UNIT_MS, "lower_is_better"),
            ("ops_per_second", rate_values, METRIC_UNIT_RATE, "higher_is_better"),
            ("peak_rss_mib", rss_values, METRIC_UNIT_RSS, "lower_is_better"),
        ):
            key = f"{scenario_id}.{metric_name}"
            block = scenario_details[scenario_id]["statistics"][metric_name]
            results[key] = {
                "source_name": key,
                "metric": metric_name,
                "unit": unit,
                "unit_path": "metric.unit",
                "direction": direction,
                "direction_path": "metric.direction",
                "group": scenario_id,
                "group_path": "metric.group",
                "subgroup": entry["api"],
                "subgroup_path": "metric.subgroup",
                "value": block["median"],
                "statistics": block,
            }
            metric_count += 1

    parameters = {
        "software": "bcrypt",
        "variant": os.environ["PERF_VARIANT"],
        "node": {"version": os.environ["NODE_VERSION"], "archive_sha256": os.environ["NODE_ARCHIVE_SHA256"]},
        "package": {
            "name": "bcrypt",
            "version": os.environ["SOFTWARE_VERSION"],
            "tarball_sha256": os.environ["BCRYPT_TARBALL_SHA256"],
            "dependency_tree_sha256": os.environ["BCRYPT_DEPS_SHA256"],
            "native_binary_sha256": os.environ["BCRYPT_NATIVE_SHA256"],
            "native_binary": runtime["bcrypt"]["native"]["binary"],
            "napi": runtime["bcrypt"]["native"].get("napi"),
            "dependencies": {name: record["version"] for name, record in runtime["dependencies"].items()},
        },
        "workload": {"password": scenarios_payload["password"]},
        "measurement": {
            "statistic": os.environ["BCRYPT_STATISTIC"],
            "repetitions": reps,
            "warmups": warmups,
            "processes_per_sample": 1,
            "operations_per_sample": {entry["id"]: entry["ops"] for entry in scenarios},
            "salt_generated_before_timed_window": True,
            "offline": True,
            "timing": "process.hrtime.bigint() per operation",
            "environment": {"UV_THREADPOOL_SIZE": "1", "TZ": "UTC", "LC_ALL": "C"},
        },
        "scenarios": {
            entry["id"]: {
                "op": entry["op"],
                "api": entry["api"],
                "cost": entry["cost"],
                "ops": entry["ops"],
                "timeout_seconds": scenario_timeout(entry["id"]),
            }
            for entry in scenarios
        },
    }

    document = {
        "software": "bcrypt",
        "version": os.environ["SOFTWARE_VERSION"],
        "variant": os.environ["PERF_VARIANT"],
        "architecture": expected_arch,
        "summary": {
            "scenario_count": len(scenarios),
            "samples_per_scenario": reps,
            "warmups_per_scenario": warmups,
            "metric_count": metric_count,
            "statistic": os.environ["BCRYPT_STATISTIC"],
        },
        "parameters": parameters,
        "runtime": runtime,
        "scenarios": scenario_details,
        "results": results,
    }
    require(metric_count == 3 * len(scenarios), "metric count does not match the scenario count")
    require(len(results) == metric_count, "duplicated metric names")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(document, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"[bcrypt] parsed {reps} sample(s) for {len(scenarios)} scenarios, published {metric_count} metrics")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"[bcrypt] result validation failed: {exc}", file=sys.stderr)
        raise SystemExit(2)
