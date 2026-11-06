#!/usr/bin/env python3
"""Stage and verify the Intel "Hyperscan hsbench samples" package.

The upstream Ultrascan benchmark procedure uses the pattern set
``hsbench-samples/pcre/snort_literals`` and the SQLite corpus
``hsbench-samples/corpora/gutenberg.db`` from the Intel package
(https://cdrdv2.intel.com/v1/dl/getContent/739375).  The package is prepared by
the user, not produced by the Ultrascan build, so this case downloads it on the
host (with an offline copy taking priority), extracts it inside the private
openEuler container and pins every member with SHA-256 values:

``download``
    Host side: reuse the offline archive or download it with resume, then verify
    the pinned SHA-256 of the zip itself.

``extract``
    Container side: unpack the archive, keep the ``hsbench-samples`` tree that
    the documentation extracts to ``/opt/Ultrascan/hsbench-samples``, verify the
    pinned SHA-256 of the two members the benchmark uses, and write a manifest.

The script never falls back to a synthetic corpus: the official samples are the
measurement input, and a missing or modified member fails the build stage.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path

SAMPLE_DIR_NAME = "hsbench-samples"
SAMPLE_ZIP_ROOT = "[Hyperscan] hsbench-samples"
RULES_RELATIVE = "pcre/snort_literals"
CORPUS_RELATIVE = "corpora/gutenberg.db"
PARTIAL_SUFFIX = ".part"


def fail(message: str) -> None:
    print(f"[samples] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def utc_timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def run(command: list[str]) -> subprocess.CompletedProcess[str]:
    print("[samples] " + " ".join(command), flush=True)
    return subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )


def download(url: str, target: Path, expected_sha256: str) -> int:
    if target.is_file():
        actual = sha256_file(target)
        if actual == expected_sha256:
            print(f"[samples] reusing verified archive {target}")
            return 0
        print(f"[samples] discarding archive with unexpected SHA-256: {actual}")
        target.unlink()
    partial = target.with_name(target.name + PARTIAL_SUFFIX)
    target.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(1, 4):
        command = [
            "curl", "-fL", "--retry", "3", "--retry-delay", "5",
            "--connect-timeout", "30", "-C", "-", "-o", str(partial), url,
        ]
        completed = run(command)
        if completed.returncode == 0:
            break
        print(f"[samples] download attempt {attempt} failed: {completed.stdout.strip()[-400:]}")
        if not partial.is_file():
            partial.unlink(missing_ok=True)
    if not partial.is_file():
        fail(f"could not download {url}")
    shutil.move(str(partial), str(target))
    actual = sha256_file(target)
    if actual != expected_sha256:
        target.unlink(missing_ok=True)
        fail(f"downloaded package SHA-256 mismatch: {actual} != {expected_sha256}")
    print(f"[samples] downloaded and verified {target}")
    return 0


def find_offline_archive(offline_dir: Path, name: str) -> Path | None:
    if not offline_dir.is_dir():
        return None
    candidate = offline_dir / name
    if candidate.is_file():
        return candidate
    return None


def extract(zip_path: Path, dest: Path, rules_sha256: str, corpus_sha256: str,
            manifest_path: Path | None) -> int:
    if not zip_path.is_file():
        fail(f"sample archive is missing: {zip_path}")
    if dest.exists():
        shutil.rmtree(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    staging = dest.parent / f".{dest.name}.extract"
    if staging.exists():
        shutil.rmtree(staging)
    staging.mkdir(parents=True)
    try:
        with zipfile.ZipFile(zip_path) as archive:
            members = archive.namelist()
            prefix = SAMPLE_ZIP_ROOT + "/"
            if not any(name.startswith(prefix) for name in members):
                fail(f"{zip_path} does not contain {SAMPLE_ZIP_ROOT}/")
            for member in members:
                if not member.startswith(prefix):
                    continue
                relative = member[len(prefix):]
                if not relative or relative.endswith("/"):
                    continue
                parts = Path(relative).parts
                if any(part in ("..", "") for part in parts):
                    fail(f"unsafe member path in {zip_path}: {member}")
                target = staging / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                with archive.open(member) as source, target.open("wb") as handle:
                    shutil.copyfileobj(source, handle)
        staging.rename(dest)
    finally:
        if staging.exists():
            shutil.rmtree(staging, ignore_errors=True)

    rules = dest / RULES_RELATIVE
    corpus = dest / CORPUS_RELATIVE
    for path in (rules, corpus):
        if not path.is_file():
            fail(f"extracted sample member is missing: {path}")
    rules_actual = sha256_file(rules)
    corpus_actual = sha256_file(corpus)
    if rules_actual != rules_sha256:
        fail(f"{RULES_RELATIVE} SHA-256 mismatch: {rules_actual} != {rules_sha256}")
    if corpus_actual != corpus_sha256:
        fail(f"{CORPUS_RELATIVE} SHA-256 mismatch: {corpus_actual} != {corpus_sha256}")
    manifest = {
        "prepared_at": utc_timestamp(),
        "package": SAMPLE_ZIP_ROOT,
        "zip_sha256": sha256_file(zip_path),
        "members": {
            RULES_RELATIVE: {"sha256": rules_actual, "bytes": rules.stat().st_size},
            CORPUS_RELATIVE: {"sha256": corpus_actual, "bytes": corpus.stat().st_size},
        },
    }
    if manifest_path is not None:
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        manifest_path.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )
    print(
        f"[samples] extracted {dest}: {RULES_RELATIVE} "
        f"({rules.stat().st_size} bytes), {CORPUS_RELATIVE} "
        f"({corpus.stat().st_size} bytes)"
    )
    return 0


def verify(dest: Path, rules_sha256: str, corpus_sha256: str) -> int:
    for relative, expected in (
        (RULES_RELATIVE, rules_sha256),
        (CORPUS_RELATIVE, corpus_sha256),
    ):
        path = dest / relative
        if not path.is_file():
            fail(f"sample member is missing: {path}")
        actual = sha256_file(path)
        if actual != expected:
            fail(f"{relative} SHA-256 mismatch: {actual} != {expected}")
    print(f"[samples] verified {dest} ({RULES_RELATIVE}, {CORPUS_RELATIVE})")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    download_parser = subparsers.add_parser("download")
    download_parser.add_argument("--offline-dir", type=Path, default=None)
    download_parser.add_argument("--url", required=True)
    download_parser.add_argument("--sha256", required=True)
    download_parser.add_argument("--name", default="hsbench-samples.zip")
    download_parser.add_argument("--target", required=True, type=Path)

    extract_parser = subparsers.add_parser("extract")
    extract_parser.add_argument("--zip", required=True, type=Path)
    extract_parser.add_argument("--dest", required=True, type=Path)
    extract_parser.add_argument("--rules-sha256", required=True)
    extract_parser.add_argument("--corpus-sha256", required=True)
    extract_parser.add_argument("--manifest", type=Path, default=None)

    verify_parser = subparsers.add_parser("verify")
    verify_parser.add_argument("--dest", required=True, type=Path)
    verify_parser.add_argument("--rules-sha256", required=True)
    verify_parser.add_argument("--corpus-sha256", required=True)

    args = parser.parse_args()
    if args.command == "download":
        offline = find_offline_archive(args.offline_dir, args.name) if args.offline_dir else None
        if offline is not None:
            actual = sha256_file(offline)
            if actual != args.sha256:
                fail(f"offline archive SHA-256 mismatch: {actual} != {args.sha256}")
            args.target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(offline, args.target)
            print(f"[samples] staged verified offline archive {offline} -> {args.target}")
            return 0
        return download(args.url, args.target, args.sha256)
    if args.command == "extract":
        return extract(args.zip, args.dest, args.rules_sha256, args.corpus_sha256,
                       args.manifest)
    return verify(args.dest, args.rules_sha256, args.corpus_sha256)


if __name__ == "__main__":
    raise SystemExit(main())
