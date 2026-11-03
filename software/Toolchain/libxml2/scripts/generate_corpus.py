#!/usr/bin/env python3
"""Generate the deterministic XML corpora used by the libxml2 matrix.

The corpora are plain, self-contained XML documents with no external entities
and no DTD fetched from the network, so every measured parse/validate step can
run with ``--nonet`` and with networking removed entirely.  The generator is
deterministic: the same source tree always produces byte-identical files, and
the manifest records the exact size and SHA-256 of each corpus so the parser can
derive throughput (MiB/s) from the bytes that were really parsed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

ITEM_ATTRIBUTES = 'id="i{index:06d}" name="item-{index}" kind="alpha" weight="{weight}"'
ITEM_TEXT = "payload &amp; text {index}"
NAMESPACE_PREFIXES = ("", "a:", "b:", "c:")
NAMESPACE_KINDS = ("alpha", "beta", "gamma")


def write_wide(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n<benchmark run="2026-10-30">\n')
        for index in range(items):
            weight = index % 97
            attributes = ITEM_ATTRIBUTES.format(index=index, weight=weight)
            text = ITEM_TEXT.format(index=index)
            handle.write(f"  <item {attributes}>{text}</item>\n")
        handle.write("</benchmark>\n")


def write_deep(path: Path, depth: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n<root>')
        for level in range(depth):
            handle.write(f'<n level="{level}">')
        handle.write("leaf")
        handle.write("</n>" * depth)
        handle.write("</root>\n")


def write_namespaced(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        handle.write(
            '<root xmlns="urn:bench:default" xmlns:a="urn:bench:a" '
            'xmlns:b="urn:bench:b" xmlns:c="urn:bench:c">\n'
        )
        for index in range(items):
            prefix = NAMESPACE_PREFIXES[index % len(NAMESPACE_PREFIXES)]
            kind = NAMESPACE_KINDS[index % len(NAMESPACE_KINDS)]
            flag = "true" if index % 2 == 0 else "false"
            handle.write(
                f'  <{prefix}node id="n{index}" a:seq="{index}" '
                f'b:kind="{kind}" c:flag="{flag}">text {index}</{prefix}node>\n'
            )
        handle.write("</root>\n")


def write_dtd(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        handle.write("<!DOCTYPE catalog [\n")
        handle.write("  <!ELEMENT catalog (item)*>\n")
        handle.write("  <!ELEMENT item (#PCDATA)>\n")
        handle.write(
            "  <!ATTLIST item id CDATA #REQUIRED "
            "kind (alpha|beta|gamma) #REQUIRED weight CDATA #IMPLIED>\n"
        )
        handle.write("]>\n<catalog>\n")
        for index in range(items):
            kind = NAMESPACE_KINDS[index % len(NAMESPACE_KINDS)]
            handle.write(
                f'  <item id="i{index}" kind="{kind}" weight="{index % 53}">value {index}</item>\n'
            )
        handle.write("</catalog>\n")


def sha256_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--repeat-iterations", type=int, default=100)
    args = parser.parse_args()
    output = args.output
    output.mkdir(parents=True, exist_ok=True)

    specs = {
        "wide": lambda path: write_wide(path, 100_000),
        "huge": lambda path: write_wide(path, 400_000),
        "repeat": lambda path: write_wide(path, 50_000),
        "deep": lambda path: write_deep(path, 2_000),
        "namespaced": lambda path: write_namespaced(path, 40_000),
        "dtd": lambda path: write_dtd(path, 60_000),
    }
    manifest = {
        "generator": "scripts/generate_corpus.py",
        "repeat_iterations": args.repeat_iterations,
        "files": {},
    }
    for name, writer in specs.items():
        path = output / f"{name}.xml"
        writer(path)
        manifest["files"][f"{name}.xml"] = {
            "bytes": path.stat().st_size,
            "sha256": sha256_of(path),
        }
        print(f"[libxml2-generate] {path.name}: {path.stat().st_size} bytes")
    manifest_path = output / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"[libxml2-generate] manifest: {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
