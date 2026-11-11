# Ultrascan 5.8.0 hsbench Mean Throughput 性能测试说明

本用例从源码构建 **Ultrascan 5.8.0**（鲲鹏社区 Hyperscan 分支）及其官方基准工具
`hsbench`，在 **Intel Hyperscan hsbench-samples** 的固定规则集与固定语料上，测量
`hsbench` 在 block 模式、单线程下的 **Mean throughput**（`Mean throughput (overall)`，
单位 Mbit/s）。

## 目标

- 只统计一个指标：`hsbench` 的 `Mean throughput (overall)`，单位 **Mbit/s**，越大越好。
- 只测两种运行方式：
  1. **无通用字节码**：`hsbench -e <samples>/pcre/snort_literals -c <samples>/corpora/gutenberg.db -N -n 1`
     —— 每次启动都在进程内现场编译规则；
  2. **有通用字节码**：先用 `hsdump -N -U` 把同一规则集编译成 fat 字节码
     `<dump>/dump/db.raw`，再
     `hsbench -U <dump>/dump/db.raw -c <samples>/corpora/gutenberg.db -N -n 1`
     —— 启动时直接加载通用字节码，不再现场编译规则。
- 每个场景 **1 次预热 + N 次独立测量**（`N = PERF_REPS`，默认 5），结果取中位数；
  原始输出逐次落盘，严格解析器校验数据完整性后才产出指标。
- 其余 hsbench 字段（block rate、matches、bytecode size、peak heap、peak RSS、wall time、
  语料大小等）**一律不产出指标**，只在原始日志里保留，避免把“过程量”混进性能结论。

本用例的测量范围固定为：`snort_literals` 规则集 + `gutenberg.db` 语料、block 模式、单线程、
`-n 1`，只产出上面两个 Mean throughput 指标。

## 版本与来源

| 项目 | 值 |
|---|---|
| 被测软件 | Ultrascan 5.8.0（开源名，见仓库 `docs/zh/release_notes.md`） |
| 代码仓 | <https://gitcode.com/boostkit/Ultrascan> |
| Tag | `Ultrascan-v5.8.0` |
| 提交 | `2a2ab98890e878b6ff297f2ffe4cd2e14330b498` |
| 源码归档 | `Ultrascan-v5.8.0-2a2ab98.tar.gz`，SHA-256 `b0ad7d0126585581e93f621d1295066e7becf6d59c2179916c74e84e67f29b9b` |
| 源码 CMake 声明 | `HS_MAJOR_VERSION=5`、`HS_MINOR_VERSION=8`、`HS_PATCH_VERSION=0` |
| 测量工具 | 同源码构建的 `tools/hsbench`，**CMake Release**（`-DBUILD_EXAMPLES=OFF -DBUILD_CHIMERA=OFF`，`--target hsbench`） |
| 字节码生成工具 | 同源码构建的 `tools/hsdump`，**CMake Debug**（`--target hsdump`，仅 Debug 构建带 `DUMP_SUPPORT`，默认 Release 不产出该工具） |

测试输入来自 Intel 官方发布的 **Hyperscan hsbench-samples** 包：

| 制品 | 来源 | SHA-256 |
|---|---|---|
| 样本包 `hsbench-samples.zip` | <https://cdrdv2.intel.com/v1/dl/getContent/739375> | `1f356096e138dda0b5e7798b028b5da5a9b4d1f15d7ec88a91a764f45b1120e6` |
| `pcre/snort_literals`（Snort literal 规则集，3116 条） | 包内 `pcre/snort_literals` | `ac54e9982237fdf81912b00e4bb182fb859b7b406d109f0593e5709eadac44ee` |
| `corpora/gutenberg.db`（Gutenberg 文本语料，约 7 MB） | 包内 `corpora/gutenberg.db` | `b1d621f8280cbbf0783e03af2ff21296628ca7c7c85f5ec67c6c92e8620318a6` |

样本包与两个成员文件的 SHA-256 全部写死在 `scripts/common.sh`；任一层校验失败即退出
30，不会带病测量。样本包优先从离线目录
`${PERF_ULTRASCAN_OFFLINE_DIR:-/home/runner/software/ultrascan}/hsbench-samples.zip`
读取，其次才从上面的 URL 下载（zip 归档 + 解包后的两个成员各校验一次）。

## 为什么测两种模式

`hsbench` 的 `Mean throughput (overall)` 只统计**扫描**阶段，但两条路径的启动成本不同：

- **无通用字节码**（`-e`）：进程启动后 `hsbench` 调用 `hs_compile_multi` 把
  `snort_literals` 现场编译成本机字节码/runtime，再开始扫描。这是“从规则文本出发”的
  标准用法，端到端可复现，但每次测量都包含一次规则编译。
- **有通用字节码**（`-U`）：`hsdump` 用 Debug 构建的 `DUMP_SUPPORT` 把同一规则集编译成
  **通用字节码（fat bytecode/runtime）**，落在 `<dump>/dump/db.raw`；`hsbench -U` 直接
  `hs_deserialize_database` 加载，不再编译规则。这条路径是“交付预编译数据库”的用法，
  加载成本与编译成本被分离。

两条命令都固定 `-N`（block 模式）与 `-n 1`（每次测量扫一遍语料），只改变“规则如何
就绪”，因此两个场景的 Mean throughput 差值直接反映**规则编译/字节码加载开销**对该规则集
的影响；同时 `-U` 的场景还验证了 fat 字节码生成与加载链路在目标架构上可用。

## 容器化执行

本用例的解包、构建、版本自证、字节码生成、扫描负载与计时全部在每次任务专属的
**openEuler 24.03 LTS SP4 私有容器**内完成。宿主机只需要 Docker、下载/校验工具与
Framework，不安装编译器、CMake、Ragel 或任何 dnf 包；仅当离线源码归档缺失时，宿主
额外需要 `git` 做 clone 回退（见下文）。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构（`x86_64:amd64` / `aarch64:arm64`）与镜像内 `/etc/os-release`
  的 24.03 版本。
- 容器：名字 `boostkit-ultrascan-<arch>-<运行ID>`，标签
  `boostkit.ultrascan.run-id=<运行ID>`，使用宿主网络，以 Runner 用户身份运行；只读挂载
  用例目录，读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，容器内路径与宿主完全相同。
- 容器内：`dnf` 安装 `cmake`、`make`、`gcc`、`gcc-c++`、`ragel`、`python3`、
  `boost-devel`、`sqlite-devel`、`pkgconf-pkg-config`、`unzip`、`tar`、`curl`、
  `coreutils`、`diffutils`、`findutils`、`time`、`glibc-devel`、`glibc-common`、
  `binutils`、`which`、`gzip`、`util-linux` 等构建依赖（关闭弱依赖，避免 rpm scriptlet
  触碰只读的 `/etc/passwd`、`/etc/group`）。`util-linux` 提供 `rev`：上游
  `cmake/build_wrapper.sh` 用它定位编译产物，缺失会导致 fat-runtime 符号链接失败。
  容器内不需要 `git`（源码归档由宿主机校验后复制进来），因此不会引入无法在无 systemd
  容器中完成的 scriptlet。
- 容器内还执行：源码解包、`HS_*_VERSION` 版本自证、`hsbench`（Release）与 `hsdump`
  （Debug，`DUMP_SUPPORT`）构建、`hsdump -N -U` 生成 `dump/db.raw` 并记录其 SHA-256、
  两个场景的计时驱动（每条样本用容器内 GNU `/usr/bin/time` 记录墙钟与峰值 RSS）、以及
  测量输入的产物/语料校验。`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 宿主机：只负责下载并校验 `hsbench-samples.zip`（离线目录优先）、把校验通过的样本包与
  源码归档放进 `${PERF_WORK_DIR}`、执行严格解析（`parse_benchmark.py report` 与
  `standalone_runtime.py` 不进入容器）以及清理本任务的容器。离线源码归档缺失时，宿主
  回退到 `git clone --depth 1 --branch Ultrascan-v5.8.0`（gitcode，失败再试 gitee），
  并强制校验 `HEAD == 2a2ab98…`；只有校验通过的源码树才会交给容器构建（容器内不装
  `git`，解包/构建仍全部在容器内完成）。
- 测量：每条样本由容器内进程直接派生（`ultrascan_container_exec_at
  "${PERF_WORK_DIR}" ...`），`docker exec` 的管理开销不落在计时窗口内；容器只产出原始
  日志与计时工件，全部数值校验、一致性检查与指标汇总都在宿主机完成，容器无法自证通过。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符时拒绝删除并返回 60）；取消任务遗留的
  同软件容器会在下一次 build 时按名字前缀 + 运行 ID 清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 固定流程

1. **宿主下载与校验**：在宿主机获取 `hsbench-samples.zip`（离线目录优先，其次
   `cdrdv2.intel.com`），校验 zip 的 SHA-256；同时准备已验证提交的源码归档。
2. **容器解包与成员校验**：在容器内解包 zip，校验 `pcre/snort_literals` 与
   `corpora/gutenberg.db` 的 SHA-256，落位到 `${PERF_WORK_DIR}/hsbench-samples`；成员路径与
   校验值写入 `build-state.json` 的 `samples`。
3. **Release 构建 hsbench**：容器内 `cmake -DCMAKE_BUILD_TYPE=Release` 配置后
   `cmake --build . --target hsbench`，产出 `build/bin/hsbench`，并执行一次冒烟扫描，
   从输出解析 `Hyperscan info: Version: 5.8.0` 自证实际版本。
4. **Debug 构建 hsdump**：容器内另建 Debug 构建目录（`DUMP_SUPPORT` 只在 Debug 打开），
   `--target hsdump` 产出 `build-debug/bin/hsdump`。
5. **生成通用字节码**：容器内对 `snort_literals` 执行 `hsdump -N -U`，把 fat 字节码写入
   `${PERF_WORK_DIR}/dump_output/dump/db.raw`，记录该文件 SHA-256，并验证 `hsbench -U`
   能加载它；该 SHA-256 写入 `build-state.json` 的 `universal_bytecode`。
6. **测量**：两个场景各 `PERF_ULTRASCAN_WARMUPS` 次预热 + `PERF_REPS` 次独立测量，
   `-N -n 1`，每条样本把原始 stdout 与 GNU time 计时工件写到
   `${RESULTS_DIR}/runs/<scenario>/`（`warmup1..` 与 `rep1..` 日志 + 同名 `.json`）。
7. **宿主严格解析**：`parse_benchmark.py report` 逐样本校验 hsbench 退出码、版本、模式、
   语料大小、匹配数一致性与吞吐为正，直接产出 `results.json`；
   `standalone_runtime.py` 再校验“恰好两条指标、`samples` 与 `sample_values` 数量一致、
   `value` 等于样本中位数”，并补入 `status`/`build_info`/环境快照，产出最终
   `results.json`、`report.md` 与 `status.json`。

## 结果与指标

最终 `results.json` 的 `results` 恰好包含两条指标，数值为 `PERF_REPS` 次独立测量的
**中位数**：

| 指标 | 原始字段 | 单位 | 优化方向 | 分组 |
|---|---|---|---|---|
| `hsbench_rules_block_mean_throughput_mbit_s` | `Mean throughput (overall)`（无通用字节码） | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_ubc_block_mean_throughput_mbit_s` | `Mean throughput (overall)`（加载通用字节码） | Mbit/s | 越大越好 | `hsbench` |

结果目录（`RESULTS_DIR`）结构分两种运行方式。**Framework / Actions 方式**由框架执行
finalize 与任务级报告，**独立运行方式**（`ultrascan_test.sh`）不经过框架、由
`standalone_runtime.py` 自己产出状态与报告：

```text
# 两种方式都有（case 的解析器/构建脚本写出）
benchmark_hsbench.txt         # 两个场景全部原始 hsbench 输出（含实际命令行）
results.json                  # 最终结果：results / benchmark / toolchain / architecture / run_id
runs/<scenario>/warmup<i>.log    # 第 i 次预热原始输出
runs/<scenario>/warmup<i>.json   # 该次运行的 command / exit_code / timed_out /
                                 #   wall_seconds / max_rss_kib
runs/<scenario>/rep<i>.log       # 第 i 次独立测量原始输出
runs/<scenario>/rep<i>.json      # 同上，逐次计时结果
build_variant.json            # build 阶段变体（case 的 dispatch.sh 写出，两种方式都有）
system_info.json              # CPU / OS / glibc 等环境信息（Framework 写；独立入口自己写）
runtime_before.json           # 运行前环境快照（同上）
runtime_after.json            # 运行后环境快照（同上）
status.json                   # 运行状态（Framework 的任务级状态；独立入口写自己的字段）
report.md                     # 任务报告（CI 由平台汇总报告生成；独立入口写两指标报告）

# 仅 Framework 方式（框架写出）
raw-output.log                # test 阶段 stdout（结果摘要与指标行）
build_info.json               # 框架格式的 7 个键：recorded_at + 类别/软件/请求版本/实际版本/架构/run-id

# 仅独立运行方式（standalone_runtime.py 额外产出）
build_info.json（详细版）      # 覆盖为源码 commit、样本与 db.raw 的 SHA-256、hsbench/hsdump 构建、编译器
```

Framework 方式下 `results.json` 不含 case 级 `build_info`/`status` 键，详细 `build_info.json`
也不发布；上游 commit、样本与 `db.raw` 的 SHA-256 记录在 `build-state.json`
（`${PERF_WORK_DIR}` 内）和构建日志里，不随 CI 产物发布。

`results.json` 的顶层键与每条指标的形态（`key == source_name`，`value` 为中位数）：

```json
{
  "software": "ultrascan",
  "version": "5.8.0",
  "variant": "base",
  "architecture": "aarch64",
  "run_id": "…",
  "generated_at": "…Z",
  "toolchain": {"compiler": "c++ (GCC) 12.3.1 …"},
  "benchmark": {
    "workload": "upstream hsbench block-mode scan of pcre/snort_literals over corpora/gutenberg.db (Mean throughput)",
    "iterations": 1,
    "warmups": 1,
    "measure_reps": 5,
    "samples_package": {"rules": "pcre/snort_literals", "corpus": "corpora/gutenberg.db"},
    "scenarios": ["hsbench_rules_block", "hsbench_ubc_block"]
  },
  "results": {
    "hsbench_rules_block_mean_throughput_mbit_s": {
      "source_name": "hsbench_rules_block_mean_throughput_mbit_s",
      "source_benchmark": "without universal bytecode (-e pcre/snort_literals)",
      "source_field": "Mean throughput (overall)",
      "value": 4321.5,
      "unit": "Mbit/s",
      "direction": "higher_is_better",
      "group": "hsbench",
      "samples": 5,
      "sample_values": [4290.1, 4330.7, 4318.9, 4350.2, 4309.6],
      "sample_summary": {"median": 4321.5, "mean": 4320.3, "min": 4290.1, "max": 4350.2},
      "wall_seconds_sample_values": [0.51, 0.50, 0.52, 0.50, 0.51],
      "max_rss_kib_sample_values": [10240, 10304, 10288, 10256, 10272]
    },
    "hsbench_ubc_block_mean_throughput_mbit_s": { "…": "同上，source_benchmark 为 with universal bytecode (-U dump/db.raw)" }
  },
  "runs_dir": "runs"
}
```

解析器严格校验：样本缺失、runs 目录出现声明之外的多余样本文件、hsbench 非零退出、
数值非有限或非正、版本/模式与请求不符、同一场景多次测量的语料大小或匹配数不一致、
指标条目不恰好为两条、`sample_values` 数量与 `samples` 不一致、`value` 不等于样本中位数时，
测试阶段或结果汇总直接失败（退出 50/70），不补零、不吞错。除上表两个 Mean throughput
指标外，本用例不产出任何其他指标。

## 运行方式

**Framework 方式**（CI / Actions）：Framework 依据 `case.yaml` 调用
`scripts/builders/dispatch.sh` 构建，再调用 `scripts/stages/` 的 `start`、`test`、`stop`
阶段，最后 `finalize` 校验 `results.json`。Actions 按 `architecture` 输入派发，**本用例
aarch64 与 x86_64 都跑**：aarch64 是鲲鹏正式口径，x86_64 需要
`scripts/x86_build_fix.py` 的可移植性修复，用于跨架构对照，两者绝对值不可直接比较。

**独立方式**：

```bash
# 默认 5 次独立测量；冒烟可用 PERF_REPS=1
PERF_REPS=1 bash software/Acceleration/ultrascan/ultrascan_test.sh \
  --version 5.8.0 --results-dir /root/ultrascan-results
```

独立入口不经过 Framework，会自己生成 `results.json`、`benchmark_hsbench.txt`、`runs/**`、
`build_variant.json`、`system_info.json`、`runtime_before/after.json`、`status.json`、
`report.md` 与详细版 `build_info.json`，并在成功/失败后清理自己创建的
`/home/runner/boostkit-perf/ultrascan/local-*` 工作目录（`--keep-workdir` 可保留）。

环境变量：

| 变量 | 默认 | 说明 |
|---|---|---|
| `PERF_REPS` | `5` | 每个场景的独立测量次数（中位数口径） |
| `PERF_ULTRASCAN_WARMUPS` | `1` | 每个场景的预热次数 |
| `PERF_ULTRASCAN_BUILD_JOBS` | `nproc`（上限 16） | 容器内 `cmake --build` 并行度 |
| `PERF_ULTRASCAN_OFFLINE_DIR` | `/home/runner/software/ultrascan` | 离线源码归档与样本包目录 |
| `PERF_ULTRASCAN_GIT_URL(S)` | gitcode / gitee | 源码归档缺失时的克隆回退 |
| `PERF_REPS` 为 1 时 | — | 仅用于链路冒烟，不作为性能证据；正式证据要求 ≥ 5（解析器不强制次数，CI 默认 5） |

退出码：

| 退出码 | 含义 |
|---|---|
| `0` | 全部阶段成功，结果校验通过 |
| `10` | 命令行参数非法 |
| `20` | 架构/环境不符合要求，或构建目录不干净 |
| `30` | 下载、校验或构建失败（含容器依赖安装失败） |
| `40` | 运行前检查失败（hsbench/hsdump/db.raw/语料缺失或容器不可用） |
| `50` | 测量或严格解析失败 |
| `60` | 容器或工作目录清理失败 |
| `70` | 结果汇总/报告校验失败（指标条数、样本数、中位数或 build_info 不满足契约） |

## 已知限制

1. **单线程、单规则集、单语料**：只测 `snort_literals` + `gutenberg.db`，`-n 1`，不带
   `-T` 线程亲和；结论不能外推到其他规则集或语料。
2. **aarch64 是正式口径**：Ultrascan 官方只验证鲲鹏 920 + openEuler；x86_64 依赖构建修复
   才能编译，Actions 会同时跑两种架构，但跨架构绝对值不可直接比较（x86_64 用于对照，
   不代表鲲鹏优化效果）。
3. **`-n 1` 固定**：每次测量只扫一遍语料，单次扫描时间短，计时噪声相对更大；中位数与
   多次独立测量是主要噪声控制手段。
4. **`gutenberg.db` 只有约 7 MB**：语料小，绝对吞吐数值（Mbit/s）相对真实流量场景偏低，
   应只用于同一机器上的版本间/路径间对比。
5. **两种模式的绝对数值不可直接互换**：`-U` 场景跳过了规则编译，吞吐通常更高；两者
   差值反映编译开销，而不是同一条路径的优化幅度。
6. **Intel 样本可获得性**：`cdrdv2.intel.com` 在专用 Runner 上可能不可达；本用例不提供
   替代输入，样本包不可获取时直接构建失败（退出 30），避免用不可比数据出结论。
7. **构建机相关的指令调优**：上游 aarch64 Release 构建默认带 `-march=native`（single-ISA
   构建），`hsbench` 会按构建机 CPU 调优（本次为 Kunpeng 950）；跨机型对比必须在同一机型
   上重跑，不能直接横向比较绝对值。

## 故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| build 退出 30，`hsbench-samples.zip` 下载失败 | 专用 Runner 无法访问 `cdrdv2.intel.com` | 把样本包放到 `PERF_ULTRASCAN_OFFLINE_DIR`，或配置 `PERF_PROXY` |
| build 退出 30，成员 SHA-256 不匹配 | 样本包被截断/被替换 | 删除缓存重新获取，核对 zip 与两个成员 SHA-256 |
| build 退出 30，`ragel` 相关 CMake 报错 | 容器内缺少 `ragel` | 检查 `ULTRASCAN_BUILD_PACKAGES` 与 dnf 是否成功 |
| build 退出 30，`hsdump` 不存在 | Debug 构建目录未生成或未带 `DUMP_SUPPORT` | 检查 `--target hsdump` 与 Debug 构建目标 |
| start 退出 40，`db.raw` 缺失 | `hsdump -N -U` 失败 | 看 `runs/`/构建日志中 hsdump 的输出 |
| test 退出 50，`Mean throughput (overall)` 缺失 | hsbench 输出格式变化或 hsbench 非零退出 | 看 `runs/<scenario>/rep<i>.log` 尾部诊断 |
| test 退出 50，语料大小/匹配数不一致 | 语料或规则集被改动 | 重新校验样本 SHA-256，确认没有并发写入 |
| 结果 70，指标不是两条 | `results.json` 的场景/指标不满足契约 | 确认只有 `hsbench_rules_block` 与 `hsbench_ubc_block` 两个场景 |

## 许可证

- Ultrascan 继承上游 Intel Hyperscan 的 **BSD-3-Clause** 许可证，仓库内
  `LICENSE` 文件为准；本用例只构建与调用其公开接口，不修改上游代码（x86_64 的
  构建图修复只作用于本次任务的私有源码副本）。
- Intel Hyperscan hsbench-samples 样本包由 Intel 官方发布，仅用于基准测试；使用时
  遵循样本包随附说明。
