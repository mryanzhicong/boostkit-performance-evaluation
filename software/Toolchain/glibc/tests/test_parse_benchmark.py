"""Checks for the glibc 2.44 public-function metric contract."""

import importlib.util
import json
from pathlib import Path

import pytest


RESULTS_DIR = Path(__file__).resolve().parents[1] / "scripts" / "results"
SPEC = importlib.util.spec_from_file_location(
    "glibc_parse_benchmark", RESULTS_DIR / "parse_benchmark.py"
)
assert SPEC is not None and SPEC.loader is not None
PARSER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PARSER)
RUNTIME_SPEC = importlib.util.spec_from_file_location(
    "glibc_standalone_runtime", RESULTS_DIR / "standalone_runtime.py"
)
assert RUNTIME_SPEC is not None and RUNTIME_SPEC.loader is not None
RUNTIME = importlib.util.module_from_spec(RUNTIME_SPEC)
RUNTIME_SPEC.loader.exec_module(RUNTIME)


def write_output(directory, function, *, timing_type="clock_gettime_ns", public=True):
    implementations = [f"generic_{function}"]
    if public:
        implementations.append(function)
    rows = []
    for length in (2048, 4096):
        row = {
            "length": length,
            "align1": 0,
            "align2": 0,
            "timings": [90.0, float(length // 1024)] if public else [90.0],
        }
        if function == "memcmp":
            row["result"] = 0
        else:
            row["dst > src"] = 0
        rows.append(row)
    (directory / f"bench-{function}.out").write_text(
        json.dumps(
            {
                "timing_type": timing_type,
                "functions": {function: {"ifuncs": implementations, "results": rows}},
            }
        ),
        encoding="utf-8",
    )


def add_preferred_memcpy(directory, value=7.0):
    path = directory / "bench-memcpy.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    benchmark = payload["functions"]["memcpy"]
    benchmark["ifuncs"].append("__memcpy_kunpeng950")
    for row in benchmark["results"]:
        row["timings"].append(value)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_public_metrics_use_same_scenarios_and_nanoseconds(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")

    metrics = PARSER.extract_metrics(tmp_path)

    assert len(metrics) == 4
    assert metrics["memcpy.length=2048.align1=0.align2=0.dst_gt_src=0"]["value"] == 2
    assert metrics["memcmp.length=4096.align1=0.align2=0.result=0"]["value"] == 4
    assert {metric["raw_unit"] for metric in metrics.values()} == {"ns"}
    assert {metric["source_field"].split(".")[-1] for metric in metrics.values()} == {
        "timings[1]"
    }
    assert metrics["memcpy.length=2048.align1=0.align2=0.dst_gt_src=0"]["implementation"] == "memcpy"
    assert metrics["memcmp.length=2048.align1=0.align2=0.result=0"]["implementation"] == "memcmp"
    standalone_metrics = RUNTIME.extract_metrics(
        {"software": "glibc", "version": "2.44", "architecture": "x86_64", "results": metrics},
        "2.44",
        "x86_64",
    )
    assert set(standalone_metrics) == set(metrics)


def test_memcpy_prefers_kunpeng950_when_present(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    add_preferred_memcpy(tmp_path, value=7.0)

    metrics = PARSER.extract_metrics(tmp_path)

    assert len(metrics) == 4
    metric = metrics["memcpy.length=2048.align1=0.align2=0.dst_gt_src=0"]
    assert metric["value"] == 7.0
    assert metric["implementation"] == "__memcpy_kunpeng950"
    assert metric["source_field"] == "functions.memcpy.results[0].timings[2]"
    assert metrics["memcmp.length=2048.align1=0.align2=0.result=0"]["implementation"] == "memcmp"


def test_memcpy_falls_back_to_public_entry(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")

    metric = PARSER.extract_metrics(tmp_path)["memcpy.length=4096.align1=0.align2=0.dst_gt_src=0"]

    assert metric["value"] == 4.0
    assert metric["implementation"] == "memcpy"
    assert metric["source_field"] == "functions.memcpy.results[1].timings[1]"


def test_duplicate_kunpeng950_entries_are_rejected(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    add_preferred_memcpy(tmp_path)
    path = tmp_path / "bench-memcpy.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["functions"]["memcpy"]["ifuncs"].append("__memcpy_kunpeng950")
    for row in payload["functions"]["memcpy"]["results"]:
        row["timings"].append(7.0)
    path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(ValueError, match="duplicate __memcpy_kunpeng950"):
        PARSER.extract_metrics(tmp_path)


def add_preferred_memcmp(directory, value=5.0):
    path = directory / "bench-memcmp.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    benchmark = payload["functions"]["memcmp"]
    benchmark["ifuncs"].append("__memcmp_kunpeng950")
    for row in benchmark["results"]:
        row["timings"].append(value)
    path.write_text(json.dumps(payload), encoding="utf-8")


def test_memcmp_prefers_kunpeng950_when_present(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    add_preferred_memcmp(tmp_path, value=5.0)

    metrics = PARSER.extract_metrics(tmp_path)

    assert len(metrics) == 4
    metric = metrics["memcmp.length=2048.align1=0.align2=0.result=0"]
    assert metric["value"] == 5.0
    assert metric["implementation"] == "__memcmp_kunpeng950"
    assert metric["source_field"] == "functions.memcmp.results[0].timings[2]"
    assert metrics["memcpy.length=2048.align1=0.align2=0.dst_gt_src=0"]["implementation"] == "memcpy"


def test_duplicate_memcmp_kunpeng950_entries_are_rejected(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    add_preferred_memcmp(tmp_path)
    path = tmp_path / "bench-memcmp.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["functions"]["memcmp"]["ifuncs"].append("__memcmp_kunpeng950")
    for row in payload["functions"]["memcmp"]["results"]:
        row["timings"].append(5.0)
    path.write_text(json.dumps(payload), encoding="utf-8")

    with pytest.raises(ValueError, match="duplicate __memcmp_kunpeng950"):
        PARSER.extract_metrics(tmp_path)


def test_extract_items_emits_one_raw_row_per_scenario(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    add_preferred_memcpy(tmp_path, value=7.0)
    add_preferred_memcmp(tmp_path, value=5.0)

    items = PARSER.extract_items(tmp_path)

    assert len(items) == 4
    assert len({item["key"] for item in items}) == 4
    memcpy = next(item for item in items if item["function"] == "memcpy" and item["scenario"]["length"] == 2048)
    assert memcpy["value"] == 7.0
    assert memcpy["implementation"] == "__memcpy_kunpeng950"
    assert memcpy["group"] == "memcpy"
    assert memcpy["unit"] == "ns"
    assert memcpy["direction"] == "lower_is_better"
    memcmp = next(item for item in items if item["function"] == "memcmp" and item["scenario"]["length"] == 4096)
    assert memcmp["value"] == 5.0
    assert memcmp["implementation"] == "__memcmp_kunpeng950"


def test_extract_items_keeps_duplicate_scenarios_unique(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    path = tmp_path / "bench-memcpy.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    payload["functions"]["memcpy"]["results"].append(
        dict(payload["functions"]["memcpy"]["results"][0])
    )
    path.write_text(json.dumps(payload), encoding="utf-8")

    items = PARSER.extract_items(tmp_path)
    keys = [item["key"] for item in items if item["function"] == "memcpy" and item["scenario"]["length"] == 2048]
    assert len(keys) == 2
    assert keys[0] != keys[1]
    assert keys[0].endswith("occurrence=0")
    assert keys[1].endswith("occurrence=1")


@pytest.mark.parametrize("timing_type", ["hp_timing", "", "clock_gettime_cycles"])
def test_other_timing_backends_are_rejected(tmp_path, timing_type):
    write_output(tmp_path, "memcpy", timing_type=timing_type)
    write_output(tmp_path, "memcmp")
    with pytest.raises(ValueError, match="does not use clock_gettime_ns"):
        PARSER.extract_metrics(tmp_path)


def test_missing_public_function_is_rejected(tmp_path):
    write_output(tmp_path, "memcpy", public=False)
    write_output(tmp_path, "memcmp")
    with pytest.raises(ValueError, match="public memcpy entry"):
        PARSER.extract_metrics(tmp_path)


def test_memcpy_page_size_duplicate_uses_first_sweep_result(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    path = tmp_path / "bench-memcpy.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    duplicate = dict(payload["functions"]["memcpy"]["results"][1])
    duplicate["timings"] = [90.0, 999.0]
    payload["functions"]["memcpy"]["results"].append(duplicate)
    path.write_text(json.dumps(payload), encoding="utf-8")

    metric = PARSER.extract_metrics(tmp_path)["memcpy.length=4096.align1=0.align2=0.dst_gt_src=0"]
    assert metric["value"] == 4.0
    assert metric["source_field"] == "functions.memcpy.results[1].timings[1]"


def test_memcmp_requires_equal_input_marker(tmp_path):
    write_output(tmp_path, "memcpy")
    write_output(tmp_path, "memcmp")
    path = tmp_path / "bench-memcmp.out"
    payload = json.loads(path.read_text(encoding="utf-8"))
    del payload["functions"]["memcmp"]["results"][0]["result"]
    path.write_text(json.dumps(payload), encoding="utf-8")
    with pytest.raises(ValueError, match="has no"):
        PARSER.extract_metrics(tmp_path)
