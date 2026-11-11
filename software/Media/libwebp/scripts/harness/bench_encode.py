#!/usr/bin/env python3
"""Measure stock libwebp 1.2.1 lossless encoding, without CPU pinning.

Ported from the untouched open-box task material
(``Test/libwebp/scripts/bench.py`` @ 21154155).  Everything that decides a
number is kept identical to the reference:

* the inputs are the script-generated 1920x1080 and 1280x720 RGBA dashboard
  PNGs (see ``generate_inputs.py``), not external media;
* the measured command is ``cwebp -quiet -lossless -z 0 -exact -mt <png>
  -o <webp>`` -- one full process: start-up, PNG read, lossless compression and
  the WebP write are all inside the timed region;
* one warm-up per scenario runs the encoder and then ``dwebp -quiet -pam``; the
  decoded pixels must be ``width * height * 4`` bytes.  Input generation and
  the decode check are outside the timed region;
* the published value is the arithmetic mean of 20 timed iterations.

Two deliberate differences from the reference harness: paths come from CLI
arguments instead of the hard-coded ``/home/test/Test`` tree, and the harness
records affinity evidence.  Nothing is pinned -- neither here nor in the
reference material.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import statistics
import subprocess
import sys
import time
from pathlib import Path

from generate_inputs import digest, prepare_inputs

COMPLETE_MARKER = "LIBWEBP_BENCH_COMPLETE"
CSV_FIELDS = ["scenario", "iterations", "ms_per_image", "status"]
MIN_SAMPLES = 5


def fail(message: str) -> int:
    print(f"ERROR: {message}", file=sys.stderr)
    return 1


def run(
    command: list[str], env: dict[str, str], timeout: int = 300
) -> subprocess.CompletedProcess:
    return subprocess.run(
        command,
        env=env,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
    )


def timed_run(command: list[str], env: dict[str, str]) -> float:
    """Run one measured encode and return its wall time in milliseconds."""
    started = time.perf_counter_ns()
    run(command, env)
    return (time.perf_counter_ns() - started) / 1e6


def decoded_pixel_bytes(pam: Path) -> int:
    """Return the pixel payload size of a dwebp PAM file (header excluded)."""
    payload = pam.read_bytes()
    marker = b"ENDHDR\n"
    position = payload.find(marker)
    if position < 0:
        raise ValueError(f"decoded PAM has no ENDHDR header terminator: {pam}")
    return len(payload[position + len(marker) :])


def describe_failure(prefix: str, error: subprocess.CalledProcessError) -> str:
    command_text = " ".join(str(part) for part in error.cmd)
    output = (error.output or b"").decode("utf-8", "replace").strip()
    detail = f"; output: {output}" if output else ""
    return f"{prefix}: command failed with exit {error.returncode}: {command_text}{detail}"


def validate_scenarios(manifest: dict) -> list[dict]:
    scenarios = manifest.get("scenarios")
    if not isinstance(scenarios, list) or not scenarios:
        raise ValueError("manifest must declare a non-empty 'scenarios' list")
    names = set()
    for scenario in scenarios:
        if not isinstance(scenario, dict):
            raise ValueError("every manifest scenario must be an object")
        for field in ("name", "group", "subgroup", "width", "height", "encoder_options"):
            if field not in scenario:
                raise ValueError(f"manifest scenario is missing the {field!r} field")
        name = scenario["name"]
        if not isinstance(name, str) or not name:
            raise ValueError("manifest scenario name must be a non-empty string")
        if name in names:
            raise ValueError(f"manifest declares the scenario {name!r} twice")
        names.add(name)
        if int(scenario["width"]) <= 0 or int(scenario["height"]) <= 0:
            raise ValueError(f"scenario {name!r} has an invalid resolution")
        options = scenario["encoder_options"]
        if not isinstance(options, list) or not all(isinstance(option, str) for option in options):
            raise ValueError(f"scenario {name!r} encoder_options must be a list of strings")
    return scenarios


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--install-dir", required=True, type=Path)
    parser.add_argument("--work-dir", required=True, type=Path)
    parser.add_argument("--results-dir", required=True, type=Path)
    parser.add_argument("--runs-dir", required=True, type=Path)
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--warmups", type=int, default=1)
    parser.add_argument("--samples", type=int, default=20)
    args = parser.parse_args(argv)

    if args.warmups < 1 or args.samples < MIN_SAMPLES:
        return fail(
            f"sampling contract requires >=1 warm-up and >={MIN_SAMPLES} samples, "
            f"got warmups={args.warmups} samples={args.samples}"
        )

    try:
        manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
        scenarios = validate_scenarios(manifest)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return fail(f"cannot load the scenario manifest {args.manifest}: {error}")

    cwebp = args.install_dir / "bin" / "cwebp"
    dwebp = args.install_dir / "bin" / "dwebp"
    for binary in (cwebp, dwebp):
        if not binary.is_file():
            return fail(f"binary is missing: {binary}")

    env = os.environ.copy()
    env["LD_LIBRARY_PATH"] = str(args.install_dir / "lib")
    # Same environment as the reference bench.py; cwebp -mt with -z 0 anyway
    # encodes on a single thread.
    env["OMP_NUM_THREADS"] = "1"

    allowed = sorted(os.sched_getaffinity(0))
    print(f"allowed cpus: {len(allowed)} (not pinned)", flush=True)
    print(
        f"lossless encode scenarios: {len(scenarios)}; "
        f"{args.warmups} warm-up + {args.samples} timed samples each; statistic=mean",
        flush=True,
    )

    args.work_dir.mkdir(parents=True, exist_ok=True)
    args.results_dir.mkdir(parents=True, exist_ok=True)
    args.runs_dir.mkdir(parents=True, exist_ok=True)

    try:
        generated = {image["name"]: image for image in prepare_inputs(args.work_dir)}
    except Exception as error:  # noqa: BLE001 - report every generator failure explicitly
        return fail(f"cannot generate the dashboard inputs under {args.work_dir}: {error}")

    input_digests = {name: digest(image["path"]) for name, image in generated.items()}
    cases: dict[str, dict] = {}
    rows: list[list[object]] = []
    scenario_order: list[str] = []

    for scenario in scenarios:
        name = scenario["name"]
        image = generated.get(name)
        if image is None:
            return fail(f"manifest scenario {name!r} has no generated input image")
        width = int(scenario["width"])
        height = int(scenario["height"])
        if (image["width"], image["height"]) != (width, height):
            return fail(
                f"scenario {name!r} declares {width}x{height} but the generated image is "
                f"{image['width']}x{image['height']}"
            )
        native_threads = int(scenario.get("native_threads", 1))

        webp = args.work_dir / (name + ".webp")
        pam = args.work_dir / (name + ".pam")
        command = [
            str(cwebp),
            "-quiet",
            *scenario["encoder_options"],
            str(image["path"]),
            "-o",
            str(webp),
        ]
        decode_command = [str(dwebp), str(webp), "-quiet", "-pam", "-o", str(pam)]

        # Warm-up: one encode, then the reference's decode size check.  Both are
        # outside the timed region.
        try:
            for _ in range(args.warmups):
                run(command, env)
                run(decode_command, env)
                pixels = decoded_pixel_bytes(pam)
                expected = width * height * 4
                if pixels != expected:
                    return fail(
                        f"scenario {name!r}: decoded image size is incorrect: "
                        f"{pixels} pixel bytes, expected {expected} ({width}x{height} RGBA)"
                    )
        except subprocess.CalledProcessError as error:
            return fail(describe_failure(f"scenario {name!r} warm-up", error))
        except (OSError, ValueError) as error:
            return fail(f"scenario {name!r} warm-up failed: {error}")

        run_dir = args.runs_dir / name
        run_dir.mkdir(parents=True, exist_ok=True)
        samples: list[float] = []
        for index in range(args.samples):
            try:
                samples.append(timed_run(command, env))
            except subprocess.CalledProcessError as error:
                return fail(describe_failure(f"scenario {name!r} sample {index + 1}", error))
            except (OSError, subprocess.TimeoutExpired) as error:
                return fail(f"scenario {name!r} sample {index + 1} failed: {error}")
            (run_dir / f"rep{index + 1}.json").write_text(
                json.dumps(
                    {
                        "scenario": name,
                        "rep": index + 1,
                        "ms": samples[-1],
                        "command": command,
                    },
                    indent=2,
                )
                + "\n",
                encoding="utf-8",
            )

        mean = statistics.mean(samples)
        output_digest = digest(webp)
        cases[name] = {
            "name": name,
            "group": scenario["group"],
            "subgroup": scenario["subgroup"],
            "width": width,
            "height": height,
            "unit": scenario.get("unit", "ms"),
            "direction": scenario.get("direction", "lower_is_better"),
            "native_threads": native_threads,
            "input_sha256": input_digests[name],
            "output_sha256": output_digest,
            "samples_ms": samples,
            "mean_ms": mean,
            "iterations": args.samples,
            "statistic": "mean",
            "command": command,
            "decode_check_command": decode_command,
            "status": "OK",
        }
        rows.append([name, args.samples, f"{mean:.6f}", "OK"])
        scenario_order.append(name)
        print(f"{name}: {mean:.6f} ms/image OK", flush=True)

    thread_counts = sorted({int(scenario.get("native_threads", 1)) for scenario in scenarios})
    evidence = {
        "benchmark": manifest.get("benchmark"),
        "source_mode": "unpatched",
        "affinity": "unbound",
        "cpu_pinning": "none",
        "memory_pinning": "none",
        "native_threads": thread_counts[0] if len(thread_counts) == 1 else thread_counts,
        "statistic": "mean",
        "warmups": args.warmups,
        "iterations": args.samples,
        "cpus_allowed": len(allowed),
        "scenario_order": scenario_order,
        "inputs": {
            name: {
                "path": str(generated[name]["path"]),
                "width": generated[name]["width"],
                "height": generated[name]["height"],
                "sha256": input_digests[name],
            }
            for name in scenario_order
        },
        "cases": cases,
    }
    (args.results_dir / "evidence.json").write_text(
        json.dumps(evidence, indent=2, allow_nan=False) + "\n", encoding="utf-8"
    )

    csv_path = args.results_dir / "result_bench-libwebp.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.writer(stream)
        writer.writerow(CSV_FIELDS)
        writer.writerows(rows)

    print(f"Result: {csv_path}")
    print("Read ms_per_image (milliseconds per image); lower is better.")
    print(COMPLETE_MARKER, flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
