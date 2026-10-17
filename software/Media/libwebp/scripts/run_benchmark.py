#!/usr/bin/env python3
"""Run the official cwebp/dwebp benchmarks and normalize time metrics.

The libwebp project ships no dedicated benchmark tool, but its official
command-line apps carry the maintainers' own timing instrumentation: in
verbose mode cwebp prints ``Time to encode picture: X.XXXs`` around the
pure WebPEncode call and dwebp prints ``Time to decode picture: X.XXXs``
around the pure DecodeWebP call (both exclude file I/O).  This driver runs
the official CLIs over fixed LCG-generated PPM images and takes the median
of repeated runs per scenario.

Scenario matrix: {encode, decode} x {1920x1080, 3840x2160} x {lossy,
lossless} — cwebp's two compression modes with their default settings
(lossy: default quality 75; lossless: the documented ``-z 6`` preset).
Decode scenarios decode the corresponding encode output.  The official
``-mt`` flag is not part of the matrix: libwebp's lossy pipeline is
effectively single-threaded (measured delta < 3%), so a thread ladder
would only measure scheduler noise.
"""

from __future__ import annotations

import json
import os
import re
import statistics
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

LOADS: tuple[tuple[str, int, int], ...] = (
    ("1920x1080", 1920, 1080),
    ("3840x2160", 3840, 2160),
)
MODES: tuple[tuple[str, tuple[str, ...]], ...] = (
    # cwebp lossy: default settings (quality 75).  cwebp lossless: the
    # documented -z 6 preset (lossless, effort 6).
    ("lossy", ()),
    ("lossless", ("-z", "6")),
)
# Measured runs per scenario (one additional warmup run is discarded).
ITERATIONS = 5
RUN_TIMEOUT_SECONDS = 600

ENCODE_TIME_RE = re.compile(r"Time to encode picture: ([\d.]+)s")
DECODE_TIME_RE = re.compile(r"Time to decode picture: ([\d.]+)s")


def fail(message: str) -> None:
    print(f"[webp-benchmark] ERROR: {message}", file=sys.stderr)


def run_cli(command: list[str]) -> str:
    completed = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=RUN_TIMEOUT_SECONDS,
        check=False,
    )
    if completed.returncode:
        raise RuntimeError(
            f"{command[0]} exited with code {completed.returncode}: {' '.join(command)}"
        )
    return completed.stdout


def parse_time(text: str, pattern: re.Pattern[str], scenario: str) -> float:
    matches = pattern.findall(text)
    if len(matches) != 1:
        raise RuntimeError(
            f"scenario {scenario}: expected exactly one timing line, got {len(matches)}"
        )
    seconds = float(matches[0])
    if seconds <= 0:
        raise RuntimeError(f"scenario {scenario}: non-positive time {seconds}")
    return seconds


def median_ms(samples_s: list[float]) -> float:
    return round(statistics.median(samples_s) * 1000.0, 3)


def main() -> int:
    if len(sys.argv) != 6:
        print(
            "usage: run_benchmark.py CWEBP DWEBP WORK_DIR RAW_OUTPUT RESULTS_JSON\n"
            "  WORK_DIR holds the pre-generated <load>.ppm inputs and receives\n"
            "  the intermediate .webp / .ppm files",
            file=sys.stderr,
        )
        return 1
    cwebp = Path(sys.argv[1])
    dwebp = Path(sys.argv[2])
    work_dir = Path(sys.argv[3])
    raw_output = Path(sys.argv[4])
    results_output = Path(sys.argv[5])

    for required in (cwebp, dwebp):
        if not required.is_file() or not os.access(required, os.X_OK):
            fail(f"official binary is unavailable: {required}")
            return 1
    if not work_dir.is_dir():
        fail(f"work directory is unavailable: {work_dir}")
        return 1

    try:
        version = os.environ["SOFTWARE_VERSION"]
        architecture = os.environ["EXPECTED_ARCH"]
    except KeyError as exc:
        fail(f"missing environment variable: {exc}")
        return 1

    # Verify the binaries under test identify as the requested version
    # (cwebp -version prints the libwebp release number).
    version_output = run_cli([str(cwebp), "-version"])
    reported_version = version_output.splitlines()[0].strip()
    if reported_version != version:
        fail(
            f"cwebp reports version {reported_version or 'unknown'}, expected {version}"
        )
        return 1

    results: dict[str, dict[str, Any]] = {}
    raw_lines: list[str] = [
        "# libwebp official benchmark (cwebp/dwebp -v timing)",
        f"# cwebp -version: {version_output.strip()}",
    ]

    try:
        for load_name, _, _ in LOADS:
            ppm_input = work_dir / f"{load_name}.ppm"
            if not ppm_input.is_file():
                raise RuntimeError(f"benchmark input is unavailable: {ppm_input}")

            for mode, mode_flags in MODES:
                # ---- encode ----
                webp_output = work_dir / f"{load_name}_{mode}.webp"
                scenario = f"encode {load_name} {mode}"
                raw_lines.append(f"### {scenario}")
                encode_command = [
                    str(cwebp), "-v", *mode_flags,
                    str(ppm_input), "-o", str(webp_output),
                ]
                samples_s: list[float] = []
                for _ in range(ITERATIONS + 1):
                    text = run_cli(encode_command)
                    raw_lines.append(text.rstrip())
                    seconds = parse_time(text, ENCODE_TIME_RE, scenario)
                    samples_s.append(seconds)
                # The first run warms the page cache; discard it.
                samples_s = samples_s[1:]
                value_ms = median_ms(samples_s)
                source_name = f"cwebp {load_name} {mode}: median"
                results[source_name] = {
                    "source_name": source_name,
                    "scenario": f"encode {load_name}",
                    "mode": mode,
                    "source_field": "median",
                    "value": value_ms,
                    "unit": "ms",
                    "direction": "lower_is_better",
                    "samples": [round(s * 1000.0, 3) for s in samples_s],
                }

                # ---- decode (the encode output from the same mode) ----
                if not webp_output.is_file():
                    raise RuntimeError(f"decode input is unavailable: {webp_output}")
                decode_output = work_dir / f"{load_name}_{mode}_decode.ppm"
                scenario = f"decode {load_name} {mode}"
                raw_lines.append(f"### {scenario}")
                decode_command = [
                    str(dwebp), "-v", "-ppm", str(webp_output), "-o", str(decode_output),
                ]
                samples_s = []
                for _ in range(ITERATIONS + 1):
                    text = run_cli(decode_command)
                    raw_lines.append(text.rstrip())
                    seconds = parse_time(text, DECODE_TIME_RE, scenario)
                    samples_s.append(seconds)
                samples_s = samples_s[1:]
                value_ms = median_ms(samples_s)
                source_name = f"dwebp {load_name} {mode}: median"
                results[source_name] = {
                    "source_name": source_name,
                    "scenario": f"decode {load_name}",
                    "mode": mode,
                    "source_field": "median",
                    "value": value_ms,
                    "unit": "ms",
                    "direction": "lower_is_better",
                    "samples": [round(s * 1000.0, 3) for s in samples_s],
                }
                decode_output.unlink(missing_ok=True)
    except (RuntimeError, OSError, subprocess.SubprocessError) as exc:
        fail(str(exc))
        return 1

    expected = 2 * len(LOADS) * len(MODES)
    if len(results) != expected:
        fail(f"expected {expected} scenarios, collected {len(results)}")
        return 1

    payload = {
        "software": "libwebp",
        "version": version,
        "architecture": architecture,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "parameters": {
            "tools": "official examples/cwebp + examples/dwebp (-v timing output)",
            "loads": [name for name, _, _ in LOADS],
            "modes": {
                "lossy": "cwebp defaults (quality 75)",
                "lossless": "cwebp -z 6 preset",
            },
            "iterations": ITERATIONS,
            "input": "fixed LCG-generated PPM images (byte-identical on every arch)",
            "metric_source": "cwebp/dwebp 'Time to encode/decode picture' lines",
            "metric": "median of measured runs in ms, lower is better",
        },
        "results": results,
    }

    raw_output.parent.mkdir(parents=True, exist_ok=True)
    raw_output.write_text("\n".join(raw_lines) + "\n", encoding="utf-8")
    results_output.parent.mkdir(parents=True, exist_ok=True)
    results_output.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"[webp-benchmark] normalized {len(results)} libwebp timing metrics")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
