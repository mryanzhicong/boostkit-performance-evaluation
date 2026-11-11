"""Offline contract tests for the libwebp lossless encode case.

They run without Docker, without a libwebp build and without any media archive,
so a silent regression in the container wiring, the generated inputs, the
sampling contract, the strict parser or the case registration fails in a plain
``pytest`` run.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
import math
import os
import re
import struct
import subprocess
import sys
import zlib
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
REPO_ROOT = CASE_DIR.parents[2]
COMMON = CASE_DIR / "scripts" / "common.sh"
DISPATCH = CASE_DIR / "scripts" / "builders" / "dispatch.sh"
BASE = CASE_DIR / "scripts" / "builders" / "base.sh"
OPTIMIZED = CASE_DIR / "scripts" / "builders" / "optimized.sh"
START_STAGE = CASE_DIR / "scripts" / "stages" / "start.sh"
TEST_STAGE = CASE_DIR / "scripts" / "stages" / "test.sh"
GENERATOR = CASE_DIR / "scripts" / "harness" / "generate_inputs.py"
HARNESS = CASE_DIR / "scripts" / "harness" / "bench_encode.py"
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
MANIFEST = CASE_DIR / "fixtures" / "media.json"
CASE_YAML = CASE_DIR / "case.yaml"
README = CASE_DIR / "README.md"
STANDALONE = CASE_DIR / "libwebp_test.sh"

SAMPLES = 5
SCENARIO_NAMES = ["dashboard_lossless_z0", "dashboard_720p_lossless_z0"]
FIRST = SCENARIO_NAMES[0]
SECOND = SCENARIO_NAMES[1]

# Built dynamically so a whole-directory grep for a retired token does not match
# this test file itself.
MEDIA_VARIABLE_TOKEN = "LIBWEBP_" + "MEDIA"
RETIRED_MEDIA_TOKEN = "Film" + "2012"
RETIRED_LOG_TOKEN = "benchmark_" + "decode"

PINNING_TOKENS = ("taskset", "numactl", "sched_setaffinity", "membind", "SchedSetaffinity")

SHELL_FILES = sorted(path for path in CASE_DIR.rglob("*.sh"))
CODE_FILES = [COMMON, DISPATCH, BASE, OPTIMIZED, START_STAGE, TEST_STAGE, GENERATOR, HARNESS, PARSER, STANDALONE]


def python_files() -> list[Path]:
    return sorted(path for path in CASE_DIR.rglob("*.py") if "__pycache__" not in path.parts)


def manifest_document() -> dict:
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_generator_module():
    spec = importlib.util.spec_from_file_location("libwebp_generate_inputs", GENERATOR)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def read_png_rgba(path: Path) -> tuple[int, int, bytes]:
    """Minimal PNG reader for the generator's 8-bit RGBA/filter-0 output."""
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n", f"{path} is not a PNG"
    offset = 8
    compressed = bytearray()
    width = height = depth = color = None
    while offset < len(data):
        (length,) = struct.unpack(">I", data[offset : offset + 4])
        kind = data[offset + 4 : offset + 8]
        payload = data[offset + 8 : offset + 8 + length]
        offset += length + 12
        if kind == b"IHDR":
            width, height, depth, color = struct.unpack(">IIBB", payload[:10])
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            break
    assert width and height and depth == 8 and color == 6, (width, height, depth, color)
    raw = zlib.decompress(bytes(compressed))
    stride = width * 4
    assert len(raw) == height * (stride + 1), "unexpected scanline layout"
    pixels = bytearray()
    for y in range(height):
        start = y * (stride + 1)
        assert raw[start] == 0, "generator must emit filter type 0"
        pixels.extend(raw[start + 1 : start + 1 + stride])
    return width, height, bytes(pixels)


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
    for output in ("build_variant.json", "benchmark_encode.txt", "benchmark_libwebp.json",
                   "result_bench-libwebp.csv"):
        assert output in text, output
    assert RETIRED_LOG_TOKEN + ".txt" not in text
    assert "name_path: source_name" in text
    assert "value_path: value" in text
    assert "group_path: group" in text
    assert "subgroup_path: subgroup" in text
    assert "unit: ms" in text
    assert "direction: lower_is_better" in text


def test_case_tree_is_complete() -> None:
    for path in (
        CASE_YAML,
        README,
        STANDALONE,
        MANIFEST,
        COMMON,
        DISPATCH,
        BASE,
        OPTIMIZED,
        START_STAGE,
        TEST_STAGE,
        CASE_DIR / "scripts" / "stages" / "stop.sh",
        GENERATOR,
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
# container runtime block and retired media plumbing
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


def test_container_wiring_has_no_media_mount_and_labels_the_run() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert "libwebp_media_mount_args" not in text
    assert "libwebp_resolve_media" not in text
    assert "libwebp_media_probe" not in text
    assert "/media-input" not in text
    assert MEDIA_VARIABLE_TOKEN not in text
    assert "boostkit.libwebp.run-id" in text
    assert "--network=host" in text
    assert "LIBWEBP_CONTAINER_EXTRA_ARGS" in text


def test_no_media_plumbing_remains_anywhere_in_the_case() -> None:
    for path in CASE_DIR.rglob("*"):
        if not path.is_file() or "__pycache__" in path.parts:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        assert MEDIA_VARIABLE_TOKEN not in text, path
        assert RETIRED_MEDIA_TOKEN not in text, path
        assert RETIRED_LOG_TOKEN not in text, path


def test_no_cpu_or_memory_pinning_anywhere() -> None:
    for path in CODE_FILES:
        text = path.read_text(encoding="utf-8")
        for token in PINNING_TOKENS:
            assert token not in text, f"{path.name} must not contain {token}"


def test_sampling_defaults_match_the_reference_material() -> None:
    text = COMMON.read_text(encoding="utf-8")
    assert 'LIBWEBP_WARMUPS="${LIBWEBP_WARMUPS:-1}"' in text
    assert 'LIBWEBP_SAMPLES="${LIBWEBP_SAMPLES:-20}"' in text
    assert 'LIBWEBP_STATISTIC="mean"' in text
    assert 'LIBWEBP_LOG="${RESULTS_DIR}/benchmark_encode.txt"' in text
    assert 'LIBWEBP_ARCHIVE_SHA256="808b98d2f5b84e9b27fdef6c5372dac769c3bda4502febbfa5031bd3c4d7d018"' in text


def test_container_dependencies_include_the_png_headers() -> None:
    text = COMMON.read_text(encoding="utf-8")
    deps_block = text.split("LIBWEBP_CONTAINER_DEPS=(", 1)[1].split(")", 1)[0]
    for package in (
        "gcc", "gcc-c++", "make", "cmake", "tar", "curl", "python3",
        "libpng-devel", "libjpeg-turbo-devel", "zlib-devel",
    ):
        assert re.search(rf"(?<![\w-]){re.escape(package)}(?![\w-])", deps_block), package
    assert "nasm" in text  # x86_64 SIMD assembler, same as the reference build


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
# scenario manifest
# ---------------------------------------------------------------------------


def test_manifest_declares_the_two_lossless_encode_scenarios() -> None:
    document = manifest_document()
    assert document["benchmark"] == "libwebp_1.2.1_lossless_encode"
    assert isinstance(document["generator"], str) and "generate_inputs.py" in document["generator"]
    for retired in ("videos", "media_directory", "media_override_env"):
        assert retired not in document, retired
    notes = " ".join(document["notes"])
    assert "sha256" in notes and "生成" in notes
    scenarios = document["scenarios"]
    assert [scenario["name"] for scenario in scenarios] == SCENARIO_NAMES
    expected_geometry = {"dashboard_lossless_z0": (1920, 1080), "dashboard_720p_lossless_z0": (1280, 720)}
    for scenario in scenarios:
        assert (scenario["width"], scenario["height"]) == expected_geometry[scenario["name"]]
        assert scenario["group"] == "无损编码"
        assert scenario["subgroup"] == "dashboard"
        assert scenario["encoder_options"] == ["-lossless", "-z", "0", "-exact", "-mt"]
        assert scenario["native_threads"] == 1
        assert scenario["unit"] == "ms"
        assert scenario["direction"] == "lower_is_better"
        assert "1 次预热" in scenario["description"] and "均值" in scenario["description"]


def test_manifest_carries_no_fixed_image_digests() -> None:
    text = MANIFEST.read_text(encoding="utf-8")
    assert not re.search(r"[0-9a-f]{64}", text), "the new method records digests in evidence only"


# ---------------------------------------------------------------------------
# generated inputs
# ---------------------------------------------------------------------------


def test_generator_is_ported_from_the_reference_and_takes_a_work_dir() -> None:
    text = GENERATOR.read_text(encoding="utf-8")
    for symbol in ("generate_ui", "resized_ui", "prepare_inputs", "zlib.compress(scan, 6)",
                   "struct.pack(\">IIBBBBB\", w, h, 8, 6, 0, 0, 0)", "1920", "1080", "1280", "720"):
        assert symbol in text, symbol
    assert "def prepare_inputs(work_dir)" in text
    assert '".work"' not in text


def test_generator_writes_the_reference_dashboard_pair(tmp_path: Path) -> None:
    module = load_generator_module()
    images = module.prepare_inputs(tmp_path / "inputs")
    assert [image["name"] for image in images] == SCENARIO_NAMES
    assert [(image["width"], image["height"]) for image in images] == [(1920, 1080), (1280, 720)]
    assert all(Path(image["path"]).is_file() for image in images)

    width, height, pixels = read_png_rgba(Path(images[0]["path"]))
    assert (width, height) == (1920, 1080)
    assert len(pixels) == 1920 * 1080 * 4
    small_width, small_height, small_pixels = read_png_rgba(Path(images[1]["path"]))
    assert (small_width, small_height) == (1280, 720)
    assert len(small_pixels) == 1280 * 720 * 4

    # 1280x720 must be the nearest-neighbour downscale of the 1080p dashboard.
    for y in (0, 1, 359, 719):
        source_y = y * 1080 // 720
        for x in (0, 1, 319, 640, 959, 1279):
            source_x = x * 1920 // 1280
            expected = pixels[(source_y * 1920 + source_x) * 4 : (source_y * 1920 + source_x) * 4 + 4]
            actual = small_pixels[(y * 1280 + x) * 4 : (y * 1280 + x) * 4 + 4]
            assert actual == expected, (x, y)

    # Generation is deterministic, so evidence digests are stable within a run.
    second = module.prepare_inputs(tmp_path / "inputs-again")
    for first_image, second_image in zip(images, second):
        assert hashlib.sha256(Path(first_image["path"]).read_bytes()).hexdigest() == hashlib.sha256(
            Path(second_image["path"]).read_bytes()
        ).hexdigest()


# ---------------------------------------------------------------------------
# harness
# ---------------------------------------------------------------------------


def test_harness_imports_only_the_standard_library_and_the_generator() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    modules = re.findall(r"^(?:import|from)\s+([a-zA-Z0-9_.]+)", text, re.MULTILINE)
    allowed = {
        "__future__", "argparse", "csv", "json", "os", "statistics", "subprocess", "sys",
        "time", "pathlib", "generate_inputs", "typings",
    }
    for module in modules:
        assert module.split(".")[0] in allowed, module


def test_harness_keeps_the_reference_command_and_sampling_contract() -> None:
    text = HARNESS.read_text(encoding="utf-8")
    assert "--install-dir" in text and "--work-dir" in text and "--results-dir" in text
    assert "--runs-dir" in text and "--manifest" in text
    assert "--warmups" in text and "--samples" in text
    assert "--media-dir" not in text
    assert "args.warmups < 1 or args.samples < MIN_SAMPLES" in text
    assert "COMPLETE_MARKER" in text
    assert "LIBWEBP_BENCH_COMPLETE" in text
    # The measured command is built from the manifest, leaving cwebp/dwebp
    # invocations identical to the reference bench.py.
    assert '*scenario["encoder_options"]' in text
    assert '"-quiet"' in text and '"-o"' in text
    assert '"-pam"' in text and '"decode_check_command"' in text
    assert "width * height * 4" in text
    assert "statistics.mean" in text
    assert '"statistic": "mean"' in text
    assert "cpu_pinning" in text and "memory_pinning" in text
    assert "sched_getaffinity" in text
    assert "input_sha256" in text and "output_sha256" in text
    assert 'runs_dir / name' in text


def write_fake_tool(path: Path, body: str) -> None:
    path.write_text("#!/usr/bin/env bash\nset -eu\n" + body, encoding="utf-8")
    path.chmod(0o755)


def prepare_fake_install(tmp_path: Path) -> Path:
    install = tmp_path / "install"
    (install / "bin").mkdir(parents=True)
    write_fake_tool(
        install / "bin" / "cwebp",
        'out="${@: -1}"\nprintf "fake-webp-bytes" > "${out}"\n',
    )
    write_fake_tool(
        install / "bin" / "dwebp",
        (
            'out="${@: -1}"\n'
            'case "${out}" in\n'
            "  *dashboard_720p*) pixels=$((1280 * 720 * 4)) ;;\n"
            "  *) pixels=$((1920 * 1080 * 4)) ;;\n"
            "esac\n"
            "printf 'P7\\nWIDTH 1920\\nHEIGHT 1080\\nDEPTH 4\\nMAXVAL 255\\nTUPLTYPE RGB_ALPHA\\nENDHDR\\n' > \"${out}\"\n"
            'head -c "${pixels}" /dev/zero >> "${out}"\n'
        ),
    )
    return install


def test_harness_produces_reference_csv_evidence_and_raw_samples(tmp_path: Path) -> None:
    install = prepare_fake_install(tmp_path)
    results = tmp_path / "results"
    command = [
        sys.executable,
        str(HARNESS),
        "--install-dir", str(install),
        "--work-dir", str(tmp_path / "work"),
        "--results-dir", str(results),
        "--runs-dir", str(results / "runs"),
        "--manifest", str(MANIFEST),
        "--warmups", "1",
        "--samples", str(SAMPLES),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stderr
    assert "LIBWEBP_BENCH_COMPLETE" in result.stdout
    assert "ms/image" in result.stdout

    csv_lines = (results / "result_bench-libwebp.csv").read_text(encoding="utf-8").splitlines()
    assert csv_lines[0] == "scenario,iterations,ms_per_image,status"
    assert len(csv_lines) == 3
    rows = [line.split(",") for line in csv_lines[1:]]
    assert [row[0] for row in rows] == SCENARIO_NAMES
    assert all(row[1] == str(SAMPLES) and row[3] == "OK" for row in rows)

    evidence = json.loads((results / "evidence.json").read_text(encoding="utf-8"))
    assert evidence["scenario_order"] == SCENARIO_NAMES
    assert list(evidence["cases"]) == SCENARIO_NAMES
    assert evidence["statistic"] == "mean"
    assert evidence["warmups"] == 1
    assert evidence["iterations"] == SAMPLES
    assert evidence["affinity"] == "unbound"
    assert evidence["cpu_pinning"] == "none"
    assert evidence["memory_pinning"] == "none"
    assert evidence["native_threads"] == 1
    assert evidence["cpus_allowed"] >= 1
    for name, row in zip(SCENARIO_NAMES, rows):
        case = evidence["cases"][name]
        assert case["status"] == "OK"
        assert case["iterations"] == SAMPLES
        assert len(case["samples_ms"]) == SAMPLES
        assert all(math.isfinite(value) and value > 0 for value in case["samples_ms"])
        assert float(row[2]) == pytest.approx(sum(case["samples_ms"]) / SAMPLES, abs=1e-6)
        assert case["input_sha256"] == sha256_bytes(Path(evidence["inputs"][name]["path"]).read_bytes())
        assert case["output_sha256"] == sha256_bytes(b"fake-webp-bytes")
        for index in range(1, SAMPLES + 1):
            sample = json.loads((results / "runs" / name / f"rep{index}.json").read_text(encoding="utf-8"))
            assert sample["scenario"] == name and sample["rep"] == index
            assert sample["ms"] == case["samples_ms"][index - 1]


def test_harness_rejects_a_short_sample_count(tmp_path: Path) -> None:
    install = prepare_fake_install(tmp_path)
    result = subprocess.run(
        [
            sys.executable,
            str(HARNESS),
            "--install-dir", str(install),
            "--work-dir", str(tmp_path / "work"),
            "--results-dir", str(tmp_path / "results"),
            "--runs-dir", str(tmp_path / "results" / "runs"),
            "--manifest", str(MANIFEST),
            "--samples", "4",
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 1
    assert "sampling contract" in result.stderr


def test_harness_reports_missing_binaries(tmp_path: Path) -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert manifest["scenarios"]
    result = subprocess.run(
        [
            sys.executable,
            str(HARNESS),
            "--install-dir", str(tmp_path / "empty-install"),
            "--work-dir", str(tmp_path / "work"),
            "--results-dir", str(tmp_path / "results"),
            "--runs-dir", str(tmp_path / "results" / "runs"),
            "--manifest", str(MANIFEST),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 1
    assert "binary is missing" in result.stderr


def test_harness_rejects_a_decoded_size_mismatch(tmp_path: Path) -> None:
    install = tmp_path / "install"
    (install / "bin").mkdir(parents=True)
    write_fake_tool(install / "bin" / "cwebp", 'out="${@: -1}"\nprintf "fake" > "${out}"\n')
    # The decoder always claims a single pixel, so the reference size check fails.
    write_fake_tool(
        install / "bin" / "dwebp",
        'out="${@: -1}"\nprintf \'P7\\nENDHDR\\nXXXX\' > "${out}"\n',
    )
    result = subprocess.run(
        [
            sys.executable,
            str(HARNESS),
            "--install-dir", str(install),
            "--work-dir", str(tmp_path / "work"),
            "--results-dir", str(tmp_path / "results"),
            "--runs-dir", str(tmp_path / "results" / "runs"),
            "--manifest", str(MANIFEST),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 1
    assert "decoded image size is incorrect" in result.stderr


# ---------------------------------------------------------------------------
# parser
# ---------------------------------------------------------------------------


def good_evidence(values: list[float] | None = None) -> dict:
    manifest = manifest_document()
    samples = list(values) if values is not None else [10.0, 10.2, 9.8, 10.1, 9.9]
    cases = {}
    inputs = {}
    for scenario in manifest["scenarios"]:
        name = scenario["name"]
        inputs[name] = {
            "path": f"work/{name}.png",
            "width": scenario["width"],
            "height": scenario["height"],
            "sha256": "1" * 64,
        }
        cases[name] = {
            "name": name,
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "width": scenario["width"],
            "height": scenario["height"],
            "unit": "ms",
            "direction": "lower_is_better",
            "native_threads": 1,
            "input_sha256": "2" * 64,
            "output_sha256": "3" * 64,
            "samples_ms": list(samples),
            "mean_ms": sum(samples) / len(samples),
            "iterations": len(samples),
            "statistic": "mean",
            "command": ["cwebp", "-quiet", "-lossless", "-z", "0", "-exact", "-mt", "in.png", "-o", "out.webp"],
            "decode_check_command": ["dwebp", "out.webp", "-quiet", "-pam", "-o", "out.pam"],
            "status": "OK",
        }
    return {
        "benchmark": manifest["benchmark"],
        "source_mode": "unpatched",
        "affinity": "unbound",
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": 1,
        "statistic": "mean",
        "warmups": 1,
        "iterations": len(samples),
        "cpus_allowed": 64,
        "scenario_order": [scenario["name"] for scenario in manifest["scenarios"]],
        "inputs": inputs,
        "cases": cases,
    }


def average_of(samples: list) -> float:
    try:
        return sum(float(value) for value in samples) / len(samples)
    except (TypeError, ValueError, ZeroDivisionError):
        return 0.0


def write_inputs(
    tmp_path: Path,
    evidence: dict,
    csv_values: dict[str, str] | None = None,
) -> tuple[Path, Path]:
    manifest = manifest_document()
    results = tmp_path / "results"
    results.mkdir(exist_ok=True)
    lines = ["scenario,iterations,ms_per_image,status"]
    for scenario in manifest["scenarios"]:
        name = scenario["name"]
        case = evidence["cases"].get(name, {})
        samples = case.get("samples_ms") or []
        value = (
            csv_values[name]
            if csv_values and name in csv_values
            else f"{average_of(samples):.6f}"
        )
        iterations = case.get("iterations", len(samples) if samples else 0)
        lines.append(f"{name},{iterations},{value},OK")
    csv_path = results / "result_bench-libwebp.csv"
    csv_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    evidence_path = results / "evidence.json"
    evidence_path.write_text(json.dumps(evidence), encoding="utf-8")
    return csv_path, evidence_path


def run_parser(
    tmp_path: Path,
    csv_path: Path,
    evidence_path: Path,
    samples: int = SAMPLES,
    manifest_path: Path | None = None,
):
    output = tmp_path / "benchmark_libwebp.json"
    result = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--csv", str(csv_path),
            "--evidence", str(evidence_path),
            "--manifest", str(manifest_path or MANIFEST),
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
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, output = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 0, result.stderr
    document = json.loads(output.read_text(encoding="utf-8"))
    assert document["benchmark"] == "libwebp_1.2.1_lossless_encode"
    assert document["software"] == "libwebp"
    assert document["version"] == "1.2.1"
    assert document["architecture"] == "x86_64"
    assert document["variant"] == "base"
    assert document["parameters"]["statistic"] == "mean"
    assert document["parameters"]["cpu_pinning"] == "none"
    assert document["parameters"]["memory_pinning"] == "none"
    assert list(document["results"]) == SCENARIO_NAMES
    expected_mean = sum([10.0, 10.2, 9.8, 10.1, 9.9]) / SAMPLES
    for name, scenario in zip(SCENARIO_NAMES, manifest_document()["scenarios"]):
        item = document["results"][name]
        assert item["source_name"] == name
        assert item["value"] == pytest.approx(expected_mean)
        assert item["unit"] == "ms"
        assert item["direction"] == "lower_is_better"
        assert item["group"] == scenario["group"]
        assert item["subgroup"] == scenario["subgroup"]
        assert item["statistic"] == "mean"
        assert len(item["samples"]) == SAMPLES
        assert item["width"] == scenario["width"] and item["height"] == scenario["height"]


@pytest.mark.parametrize(
    ("mutate", "message"),
    [
        (lambda ev: ev["cases"][FIRST].update(samples_ms=[]), "expected 5"),
        (lambda ev: ev["cases"][FIRST]["samples_ms"].__setitem__(1, 0.0), "must be positive"),
        (lambda ev: ev["cases"][FIRST]["samples_ms"].__setitem__(0, None), "not numeric"),
        (lambda ev: ev["cases"][FIRST]["samples_ms"].__setitem__(0, float("inf")), "must be finite"),
        (lambda ev: ev["cases"][FIRST].update(statistic="median"), "statistic is not 'mean'"),
        (lambda ev: ev["cases"][FIRST].update(status="FAIL"), "status is not 'OK'"),
        (lambda ev: ev["cases"][FIRST].update(input_sha256="0" * 63), "input_sha256"),
        (lambda ev: ev["cases"][FIRST].update(group="有损编码"), "group"),
        (lambda ev: ev.update(cpu_pinning="taskset 0-1"), "pinning"),
        (lambda ev: ev.update(memory_pinning="numactl --membind 0"), "pinning"),
        (lambda ev: ev.update(cpus_allowed=0), "allowed CPU set"),
        (lambda ev: ev.update(statistic="median"), "evidence statistic"),
        (lambda ev: ev.update(warmups=0), "warm-ups"),
        (lambda ev: ev.update(iterations=20), "iterations disagree"),
        (lambda ev: ev.update(scenario_order=list(reversed(ev["scenario_order"]))), "scenario order"),
        (
            lambda ev: ev.update(cases={name: ev["cases"][name] for name in reversed(SCENARIO_NAMES)}),
            "evidence cases",
        ),
    ],
)
def test_parser_rejects_contract_violations(tmp_path: Path, mutate, message: str) -> None:
    evidence = good_evidence()
    mutate(evidence)
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert message in result.stderr


def test_parser_rejects_a_csv_that_disagrees_with_the_samples(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(
        tmp_path, evidence, csv_values={FIRST: "12.345678", SECOND: "12.345678"}
    )
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "disagrees" in result.stderr


def test_parser_rejects_a_failed_status(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(csv_path.read_text(encoding="utf-8").replace(",OK", ",FAIL"), encoding="utf-8")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "status" in result.stderr


def test_parser_rejects_a_single_row_csv(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(csv_path.read_text(encoding="utf-8").splitlines()[0] + "\n", encoding="utf-8")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "expected exactly 2" in result.stderr


def test_parser_rejects_swapped_csv_rows(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    header, first, second = csv_path.read_text(encoding="utf-8").splitlines()
    csv_path.write_text("\n".join([header, second, first]) + "\n", encoding="utf-8")
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "CSV scenario" in result.stderr


def test_parser_rejects_a_wrong_iteration_count(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    csv_path.write_text(
        csv_path.read_text(encoding="utf-8").replace(f",{SAMPLES},", ",20,"), encoding="utf-8"
    )
    result, _ = run_parser(tmp_path, csv_path, evidence_path)
    assert result.returncode == 1
    assert "CSV iterations" in result.stderr


def test_parser_rejects_a_short_sample_count(tmp_path: Path) -> None:
    evidence = good_evidence()
    evidence["iterations"] = 20
    for name in SCENARIO_NAMES:
        evidence["cases"][name]["iterations"] = 20
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    result, _ = run_parser(tmp_path, csv_path, evidence_path, samples=20)
    assert result.returncode == 1
    assert "expected 20" in result.stderr


def test_parser_rejects_a_manifest_with_a_single_scenario(tmp_path: Path) -> None:
    evidence = good_evidence()
    csv_path, evidence_path = write_inputs(tmp_path, evidence)
    manifest = manifest_document()
    manifest["scenarios"] = manifest["scenarios"][:1]
    manifest_path = tmp_path / "media.json"
    manifest_path.write_text(json.dumps(manifest), encoding="utf-8")
    result, _ = run_parser(tmp_path, csv_path, evidence_path, manifest_path=manifest_path)
    assert result.returncode == 1
    assert "exactly 2 scenarios" in result.stderr


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
    assert "lossless" in help_result.stdout.lower()
    assert MEDIA_VARIABLE_TOKEN not in help_result.stdout
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
