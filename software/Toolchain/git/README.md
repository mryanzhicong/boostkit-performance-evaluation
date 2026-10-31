# Git 2.56.0 性能测试

本用例在 x86_64、aarch64 Runner 上从 Git 官方仓库构建 release tag `v2.56.0`，使用 Git
上游自带的性能测试套件 `t/perf`（官方 `perf-lib.sh` + 官方脚本）进行开箱性能对比。
构建遵循上游默认配置（含 Git 的 Rust 组件），不修改源码，不绑核，不做额外调优。

软件入口为 `git_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也使用这些阶段函数。基础版构建位于 `scripts/builders/base.sh`，公共路径在
`scripts/common.sh`，结果处理在 `scripts/results/`。工作流可选择 `base` 或 `optimized`，
默认 `base`；`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Git | 官方仓库 `https://github.com/git/git.git`，release tag `v2.56.0`，提交 `a018953688f1b10bddf91bff8747068f5f4746a4` | `git clone --depth 1 --branch v2.56.0` 到 `${PERF_WORK_DIR}/git-src` |
| 性能测试套件 | 固定提交内自带的 `t/perf`（`perf-lib.sh`、`run`、`aggregate.perl` 与 `pNNNN-*.sh`） | `${PERF_WORK_DIR}/git-src/t/perf` |
| GNU time | 系统包 `time`（`/usr/bin/time`，perf-lib 必需；无版本号可核实，`case.yaml` 中记为 `unknown`） | `/usr/bin/time` |

Git 2.56 的默认构建包含 Rust 组件（`src/*.rs` → `libgitcore.a`），上游 CI 同样安装
`cargo` 构建，因此本用例不设置 `NO_RUST`。脚本通过 `dnf` 安装缺失的依赖：`git`、`make`、
`gcc`、`perl`、`python3`、`gawk`、`gettext`、`zlib-devel`、`openssl-devel`、
`libcurl-devel`、`expat-devel`、`cargo`（会同时安装 `rust`）、`time`、`tar`、`gzip`。
启用 `PERF_PROXY` 时，clone 与构建的下载通过代理。

## 获取、构建与版本核对

```bash
git clone --depth 1 --branch v2.56.0 https://github.com/git/git.git "${PERF_WORK_DIR}/git-src"
git -C "${PERF_WORK_DIR}/git-src" rev-parse HEAD          # 必须为 a018953688f1b10bddf91bff8747068f5f4746a4
git -C "${PERF_WORK_DIR}/git-src" describe --tags --exact-match  # v2.56.0
cd "${PERF_WORK_DIR}/git-src" && make -j"$(nproc)" NO_TCLTK=1
"${PERF_WORK_DIR}/git-src/bin-wrappers/git" --version     # 必须报告 2.56.0
```

实际版本取自 `git describe --tags --exact-match`（短 tag 去掉 `v`）和构建产物的
`git --version`，写入 `PERF_ACTUAL_VERSION_FILE`，不直接写请求版本。`NO_TCLTK=1` 只是
跳过图形界面，不影响 `t/perf`。

**工作负载仓库**：`t/perf` 默认使用构建目录本身作为基准仓库。本用例使用 `--depth 1`
检出（`git.git` v2.56.0，4854 个工作区文件），两侧架构使用完全相同的检出。深度 1 的
历史使依赖历史遍历的脚本失去代表性，因此固定子集**排除** `p0000`（框架自检）、
`p0001-rev-list`（历史遍历）和 `p0006-read-tree-checkout`（需要 `HEAD^`）；这两个脚本
的结果在浅历史下接近 0，不能反映真实差异。该限制同样适用于两个架构，配对仍然有效。

## 正式测试

`start` 阶段检查工具链、`/usr/bin/time` 与 `t/perf`，并以 `p0002-read-cache.sh`、
1 次重复冒烟运行完整官方执行链，确认可用后清空冒烟结果。`test` 阶段固定运行以下官方
脚本子集（`GIT_PERF_REPEAT_COUNT=5`，即 upstream 默认的 best-of-5）：

```bash
cd "${PERF_WORK_DIR}/git-src/t/perf"
GIT_PERF_REPEAT_COUNT=5 ./run . -- \
  p0002-read-cache.sh p0003-delta-base-cache.sh p0004-lazy-init-name-hash.sh \
  p0005-status.sh p0007-write-cache.sh p0008-odb-fsync.sh p0009-diff-pathspec.sh \
  p0071-sort.sh p0090-cache-tree.sh p0100-globbing.sh
```

`./run .` 由上游脚本自行调用各 `pNNNN-*.sh`，每个子测试内部用 `/usr/bin/time -f
"%E %U %S"` 计时并重复 5 次取最快值；计时结果写入 `t/perf/test-results/`，完整控制台
输出（含 upstream `aggregate.perl` 汇总表）写入 `git_benchmark_raw.log`。预计单架构
耗时约 10–20 分钟（clone 与依赖安装 2–5 分钟、构建 2–5 分钟、基准 1.5–2 分钟）。

## 指标与产物

每个子测试保留 1 个字段，共 57 个指标（脚本与子测试数量固定于 v2.56.0）：

| 原始字段 | 指标名格式 | 单位 | 方向 |
|---|---|---|---|
| `test-results/<脚本>.<子测试>.result` 的第一个值（Elapsed） | `<脚本>.<子测试>: <官方 description>` | s | 越小越好 |

解析器要求 10 个脚本的 `.subtests` 数量与固定值一致（1/2/2/1/1/16/1/9/12/12），每个
子测试的 `.descr` 与 `.result` 都存在、结果行符合 `HH:MM:SS` 格式、耗时为有限非负数；
缺失、数量不符或解析失败都会使测试失败，不补零、不估算。报告按脚本分组。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `git_benchmark_raw.log` | `t/perf/run` 完整控制台输出与官方汇总表 |
| `git_perf_results/` | `test-results/` 原始 `.subtests`、`.descr`、`.result` 副本 |
| `benchmark_git.json` | 57 个指标、来源字段与固定参数 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从产物读取的实际版本 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段无需停止服务（所有进程为测试阶段的子进程，随阶段结束退出）；
私有工作目录由 Framework 或独立入口清理。脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/git/git_test.sh \
  --version 2.56.0 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/git/results/2.56.0
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于该版本下的
`optimized/` 子目录。排错时可加 `--keep-workdir` 保留源码检出与构建产物。
