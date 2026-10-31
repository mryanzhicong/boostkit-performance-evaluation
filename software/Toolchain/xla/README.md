# XLA 提交 1930995a8aab 性能测试

本用例在 x86_64、aarch64 Runner 上从官方源码构建 [openxla/xla](https://github.com/openxla/xla)
固定提交，并使用 XLA 官方基准套件（仓库自带的 `xla/tools/benchmarks` CPU 注册表条目和
`.github/workflows/benchmarks/run_benchmark.sh` 执行链）进行开箱性能对比。不修改源码，
不绑核，不做额外调优。**构建与测试全部在 openEuler 24.03 LTS SP4 容器内运行**
（基镜像与用法参照 MySQL 用例），容器不绑核、不绑 NUMA、使用宿主机网络；源码、构建
产物和结果目录通过 bind mount 保存在宿主机本次任务目录。

软件入口为 `xla_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也使用这些阶段函数。基础版构建位于 `scripts/builders/base.sh`，公共路径在
`scripts/common.sh`，结果处理在 `scripts/results/`。工作流可选择 `base` 或 `optimized`，
默认 `base`；`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

openxla/xla 采用滚动开发模式，没有 release 或 tag，因此软件版本以提交固定：

| 项目 | 值 |
|---|---|
| 仓库 | `https://github.com/openxla/xla.git` |
| 提交（完整） | `1930995a8aabe45a13854f701b5b39ab732aef94` |
| 提交（清单版本） | `1930995a8aab`（2026-10-31） |

混合精度（bf16）工作负载在固定提交内自带，另外两个工作负载来自官方 GCS 桶，均以
SHA-256 固定（见下表）；更换提交时必须同时更新 `xla_test.sh` 中的提交和三份 HLO 校验值。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| XLA | 官方仓库固定提交（bazel 源码构建，非二进制包） | 容器内 `${PERF_WORK_DIR}/xla-src`（宿主机同路径可见） |
| Bazel | 由仓库 `.bazelversion` 固定为 `8.8.2`，经 bazelisk 下载 | `${PERF_WORK_DIR}/bazel-root` |
| bazelisk | 官方 GitHub Release [`v1.29.0`](https://github.com/bazelbuild/bazelisk/releases/tag/v1.29.0)（`bazelisk-linux-amd64` / `bazelisk-linux-arm64`，SHA-256 校验） | `${PERF_WORK_DIR}/bazelisk/bazelisk` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载；SHA-256 校验后 `docker load` |
| 基准执行链 | 仓库自带 `run_benchmark.sh`、`hlo_runner_main`、`compute_xspace_stats_main` | 固定提交内构建 |

`x` 架构到官方硬件类别的对应关系：`x86_64 → CPU_X86`，`aarch64 → CPU_ARM64`；
`run_benchmark.sh` 在 CPU 上以 `--device_type=host` 运行，指标名两种架构一致。

脚本在容器内用 `dnf` 安装缺失的系统依赖：`git`、`curl`、`jq`、`python3`、`tar`、
`gzip`、`unzip`、`findutils`、`sed`、`coreutils`、`which`、`diffutils`、`patch`、
`make`、`gcc`、`gcc-c++`。XLA 默认使用自带的 hermetic clang 工具链，不依赖系统 GCC。
容器内仓库切换为华为云 openEuler 镜像；启用 `PERF_PROXY` 时，容器挂载代理 CA 证书目录
并执行 `update-ca-trust extract`，`git`、`curl` 与 Bazel 的下载都通过代理。

## 容器

每个任务创建且仅创建一个私有容器 `boostkit-xla-<架构>-<run-id>`，带
`boostkit.xla.run-id=<run-id>` 归属标签。启动方式：

```bash
docker run --detach --name "${XLA_CONTAINER_NAME}" \
  --label "boostkit.xla.run-id=${PERF_RUN_ID}" \
  --network=host --ulimit nofile=1048576:1048576 \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${XLA_CONTAINER_IMAGE}" sleep infinity
```

- 不使用 `--cpus`、`--cpuset-cpus`、`--cpuset-mems`：不绑核、不绑 NUMA。
- `--network=host`：容器直接使用宿主机网络。
- `--ulimit nofile=1048576:1048576`：Bazel 启动时需要较多文件描述符，Docker 守护进程
  的默认上限可能只有 1024，会导致 `epoll_create1() failed: Too many open files`。
- `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 以宿主机原路径挂载，源码、Bazel 产物和所有
  测试结果都落在宿主机指定目录；容器内的 `HOME` 与 `BAZELISK_HOME` 指向任务私有目录，
  避免 bazelisk 尝试写入镜像内不可写的 `/home/runner/.cache`。
- `stop` 阶段只停止并删除带本任务归属标签的容器，重复调用安全。

## 获取、构建与版本核对

bazelisk 优先读取离线包 `/home/runner/software/xla/bazelisk-linux-<arch>`（与上游 Release
资产同名，不带版本号；版本由下方 SHA-256 固定），
缺失时从官方 Release 下载；两种来源都校验 SHA-256：

| 架构 | 文件 | 下载地址 | SHA-256 |
|---|---|---|---|
| `x86_64` | `bazelisk-linux-amd64` | <https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-linux-amd64> | `5a408715e932c0250d28bd84555f12edbf70117de42f9181691c736eacc4a992` |
| `aarch64` | `bazelisk-linux-arm64` | <https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-linux-arm64> | `e20e8b0f4f240091b7a55bf17b9398bd4f40ee70ae0208dff95dd4c445fb4010` |

源码与构建命令形态：

```bash
docker exec "${XLA_CONTAINER_NAME}" git clone --filter=blob:none \
  https://github.com/openxla/xla.git "${PERF_WORK_DIR}/xla-src"
docker exec "${XLA_CONTAINER_NAME}" git -C "${PERF_WORK_DIR}/xla-src" \
  checkout --detach 1930995a8aabe45a13854f701b5b39ab732aef94
docker exec "${XLA_CONTAINER_NAME}" git -C "${PERF_WORK_DIR}/xla-src" \
  rev-parse --short=12 HEAD   # 必须为 1930995a8aab

docker exec "${XLA_CONTAINER_NAME}" sh -c \
  "cd '${PERF_WORK_DIR}/xla-src' && python3 ./configure.py --backend=CPU && \
   '${PERF_WORK_DIR}/bazelisk/bazelisk' --output_user_root='${PERF_WORK_DIR}/bazel-root' \
     build -c opt --config=nonccl --jobs=\"\$(getconf _NPROCESSORS_ONLN)\" \
     //xla/tools/multihost_hlo_runner:hlo_runner_main \
     //xla/tools:compute_xspace_stats_main"
```

`--config=nonccl` 来自仓库 `tensorflow.bazelrc`，与官方 CPU 构建类型
（`XLA_LINUX_X86_CPU_*_PRESUBMIT_GITHUB_ACTIONS` 对应的本地等价构建）一致；官方
RBE 远程执行配置只适用于 Google 内部 CI，因此使用本地构建。Bazel 依赖和产物全部位于
`${PERF_WORK_DIR}/bazel-root`，不污染系统目录。

构建完成后运行产物自己的版本核对：

```bash
git -C "${PERF_WORK_DIR}/xla-src" rev-parse --short=12 HEAD  # 写入 actual-version.txt
```

`PERF_ACTUAL_VERSION_FILE` 中记录的是从检出读取的实际提交，不直接写请求版本。

## 基准数据与正式测试

`start` 阶段把官方注册表中的三个 CPU 工作负载布置到 `${PERF_WORK_DIR}/benchmark/`：

| 基准名 | HLO 来源 | SHA-256 |
|---|---|---|
| `gemma3_1b_flax_call` | 官方 GCS `xla-benchmarking-temp/gemma3_1b_flax_call.hlo` | `b3bee2a908477a49d41dd6d0adb8ccf2a25fe0bfecb5aa7d6bdb7cee4633b7de` |
| `gemma2_2b_keras_jax` | 官方 GCS `xla-benchmarking-temp/gemma2_2b_keras_jax.hlo` | `78aaab6a47a87edbaba4d6acc10f3d5175a09c4a38b9a4cf02900c96558eb49c` |
| `gemma4_2b_bf16` | 固定提交内 `xla/tools/benchmarks/hlo/hlo_gemma4_2b_bf16.hlo` | `b3a724c8d9990f10b8b788a8879129bf47024b847da665fccc2271ce9331f5f0` |

每个文件优先读取 `/home/runner/software/xla/<文件名>`，缺失时从官方地址下载（第三个
直接取自源码树），全部校验 SHA-256。

`start` 还会用最小负载 `gemma3_1b_flax_call` 以 1 次重复完整走一遍官方执行链，确认
工具链、工作负载与剖析链路可用，冒烟产物随后丢弃。正式测试只对已验证的组合计时。

`test` 阶段对每个工作负载调用仓库自带的 `run_benchmark.sh`：

```bash
BENCHMARK_NAME=<基准名> CONFIG_ID=cpu_x86 HARDWARE_CATEGORY=CPU_X86 \
OUTPUT_DIR=<私有目录> RUNNER_BINARY=<hlo_runner_main> \
STATS_BINARY=<compute_xspace_stats_main> DEVICE_TYPE_FLAG=host \
LOCAL_ARTIFACT_PATH=<HLO> RUNTIME_FLAGS_JSON='["--num_repeats=5"]' \
XLA_FLAGS_JSON='[]' COMMIT_SHA=1930995a8aabe45a13854f701b5b39ab732aef94 \
bash .github/workflows/benchmarks/run_benchmark.sh
```

执行链：`hlo_runner_main --device_type=host --num_repeats=5` 编译并运行 HLO，最后一轮
输出 XSpace 剖析；`compute_xspace_stats_main --input=xspace.pb --device_type=CPU` 输出
`CPU Time` 和 `Wall Time`（微秒），官方脚本换算为毫秒写入 `results.json`。
每个基准的 `results.json`、`runner_stdout.txt` 与完整控制台输出保留在
`${RESULTS_DIR}/benchmark_runs/` 和 `hlo_benchmark_raw.log`。

固定负载参数（写入结果 `parameters`）：官方注册表三个 CPU 条目、`--num_repeats=5`、
`--device_type=host`、无额外 XLA flags。硬件类别（`CPU_X86`/`CPU_ARM64`）与 `config_id`
属于架构相关值，写入 `runtime_context`，不进入 `parameters`，保证跨架构参数签名一致；
CPU 型号与核数等机器相关值记录在系统信息中，不跨架构强行统一。

预计单架构耗时：镜像加载与容器内依赖安装 5–15 分钟，bazel 依赖下载 10–30 分钟，
XLA 构建 1–3 小时（随核数变化），三个基准各 5 次重复约 20–60 分钟；峰值磁盘约 30 GiB。

## 指标与产物

每个基准保留官方执行链产出的 2 个字段，不做平均、加权或跨基准聚合，总计 6 个指标：

| 指标名 | 官方字段 | 单位 | 方向 | 含义 |
|---|---|---|---|---|
| `<基准名>/CPU_TIME` | `results.json` 的 `metrics.CPU_TIME.value` | ms | 越小越好 | XSpace 剖析轮的 CPU 时间 |
| `<基准名>/WALL_TIME` | `results.json` 的 `metrics.WALL_TIME.value` | ms | 越小越好 | 同一轮的墙钟时间 |

解析器要求三个基准的 `results.json` 全部存在、`run_status == SUCCESS`、硬件类别与
本机架构一致、两个指标均为正数且单位为 ms；缺项、失败或数值异常时测试失败，不补零、
不估算。报告按基准名分组。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `hlo_benchmark_raw.log` | 三个基准的完整控制台输出 |
| `benchmark_runs/<基准名>/results.json` | 官方执行链产出的结构化结果 |
| `benchmark_runs/<基准名>/runner_stdout.txt` | `hlo_runner_main` 与统计工具的原始输出 |
| `benchmark_xla.json` | 汇总后的指标、参数与来源字段 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从源码检出读取的实际提交 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段停止并删除本任务的容器（按归属标签校验），无需停止其他服务；宿主机的
`${PERF_WORK_DIR}` 由 Framework 或独立入口清理，`${RESULTS_DIR}` 保留。脱离 Workflow
执行完整流程（宿主机需可访问 Docker daemon）：

```bash
bash software/Toolchain/xla/xla_test.sh \
  --version 1930995a8aab \
  --variant base \
  --results-dir /home/runner/boostkit-perf/xla/results/1930995a8aab
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于该版本下的
`optimized/` 子目录。排错时可加 `--keep-workdir` 保留源码、Bazel 产物和已下载的 HLO。
