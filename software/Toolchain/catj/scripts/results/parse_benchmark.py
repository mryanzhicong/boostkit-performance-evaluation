#!/usr/bin/env python3
"""Strictly validate the catj samples and publish the result document.

The parser is the only component that declares a measurement successful.  It
re-reads every sample, the generated inputs, the staged runtime and the pinned
output hashes, and refuses to publish anything when one invariant is violated:
a missing or extra sample, a timeout, a runtime or package drift, a modified
input, a different stdout than the pinned byte-identical flattening output, or a
sample outside the fixed protocol.
"""

import hashlib
import json
import math
import os
import statistics
import subprocess
import sys
from pathlib import Path

METRIC_UNIT_SECONDS = "s"
METRIC_UNIT_RSS = "MiB"
METRIC_UNIT_THROUGHPUT = "MiB/s"

SCENARIO_TIMEOUTS = {
    "flatten_file_100000": 180,
    "flatten_stdin_100000": 180,
}
DEFAULT_TIMEOUT = 120


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
    inputs = payload.get("inputs")
    require(isinstance(scenarios, list) and scenarios, f"{path} has no scenarios")
    require(isinstance(inputs, list) and inputs, f"{path} has no inputs")
    seen = set()
    for entry in scenarios:
        require(isinstance(entry, dict), f"{path}: every scenario must be an object")
        scenario_id = entry.get("id")
        require(isinstance(scenario_id, str) and scenario_id, f"{path}: scenario without id")
        require(scenario_id not in seen, f"{path}: duplicated scenario {scenario_id!r}")
        seen.add(scenario_id)
        require(entry.get("mode") in ("file", "stdin"), f"{scenario_id}: invalid input mode")
        require(isinstance(entry.get("iterations"), int) and entry["iterations"] >= 1, f"{scenario_id}: iterations")
        for key in ("expected_last_token", "expected_value_token"):
            require(isinstance(entry.get(key), str) and entry[key], f"{scenario_id}: missing {key}")
        require(
            any(item["name"] == entry.get("input") for item in inputs if isinstance(item, dict)),
            f"{scenario_id}: unknown input",
        )
    input_names = set()
    for entry in inputs:
        require(isinstance(entry, dict), f"{path}: every input must be an object")
        for key in ("name", "sha256", "output_sha256"):
            require(isinstance(entry.get(key), str) and entry[key], f"{path}: input without {key}")
        require(entry["name"] not in input_names, f"{path}: duplicated input {entry['name']!r}")
        input_names.add(entry["name"])
        require(isinstance(entry.get("objects"), int) and entry["objects"] > 0, f"{path}: bad objects")
        require(isinstance(entry.get("bytes"), int) and entry["bytes"] > 0, f"{path}: bad bytes")
        require(isinstance(entry.get("output_lines"), int) and entry["output_lines"] > 0, f"{path}: bad output_lines")
        require(entry.get("output_lines") == entry["objects"] * 9, f"{path}: output_lines is not objects * 9")
    return payload, scenarios


def verify_runtime(runtime_path: Path, scenarios_payload: dict, expected_arch: str) -> dict:
    runtime = read_json(runtime_path)
    require(runtime.get("suite") == scenarios_payload["suite"], "runtime suite drift")
    require(runtime.get("catj", {}).get("version") == os.environ["SOFTWARE_VERSION"], "runtime catj version drift")
    require(runtime.get("scenarios") == [item["id"] for item in scenarios_payload["scenarios"]], "runtime scenario drift")
    require(runtime.get("machine") == expected_arch, "runtime machine does not match the architecture")
    node_reported = subprocess.run(
        [os.environ["CATJ_NODE_BIN"], "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    require(node_reported == os.environ["NODE_VERSION"], "runtime node version drift")
    require(runtime["node"]["version"] == node_reported, "runtime record node version drift")
    dependencies = runtime.get("dependencies", {})
    for name in ("colors", "minimist", "optimist", "wordwrap"):
        require(name in dependencies, f"runtime does not pin dependency {name!r}")
        require(isinstance(dependencies[name].get("version"), str), f"dependency {name!r} has no version")
    files = runtime.get("catj", {}).get("files", {})
    app_dir = Path(os.environ["CATJ_APP_DIR"]) / "node_modules" / "catj"
    for name, digest in files.items():
        candidate = app_dir / name
        require(candidate.is_file(), f"staged catj file is missing: {candidate}")
        require(sha256_file(candidate) == digest, f"staged catj file was modified: {name}")
    inputs = {item["name"]: item for item in runtime.get("inputs", [])}
    for entry in scenarios_payload["inputs"]:
        require(entry["name"] in inputs, f"runtime record does not pin input {entry['name']}")
        target = Path(os.environ["CATJ_INPUT_DIR"]) / entry["name"]
        require(target.is_file(), f"generated input is missing: {target}")
        require(sha256_file(target) == entry["sha256"], f"generated input was modified: {entry['name']}")
        require(target.stat().st_size == entry["bytes"], f"generated input size drift: {entry['name']}")
    return runtime


def verify_output(scenario: dict, entry: dict, output: Path) -> dict:
    scenario_id = scenario["id"]
    require(output.is_file(), f"{scenario_id}: missing stdout capture {output.name}")
    data = output.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    require(digest == entry["output_sha256"], f"{scenario_id}: stdout differs from the pinned flattening output")
    lines = data.count(b"\n")
    require(lines == entry["output_lines"], f"{scenario_id}: {lines} output lines, expected {entry['output_lines']}")
    text = data.decode("utf-8")
    require(scenario["expected_last_token"] in text, f"{scenario_id}: last object token is missing")
    require(scenario["expected_value_token"] in text, f"{scenario_id}: last value token is missing")
    return {"output_sha256": digest, "output_bytes": len(data), "output_lines": lines}


def validate_sample(scenario: dict, entry: dict, sample_json: Path, today_output: Path) -> dict:
    scenario_id = scenario["id"]
    timing = read_json(sample_json)
    require(timing.get("label", "").startswith(f"{scenario_id}#"), f"{scenario_id}: unexpected sample label")
    require(timing.get("exit_code") == 0, f"{scenario_id}: {sample_json.name} exited non-zero")
    require(timing.get("timed_out") is False, f"{scenario_id}: {sample_json.name} timed out")
    require(
        timing.get("timeout_seconds") == scenario_timeout(scenario_id),
        f"{scenario_id}: sample ran with an unexpected timeout",
    )
    wall = timing.get("wall_seconds")
    rss = timing.get("max_rss_mib")
    require(isinstance(wall, (int, float)) and wall > 0, f"{scenario_id}: non-positive wall time")
    require(isinstance(rss, (int, float)) and rss > 0, f"{scenario_id}: non-positive peak RSS")
    require(wall <= scenario_timeout(scenario_id), f"{scenario_id}: process exceeded its timeout")
    detail = verify_output(scenario, entry, today_output)
    throughput = entry["bytes"] / (1024.0 * 1024.0) / wall
    require(throughput > 0, f"{scenario_id}: non-positive throughput")
    return {
        "wall_seconds": float(wall),
        "peak_rss_mib": float(rss),
        "throughput_mib_s": throughput,
        "output": detail,
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
        "CATJ_WARMUPS",
        "CATJ_STATISTIC",
        "CATJ_SCENARIOS_FILE",
        "CATJ_RUNTIME_JSON",
        "CATJ_APP_DIR",
        "CATJ_INPUT_DIR",
        "CATJ_NODE_BIN",
        "CATJ_OFFLINE_MEASUREMENT",
        "CATJ_TARBALL_SHA256",
        "CATJ_DEPS_SHA256",
        "NODE_VERSION",
        "NODE_ARCHIVE_SHA256",
    ]
    missing = [name for name in required_env if not os.environ.get(name)]
    if missing:
        raise ValidationError(f"missing environment variables: {', '.join(missing)}")

    reps = int(os.environ["PERF_REPS"])
    warmups = int(os.environ["CATJ_WARMUPS"])
    require(reps >= 1, "PERF_REPS must be at least 1")
    require(warmups >= 0, "CATJ_WARMUPS must be non-negative")
    expected_arch = os.environ["EXPECTED_ARCH"]
    require(os.environ["CATJ_OFFLINE_MEASUREMENT"] == "true", "offline measurement must be enabled")

    scenarios_payload, scenarios = load_scenarios(Path(os.environ["CATJ_SCENARIOS_FILE"]))
    require(scenarios_payload.get("software") == "catj", "scenario file belongs to another software")
    require(
        scenarios_payload.get("version") == os.environ["SOFTWARE_VERSION"],
        "scenario file version does not match the requested version",
    )
    require(len(scenarios) == 6, f"expected 6 scenarios, found {len(scenarios)}")
    runtime = verify_runtime(Path(os.environ["CATJ_RUNTIME_JSON"]), scenarios_payload, expected_arch)
    inputs = {item["name"]: item for item in scenarios_payload["inputs"]}
    require(len(inputs) == 3, f"expected 3 pinned inputs, found {len(inputs)}")

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
        input_entry = inputs[entry["input"]]
        expected_files = {f"rep{index}.json" for index in range(1, reps + 1)}
        expected_files |= {f"rep{index}.out" for index in range(1, reps + 1)}
        expected_files |= {f"rep{index}.err" for index in range(1, reps + 1)}
        if warmups > 0:
            expected_files |= {"warmup.json", "warmup.out", "warmup.err"}
        actual_files = {path.name for path in scenario_dir.iterdir() if path.is_file()}
        require(
            actual_files == expected_files,
            f"{scenario_id}: unexpected sample files: extra={sorted(actual_files - expected_files)}, "
            f"missing={sorted(expected_files - actual_files)}",
        )
        if warmups > 0:
            render = read_json(scenario_dir / "warmup.json")
            require(render.get("exit_code") == 0, f"{scenario_id}: warm-up exited non-zero")
            require(render.get("timed_out") is False, f"{scenario_id}: warm-up timed out")
            verify_output(entry, input_entry, scenario_dir / "warmup.out")
        samples = [
            validate_sample(entry, input_entry, scenario_dir / f"rep{index}.json", scenario_dir / f"rep{index}.out")
            for index in range(1, reps + 1)
        ]
        walls = [sample["wall_seconds"] for sample in samples]
        rss = [sample["peak_rss_mib"] for sample in samples]
        throughput = [sample["throughput_mib_s"] for sample in samples]
        outputs = {sample["output"]["output_sha256"] for sample in samples}
        require(len(outputs) == 1, f"{scenario_id}: samples produced different stdout")
        scenario_details[scenario_id] = {
            "input": entry["input"],
            "mode": entry["mode"],
            "iterations": entry["iterations"],
            "input_bytes": input_entry["bytes"],
            "input_objects": input_entry["objects"],
            "stdout_sha256": input_entry["output_sha256"],
            "stdout_lines": input_entry["output_lines"],
            "statistics": {
                "wall_seconds": statistics_block(walls),
                "peak_rss_mib": statistics_block(rss),
                "throughput_mib_s": statistics_block(throughput),
            },
        }
        for metric_name, values, unit, direction in (
            ("wall_seconds", walls, METRIC_UNIT_SECONDS, "lower_is_better"),
            ("peak_rss_mib", rss, METRIC_UNIT_RSS, "lower_is_better"),
            ("throughput_mib_s", throughput, METRIC_UNIT_THROUGHPUT, "higher_is_better"),
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
                "subgroup": entry["mode"],
                "subgroup_path": "metric.subgroup",
                "value": block["median"],
                "statistics": block,
            }
            metric_count += 1

    parameters = {
        "software": "catj",
        "variant": os.environ["PERF_VARIANT"],
        "node": {
            "version": os.environ["NODE_VERSION"],
            "archive_sha256": os.environ["NODE_ARCHIVE_SHA256"],
        },
        "package": {
            "name": "catj",
            "version": os.environ["SOFTWARE_VERSION"],
            "tarball_sha256": os.environ["CATJ_TARBALL_SHA256"],
            "dependency_tree_sha256": os.environ["CATJ_DEPS_SHA256"],
            "dependencies": {
                name: record["version"] for name, record in runtime["dependencies"].items()
            },
        },
        "inputs": [
            {"name": item["name"], "objects": item["objects"], "bytes": item["bytes"], "sha256": item["sha256"]}
            for item in scenarios_payload["inputs"]
        ],
        "measurement": {
            "statistic": os.environ["CATJ_STATISTIC"],
            "repetitions": reps,
            "warmups": warmups,
            "processes_per_sample": 1,
            "offline": True,
            "captures_stdout": True,
            "environment": {"FORCE_COLOR": "0", "TZ": "UTC", "LC_ALL": "C"},
        },
        "scenarios": {
            entry["id"]: {
                "input": entry["input"],
                "mode": entry["mode"],
                "iterations": entry["iterations"],
                "timeout_seconds": scenario_timeout(entry["id"]),
            }
            for entry in scenarios
        },
    }

    document = {
        "software": "catj",
        "version": os.environ["SOFTWARE_VERSION"],
        "variant": os.environ["PERF_VARIANT"],
        "architecture": expected_arch,
        "summary": {
            "scenario_count": len(scenarios),
            "samples_per_scenario": reps,
            "warmups_per_scenario": warmups,
            "metric_count": metric_count,
            "statistic": os.environ["CATJ_STATISTIC"],
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
    print(
        f"[catj] parsed {reps} sample(s) for {len(scenarios)} scenarios, published {metric_count} metrics"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"[catj] result validation failed: {exc}", file=sys.stderr)
        raise SystemExit(2)
