"""Strict parser tests for `openssl speed -mr` sample logs."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

CASE = Path(__file__).resolve().parents[1]
PARSER = CASE / "scripts" / "results" / "parse_speed.py"
FIXTURES = json.loads((CASE / "fixtures" / "scenarios.json").read_text(encoding="utf-8"))
BLOCK = int(FIXTURES["block_bytes"])


def symmetric_log(name: str, f_index: int, count: int, seconds: float = 2.0) -> list[str]:
    return [
        f"+DT:{name}:2:{BLOCK}",
        f"+R:{count}:{name}:{seconds:.6f}",
        f"+H:{BLOCK}",
        f"+F:{f_index}:{name}:{BLOCK * count / seconds:.2f}",
    ]


def rsa_log(sign: float = 2718.0, verify: float = 90524.5) -> list[str]:
    sign_count = int(round(sign * 2.0))
    verify_count = int(round(verify * 2.0))
    return [
        "+DTP:2048:private:rsa sign:2",
        "+R1:5396:2048:1.99",
        "+DTP:2048:public:rsa verify:2",
        "+R2:180839:2048:2.00",
        "+DTP:rsa2048:signs:2",
        f"+R19:{sign_count}:rsa2048:2.00",
        "+DTP:rsa2048:verify:2",
        f"+R20:{verify_count}:rsa2048:2.00",
        "+F2:2:2048:2711.557789:90419.500000:85683.417085:2668.500000",
        f"+F9:2:41.293532:{sign:.6f}:{verify:.6f}",
    ]


def ecdsa_log(sign: float = 72427.272727, verify: float = 22563.0) -> list[str]:
    return [
        "+DTP:256:sign:prime256v1:2",
        f"+R7:{int(round(sign * 1.98))}:prime256v1:1.98",
        "+DTP:256:verify:prime256v1:2",
        f"+R8:{int(round(verify * 2.0))}:prime256v1:2.00",
        f"+F4:3:256:{sign:.6f}:{verify:.6f}",
    ]


def ed25519_log(sign: float = 52312.5, verify: float = 16532.0) -> list[str]:
    return [
        "+DTP:253:sign:Ed25519:2",
        f"+R7:{int(round(sign * 2.0))}:Ed25519:2.00",
        "+DTP:253:verify:Ed25519:2",
        f"+R8:{int(round(verify * 2.0))}:Ed25519:2.00",
        f"+F4:22:253:{sign:.6f}:{verify:.6f}",
    ]


def base_round() -> dict[str, list[str]]:
    return {
        "sha256": symmetric_log("sha256", 6, 306112),
        "sha512": symmetric_log("sha512", 7, 134955),
        "aes_128_gcm": symmetric_log("AES-128-GCM", 25, 555741, seconds=1.0),
        "aes_256_gcm": symmetric_log("AES-256-GCM", 25, 474932, seconds=1.0),
        "chacha20_poly1305": symmetric_log("ChaCha20-Poly1305", 25, 185870, seconds=1.0),
        "rsa2048": rsa_log(),
        "ecdsa_p256": ecdsa_log(),
        "ed25519": ed25519_log(),
    }


def write_sample(directory: Path, index: int, lines: list[str]) -> None:
    directory.mkdir(parents=True, exist_ok=True)
    rendered = [line for line in lines if line]
    stdout = [line for line in rendered if line.startswith(("+H", "+F"))]
    stderr = [line for line in rendered if not line.startswith(("+H", "+F"))]
    (directory / f"rep{index}.log").write_text("\n".join(stdout) + "\n", encoding="utf-8")
    (directory / f"rep{index}.err").write_text("\n".join(stderr) + "\n", encoding="utf-8")


def write_rounds(root: Path, total: int, mutations=None) -> None:
    """Write one sample per scenario, split the way `openssl speed -mr` prints:
    headers and op counts go to stderr, throughput rows go to stdout."""
    mutations = mutations or []
    for index in range(total):
        for scenario, lines in base_round().items():
            text = "\n".join(lines)
            for target, old, new in mutations:
                if target == scenario:
                    text = text.replace(old, new)
            write_sample(root / scenario, index, text.splitlines())


def run_parser(root: Path, results: Path, reps: int, warmups: int = 1) -> subprocess.CompletedProcess:
    return subprocess.run(
        [
            sys.executable, str(PARSER),
            "--runs-dir", str(root),
            "--results-dir", str(results),
            "--fixtures", str(CASE / "fixtures" / "scenarios.json"),
            "--warmups", str(warmups),
            "--reps", str(reps),
            "--version", "4.1.0",
            "--architecture", "x86_64",
            "--variant", "base",
            "--run-id", "test-run",
        ],
        text=True, capture_output=True, check=False,
    )


def test_happy_path_produces_the_sixteen_metrics(tmp_path) -> None:
    runs = tmp_path / "runs"
    results = tmp_path / "results"
    write_rounds(runs, 2)
    completed = run_parser(runs, results, reps=1)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    payload = json.loads((results / "speed_result.json").read_text(encoding="utf-8"))

    metrics = payload["results"]
    assert len(metrics) == 16
    assert payload["sampling"]["warmups"] == 1
    assert payload["sampling"]["reps"] == 1
    assert payload["sampling"]["aggregation"] == "median"

    expected_bytes = BLOCK * 306112 / 2.0
    assert metrics["sha256_bytes_per_s"]["value"] == round(expected_bytes, 6)
    assert metrics["sha256_bytes_per_s"]["unit"] == "B/s"
    assert metrics["sha256_bytes_per_s"]["group"] == "sha256"
    assert metrics["sha256_ops_per_s"]["value"] == 306112 / 2.0
    assert metrics["sha256_ops_per_s"]["unit"] == "op/s"
    assert metrics["rsa2048_sign_per_s"]["value"] == 2718.0
    assert metrics["rsa2048_verify_per_s"]["value"] == 90524.5
    assert metrics["ecdsa_p256_sign_per_s"]["value"] == 72427.272727
    assert metrics["ed25519_verify_per_s"]["value"] == 16532.0
    assert all(item["direction"] == "higher_is_better" for item in metrics.values())

    # every round, including the warmup, keeps its own parsed sample file
    for scenario in base_round():
        for index in range(2):
            sample = json.loads((runs / scenario / f"rep{index}.json").read_text(encoding="utf-8"))
            assert sample["round"] == index
            assert sample["warmup"] is (index == 0)
            assert len(sample["metrics"]) == 2


def test_median_uses_only_measured_rounds(tmp_path) -> None:
    runs = tmp_path / "runs"
    results = tmp_path / "results"
    write_rounds(runs, 2)
    # corrupt the warmup only: it must not affect the reported median
    write_sample(runs / "sha256", 0, symmetric_log("sha256", 6, 1))
    completed = run_parser(runs, results, reps=1, warmups=1)
    assert completed.returncode == 0, completed.stdout + completed.stderr
    payload = json.loads((results / "speed_result.json").read_text(encoding="utf-8"))
    assert payload["results"]["sha256_ops_per_s"]["value"] == 306112 / 2.0
    assert payload["samples"]["sha256_ops_per_s"]["samples"] == 1


def test_throughput_contradicting_the_op_count_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    value = BLOCK * 306112 / 2.0
    write_rounds(runs, 1, mutations=[
        ("sha256", f"+F:6:sha256:{value:.2f}", f"+F:6:sha256:{value * 2:.2f}"),
    ])
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "contradicts" in completed.stderr


def test_missing_throughput_row_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1, mutations=[("ed25519", "+F4:22:253:", "")])
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "expected exactly one +F4" in completed.stderr


def test_duplicate_throughput_row_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1)
    # append a duplicate of the +F row
    path = runs / "sha512" / "rep0.log"
    text = path.read_text(encoding="utf-8")
    path.write_text(text + text.splitlines()[-1] + "\n", encoding="utf-8")
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "expected exactly one +F7 row" in completed.stderr


def test_block_size_mismatch_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1, mutations=[
        ("aes_128_gcm", f"+DT:AES-128-GCM:2:{BLOCK}", f"+DT:AES-128-GCM:2:8192"),
        ("aes_128_gcm", f"+H:{BLOCK}", "+H:8192"),
    ])
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "expected" in completed.stderr


def test_missing_stderr_sample_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1)
    (runs / "rsa2048" / "rep0.err").unlink()
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "missing sample stderr log" in completed.stderr


def test_missing_round_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 2)
    (runs / "sha256" / "rep1.log").unlink()
    completed = run_parser(runs, tmp_path / "results", reps=1)
    assert completed.returncode != 0
    assert "sample rounds" in completed.stderr


def test_non_positive_throughput_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1, mutations=[
        ("sha256", f"+F:6:sha256:{BLOCK * 306112 / 2.0:.2f}", "+F:6:sha256:0"),
    ])
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "finite positive" in completed.stderr


def test_signature_rate_contradicting_the_op_count_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1, mutations=[
        ("rsa2048", "+F9:2:41.293532:2718.000000:90524.500000",
         "+F9:2:41.293532:3000.000000:90524.500000"),
    ])
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "contradicts" in completed.stderr


def test_unknown_machine_readable_row_fails(tmp_path) -> None:
    runs = tmp_path / "runs"
    write_rounds(runs, 1)
    path = runs / "sha256" / "rep0.log"
    path.write_text(path.read_text(encoding="utf-8") + "+XYZ:not-a-row\n", encoding="utf-8")
    completed = run_parser(runs, tmp_path / "results", reps=1, warmups=0)
    assert completed.returncode != 0
    assert "unrecognised machine readable row" in completed.stderr
