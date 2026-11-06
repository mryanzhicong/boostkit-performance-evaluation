"""Offline contract tests for the OpenCV case.

They run without Docker, without an OpenCV build, without numpy and without the
YUV archive, so a silent regression in the container wiring, the sampling
contract, the strict parser or the case registration fails in a plain pytest run.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = CASE_DIR.parents[2]
COMMON = CASE_DIR / "scripts" / "common.sh"
DISPATCH = CASE_DIR / "scripts" / "builders" / "dispatch.sh"
BASE = CASE_DIR / "scripts" / "builders" / "base.sh"
OPTIMIZED = CASE_DIR / "scripts" / "builders" / "optimized.sh"
TEST_STAGE = CASE_DIR / "scripts" / "stages" / "test.sh"
HARNESS = CASE_DIR / "scripts" / "harness" / "bench_norm.py"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
MANIFEST = CASE_DIR / "fixtures" / "media.json"
CASE_YAML = CASE_DIR / "case.yaml"
STANDALONE = CASE_DIR / "opencv_test.sh"

SAMPLES = 5
CALLS = 500

PINNING_TOKENS = ("taskset", "numactl", "sched_setaffinity", "membind", "SchedSetaffinity")

SHELL_FILES = sorted(path for path in CASE_DIR.rglob("*.sh"))

BUILD_INFO = """
General configuration for OpenCV 4.10.0
  Parallel framework:            none
"""


def manifest_document() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# case wiring
# ---------------------------------------------------------------------------


def test_case_declares_the_four_stages_and_timeout() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for stage in ("build", "start", "test", "stop"):
        assert re.search(rf"^\s{{4}}{stage}:\s*$", text, re.MULTILINE), stage
    assert "timeout_minutes: 1200" in text
    assert "category: Media" in text
    assert '  - "4.10.0"' in text


def test_case_publishes_the_expected_outputs_and_metric() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for output in ("build_variant.json", "benchmark_norm.txt", "benchmark_opencv.json",
                   "result_bench-opencv.csv"):
        assert output in text
    assert "name_path: source_name" in text
    assert "value_path: value" in text
    assert "unit: ms" in text
    assert "direction: lower_is_better" in text


def test_case_tree_is_complete() -> None:
    for path in (
        CASE_YAML,
        CASE_DIR / "README.md",
        STANDALONE,
        MANIFEST,
        COMMON,
        DISPATCH,
        BASE,
        OPTIMIZED,
        TEST_STAGE,
        CASE_DIR / "scripts" / "stages" / "start.sh",
        CASE_DIR / "scripts" / "stages" / "stop.sh",
        HARNESS,
        PARSER,
    ):
        assert path.is_file(), path


def test_case_is_registered_in_the_media_category_and_workflows() -> None:
    categories = (REPO_ROOT / "config" / "categories.yaml").read_text(encoding="utf-8")
    media_block = categories.split("Media:", 1)[1].splitlines()
    assert any(line.strip() == "- opencv" for line in media_block[:6]), media_block[:6]
    for workflow in (
        ".github/workflows/performance-test-blue.yml",
        ".github/workflows/performance-test.yml",
        ".github/workflows/development-performance-test.yml",
        ".github/workflows/compare-existing-results.yml",
    ):
        text = (REPO_ROOT / workflow).read_text(encoding="utf-8")
        assert re.search(r"^\s*-\s*opencv\s*$", text, re.MULTILINE), workflow


# ---------------------------------------------------------------------------
# container runtime block
# ---------------------------------------------------------------------------


def test_generated_container_block_is_present_and_complete() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "# >>> container-runtime:begin" in text
    assert "# >>> container-runtime:end" in text
    for function in (
        "require_opencv_docker",
        "prepare_opencv_container_image",
        "start_opencv_container",
        "check_opencv_container",
        "opencv_container_exec",
        "remove_opencv_container",
    ):
        assert f"{function}()" in text, function


def test_container_block_mounts_read_only_media_and_labels_the_run() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "opencv_media_mount_args()" in text
    assert 'target=${OPENCV_MEDIA_CONTAINER_DIR},readonly' in text
    assert "boostkit.opencv.run-id" in text
    assert "--network=host" in text
    assert "OPENCV_CONTAINER_EXTRA_ARGS" in text


def test_no_cpu_or_memory_pinning_anywhere() -> None:
    for path in [COMMON, DISPATCH, BASE, OPTIMIZED, TEST_STAGE, HARNESS, PARSER, STANDALONE]:
        text = path.read_text(encoding="utf-8")
        for token in PINNING_TOKENS:
            assert token not in text, f"{path.name} must not contain {token}"


def test_sampling_defaults_and_pinned_archive() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert 'OPENCV_WARMUPS="${OPENCV_WARMUPS:-5}"' in text
    assert 'OPENCV_SAMPLES="${OPENCV_SAMPLES:-20}"' in text
    assert 'OPENCV_CALLS_PER_SAMPLE="${OPENCV_CALLS_PER_SAMPLE:-500}"' in text
    assert 'OPENCV_STATISTIC="median"' in text
    assert 'OPENCV_ARCHIVE_SHA256="b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9"' in text
    assert "codeload.github.com/opencv/opencv/tar.gz/refs/tags" in text


def test_build_disables_every_threading_backend() -> None:
    text = BASE.read_text(encoding="utf-8")
    for flag in ("-DWITH_TBB=OFF", "-DWITH_PTHREADS_PF=OFF", "-DWITH_OPENMP=OFF",
                 "-DWITH_IPP=OFF", "-DWITH_OPENCL=OFF", "-DOPENCV_SKIP_PYTHON_LOADER=ON",
                 "-DBUILD_LIST=core,imgproc,python3"):
        assert flag in text, flag


def test_every_shell_file_parses() -> None:
    for script in SHELL_FILES:
        result = subprocess.run(
            ["bash", "-n", str(script)], capture_output=True, text=True, check=False
        )
        assert result.returncode == 0, f"{script}: {result.stderr}"


def test_optimized_variant_fails_loudly(tmp_path: Path) -> None:
    environment = {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
        "PERF_RUN_ID": "test-run",
    }
    result = subprocess.run(
        ["bash", "--noprofile", "--norc", "-c", f"source {DISPATCH}; PERF_VARIANT=optimized; build_opencv"],
        env=environment,
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "not implemented" in result.stdout


# ---------------------------------------------------------------------------
# media manifest
# ---------------------------------------------------------------------------


def test_media_manifest_pins_three_videos_and_three_scenarios() -> None:
    document = manifest_document()
    assert document["resolution"] == "1920x1080"
    assert document["color_format"] == "gray8"
    assert document["calls_per_sample"] == 500
    assert document["native_threads"] == 1
    videos = document["videos"]
    assert set(videos) == {"BQTerrace", "Film2012", "messi"}
    for name, video in videos.items():
        assert video["filename"].endswith(".yuv"), name
        assert video["bytes"] == video["frames"] * 1920 * 1080 * 3 // 2, name
        for field in ("sha256", "frame0_sha256", "rgb_sha256"):
            assert re.fullmatch(r"[0-9a-f]{64}", video[field]), (name, field)
    scenarios = document["scenarios"]
    assert [scenario["name"] for scenario in scenarios] == [
        "BQTerrace_norm_l1_gray8", "Film2012_norm_l1_gray8", "messi_norm_l1_gray8",
    ]
    for scenario in scenarios:
        assert scenario["group"] == "图像处理"
        assert scenario["operation"] == "norm_l1_gray8"
        assert scenario["api"] == "cv2.norm(gray, cv2.NORM_L1)"
        assert scenario["video"] in videos


def test_manifest_digests_match_the_reference_material() -> None:
    videos = manifest_document()["videos"]
    assert videos["BQTerrace"]["filename"] == "BQTerrace_1920x1080_60.yuv"
    assert videos["BQTerrace"]["frame0_sha256"] == "40454da92d6bcd66757a280d0ed89f8d53bb4cadd27d6fb0e158f07f8bcd537f"
    assert videos["BQTerrace"]["rgb_sha256"] == "65cbb4131d78152b2a8b9a326b1b7f8822f2eb137e4641866d9430f1485f9def"
    assert videos["Film2012"]["frame0_sha256"] == "ac6f75f3f5e725f4e1589f94dfb5428c963a665bc1b1bbde4b499adc380bdb22"
    assert videos["messi"]["rgb_sha256"] == "31c0b0e13543cefe0f6d47f2c363ac639a8065bb2762226fe421c87568123a0a"


# ---------------------------------------------------------------------------
# harness and parser
# ---------------------------------------------------------------------------


def test_harness_imports_only_the_standard_library_at_module_level() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    modules = re.findall(r"^(?:import|from)\s+([a-zA-Z0-9_.]+)", text, re.MULTILINE)
    allowed = {
        "__future__", "argparse", "csv", "hashlib", "json", "os", "statistics", "sys",
        "time", "pathlib", "typings",
    }
    for module in modules:
        assert module.split(".")[0] in allowed, module


def test_harness_enforces_the_sampling_and_correctness_contract() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    assert "--warmups" in text and "--samples" in text and "--calls" in text
    assert "args.warmups < 1 or args.samples < 5 or args.calls < 1" in text
    assert "COMPLETE_MARKER" in text
    assert "cpu_pinning" in text and "memory_pinning" in text
    assert "cv2.norm does not match the reference sum" in text
    assert "cv2.norm result changed during the measurement" in text
    assert "setNumThreads" in text


def good_evidence(values: list[float]) -> dict:
    manifest = manifest_document()
    cases = {}
    for scenario in manifest["scenarios"]:
        video = manifest["videos"][scenario["video"]]
        cases[scenario["name"]] = {
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "samples_ms": list(values),
            "mean_ms": sum(values) / len(values),
            "median_ms": sorted(values)[len(values) // 2],
            "output": 1234567.0,
            "input_sha256": "c" * 64,
            "frame0_sha256": video["frame0_sha256"],
            "rgb_sha256": video["rgb_sha256"],
        }
    return {
        "version": "4.10.0",
        "build": BUILD_INFO,
        "source_mode": "unpatched",
        "cpus_allowed": 384,
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": 1,
        "warmups": 5,
        "samples": len(values),
        "calls_per_sample": CALLS,
        "statistic": "median",
        "cases": cases,
    }


def write_inputs(tmp_path: Path, evidence: dict, csv_value: str | None = None) -> tuple[Path, Path]:
    manifest = manifest_document()
    values = evidence["cases"][manifest["scenarios"][0]["name"]]["samples_ms"]
    value = csv_value if csv_value is not None else f"{sorted(values)[len(values) // 2]:.6f}"
    results = tmp_path / "results"
    results.mkdir()
    lines = ["scenario,iterations,ms_per_call,status"]
    for scenario in manifest["scenarios"]:
        lines.append(
            f"{scenario['name']},{evidence['calls_per_sample'] * evidence['samples']},{value},OK"
        )
    csv_path = results / "result_bench-opencv.csv"
    csv_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    evidence_path = results / "evidence.json"
    evidence_path.write_text(json.dumps(evidence), encoding="utf-8")
    return csv_path, evidence_path


def run_parser(tmp_path: Path, csv_path: Path, evidence_path: Path, samples: int = SAMPLES):
    output = tmp_path / "benchmark_opencv.json"
    result = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--csv", str(csv_path),
            "--evidence", str(evidence_path),
            "--manifest", str(MANIFEST),
            "--output", str(output),
            "--warmups", "5",
            "--samples", str(samples),
            "--calls", str(CALLS),
            "--version", "4.10.0",
            "--architecture", "x86_64",
            "--variant", "base",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    return result, output


def test_parser_accepts_a_contract_conforming_run(tmp_path: Path) -> None:
    evidence = good_evidence([0.5, 0.52, 0.48, 0.51, 0.49])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, output = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 0, result.stderr
    document = json.loads(output.read_text(encoding="utf-8"))
    assert document["software"] == "opencv"
    assert document["version"] == "4.10.0"
    assert document["parameters"]["cpu_pinning"] == "none"
    assert document["parameters"]["calls_per_sample"] == CALLS
    assert len(document["results"]) == 3
    for item in document["results"].values():
        assert item["value"] == pytest.approx(0.5)
        assert item["unit"] == "ms"
        assert item["direction"] == "lower_is_better"
        assert item["group"] == "图像处理"
        assert item["calls_per_sample"] == CALLS
        assert len(item["samples"]) == SAMPLES


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda item: item["cases"].pop("messi_norm_l1_gray8"), "expected"),
        (lambda item: item.update(cpu_pinning="taskset"), "pinning"),
        (lambda item: item.update(statistic="mean"), "statistic"),
        (lambda item: item.update(warmups=0), "warm-ups"),
        (lambda item: item.update(samples=7), "samples"),
        (lambda item: item.update(calls_per_sample=250), "calls per sample"),
        (lambda item: item.update(source_mode="patched"), "unpatched"),
        (lambda item: item.update(build="Parallel framework:            TBB"), "not none"),
        (lambda item: item["cases"]["Film2012_norm_l1_gray8"].update(samples_ms=[1.0]), "expected 5"),
        (lambda item: item["cases"]["Film2012_norm_l1_gray8"].update(frame0_sha256="0" * 64), "pinned frame"),
        (lambda item: item["cases"]["Film2012_norm_l1_gray8"].update(input_sha256="short"), "measured luma digest"),
        (lambda item: item["cases"]["Film2012_norm_l1_gray8"]["samples_ms"].__setitem__(1, 0.0), "positive"),
    ],
)
def test_parser_rejects_contract_violations(tmp_path: Path, mutate, message: str) -> None:
    evidence = good_evidence([0.5, 0.52, 0.48, 0.51, 0.49])
    mutate(evidence)
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert message in result.stderr


def test_parser_rejects_a_failed_status(tmp_path: Path) -> None:
    evidence = good_evidence([0.5, 0.52, 0.48, 0.51, 0.49])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(
        csv_path.read_text(encoding="utf-8").replace("Film2012_norm_l1_gray8,2500,0.500000,OK",
                                                     "Film2012_norm_l1_gray8,2500,,FAIL"),
        encoding="utf-8",
    )
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "status" in result.stderr


def test_parser_rejects_a_csv_that_disagrees_with_the_samples(tmp_path: Path) -> None:
    evidence = good_evidence([0.5, 0.52, 0.48, 0.51, 0.49])
    csv_path, evidence_path = write_inputs(tmp_path, evidence, csv_value="9.000000")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "disagrees" in result.stderr


def test_parser_rejects_a_short_sample_count_argument(tmp_path: Path) -> None:
    evidence = good_evidence([0.5, 0.52, 0.48, 0.51])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path, samples=4)
    assert result.returncode == 1
    assert "samples must be" in result.stderr


# ---------------------------------------------------------------------------
# standalone entry point
# ---------------------------------------------------------------------------


def test_standalone_help_and_unknown_option(tmp_path: Path) -> None:
    environment = {
        "PATH": "/usr/local/bin:/usr/bin:/bin",
        "PERF_WORK_DIR": str(tmp_path / "work"),
        "RESULTS_DIR": str(tmp_path / "results"),
    }
    help_result = subprocess.run(
        ["bash", str(STANDALONE), "--help"],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert help_result.returncode == 0
    assert "pinning" in help_result.stdout.lower()
    bad = subprocess.run(
        ["bash", str(STANDALONE), "--nope"],
        env=environment, capture_output=True, text=True, check=False,
    )
    assert bad.returncode == 10
