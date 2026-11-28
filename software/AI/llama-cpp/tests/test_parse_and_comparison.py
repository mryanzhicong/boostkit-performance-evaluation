"""Validate llama-bench JSON parsing, standalone report generation, and dual-arch comparison."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[4]
CASE_DIR = Path(__file__).resolve().parents[1]
PARSER_PATH = CASE_DIR / "scripts/results/parse_benchmark.py"
RUNTIME_PATH = CASE_DIR / "scripts/results/standalone_runtime.py"

if str(REPO_ROOT / "framework") not in sys.path:
    sys.path.insert(0, str(REPO_ROOT / "framework"))

import build_info  # noqa: E402
import catalog  # noqa: E402
import context as fw_context  # noqa: E402
import generate_comparison  # noqa: E402
import normalize_results  # noqa: E402
import reporting  # noqa: E402


def _load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


PARSER = _load_module("llama_cpp_parse_benchmark", PARSER_PATH)
STANDALONE = _load_module("llama_cpp_standalone_runtime", RUNTIME_PATH)

MODEL_SHA = "aa473d51f451a22f0fcf39ba3330c14bed38a385712b1113440f69df4047a173"


def make_raw_entry(
    *,
    cpu_info: str = "Intel(R) Xeon(R) Platinum",
    model_filename: str = "/home/runner/boostkit-perf/llama-cpp/3ac67535c86/x86_64/100-1/models/bge-m3-q8_0.gguf",
    avg_ts: float = 42.5,
    stddev_ts: float = 0.35,
    avg_ns: int = 12_047_058_824,
    stddev_ns: int = 98_500_000,
    samples_ns: list[int] | None = None,
    samples_ts: list[float] | None = None,
    test_time: str = "2026-11-27T08:00:00Z",
    **overrides,
) -> dict:
    entry = {
        "build_commit": "3ac67535",
        "build_number": 5624,
        "cpu_info": cpu_info,
        "gpu_info": "",
        "backends": "CPU",
        "model_filename": model_filename,
        "model_type": "xlm-roberta 568M Q8_0",
        "model_size": 634_553_760,
        "model_n_params": 567_754_752,
        "n_batch": 512,
        "n_ubatch": 512,
        "n_threads": 1,
        "cpu_mask": "0x0",
        "cpu_strict": False,
        "poll": 50,
        "type_k": "f16",
        "type_v": "f16",
        "n_gpu_layers": 99,
        "split_mode": "layer",
        "main_gpu": 0,
        "no_kv_offload": False,
        "flash_attn": False,
        "tensor_split": "0.00",
        "tensor_buft_overrides": "none",
        "defrag_thold": -1.0,
        "use_mmap": True,
        "embeddings": False,
        "no_op_offload": 0,
        "n_prompt": 512,
        "n_gen": 0,
        "n_depth": 0,
        "test_time": test_time,
        "avg_ns": avg_ns,
        "stddev_ns": stddev_ns,
        "avg_ts": avg_ts,
        "stddev_ts": stddev_ts,
        "samples_ns": samples_ns or [12_010_000_000, 12_050_000_000, 12_080_000_000, 12_045_000_000, 12_050_294_120],
        "samples_ts": samples_ts or [42.63114, 42.48963, 42.38411, 42.50726, 42.48859],
    }
    entry.update(overrides)
    return entry


def write_raw(path: Path, payload: object) -> Path:
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return path


def test_parse_valid_llama_bench_json(tmp_path: Path) -> None:
    raw_file = write_raw(tmp_path / "benchmark_llama_bench.json", [make_raw_entry()])
    parsed = PARSER.parse_llama_bench_json(raw_file, MODEL_SHA, "3ac67535c86")

    assert set(parsed["results"]) == {
        "pp512,b512,t1/prompt_throughput",
        "pp512,b512,t1/prompt_throughput_stddev",
        "pp512,b512,t1/avg_latency_ms",
        "pp512,b512,t1/latency_stddev_ms",
    }
    assert parsed["results"]["pp512,b512,t1/prompt_throughput"] == {
        "value": 42.5,
        "unit": "tokens/s",
        "direction": "higher_is_better",
        "group": "pp512,b512,t1",
    }
    assert parsed["results"]["pp512,b512,t1/avg_latency_ms"] == {
        "value": 12047.058824,
        "unit": "ms",
        "direction": "lower_is_better",
        "group": "pp512,b512,t1",
    }
    assert parsed["parameters"]["model_name"] == "bge-m3-q8_0.gguf"
    assert parsed["parameters"]["model_sha256"] == MODEL_SHA
    assert parsed["parameters"]["repetitions"] == 5
    assert "cpu_info" not in parsed["parameters"]
    assert "model_filename" not in parsed["parameters"]
    assert parsed["runtime_context"]["cpu_info"] == "Intel(R) Xeon(R) Platinum"


@pytest.mark.parametrize(
    ("mutator", "pattern"),
    [
        (lambda e: [], "expected exactly 1"),
        (lambda e: [e, e], "expected exactly 1"),
        (lambda e: [{**e, "build_commit": "unknown"}], "invalid build_commit"),
        (lambda e: [{**e, "build_commit": "deadbeef"}], "does not match expected"),
        (lambda e: [{**e, "n_threads": 4}], "workload parameter mismatch for n_threads"),
        (lambda e: [{**e, "n_prompt": 256}], "workload parameter mismatch for n_prompt"),
        (lambda e: [{**e, "samples_ns": e["samples_ns"][:4]}], "expected 5 timed repetitions"),
        (lambda e: [{**e, "avg_ts": 0.0}], "avg_ts must be > 0"),
        (lambda e: [{**e, "avg_ts": 99.0}], "diverges from mean"),
        (lambda e: [{**e, "model_filename": "/tmp/other.gguf"}], "unexpected model filename"),
    ],
)
def test_parse_rejects_invalid_or_incomplete_outputs(tmp_path: Path, mutator, pattern: str) -> None:
    raw_file = write_raw(tmp_path / "bad.json", mutator(make_raw_entry()))
    with pytest.raises(ValueError, match=pattern):
        PARSER.parse_llama_bench_json(raw_file, MODEL_SHA, "3ac67535c86")


def test_standalone_finalize_preserves_metrics(tmp_path: Path) -> None:
    raw_file = write_raw(tmp_path / "benchmark_llama_bench.json", [make_raw_entry()])
    parsed = PARSER.parse_llama_bench_json(raw_file, MODEL_SHA, "3ac67535c86")
    (tmp_path / "benchmark_llama_cpp.json").write_text(json.dumps(parsed), encoding="utf-8")

    rc = STANDALONE.finalize(tmp_path, "3ac67535c86", "x86_64", "local-1", "passed", "passed", "")
    assert rc == 0
    results = json.loads((tmp_path / "results.json").read_text(encoding="utf-8"))
    assert results["status"] == "passed"
    assert len(results["metrics"]) == 4
    assert "pp512,b512,t1/prompt_throughput" in (tmp_path / "report.md").read_text(encoding="utf-8")


def test_dual_architecture_normalization_and_comparison_pair_cleanly(tmp_path: Path) -> None:
    """Preflight Framework normalization + cross-arch comparison with realistic x86_64 & aarch64 outputs."""
    case, errors = catalog.validate_case(CASE_DIR / "case.yaml", REPO_ROOT)
    assert errors == []
    assert case is not None

    normalized_by_arch = {}
    arch_specs = [
        (
            "x86_64",
            "Intel(R) Xeon(R) Gold 6338 CPU @ 2.00GHz",
            "/home/runner/boostkit-perf/llama-cpp/3ac67535c86/x86_64/run-1/models/bge-m3-q8_0.gguf",
            42.5,
            12_047_058_824,
            [12_010_000_000, 12_050_000_000, 12_080_000_000, 12_045_000_000, 12_050_294_120],
            [42.63114, 42.48963, 42.38411, 42.50726, 42.48859],
            "2026-11-27T08:00:00Z",
        ),
        (
            "aarch64",
            "Kunpeng-920 CPU",
            "/home/runner/boostkit-perf/llama-cpp/3ac67535c86/aarch64/run-2/models/bge-m3-q8_0.gguf",
            51.2,
            10_000_000_000,
            [9_980_000_000, 10_010_000_000, 10_020_000_000, 9_990_000_000, 10_000_000_000],
            [51.30261, 51.14885, 51.09780, 51.25125, 51.20000],
            "2026-11-27T08:05:12Z",
        ),
    ]

    for arch, cpu_info, model_path, avg_ts, avg_ns, s_ns, s_ts, t_stamp in arch_specs:
        work_dir = tmp_path / "work" / arch
        output_dir = tmp_path / "out" / arch
        work_dir.mkdir(parents=True)
        output_dir.mkdir(parents=True)
        ctx = fw_context.RunContext(
            root=REPO_ROOT,
            case_path=CASE_DIR / "case.yaml",
            case=case,
            category="AI",
            software="llama-cpp",
            version="3ac67535c86",
            architecture=arch,
            run_id=f"preflight-{arch}",
            work_dir=work_dir,
            output_dir=output_dir,
        )
        (work_dir / "actual-version.txt").write_text("3ac67535c86\n", encoding="utf-8")
        build_info.record_build_info(ctx)
        (output_dir / "build_variant.json").write_text(
            json.dumps({"variant": "base", "parameters": {"variant": "base"}}) + "\n",
            encoding="utf-8",
        )
        raw_file = write_raw(
            output_dir / "benchmark_llama_bench.json",
            [
                make_raw_entry(
                    cpu_info=cpu_info,
                    model_filename=model_path,
                    avg_ts=avg_ts,
                    avg_ns=avg_ns,
                    samples_ns=s_ns,
                    samples_ts=s_ts,
                    test_time=t_stamp,
                )
            ],
        )
        (output_dir / "benchmark_llama_bench.log").write_text(
            "llama-bench: benchmark 1/1: starting\n", encoding="utf-8"
        )
        parsed = PARSER.parse_llama_bench_json(raw_file, MODEL_SHA, "3ac67535c86")
        (output_dir / "benchmark_llama_cpp.json").write_text(
            json.dumps(parsed, indent=2) + "\n", encoding="utf-8"
        )
        normalized = normalize_results.normalize(ctx, command_status="passed")
        assert normalized["status"] == "passed"
        normalized_by_arch[arch] = normalized

    compared = generate_comparison.compare_pair(
        normalized_by_arch["x86_64"], normalized_by_arch["aarch64"]
    )
    assert compared["software"] == "llama-cpp"
    assert compared["version"] == "3ac67535c86"
    assert len(compared["metrics"]) == 4
    tp = compared["metrics"]["pp512,b512,t1/prompt_throughput"]
    assert tp["x86_64"] == 42.5
    assert tp["aarch64"] == 51.2
    assert tp["unit"] == "tokens/s"
    assert tp["direction"] == "higher_is_better"
    assert tp["relative_performance"] == round(51.2 / 42.5, 4)
    lat = compared["metrics"]["pp512,b512,t1/avg_latency_ms"]
    assert lat["direction"] == "lower_is_better"
    assert lat["relative_performance"] == round(12047.058824 / 10000.0, 4)
    summary = generate_comparison.build_summary(list(normalized_by_arch.values()), [compared])
    markdown = reporting.render_summary(summary, [compared])
    assert "pp512,b512,t1" in markdown
    assert "prompt_throughput" in markdown
    assert "tokens/s" in markdown
