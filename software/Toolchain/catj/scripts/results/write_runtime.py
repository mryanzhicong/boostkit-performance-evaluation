#!/usr/bin/env python3
"""Record the measured runtime: Node.js, catj, its dependencies and the inputs."""

import argparse
import hashlib
import json
import platform
import subprocess
import sys
from pathlib import Path


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def node_json(node_bin: str, expression: str) -> dict:
    output = subprocess.run(
        [node_bin, "-e", expression],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    return json.loads(output)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--node-bin", required=True)
    parser.add_argument("--app-dir", required=True)
    parser.add_argument("--input-dir", required=True)
    args = parser.parse_args()

    scenarios = json.loads(Path(args.scenarios).read_text(encoding="utf-8"))
    app = Path(args.app_dir)
    inputs_dir = Path(args.input_dir)
    node_version = subprocess.run(
        [args.node_bin, "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    app_dir = str(app / "node_modules")
    versions = node_json(
        args.node_bin,
        "const path=require('path');"
        f"const base={json.dumps(app_dir)};"
        "const names=['catj','colors','minimist','optimist','wordwrap'];"
        "const out={};"
        "for (const name of names) { out[name] = require(path.join(base, name, 'package.json')).version; }"
        "process.stdout.write(JSON.stringify(out));",
    )
    packages = {}
    for name in ("catj", "colors", "minimist", "optimist", "wordwrap"):
        package_dir = app / "node_modules" / name
        files = {"package.json": sha256_file(package_dir / "package.json")}
        license_file = package_dir / "LICENSE"
        if license_file.is_file():
            files["LICENSE"] = sha256_file(license_file)
        packages[name] = {"version": versions[name], "files": files}
    packages["catj"]["files"]["catj.js"] = sha256_file(app / "node_modules" / "catj" / "catj.js")
    inputs = []
    for entry in scenarios["inputs"]:
        target = inputs_dir / entry["name"]
        actual = sha256_file(target)
        if actual != entry["sha256"]:
            print(f"input {entry['name']} has sha256 {actual}, expected {entry['sha256']}", file=sys.stderr)
            return 2
        inputs.append({"name": entry["name"], "objects": entry["objects"], "bytes": entry["bytes"], "sha256": actual})
    payload = {
        "machine": platform.machine(),
        "node": {"version": node_version},
        "catj": packages["catj"],
        "dependencies": {name: packages[name] for name in ("colors", "minimist", "optimist", "wordwrap")},
        "inputs": inputs,
        "scenarios": [entry["id"] for entry in scenarios["scenarios"]],
        "suite": scenarios["suite"],
    }
    Path(args.output).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"node": node_version, "catj": versions["catj"], "machine": payload["machine"]}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
