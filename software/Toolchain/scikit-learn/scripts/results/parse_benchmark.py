#!/usr/bin/env python3
"""Strictly validate the raw scikit-learn benchmark samples and normalize metrics.

The test stage leaves every repetition untouched under
``runs/<scenario>/{warmup.log,rep<i>.log,rep<i>.json}``.  This parser refuses to
publish anything unless

* every scenario of ``fixtures/scenarios.json`` has exactly the configured
  number of successful samples,
* each ``rep<i>.json`` reports a clean exit and a positive wall clock/peak RSS,
* each log contains the pinned runtime banner and exactly one evidence line,
* the evidence matches the upstream benchmark definition (class, parameters,
  method) and the expected train-split data shape,
* the correctness score is finite and inside the scenario threshold,
* the vendored upstream asv snapshot still matches its SHA-256 manifest.

Any violation aborts the test stage instead of silently publishing partial
results: a missing sample is a failed measurement, not "fewer metrics".
"""

from __future__ import annotations

import hashlib
import json
import math
import os
import statistics
import sys
from pathlib import Path

BANNER_PREFIX = "[sklearn-env]"
EVIDENCE_PREFIX = "[sklearn-bench] "
FAILURE_MARKERS = (
    "Traceback (most recent call last)",
    "MemoryError",
    "Killed",
    "Segmentation fault",
    "core dumped",
    "No space left on device",
    "ERROR: scenario",
)


class ValidationError(ValueError):
    """Raised when a raw sample does not satisfy the benchmark contract."""


def log(message: str) -> None:
    print(f"[sklearn-parse] {message}", flush=True)


def require_env(name: str) -> str:
    value = os.environ.get(name, "")
    if not value:
        raise ValidationError(f"environment variable {name} is required")
    return value


def load_json(path: Path) -> dict:
    try:
        with path.open(encoding="utf-8") as handle:
            value = json.load(handle)
    except FileNotFoundError as exc:
        raise ValidationError(f"missing file: {path}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(f"invalid JSON in {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise ValidationError(f"JSON root of {path} must be an object")
    return value


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def verify_asv_snapshot(asv_dir: Path) -> str:
    manifest_path = asv_dir / "manifest.sha256"
    if not manifest_path.is_file():
        raise ValidationError(f"missing asv snapshot manifest: {manifest_path}")
    entries: dict[str, str] = {}
    for line in manifest_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) != 2:
            raise ValidationError(f"malformed manifest line: {line}")
        digest, relative = parts
        entries[relative] = digest
    if not entries:
        raise ValidationError("asv snapshot manifest is empty")

    for relative, expected in sorted(entries.items()):
        path = asv_dir / relative
        if not path.is_file():
            raise ValidationError(f"asv snapshot file is missing: {relative}")
        actual = sha256_file(path)
        if actual != expected:
            raise ValidationError(
                f"asv snapshot file changed: {relative} (got {actual}, expected {expected})"
            )

    expected_bench_files = {
        relative
        for relative in entries
        if relative.startswith("benchmarks/") and relative.endswith(".py")
    }
    # Only the benchmark package itself is part of the snapshot: the joblib
    # dataset cache below benchmarks/cache also stores ``func_code.py`` helper
    # files, which are measurement state and not vendored sources.
    actual_bench_files = {
        str(path.relative_to(asv_dir))
        for path in (asv_dir / "benchmarks").glob("*.py")
    }
    missing = expected_bench_files - actual_bench_files
    extra = actual_bench_files - expected_bench_files
    if missing or extra:
        raise ValidationError(
            f"asv benchmark package does not match the manifest (missing={sorted(missing)}, extra={sorted(extra)})"
        )
    return sha256_file(manifest_path)


def parse_banner(line: str) -> dict:
    fields = {}
    for token in line[len(BANNER_PREFIX) :].strip().split():
        if "=" not in token:
            continue
        key, value = token.split("=", 1)
        fields[key] = value
    return fields


def parse_evidence(line: str) -> dict:
    try:
        payload = json.loads(line[len(EVIDENCE_PREFIX) :])
    except json.JSONDecodeError as exc:
        raise ValidationError(f"malformed evidence line: {exc}") from exc
    if not isinstance(payload, dict):
        raise ValidationError("evidence line must be a JSON object")
    return payload


def validate_log(log_path: Path, scenario: dict, runtime: dict, timeout_seconds: float) -> dict:
    if not log_path.is_file() or log_path.stat().st_size == 0:
        raise ValidationError(f"missing measurement log: {log_path}")
    text = log_path.read_text(encoding="utf-8", errors="replace")
    for marker in FAILURE_MARKERS:
        if marker in text:
            raise ValidationError(f"failure marker {marker!r} in {log_path}")

    banners = [line for line in text.splitlines() if line.startswith(BANNER_PREFIX)]
    if len(banners) != 1:
        raise ValidationError(
            f"expected exactly one runtime banner in {log_path}, found {len(banners)}"
        )
    banner = parse_banner(banners[0])
    # The banner abbreviates the distribution name: scikit-learn -> sklearn.
    expected_banner = {
        "python": runtime["python"],
        "sklearn": runtime["runtime"]["scikit-learn"],
        "numpy": runtime["runtime"]["numpy"],
        "scipy": runtime["runtime"]["scipy"],
        "joblib": runtime["runtime"]["joblib"],
        "narwhals": runtime["runtime"]["narwhals"],
        "threadpoolctl": runtime["runtime"]["threadpoolctl"],
    }
    for key, expected in expected_banner.items():
        if banner.get(key) != expected:
            raise ValidationError(
                f"{log_path} reports {key}={banner.get(key)}, expected {expected}"
            )

    evidence_lines = [line for line in text.splitlines() if line.startswith(EVIDENCE_PREFIX)]
    if len(evidence_lines) != 1:
        raise ValidationError(
            f"expected exactly one evidence line in {log_path}, found {len(evidence_lines)}"
        )
    evidence = parse_evidence(evidence_lines[0])
    if evidence.get("scenario") != scenario["name"]:
        raise ValidationError(f"evidence scenario mismatch in {log_path}")
    if evidence.get("mode") != "measure":
        raise ValidationError(f"evidence mode is not 'measure' in {log_path}")
    if evidence.get("benchmark_class") != scenario["class"]:
        raise ValidationError(f"evidence benchmark class mismatch in {log_path}")
    if evidence.get("method") != scenario["method"]:
        raise ValidationError(f"evidence method mismatch in {log_path}")
    if evidence.get("metric") != scenario["metric"]:
        raise ValidationError(f"evidence metric mismatch in {log_path}")
    if list(evidence.get("params", [])) != list(scenario["params"]):
        raise ValidationError(f"evidence parameters mismatch in {log_path}")

    expected = scenario["expected"]
    data_shape = evidence.get("data_shape")
    if not isinstance(data_shape, list) or len(data_shape) != 2:
        raise ValidationError(f"evidence data shape is invalid in {log_path}: {data_shape}")
    if data_shape != [expected["n_samples"], expected["n_features"]]:
        raise ValidationError(
            f"data shape {data_shape} does not match {[expected['n_samples'], expected['n_features']]} in {log_path}"
        )

    wall = evidence.get("wall_seconds")
    if not isinstance(wall, (int, float)) or isinstance(wall, bool):
        raise ValidationError(f"evidence wall clock is not numeric in {log_path}")
    if not math.isfinite(float(wall)) or float(wall) <= 0:
        raise ValidationError(f"evidence wall clock is not positive in {log_path}: {wall}")
    if float(wall) > timeout_seconds:
        raise ValidationError(
            f"evidence wall clock {wall} exceeds the scenario timeout {timeout_seconds} in {log_path}"
        )

    score = evidence.get("score")
    if not isinstance(score, (int, float)) or isinstance(score, bool):
        raise ValidationError(f"evidence score is not numeric in {log_path}")
    score = float(score)
    if not math.isfinite(score):
        raise ValidationError(f"evidence score is not finite in {log_path}")
    if evidence.get("score_kind") != expected.get("score_kind"):
        raise ValidationError(f"evidence score kind mismatch in {log_path}")
    if "min_score" in expected and score < expected["min_score"]:
        raise ValidationError(
            f"correctness score {score} is below the {expected['score_kind']} threshold {expected['min_score']} in {log_path}"
        )
    if "max_score" in expected and score > expected["max_score"]:
        raise ValidationError(
            f"correctness score {score} is above the {expected['score_kind']} threshold {expected['max_score']} in {log_path}"
        )

    return {
        "scenario": scenario["name"],
        "wall_seconds": float(wall),
        "max_rss_mib": float(evidence.get("max_rss_mib") or 0.0),
        "data_shape": data_shape,
        "score": score,
        "score_kind": expected.get("score_kind"),
        "warnings": evidence.get("warnings", []),
        "benchmark_class": scenario["class"],
        "method": scenario["method"],
        "params": list(scenario["params"]),
    }


def validate_sample(log_path: Path, json_path: Path, scenario: dict, runtime: dict) -> dict:
    record = load_json(json_path)
    if record.get("exit_code") != 0:
        raise ValidationError(f"{json_path} reports exit code {record.get('exit_code')}")
    if record.get("timed_out"):
        raise ValidationError(f"{json_path} reports a timeout")
    wall = record.get("wall_seconds")
    rss = record.get("max_rss_mib")
    for field, value in (("wall_seconds", wall), ("max_rss_mib", rss)):
        if not isinstance(value, (int, float)) or isinstance(value, bool):
            raise ValidationError(f"{json_path} has no numeric {field}")
        if not math.isfinite(float(value)) or float(value) <= 0:
            raise ValidationError(f"{json_path} has a non-positive {field}: {value}")
    timeout_seconds = float(record.get("timeout_seconds") or 0.0)
    if timeout_seconds <= 0:
        raise ValidationError(f"{json_path} has no positive timeout budget")
    evidence = validate_log(log_path, scenario, runtime, timeout_seconds)
    process_wall = float(wall)
    if evidence["wall_seconds"] > process_wall + 1.0:
        raise ValidationError(
            f"{log_path} reports a measured window ({evidence['wall_seconds']:.3f}s) longer than the process wall clock ({process_wall:.3f}s)"
        )
    if evidence["max_rss_mib"] > 0 and abs(evidence["max_rss_mib"] - float(rss)) > max(1.0, 0.05 * float(rss)):
        log(
            f"WARNING: {log_path.name}: in-process peak RSS {evidence['max_rss_mib']:.1f} MiB "
            f"differs from process peak RSS {float(rss):.1f} MiB"
        )
    return {
        "wall_seconds": evidence["wall_seconds"],
        "process_wall_seconds": process_wall,
        "max_rss_mib": float(rss),
        "evidence": evidence,
    }


def build_statistics(samples: list[float]) -> dict:
    if not samples:
        raise ValidationError("a metric has no samples")
    if len(samples) == 1:
        stdev = 0.0
    else:
        stdev = statistics.stdev(samples)
    return {
        "count": len(samples),
        "samples": samples,
        "median": statistics.median(samples),
        "mean": statistics.fmean(samples),
        "min": min(samples),
        "max": max(samples),
        "stdev": stdev,
        "statistic": "median",
    }


def main() -> int:
    if len(sys.argv) != 3:
        log("usage: parse_benchmark.py <runs-dir> <output-json>")
        return 10
    runs_dir = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    try:
        version = require_env("SOFTWARE_VERSION")
        variant = require_env("PERF_VARIANT")
        architecture = require_env("EXPECTED_ARCH")
        reps = int(require_env("PERF_REPS"))
        warmups = int(require_env("SKLEARN_WARMUPS"))
        statistic = require_env("SKLEARN_STATISTIC")
        scenarios_file = Path(require_env("SKLEARN_SCENARIOS_FILE"))
        asv_dir = Path(require_env("SKLEARN_ASV_DIR"))
        runtime_path = Path(require_env("SKLEARN_RUNTIME_VERSIONS"))
        asv_tag = require_env("SKLEARN_ASV_TAG")
        asv_commit = require_env("SKLEARN_ASV_COMMIT")
        asv_repository = require_env("SKLEARN_ASV_REPOSITORY")
        asv_suite = require_env("SKLEARN_ASV_SUITE")
        asv_profile = require_env("SKLEARN_ASV_PROFILE")
        offline_measurement = require_env("SKLEARN_OFFLINE_MEASUREMENT")
        python_version = require_env("PYTHON_VERSION")
        python_sha256 = require_env("PYTHON_SHA256")
        sdist_sha256 = require_env("SKLEARN_SDIST_SHA256")
        if reps < 1:
            raise ValidationError(f"PERF_REPS must be positive, got {reps}")
        if statistic != "median":
            raise ValidationError(f"unsupported statistic: {statistic}")

        scenario_payload = load_json(scenarios_file)
        scenarios = scenario_payload.get("scenarios")
        if not isinstance(scenarios, list) or not scenarios:
            raise ValidationError(f"{scenarios_file} defines no scenarios")
        runtime = load_json(runtime_path)
        for key in ("python", "python_implementation", "runtime"):
            if key not in runtime:
                raise ValidationError(f"{runtime_path} is missing {key}")
        if runtime["python"] != python_version:
            raise ValidationError(
                f"recorded Python is {runtime['python']}, expected {python_version}"
            )
        if runtime["runtime"].get("scikit-learn") != version:
            raise ValidationError(
                f"recorded scikit-learn is {runtime['runtime'].get('scikit-learn')}, expected {version}"
            )
        manifest_digest = verify_asv_snapshot(asv_dir)

        scenario_names = [item["name"] for item in scenarios]
        if len(set(scenario_names)) != len(scenario_names):
            raise ValidationError("scenario names in scenarios.json are not unique")
        expected_dirs = set(scenario_names)
        actual_dirs = {path.name for path in runs_dir.iterdir() if path.is_dir()}
        if actual_dirs != expected_dirs:
            raise ValidationError(
                f"unexpected scenario directories in {runs_dir}: "
                f"missing={sorted(expected_dirs - actual_dirs)}, extra={sorted(actual_dirs - expected_dirs)}"
            )

        results: dict[str, dict] = {}
        scenarios_report: dict[str, dict] = {}
        warning_summary: dict[str, set[str]] = {}
        for scenario in scenarios:
            name = scenario["name"]
            scenario_dir = runs_dir / name
            if warmups > 0:
                warmup_log = scenario_dir / "warmup.log"
                if not warmup_log.is_file() or warmup_log.stat().st_size == 0:
                    raise ValidationError(f"missing warmup log: {warmup_log}")
            rep_json = sorted(scenario_dir.glob("rep*.json"))
            if len(rep_json) != reps:
                raise ValidationError(
                    f"scenario {name} has {len(rep_json)} sample files, expected {reps}"
                )
            wall_samples: list[float] = []
            rss_samples: list[float] = []
            evidence_first: dict | None = None
            for index in range(1, reps + 1):
                log_path = scenario_dir / f"rep{index}.log"
                json_path = scenario_dir / f"rep{index}.json"
                if not json_path.is_file():
                    raise ValidationError(f"missing sample file: {json_path}")
                sample = validate_sample(log_path, json_path, scenario, runtime)
                wall_samples.append(sample["wall_seconds"])
                rss_samples.append(sample["max_rss_mib"])
                warning_summary.setdefault(name, set()).update(
                    str(item) for item in sample["evidence"].get("warnings", [])
                )
                if evidence_first is None:
                    evidence_first = sample["evidence"]
            wall_stats = build_statistics(wall_samples)
            rss_stats = build_statistics(rss_samples)
            results[f"{name}.wall_seconds"] = {
                "source_name": f"{name}.wall_seconds",
                "value": wall_stats["median"],
                "unit": "s",
                "direction": "lower_is_better",
                "group": name,
                "statistics": wall_stats,
            }
            results[f"{name}.peak_rss_mib"] = {
                "source_name": f"{name}.peak_rss_mib",
                "value": rss_stats["median"],
                "unit": "MiB",
                "direction": "lower_is_better",
                "group": name,
                "statistics": rss_stats,
            }
            scenarios_report[name] = {
                "statistics": {
                    "wall_seconds": wall_stats,
                    "peak_rss_mib": rss_stats,
                },
                "evidence": evidence_first,
                "correctness": {
                    "score": evidence_first["score"],
                    "score_kind": evidence_first["score_kind"],
                    "threshold": scenario["expected"],
                },
            }

        parameters = {
            "variant": variant,
            "python": {
                "implementation": "CPython",
                "version": python_version,
                "source_sha256": python_sha256,
                "configure_options": ["--with-ensurepip=install"],
            },
            "runtime": runtime["runtime"],
            "source_distribution_sha256": sdist_sha256,
            "asv": {
                "repository": asv_repository,
                "tag": asv_tag,
                "tag_commit": asv_commit,
                "suite": asv_suite,
                "profile": asv_profile,
                "n_jobs": 1,
                "vendored_manifest_sha256": manifest_digest,
            },
            "scenarios": [
                {
                    "name": item["name"],
                    "module": item["module"],
                    "benchmark_class": item["class"],
                    "params": item["params"],
                    "method": item["method"],
                    "metric": item["metric"],
                }
                for item in scenarios
            ],
            "measurement": {
                "warmups": warmups,
                "repetitions": reps,
                "statistic": statistic,
                "processes_per_sample": 1,
                "offline": offline_measurement == "true",
                "threads": {
                    "OMP_NUM_THREADS": "1",
                    "OPENBLAS_NUM_THREADS": "1",
                    "MKL_NUM_THREADS": "1",
                    "NUMEXPR_NUM_THREADS": "1",
                },
                "environment": {
                    "PYTHONHASHSEED": "0",
                    "LC_ALL": "C",
                    "TZ": "UTC",
                },
            },
        }

        payload = {
            "software": "scikit-learn",
            "version": version,
            "variant": variant,
            "architecture": architecture,
            "parameters": parameters,
            "summary": {
                "scenario_count": len(scenarios),
                "samples_per_scenario": reps,
                "warmups_per_scenario": warmups,
                "metric_count": len(results),
                "statistic": statistic,
            },
            "results": results,
            "scenarios": scenarios_report,
            "runtime": runtime,
            "asv_snapshot": {
                "repository": asv_repository,
                "tag": asv_tag,
                "tag_commit": asv_commit,
                "manifest_sha256": manifest_digest,
            },
            "warnings_observed": {
                name: sorted(items) for name, items in sorted(warning_summary.items())
            },
        }
        output_path.parent.mkdir(parents=True, exist_ok=True)
        tmp_path = output_path.with_suffix(output_path.suffix + ".tmp")
        tmp_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        os.replace(tmp_path, output_path)
        log(
            f"validated {len(scenarios)} scenarios x {reps} samples "
            f"({len(results)} metrics) from {runs_dir}"
        )
        for name in scenario_names:
            stats = scenarios_report[name]["statistics"]["wall_seconds"]
            rss = scenarios_report[name]["statistics"]["peak_rss_mib"]
            log(
                f"{name}: wall median {stats['median']:.3f}s "
                f"(min {stats['min']:.3f}s, max {stats['max']:.3f}s, stdev {stats['stdev']:.3f}s), "
                f"peak RSS median {rss['median']:.1f} MiB, "
                f"score {scenarios_report[name]['correctness']['score']:.4f}"
            )
        return 0
    except ValidationError as exc:
        log(f"ERROR: {exc}")
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
