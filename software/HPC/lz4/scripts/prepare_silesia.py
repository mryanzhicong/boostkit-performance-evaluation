#!/usr/bin/env python3
"""Verify the GitHub Silesia mirror and build a reproducible tar corpus."""

import hashlib
import sys
import tarfile
import zipfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import BinaryIO, Iterable


@dataclass(frozen=True)
class CorpusMember:
    name: str
    size: int
    md5: str


# Official file order, raw sizes, and MD5 digests published by the corpus author.
CORPUS_MEMBERS: tuple[CorpusMember, ...] = (
    CorpusMember("dickens", 10_192_446, "88334708559f6db57d79096bc0aca07e"),
    CorpusMember("mozilla", 51_220_480, "c7789a2097f1ff944b0c737430a339b3"),
    CorpusMember("mr", 9_970_564, "38e623e3093b7bf2003ca4b1bbc19927"),
    CorpusMember("nci", 33_553_445, "31f85bc8706f3c921104e7c169e2e2e1"),
    CorpusMember("ooffice", 6_152_192, "573c4ae915e36631d8f2dcffb9b9b66d"),
    CorpusMember("osdb", 10_085_684, "e734b0c48e6a982adfb5802da3032ecd"),
    CorpusMember("reymont", 6_627_202, "d8f54d78105079775f32d76dc55fc671"),
    CorpusMember("samba", 21_606_400, "154eaea7ea70e89f6339ff0abf4112ca"),
    CorpusMember("sao", 7_251_944, "79e95a22e18cd82b7e42bf91b380d30b"),
    CorpusMember("webster", 41_458_703, "474931ad907ac27bf962c75ded46c069"),
    CorpusMember("x-ray", 8_474_240, "9baec32ad14ec3eff487d254382cb91c"),
    CorpusMember("xml", 5_345_280, "9b09c0c80104adb8aae910b7d7db003e"),
)
EXPECTED_CORPUS_SHA256 = "0b5ec70c8048321525f820bc1d76429840bd22ee2c7a116175253a0fec2c724d"


def digest_stream(stream: BinaryIO, algorithm: str) -> str:
    digest = (
        hashlib.md5(usedforsecurity=False)
        if algorithm == "md5"
        else hashlib.new(algorithm)
    )
    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
        digest.update(chunk)
    return digest.hexdigest()


def find_zip_member(archive: zipfile.ZipFile, expected_name: str) -> zipfile.ZipInfo:
    matches = [
        entry
        for entry in archive.infolist()
        if not entry.is_dir() and PurePosixPath(entry.filename).name == expected_name
    ]
    if len(matches) != 1:
        raise RuntimeError(
            f"expected exactly one {expected_name!r} member in the ZIP, found {len(matches)}"
        )
    return matches[0]


def validate_member(
    source_dir: Path, specification: CorpusMember
) -> str:
    archive_path = source_dir / f"{specification.name}.zip"
    if not archive_path.is_file() or archive_path.stat().st_size == 0:
        raise RuntimeError(f"Silesia ZIP is missing or empty: {archive_path}")
    with zipfile.ZipFile(archive_path) as archive:
        member = find_zip_member(archive, specification.name)
        if member.file_size != specification.size:
            raise RuntimeError(
                f"{specification.name} size is {member.file_size}, expected {specification.size}"
            )
        with archive.open(member) as stream:
            actual_md5 = digest_stream(stream, "md5")
        if actual_md5 != specification.md5:
            raise RuntimeError(
                f"{specification.name} MD5 is {actual_md5}, expected {specification.md5}"
            )
        return member.filename


def build_corpus(
    source_dir: Path,
    output_path: Path,
    specifications: Iterable[CorpusMember] = CORPUS_MEMBERS,
) -> str:
    specification_list = list(specifications)
    validated_names = [validate_member(source_dir, item) for item in specification_list]
    temporary_path = output_path.with_name(f".{output_path.name}.tmp")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        with tarfile.open(temporary_path, "w", format=tarfile.USTAR_FORMAT) as corpus:
            for specification, member_name in zip(
                specification_list, validated_names, strict=True
            ):
                archive_path = source_dir / f"{specification.name}.zip"
                with zipfile.ZipFile(archive_path) as archive:
                    member = archive.getinfo(member_name)
                    info = tarfile.TarInfo(specification.name)
                    info.size = specification.size
                    info.mode = 0o644
                    info.mtime = 0
                    info.uid = 0
                    info.gid = 0
                    info.uname = ""
                    info.gname = ""
                    with archive.open(member) as stream:
                        corpus.addfile(info, stream)
        temporary_path.replace(output_path)
    finally:
        temporary_path.unlink(missing_ok=True)

    with output_path.open("rb") as stream:
        return digest_stream(stream, "sha256")


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: prepare_silesia.py GITHUB_CHECKOUT OUTPUT_TAR", file=sys.stderr)
        return 1
    source_dir, output_path = map(Path, sys.argv[1:])
    digest = build_corpus(source_dir, output_path)
    if digest != EXPECTED_CORPUS_SHA256:
        raise RuntimeError(
            f"generated corpus SHA-256 is {digest}, expected {EXPECTED_CORPUS_SHA256}"
        )
    print(f"[lz4] prepared reproducible Silesia corpus: {digest}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
