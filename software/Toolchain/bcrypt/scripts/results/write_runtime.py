#!/usr/bin/env python3
"""Record the measured runtime: Node.js, bcrypt, its dependencies, the native binary."""

import argparse
import hashlib
import json
import platform
import subprocess
from pathlib import Path


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scenarios", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--node-bin", required=True)
    parser.add_argument("--app-dir", required=True)
    parser.add_argument("--native-sha256", required=True)
    args = parser.parse_args()

    scenarios = json.loads(Path(args.scenarios).read_text(encoding="utf-8"))
    package_dir = Path(args.app_dir) / "node_modules" / "bcrypt"
    node_version = subprocess.run(
        [args.node_bin, "--version"], check=True, capture_output=True, text=True
    ).stdout.strip()
    versions = json.loads(
        subprocess.run(
            [
                args.node_bin,
                "-e",
                "const path=require('path');"
                f"const base={json.dumps(str(Path(args.app_dir) / 'node_modules'))};"
                "const names=['bcrypt','node-addon-api','node-gyp-build'];"
                "const out={};"
                "for (const name of names) { out[name] = require(path.join(base, name, 'package.json')).version; }"
                "out.napi = process.versions.napi || null;"
                "process.stdout.write(JSON.stringify(out));",
            ],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
    )
    files = {
        "package.json": sha256_file(package_dir / "package.json"),
        "bcrypt.js": sha256_file(package_dir / "bcrypt.js"),
        "binding.gyp": sha256_file(package_dir / "binding.gyp"),
    }
    payload = {
        "machine": platform.machine(),
        "node": {"version": node_version},
        "bcrypt": {
            "version": versions["bcrypt"],
            "files": files,
            "native": {
                "binary": "prebuilds/linux-x64/bcrypt.glibc.node"
                if platform.machine() in ("x86_64", "AMD64")
                else "prebuilds/linux-arm64/bcrypt.glibc.node",
                "sha256": args.native_sha256,
                "napi": versions.get("napi"),
            },
        },
        "dependencies": {
            name: {"version": versions[name]} for name in ("node-addon-api", "node-gyp-build")
        },
        "scenarios": [entry["id"] for entry in scenarios["scenarios"]],
        "suite": scenarios["suite"],
    }
    Path(args.output).write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({"node": node_version, "bcrypt": versions["bcrypt"], "napi": versions.get("napi")}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
