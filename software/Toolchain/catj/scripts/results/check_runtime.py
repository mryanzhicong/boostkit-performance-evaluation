#!/usr/bin/env python3
"""Cross-check the build-time runtime record against the staged artefacts."""

import argparse
import hashlib
import json
import platform
import subprocess
import sys
from pathlib import Path


class RuntimeError_(RuntimeError):
    pass


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--runtime", required=True)
    parser.add_argument("--input-dir", required=True)
    parser.add_argument("--node-bin", required=True)
    args = parser.parse_args()

    scenarios = json.loads(Path(args.scenarios).read_text(encoding="utf-8"))
    runtime = json.loads(Path(args.runtime).read_text(encoding="utf-8"))
    node_version = subprocess.run(
        [args.node_bin, "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    expected_ids = [entry["id"] for entry in scenarios["scenarios"]]
    checks = [
        (runtime.get("node", {}).get("version") == node_version, "node version drift"),
        (runtime.get("catj", {}).get("version") == scenarios["version"], "catj version drift"),
        (runtime.get("scenarios") == expected_ids, "scenario list drift"),
        (runtime.get("suite") == scenarios["suite"], "suite drift"),
        (
            runtime.get("machine") == platform.machine(),
            f"machine {runtime.get('machine')!r} does not match {platform.machine()!r}",
        ),
    ]
    for condition, message in checks:
        if not condition:
            raise RuntimeError_(message)
    inputs = {item["name"]: item for item in runtime.get("inputs", [])}
    for entry in scenarios["inputs"]:
        if entry["name"] not in inputs:
            raise RuntimeError_(f"runtime record does not pin {entry['name']}")
        target = Path(args.input_dir) / entry["name"]
        if not target.is_file():
            raise RuntimeError_(f"generated input is missing: {target}")
        actual = sha256_file(target)
        if actual != entry["sha256"]:
            raise RuntimeError_(f"input {entry['name']} has sha256 {actual}, expected {entry['sha256']}")
    files = runtime["catj"].get("files", {})
    for name in ("package.json", "catj.js"):
        if not name in files:
            raise RuntimeError_(f"runtime record does not pin catj {name}")
    for dependency, record in runtime.get("dependencies", {}).items():
        if not record.get("version"):
            raise RuntimeError_(f"runtime record does not pin dependency {dependency}")
    print(
        json.dumps(
            {
                "node": runtime["node"]["version"],
                "catj": runtime["catj"]["version"],
                "dependencies": {name: record["version"] for name, record in runtime["dependencies"].items()},
                "inputs": [item["name"] for item in runtime["inputs"]],
                "scenarios": len(expected_ids),
            },
            sort_keys=True,
        )
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError_ as exc:
        print(f"[catj] runtime check failed: {exc}", file=sys.stderr)
        raise SystemExit(2)
