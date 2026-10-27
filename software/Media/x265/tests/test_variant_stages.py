"""Contract tests for the x265 variant-aware stage split."""

from __future__ import annotations

import importlib.util
import io
import json
import os
import re
import subprocess
import tarfile
from decimal import Decimal
from pathlib import Path

import pytest
import yaml

CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT_DIR = CASE_DIR / "scripts"
MEDIA_DIR = CASE_DIR.parent

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
        "function": "build_x265",
    }
    assert stages["start"] == {
        "script": "scripts/stages/start.sh",
        "function": "start_x265_runtime",
    }
    assert stages["test"] == {
        "script": "scripts/stages/test.sh",
        "function": "run_x265_benchmarks",
    }
    assert stages["stop"] == {
        "script": "scripts/stages/stop.sh",
        "function": "stop_x265_runtime",
    }
    build_variant = case["outputs"]["build_variant"]
    assert build_variant["path"] == "build_variant.json"
    assert build_variant["stage"] == "build"
    assert build_variant["required"] is True


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
            'source "$1"; build_x265',
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
    assert "optimized x265 build is not implemented" in result.stdout
    assert not (tmp_path / "x265_4.2").exists()


def test_standalone_variant_option_rejects_unknown_values() -> None:
    result = subprocess.run(
        ["bash", str(CASE_DIR / "x265_test.sh"), "--variant", "invalid"],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 10
    assert "invalid build variant" in result.stdout


def _write_source_archive(path: Path) -> None:
    content = b"fixture x265 source\n"
    with tarfile.open(path, "w:gz") as archive:
        member = tarfile.TarInfo("x265_4.2/source/CMakeLists.txt")
        member.size = len(content)
        archive.addfile(member, io.BytesIO(content))


def _extract_source_archive(
    tmp_path: Path, local_archive: Path | None
) -> subprocess.CompletedProcess[str]:
    work_dir = tmp_path / "work"
    work_dir.mkdir()
    offline_dir = tmp_path / "offline"
    offline_dir.mkdir()
    if local_archive is not None:
        (offline_dir / "x265_4.2.tar.gz").write_bytes(local_archive.read_bytes())
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    wget = bin_dir / "wget"
    wget.write_text(
        '#!/bin/sh\n'
        'printf "%s\\n" "$*" >> "$X265_WGET_CALLS"\n'
        'cp "$X265_TEST_REMOTE_ARCHIVE" "$2"\n',
        encoding="utf-8",
    )
    wget.chmod(0o755)
    return subprocess.run(
        ["bash", "-c", 'source "$1"; prepare_x265_source_archive', "bash",
         str(SCRIPT_DIR / "builders" / "base.sh")],
        env={
            **os.environ,
            "PATH": f"{bin_dir}:{os.environ['PATH']}",
            "PERF_WORK_DIR": str(work_dir),
            "X265_SOURCE_ARCHIVE_DIR": str(offline_dir),
            "X265_TEST_REMOTE_ARCHIVE": str(tmp_path / "remote.tar.gz"),
            "X265_WGET_CALLS": str(tmp_path / "wget-calls.log"),
        },
        capture_output=True, text=True, check=False,
    )


def test_x265_prefers_local_source_archive(tmp_path: Path) -> None:
    archive = tmp_path / "local.tar.gz"
    _write_source_archive(archive)
    result = _extract_source_archive(tmp_path, archive)
    assert result.returncode == 0, result.stdout + result.stderr
    assert (tmp_path / "work" / "x265_4.2" / "source" / "CMakeLists.txt").is_file()
    assert not (tmp_path / "wget-calls.log").exists()


def test_x265_downloads_when_local_archive_is_missing(tmp_path: Path) -> None:
    _write_source_archive(tmp_path / "remote.tar.gz")
    result = _extract_source_archive(tmp_path, None)
    assert result.returncode == 0, result.stdout + result.stderr
    assert (tmp_path / "work" / "x265_4.2" / "source" / "CMakeLists.txt").is_file()
    assert "x265_4.2.tar.gz" in (tmp_path / "wget-calls.log").read_text(encoding="utf-8")


def test_x265_rejects_empty_local_archive_without_network_fallback(tmp_path: Path) -> None:
    archive = tmp_path / "local.tar.gz"
    archive.touch()
    result = _extract_source_archive(tmp_path, archive)
    assert result.returncode == 30
    assert "not a non-empty file" in result.stdout
    assert not (tmp_path / "wget-calls.log").exists()


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
            "subgroup": "sample",
            "value": 12.5,
            "average_bin_size_bytes": 4.0,
        }}
    normalized_output = tmp_path / f"benchmark-x265-{architecture}.json"
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
            "--encoder", "x265",
            "--video-dir", str(tmp_path / "video"),
            "--work-dir", str(tmp_path),
            "--raw-output", str(raw_output),
            "--summary", str(tmp_path / "score.csv"),
            "--whole-machine-routes", "2",
            "--normalized-output", str(normalized_output),
            "--version", "4.2",
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
