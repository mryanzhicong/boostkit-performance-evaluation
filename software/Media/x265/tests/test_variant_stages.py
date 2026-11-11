"""Contracts for the vendored Test/x265 scripts and Framework adapter."""

from __future__ import annotations

import argparse
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
SCRIPT_DIR = CASE_DIR / "scripts"
SPEC = importlib.util.spec_from_file_location(
    "x265_parse_reference", SCRIPT_DIR / "results/parse_reference.py"
)
assert SPEC is not None and SPEC.loader is not None
parser = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(parser)


def test_case_declares_split_stages_and_original_csv() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    assert case["versions"] == ["4.2"]
    assert case["test_tools"]["ffmpeg"]["version"] == "7.0.1"
    assert case["execution"]["stages"] == {
        "build": {"script": "scripts/builders/dispatch.sh", "function": "build_x265"},
        "start": {"script": "scripts/stages/start.sh", "function": "start_x265_runtime"},
        "test": {"script": "scripts/stages/test.sh", "function": "run_x265_benchmarks"},
        "stop": {"script": "scripts/stages/stop.sh", "function": "stop_x265_runtime"},
    }
    assert case["outputs"]["reference_summary"]["path"] == "result_bench-x265.csv"
    assert len(case["outputs"]) == 4


def test_original_encoder_engine_is_byte_identical() -> None:
    data = (SCRIPT_DIR / "reference/bench_scene.py").read_bytes()
    assert hashlib.sha256(data).hexdigest() == (
        "d69fe2b686bc4b1eaca96c67de00e8f412da6e4f421679992f9181ad3f05e101"
    )
    run_script = (SCRIPT_DIR / "reference/run.py").read_text()
    assert "X265_VIDEO_DIR" in run_script
    assert "for crf in (24, 28)" in run_script
    assert "engine.encode_one" in run_script
    stage_script = (SCRIPT_DIR / "stages/test.sh").read_text()
    assert '"${private_scripts}/run.py"' in stage_script
    assert "parse_reference.py" in stage_script
    build_script = (SCRIPT_DIR / "builders/base.sh").read_text()
    assert '"${private_scripts}/bench_scene.py" build' in build_script


def test_optimized_build_is_not_silently_replaced_by_base(tmp_path: Path) -> None:
    result = subprocess.run(
        ["bash", "-c", 'source "$1"; build_x265', "bash",
         str(SCRIPT_DIR / "builders/dispatch.sh")],
        env={**os.environ, "PERF_VARIANT": "optimized", "PERF_WORK_DIR": str(tmp_path)},
        capture_output=True, text=True, check=False,
    )
    assert result.returncode == 30
    assert "optimized x265 build is not implemented" in result.stdout


def make_reference_fixture(tmp_path: Path) -> tuple[Path, Path]:
    reference = tmp_path / "reference"
    scripts = reference / "scripts"
    scripts.mkdir(parents=True)
    video = tmp_path / parser.VIDEO_NAME
    video.write_bytes(b"fixture")
    records = []
    csv = ["scenario,frames,fps,status\n"]
    for scenario, crf in parser.SCENARIOS.items():
        folder = scripts / ".work/cases" / scenario / "encode-r1-n0"
        folder.mkdir(parents=True)
        output = folder / "output.mp4"
        output.write_bytes(b"MP4")
        command = [
            "/private/bin/ffmpeg", "-frames:v", "600", "-preset", "medium",
            "-crf", str(crf), "-maxrate", "6000k", "-bufsize", "12000k",
            "-x265-params", parser.X265_PARAMS, str(output),
        ]
        (folder / "command.json").write_text(json.dumps(command))
        for name in ("progress.txt", "encode.log", "probe.json", "result.json"):
            (folder / name).write_text("original reference evidence\n")
        settings = {
            "cores": 16, "preset": "medium", "frame_threads": 15,
            "pool_threads": 16, "ctu_size": 16, "bframes": 7,
            "aq_mode": 4, "crf": crf, "maxrate_kbps": 6000,
            "bufsize_kbits": 12000,
            "video": {
                "path": str(video), "width": 1920, "height": 1080,
                "fps": "60", "pix_fmt": "yuv420p", "start_frame": 0,
                "screen_frames": 600,
            },
        }
        row = {
            "status": "OK", "frames": 600, "affinity": "unbound",
            "phase": "confirm", "start_frame": 0, "settings": settings,
            "seconds": 10.0, "fps": 60.0,
            "output_bytes": 3, "output_sha256": "output-sha",
        }
        records.append({
            "scenario": scenario,
            "item": {"name": "BQTerrace", "filename": parser.VIDEO_NAME, "fps": 60},
            "data": {"affinity": "unbound", "rows": [row]},
            "output": str(output), "command_file": str(folder / "command.json"),
        })
        csv.append(f"{scenario},600,60.000,OK\n")
    (scripts / ".work/evidence.json").write_text(json.dumps({
        "runs": records, "affinity": "unbound",
    }))
    (scripts / "result_bench-x265.csv").write_text("".join(csv))
    return reference, video


def test_original_reference_rows_generate_two_comparable_metrics(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    reference, video = make_reference_fixture(tmp_path)
    monkeypatch.setattr(parser, "sha256_file", lambda path: "same-video-sha")
    payloads = []
    for arch in ("x86_64", "aarch64"):
        output = tmp_path / arch
        (output / "benchmark_encode.txt").parent.mkdir()
        (output / "benchmark_encode.txt").write_text("original run.py stdout\n")
        args = argparse.Namespace(
            reference_dir=reference, video=video, results_dir=output,
            version="4.2", architecture=arch,
        )
        payload = parser.parse(args)
        assert (output / "scenarios/BQTerrace_medium_crf24_offline/encode.log").is_file()
        assert len(payload["results"]) == 2
        payloads.append(payload)
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    sys.path.insert(0, str(CASE_DIR.parents[2] / "framework"))
    from context import RunContext
    from generate_comparison import compare_pair
    from normalize_results import _extract_metrics, parameter_signature

    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text())
    normalized = []
    for arch, payload in zip(("x86_64", "aarch64"), payloads):
        context = RunContext(
            root=CASE_DIR.parents[2], case_path=CASE_DIR / "case.yaml",
            case=case, category="Media", software="x265", version="4.2",
            architecture=arch, run_id="test-1", output_dir=tmp_path / arch,
            work_dir=tmp_path / arch / "work",
        )
        parameters = {"benchmark_result": payload["parameters"]}
        normalized.append({
            "category": "Media", "software": "x265", "version": "4.2",
            "architecture": arch, "parameters": parameters,
            "parameter_signature": parameter_signature(context, parameters),
            "test_tools": case["test_tools"],
            "metrics": _extract_metrics(context, {"benchmark_result": payload}),
        })
    assert len(compare_pair(*normalized)["metrics"]) == 2


def test_missing_original_scene_is_rejected(tmp_path: Path) -> None:
    reference, video = make_reference_fixture(tmp_path)
    evidence = reference / "scripts/.work/evidence.json"
    payload = json.loads(evidence.read_text())
    payload["runs"].pop()
    evidence.write_text(json.dumps(payload))
    with pytest.raises(ValueError, match="two unbound scenes"):
        parser.parse(argparse.Namespace(
            reference_dir=reference, video=video, results_dir=tmp_path / "result",
            version="4.2", architecture="x86_64",
        ))
