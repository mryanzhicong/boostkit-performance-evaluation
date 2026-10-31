#!/usr/bin/env python3
"""Measure the Next.js production server over loopback HTTP.

The delivery load is "fixed 1000 static pages, production build, then GET
127.0.0.1:18181 100 times and verify item-999" and it explicitly forbids calling
the inverse of a serial connection latency a high-concurrency QPS.  This script
implements exactly that measurement, strictly:

* the server is started and the time until the first HTTP 200 response is
  recorded (startup latency, measured in ``startup`` mode);
* in ``latency`` mode one warmup request is sent first, then exactly N serial
  requests are timed; every response must be HTTP 200 and must contain the
  expected content marker, otherwise the run fails;
* requests are strictly serial: the next request starts after the previous
  response has been read completely, so the reported latency is a single
  connection round trip and not a throughput number;
* the server process group is always terminated; a leftover server on the port
  makes the next run fail loudly instead of measuring a stale process.

The evidence line printed to stdout is parsed by scripts/results/parse_benchmark.py.
"""

from __future__ import annotations

import argparse
import json
import os
import signal
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request

EVIDENCE_PREFIX = "[next-http]"


def port_is_free(host: str, port: int) -> bool:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as probe:
        probe.settimeout(1.0)
        return probe.connect_ex((host, port)) != 0


def wait_until_free(host: str, port: int, timeout: float) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        if port_is_free(host, port):
            return True
        time.sleep(0.05)
    return port_is_free(host, port)


def fetch(host: str, port: int, path: str, timeout: float) -> tuple[int, str, float]:
    begin = time.perf_counter()
    request = urllib.request.Request(f"http://{host}:{port}{path}")
    with urllib.request.urlopen(request, timeout=timeout) as response:
        body = response.read().decode("utf-8", "replace")
        status = response.status
    return status, body, time.perf_counter() - begin


def stop_process(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    try:
        os.killpg(os.getpgid(process.pid), signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(os.getpgid(process.pid), signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait(timeout=10)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--app-dir", required=True)
    parser.add_argument("--next-bin", required=True)
    parser.add_argument("--node-bin", required=True)
    parser.add_argument("--mode", choices=("startup", "latency"), required=True)
    parser.add_argument("--path", required=True)
    parser.add_argument("--expect", required=True)
    parser.add_argument("--requests", type=int, default=100)
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--startup-timeout", type=float, default=180.0)
    parser.add_argument("--request-timeout", type=float, default=60.0)
    arguments = parser.parse_args()

    if not wait_until_free(arguments.host, arguments.port, 30.0):
        print(
            f"{EVIDENCE_PREFIX} ERROR: {arguments.host}:{arguments.port} is not free",
            flush=True,
        )
        return 1

    environment = dict(os.environ)
    environment["NEXT_TELEMETRY_DISABLED"] = "1"
    environment.setdefault("NODE_ENV", "production")

    spawn_begin = time.perf_counter()
    process = subprocess.Popen(
        [
            arguments.node_bin,
            arguments.next_bin,
            "start",
            "-p",
            str(arguments.port),
            "-H",
            arguments.host,
        ],
        cwd=arguments.app_dir,
        env=environment,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )

    try:
        startup_seconds = None
        deadline = spawn_begin + arguments.startup_timeout
        while time.perf_counter() < deadline:
            if process.poll() is not None:
                print(
                    f"{EVIDENCE_PREFIX} ERROR: the server exited before becoming ready",
                    flush=True,
                )
                return 1
            try:
                status, _, _ = fetch(arguments.host, arguments.port, "/", arguments.request_timeout)
            except (urllib.error.URLError, ConnectionError, TimeoutError, OSError):
                time.sleep(0.02)
                continue
            if status == 200:
                startup_seconds = time.perf_counter() - spawn_begin
                break
            time.sleep(0.02)
        if startup_seconds is None:
            print(
                f"{EVIDENCE_PREFIX} ERROR: the server did not become ready within "
                f"{arguments.startup_timeout:.0f}s",
                flush=True,
            )
            return 1

        status, body, _ = fetch(
            arguments.host, arguments.port, arguments.path, arguments.request_timeout
        )
        if status != 200 or arguments.expect not in body:
            print(
                f"{EVIDENCE_PREFIX} ERROR: verification request {arguments.path} failed "
                f"(status={status}, expected marker {arguments.expect!r})",
                flush=True,
            )
            return 1

        latencies: list[float] = []
        if arguments.mode == "latency":
            verified = 0
            for index in range(arguments.requests):
                try:
                    status, body, elapsed = fetch(
                        arguments.host,
                        arguments.port,
                        arguments.path,
                        arguments.request_timeout,
                    )
                except (urllib.error.URLError, ConnectionError, TimeoutError, OSError) as error:
                    print(
                        f"{EVIDENCE_PREFIX} ERROR: request {index + 1}/{arguments.requests} "
                        f"failed: {error}",
                        flush=True,
                    )
                    return 1
                if status != 200:
                    print(
                        f"{EVIDENCE_PREFIX} ERROR: request {index + 1}/{arguments.requests} "
                        f"returned HTTP {status}",
                        flush=True,
                    )
                    return 1
                if arguments.expect not in body:
                    print(
                        f"{EVIDENCE_PREFIX} ERROR: request {index + 1}/{arguments.requests} "
                        f"did not contain {arguments.expect!r}",
                        flush=True,
                    )
                    return 1
                latencies.append(elapsed)
                verified += 1
        else:
            verified = 1

        ordered = sorted(latencies)
        payload = {
            "mode": arguments.mode,
            "path": arguments.path,
            "expect": arguments.expect,
            "requests": len(latencies),
            "verified": verified,
            "startup_seconds": round(startup_seconds, 6),
            "latency_median_seconds": round(ordered[len(ordered) // 2], 6) if ordered else None,
            "latency_min_seconds": round(ordered[0], 6) if ordered else None,
            "latency_max_seconds": round(ordered[-1], 6) if ordered else None,
            "latencies": [round(value, 6) for value in latencies],
        }
        print(f"{EVIDENCE_PREFIX} {json.dumps(payload, sort_keys=True)}", flush=True)
        return 0
    finally:
        stop_process(process)
        if not wait_until_free(arguments.host, arguments.port, 30.0):
            print(
                f"{EVIDENCE_PREFIX} ERROR: the server is still listening on "
                f"{arguments.host}:{arguments.port}",
                flush=True,
            )


if __name__ == "__main__":
    sys.exit(main())
