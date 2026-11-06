"""Offline contract tests for the libavif case.

They run without Docker, without a libavif/AOM build and without the YUV
archive, so a silent regression in the container wiring, the sampling contract,
the strict parser or the case registration fails in a plain ``pytest`` run.
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
HARNESS = CASE_DIR / "scripts" / "harness" / "bench_encode.py"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
MANIFEST = CASE_DIR / "fixtures" / "media.json"
CASE_YAML = CASE_DIR / "case.yaml"
STANDALONE = CASE_DIR / "libavif_test.sh"

SAMPLES = 5

PINNING_TOKENS = ("taskset", "numactl", "sched_setaffinity", "membind", "SchedSetaffinity")

SHELL_FILES = sorted(path for path in CASE_DIR.rglob("*.sh"))


def manifest_document() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# case wiring
# ---------------------------------------------------------------------------


def test_case_declares_the_four_stages_and_timeout() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for stage in ("build", "start", "test", "stop"):
        assert re.search(rf"^\s{{4}}{stage}:\s*$", text, re.MULTILINE), stage
    assert "timeout_minutes: 900" in text
    assert "category: Media" in text
    assert '  - "0.9.3"' in text


def test_case_publishes_the_expected_outputs_and_metric() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for output in ("build_variant.json", "benchmark_encode.txt", "benchmark_libavif.json",
                   "result_bench-libavif.csv"):
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
    assert any(line.strip() == "- libavif" for line in media_block[:6]), media_block[:6]
    for workflow in (
        ".github/workflows/performance-test-blue.yml",
        ".github/workflows/performance-test.yml",
        ".github/workflows/development-performance-test.yml",
        ".github/workflows/compare-existing-results.yml",
    ):
        text = (REPO_ROOT / workflow).read_text(encoding="utf-8")
        assert re.search(r"^\s*-\s*libavif\s*$", text, re.MULTILINE), workflow


# ---------------------------------------------------------------------------
# container runtime block
# ---------------------------------------------------------------------------


def test_generated_container_block_is_present_and_complete() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "# >>> container-runtime:begin" in text
    assert "# >>> container-runtime:end" in text
    for function in (
        "require_libavif_docker",
        "prepare_libavif_container_image",
        "start_libavif_container",
        "check_libavif_container",
        "libavif_container_exec",
        "remove_libavif_container",
    ):
        assert f"{function}()" in text, function


def test_container_block_mounts_read_only_media_and_labels_the_run() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "libavif_media_mount_args()" in text
    assert 'target=${LIBAVIF_MEDIA_CONTAINER_DIR},readonly' in text
    assert "boostkit.libavif.run-id" in text
    assert "--network=host" in text
    assert "LIBAVIF_CONTAINER_EXTRA_ARGS" in text


def test_no_cpu_or_memory_pinning_anywhere() -> None:
    for path in [COMMON, DISPATCH, BASE, OPTIMIZED, TEST_STAGE, HARNESS, PARSER, STANDALONE]:
        text = path.read_text(encoding="utf-8")
        for token in PINNING_TOKENS:
            assert token not in text, f"{path.name} must not contain {token}"


def test_sampling_defaults_and_pinned_archives() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert 'LIBAVIF_WARMUPS="${LIBAVIF_WARMUPS:-1}"' in text
    assert 'LIBAVIF_SAMPLES="${LIBAVIF_SAMPLES:-20}"' in text
    assert 'LIBAVIF_STATISTIC="median"' in text
    assert 'LIBAVIF_ARCHIVE_SHA256="bcd9a1f57f982a9615eb7e2faf87236dc88eb1d0c886f3471c7440ead605060d"' in text
    assert 'AOM_ARCHIVE_SHA256="34132ae827c469a223fe5fbb0e42ac342539649cf2b97764c9912d7333d79169"' in text
    assert "gitcode.com/boostkit/libavif.git" in text


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
        ["bash", "--noprofile", "--norc", "-c", f"source {DISPATCH}; PERF_VARIANT=optimized; build_libavif"],
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


def test_media_manifest_pins_three_videos_and_six_scenarios() -> None:
    document = manifest_document()
    assert document["resolution"] == "1920x1080"
    assert document["codec"] == "aom 3.2.0"
    assert document["native_threads"] == 8
    videos = document["videos"]
    assert set(videos) == {"BQTerrace", "Film2012", "messi"}
    for name, video in videos.items():
        assert video["filename"].endswith(".yuv"), name
        assert video["bytes"] == video["frames"] * 1920 * 1080 * 3 // 2, name
        for field in ("sha256", "png_sha256"):
            assert re.fullmatch(r"[0-9a-f]{64}", video[field]), (name, field)
    scenarios = document["scenarios"]
    assert len(scenarios) == 6
    assert [scenario["name"] for scenario in scenarios] == [
        "BQTerrace_qp20_c8", "BQTerrace_qp32_c8",
        "Film2012_qp20_c8", "Film2012_qp32_c8",
        "messi_qp20_c8", "messi_qp32_c8",
    ]
    for scenario in scenarios:
        assert scenario["qp"] in (20, 32)
        assert scenario["group"] == "AV1编码"
        assert scenario["video"] in videos
    assert document["encoder_options"][:6] == ["--codec", "aom", "--yuv", "420", "--speed", "8"]
    assert "--tilecolslog2" in document["encoder_options"]


def test_manifest_digests_match_the_reference_material() -> None:
    videos = manifest_document()["videos"]
    assert videos["BQTerrace"]["filename"] == "BQTerrace_1920x1080_60.yuv"
    assert videos["BQTerrace"]["sha256"] == "5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7"
    assert videos["BQTerrace"]["png_sha256"] == "876ed491d59c60994e6720de409b58dc320c7f1e4df4849ebdc1af5d94e9adb9"
    assert videos["Film2012"]["png_sha256"] == "2274fd1b7c25e5c2cd1d4621211426fb5acb1d40ff75da2d5a37f8291a1c1c03"
    assert videos["messi"]["png_sha256"] == "1933cba6ba825d6b3b217614e3d4bfdcb98d36cebe5586e1865ccf94f072d068"


# ---------------------------------------------------------------------------
# harness and parser
# ---------------------------------------------------------------------------


def test_harness_imports_only_the_standard_library() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    modules = re.findall(r"^(?:import|from)\s+([a-zA-Z0-9_.]+)", text, re.MULTILINE)
    allowed = {
        "__future__", "argparse", "binascii", "csv", "hashlib", "json", "os", "statistics",
        "struct", "subprocess", "sys", "time", "zlib", "pathlib", "typings", "datetime",
    }
    for module in modules:
        assert module.split(".")[0] in allowed, module


def test_harness_enforces_the_sampling_and_correctness_contract() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    assert "--warmups" in text and "--samples" in text
    assert "args.warmups < 1 or args.samples < 5" in text
    assert "COMPLETE_MARKER" in text
    assert "cpu_pinning" in text and "memory_pinning" in text
    assert "repeated encoding output differs" in text
    assert "repeated decoded pixels differ" in text
    assert "observed_threads" in text


def good_evidence(manifest: dict, values: list[float]) -> dict:
    cases = {}
    for scenario in manifest["scenarios"]:
        cases[scenario["name"]] = {
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "qp": scenario["qp"],
            "samples_ms": list(values),
            "mean_ms": sum(values) / len(values),
            "median_ms": sorted(values)[len(values) // 2],
            "encoded_sha256": "a" * 64,
            "decoded_yuv_sha256": "b" * 64,
            "observed_threads": 8,
        }
    return {
        "cpus_allowed": 384,
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": 8,
        "warmups": 1,
        "samples": len(values),
        "statistic": "median",
        "source_mode": "unpatched",
        "cases": cases,
    }


def write_inputs(tmp_path: Path, evidence: dict, csv_value: str | None = None) -> tuple[Path, Path]:
    manifest = manifest_document()
    values = evidence["cases"][manifest["scenarios"][0]["name"]]["samples_ms"]
    value = csv_value if csv_value is not None else f"{sorted(values)[len(values) // 2]:.6f}"
    results = tmp_path / "results"
    results.mkdir()
    lines = ["scenario,iterations,ms_per_image,status"]
    for scenario in manifest["scenarios"]:
        lines.append(f"{scenario['name']},{evidence['samples']},{value},OK")
    csv_path = results / "result_bench-libavif.csv"
    csv_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    evidence_path = results / "evidence.json"
    evidence_path.write_text(json.dumps(evidence), encoding="utf-8")
    return csv_path, evidence_path


def run_parser(tmp_path: Path, csv_path: Path, evidence_path: Path, samples: int = SAMPLES):
    output = tmp_path / "benchmark_libavif.json"
    result = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--csv", str(csv_path),
            "--evidence", str(evidence_path),
            "--manifest", str(MANIFEST),
            "--output", str(output),
            "--warmups", "1",
            "--samples", str(samples),
            "--version", "0.9.3",
            "--architecture", "aarch64",
            "--variant", "base",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    return result, output


def test_parser_accepts_a_contract_conforming_run(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [150.0, 152.0, 148.0, 151.0, 149.0])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, output = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 0, result.stderr
    document = json.loads(output.read_text(encoding="utf-8"))
    assert document["software"] == "libavif"
    assert document["version"] == "0.9.3"
    assert document["architecture"] == "aarch64"
    assert document["parameters"]["cpu_pinning"] == "none"
    assert len(document["results"]) == 6
    for name, item in document["results"].items():
        assert item["value"] == pytest.approx(150.0)
        assert item["unit"] == "ms"
        assert item["direction"] == "lower_is_better"
        assert item["group"] == "AV1编码"
        assert len(item["samples"]) == SAMPLES


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda item: item["cases"].pop("messi_qp32_c8"), "expected"),
        (lambda item: item.update(cpu_pinning="numactl --membind=3"), "pinning"),
        (lambda item: item.update(statistic="mean"), "statistic"),
        (lambda item: item.update(warmups=0), "warm-ups"),
        (lambda item: item["cases"]["Film2012_qp20_c8"].update(observed_threads=4), "threads"),
        (lambda item: item["cases"]["Film2012_qp20_c8"].update(samples_ms=[1.0]), "expected 5"),
        (lambda item: item["cases"]["Film2012_qp20_c8"].update(encoded_sha256="short"), "sha256"),
        (lambda item: item["cases"]["Film2012_qp20_c8"]["samples_ms"].__setitem__(2, 0.0), "positive"),
    ],
)
def test_parser_rejects_contract_violations(tmp_path: Path, mutate, message: str) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [150.0, 152.0, 148.0, 151.0, 149.0])
    mutate(evidence)
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert message in result.stderr


def test_parser_rejects_a_failed_status_and_a_short_sample_count(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [150.0, 152.0, 148.0, 151.0, 149.0])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(
        csv_path.read_text(encoding="utf-8").replace("Film2012_qp20_c8,5,150.000000,OK",
                                                     "Film2012_qp20_c8,5,,FAIL"),
        encoding="utf-8",
    )
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "status" in result.stderr


def test_parser_rejects_a_csv_that_disagrees_with_the_samples(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [150.0, 152.0, 148.0, 151.0, 149.0])
    csv_path, evidence_path = write_inputs(tmp_path, evidence, csv_value="999.000000")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "disagrees" in result.stderr


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
