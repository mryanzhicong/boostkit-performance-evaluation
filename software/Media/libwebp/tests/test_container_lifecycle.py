"""Offline contract tests for the libwebp case.

They run without Docker, without a libwebp build and without the YUV archive, so
a silent regression in the container wiring, the sampling contract, the strict
parser or the case registration fails in a plain ``pytest`` run.
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
HARNESS = CASE_DIR / "scripts" / "harness" / "bench_decode.py"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
MANIFEST = CASE_DIR / "fixtures" / "media.json"
CASE_YAML = CASE_DIR / "case.yaml"
STANDALONE = CASE_DIR / "libwebp_test.sh"

SAMPLES = 5

PINNING_TOKENS = ("taskset", "numactl", "sched_setaffinity", "membind", "SchedSetaffinity")

SHELL_FILES = sorted(path for path in CASE_DIR.rglob("*.sh"))


def python_files() -> list[Path]:
    return sorted(CASE_DIR.rglob("*.py"))


def manifest_document() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


# ---------------------------------------------------------------------------
# case wiring
# ---------------------------------------------------------------------------


def test_case_declares_the_four_stages_and_timeout() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for stage in ("build", "start", "test", "stop"):
        assert re.search(rf"^\s{{4}}{stage}:\s*$", text, re.MULTILINE), stage
    assert "timeout_minutes: 600" in text
    assert "category: Media" in text
    assert '  - "1.2.1"' in text


def test_case_publishes_the_expected_outputs_and_metric() -> None:
    text = CASE_YAML.read_text(encoding="utf-8")
    for output in ("build_variant.json", "benchmark_decode.txt", "benchmark_libwebp.json",
                   "result_bench-libwebp.csv"):
        assert output in text
    assert "name_path: source_name" in text
    assert "value_path: value" in text
    assert "group_path: group" in text
    assert "subgroup_path: subgroup" in text
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
    assert any(line.strip() == "- libwebp" for line in media_block[:6]), (
        f"{REPO_ROOT / 'config' / 'categories.yaml'}: {media_block[:6]}"
    )
    for workflow in (
        ".github/workflows/performance-test-blue.yml",
        ".github/workflows/performance-test.yml",
        ".github/workflows/development-performance-test.yml",
        ".github/workflows/compare-existing-results.yml",
    ):
        text = (REPO_ROOT / workflow).read_text(encoding="utf-8")
        assert re.search(r"^\s*-\s*libwebp\s*$", text, re.MULTILINE), workflow


# ---------------------------------------------------------------------------
# container runtime block
# ---------------------------------------------------------------------------


def test_generated_container_block_is_present_and_complete() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "# >>> container-runtime:begin" in text
    assert "# >>> container-runtime:end" in text
    for function in (
        "require_libwebp_docker",
        "prepare_libwebp_container_image",
        "start_libwebp_container",
        "check_libwebp_container",
        "libwebp_container_exec",
        "remove_libwebp_container",
    ):
        assert re.search(rf"^[a-z_]*{function}\(\)", text, re.MULTILINE) or f"{function}()" in text, function


def test_container_block_mounts_read_only_media_and_labels_the_run() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "libwebp_media_mount_args()" in text
    assert 'target=${LIBWEBP_MEDIA_CONTAINER_DIR},readonly' in text
    assert "boostkit.libwebp.run-id" in text
    assert '--network host' in text or "--network=host" in text
    assert "LIBWEBP_CONTAINER_EXTRA_ARGS" in text


def test_no_cpu_or_memory_pinning_anywhere() -> None:
    for path in [COMMON, DISPATCH, BASE, OPTIMIZED, TEST_STAGE, HARNESS, PARSER, STANDALONE]:
        text = path.read_text(encoding="utf-8")
        for token in PINNING_TOKENS:
            assert token not in text, f"{path.name} must not contain {token}"


def test_sampling_defaults_match_the_reference_material() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert 'LIBWEBP_WARMUPS="${LIBWEBP_WARMUPS:-1}"' in text
    assert 'LIBWEBP_SAMPLES="${LIBWEBP_SAMPLES:-20}"' in text
    assert 'LIBWEBP_STATISTIC="median"' in text
    assert 'LIBWEBP_ARCHIVE_SHA256="808b98d2f5b84e9b27fdef6c5372dac769c3bda4502febbfa5031bd3c4d7d018"' in text


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
        [
            "bash",
            "--noprofile",
            "--norc",
            "-c",
            f"source {DISPATCH}; PERF_VARIANT=optimized; build_libwebp",
        ],
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


def test_media_manifest_pins_one_scenario_and_its_digests() -> None:
    document = manifest_document()
    assert document["resolution"] == "1920x1080"
    assert document["color_format"] == "I420_8bit"
    videos = document["videos"]
    assert len(videos) == 1
    video = videos["Film2012_1920x1080_25_8bit_8Mbps"]
    assert video["filename"] == "Film2012_1920x1080_25_8bit_8Mbps.yuv"
    assert video["bytes"] == 4665600000
    assert video["frames"] == 1500
    for field in ("sha256", "png_sha256", "webp_sha256", "decoded_pam_sha256", "rgb_frame0_sha256"):
        assert re.fullmatch(r"[0-9a-f]{64}", video[field]), field
    scenarios = document["scenarios"]
    assert len(scenarios) == 1
    scenario = scenarios[0]
    assert scenario["name"] == "Film2012_lossy_decode_pam_c2"
    assert scenario["native_threads"] == 2
    assert scenario["encoder_options"] == ["-q", "85", "-m", "4"]
    assert scenario["decoder_options"] == ["-mt", "-pam"]
    assert scenario["unit"] == "ms"
    assert scenario["direction"] == "lower_is_better"


def test_manifest_digests_match_the_reference_material() -> None:
    video = manifest_document()["videos"]["Film2012_1920x1080_25_8bit_8Mbps"]
    assert video["sha256"] == "27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc"
    assert video["png_sha256"] == "2274fd1b7c25e5c2cd1d4621211426fb5acb1d40ff75da2d5a37f8291a1c1c03"
    assert video["webp_sha256"] == "bda353b918d67e7071bc1e2753aa783b46cdec44e99110377b52a60e053b0930"
    assert video["decoded_pam_sha256"] == "1db78c8e0f0ae3208c129b00b9c3e8917e614958981de66b4b2071b9de04983a"


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


def test_harness_enforces_the_sampling_contract() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    assert "--warmups" in text and "--samples" in text
    assert "args.warmups < 1 or args.samples < 5" in text
    assert "COMPLETE_MARKER" in text
    assert "cpu_pinning" in text and "memory_pinning" in text
    assert "rgb_frame0_sha256" in text and "decoded_pam_sha256" in text


def good_evidence(manifest: dict, values: list[float]) -> dict:
    scenario = manifest["scenarios"][0]
    video = manifest["videos"][scenario["video"]]
    return {
        "scenario": scenario["name"],
        "group": scenario["group"],
        "subgroup": scenario["subgroup"],
        "samples_ms": values,
        "mean_ms": sum(values) / len(values),
        "median_ms": sorted(values)[len(values) // 2],
        "iterations": len(values),
        "warmups": 1,
        "statistic": "median",
        "cpus_allowed": 384,
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "observed_threads": 2,
        "source": {"file": video["filename"], "bytes": video["bytes"], "sha256": video["sha256"]},
        "png_sha256": video["png_sha256"],
        "webp_sha256": video["webp_sha256"],
        "decoded_pam_sha256": video["decoded_pam_sha256"],
    }


def write_inputs(tmp_path: Path, evidence: dict, csv_value: str | None = None) -> tuple[Path, Path]:
    manifest = manifest_document()
    scenario = manifest["scenarios"][0]
    values = evidence["samples_ms"]
    if csv_value is None:
        median = sorted(values)[len(values) // 2] if values else 0.0
        value = f"{median:.6f}"
    else:
        value = csv_value
    results = tmp_path / "results"
    results.mkdir()
    csv_path = results / "result_bench-libwebp.csv"
    csv_path.write_text(
        "scenario,iterations,ms_per_image,status\n"
        f"{scenario['name']},{evidence['iterations']},{value},OK\n",
        encoding="utf-8",
    )
    evidence_path = results / "evidence.json"
    evidence_path.write_text(json.dumps(evidence), encoding="utf-8")
    return csv_path, evidence_path


def run_parser(tmp_path: Path, csv_path: Path, evidence_path: Path, samples: int = SAMPLES):
    output = tmp_path / "benchmark_libwebp.json"
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
            "--version", "1.2.1",
            "--architecture", "x86_64",
            "--variant", "base",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    return result, output


def test_parser_accepts_a_contract_conforming_run(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [10.0, 10.2, 9.8, 10.1, 9.9])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, output = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 0, result.stderr
    document = json.loads(output.read_text(encoding="utf-8"))
    assert document["software"] == "libwebp"
    assert document["version"] == "1.2.1"
    assert document["architecture"] == "x86_64"
    assert document["parameters"]["cpu_pinning"] == "none"
    assert document["parameters"]["memory_pinning"] == "none"
    item = document["results"]["Film2012_lossy_decode_pam_c2"]
    assert item["value"] == pytest.approx(10.0)
    assert item["unit"] == "ms"
    assert item["direction"] == "lower_is_better"
    assert item["group"] == "RGB解码"
    assert item["subgroup"] == "Film2012"
    assert item["mean_ms"] == pytest.approx(10.0)
    assert len(item["samples"]) == SAMPLES


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda item: item.update(samples_ms=[]), "expected 5"),
        (lambda item: item["samples_ms"].__setitem__(1, 0.0), "must be positive"),
        (lambda item: item.update(cpu_pinning="taskset 0-1"), "pinning"),
        (lambda item: item.update(observed_threads=1), "threads"),
        (lambda item: item.update(statistic="mean"), "statistic"),
        (lambda item: item["source"].update(sha256="0" * 64), "sha256"),
        (lambda item: item.update(webp_sha256="0" * 64), "WebP"),
        (lambda item: item.update(warmups=0), "warm-ups"),
    ],
)
def test_parser_rejects_contract_violations(tmp_path: Path, mutate, message: str) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [10.0, 10.2, 9.8, 10.1, 9.9])
    mutate(evidence)
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert message in result.stderr


def test_parser_rejects_a_csv_that_disagrees_with_the_samples(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [10.0, 10.2, 9.8, 10.1, 9.9])
    csv_path, evidence_path = write_inputs(tmp_path, evidence, csv_value="12.345678")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "disagrees" in result.stderr


def test_parser_rejects_a_failed_status(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [10.0, 10.2, 9.8, 10.1, 9.9])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(
        csv_path.read_text(encoding="utf-8").replace(",OK", ",FAIL"), encoding="utf-8"
    )
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "status" in result.stderr


def test_parser_rejects_a_short_sample_count(tmp_path: Path) -> None:
    manifest = manifest_document()
    evidence = good_evidence(manifest, [10.0, 10.2, 9.8, 10.1, 9.9])
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path, samples=20)
    assert result.returncode == 1
    assert "expected 20" in result.stderr


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


def test_all_python_helpers_compile() -> None:
    for path in python_files():
        subprocess.run([sys.executable, "-m", "py_compile", str(path)], check=True)
        cache = path.parent / "__pycache__"
        if cache.is_dir():
            for entry in cache.iterdir():
                entry.unlink()
            cache.rmdir()
