#!/usr/bin/env python3
"""Read TexMex fvecs records and write the two official SIFT-1M Lance datasets."""

import argparse
from pathlib import Path

import lance
import numpy as np
import pyarrow as pa


DIMENSION = 128


def read_fvecs(path: Path, count: int) -> np.ndarray:
    words = np.memmap(path, dtype="<i4", mode="r")
    if words.size % (DIMENSION + 1):
        raise ValueError(f"invalid fvecs record length: {path}")
    records = words.reshape(-1, DIMENSION + 1)
    if records.shape[0] < count or not np.all(records[:count, 0] == DIMENSION):
        raise ValueError(f"expected {count} complete {DIMENSION}-dimensional vectors: {path}")
    return records[:count, 1:].copy().view("<f4")


def write_vectors(path: Path, out: Path, count: int) -> None:
    vectors = read_fvecs(path, count)
    values = pa.array(vectors.reshape(-1), type=pa.float32())
    table = pa.Table.from_arrays(
        [
            pa.array(np.arange(count, dtype=np.uint32)),
            pa.FixedSizeListArray.from_arrays(values, list_size=DIMENSION),
        ],
        names=["id", "vector"],
    )
    lance.write_dataset(
        table,
        str(out),
        max_rows_per_group=8192,
        max_rows_per_file=1024 * 1024,
    )
    if lance.dataset(str(out)).count_rows() != count:
        raise ValueError(f"Lance row count mismatch: {out}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("sift_dir", type=Path)
    parser.add_argument("output_dir", type=Path)
    args = parser.parse_args()
    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_vectors(args.sift_dir / "sift_base.fvecs", args.output_dir / "sift1m.lance", 1_000_000)
    write_vectors(args.sift_dir / "sift_query.fvecs", args.output_dir / "sift_query.lance", 1_000)


if __name__ == "__main__":
    main()
