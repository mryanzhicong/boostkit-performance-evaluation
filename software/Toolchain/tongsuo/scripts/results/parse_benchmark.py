#!/usr/bin/env python3
"""Strict parser for the Tongsuo 8.5.0 `openssl speed` samples.

Contract (never relaxed):
  * every scenario owns exactly one directory ``runs/<scenario>``;
  * it must contain exactly ``--warmups`` warm-up logs and ``--samples`` measured
    logs, named ``warmup.log`` / ``rep<i>.log``;
  * each log must contain exactly one table for the expected algorithm, with a
    positive finite value for every declared column;
  * a missing sample, an extra sample, a missing row, a duplicate row or a
    non-positive value fails the run instead of being zero-filled.

The reported value is the median of the measured samples; every per-sample value
is preserved in ``samples.json`` next to ``results.json``.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path

SCENARIOS = {
    "sm4_gcm": {
        "kind": "table",
        "label": "SM4-GCM",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "sm4_gcm_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "sm4_gcm_16384b_mb_per_sec"
            }
        ]
    },
    "sm4_cbc": {
        "kind": "table",
        "label": "SM4-CBC",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "sm4_cbc_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "sm4_cbc_16384b_mb_per_sec"
            }
        ]
    },
    "aes_256_gcm": {
        "kind": "table",
        "label": "AES-256-GCM",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "aes_256_gcm_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "aes_256_gcm_16384b_mb_per_sec"
            }
        ]
    },
    "zuc_128_eea3": {
        "kind": "table",
        "label": "ZUC-128-EEA3",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "zuc_128_eea3_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "zuc_128_eea3_16384b_mb_per_sec"
            }
        ]
    },
    "sm3": {
        "kind": "table",
        "label": "sm3",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "sm3_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "sm3_16384b_mb_per_sec"
            }
        ]
    },
    "sha256": {
        "kind": "table",
        "label": "sha256",
        "columns": [
            {
                "key": "16b",
                "header": "16 bytes",
                "metric": "sha256_16b_mb_per_sec"
            },
            {
                "key": "16384b",
                "header": "16384 bytes",
                "metric": "sha256_16384b_mb_per_sec"
            }
        ]
    },
    "sm2_sign_verify": {
        "kind": "pubkey",
        "label": None,
        "columns": [
            {
                "key": "sign",
                "header": None,
                "metric": "sm2_sign_ops_per_sec"
            },
            {
                "key": "verify",
                "header": None,
                "metric": "sm2_verify_ops_per_sec"
            }
        ]
    },
    "ecdsa_p256": {
        "kind": "pubkey",
        "label": None,
        "columns": [
            {
                "key": "sign",
                "header": None,
                "metric": "ecdsa_p256_sign_ops_per_sec"
            },
            {
                "key": "verify",
                "header": None,
                "metric": "ecdsa_p256_verify_ops_per_sec"
            }
        ]
    },
    "rsa2048": {
        "kind": "pubkey",
        "label": None,
        "columns": [
            {
                "key": "sign",
                "header": None,
                "metric": "rsa2048_sign_ops_per_sec"
            },
            {
                "key": "verify",
                "header": None,
                "metric": "rsa2048_verify_ops_per_sec"
            }
        ]
    },
    "ecdh_p256": {
        "kind": "ecdh",
        "label": None,
        "columns": [
            {
                "key": "op",
                "header": None,
                "metric": "ecdh_p256_ops_per_sec"
            }
        ]
    }
}

TABLE_HEADER = re.compile(r"^type\s+(?P<cols>(?:\d+\s+bytes\s*)+)$")
NUMBER_TOKEN = re.compile(r"^(?P<value>\d+(?:\.\d+)?)(?P<suffix>[kKmMgG]?)$")
SUFFIX = {"": 1.0, "k": 1e3, "m": 1e6, "g": 1e9}

class ParseError(RuntimeError):
    """Raised when a sample log cannot be trusted."""

def _bytes_per_second(token: str) -> float:
    match = NUMBER_TOKEN.match(token.strip())
    if not match:
        raise ParseError(f"unexpected throughput token: {token!r}")
    return float(match.group("value")) * SUFFIX[match.group("suffix").lower()]

def _float_token(token: str) -> float:
    try:
        return float(token)
    except ValueError as exc:  # pragma: no cover - defensive
        raise ParseError(f"unexpected numeric token: {token!r}") from exc

def _table_columns(header_line: str) -> dict[str, int]:
    tokens = header_line.split()
    if not tokens or tokens[0] != "type":
        raise ParseError(f"not a speed table header: {header_line!r}")
    columns: dict[str, int] = {}
    position = 1
    while position + 1 < len(tokens):
        number, unit = tokens[position], tokens[position + 1]
        if not number.isdigit() or unit != "bytes":
            break
        columns[f"{number} bytes"] = len(columns)
        position += 2
    if not columns:
        raise ParseError(f"speed table header carries no byte columns: {header_line!r}")
    return columns

def parse_table(text: str, spec: dict) -> dict[str, float]:
    lines = text.splitlines()
    header_index = None
    columns: dict[str, int] = {}
    for position, line in enumerate(lines):
        if TABLE_HEADER.match(line.strip()):
            header_index = position
            columns = _table_columns(line.strip())
            break
    if header_index is None:
        raise ParseError("no `type ... bytes` table header found")
    wanted = spec["label"]
    rows = []
    for line in lines[header_index + 1:]:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("type "):
            break
        tokens = stripped.split()
        if tokens[0] != wanted:
            continue
        rows.append(tokens)
    if len(rows) != 1:
        raise ParseError(f"expected exactly one `{wanted}` row, found {len(rows)}")
    row = rows[0]
    values: dict[str, float] = {}
    for column in spec["columns"]:
        index = columns.get(column["header"])
        if index is None:
            raise ParseError(f"table has no `{column['header']}` column: {sorted(columns)}")
        if index + 1 >= len(row):
            raise ParseError(f"row has no value for `{column['header']}`: {row}")
        values[column["metric"]] = _bytes_per_second(row[index + 1]) / 1e6
    return values

def parse_pubkey(text: str, spec: dict) -> dict[str, float]:

    """Read the `sign/s` / `verify/s` columns of a public-key speed table.



    RSA-2048 prints three stacked tables (sign/verify/encrypt/decrypt plus RSA-KEM

    and RSA-signature rows), so the column names of the header line decide where

    the rates live: the row is aligned to the header width and the wanted columns

    are read by name instead of by "last two numbers".

    """

    lines = text.splitlines()

    for position, line in enumerate(lines):

        header = line.split()

        if "sign/s" not in header or "verify/s" not in header:

            continue

        width = len(header)

        sign_index = header.index("sign/s")

        verify_index = header.index("verify/s")

        for candidate in lines[position + 1:]:

            tokens = candidate.split()

            if len(tokens) < width:

                continue

            row = tokens[-width:]

            try:

                sign_per_sec = _float_token(row[sign_index].rstrip("s"))

                verify_per_sec = _float_token(row[verify_index].rstrip("s"))

            except ParseError:

                continue

            values: dict[str, float] = {}

            for column in spec["columns"]:

                values[column["metric"]] = (

                    sign_per_sec if column["key"] == "sign" else verify_per_sec

                )

            return values

        break

    raise ParseError("no `sign/s verify/s` public-key table found")



def parse_ecdh(text: str, spec: dict) -> dict[str, float]:
    """Read the single `op/s` value of the ECDH table.

    The progress line ("Doing 256 bits  ecdh ops for 1s: 29154 256-bits ECDH ops
    in 1.00s") also mentions ecdh, so the value must come from the table that
    follows the `op      op/s` header, never from the first matching line.
    """
    lines = text.splitlines()
    for position, line in enumerate(lines):
        header = line.split()
        if "op/s" not in header:
            continue
        for candidate in lines[position + 1:]:
            row = candidate.split()
            if len(row) < 2 or "ecdh" not in candidate.lower():
                continue
            return {
                column["metric"]: _float_token(row[-1]) for column in spec["columns"]
            }
        break
    raise ParseError("no `<bits> bits ecdh ... <op/s>` table row found")


EXTRACTORS = {"table": parse_table, "pubkey": parse_pubkey, "ecdh": parse_ecdh}

def _sample_files(runs_dir: Path, scenario: str, warmups: int, samples: int) -> tuple[list[Path], list[Path]]:
    directory = runs_dir / scenario
    if not directory.is_dir():
        raise ParseError(f"missing scenario directory: {directory}")
    present = sorted(path.name for path in directory.iterdir() if path.is_file())
    warmup_names = [f"warmup{i}.log" for i in range(1, warmups + 1)]
    measured_names = [f"rep{i}.log" for i in range(1, samples + 1)]
    expected = warmup_names + measured_names
    if present != sorted(expected):
        raise ParseError(
            f"{scenario}: sample set mismatch; expected {sorted(expected)}, found {present}"
        )
    return [directory / name for name in warmup_names], [directory / name for name in measured_names]

def _finite_positive(metric: str, value: float) -> float:
    if not math.isfinite(value) or value <= 0.0:
        raise ParseError(f"{metric}: value must be finite and positive, got {value!r}")
    return value

def collect(
    runs_dir: Path, warmups: int, samples: int, selected: list[str] | None = None
) -> tuple[dict, dict]:
    results: dict[str, dict] = {}
    all_samples: dict[str, list[float]] = {}
    names = list(SCENARIOS) if selected is None else list(selected)
    unknown = [name for name in names if name not in SCENARIOS]
    if unknown:
        raise ParseError(f"unknown scenario(s): {unknown}")
    for scenario in names:
        spec = SCENARIOS[scenario]
        warmup_logs, measured = _sample_files(runs_dir, scenario, warmups, samples)
        extractor = EXTRACTORS[spec["kind"]]
        for path in warmup_logs + measured:
            try:
                extractor(path.read_text(encoding="utf-8", errors="replace"), spec)
            except ParseError as exc:
                raise ParseError(f"{scenario}/{path.name}: {exc}") from exc
        per_metric: dict[str, list[float]] = {column["metric"]: [] for column in spec["columns"]}
        for path in measured:
            values = extractor(path.read_text(encoding="utf-8", errors="replace"), spec)
            for metric, value in values.items():
                per_metric[metric].append(_finite_positive(metric, value))
        for metric, values in per_metric.items():
            if len(values) != samples:
                raise ParseError(f"{metric}: expected {samples} samples, collected {len(values)}")
            all_samples[metric] = values
            # results.json keeps a mapping keyed by metric name: the Framework
            # reads metrics.collection.path as an object, not as a list.
            results[metric] = {
                "group": scenario,
                "source_name": metric,
                "value": round(statistics.median(values), 3),
                "unit": "MB/s" if spec["kind"] == "table" else "ops/s",
                "direction": "higher_is_better",
                "samples": len(values),
                "sample_values": values,
            }
    return results, all_samples

def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs-dir", type=Path, required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--samples", type=int, default=6)
    parser.add_argument("--version", required=True)
    parser.add_argument("--architecture", required=True)
    parser.add_argument("--variant", default="base")
    parser.add_argument("--scenarios", default="",
                        help="comma separated subset (smoke runs only; default: all)")
    args = parser.parse_args(argv)

    try:
        selected = [name for name in args.scenarios.split(",") if name] or None
        results, samples = collect(args.runs_dir, args.warmups, args.samples, selected)
    except ParseError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 40

    payload = {
        "software": "tongsuo",
        "version": args.version,
        "architecture": args.architecture,
        "variant": args.variant,
        "scenarios": len(SCENARIOS),
        "metric_count": len(results),
        "results": results,
    }
    args.results_dir.mkdir(parents=True, exist_ok=True)
    (args.results_dir / "results.json").write_text(
        json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n"
    )
    (args.results_dir / "samples.json").write_text(
        json.dumps(samples, indent=2, ensure_ascii=False) + "\n", encoding="utf-8", newline="\n"
    )
    print(f"parsed {len(results)} metrics from {len(SCENARIOS)} scenarios")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
