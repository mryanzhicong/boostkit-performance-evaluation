"""Strictness tests for the fio repetition parser."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

import pytest

CASE_DIR = Path(__file__).resolve().parents[1]
PARSER = CASE_DIR / "scripts" / "results" / "parse_benchmark.py"
sys.path.insert(0, str(PARSER.parent))

import parse_benchmark as parser  # noqa: E402

NUMJOBS = 4
IODEPTH = 128
RUNTIME = 600


def report(
    *,
    version: str = "3.34",
    numjobs: int = NUMJOBS,
    iodepth: int = IODEPTH,
    rw: str = "randrw",
    bs: int = 4096,
    errors: int = 0,
    duration_ms: int = RUNTIME * 1000,
    read_iops: str = "153k",
    write_iops: str = "65.9k",
    read_bw: str = "598",
    write_bw: str = "257",
    read_avg: str = "2318.74",
    write_avg: str = "2321.42",
    read_p99: str = "4817",
    write_p99: str = "4817",
    drop_write: bool = False,
) -> str:
    lines = [
        f"randrw_4k: (g=0): rw={rw}, bs=(R) {bs}B-{bs}B, (W) {bs}B-{bs}B, (T) {bs}B-{bs}B, ioengine=libaio, iodepth={iodepth}",
        f"fio-{version}",
        f"Starting {numjobs} thread" + ("" if numjobs == 1 else "s"),
        "",
        f"randrw_4k: (groupid=0, jobs={numjobs}): err={errors:2d}: pid=1234: Sat Nov 28 03:56:20 2026",
        f"  read: IOPS={read_iops}, BW={read_bw}MiB/s (627MB/s)(4787MiB/{duration_ms}msec)",
        "    slat (nsec): min=458, max=2054.0k, avg=17612.77, stdev=50994.40",
        f"    clat (usec): min=42, max=10603, avg={read_avg}, stdev=760.97",
        "     lat (usec): min=115, max=10605, avg=2336.42, stdev=764.31",
        "    clat percentiles (usec):",
        "     |  1.00th=[  938],  5.00th=[ 1319], 10.00th=[ 1500], 20.00th=[ 1729],",
        "     | 30.00th=[ 1893], 40.00th=[ 2057], 50.00th=[ 2212], 60.00th=[ 2376],",
        "     | 70.00th=[ 2573], 80.00th=[ 2835], 90.00th=[ 3261], 95.00th=[ 3687],",
        f"     | 99.00th=[ {read_p99}], 99.50th=[ 5342], 99.90th=[ 6390], 99.95th=[ 6849],",
        "     | 99.99th=[ 7635]",
        "   bw (  KiB/s): min=381705, max=711592, per=100.00%, avg=612592.00, stdev=20751.89, samples=64",
        "   iops        : min=95424, max=177900, avg=153147.81, stdev=5188.03, samples=64",
    ]
    if not drop_write:
        lines += [
            f"  write: IOPS={write_iops}, BW={write_bw}MiB/s (270MB/s)(2060MiB/{duration_ms}msec); 0 zone resets",
            "    slat (nsec): min=477, max=1763.0k, avg=17906.61, stdev=51112.74",
            f"    clat (usec): min=116, max=10496, avg={write_avg}, stdev=761.83",
            "     lat (usec): min=128, max=10519, avg=2339.40, stdev=765.14",
            "    clat percentiles (usec):",
            "     |  1.00th=[  930],  5.00th=[ 1319], 10.00th=[ 1500], 20.00th=[ 1729],",
            "     | 30.00th=[ 1893], 40.00th=[ 2057], 50.00th=[ 2212], 60.00th=[ 2376],",
            "     | 70.00th=[ 2573], 80.00th=[ 2835], 90.00th=[ 3261], 95.00th=[ 3687],",
            f"     | 99.00th=[ {write_p99}], 99.50th=[ 5342], 99.90th=[ 6390], 99.95th=[ 6783],",
            "     | 99.99th=[ 7701]",
            "   bw (  KiB/s): min=164552, max=305752, per=100.00%, avg=263673.12, stdev=8873.53, samples=64",
            "   iops        : min=41137, max=76438, avg=65918.06, stdev=2218.41, samples=64",
            "  lat (usec)   : 50=0.01%, 250=0.04%, 500=0.15%, 750=0.30%, 1000=0.82%",
            "  lat (msec)   : 2=35.05%, 4=60.67%, 10=3.00%, 20=0.01%",
            "  cpu          : usr=4.19%, sys=9.77%, ctx=842822, majf=0, minf=0",
            "  IO depths    : 1=0.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=100.0%",
            "     issued rwts: total=1225033,527258,0,0 short=0,0,0,0 dropped=0,0,0,0",
        ]
    lines += [
        "",
        "Run status group 0 (all jobs):",
        "   READ: bw=598MiB/s (627MB/s), 598MiB/s-598MiB/s (627MB/s-627MB/s), io=4787MiB (5019MB), run=8001-8001msec",
        "  WRITE: bw=257MiB/s (270MB/s), 257MiB/s-257MiB/s (270MB/s-270MB/s), io=2060MiB (2160MB), run=8001-8001msec",
        "",
    ]
    return "\n".join(lines) + "\n"


def expected(**overrides) -> dict:
    base = {
        "version": "3.34",
        "numjobs": NUMJOBS,
        "iodepth": IODEPTH,
        "rw": "randrw",
        "block_size_bytes": 4096,
        "runtime_seconds": RUNTIME,
    }
    base.update(overrides)
    return base


def write_rep(tmp_path: Path, text: str, rep: int = 2) -> Path:
    path = tmp_path / f"rep{rep}.log"
    path.write_text(text, encoding="utf-8")
    return path


def test_parses_a_complete_repetition(tmp_path: Path) -> None:
    directions = parser.parse_repetition(write_rep(tmp_path, report()), expected())
    assert directions["read"]["iops"] == pytest.approx(153_000.0)
    assert directions["write"]["iops"] == pytest.approx(65_900.0)
    assert directions["read"]["bw_mib_s"] == pytest.approx(598.0)
    assert directions["read"]["clat_avg_us"] == pytest.approx(2318.74)
    assert directions["write"]["clat_p99_us"] == pytest.approx(4817.0)
    assert directions["read"]["duration_ms"] == RUNTIME * 1000


def test_rejects_a_wrong_version(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(version="3.28")), expected())


def test_rejects_a_wrong_queue_depth(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(iodepth=IODEPTH * 2)), expected())


def test_rejects_a_wrong_job_count(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(numjobs=NUMJOBS + 1)), expected())


def test_rejects_a_wrong_block_size(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(bs=4096 * 2)), expected())


def test_rejects_a_run_error(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(errors=3)), expected())


def test_rejects_a_short_run(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(duration_ms=60_000)), expected())


def test_rejects_a_missing_write_report(tmp_path: Path) -> None:
    with pytest.raises(parser.ParseError):
        parser.parse_repetition(write_rep(tmp_path, report(drop_write=True)), expected())


def test_requires_one_warmup_and_five_measured_repetitions(tmp_path: Path) -> None:
    for rep in range(1, 6):
        write_rep(tmp_path, report(), rep)
    with pytest.raises(parser.ParseError):
        parser.collect(tmp_path, 5, expected())


def test_medians_ignore_the_warmup_repetition(tmp_path: Path) -> None:
    samples = []
    values = [(100.0, 200.0), (300.0, 400.0), (500.0, 600.0), (700.0, 800.0)]
    samples.append(
        {
            "read": {"iops": 1.0, "bw_mib_s": 1.0, "clat_avg_us": 999.0, "clat_p99_us": 999.0, "duration_ms": RUNTIME * 1000},
            "write": {"iops": 1.0, "bw_mib_s": 1.0, "clat_avg_us": 999.0, "clat_p99_us": 999.0, "duration_ms": RUNTIME * 1000},
        }
    )
    for read_iops, write_iops in values:
        samples.append(
            {
                "read": {"iops": read_iops, "bw_mib_s": read_iops / 10, "clat_avg_us": read_iops, "clat_p99_us": read_iops, "duration_ms": RUNTIME * 1000},
                "write": {"iops": write_iops, "bw_mib_s": write_iops / 10, "clat_avg_us": write_iops, "clat_p99_us": write_iops, "duration_ms": RUNTIME * 1000},
            }
        )
    results, per_rep = parser.build_metrics(samples)
    assert results["fio.read.iops"]["value"] == pytest.approx(400.0)
    assert results["fio.write.iops"]["value"] == pytest.approx(500.0)
    assert results["fio.read.iops"]["direction"] == "higher_is_better"
    assert results["fio.read.clat_avg_us"]["direction"] == "lower_is_better"
    assert list(per_rep) == ["rep2", "rep3", "rep4", "rep5"]


def test_cli_writes_the_normalized_payload(tmp_path: Path) -> None:
    runs = tmp_path / "runs"
    runs.mkdir()
    for rep in range(1, 7):
        (runs / f"rep{rep}.log").write_text(
            report(read_iops="100k", write_iops="40k", read_bw="400", write_bw="160"),
            encoding="utf-8",
        )
    output = tmp_path / "benchmark_fio.json"
    result = subprocess.run(
        [
            sys.executable,
            str(PARSER),
            "--runs-dir",
            str(runs),
            "--reps",
            "6",
            "--output",
            str(output),
        ],
        capture_output=True,
        text=True,
        env={
            "SOFTWARE_VERSION": "3.34",
            "EXPECTED_ARCH": "aarch64",
            "FIO_NUMJOBS": str(NUMJOBS),
            "FIO_IODEPTH": str(IODEPTH),
            "FIO_BLOCK_SIZE": "4k",
            "FIO_RUNTIME": str(RUNTIME),
            "FIO_RW": "randrw",
            "FIO_LV_COUNT": "4",
            "FIO_LV_SIZE_GIB": "16",
            "PATH": "/usr/bin:/bin",
        },
        check=False,
    )
    assert result.returncode == 0, result.stderr
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["software"] == "fio"
    assert payload["version"] == "3.34"
    assert payload["architecture"] == "aarch64"
    assert payload["samples"]["measured"] == 5
    assert payload["samples"]["warmup"] == 1
    assert payload["parameters"]["logical_volumes"] == "4"
    assert payload["parameters"]["workload"]["iodepth"] == IODEPTH
    assert len(payload["results"]) == 12
    assert payload["results"]["fio.read.iops"]["value"] == pytest.approx(100_000.0)
    assert payload["results"]["fio.write.bw_mib"]["value"] == pytest.approx(160.0)


def test_parses_a_real_fio_console_sample() -> None:
    """The captured sample comes from a real fio 3.28 run (4k randrw, qd128, 8 s)."""
    sample = CASE_DIR / "tests" / "data" / "sample-fio-3.28-qd128.log"
    directions = parser.parse_repetition(
        sample,
        {
            "version": "3.28",
            "numjobs": 4,
            "iodepth": 128,
            "rw": "randrw",
            "block_size_bytes": 4096,
            "runtime_seconds": 8,
        },
    )
    assert directions["read"]["iops"] == pytest.approx(153147.81, rel=0.2)
    assert directions["write"]["iops"] == pytest.approx(65918.06, rel=0.2)
    assert directions["read"]["clat_p99_us"] == pytest.approx(4817.0)
    assert directions["read"]["duration_ms"] == 8001


def test_percentiles_are_scaled_from_milliseconds(tmp_path: Path) -> None:
    """Under emulation the whole distribution lands in the msec table."""
    text = report()
    text = text.replace("clat percentiles (usec):", "clat percentiles (msec):")
    text = text.replace("| 99.00th=[ 4817]", "| 99.00th=[  100]")
    text = text.replace("|  1.00th=[  938]", "|  1.00th=[   69]")
    directions = parser.parse_repetition(
        write_rep(tmp_path, text), expected()
    )
    assert directions["read"]["clat_p99_us"] == pytest.approx(100000.0)
    assert directions["write"]["clat_p99_us"] == pytest.approx(100000.0)


def test_parses_the_real_guest_run() -> None:
    """The sample is rep 1 of a real fio 3.34 run inside the reference VM."""
    sample = CASE_DIR / "tests" / "data" / "sample-fio-3.34-qd128-local.log"
    directions = parser.parse_repetition(
        sample,
        {
            "version": "3.34",
            "numjobs": 4,
            "iodepth": 128,
            "rw": "randrw",
            "block_size_bytes": 4096,
            "runtime_seconds": 20,
        },
    )
    assert directions["read"]["iops"] == pytest.approx(4301.0, rel=0.2)
    assert directions["write"]["iops"] == pytest.approx(1850.0, rel=0.2)
    assert directions["read"]["clat_p99_us"] == pytest.approx(100000.0)
    assert directions["write"]["clat_p99_us"] == pytest.approx(100000.0)
    assert directions["read"]["duration_ms"] == 20013


def test_accepts_the_singular_thread_banner(tmp_path: Path) -> None:
    """A single-job run prints "Starting 1 thread"."""
    text = report(numjobs=1, read_iops="3448", write_iops="1478")
    text = text.replace("Starting 1 thread", "Starting 1 thread")
    directions = parser.parse_repetition(
        write_rep(tmp_path, text),
        {
            "version": "3.34",
            "numjobs": 1,
            "iodepth": IODEPTH,
            "rw": "randrw",
            "block_size_bytes": 4096,
            "runtime_seconds": RUNTIME,
        },
    )
    assert directions["read"]["iops"] == pytest.approx(3448.0)


def test_average_latency_is_scaled_from_its_own_unit(tmp_path: Path) -> None:
    """A rep whose whole distribution is slow prints avg in msec as well."""
    text = report()
    text = text.replace("    clat (usec): min=42, max=10603, avg=2318.74, stdev=760.97",
                        "    clat (msec): min=4, max=106, avg=84.10, stdev= 6.23")
    directions = parser.parse_repetition(write_rep(tmp_path, text), expected())
    assert directions["read"]["clat_avg_us"] == pytest.approx(84100.0)


def test_average_latency_accepts_the_nanosecond_table(tmp_path: Path) -> None:
    """numjobs=1 on fast storage reports nsec with k-suffixed min/max values."""
    text = report()
    text = text.replace("    clat (usec): min=42, max=10603, avg=2318.74, stdev=760.97",
                        "    clat (nsec): min=570, max=3554.9k, avg=27316.33, stdev=3012.76")
    directions = parser.parse_repetition(write_rep(tmp_path, text), expected())
    assert directions["read"]["clat_avg_us"] == pytest.approx(27.31633)
