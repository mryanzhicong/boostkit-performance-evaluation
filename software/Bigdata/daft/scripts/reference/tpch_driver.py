#!/usr/bin/env python3
"""Daft 官方 TPC-H 的多轮驱动：查询、计时、预热全部复用 Daft v0.7.2 源码里的官方实现。

本脚本只在官方入口 `python -m benchmarking.tpch` 外面加三件事：
  1. 同一进程内跑多轮（官方入口一个进程只跑一轮）；
  2. 单个查询失败只记录错误、继续跑下一个（官方入口任一查询失败整轮 CSV 全丢）；
  3. 每个查询跑完立刻追加写 timings.jsonl，不等整轮结束。
另有 --mode answers：把 22 个查询的结果各写一份 parquet，用于两台机器之间核对正确性。

必须在 Daft v0.7.2 稀疏检出目录（只含 benchmarking/）下运行，并设置 DAFT_RUNNER=native|ray。
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import time
import traceback
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, os.getcwd())

from benchmarking.tpch import answers  # noqa: E402
from benchmarking.tpch.__main__ import (  # noqa: E402
    MetricsBuilder,
    get_daft_benchmark_runner_name,
    get_df_with_parquet_folder,
    warmup_environment,
)

NUM_QUESTIONS = MetricsBuilder.NUM_TPCH_QUESTIONS


def _questions(spec: str | None) -> list[int]:
    if not spec:
        return list(range(1, NUM_QUESTIONS + 1))
    return sorted({int(s) for s in spec.split(",")})


def _append(path: Path, rec: dict) -> None:
    with path.open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
        f.flush()
        os.fsync(f.fileno())


def run_timing(parquet: str, out: Path, rounds: int, questions: list[int]) -> int:
    runner = get_daft_benchmark_runner_name()
    timings = out / "timings.jsonl"
    warmup_environment(None, parquet)                      # 官方预热：Ray 初始化 + 逐表 count
    get_df = get_df_with_parquet_folder(parquet)
    failures = 0
    for r in range(1, rounds + 1):
        mb = MetricsBuilder(runner)
        for q in questions:
            started = datetime.now(timezone.utc).isoformat()
            rec = {"round": r, "q": q, "runner": runner, "started_at": started}
            try:
                df = getattr(answers, f"q{q}")(get_df)      # 与官方一致：建图不计时
                with mb.collect_metrics(q):                 # 与官方一致：只计 collect() 墙钟
                    df.collect()
                rec["wall_s"] = mb._metrics[f"tpch_q{q}"]
            except Exception as e:  # noqa: BLE001 - 单查询失败要记下来继续跑
                failures += 1
                rec["error"] = f"{type(e).__name__}: {e}"
                rec["traceback"] = traceback.format_exc()
            _append(timings, rec)
            print(f"[tpch] round={r} q{q:02d} " + (f"{rec['wall_s']:.3f}s" if "wall_s" in rec else rec["error"]),
                  flush=True)
        mb.dump_csv(str(out / f"round_{r}.csv"))            # 官方格式的 CSV，留档用
    return 1 if failures else 0


def run_answers(parquet: str, out: Path, questions: list[int]) -> int:
    import pyarrow.parquet as pq

    get_df = get_df_with_parquet_folder(parquet)
    ans = out / "answers"
    ans.mkdir(parents=True, exist_ok=True)
    failures = 0
    for q in questions:
        try:
            pq.write_table(getattr(answers, f"q{q}")(get_df).to_arrow(), ans / f"q{q:02d}.parquet")
            print(f"[answers] q{q:02d} ok", flush=True)
        except Exception as e:  # noqa: BLE001
            failures += 1
            print(f"[answers] q{q:02d} FAILED {type(e).__name__}: {e}", flush=True)
    return 1 if failures else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--parquet", required=True, help="TPC-H parquet 目录（下含 lineitem/ orders/ ... 子目录）")
    ap.add_argument("--out", required=True, help="本次运行的输出目录")
    ap.add_argument("--mode", choices=["timing", "answers"], default="timing")
    ap.add_argument("--rounds", type=int, default=4, help="轮数；第 1 轮在汇总时作为预热丢弃")
    ap.add_argument("--questions", default=None, help="逗号分隔，默认全部 22 个")
    args = ap.parse_args()

    parquet = args.parquet.rstrip("/") + "/"
    for t in ("lineitem", "orders", "customer", "part", "partsupp", "supplier", "nation", "region"):
        if not list(Path(parquet, t).glob("*.parquet")):
            sys.exit(f"missing parquet for table {t} under {parquet}")
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    t0 = time.time()
    if args.mode == "timing":
        rc = run_timing(parquet, out, args.rounds, _questions(args.questions))
    else:
        rc = run_answers(parquet, out, _questions(args.questions))
    print(f"[tpch] mode={args.mode} done in {time.time() - t0:.1f}s rc={rc}", flush=True)
    return rc


if __name__ == "__main__":
    sys.exit(main())
