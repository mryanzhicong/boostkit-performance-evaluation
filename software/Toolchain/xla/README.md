# XLA 性能测试说明

本目录测试 OpenXLA 官方仓库 [openxla/xla](https://github.com/openxla/xla)
固定提交上的 XLA 编译器，并使用 XLA 官方基准套件（仓库自带
`xla/tools/benchmarks` 注册表中的 CPU 条目 + 仓库自带的
`run_benchmark.sh` 执行链）进行 x86_64 与 aarch64 开箱性能对比。软件入口
为 `xla_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

openxla/xla 采用滚动开发模式，没有 release/tag，因此软件版本以提交
SHA 固定（与 mysql 用例固定 database_blue 提交的方式一致）。当前清单
仅声明提交 `46bedfb7bd71`（完整提交
`46bedfb7bd71ae6574ca6d8d4109fdd44fa2971d`，2026-09-10）。更换版本时，
必须同步更新 `xla_test.sh` 中的 `XLA_COMMIT` 与三个 HLO 工作负载的
SHA-256，不能跳过校验。

## 构建与安装

这里的“构建”是从官方源码编译 XLA 基准执行链，不安装任何系统级
LLVM/XLA 软件包：

1. 按 `--filter=blob:none` 部分克隆官方仓库并 `git checkout --detach`
   到固定提交，校验 `git rev-parse --short=12 HEAD` 与请求版本一致；
2. 从 bazelisk 官方 GitHub Release（`v1.29.0`，按架构选择
   `bazelisk-linux-amd64` / `bazelisk-linux-arm64`，SHA-256 校验）获取
   bazelisk；Bazel 版本由仓库内 `.bazelversion` 固定为 `8.7.0`，
   bazelisk 自动下载对应版本；
3. 在源码目录本地构建官方 CI 基准目标（官方 presubmit 构建类型使用的
   目标与 `--config=nonccl` 配置；其 RBE 远程执行配置仅适用于 Google
   内部 CI，自建 Runner 使用本地等价构建）：

   ```bash
   bazelisk --output_user_root="${PERF_WORK_DIR}/bazel-root" \
     build -c opt --config=nonccl --jobs="$(getconf _NPROCESSORS_ONLN)" \
     //xla/tools/multihost_hlo_runner:hlo_runner_main \
     //xla/tools:compute_xspace_stats_main
   ```

XLA 默认启用 hermetic C++ 工具链（`.bazelrc` 中
`USE_HERMETIC_CC_TOOLCHAIN=1`），编译使用仓库自带的 clang，不依赖系统
GCC 版本。Bazel 拉取依赖与产物全部位于
`${PERF_WORK_DIR}/bazel-root`，不污染系统目录。运行时缺失的系统命令
（`git`、`python3`、`jq` 等）由脚本自动通过 `dnf` 安装；非 root Runner
使用 `sudo -n dnf`。

在 Runner 预置离线包时，放入 `/home/runner/software/xla/`，文件名需带
版本号：

```bash
sudo install -d -o runner -g runner /home/runner/software/xla
sudo install -o runner -g runner bazelisk-linux-arm64-v1.29.0 \
  /home/runner/software/xla/
sha256sum /home/runner/software/xla/bazelisk-linux-arm64-v1.29.0
```

## 基准就绪（start）

XLA 没有常驻服务。`start` 阶段把官方基准注册表
（`xla/tools/benchmarks/benchmark_registry.pbtxt`）中带 CPU 配置的三个
Gemma HLO 工作负载布置到本次任务的 `PERF_WORK_DIR/benchmark` 目录：

| 基准名 | HLO 来源 | SHA-256（前 16 位） |
|---|---|---|
| `gemma3_1b_flax_call` | 官方 GCS `xla-benchmarking-temp/gemma3_1b_flax_call.hlo` | `b3bee2a908477a49` |
| `gemma2_2b_keras_jax` | 官方 GCS `xla-benchmarking-temp/gemma2_2b_keras_jax.hlo` | `78aaab6a47a87edb` |
| `gemma4_2b_bf16` | 固定提交仓库内 `xla/tools/benchmarks/hlo/hlo_gemma4_2b_bf16.hlo` | `b3a724c8d9990f10` |

前两个工作负载依次从 `/home/runner/software/xla/<文件名>` 本地离线包、
已缓存副本、官方 GCS URL 获取；第三个直接取自固定提交的源码树。三个
文件全部做 SHA-256 校验，校验失败立即退出。

源码就绪后，`start` 阶段用最小负载 `gemma3_1b_flax_call` 以
`--num_repeats=1` 完整走一遍官方执行链（hlo_runner_main → XSpace 剖析
→ compute_xspace_stats_main → results.json），确认工具链、工作负载与
剖析链路全部可用后丢弃冒烟产物；`test` 阶段只对已验证的组合计时。

## 性能测试

测试直接调用 XLA 仓库自带的官方执行脚本
`.github/workflows/benchmarks/run_benchmark.sh`（即官方
`hlo_workload_executor` 复合动作的核心步骤），对每个基准执行：

```bash
hlo_runner_main --device_type=host --num_repeats=5 \
  --xla_gpu_dump_xspace_to=<目录>/xspace.pb <负载>.hlo
compute_xspace_stats_main --input=<目录>/xspace.pb --device_type=CPU
```

执行链说明：

1. `hlo_runner_main` 在 CPU（`--device_type=host`）上编译并运行 HLO
   模块，每档重复 `XLA_NUM_REPEATS`（默认 5）次，最后一轮开启 XSpace
   剖析；HLO 参数由 runner 随机初始化；
2. `compute_xspace_stats_main` 从 XSpace 剖析中输出被剖析那一轮的
   `CPU Time` 与 `Wall Time`（微秒），官方脚本换算为毫秒写入
   `results.json`（`run_status`、`metrics.CPU_TIME`、`metrics.WALL_TIME`）；
3. 每个基准的 `results.json` 与完整 `runner_stdout.txt` 保留在
   `benchmark_runs/<基准名>/`，整轮控制台输出保留为
   `hlo_benchmark_raw.log`；
4. 三个基准全部完成后，`scripts/collect_xla_benchmark.py` 校验每个
   `results.json`（`run_status == SUCCESS`、硬件类别与本机架构一致、
   两个指标为正数且单位为 ms）并汇总为顶层 `results.json`。

架构与官方硬件类别的对应关系：`x86_64 → CPU_X86`、
`aarch64 → CPU_ARM64`（即官方 `build_binaries.sh` 支持的两种 CPU 类别）。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop
并保存同样的产物。例如：

```bash
bash software/Toolchain/xla/xla_test.sh \
  --version 46bedfb7bd71 \
  --results-dir /home/runner/boostkit-perf/xla/results/46bedfb7bd71
```

## 指标

每个基准保留官方执行链产出的 2 个字段，不做平均、加权或跨基准聚合。
总计为：

```text
3 个基准 × 2 个指标 = 6 个指标
```

| 官方字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `CPU_TIME` | `<基准名>: CPU_TIME` | ms | 越小越好 | 被剖析一轮执行的 CPU 时间（核心时间合计，官方 us→ms 换算） |
| `WALL_TIME` | `<基准名>: WALL_TIME` | ms | 越小越好 | 被剖析一轮执行的墙钟时间 |

报告按基准名分组展示，便于在相同 HLO 负载下比较 x86_64 与 aarch64。
构建工具及其固定版本（bazelisk `v1.29.0`、Bazel `8.7.0`）会同时列在
报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `hlo_benchmark_raw.log`：整轮控制台原始输出；
- `benchmark_runs/`：每个基准的官方 `results.json` 与 `runner_stdout.txt`；
- `results.json`：6 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务，仅移除本次任务布置的 HLO 工作负载目录
`PERF_WORK_DIR/benchmark`。Standalone 模式结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/xla/local-*` 工作目录（含 bazel 构建缓存）；
Framework 随后执行 Runner 级环境清理。
