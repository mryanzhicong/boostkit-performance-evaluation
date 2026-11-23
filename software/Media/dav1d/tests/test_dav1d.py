"""Contracts for the dav1d container adapter and result conversion."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPTS = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location(
    "dav1d_parse_benchmark", SCRIPTS / "results/parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)

DECODER = "/work/sources/dav1d-1.5.4/install/bin/dav1d"
STREAM_BQ = "/work/media/BQTerrace-30.ivf"
STREAM_MESSI = "/work/media/messi-30.ivf"
OUTPUT_BYTES = 1920 * 1080 * 3 // 2 * 30


def manifest() -> dict:
    return {
        "videos": [
            {
                "name": "BQTerrace",
                "source_filename": "BQTerrace_1920x1080_60-dianbo.yuv",
                "source_path": "/videos/BQTerrace_1920x1080_60-dianbo.yuv",
                "source_bytes": 1866240000,
                "source_sha256": "a" * 64,
                "fps": 60,
                "stream_filename": "BQTerrace-30.ivf",
                "stream_path": STREAM_BQ,
                "stream_bytes": 12345,
                "stream_sha256": "b" * 64,
                "command": ["aomenc"],
            },
            {
                "name": "messi",
                "source_filename": "messi_1920x1080_25_1000.yuv",
                "source_path": "/videos/messi_1920x1080_25_1000.yuv",
                "source_bytes": 3110400000,
                "source_sha256": "c" * 64,
                "fps": 25,
                "stream_filename": "messi-30.ivf",
                "stream_path": STREAM_MESSI,
                "stream_bytes": 23456,
                "stream_sha256": "d" * 64,
                "command": ["aomenc"],
            },
        ],
        "frames": 30,
        "width": 1920,
        "height": 1080,
        "bit_depth": 8,
        "cq_level": 32,
        "encoder": {
            "path": "/work/sources/aom-3.2.0/build-generic/aomenc",
            "version": "aom-3.2.0",
            "settings": {
                "codec": "av1", "good": True, "cpu_used": 8, "passes": 1,
                "threads": 1, "row_mt": 0, "tile_columns": 1, "end_usage": "q",
                "cq_level": 32, "limit": 30, "input_bit_depth": 8, "bit_depth": 8,
            },
        },
        "prepared_at": "2026-01-01T00:00:00Z",
    }


def evidence() -> dict:
    data = manifest()
    scenarios = []
    for video, stream_sha, stream_path in (
        ("BQTerrace", "b" * 64, STREAM_BQ),
        ("messi", "d" * 64, STREAM_MESSI),
    ):
        samples = [1.0 + index * 0.01 for index in range(20)]
        scenarios.append({
            "scenario": f"{video}_1080p_decode_c16",
            "video": video,
            "threads": 16,
            "frames": 30,
            "iterations": 20,
            "input_sha256": stream_sha,
            "warmup": {
                "command": [DECODER, "--input", stream_path, "--muxer", "yuv"],
                "seconds": 0.5,
                "output_bytes": OUTPUT_BYTES,
                "output_sha256": "e" * 64,
            },
            "timed_command": [
                DECODER, "--input", stream_path, "--threads", "16",
                "--framedelay", "0", "--filmgrain", "1", "--quiet",
                "--muxer", "null", "--output", "/dev/null",
            ],
            "samples_ms_per_frame": samples,
            "mean_ms_per_frame": sum(samples) / len(samples),
            "median_ms_per_frame": 1.095,
            "min_ms_per_frame": min(samples),
            "max_ms_per_frame": max(samples),
            "stdev_ms_per_frame": 0.1,
            "total_seconds": sum(samples) * 30 / 1000.0,
        })
    return {
        "software": "dav1d",
        "version": "1.5.4",
        "architecture": "x86_64",
        "generated_at": "2026-01-01T00:00:00Z",
        "decoder": {
            "path": DECODER,
            "sha256": "f" * 64,
            "version_output": "dav1d 1.5.4",
        },
        "manifest": data,
        "parameters": parser.expected_parameters(data),
        "runtime_context": {"cpu_count": 16, "machine": "x86_64"},
        "scenarios": scenarios,
    }


def csv_text(data: dict) -> str:
    lines = ["scenario,frames,ms_per_frame,status"]
    for item in data["scenarios"]:
        lines.append(f"{item['scenario']},30,{item['mean_ms_per_frame']:.6f},OK")
    return "\n".join(lines) + "\n"


def test_valid_evidence_produces_two_fixed_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "1.5.4", "x86_64")
    assert payload["benchmark"] == "dav1d_decode"
    assert payload["parameters"]["frames"] == 30
    assert payload["parameters"]["decode_threads"] == 16
    assert payload["parameters"]["affinity"] == "unbound"
    assert len(payload["parameters"]["videos"]) == 2
    assert set(payload["results"]) == {
        "BQTerrace_1080p_decode_c16", "messi_1080p_decode_c16",
    }
    item = payload["results"]["BQTerrace_1080p_decode_c16"]
    assert item["unit"] == "ms/frame"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "BQTerrace"
    assert item["value"] == pytest.approx(1.095, abs=1e-9)
    assert payload["runtime_context"]["stream_sha256"]["messi"] == "d" * 64


def test_rejects_missing_and_duplicate_csv_scenarios() -> None:
    data = evidence()
    lines = csv_text(data).splitlines()
    with pytest.raises(ValueError, match="exactly two"):
        parser.parse("\n".join(lines[:-1]) + "\n", data, "1.5.4", "x86_64")
    duplicate = lines + [lines[1]]
    with pytest.raises(ValueError, match="duplicate|exactly two"):
        parser.parse("\n".join(duplicate) + "\n", data, "1.5.4", "x86_64")


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda data: data["scenarios"][0]["samples_ms_per_frame"].pop(), "20 timing samples"),
        (lambda data: data["scenarios"][0]["samples_ms_per_frame"].__setitem__(0, 0), "positive"),
        (lambda data: data["scenarios"][0].__setitem__("mean_ms_per_frame", 99.0), "recorded mean"),
        (lambda data: data["scenarios"][0].__setitem__("input_sha256", "1" * 64), "input stream"),
        (lambda data: data["scenarios"][0]["warmup"].__setitem__("output_bytes", 1), "30 frames"),
        (lambda data: data["scenarios"][1].__setitem__("threads", 8), "16 decoder threads"),
        (lambda data: data["scenarios"].pop(), "exactly two"),
        (lambda data: data["parameters"].__setitem__("cq_level", 31), "fixed workload"),
        (lambda data: data["manifest"].__setitem__("cq_level", 31), "fixed workload"),
    ],
)
def test_rejects_incomplete_or_inconsistent_evidence(mutate, message: str) -> None:
    data = evidence()
    mutate(data)
    with pytest.raises(ValueError, match=message):
        parser.parse(csv_text(data), data, "1.5.4", "x86_64")


def test_rejects_wrong_architecture_and_version() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="architecture"):
        parser.parse(csv_text(data), data, "1.5.4", "aarch64")
    with pytest.raises(ValueError, match="requested dav1d version"):
        parser.parse(csv_text(data), data, "1.6.0", "x86_64")


def test_rejects_bad_csv_status_and_value() -> None:
    data = evidence()
    text = csv_text(data).replace(",OK", ",FAILED", 1)
    with pytest.raises(ValueError, match="did not complete"):
        parser.parse(text, data, "1.5.4", "x86_64")
    text = csv_text(data).replace(",1.095000,", ",nan,", 1)
    with pytest.raises(ValueError, match="positive"):
        parser.parse(text, data, "1.5.4", "x86_64")


def test_case_declares_container_stages_and_outputs() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["category"] == "Media"
    assert case["versions"] == ["1.5.4"]
    assert case["test_tools"]["aom"]["version"] == "3.2.0"
    assert case["execution"]["stages"] == {
        "build": {"script": "scripts/builders/dispatch.sh", "function": "build_dav1d"},
        "start": {"script": "scripts/stages/start.sh", "function": "start_dav1d_runtime"},
        "test": {"script": "scripts/stages/test.sh", "function": "run_dav1d_benchmarks"},
        "stop": {"script": "scripts/stages/stop.sh", "function": "stop_dav1d_runtime"},
    }
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_dav1d.json"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-dav1d.csv"
    assert case["outputs"]["decode_evidence"]["format"] == "directory"
    assert case["metrics"]["collection"]["group_path"] == "group"
    assert len(case["outputs"]) == 5


def test_optimized_build_fails_without_writing_variant(tmp_path: Path) -> None:
    results = tmp_path / "results"
    work = tmp_path / "work"
    environment = {
        **os.environ,
        "PERF_VARIANT": "optimized",
        "PERF_RUN_ID": "test-run",
        "EXPECTED_ARCH": "x86_64",
        "PERF_WORK_DIR": str(work),
        "RESULTS_DIR": str(results),
    }
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; build_dav1d', "bash",
         str(CASE_DIR / "scripts/builders/dispatch.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 40
    assert "optimized dav1d build is not implemented" in result.stdout
    assert not (results / "build_variant.json").exists()


def test_container_name_is_derived_from_architecture_and_run_id(tmp_path: Path) -> None:
    environment = {
        **os.environ,
        "PERF_RUN_ID": "12345-1",
        "EXPECTED_ARCH": "aarch64",
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
    }
    result = subprocess.run(
        ["bash", "-c",
         'source "$1"; configure_runtime_paths; printf "%s\\n" "${DAV1D_CONTAINER_NAME}"',
         "bash", str(SCRIPTS / "common.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-dav1d-aarch64-12345-1"


def test_only_build_creates_the_container() -> None:
    for stage in ("start.sh", "test.sh", "stop.sh"):
        text = (SCRIPTS / "stages" / stage).read_text()
        assert "docker run" not in text
        assert "require_dav1d_container" not in text
    assert "require_dav1d_container" in (SCRIPTS / "builders/base.sh").read_text()


def _small_video_fixture(tmp_path: Path) -> tuple[Path, Path, Path]:
    source_dir = tmp_path / "video"
    output_dir = tmp_path / "media"
    log_dir = tmp_path / "logs"
    source_dir.mkdir()
    output_dir.mkdir()
    log_dir.mkdir()
    manifest_path = output_dir / "manifest.json"
    videos = []
    for name, filename, fps, stream in (
        ("BQTerrace", "BQTerrace_1920x1080_60-dianbo.yuv", 60, "BQTerrace-30.ivf"),
        ("messi", "messi_1920x1080_25_1000.yuv", 25, "messi-30.ivf"),
    ):
        source = source_dir / filename
        source.write_bytes(b"\x00" * (4 * 4 * 3 // 2 * 2))
        stream_path = output_dir / stream
        stream_path.write_bytes(b"IVF0")
        videos.append({
            "name": name, "source_filename": filename,
            "source_path": str(source), "source_bytes": source.stat().st_size,
            "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
            "fps": fps, "stream_filename": stream,
            "stream_path": str(stream_path), "stream_bytes": stream_path.stat().st_size,
            "stream_sha256": hashlib.sha256(stream_path.read_bytes()).hexdigest(),
            "command": ["aomenc"],
        })
    manifest_path.write_text(json.dumps({
        "videos": videos, "frames": 2, "width": 4, "height": 4,
        "bit_depth": 8, "cq_level": 32,
        "encoder": {"version": "aom-3.2.0", "settings": {}},
    }), encoding="utf-8")
    return source_dir, output_dir, manifest_path


def test_prepare_inputs_verify_only_checks_hashes(tmp_path: Path) -> None:
    source_dir, output_dir, manifest_path = _small_video_fixture(tmp_path)
    command = [
        sys.executable, str(SCRIPTS / "results/prepare_inputs.py"),
        "--source-dir", str(source_dir), "--output-dir", str(output_dir),
        "--manifest", str(manifest_path), "--log-dir", str(tmp_path / "logs"),
        "--width", "4", "--height", "4", "--frames", "2", "--verify-only",
    ]
    passed = subprocess.run(command, capture_output=True, text=True, check=False)
    assert passed.returncode == 0, passed.stderr
    (output_dir / "messi-30.ivf").write_bytes(b"BAD!")
    failed = subprocess.run(command, capture_output=True, text=True, check=False)
    assert failed.returncode == 2
    assert "checksum differs" in failed.stderr


def test_prepare_inputs_runs_encoder_in_writable_output_directory(tmp_path: Path) -> None:
    source_dir = tmp_path / "video"
    output_dir = tmp_path / "media"
    log_dir = tmp_path / "logs"
    source_dir.mkdir()
    log_dir.mkdir()
    encoder = tmp_path / "fake-aomenc"
    encoder.write_text(
        "#!/usr/bin/env python3\n"
        "from pathlib import Path\n"
        "import sys\n"
        "Path('psnr.txt').write_text('encoder sidecar')\n"
        "Path(sys.argv[sys.argv.index('-o') + 1]).write_bytes(b'IVF0')\n",
        encoding="utf-8",
    )
    encoder.chmod(0o755)
    for filename in (
        "BQTerrace_1920x1080_60-dianbo.yuv",
        "messi_1920x1080_25_1000.yuv",
    ):
        (source_dir / filename).write_bytes(b"\x00" * (4 * 4 * 3 // 2 * 2))
    manifest_path = tmp_path / "media" / "manifest.json"
    result = subprocess.run(
        [sys.executable, str(SCRIPTS / "results/prepare_inputs.py"),
         "--encoder", str(encoder), "--source-dir", str(source_dir),
         "--output-dir", str(output_dir), "--manifest", str(manifest_path),
         "--log-dir", str(log_dir), "--width", "4", "--height", "4", "--frames", "2"],
        cwd=tmp_path, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert (output_dir / "psnr.txt").read_text() == "encoder sidecar"
    assert not (tmp_path / "psnr.txt").exists()
    assert (output_dir / "BQTerrace-30.ivf").read_bytes() == b"IVF0"
    assert (output_dir / "messi-30.ivf").read_bytes() == b"IVF0"
