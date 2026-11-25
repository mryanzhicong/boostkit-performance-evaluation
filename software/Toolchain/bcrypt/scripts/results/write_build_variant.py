#!/usr/bin/env python3
"""Write the build metadata of the bcrypt case (architecture neutral)."""

import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--runtime", required=True)
    parser.add_argument("--node-version", required=True)
    parser.add_argument("--node-sha256", required=True)
    parser.add_argument("--bcrypt-sha256", required=True)
    parser.add_argument("--deps-sha256", required=True)
    parser.add_argument("--reps", type=int, required=True)
    parser.add_argument("--warmups", type=int, required=True)
    args = parser.parse_args()

    scenarios = json.loads(Path(args.scenarios).read_text(encoding="utf-8"))
    runtime = json.loads(Path(args.runtime).read_text(encoding="utf-8"))
    payload = {
        "software": scenarios["software"],
        "version": scenarios["version"],
        "variant": "base",
        "toolchain": {
            "node": {"version": args.node_version, "archive_sha256": args.node_sha256},
            "package_manager": "vendored node_modules (no registry access during measurement)",
            "native_module": "prebuilt N-API binary shipped in the release tarball",
        },
        "package": {
            "name": scenarios["software"],
            "version": scenarios["version"],
            "tarball_sha256": args.bcrypt_sha256,
            "dependency_tree_sha256": args.deps_sha256,
        },
        "runtime": runtime,
        "fixtures": {"suite": scenarios["suite"], "upstream_suite": bool(scenarios["selection"]["upstream_suite"])},
        "measurement_protocol": {
            "statistic": "median",
            "repetitions": args.reps,
            "warmups": args.warmups,
            "processes_per_sample": 1,
            "offline": True,
            "timing": "per-operation process.hrtime.bigint(), salt generated before the timed window",
            "environment": {"UV_THREADPOOL_SIZE": "1", "TZ": "UTC", "LC_ALL": "C"},
        },
        "scenarios": scenarios["scenarios"],
    }
    Path(args.output).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
