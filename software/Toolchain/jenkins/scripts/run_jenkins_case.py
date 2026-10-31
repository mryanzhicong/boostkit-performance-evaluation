#!/usr/bin/env python3
"""Run one measured Jenkins 2.588 controller workload repetition.

Every scenario starts from a *reset* ``JENKINS_HOME`` and measures exactly one
window around the controller:

* ``startup_cold``  - spawn the official ``jenkins.war`` on an empty home and
  stop the clock when ``/api/json`` answers with the expected ``X-Jenkins``
  version.
* ``startup_warm``  - same, but the home is a restored copy of a home that has
  already completed one boot/shutdown cycle.
* ``job_batch``     - start an initialized controller (untimed), create
  ``<scale>`` freestyle shell jobs over REST, then measure from triggering the
  first job to the last completed build result; every build must be SUCCESS.
* ``api_list``      - start a controller whose home contains ``<scale>`` jobs
  (untimed) and measure repeated reads of ``/api/json?tree=jobs[name]``.
* ``api_scan``      - start a controller whose home contains ``<scale>`` jobs
  (untimed) and measure one ``/job/<name>/api/json`` read per job.

Preparation, server start-up for the job/API scenarios and home copies happen
outside the measured window; their cost is recorded in the log but is not part
of the reported sample.  The measured window is wall time measured here with
``time.monotonic`` and the controller JVM peak RSS read from
``/proc/<pid>/status`` (``VmHWM``) at the end of the window.
"""

from __future__ import annotations

import argparse
import json
import math
import os
import shutil
import signal
import subprocess
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

JOB_XML = (
    b'<project><description>boostkit performance benchmark job</description>'
    b"<keepDependencies>false</keepDependencies><properties/>"
    b'<scm class="hudson.scm.NullSCM"/>'
    b"<canRoam>true</canRoam><disabled>false</disabled>"
    b"<blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>"
    b"<blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>"
    b"<triggers/><concurrentBuild>false</concurrentBuild>"
    b"<builders><hudson.tasks.Shell>"
    b"<command>echo JENKINS_BENCH_OK; exit 0</command>"
    b"</hudson.tasks.Shell></builders>"
    b"<publishers/><buildWrappers/></project>"
)
API_LIST_ITERATIONS = 20


class DriverError(RuntimeError):
    """A scenario failed before a sample could be recorded."""


def now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def atomic_write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temporary.replace(path)


class Logger:
    def __init__(self, handle) -> None:
        self.handle = handle

    def log(self, message: str) -> None:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        line = f"[jenkins-driver] {timestamp} {message}"
        print(line, flush=True)
        self.handle.write(line + "\n")
        self.handle.flush()


def http_request(
    url: str,
    data: bytes | None = None,
    method: str | None = None,
    timeout: float = 30.0,
    content_type: str | None = None,
) -> tuple[int, dict[str, str], bytes]:
    request = urllib.request.Request(url, data=data, method=method)
    if content_type:
        request.add_header("Content-Type", content_type)
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return response.status, dict(response.headers), response.read()
    except urllib.error.HTTPError as exc:
        return exc.code, dict(exc.headers), exc.read()


def read_peak_rss_kib(pid: int) -> int:
    try:
        with open(f"/proc/{pid}/status", encoding="utf-8") as handle:
            for line in handle:
                if line.startswith("VmHWM:"):
                    return int(line.split()[1])
    except OSError:
        return 0
    return 0


def build_command(
    args: argparse.Namespace, extra_system_properties: list[str]
) -> list[str]:
    command = [
        str(args.java),
        "-Xms512m",
        "-Xmx512m",
        "-Djava.awt.headless=true",
        "-Djenkins.install.runSetupWizard=false",
        "-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true",
        "-Dhudson.model.UpdateCenter.updateCenterUrl=http://127.0.0.1:1/update-center.json",
        "-Djenkins.model.DownloadService.noSignatureCheck=true",
        "-Dhudson.model.UsageStatistics.disabled=true",
        *extra_system_properties,
        "-jar",
        str(args.war),
        f"--httpPort={args.port}",
        "--httpListenAddress=127.0.0.1",
    ]
    return command


def base_url(port: int) -> str:
    return f"http://127.0.0.1:{port}"


def wait_ready(
    port: int, expected_version: str, timeout: float, logger: Logger
) -> tuple[float, str]:
    started = time.monotonic()
    deadline = started + timeout
    last_error = "no answer yet"
    while time.monotonic() < deadline:
        try:
            status, headers, _ = http_request(f"{base_url(port)}/api/json", timeout=5)
            if status == 200:
                version = headers.get("X-Jenkins", "")
                if not version:
                    last_error = "missing X-Jenkins header"
                elif version != expected_version:
                    last_error = f"controller reports {version}"
                else:
                    elapsed = time.monotonic() - started
                    logger.log(f"controller ready after {elapsed:.3f}s (X-Jenkins {version})")
                    return elapsed, version
        except (urllib.error.URLError, TimeoutError, ConnectionError, OSError) as exc:
            last_error = str(exc)
        time.sleep(0.05)
    raise DriverError(
        f"controller did not become ready within {timeout:.0f}s: {last_error}"
    )


def start_controller(
    args: argparse.Namespace, home: Path, log_handle, logger: Logger
) -> subprocess.Popen[bytes]:
    env = dict(os.environ)
    env["JENKINS_HOME"] = str(home)
    env.pop("JENKINS_URL", None)
    env.pop("HUDSON_URL", None)
    command = build_command(args, [])
    logger.log(f"starting controller: {' '.join(command)}")
    return subprocess.Popen(
        command,
        env=env,
        stdout=log_handle,
        stderr=subprocess.STDOUT,
        start_new_session=True,
    )


def stop_controller(process: subprocess.Popen[bytes], logger: Logger) -> None:
    if process.poll() is not None:
        return
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        return
    try:
        process.wait(timeout=60)
    except subprocess.TimeoutExpired:
        logger.log("controller did not stop within 60s; sending SIGKILL")
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


def reset_home(home: Path, template: Path | None, logger: Logger) -> None:
    shutil.rmtree(home, ignore_errors=True)
    home.parent.mkdir(parents=True, exist_ok=True)
    if template is None:
        home.mkdir(parents=True, exist_ok=True)
        logger.log(f"reset empty JENKINS_HOME: {home}")
        return
    if not template.is_dir():
        raise DriverError(f"initialized home template is missing: {template}")
    started = time.monotonic()
    shutil.copytree(template, home, symlinks=True)
    logger.log(f"restored initialized JENKINS_HOME from {template} in {time.monotonic()-started:.3f}s")


def create_jobs_over_http(port: int, count: int, logger: Logger) -> list[str]:
    names: list[str] = []
    for index in range(count):
        name = f"bench_job_{index:04d}"
        status, _, body = http_request(
            f"{base_url(port)}/createItem?name={name}",
            JOB_XML,
            content_type="application/xml",
        )
        if status not in (200, 201):
            raise DriverError(f"creating job {name} failed with HTTP {status}: {body[:200]!r}")
        names.append(name)
    logger.log(f"created {count} freestyle jobs over REST")
    return names


def write_job_configs(home: Path, count: int, logger: Logger) -> list[str]:
    names: list[str] = []
    for index in range(count):
        name = f"bench_job_{index:04d}"
        job_dir = home / "jobs" / name
        job_dir.mkdir(parents=True, exist_ok=True)
        (job_dir / "config.xml").write_bytes(JOB_XML)
        names.append(name)
    logger.log(f"prepared {count} job configurations under {home / 'jobs'}")
    return names


def trigger_jobs(port: int, names: list[str], logger: Logger) -> float:
    started = time.monotonic()
    for name in names:
        status, _, body = http_request(
            f"{base_url(port)}/job/{name}/build?delay=0sec", b"", method="POST"
        )
        if status not in (200, 201, 302):
            raise DriverError(f"triggering {name} failed with HTTP {status}: {body[:200]!r}")
    logger.log(f"triggered {len(names)} builds in {time.monotonic()-started:.3f}s")
    return started


def wait_for_builds(port: int, names: list[str], timeout: float, logger: Logger) -> tuple[float, int]:
    """Wait until every job has a completed build; return completion time and successes."""
    started = time.monotonic()
    deadline = started + timeout
    pending = set(names)
    successes = 0
    failures: list[str] = []
    while pending and time.monotonic() < deadline:
        status, _, body = http_request(
            f"{base_url(port)}/api/json?tree=jobs[name,lastBuild[number,building,result]]"
        )
        if status != 200:
            raise DriverError(f"reading build status failed with HTTP {status}")
        payload = json.loads(body)
        seen: dict[str, dict[str, Any]] = {}
        for item in payload.get("jobs", []):
            if item.get("name") in pending:
                seen[item["name"]] = item
        for name in list(pending):
            item = seen.get(name)
            build = item.get("lastBuild") if isinstance(item, dict) else None
            if not build or build.get("building") or not build.get("result"):
                continue
            pending.discard(name)
            if build["result"] == "SUCCESS":
                successes += 1
            else:
                failures.append(f"{name}={build['result']}")
        if pending:
            time.sleep(0.02)
    if pending:
        raise DriverError(
            f"{len(pending)} builds did not complete within {timeout:.0f}s: "
            f"{sorted(pending)[:5]}"
        )
    elapsed = time.monotonic() - started
    if failures:
        raise DriverError(f"builds finished unsuccessfully: {failures[:5]}")
    logger.log(f"all {len(names)} builds completed successfully in {elapsed:.3f}s")
    return elapsed, successes


def measure_api_list(port: int, expected_jobs: int, logger: Logger) -> dict[str, Any]:
    failures = 0
    observed = 0
    for index in range(API_LIST_ITERATIONS):
        status, _, body = http_request(f"{base_url(port)}/api/json?tree=jobs[name]")
        if status != 200:
            raise DriverError(f"job list request failed with HTTP {status}")
        jobs = json.loads(body).get("jobs", [])
        observed = len(jobs)
        if observed != expected_jobs:
            failures += 1
        if index == 0:
            logger.log(f"job list reports {observed} jobs")
    return {
        "api_requests": API_LIST_ITERATIONS,
        "api_failures": failures,
        "api_jobs": observed,
    }


def measure_api_scan(port: int, names: list[str], logger: Logger) -> dict[str, Any]:
    failures = 0
    for name in names:
        status, _, body = http_request(f"{base_url(port)}/job/{name}/api/json")
        if status != 200:
            failures += 1
            continue
        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            failures += 1
            continue
        if payload.get("name") != name:
            failures += 1
    logger.log(f"scanned {len(names)} job detail documents, failures={failures}")
    return {
        "api_requests": len(names),
        "api_failures": failures,
        "api_jobs": len(names),
    }


def scenario_run(args: argparse.Namespace) -> tuple[int, dict[str, Any]]:
    log_handle = args.log.open("w", encoding="utf-8")
    logger = Logger(log_handle)
    started_at = now_utc()
    payload: dict[str, Any] = {
        "scenario": args.scenario,
        "action": args.action,
        "started_at": started_at,
        "command": [str(args.java), "-jar", str(args.war), f"--httpPort={args.port}"],
        "timeout_seconds": args.timeout,
    }
    process: subprocess.Popen[bytes] | None = None
    exit_code = 0
    timed_out = False
    wall_seconds = 0.0
    max_rss_kib = 0
    checks: dict[str, Any] = {}
    home = Path(args.home)
    template = Path(args.template_home) if args.template_home else None
    try:
        logger.log(
            f"scenario {args.scenario} action={args.action} scale={args.scale} "
            f"home={home} template={template}"
        )
        if args.action == "startup_cold":
            reset_home(home, None, logger)
        elif args.action in {"startup_warm", "job_batch", "api_list", "api_scan"}:
            reset_home(home, template, logger)
        else:
            raise DriverError(f"unsupported scenario action: {args.action}")

        job_names: list[str] = []
        if args.action in {"api_list", "api_scan"}:
            job_names = write_job_configs(home, args.scale, logger)
        if args.action == "job_batch":
            pass  # jobs are created after the controller is ready (untimed)

        process = start_controller(args, home, log_handle, logger)
        if args.action in {"startup_cold", "startup_warm"}:
            ready_seconds, version = wait_ready(
                args.port, args.expected_version, args.ready_timeout, logger
            )
            wall_seconds = ready_seconds
            max_rss_kib = read_peak_rss_kib(process.pid)
            checks["ready"] = True
            checks["jenkins_version"] = version
        else:
            _, ready_version = wait_ready(
                args.port, args.expected_version, args.ready_timeout, logger
            )
            checks["ready"] = True
            checks["jenkins_version"] = ready_version
            if args.action == "job_batch":
                job_names = create_jobs_over_http(args.port, args.scale, logger)
                wall_seconds = trigger_jobs(args.port, job_names, logger)
                elapsed, successes = wait_for_builds(
                    args.port, job_names, args.build_timeout, logger
                )
                wall_seconds = time.monotonic() - wall_seconds
                max_rss_kib = read_peak_rss_kib(process.pid)
                checks["jobs_created"] = len(job_names)
                checks["builds_total"] = len(job_names)
                checks["builds_success"] = successes
                checks["builds_result"] = "SUCCESS"
                _ = elapsed
            elif args.action == "api_list":
                started = time.monotonic()
                checks.update(measure_api_list(args.port, args.scale, logger))
                max_rss_kib = read_peak_rss_kib(process.pid)
                wall_seconds = time.monotonic() - started
            elif args.action == "api_scan":
                started = time.monotonic()
                checks.update(measure_api_scan(args.port, job_names, logger))
                max_rss_kib = read_peak_rss_kib(process.pid)
                wall_seconds = time.monotonic() - started
    except DriverError as exc:
        logger.log(f"ERROR: {exc}")
        exit_code = 50
        if " within " in str(exc):
            timed_out = True
            exit_code = 124
    except Exception as exc:  # noqa: BLE001 - any unexpected failure must fail the sample
        logger.log(f"ERROR: unexpected failure: {exc!r}")
        exit_code = 50
    finally:
        if process is not None:
            try:
                stop_controller(process, logger)
            except Exception as exc:  # noqa: BLE001
                logger.log(f"ERROR: failed to stop the controller cleanly: {exc!r}")
                if exit_code == 0:
                    exit_code = 50
        log_handle.flush()

    if not math.isfinite(wall_seconds) or wall_seconds <= 0:
        if exit_code == 0:
            exit_code = 50
        wall_seconds = 0.0
    max_rss_mib = round(max_rss_kib / 1024.0, 3) if max_rss_kib else 0.0
    payload.update(
        {
            "exit_code": exit_code,
            "timed_out": timed_out,
            "wall_seconds": round(wall_seconds, 6),
            "max_rss_kib": max_rss_kib,
            "max_rss_mib": max_rss_mib,
            "rss_source": "VmHWM of the controller JVM at the end of the measured window",
            "jenkins_port": args.port,
            "checks": checks,
            "finished_at": now_utc(),
        }
    )
    result_line = (
        f"RESULT scenario={args.scenario} wall={wall_seconds:.6f} rss_kib={max_rss_kib} "
        f"checks={json.dumps(checks, sort_keys=True)}"
    )
    with args.log.open("a", encoding="utf-8") as handle:
        handle.write(result_line + "\n")
    atomic_write_json(args.json, payload)
    return exit_code, payload


def prepare_template(args: argparse.Namespace) -> int:
    log_handle = args.log.open("w", encoding="utf-8")
    logger = Logger(log_handle)
    home = Path(args.prepare_home)
    template = Path(args.template_home)
    process: subprocess.Popen[bytes] | None = None
    try:
        reset_home(home, None, logger)
        location_dir = home / "init.groovy.d"
        location_dir.mkdir(parents=True, exist_ok=True)
        (location_dir / "location.groovy").write_text(
            "import jenkins.model.JenkinsLocationConfiguration\n"
            "def jlc = JenkinsLocationConfiguration.get()\n"
            f"jlc.setUrl('{base_url(args.port)}/')\n"
            "jlc.save()\n",
            encoding="utf-8",
        )
        process = start_controller(args, home, log_handle, logger)
        wait_ready(args.port, args.expected_version, args.ready_timeout, logger)
    except (DriverError, OSError) as exc:
        logger.log(f"ERROR: template preparation failed: {exc}")
        if process is not None:
            stop_controller(process, logger)
        return 50
    try:
        stop_controller(process, logger)
    except Exception as exc:  # noqa: BLE001
        logger.log(f"ERROR: failed to stop the template controller: {exc!r}")
        return 50
    shutil.rmtree(template, ignore_errors=True)
    shutil.copytree(home, template, symlinks=True)
    logger.log(f"initialized JENKINS_HOME template written to {template}")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scenario", default="")
    parser.add_argument("--action", default="")
    parser.add_argument("--scale", type=int, default=0)
    parser.add_argument("--json", type=Path)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--timeout", type=float, default=900.0)
    parser.add_argument("--ready-timeout", type=float, default=180.0)
    parser.add_argument("--build-timeout", type=float, default=300.0)
    parser.add_argument("--war", type=Path, required=True)
    parser.add_argument("--java", type=Path, required=True)
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--home", type=Path)
    parser.add_argument("--template-home", type=Path)
    parser.add_argument("--prepare-template", action="store_true")
    parser.add_argument("--prepare-home", type=Path)
    parser.add_argument("--expected-version", default="2.588")
    args = parser.parse_args()
    if args.prepare_template:
        if not args.prepare_home or not args.template_home:
            parser.error("--prepare-template requires --prepare-home and --template-home")
        return args
    if not args.scenario or not args.action or not args.json or not args.home:
        parser.error("a scenario run requires --scenario --action --json --home")
    return args


def main() -> int:
    args = parse_args()
    if args.prepare_template:
        return prepare_template(args)
    exit_code, _ = scenario_run(args)
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
