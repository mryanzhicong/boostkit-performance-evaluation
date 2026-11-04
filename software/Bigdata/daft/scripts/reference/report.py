#!/usr/bin/env python3
"""汇总两台机器的 TPC-H 开箱结果。只依赖 pyarrow（venv 里已有）。

  perf     各机器每个查询取中位数（丢弃第 1 轮预热），给出整机倍率和按物理核归一化倍率
  answers  逐查询核对两台机器的结果是否一致（浮点按相对误差比较）

用法::

    python report.py perf    --result results/kp950 --result results/epyc9654 --sf 100 --runner native
    python report.py answers --a results/kp950/sf100/answers --b results/epyc9654/sf100/answers
"""
from __future__ import annotations

import argparse
import json
import math
import re
import statistics
import sys
from pathlib import Path

NUM_Q = 22
SPREAD_WARN = 0.10
# 上游 q15 用浮点等值 join（max(total_revenue) 与逐供应商 total_revenue 各算一遍），并行求和顺序
# 不同时末位不等、结果为 0 行；同一台机器反复跑也会 0/1 行交替。计算量相同，计时照常有效。
KNOWN_UNSTABLE = {15: "浮点等值 join，结果 0 或 1 行不确定（上游实现特性）"}


def _cpu(env_dir: Path) -> dict:
    """从 lscpu.txt 取 CPU 型号与核数。"""
    info = {}
    p = env_dir / "lscpu.txt"
    if not p.exists():
        return info
    for line in p.read_text(encoding="utf-8", errors="replace").splitlines():
        k, _, v = line.partition(":")
        info[k.strip()] = v.strip()
    out = {"model": info.get("Model name", "?"), "logical": int(info.get("CPU(s)", 0) or 0)}
    try:
        out["physical"] = int(info["Core(s) per socket"]) * int(info["Socket(s)"])
    except (KeyError, ValueError):
        out["physical"] = 0
    out["threads_per_core"] = info.get("Thread(s) per core", "?")
    out["numa_nodes"] = info.get("NUMA node(s)", "?")
    return out


def _load(result: Path, sf: str, runner: str) -> dict:
    timings = result / f"sf{sf}" / runner / "timings.jsonl"
    if not timings.exists():
        sys.exit(f"missing {timings}")
    per_q: dict[int, list[float]] = {}
    errors: dict[int, list[str]] = {}
    rounds = set()
    for line in timings.read_text(encoding="utf-8").splitlines():
        rec = json.loads(line)
        rounds.add(rec["round"])
        if rec["round"] == 1:                       # 第 1 轮是预热
            continue
        if "wall_s" in rec:
            per_q.setdefault(rec["q"], []).append(rec["wall_s"])
        else:
            errors.setdefault(rec["q"], []).append(rec.get("error", "?"))
    mem = None
    mem_log = result / f"sf{sf}" / runner / "mem_used_mb.log"
    if mem_log.exists():
        xs = [int(v.split()[1]) for v in mem_log.read_text().splitlines() if len(v.split()) == 2]
        if xs:
            mem = (xs[0] / 1024, max(xs) / 1024)
    return {"name": result.name, "cpu": _cpu(result / "env"), "rounds": max(rounds) if rounds else 0,
            "per_q": per_q, "errors": errors, "mem_gb": mem}


def _fmt(x: float | None, nd: int = 2) -> str:
    return "—" if x is None else f"{x:.{nd}f}"


def cmd_perf(args) -> int:
    ms = [_load(Path(r), args.sf, args.runner) for r in args.result]
    base = ms[0]
    lines = [f"# Daft 0.7.2 TPC-H SF{args.sf} 开箱对比（runner={args.runner}）", ""]
    lines += ["| 机器 | CPU | 物理核 | 逻辑核 | 每核线程 | NUMA 节点 | 有效轮数 |", "|---|---|---|---|---|---|---|"]
    for m in ms:
        c = m["cpu"]
        lines.append(f"| {m['name']} | {c.get('model', '?')} | {c.get('physical', '?')} | {c.get('logical', '?')} "
                     f"| {c.get('threads_per_core', '?')} | {c.get('numa_nodes', '?')} | {max(m['rounds'] - 1, 0)} |")
    lines.append("")
    others = ms[1:]
    head = "| 查询 | " + " | ".join(f"{m['name']} 中位数 s" for m in ms)
    head += "".join(f" | {m['name']}/{base['name']} 整机倍率 | 按物理核归一化" for m in others) + " | 离散度提示 |"
    lines += [head, "|" + "---|" * (head.count("|") - 1)]
    ratios: dict[str, list[float]] = {m["name"]: [] for m in others}
    core_ratios: dict[str, list[float]] = {m["name"]: [] for m in others}
    totals = {m["name"]: 0.0 for m in ms}
    warn_spread = []
    for q in range(1, NUM_Q + 1):
        med = {}
        for m in ms:
            xs = m["per_q"].get(q)
            if xs and not m["errors"].get(q):
                med[m["name"]] = statistics.median(xs)
                spread = (max(xs) - min(xs)) / med[m["name"]] if med[m["name"]] else 0.0
                if spread > SPREAD_WARN:
                    warn_spread.append(f"{m['name']} q{q} {spread:.0%}")
        complete = len(med) == len(ms)
        row = f"| q{q} | " + " | ".join(_fmt(med.get(m["name"]), 3) for m in ms)
        for m in others:
            r = cr = None
            if complete:
                r = med[m["name"]] / med[base["name"]]
                ratios[m["name"]].append(r)
                pb, po = base["cpu"].get("physical") or 0, m["cpu"].get("physical") or 0
                if pb and po:
                    cr = r * po / pb
                    core_ratios[m["name"]].append(cr)
            row += f" | {_fmt(r)} | {_fmt(cr)}"
        flags = [w.split()[0] for w in warn_spread if w.split()[1] == f"q{q}"]
        row += f" | {'、'.join(flags) if flags else ''} |"
        lines.append(row)
        if complete:
            for m in ms:
                totals[m["name"]] += med[m["name"]]
    lines.append("")
    lines.append("合计（只算所有机器都成功的查询，中位数相加）：" +
                 "，".join(f"{n} {t:.2f}s" for n, t in totals.items()))
    for m in others:
        rs, crs = ratios[m["name"]], core_ratios[m["name"]]
        if rs:
            g = math.exp(sum(map(math.log, rs)) / len(rs))
            line = f"{m['name']}/{base['name']}：几何平均整机倍率 {g:.3f}（>1 表示 {base['name']} 更快）"
            if crs:
                gc = math.exp(sum(map(math.log, crs)) / len(crs))
                line += f"，按物理核归一化 {gc:.3f}"
            lines.append(line)
    for m in ms:
        if m["mem_gb"]:
            lines.append(f"{m['name']} 整机已用内存：运行前 {m['mem_gb'][0]:.1f} GB，峰值 {m['mem_gb'][1]:.1f} GB")
    errs = [f"{m['name']} q{q}: {e[0]}" for m in ms for q, e in sorted(m["errors"].items())]
    if errs:
        lines += ["", "失败的查询（不计入合计和倍率）："] + [f"- {e}" for e in errs]
    if warn_spread:
        lines += ["", f"离散度超过 {SPREAD_WARN:.0%} 的查询（(最大 − 最小) / 中位数），须排除干扰或增加轮数后重测："]
        lines += [f"- {w}" for w in warn_spread]
    text = "\n".join(lines) + "\n"
    if args.out:
        Path(args.out).write_text(text, encoding="utf-8")
    print(text)
    return 1 if errs else 0


def _canonical(tbl):
    """按全部列排序，消除并列行顺序差异；浮点列先按 6 位有效数字取整再参与排序。"""
    import pyarrow as pa
    import pyarrow.compute as pc

    keys = []
    cols = {}
    for name in tbl.column_names:
        col = tbl.column(name)
        if pa.types.is_floating(col.type):
            cols[f"__k_{name}"] = pa.array([None if v is None else float(f"{v:.6g}") for v in col.to_pylist()])
            keys.append((f"__k_{name}", "ascending"))
        else:
            keys.append((name, "ascending"))
    for k, v in cols.items():
        tbl = tbl.append_column(k, v)
    tbl = tbl.take(pc.sort_indices(tbl, sort_keys=keys))
    return tbl.drop_columns(list(cols))


def cmd_answers(args) -> int:
    import pyarrow.parquet as pq

    bad = 0
    for q in range(1, NUM_Q + 1):
        pa_, pb_ = Path(args.a) / f"q{q:02d}.parquet", Path(args.b) / f"q{q:02d}.parquet"
        if not pa_.exists() or not pb_.exists():
            print(f"q{q:02d} MISSING ({pa_.exists()=}, {pb_.exists()=})")
            bad += 1
            continue
        ta, tb = pq.read_table(pa_), pq.read_table(pb_)
        problems = []
        if ta.column_names != tb.column_names:
            problems.append(f"columns {ta.column_names} != {tb.column_names}")
        elif q in KNOWN_UNSTABLE and ta.num_rows != tb.num_rows and max(ta.num_rows, tb.num_rows) <= 1:
            print(f"q{q:02d} rows={ta.num_rows}/{tb.num_rows} UNSTABLE-KNOWN（{KNOWN_UNSTABLE[q]}，不计为不一致）")
            continue
        elif ta.num_rows != tb.num_rows:
            problems.append(f"rows {ta.num_rows} != {tb.num_rows}")
        else:
            ta, tb = _canonical(ta), _canonical(tb)
            for name in ta.column_names:
                va, vb = ta.column(name).to_pylist(), tb.column(name).to_pylist()
                for i, (x, y) in enumerate(zip(va, vb)):
                    if isinstance(x, float) and isinstance(y, float):
                        same = math.isclose(x, y, rel_tol=args.rtol, abs_tol=args.atol)
                    else:
                        same = x == y
                    if not same:
                        problems.append(f"col {name} row {i}: {x!r} != {y!r}")
                        break
        status = "OK" if not problems else "DIFF " + "; ".join(problems)
        bad += bool(problems)
        print(f"q{q:02d} rows={ta.num_rows:<6} {status}")
    print(f"{NUM_Q - bad}/{NUM_Q} queries match")
    return 1 if bad else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("perf")
    p.add_argument("--result", action="append", required=True, help="results/<机器标签>；第一个作为倍率基准")
    p.add_argument("--sf", required=True, help="与运行时一致，例如 100")
    p.add_argument("--runner", default="native", choices=["native", "ray"])
    p.add_argument("--out", default=None, help="同时写入该 markdown 文件")
    a = sub.add_parser("answers")
    a.add_argument("--a", required=True)
    a.add_argument("--b", required=True)
    a.add_argument("--rtol", type=float, default=1e-6)
    a.add_argument("--atol", type=float, default=1e-6)
    args = ap.parse_args()
    if not re.fullmatch(r"[0-9]+(\.[0-9]+)?", getattr(args, "sf", "0")):
        sys.exit("--sf must be a number")
    return cmd_perf(args) if args.cmd == "perf" else cmd_answers(args)


if __name__ == "__main__":
    sys.exit(main())
