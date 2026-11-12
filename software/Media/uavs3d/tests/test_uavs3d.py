"""Contracts for the uavs3d container adapter and result conversion."""

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
    "uavs3d_parse_benchmark", SCRIPTS / "results/parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)

STREAM_PATH = "/work/media/Film2012_1080p_q32.avs3"
DECODER = "/work/sources/uavs3d-1.2/build/uavs3dec"
OUTPUT_BYTES = 1920 * 1080 * 3 // 2 * 120


def manifest() -> dict:
    return {
        "name": "Film2012",
        "source_filename": "Film2012_1920x1080_25_8bit_8Mbps.yuv",
        "source_path": "/videos/Film2012_1920x1080_25_8bit_8Mbps.yuv",
        "source_bytes": OUTPUT_BYTES,
        "source_sha256": "a" * 64,
        "frames": 120,
        "width": 1920,
        "height": 1080,
        "fps": 25,
        "qp": 32,
        "bit_depth": 8,
        "stream_filename": "Film2012_1080p_q32.avs3",
        "stream_path": STREAM_PATH,
        "stream_bytes": 12345,
        "stream_sha256": "b" * 64,
        "encoder": {
            "path": "/work/sources/uavs3e-1.3/build/uavs3enc",
            "version": "uavs3e-1.3",
            "settings": {
                "wpp_threads": 4, "frm_threads": 2, "speed_level": 4,
                "gop": 7, "preset": 0, "fps_num": 25, "fps_den": 1,
            },
            "command": ["uavs3enc"],
        },
        "prepared_at": "2026-01-01T00:00:00Z",
    }


def evidence() -> dict:
    data = manifest()
    scenarios = []
    for threads in (16, 24):
        samples = [1.0 + index * 0.01 for index in range(20)]
        scenarios.append({
            "scenario": f"Film2012_1080p_q32_decode_c{threads}",
            "threads": threads,
            "frames": 120,
            "iterations": 20,
            "input_sha256": data["stream_sha256"],
            "warmup": {
                "command": [DECODER, "-i", STREAM_PATH, "-o", "/work/media/warmup.yuv"],
                "seconds": 0.5,
                "output_bytes": OUTPUT_BYTES,
                "output_sha256": "c" * 64,
            },
            "timed_command": [
                DECODER, "-i", STREAM_PATH, "-o", "/dev/null",
                "-t", str(threads), "-l", "1", "-s", "0",
            ],
            "samples_ms_per_frame": samples,
            "mean_ms_per_frame": sum(samples) / len(samples),
            "median_ms_per_frame": 1.095,
            "min_ms_per_frame": min(samples),
            "max_ms_per_frame": max(samples),
            "stdev_ms_per_frame": 0.1,
            "total_seconds": sum(samples) * 120 / 1000.0,
        })
    return {
        "software": "uavs3d",
        "version": "1.2",
        "architecture": "x86_64",
        "generated_at": "2026-01-01T00:00:00Z",
        "decoder": {
            "path": DECODER,
            "sha256": "d" * 64,
            "version_output": "uavs2d: 1.2._release, ",
        },
        "manifest": data,
        "parameters": parser.expected_parameters(data),
        "runtime_context": {"cpu_count": 16, "machine": "x86_64"},
        "scenarios": scenarios,
    }


def csv_text(data: dict) -> str:
    lines = ["scenario,frames,ms_per_frame,status"]
    for item in data["scenarios"]:
        lines.append(f"{item['scenario']},120,{item['mean_ms_per_frame']:.6f},OK")
    return "\n".join(lines) + "\n"


def test_valid_evidence_produces_two_fixed_metrics() -> None:
    data = evidence()
    payload = parser.parse(csv_text(data), data, "1.2", "x86_64")
    assert payload["benchmark"] == "uavs3d_decode"
    assert payload["parameters"]["frames"] == 120
    assert payload["parameters"]["iterations"] == 20
    assert payload["parameters"]["decode_threads"] == [16, 24]
    assert payload["parameters"]["affinity"] == "unbound"
    assert payload["parameters"]["video_sha256"] == "a" * 64
    assert set(payload["results"]) == {
        "Film2012_1080p_q32_decode_c16", "Film2012_1080p_q32_decode_c24",
    }
    sixteen = payload["results"]["Film2012_1080p_q32_decode_c16"]
    assert sixteen["unit"] == "ms/frame"
    assert sixteen["direction"] == "lower_is_better"
    assert sixteen["group"] == "16 threads"
    assert sixteen["value"] == pytest.approx(1.095, abs=1e-9)
    assert payload["runtime_context"]["stream_sha256"] == "b" * 64


def test_rejects_missing_and_duplicate_csv_scenarios() -> None:
    data = evidence()
    lines = csv_text(data).splitlines()
    with pytest.raises(ValueError, match="exactly two"):
        parser.parse("\n".join(lines[:-1]) + "\n", data, "1.2", "x86_64")
    duplicate = lines + [lines[1]]
    with pytest.raises(ValueError, match="duplicate|exactly two"):
        parser.parse("\n".join(duplicate) + "\n", data, "1.2", "x86_64")


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda data: data["scenarios"][0]["samples_ms_per_frame"].pop(), "20 timing samples"),
        (lambda data: data["scenarios"][0]["samples_ms_per_frame"].__setitem__(0, 0), "positive"),
        (lambda data: data["scenarios"][0].__setitem__("mean_ms_per_frame", 99.0), "recorded mean"),
        (lambda data: data["scenarios"][0].__setitem__("input_sha256", "e" * 64), "input stream"),
        (lambda data: data["scenarios"][0]["warmup"].__setitem__("output_bytes", 1), "120 frames"),
        (lambda data: data["scenarios"][1].__setitem__("threads", 32), "thread count"),
        (lambda data: data["scenarios"].pop(), "exactly two"),
        (lambda data: data["parameters"].__setitem__("qp", 31), "fixed workload"),
        (lambda data: data["manifest"].__setitem__("qp", 31), "fixed workload"),
    ],
)
def test_rejects_incomplete_or_inconsistent_evidence(mutate, message: str) -> None:
    data = evidence()
    mutate(data)
    with pytest.raises(ValueError, match=message):
        parser.parse(csv_text(data), data, "1.2", "x86_64")


def test_rejects_wrong_architecture_and_version() -> None:
    data = evidence()
    with pytest.raises(ValueError, match="architecture"):
        parser.parse(csv_text(data), data, "1.2", "aarch64")
    with pytest.raises(ValueError, match="requested uavs3d version"):
        parser.parse(csv_text(data), data, "1.3", "x86_64")


def test_rejects_bad_csv_status_and_value() -> None:
    data = evidence()
    text = csv_text(data).replace(",OK", ",FAILED", 1)
    with pytest.raises(ValueError, match="did not complete"):
        parser.parse(text, data, "1.2", "x86_64")
    text = csv_text(data).replace(",1.095000,", ",nan,", 1)
    with pytest.raises(ValueError, match="positive"):
        parser.parse(text, data, "1.2", "x86_64")


def test_case_declares_container_stages_and_outputs() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["category"] == "Media"
    assert case["versions"] == ["1.2"]
    assert case["test_tools"]["uavs3e"]["version"] == "1.3"
    assert case["execution"]["stages"] == {
        "build": {"script": "scripts/builders/dispatch.sh", "function": "build_uavs3d"},
        "start": {"script": "scripts/stages/start.sh", "function": "start_uavs3d_runtime"},
        "test": {"script": "scripts/stages/test.sh", "function": "run_uavs3d_benchmarks"},
        "stop": {"script": "scripts/stages/stop.sh", "function": "stop_uavs3d_runtime"},
    }
    assert case["outputs"]["benchmark_result"]["path"] == "benchmark_uavs3d.json"
    assert case["outputs"]["benchmark_result_csv"]["path"] == "result_bench-uavs3d.csv"
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
        ["bash", "-c", 'source "$1"; build_uavs3d', "bash",
         str(CASE_DIR / "scripts/builders/dispatch.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 40
    assert "optimized uavs3d build is not implemented" in result.stdout
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
         'source "$1"; configure_runtime_paths; printf "%s\\n" "${UAVS3D_CONTAINER_NAME}"',
         "bash", str(SCRIPTS / "common.sh")],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "boostkit-uavs3d-aarch64-12345-1"


def test_only_build_creates_the_container() -> None:
    for stage in ("start.sh", "test.sh", "stop.sh"):
        text = (SCRIPTS / "stages" / stage).read_text()
        assert "docker run" not in text
        assert "require_uavs3d_container" not in text
    assert "require_uavs3d_container" in (SCRIPTS / "builders/base.sh").read_text()


def test_prepare_inputs_verify_only_checks_hashes(tmp_path: Path) -> None:
    source = tmp_path / "small.yuv"
    source.write_bytes(b"\x00" * (4 * 4 * 3 // 2 * 2))
    stream = tmp_path / "small.avs3"
    stream.write_bytes(b"\x01\x02\x03\x04")
    manifest_path = tmp_path / "manifest.json"

    def digest(path: Path) -> str:
        return hashlib.sha256(path.read_bytes()).hexdigest()

    manifest_path.write_text(json.dumps({
        "name": "Film2012", "source_filename": source.name,
        "source_sha256": digest(source), "source_bytes": source.stat().st_size,
        "stream_filename": stream.name, "stream_sha256": digest(stream),
        "stream_bytes": stream.stat().st_size, "width": 4, "height": 4,
        "frames": 2, "fps": 25, "qp": 32, "bit_depth": 8,
        "encoder": {"version": "uavs3e-1.3", "settings": {}},
    }), encoding="utf-8")

    def verify() -> subprocess.CompletedProcess:
        return subprocess.run(
            [sys.executable, str(SCRIPTS / "results/prepare_inputs.py"),
             "--source", str(source), "--output", str(stream),
             "--manifest", str(manifest_path), "--width", "4", "--height", "4",
             "--frames", "2", "--fps", "25", "--qp", "32", "--verify-only"],
            capture_output=True, text=True, check=False,
        )

    passed = verify()
    assert passed.returncode == 0, passed.stderr
    assert "Input verified" in passed.stdout
    stream.write_bytes(b"\x01\x02\x03\x05")
    failed = verify()
    assert failed.returncode == 2
    assert "checksum differs" in failed.stderr


def test_prepare_inputs_runs_encoder_in_writable_output_directory(tmp_path: Path) -> None:
    source = tmp_path / "small.yuv"
    source.write_bytes(b"\x00" * (4 * 4 * 3 // 2 * 2))
    encoder = tmp_path / "fake-uavs3enc"
    encoder.write_text(
        "#!/usr/bin/env python3\n"
        "from pathlib import Path\n"
        "import sys\n"
        "Path('psnr.txt').write_text('encoder sidecar')\n"
        "Path(sys.argv[sys.argv.index('-o') + 1]).write_bytes(b'AVS3')\n",
        encoding="utf-8",
    )
    encoder.chmod(0o755)
    output = tmp_path / "private-media" / "small.avs3"
    manifest_path = tmp_path / "private-media" / "manifest.json"
    result = subprocess.run(
        [sys.executable, str(SCRIPTS / "results/prepare_inputs.py"),
         "--encoder", str(encoder), "--source", str(source),
         "--output", str(output), "--manifest", str(manifest_path),
         "--width", "4", "--height", "4", "--frames", "2"],
        cwd=tmp_path, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stderr
    assert output.read_bytes() == b"AVS3"
    assert (output.parent / "psnr.txt").read_text() == "encoder sidecar"
    assert not (tmp_path / "psnr.txt").exists()
