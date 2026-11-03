#!/usr/bin/env python3
"""Generate the deterministic XML corpora used by the expat matrix.

The corpora are plain, self-contained XML documents.  Only the external-DTD
corpus references a second file (``external.dtd``, generated next to it), so the
external-entity path can be measured without any network access.  The generator
is deterministic: the same source tree always produces byte-identical files, and
the manifest records the exact size and SHA-256 of every corpus so the parser
derives throughput (MiB/s) from the bytes that were really parsed.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

NAMESPACE_PREFIXES = ("", "a:", "b:", "c:")
KINDS = ("alpha", "beta", "gamma")


def write_wide(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n<benchmark run="2026-10-30">\n')
        for index in range(items):
            handle.write(
                f'  <item id="i{index:06d}" name="item-{index}" kind="alpha" '
                f'weight="{index % 97}">payload &amp; text {index}</item>\n'
            )
        handle.write("</benchmark>\n")


def write_namespaced(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        handle.write(
            '<root xmlns="urn:bench:default" xmlns:a="urn:bench:a" '
            'xmlns:b="urn:bench:b" xmlns:c="urn:bench:c">\n'
        )
        for index in range(items):
            prefix = NAMESPACE_PREFIXES[index % len(NAMESPACE_PREFIXES)]
            kind = KINDS[index % len(KINDS)]
            flag = "true" if index % 2 == 0 else "false"
            handle.write(
                f'  <{prefix}node id="n{index}" a:seq="{index}" '
                f'b:kind="{kind}" c:flag="{flag}">text {index}</{prefix}node>\n'
            )
        handle.write("</root>\n")


def write_entities(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        handle.write("<!DOCTYPE feed [\n")
        handle.write('  <!ENTITY product "Widget &amp; Gadget Corporation">\n')
        handle.write('  <!ENTITY tag "benchmark-entity-value">\n')
        handle.write("]>\n<feed>\n")
        for index in range(items):
            handle.write(
                f'  <entry id="e{index}"><name>&product; #{index}</name>'
                f"<tag>&tag;</tag></entry>\n"
            )
        handle.write("</feed>\n")


def write_external_dtd(path: Path) -> None:
    path.write_text(
        "<!ELEMENT catalog (item)*>\n"
        "<!ELEMENT item (#PCDATA)>\n"
        '<!ATTLIST item id CDATA #REQUIRED kind (alpha|beta|gamma) #REQUIRED '
        "weight CDATA #IMPLIED>\n",
        encoding="utf-8",
    )


def write_dtd_external(path: Path, items: int) -> None:
    with path.open("w", encoding="utf-8") as handle:
        handle.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        handle.write('<!DOCTYPE catalog SYSTEM "external.dtd">\n<catalog>\n')
        for index in range(items):
            kind = KINDS[index % len(KINDS)]
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
    parser.add_argument("--benchmark-iterations", type=int, default=20)
    parser.add_argument("--benchmark-buffer", type=int, default=8192)
    args = parser.parse_args()
    output = args.output
    output.mkdir(parents=True, exist_ok=True)

    specs = {
        "wide": lambda path: write_wide(path, 100_000),
        "huge": lambda path: write_wide(path, 400_000),
        "namespaced": lambda path: write_namespaced(path, 40_000),
        "entities": lambda path: write_entities(path, 150_000),
        "dtd_ext": lambda path: write_dtd_external(path, 60_000),
    }
    write_external_dtd(output / "external.dtd")
    manifest = {
        "generator": "scripts/generate_corpus.py",
        "benchmark_iterations": args.benchmark_iterations,
        "benchmark_buffer": args.benchmark_buffer,
        "files": {},
    }
    for name, writer in specs.items():
        path = output / f"{name}.xml"
        writer(path)
        manifest["files"][f"{name}.xml"] = {
            "bytes": path.stat().st_size,
            "sha256": sha256_of(path),
        }
        print(f"[expat-generate] {path.name}: {path.stat().st_size} bytes")
    external = output / "external.dtd"
    manifest["files"]["external.dtd"] = {
        "bytes": external.stat().st_size,
        "sha256": sha256_of(external),
    }
    manifest_path = output / "manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"[expat-generate] manifest: {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
