"""Check atomic runner-side result preservation and directory conventions."""

import importlib.util
import json
from pathlib import Path

import pytest


SCRIPT = Path(__file__).with_name("persist_result.py")
SPEC = importlib.util.spec_from_file_location("persist_result", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
persist_result = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(persist_result)


def test_base_and_optimized_result_paths(tmp_path: Path) -> None:
    common = ("Media", "x265", "4.2", "timestamp_123-1", "x86_64")
    assert persist_result.destination(*common, "base", tmp_path) == (
        tmp_path / "Media/x265/4.2/timestamp_123-1/x86_64"
    )
    assert persist_result.destination(*common, "optimized", tmp_path) == (
        tmp_path / "Media/x265/4.2/optimized/timestamp_123-1/x86_64"
    )


def test_preserve_complete_result_without_overwrite(tmp_path: Path) -> None:
    source = tmp_path / "output"
    source.mkdir()
    (source / "status.json").write_text(json.dumps({"status": "passed"}), encoding="utf-8")
    (source / "raw-output.log").write_text("benchmark output\n", encoding="utf-8")
    target = tmp_path / "spool" / "result"

    persist_result.persist(source, target)

    assert (target / "status.json").read_text(encoding="utf-8") == (
        source / "status.json"
    ).read_text(encoding="utf-8")
    assert (target / "raw-output.log").read_text(encoding="utf-8") == "benchmark output\n"
    assert list(target.parent.glob(".result.pending-*")) == []
    with pytest.raises(ValueError, match="refusing to overwrite"):
        persist_result.persist(source, target)


def test_reject_unsafe_path_component(tmp_path: Path) -> None:
    with pytest.raises(ValueError, match="invalid result path component"):
        persist_result.destination("Media", "../x265", "4.2", "run", "x86_64", "base", tmp_path)
