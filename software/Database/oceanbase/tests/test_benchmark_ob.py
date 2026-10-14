"""Validate the document-aligned Sysbench matrix and strict metric parsing."""

import importlib.util
import json
import os
from pathlib import Path

import pytest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/benchmark_ob.py"
SPEC = importlib.util.spec_from_file_location("oceanbase_benchmark", SCRIPT)
assert SPEC is not None and SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)

SUMMARY = """SQL statistics:
    queries:                            3000 (100.00 per sec.)
General statistics:
    total time:                          30.0000s
    total number of events:              600
Latency (ms):
         min:                                    1.00
         avg:                                    2.50
         max:                                    9.00
         95th percentile:                        4.00
Threads fairness:
    events (avg/stddev):           600.0000/0.00
    execution time (avg/stddev):   30.0000/0.00
transactions:                        600 (20.00 per sec.)
"""


def test_matrix_uses_selected_guidance_levels() -> None:
    assert MODULE.WORKLOADS == ("read_only", "insert", "read_write", "write_only")
    assert MODULE.THREADS == (1, 64, 256)
    assert MODULE.TABLE_SIZE == 500000
    assert MODULE.DURATION_SECONDS == 300
    assert MODULE.PAUSE_SECONDS == 60


def test_summary_requires_all_positive_official_fields() -> None:
    assert MODULE.parse_summary(SUMMARY, "insert", 256) == {
        "tps": 20.0,
        "qps": 100.0,
        "avg_latency_ms": 2.5,
        "p95_latency_ms": 4.0,
    }
    with pytest.raises(ValueError, match="expected one tps"):
        MODULE.parse_summary(SUMMARY.replace("transactions:", "other:"), "insert", 256)


def test_sysbench_fatal_output_fails_even_with_zero_exit_code(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setenv("SYSBENCH_LUA_DIR", str(tmp_path))
    sysbench = tmp_path / "sysbench"
    sysbench.write_text(
        "#!/bin/sh\nprintf '%s\\n' 'FATAL: error 2013: handshake failed'\nexit 0\n",
        encoding="utf-8",
    )
    sysbench.chmod(0o755)
    output = tmp_path / "prepare.log"
    with (tmp_path / "raw.log").open("w", encoding="utf-8") as raw:
        with pytest.raises(RuntimeError, match="Sysbench reported FATAL: error 2013"):
            MODULE.run_command([str(sysbench)], raw, output, "read_only-threads64: prepare")
    assert "FATAL: error 2013" in output.read_text(encoding="utf-8")


def test_output_preserves_workload_and_thread_names(tmp_path: Path, monkeypatch) -> None:
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    sysbench = bin_dir / "sysbench"
    sysbench.write_text(
        "#!/bin/sh\n"
        "printf '%s\\n' \"$@\"\n"
        "case \" $* \" in *' run '*)\n"
        "printf '%s\\n' 'transactions: 600 (20.00 per sec.)' "
        "'queries: 3000 (100.00 per sec.)' 'avg: 2.50' "
        "'95th percentile: 4.00' ;; esac\n",
        encoding="utf-8",
    )
    sysbench.chmod(0o755)
    lua_dir = tmp_path / "lua"
    lua_dir.mkdir()
    (lua_dir / "oltp_insert.lua").write_text("", encoding="utf-8")
    monkeypatch.setattr(MODULE, "WORKLOADS", ("insert",))
    monkeypatch.setattr(MODULE, "THREADS", (64,))
    monkeypatch.setenv("PATH", f"{bin_dir}:{os.environ['PATH']}")
    monkeypatch.setenv("SYSBENCH_LUA_DIR", str(lua_dir))
    monkeypatch.setenv("SYSBENCH_BIN", str(sysbench))
    monkeypatch.setenv("SOFTWARE_VERSION", "4.2.5.6")
    monkeypatch.setenv("OB_PROXY_VERSION", "4.3.6.1")
    monkeypatch.setenv("EXPECTED_ARCH", "aarch64")
    monkeypatch.setattr(
        "sys.argv",
        [str(SCRIPT), "--host", "127.0.0.1", "--port", "2883", "--user",
         "root@test#demo", "--database", "obtest", "--results-dir", str(tmp_path / "results")],
    )
    assert MODULE.main() == 0
    payload = json.loads((tmp_path / "results/results.json").read_text(encoding="utf-8"))
    assert len(payload["results"]) == 4
    assert payload["results"]["insert :: threads=64 :: tps"]["value"] == 20.0
    assert payload["parameters"]["connection"] == "obproxy"
    raw = (tmp_path / "results/sysbench_raw.log").read_text(encoding="utf-8")
    assert "insert-threads64: cleanup" in raw
    assert "insert-threads64: prepare" in raw
    assert "insert-threads64: run" in raw
    assert "--mysql-ignore-errors=" in raw

    monkeypatch.setenv("EXPECTED_ARCH", "x86_64")
    monkeypatch.setattr(
        "sys.argv",
        [str(SCRIPT), "--host", "127.0.0.1", "--port", "2883", "--user",
         "root@test#demo", "--database", "obtest", "--results-dir", str(tmp_path / "x86")],
    )
    assert MODULE.main() == 0
    x86 = json.loads((tmp_path / "x86/results.json").read_text(encoding="utf-8"))
    assert x86["parameters"] == payload["parameters"]
    assert set(x86["results"]) == set(payload["results"])
