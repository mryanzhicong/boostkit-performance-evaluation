"""Contract tests for the x264 variant-aware stage split."""

from __future__ import annotations

import importlib.util
import json
import os
import re
import subprocess
from decimal import Decimal
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
MEDIA_DIR = CASE_DIR.parent
RESULTS_DIR = SCRIPT_DIR / "results"

_SPEC = importlib.util.spec_from_file_location(
    "collect_reference_module", MEDIA_DIR / "collect_reference.py"
)
assert _SPEC is not None and _SPEC.loader is not None
reference_module = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(reference_module)


def test_case_yaml_stages_use_split_scripts() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    stages = case["execution"]["stages"]
    assert stages["build"] == {
        "script": "scripts/builders/dispatch.sh",
        "function": "build_x264",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_x264_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_x264_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_x264_runtime",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


def test_base_build_uses_pinned_checked_source_archive() -> None:
    common = (SCRIPT_DIR / "common.sh").read_text(encoding="utf-8")
    builder = (SCRIPT_DIR / "builders" / "base.sh").read_text(encoding="utf-8")
    assert 'X264_SOURCE_REVISION="0480cb05"' in common
    assert (
        'X264_SOURCE_SHA256="d0967a1348c85dfde363bb52610403be898171493100561efa0dd05d5fd1ae50"'
        in common
    )
    assert 'https://github.com/mirror/x264/archive/${X264_SOURCE_REVISION}.tar.gz' in common
    assert "sha256sum -c -" in builder
    assert 'tar -xzf "${archive_path}"' in builder
    assert "git clone" not in builder


@pytest.mark.parametrize(
    ("binary_version", "expected_status"),
    [("0.165.3223", 0), ("0.165.x", 0), ("0.164.x", 40)],
)
def test_archive_build_version_validation(
    binary_version: str, expected_status: int
) -> None:
    result = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; verify_x264_version "$2"',
            "bash",
            str(SCRIPT_DIR / "builders" / "base.sh"),
            binary_version,
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == expected_status


def test_stage_scripts_do_not_depend_on_builder_only_functions() -> None:
    """Framework stages run standalone; they must not call builder-only helpers."""
    builder_functions: set[str] = set()
    for builder in sorted((SCRIPT_DIR / "builders").glob("*.sh")):
        builder_functions.update(
            re.findall(
                r"^([a-z_]+)\(\)", builder.read_text(encoding="utf-8"), re.MULTILINE
            )
        )
    assert builder_functions
    for stage in sorted((SCRIPT_DIR / "stages").glob("*.sh")):
        content = stage.read_text(encoding="utf-8")
        referenced = {
            name for name in builder_functions if re.search(rf"\b{name}\b", content)
        }
        assert not referenced, (
            f"{stage.name} references builder-only functions: {referenced}"
        )


def test_optimized_build_fails_without_running_base_build(tmp_path: Path) -> None:
    result = subprocess.run(
        [
            "bash",
            "-c",
            'source "$1"; build_x264',
            "bash",
            str(SCRIPT_DIR / "builders" / "dispatch.sh"),
        ],
        env={
            **os.environ,
            "PERF_VARIANT": "optimized",
            "PERF_WORK_DIR": str(tmp_path),
        },
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 30
    assert "optimized x264 build is not implemented" in result.stdout
    assert not (tmp_path / "x264").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "x264_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _run_faked_main(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch, architecture: str
) -> dict:
    videos = {"sample": {"bytes": 6, "frames": 1, "sha256": "deadbeef"}}
    rows = {("sample", 2000): (Decimal("12.50"), Decimal(4))}
    def fake_collect(*args: object) -> dict:
        mode = args[-2]
        name = f"{mode}/sample/2000k/total_fps"
        return {name: {
            "source_name": name,
            "source_field": "fps",
            "group": "单路" if mode == "single" else "整机",
            "value": 12.5,
            "average_bin_size_bytes": 4.0,
        }}
    normalized_output = tmp_path / f"benchmark-x264-{architecture}.json"
    raw_output = tmp_path / f"raw-{architecture}.txt"
    raw_output.write_text("original command output\n", encoding="utf-8")

    monkeypatch.setattr(
        reference_module, "inspect_videos", lambda *args, **kwargs: videos
    )
    monkeypatch.setattr(reference_module, "read_summary", lambda *args: rows)
    monkeypatch.setattr(reference_module, "collect", fake_collect)
    monkeypatch.setattr(
        reference_module.sys,
        "argv",
        [
            "collect_reference.py",
            "--encoder", "x264",
            "--video-dir", str(tmp_path / "video"),
            "--work-dir", str(tmp_path),
            "--raw-output", str(raw_output),
            "--summary", str(tmp_path / "score.csv"),
            "--whole-machine-routes", "2",
            "--normalized-output", str(normalized_output),
            "--version", "0.165.3223",
            "--architecture", architecture,
        ],
    )
    monkeypatch.setenv("PERF_VARIANT", "base")
    assert reference_module.main() == 0
    return json.loads(normalized_output.read_text(encoding="utf-8"))


def test_normalized_parameters_align_across_architectures(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    payloads = [
        _run_faked_main(tmp_path, monkeypatch, architecture)
        for architecture in ("x86_64", "aarch64")
    ]
    assert payloads[0]["variant"] == "base"
    assert len(payloads[0]["results"]) == 2
    assert payloads[0]["parameters"] == payloads[1]["parameters"]
    assert not any(
        "boostkit-perf" in json.dumps(payload["parameters"]) for payload in payloads
    )
