# 验证清单

分五层，逐层给证据；没跑过就是“未验证”，不能写成通过。命令以 `software/AI/numpy` 为例，替换 `<sw>`。

## L0 静态与结构

```bash
cd <repo>
bash -n software/AI/<sw>/scripts/common.sh
bash -n software/AI/<sw>/scripts/builders/dispatch.sh
bash -n software/AI/<sw>/scripts/builders/base.sh
bash -n software/AI/<sw>/scripts/builders/optimized.sh
bash -n software/AI/<sw>/scripts/stages/{start,test,stop}.sh
python3 skills/add-optimized-variant/scripts/check_optimized_case.py --case software/AI/<sw>
python3 skills/add-optimized-variant/scripts/validate_bundle.py
python3 framework/catalog.py validate
```

预期：`bash -n` 全绿；`check_optimized_case.py` 无 ERROR（警告需逐条解释）；`validate_bundle.py` 打印 `portable skill structure OK`；`catalog` 通过。

若在尚未实现优化版的分支/工作区（例如 `optimized.sh` 仍返回 10）运行 `check_optimized_case.py`，它会报 “does not define `build_<sw>_optimized`” 和 “still contains the stub marker”，这是**预期行为**，说明该用例确实还没接入。

## L1 Shell 行为（不依赖容器）

在临时目录里 source `scripts/common.sh`，用假记录验证期望值加载：

```bash
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
PERF_RUN_ID=unit-test PERF_WORK_DIR="$tmp/work" RESULTS_DIR="$tmp/results" \
  PERF_VARIANT=optimized bash -c '
    source software/AI/<sw>/scripts/common.sh >/dev/null 2>&1 || true
    configure_runtime_paths
    # 1) 记录缺失 → 30，错误信息提示先跑 build
    <sw>_load_expected_source; echo "rc=$?"
    # 2) 写入记录后 → 期望 commit/tree/branch 正确
    printf "%s\n" "head=aaa..." "head_tree=bbb..." "branch=master" "parent=ccc..." > "$<SW>_SOURCE_RECORD"
    <sw>_load_expected_source; echo "$<SW>_EXPECTED_COMMIT|$<SW>_EXPECTED_TREE|$<SW>_EXPECTED_BRANCH"
    # 3) 分支不符 → 30
  '
```

补齐断言：base 变体返回钉住的基线 commit/tree 且分支为空；优化版环境包含 pip 镜像变量、不含代理黑洞；基础版相反。

## L2 解析器

用 `tests/fixtures/` 的合成结果跑解析：

```bash
NUMPY_REPS=5 NUMPY_WARMUPS=1 NUMPY_PYTHON_SHORT=3.14 SOFTWARE_VERSION=2.4.3 \
PERF_VARIANT=standalone EXPECTED_ARCH="$(uname -m)" ASV_SUITE_COMMIT=95422b2 ASV_VERSION=0.6.4 \
NUMPY_EXPECTED_COMMIT=<measured> \
python3 software/AI/<sw>/scripts/results/parse_benchmark.py \
  --results tests/fixtures/synthetic_asv_results.json \
  --list tests/fixtures/synthetic_ids.txt --out /tmp/out.json --samples /tmp/samples.json
```

必须覆盖：命中 → 0 且字段齐全；不匹配 → 50 且不产出文件；优化版文档带 `branch`/`parent_commit`/`commit_range`；基础版文档不带这些键。

## L3 Runner 短测

在 Linux Runner 上，私有目录、`PERF_REPS=1`：

```bash
PERF_VARIANT=optimized PERF_REPS=1 PERF_RUN_ID=smoke-$(date +%s) \
PERF_WORK_DIR=/tmp/<sw>-smoke PERF_RESULTS_DIR=/tmp/<sw>-smoke-results \
  ./software/AI/<sw>/<sw>_test.sh
```

检查：build 写出 `build_variant.json`（commit 为实测尖端）、`numpy-source.txt`；start 复核通过；test 产出 `runs/asv-results.json`、`results.json`（指标数对得上清单）、`asv/html/index.html`；stop 删掉本任务容器。

## L4 正式矩阵

- 双架构（ARM64/X86_64）分别跑完整清单与采样（`PERF_REPS=5`、`PERF_WARMUPS=1`）；
- 与基础版结果分开存放，不更新基础 baseline；
- 报告写明 commit/range、Python 版本、机器型号、可选项开关状态；
- 记录墙钟耗时，确认 300 分钟超时是否够用（隔离构建 + 取包会显著变慢）。

## 证据表（交付时逐行填）

| 层 | 命令 | 环境 | 退出码 | 产物/日志 | 结论 |
|---|---|---|---|---|---|
| L0 | `bash -n …` | 本机 | 0 | — | 通过 |
| L0 | `check_optimized_case.py` | 本机 | | | |
| L0 | `catalog.py validate` | 本机 | | | |
| L1 | 记录往返/缺失/分支不符 | 本机 | | | |
| L2 | 解析命中/不命中 | 本机 | | | |
| L3 | Runner 短测 | Runner | | `build_variant.json`、`runs/` | |
| L4 | 正式双架构 | Runner | | `asv/results`、`asv/html` | |

本机缺 Python/Docker 时，L0 的 Python 脚本与 L2–L4 都要标“未验证”，并给出在 Runner/CI 上执行的原命令。
