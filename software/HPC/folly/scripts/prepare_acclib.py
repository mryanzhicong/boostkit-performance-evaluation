#!/usr/bin/env python3
"""Copy AccLibBenchmark and remove fork-only calls from the private copy.

The original benchmark checkout and all four upstream dependency checkouts are
left untouched.  The benchmark always runs with io_uring disabled.
"""

from __future__ import annotations

import hashlib
import json
import shutil
import sys
from pathlib import Path


def replace_once(data: bytes, old: bytes, new: bytes, label: str) -> bytes:
    if data.count(old) != 1:
        raise RuntimeError(f"expected one {label} compatibility site, found {data.count(old)}")
    return data.replace(old, new)


def prepare(source: Path, target: Path, manifest: Path) -> None:
    benchmark = source / "fbthrift_folly_benchmark"
    if not benchmark.is_dir() or not (benchmark / "CMakeLists.txt").is_file():
        raise RuntimeError(f"AccLibBenchmark source is incomplete: {benchmark}")
    if target.exists():
        raise RuntimeError(f"private benchmark directory already exists: {target}")
    shutil.copytree(benchmark, target)
    original_hashes = {}
    for relative in ("server/PressServer.cpp", "client/PressTestClient.cpp"):
        path = target / relative
        original_hashes[relative] = hashlib.sha256(path.read_bytes()).hexdigest()

    server = target / "server/PressServer.cpp"
    data = server.read_bytes()
    data = replace_once(
        data,
        b"#include <folly/experimental/io/IoUringBackend.h>\n",
        b"",
        "unavailable Folly io_uring header",
    )
    data = replace_once(
        data,
        b"  if (FLAGS_use_io_uring) {\n"
        b"    folly::EventBaseBackendBase::FactoryFunc bf = []() {\n"
        b"      folly::IoUringBackend::Options opts;\n"
        b"      opts.setCapacity(65536).setMaxSubmit(4096).setInitialProvidedBuffers(4096, 1024);\n"
        b"      return std::unique_ptr<folly::EventBaseBackendBase>(new folly::IoUringBackend(opts));\n"
        b"    };\n"
        b"    holder.ebm = std::make_shared<folly::EventBaseManager>(bf);\n"
        b"    auto io_pool = std::make_shared<folly::IOThreadPoolExecutor>(\n"
        b"        num_io_threads, std::make_shared<folly::NamedThreadFactory>(\"ServerIOThreadPool\"), holder.ebm.get());\n"
        b"    server->setIOThreadPool(io_pool);\n"
        b"    server->setPreferIoUring(true);\n"
        b"  } else {\n"
        b"    server->setNumIOWorkerThreads(num_io_threads);\n"
        b"  }\n",
        b"  if (FLAGS_use_io_uring) {\n"
        b"    LOG(FATAL) << \"io_uring is unavailable in this upstream build\";\n"
        b"  }\n"
        b"  server->setNumIOWorkerThreads(num_io_threads);\n",
        "fork-specific server io_uring branch",
    )
    data = replace_once(
        data,
        b"  if (!getenv(\"DISABLE_IOBUF_POOL\")) {\n"
        b"    folly::IOBuf::setBlockSize(256 * 1024);\n"
        b"    folly::IOBuf::setMaxBlocksPerThread(64);\n"
        b"    folly::IOBuf::enableMemoryPool();\n"
        b"  }\n",
        b"",
        "fork-only Folly IOBuf pool",
    )
    server.write_bytes(data)

    client = target / "client/PressTestClient.cpp"
    data = client.read_bytes()
    data = replace_once(data, b"#include <folly/experimental/io/AsyncIoUringSocket.h>\n",
                        b"", "unavailable AsyncIoUringSocket header")
    data = replace_once(data, b"#include <folly/experimental/io/IoUringBackend.h>\n",
                        b"", "unavailable IoUringBackend header")
    data = replace_once(
        data,
        b"  if (FLAGS_use_io_uring) {\n"
        b"    tsock = folly::AsyncIoUringSocket::UniquePtr(new folly::AsyncIoUringSocket(std::move(socket)));\n"
        b"  } else {\n"
        b"    tsock = std::move(socket);\n"
        b"  }\n",
        b"  if (FLAGS_use_io_uring) {\n"
        b"    LOG(FATAL) << \"io_uring is unavailable in this upstream build\";\n"
        b"  }\n"
        b"  tsock = std::move(socket);\n",
        "fork-specific client socket branch",
    )
    data = replace_once(
        data,
        b"  if (FLAGS_use_io_uring) {\n"
        b"    folly::EventBaseBackendBase::FactoryFunc bf = []() {\n"
        b"      folly::IoUringBackend::Options opts;\n"
        b"      opts.setCapacity(65536).setMaxSubmit(4096).setInitialProvidedBuffers(4096, 1024);\n"
        b"      return std::unique_ptr<folly::EventBaseBackendBase>(new folly::IoUringBackend(opts));\n"
        b"    };\n"
        b"    ebm = std::make_unique<folly::EventBaseManager>(bf);\n"
        b"  } else {\n"
        b"    ebm = std::make_unique<folly::EventBaseManager>();\n"
        b"  }\n",
        b"  ebm = std::make_unique<folly::EventBaseManager>();\n",
        "fork-specific client io_uring backend",
    )
    data = replace_once(
        data,
        b"  if (!getenv(\"DISABLE_IOBUF_POOL\")) {\n"
        b"    folly::IOBuf::setBlockSize(256 * 1024);\n"
        b"    folly::IOBuf::setMaxBlocksPerThread(64);\n"
        b"    folly::IOBuf::enableMemoryPool();\n"
        b"  }\n",
        b"",
        "fork-only client Folly IOBuf pool",
    )
    data = replace_once(data, b"'\x00'", b"'\\0'", "embedded NUL character literal")
    client.write_bytes(data)

    forbidden = (
        b"IOBuf::setBlockSize", b"IOBuf::setMaxBlocksPerThread",
        b"IOBuf::enableMemoryPool", b"setPreferIoUring",
        b"folly::AsyncIoUringSocket", b"folly::IoUringBackend",
    )
    for path in target.rglob("*"):
        if path.suffix not in {".cpp", ".h"}:
            continue
        data = path.read_bytes()
        remaining = [name.decode("ascii") for name in forbidden if name in data]
        if remaining:
            raise RuntimeError(
                f"fork-only interfaces remain in {path.relative_to(target)}: {remaining}"
            )

    adapted_hashes = {
        relative: hashlib.sha256((target / relative).read_bytes()).hexdigest()
        for relative in original_hashes
    }
    if any(adapted_hashes[name] == original_hashes[name] for name in original_hashes):
        raise RuntimeError("AccLibBenchmark compatibility changes were not applied")
    manifest.parent.mkdir(parents=True, exist_ok=True)
    manifest.write_text(
        json.dumps({"source": str(source), "original_sha256": original_hashes,
                    "adapted_sha256": adapted_hashes,
                    "compatibility_changes": ["omit fork-only IOBuf pool calls",
                                              "disable unavailable io_uring API branches",
                                              "normalize embedded NUL literal"],
                    "source_is_unchanged": True}, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("usage: prepare_acclib.py SOURCE_ROOT PRIVATE_COPY MANIFEST")
    prepare(*(Path(value) for value in sys.argv[1:]))
