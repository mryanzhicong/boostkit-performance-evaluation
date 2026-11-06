"""Contract tests for TPC-H data identity and 22-query normalization."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1] / "scripts" / "results"
BASE = Path(__file__).resolve().parents[1] / "scripts" / "builders" / "base.sh"


def module(name: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / f"{name}.py")
    assert spec and spec.loader
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def test_manifest_verifies_all_tables_and_detects_changed_data(tmp_path: Path) -> None:
    writer = module("write_manifest")
    verifier = module("verify_data")
    parquet = tmp_path / "parquet"
    for table in verifier.TABLES:
        directory = parquet / table
        directory.mkdir(parents=True)
        (directory / "part-0.parquet").write_bytes(table.encode())
    manifest = writer.write_manifest(parquet)
    signature = verifier.verify(parquet, manifest)
    assert signature == hashlib.sha256(manifest.read_bytes()).hexdigest()
    (parquet / "orders" / "part-0.parquet").write_bytes(b"different")
    with pytest.raises(ValueError, match="mismatch"):
        verifier.verify(parquet, manifest)


def test_parser_requires_complete_formal_rounds_and_uses_median(tmp_path: Path) -> None:
    parser = module("parse_benchmark")
    timings = tmp_path / "timings.jsonl"
    manifest = tmp_path / "parquet.sha256"
    revision = tmp_path / "revision.txt"
    manifest.write_text("a" * 64 + "  ./orders/part.parquet\n")
    revision.write_text("b" * 40 + "\n")
    rows = [
        {"round": round_number, "q": query, "runner": "native", "wall_s": float(round_number)}
        for round_number in range(1, 5)
        for query in range(1, 23)
    ]
    timings.write_text("\n".join(json.dumps(row) for row in rows) + "\n")
    result = parser.parse(timings, manifest, revision, 100, 4)
    assert len(result["results"]) == 22
    assert result["results"]["q01/wall_time"]["value"] == 3.0
    assert result["parameters"]["dataset_manifest_sha256"] == hashlib.sha256(manifest.read_bytes()).hexdigest()
    sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "framework"))
    from generate_comparison import compare_pair

    left = {"category": "Bigdata", "software": "daft", "version": "0.7.2",
            "parameters": result["parameters"], "metrics": result["results"]}
    right = {**left, "metrics": {name: {**item, "value": item["value"] * 2}
                                for name, item in result["results"].items()}}
    assert len(compare_pair(left, right)["metrics"]) == 22
    timings.write_text("\n".join(json.dumps(row) for row in rows[:-1]) + "\n")
    with pytest.raises(ValueError, match="expected 88"):
        parser.parse(timings, manifest, revision, 100, 4)


def test_parser_rejects_query_error(tmp_path: Path) -> None:
    parser = module("parse_benchmark")
    timings = tmp_path / "timings.jsonl"
    manifest = tmp_path / "parquet.sha256"
    revision = tmp_path / "revision.txt"
    manifest.write_text("content")
    revision.write_text("b" * 40)
    rows = [
        {"round": round_number, "q": query, "runner": "native", "wall_s": 1.0}
        for round_number in range(1, 3)
        for query in range(1, 23)
    ]
    rows[3]["error"] = "query failed"
    timings.write_text("\n".join(json.dumps(row) for row in rows) + "\n")
    with pytest.raises(ValueError, match="query failed"):
        parser.parse(timings, manifest, revision, 1, 2)


def test_single_runner_data_mode_generates_once_and_rejects_partial(tmp_path: Path) -> None:
    root = tmp_path / "tpch-data"
    parent = root / "100_0" / "100"
    parquet = parent / "parquet"
    manifest = parent / "parquet.sha256"
    root.mkdir()
    env = {**os.environ, "DAFT_DATA_ROOT": str(root), "DAFT_SF": "100"}

    def mode():
        return subprocess.run(
            ["bash", "-c", f'source "{BASE}"; DAFT_PARQUET="{parquet}"; DAFT_MANIFEST="{manifest}"; select_data_mode; printf "MODE=%s\\n" "$DAFT_PREPARE_DATA"'],
            env=env, text=True, capture_output=True, check=False,
        )

    assert "MODE=1" in mode().stdout
    parquet.mkdir(parents=True)
    assert mode().returncode == 30
    manifest.write_text("manifest")
    assert "MODE=0" in mode().stdout


def test_data_generation_uses_network_aware_container_exec(tmp_path: Path) -> None:
    data_root = tmp_path / "data"
    results = tmp_path / "results"
    data_root.mkdir()
    results.mkdir()
    script = r'''
        source "$1"
        df() { printf 'Filesystem 1B-blocks Used Available Use%% Mounted on\nfs 200000000000 0 200000000000 0%% /\n'; }
        docker() { echo 'unexpected direct docker exec'; return 90; }
        container_exec() { printf 'wrapped: %s\n' "$*"; return 79; }
        prepare_daft_dataset
    '''
    env = {
        **os.environ,
        "DAFT_DATA_ROOT": str(data_root),
        "DAFT_SF": "1",
        "DAFT_SOURCE": str(tmp_path / "source"),
        "DAFT_VENV": str(tmp_path / "venv"),
        "RESULTS_DIR": str(results),
    }
    completed = subprocess.run(
        ["bash", "-c", script, "bash", str(BASE)],
        env=env, capture_output=True, text=True, check=False,
    )
    assert completed.returncode == 40
    output = (results / "data-generation.log").read_text(encoding="utf-8")
    assert "wrapped: env DAFT_PROGRESS_BAR=0 sh -c" in output
    assert "unexpected direct docker exec" not in output
