"""Validate official Ray Shuffle result extraction without starting Ray."""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path
from types import SimpleNamespace

import pytest


SOURCE = Path(__file__).resolve().parents[1] / "scripts/run_shuffle.py"
SPEC = importlib.util.spec_from_file_location("ray_shuffle_adapter", SOURCE)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


def official_result(value: object) -> dict:
    return {
        "shuffle_time": value,
        "perf_metrics": [{"perf_metric_name": "shuffle_time",
                          "perf_metric_value": value, "perf_metric_type": "LATENCY"}],
    }


def test_parse_official_shuffle_time(tmp_path: Path) -> None:
    path = tmp_path / "round.json"
    path.write_text(json.dumps(official_result(12.5)), encoding="utf-8")
    assert MODULE.parse_round(path) == 12.5


@pytest.mark.parametrize("payload", [
    official_result(0),
    official_result(float("nan")),
    {"shuffle_time": 5, "perf_metrics": []},
    {"shuffle_time": 5, "perf_metrics": [{"perf_metric_name": "other",
                                            "perf_metric_value": 5}]},
    {"shuffle_time": 5, "perf_metrics": [{"perf_metric_name": "shuffle_time",
                                            "perf_metric_value": 6}]},
])
def test_reject_incomplete_official_result(tmp_path: Path, payload: dict) -> None:
    path = tmp_path / "round.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(ValueError):
        MODULE.parse_round(path)


def test_single_node_aggregate_keeps_fixed_parameters(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    calls = []
    fake_ray = SimpleNamespace(
        __version__="2.55.1",
        init=lambda **kwargs: calls.append(kwargs) or SimpleNamespace(address_info={"address": "127.0.0.1:7000"}),
        shutdown=lambda: calls.append("shutdown"),
    )
    monkeypatch.setitem(sys.modules, "ray", fake_ray)
    monkeypatch.setattr(MODULE, "run_round", lambda _script, _output, _log, _address, index, _warmup: float(index))
    payload = MODULE.run(tmp_path / "shuffle_test.py", tmp_path / "work", tmp_path / "results")
    assert payload["results"] == {"shuffle_time": 5.0}
    assert payload["parameters"]["nodes"] == 1
    assert payload["parameters"]["num_partitions"] == 50
    assert payload["parameters"]["formal_rounds"] == 7
    assert sum(row["included"] for row in payload["measurements"]) == 7
    assert calls[0]["resources"] == {"node": 1}
    assert calls[-1] == "shutdown"
