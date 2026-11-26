#!/usr/bin/env python3
"""Unit tests for the strict Tongsuo speed parser."""
from __future__ import annotations

import importlib.util
import json
import re
import sys
from pathlib import Path

import pytest

CASE = Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location(
    "tongsuo_parse_benchmark", CASE / "scripts" / "results" / "parse_benchmark.py"
)
parser = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(parser)

TABLE_LOG = """+------------------------------------------------------------------------+
| She146 3.5.4 speed                                                      |
+------------------------------------------------------------------------+
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
SM4-GCM          82058.45k    91805.99k    94035.22k    94432.66k    94643.63k    94583.35k
SM4-CBC          90000.00k    100000.00k   110000.00k   120000.00k   130000.00k   140000.00k
"""

PUBKEY_LOG = """Doing 2048 bits private rsa sign ops for 1s: 2694 ops
Doing 2048 bits public rsa verify ops for 1s: 89258 ops
version: 3.5.4
built on: Thu Nov 26 10:04:21 2026 UTC
                   sign    verify    encrypt   decrypt   sign/s verify/s  encr./s  decr./s
rsa  2048 bits 0.000371s 0.000011s 0.000012s 0.000373s   2694.0  89258.0  86492.9   2682.8
                               keygen    encaps    decaps keygens/s  encaps/s  decaps/s
                    rsa2048 0.023182s 0.000012s 0.000370s      43.1   81309.0    2706.0
"""

SM2_LOG = """Doing 256 bits sign CurveSM2 ops for 1s: 5619 ops
                              sign    verify    sign/s verify/s
 256 bits SM2 (CurveSM2)   0.0002s   0.0002s   5619.0   5780.0
"""

ECDSA_LOG = """Doing 256 bits sign ecdsa ops for 1s: 71198 ops
                              sign    verify    sign/s verify/s
 256 bits ecdsa (nistp256)   0.0000s   0.0000s  71198.0  22645.5
"""

ECDH_LOG = """+------------------------------------------------------------------------+
| She146 3.5.4 speed                                                      |
+------------------------------------------------------------------------+
                              op      op/s
 256 bits ecdh (nistp256)   0.0001s  12000.0
"""


def _scenario(name: str, log: str, directory: Path, reps: int = 6, warmups: int = 1) -> None:
    target = directory / name
    target.mkdir(parents=True)
    for index in range(1, warmups + 1):
        (target / ("warmup%d.log" % index)).write_text(log, encoding="utf-8")
    for index in range(1, reps + 1):
        (target / ("rep%d.log" % index)).write_text(log, encoding="utf-8")


def test_table_metrics_convert_to_megabytes(tmp_path):
    spec = parser.SCENARIOS["sm4_gcm"]
    values = parser.parse_table(TABLE_LOG, spec)
    assert values["sm4_gcm_16b_mb_per_sec"] == pytest.approx(82.05845, rel=1e-6)
    assert values["sm4_gcm_16384b_mb_per_sec"] == pytest.approx(94.58335, rel=1e-6)


def test_rsa_metrics_come_from_the_wider_table():
    spec = parser.SCENARIOS["rsa2048"]
    values = parser.parse_pubkey(PUBKEY_LOG, spec)
    # sign/s and verify/s are columns 5 and 6 of an 8-column table; the last two
    # numbers of the row are encr./s and decr./s and must not be picked up.
    assert values["rsa2048_sign_ops_per_sec"] == pytest.approx(2694.0)
    assert values["rsa2048_verify_ops_per_sec"] == pytest.approx(89258.0)


def test_sm2_and_ecdsa_tables():
    sm2 = parser.parse_pubkey(SM2_LOG, parser.SCENARIOS["sm2_sign_verify"])
    assert sm2["sm2_sign_ops_per_sec"] == pytest.approx(5619.0)
    assert sm2["sm2_verify_ops_per_sec"] == pytest.approx(5780.0)
    ecdsa = parser.parse_pubkey(ECDSA_LOG, parser.SCENARIOS["ecdsa_p256"])
    assert ecdsa["ecdsa_p256_sign_ops_per_sec"] == pytest.approx(71198.0)
    assert ecdsa["ecdsa_p256_verify_ops_per_sec"] == pytest.approx(22645.5)



ECDH_LOG = """Doing 256 bits  ecdh ops for 1s: 29154 256-bits ECDH ops in 1.00s
version: 3.5.4
                              op      op/s
 256 bits ecdh (nistp256)   0.0000s  29154.0
"""


def test_ecdh_ignores_the_progress_line():
    values = parser.parse_ecdh(ECDH_LOG, parser.SCENARIOS["ecdh_p256"])
    # the "Doing ... 1.00s" line must not be read as the rate
    assert values["ecdh_p256_ops_per_sec"] == pytest.approx(29154.0)

def test_digest_labels_are_lowercase_in_speed_output():
    log = TABLE_LOG.replace("SM4-GCM", "sm3").replace("SM4-CBC", "sha256")
    sm3 = parser.parse_table(log, parser.SCENARIOS["sm3"])
    assert sm3["sm3_16b_mb_per_sec"] == pytest.approx(82.05845, rel=1e-6)
    sha256 = parser.parse_table(log, parser.SCENARIOS["sha256"])
    assert sha256["sha256_16384b_mb_per_sec"] == pytest.approx(140.0)


def test_median_is_reported_and_samples_kept(tmp_path):
    runs = tmp_path / "runs"
    spec = parser.SCENARIOS["sm4_gcm"]
    directory = runs / "sm4_gcm"
    directory.mkdir(parents=True)
    (directory / "warmup1.log").write_text(TABLE_LOG, encoding="utf-8")
    for index, value in enumerate([10.0, 20.0, 30.0, 40.0, 50.0, 60.0], start=1):
        log = TABLE_LOG.replace("82058.45k", f"{value * 1000:.2f}k")
        (directory / ("rep%d.log" % index)).write_text(log, encoding="utf-8")
    results, samples = parser.collect(runs, 1, 6, ["sm4_gcm"])
    entry = results["sm4_gcm_16b_mb_per_sec"]
    assert entry["source_name"] == "sm4_gcm_16b_mb_per_sec"
    assert entry["value"] == pytest.approx(35.0)
    assert entry["samples"] == 6
    assert samples["sm4_gcm_16b_mb_per_sec"] == [pytest.approx(v) for v in
                                                 [10.0, 20.0, 30.0, 40.0, 50.0, 60.0]]


def test_missing_sample_fails(tmp_path):
    runs = tmp_path / "runs"
    _scenario("sm4_gcm", TABLE_LOG, runs, reps=5)
    with pytest.raises(parser.ParseError):
        parser.collect(runs, 1, 6, ["sm4_gcm"])


def test_extra_sample_fails(tmp_path):
    runs = tmp_path / "runs"
    _scenario("sm4_gcm", TABLE_LOG, runs, reps=7)
    with pytest.raises(parser.ParseError):
        parser.collect(runs, 1, 6, ["sm4_gcm"])


def test_missing_row_fails(tmp_path):
    runs = tmp_path / "runs"
    _scenario("sm4_gcm", TABLE_LOG.replace("SM4-GCM", "SM4-XTS"), runs)
    with pytest.raises(parser.ParseError):
        parser.collect(runs, 1, 6, ["sm4_gcm"])


def test_zero_value_fails(tmp_path):
    runs = tmp_path / "runs"
    _scenario("sm4_gcm", TABLE_LOG.replace("82058.45k", "0.00k"), runs)
    with pytest.raises(parser.ParseError):
        parser.collect(runs, 1, 6, ["sm4_gcm"])


def test_cli_writes_results_and_samples(tmp_path):
    runs = tmp_path / "runs"
    _scenario("sm4_gcm", TABLE_LOG, runs)
    out = tmp_path / "out"
    rc = parser.main([
        "--runs-dir", str(runs), "--results-dir", str(out),
        "--warmups", "1", "--samples", "6", "--version", "8.5.0",
        "--architecture", "aarch64", "--variant", "base", "--scenarios", "sm4_gcm",
    ])
    assert rc == 0
    payload = json.loads((out / "results.json").read_text(encoding="utf-8"))
    assert payload["architecture"] == "aarch64"
    assert payload["metric_count"] == 2
    assert isinstance(payload["results"], dict)
    assert set(payload["results"]) == {"sm4_gcm_16b_mb_per_sec", "sm4_gcm_16384b_mb_per_sec"}
    item = payload["results"]["sm4_gcm_16b_mb_per_sec"]
    assert item["unit"] == "MB/s"
    assert item["group"] == "sm4_gcm"
    assert len(item["sample_values"]) == 6
    assert (out / "samples.json").is_file()


def test_scenario_table_matches_shell_configuration():
    common = (CASE / "scripts" / "common.sh").read_text(encoding="utf-8")
    block = re.search(r"TONGSUO_SCENARIOS=\((.*?)\n\)", common, re.S)
    assert block, "TONGSUO_SCENARIOS not found in scripts/common.sh"
    names = [line.strip().strip('"').split("|")[0] for line in block.group(1).splitlines() if line.strip()]
    assert names == list(parser.SCENARIOS), (names, list(parser.SCENARIOS))
