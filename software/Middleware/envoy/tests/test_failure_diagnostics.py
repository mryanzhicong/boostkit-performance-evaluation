"""Keep Envoy failure evidence without changing benchmark validity rules."""

import json
import os
import runpy
import subprocess
from pathlib import Path

import pytest


ENVOY_DIR = Path(__file__).resolve().parents[1]


def test_k6_logs_failed_response_and_still_rejects_failed_summary(tmp_path: Path) -> None:
    module = runpy.run_path(str(ENVOY_DIR / "scripts/run_k6_benchmark.py"))
    script = module["SCRIPT"]
    assert "response.status < 200 || response.status >= 400" in script
    assert "response.error_code" in script
    assert "response.error" in script
    summary = tmp_path / "summary.json"
    summary.write_text(
        json.dumps(
            {
                "metrics": {
                    "http_reqs": {"count": 118187, "rate": 5908.27},
                    "http_req_duration": {"avg": 1.96, "p(95)": 4.67},
                    "http_req_failed": {"rate": 1 / 118187},
                }
            }
        ),
        encoding="utf-8",
    )
    with pytest.raises(RuntimeError, match="non-zero http_req_failed rate"):
        module["parse_summary"](summary, "reverse_proxy", "HTTPS reverse proxy")


def test_stop_preserves_envoy_process_logs(tmp_path: Path) -> None:
    work_dir = tmp_path / "work"
    runtime_dir = work_dir / "runtime"
    results_dir = tmp_path / "results"
    runtime_dir.mkdir(parents=True)
    for name in ("direct", "proxy", "backend"):
        (runtime_dir / f"{name}.log").write_text(f"{name} diagnostic\n", encoding="utf-8")
    env = os.environ | {
        "PERF_WORK_DIR": str(work_dir),
        "RESULTS_DIR": str(results_dir),
        "PERF_RUN_ID": "diagnostic-test",
        "EXPECTED_ARCH": os.uname().machine,
        "TEST_SCRIPT": str(ENVOY_DIR / "envoy_test.sh"),
    }
    subprocess.run(
        ["bash", "-c", 'source "$TEST_SCRIPT"; stop_envoy_runtime'],
        env=env,
        check=True,
        capture_output=True,
        text=True,
    )
    assert not runtime_dir.exists()
    for name in ("direct", "proxy", "backend"):
        assert (results_dir / f"envoy-{name}.log").read_text(encoding="utf-8") == (
            f"{name} diagnostic\n"
        )
