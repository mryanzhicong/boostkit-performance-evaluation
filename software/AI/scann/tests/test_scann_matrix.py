"""Validate the fixed open-source ScaNN benchmark matrix."""

from __future__ import annotations

import importlib.util
import math
import subprocess
from pathlib import Path

import pytest
import yaml


CASE_DIR = Path(__file__).resolve().parents[1]
SCRIPT = CASE_DIR / "scripts" / "results" / "run_benchmark.py"
SPEC = importlib.util.spec_from_file_location("scann_benchmark", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def test_five_official_configs_have_one_query_group_each(tmp_path: Path) -> None:
    MODULE.write_configs(tmp_path, "ann-benchmarks-scann-test")
    assert len(MODULE.DATASETS) == 5
    for dataset, (distance, arguments, query) in MODULE.DATASETS.items():
        path = tmp_path / "os-configs" / dataset / "scann" / "config.yml"
        config = yaml.safe_load(path.read_text(encoding="utf-8"))
        section = config["float"][distance][0]
        group = section["run_groups"]["adapter"]
        assert section["module"] == "ann_benchmarks.algorithms.scann"
        assert section["docker_tag"] == "ann-benchmarks-scann-test"
        assert len(group["query_args"]) == 1
        assert group["query_args"] == [[query]]
        assert group["args"][0][0] == arguments[0]
        if isinstance(arguments[1], float) and math.isnan(arguments[1]):
            assert math.isnan(group["args"][1][0])
        else:
            assert group["args"][1][0] == arguments[1]


def test_metric_names_and_directions_are_complete() -> None:
    assert MODULE.METRICS["recall_at_10"] == ("ratio", "higher_is_better")
    assert MODULE.METRICS["qps"] == ("queries/s", "higher_is_better")
    assert MODULE.METRICS["build_time_s"] == ("s", "lower_is_better")
    assert len(MODULE.METRICS) == 5
    assert not any(name.startswith("p") and name.endswith("_ms") for name in MODULE.METRICS)


def test_official_run_uses_batch_and_flushes_its_log(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    commands = []
    logfile = tmp_path / "ann-benchmarks-logs" / "sift-128-euclidean.log"

    class FakeProcess:
        def __init__(self) -> None:
            self.stdout = self.lines()

        def lines(self):
            yield "one line\n"
            assert logfile.read_text() == "one line\n"

        def wait(self) -> int:
            return 0

    def fake_popen(command: list[str], **kwargs: object) -> FakeProcess:
        commands.append(command)
        return FakeProcess()

    monkeypatch.setattr(MODULE.subprocess, "Popen", fake_popen)
    MODULE.run_official(tmp_path, Path("/venv/bin/python"), "sift-128-euclidean", tmp_path)
    assert "--batch" in commands[0]
    assert logfile.read_text() == "one line\n"


def test_case_declares_split_stages_and_official_tool() -> None:
    case = yaml.safe_load((CASE_DIR / "case.yaml").read_text(encoding="utf-8"))
    assert case["versions"] == ["1.4.2"]
    assert case["execution"]["stages"]["build"]["script"] == "scripts/builders/dispatch.sh"
    assert case["metrics"]["collection"]["group_path"] == "group"
    assert case["test_tools"]["ann_benchmarks"]["version"] == MODULE.REVISION


def test_stage_scripts_can_source_common_more_than_once() -> None:
    scripts = CASE_DIR / "scripts"
    command = (
        'source "$1/builders/dispatch.sh"; '
        'source "$1/builders/base.sh"; '
        'source "$1/builders/optimized.sh"; '
        'source "$1/stages/start.sh"; '
        'source "$1/stages/test.sh"; '
        'source "$1/stages/stop.sh"; '
        'test "$ANNB_REVISION" = "$2"'
    )
    subprocess.run(
        ["bash", "-c", command, "bash", str(scripts), MODULE.REVISION],
        check=True,
    )


def test_docker_image_build_uses_host_network() -> None:
    builder = (CASE_DIR / "scripts" / "builders" / "base.sh").read_text(encoding="utf-8")
    assert 'docker build --rm --network=host "${proxy_args[@]}"' in builder
    assert '--build-arg "RUN_UID=$(id -u)" --build-arg "RUN_GID=$(id -g)"' in builder


def test_scann_container_writes_results_as_runner() -> None:
    dockerfile = (CASE_DIR / "scripts" / "Dockerfile.scann").read_text(encoding="utf-8")
    common = (CASE_DIR / "scripts" / "common.sh").read_text(encoding="utf-8")
    assert "USER ${RUN_UID}:${RUN_GID}" in dockerfile
    assert "ENV HOME=/home/app" in dockerfile
    assert '"1.4.2 $(id -u):$(id -g)"' in common


def test_parses_one_official_hdf5_result_and_preserves_raw(tmp_path: Path) -> None:
    h5py = pytest.importorskip("h5py")
    np = pytest.importorskip("numpy")
    dataset = "sift-128-euclidean"
    source = tmp_path / "source"
    data = tmp_path / "data"
    output = tmp_path / "output"
    result_dir = source / "results" / dataset / "10" / "scann-batch"
    data.mkdir()
    result_dir.mkdir(parents=True)
    with h5py.File(data / f"{dataset}.hdf5", "w") as file:
        file.create_dataset("test", data=np.zeros((2, 128)))
        file.create_dataset("distances", data=np.tile(np.arange(10), (2, 1)))
    with h5py.File(result_dir / "test.hdf5", "w") as file:
        file.attrs.update({"algo": "scann", "dataset": dataset, "batch_mode": True,
                           "run_count": 1, "count": 10, "best_search_time": 0.01,
                           "build_time": 2.5, "candidates": 10.0, "index_size": 100.0})
        file.create_dataset("distances", data=np.tile(np.arange(10), (2, 1)))
        file.create_dataset("times", data=np.array([0.01, 0.01]))
    parsed = MODULE.parse_official_result(source, data, dataset, output)
    assert parsed["recall_at_10"] == 1.0
    assert parsed["qps"] == 100.0
    assert parsed["build_time_s"] == 2.5
    assert len(parsed) == 5
    assert (output / "ann-benchmarks-results" / dataset / "test.hdf5").is_file()


def test_non_batch_result_is_rejected(tmp_path: Path) -> None:
    h5py = pytest.importorskip("h5py")
    np = pytest.importorskip("numpy")
    dataset = "sift-128-euclidean"
    data = tmp_path / "data"
    result_dir = tmp_path / "results" / dataset / "10" / "scann-batch"
    data.mkdir()
    result_dir.mkdir(parents=True)
    with h5py.File(data / f"{dataset}.hdf5", "w") as file:
        file.create_dataset("test", data=np.zeros((2, 128)))
        file.create_dataset("distances", data=np.tile(np.arange(10), (2, 1)))
    with h5py.File(result_dir / "test.hdf5", "w") as file:
        file.attrs.update({"algo": "scann", "dataset": dataset, "batch_mode": False, "run_count": 1})
    with pytest.raises(RuntimeError, match="unexpected query mode"):
        MODULE.parse_official_result(tmp_path, data, dataset, tmp_path)


def test_missing_official_hdf5_result_fails(tmp_path: Path) -> None:
    pytest.importorskip("h5py")
    with pytest.raises(RuntimeError, match="exactly one"):
        MODULE.parse_official_result(tmp_path, tmp_path, "sift-128-euclidean", tmp_path)
