# cmake

CMake 4.4.5 构建工具性能用例。完整口径为**系统化 configure/build 矩阵 + 上游 CMake 源码工程负载**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **4.4.5** |
| 上游标签 | `Kitware/CMake` `v4.4.5`（2026-10-27 发布） |
| x86_64 官方二进制 | `cmake-4.4.5-linux-x86_64.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5-linux-x86_64.tar.gz`<br>SHA-256 `ed85135c5a5135b45e50423cb406dea04ca3338da0b8ef3c9ede963559680be0` |
| aarch64 官方二进制 | `cmake-4.4.5-linux-aarch64.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5-linux-aarch64.tar.gz`<br>SHA-256 `301d5063ab259577c1b57ce5490b1aab9ea5c56dc4c822f73499553dab94925f` |
| 源码制品（上游工程负载） | `cmake-4.4.5.tar.gz`<br>`https://github.com/Kitware/CMake/releases/download/v4.4.5/cmake-4.4.5.tar.gz`<br>SHA-256 `a0c54c88abb8078dd8eccadb717fc6bb194bf18e7d44c86309910288886e04e2` |
| 官方校验清单 | `cmake-4.4.5-SHA-256.txt`（SHA-256 `f502d7058129606f8e468d2373178a5b48eb2c5f9785641b706f45952956dd25`，列出上述两个二进制归档的校验值） |
| C 编译器 | Runner 系统 `cc`（版本未固定，逐次运行写入 `build_info.json` 与 `results.json`） |

两个架构使用**各自架构的官方二进制归档**（不做源码自举），被测能力是 configure/build，不是编译 CMake 本身。所有归档在解包前强制核对 SHA-256：不匹配、下载失败、解包失败一律 `build` 失败（返回非零），不降级、不跳过。源码归档的 SHA-256 取自 GitHub release 资产元数据（官方 `SHA-256.txt` 不包含源码归档），已在取得归档时本地复核。

离线包约定：把下列文件预置到 `/home/runner/software/cmake/` 时优先使用并强制校验，缺失才联网下载：

```text
cmake-4.4.5-linux-x86_64.tar.gz
cmake-4.4.5-linux-aarch64.tar.gz
cmake-4.4.5.tar.gz
cmake-4.4.5-SHA-256.txt          # 可选，仅作审计参考
```

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验系统依赖（`curl`、`tar`、`gzip`、`sha256sum`、`gawk`、`make`、`cc`、`python3`）；Runner 通过 `sudo -n dnf` 补齐缺失包，代理来自 `PERF_PROXY`。
2. 取本架构官方二进制归档，核对 SHA-256 后解包到 `$PERF_WORK_DIR/cmake-install`；`cmake --version` 解析出的版本必须是 `4.4.5`，否则 `build` 失败（框架据 `actual-version.txt` 强制校验）。
3. 取官方源码归档并解包到 `$PERF_WORK_DIR/cmake-source`，作为上游工程负载。
4. 用语例自带的 `scripts/generate_project.py` 确定性生成 100 / 1,000 / 10,000 源文件的 C 工程到 `$PERF_WORK_DIR/projects/`。
5. 冒烟校验：以固定参数 configure 并完整构建 100 源文件工程，确认工具链在进入测量阶段前可用（不计入测量）。
6. 退出前写出 `build_variant.json`。

**测量阶段不需要网络**：CMake 本身不联网，工程由用例生成，上游源码来自 build 阶段归档，`upstream_build` 首次完整构建也只在测量基线准备时进行，不下载任何依赖。

## 3. 完整测试口径

### 3.1 为什么不用 CTest 套件

CMake 没有上游性能基准套件。CTest/`cmake` 自身的 `Tests/` 是**正确性测试**（数千个通过/失败用例、以覆盖功能为目标、按 CMake 版本耦合，单例耗时毫秒级到秒级不等且大量依赖外部工具），把它当性能口径会产生不可复现、不可解释的数字；因此本用例不采用 CTest 作为计时负载，改用可字节级复现的**系统化矩阵 + 上游工程负载**。

### 3.2 矩阵

每个场景 **1 次预热 + 5 次独立正式测量**，报中位数，同时保留每次样本、最小值、最大值、均值、标准差。

| 场景 | 任务 | 规模 | 说明 |
|---|---|---|---|
| `configure_100` | `configure` | 100 源文件 | 空构建目录的首次配置 |
| `clean_build_100` | `clean build` | 100 源文件 | `--target clean` 后完整构建 |
| `incremental_build_100` | `incremental build` | 100 源文件 | 改 1 个源文件后构建 |
| `noop_build_100` | `no-op build` | 100 源文件 | 无任何改动后构建 |
| `configure_1000` | `configure` | 1,000 源文件 | 空构建目录的首次配置 |
| `clean_build_1000` | `clean build` | 1,000 源文件 | `--target clean` 后完整构建 |
| `incremental_build_1000` | `incremental build` | 1,000 源文件 | 改 1 个源文件后构建 |
| `noop_build_1000` | `no-op build` | 1,000 源文件 | 无任何改动后构建 |
| `configure_10000` | `configure` | 10,000 源文件 | 空构建目录的首次配置 |
| `clean_build_10000` | `clean build` | 10,000 源文件 | `--target clean` 后完整构建 |
| `incremental_build_10000` | `incremental build` | 10,000 源文件 | 改 1 个源文件后构建 |
| `noop_build_10000` | `no-op build` | 10,000 源文件 | 无任何改动后构建 |
| `upstream_configure` | `configure` | 上游 CMake 4.4.5 源码树 | 空构建目录的首次配置（真实大型工程） |
| `upstream_build` | `clean build` | 上游 CMake 4.4.5 源码树 | `--target clean` 后构建 `cmake` 目标 |
| `upstream_incremental_build` | `incremental build` | 上游 CMake 4.4.5 源码树 | 改 1 个叶子源文件后构建 `cmake` 目标 |
| `upstream_noop_build` | `no-op build` | 上游 CMake 4.4.5 源码树 | 无改动构建 `cmake` 目标 |

共 16 个场景 × 2 项指标 = 32 个指标。

生成工程为确定性单可执行目标：`CMakeLists.txt` 显式列出全部 `src/unit_XXXXX.c` 加 `main.c`，每个翻译单元只含一个常量算术函数，`main` 调用全部函数并打印结果。显式源列表让 `configure` 的耗时集中在 CMake 自身的 CMakeLists 解析、目标建模与 Makefile 生成上（而不是遍历文件系统）；输入完全可复现。

### 3.3 固定条件

- 构建并行度**固定 `-j8`**（`cmake --build <dir> -j 8`），两个架构一致；不使用 `$(nproc)`，避免把机器核数混入指标。Runner 核数 ≥ 8 时该并行度可被完整调度。
- 构建类型 `Release`，编译选项固定 `-O2 -DNDEBUG`（生成工程与上游工程一致）。
- 构建工具为 CMake 默认的 **Unix Makefiles**；不额外安装 Ninja，避免把生成器差异引入结果。该生成器为每个源文件生成独立规则，10,000 源文件时 `build.make` 约 14 MB，`make` 每次调用都要解析它，因此 10,000 规模的 `incremental_build` / `noop_build` 会稳定地包含约 15 s 的 make 解析时间（本机对照：同工程 Ninja 生成器 no-op 约 0.07 s）。这是 CMake 默认 Makefile 生成器在超大单目标下的真实行为，属被测口径的一部分，不人为规避；README 第 4 节与报告同时标注。
- `configure` 场景每次都在**全新的空目录**中进行，测量的是"首次配置"；`clean_build` 场景在已配置目录上 `--target clean` 后构建（不重复计入 configure）；`incremental_build` 每次只改 `src/unit_00001.c` 一个文件（上游场景只改 `Source/cmWorkingDirectory.cxx` 一个叶子文件）；`noop_build` 不做任何改动。
- 上游工程固定 `--target cmake`，并配置 `-DBUILD_TESTING=OFF -DCMAKE_USE_OPENSSL=OFF`，使构建工作量只依赖固定源码归档，不引入系统 OpenSSL 版本差异。
- 测量阶段不联网、不设 `MAKEFLAGS`、不注入编译器缓存（`ccache` 等）。
- 指标统计为 5 次独立测量的**中位数**；原始样本与完整 stdout+stderr 全部保留。

### 3.4 单架构耗时

本机 x86_64（WSL2，20 逻辑核，`-j8`、`PERF_REPS=5`、离线包已预置）六阶段实测：`build` 约 3 s，`test` 约 **22.5 分钟**，六阶段合计 **22.6 分钟**。其中中位数：`configure` 1000/10000 为 0.21 s / 1.02 s，`clean_build_10000` 为 31.6 s，`upstream_configure` 为 17.0 s，`upstream_build` 为 97.1 s，`upstream_incremental_build` 为 1.32 s，`upstream_noop_build` 为 0.26 s。aarch64 专用 Runner 预计 30–45 分钟，低于单架构 60 分钟上限。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好 | `scripts/run_timed.py` 测得的单次 `cmake` 子进程墙钟，取 5 次中位数 |
| `<场景>_rss` | `MiB` | 越低越好 | 同一子进程树（cmake → make → cc）的 `ru_maxrss`，取 5 次中位数 |

全部 32 个指标由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合；任一场景缺样本、`exit_code != 0`、超时、数值非有限或非正、原始日志缺失即解析失败，`test` 阶段返回非零，**不补零、不估算**。

注意：`clean_build` / `incremental_build` / `noop_build` 的墙钟包含 Runner 系统 C 编译器的编译时间（尤其 10,000 规模的全量构建），`configure` 场景才是纯 CMake 能力指标；跨架构对比时墙钟同时受各架构编译器与单核性能影响，报告只按同名场景配对，不把不同负载直接排序。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 运行 → 解析 → 报告），产出**不是**性能结论。
- 脚本保持架构无关：只用 `uname -m` 选择官方二进制归档，不使用任何架构专用编译选项；两个架构使用同一份生成器、同一套固定参数与同一并行度。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: cmake
version: 4.4.5
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_WORK_DIR=$HOME/cmake-work        # 可选；默认 /home/runner/boostkit-perf
export PERF_REPS=5                          # 默认 5；本机链路验证可临时降低并记录
bash software/Toolchain/cmake/cmake_test.sh \
  --version 4.4.5 --variant base --results-dir "$HOME/cmake-results"
```

`optimized` 变体尚未实现：`cmake_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base，也不写 `build_variant.json`。

可选环境变量：

| 变量 | 作用 |
|---|---|
| `PERF_REPS` | 每个场景的独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |
| `PERF_CMAKE_JOBS` | 固定构建并行度，默认 8；正式证据要求与默认值一致 |
| `PERF_CMAKE_OFFLINE_DIR` | 覆盖离线包目录，默认 `/home/runner/software/cmake` |
| `PERF_CMAKE_MIRROR` | GitHub 下载 URL 的前缀镜像（如受限网络下的 release 代理）；不设置时只用官方地址 |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`results.log`、`runs/`（每场景预热 + 5 次测量的完整原始日志与计时 JSON）。框架六阶段运行时另有 `raw-output.log`（`test` 阶段完整控制台输出）。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 CMake 负载是"固定 100 个 C 文件工程 configure/clean build/no-op，`-j1`，3 次样本"，属于**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"，其 111 实测值不迁移进仓库、不作为性能结论。本用例把它作为矩阵的一个子集（`configure_100` / `clean_build_100` / `noop_build_100`）保留，但真正的性能证据是包含 1k/10k 规模、增量构建、上游 CMake 源码工程、固定 `-j8` 且每场景 5 次中位数的完整口径。

## 8. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 SHA-256 不匹配 | 检查 `/home/runner/software/cmake/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `build` 报 `cmake --version` 不是 4.4.5 | 预置包版本错误，或 `$PERF_WORK_DIR/cmake-install` 残留旧解包；清理该目录重试 |
| `build` 报下载失败 | GitHub release 不可达时设置 `PERF_CMAKE_MIRROR`，或预置离线包；日志会打印尝试过的每个 URL |
| `test` 报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`/`rep*.log`；失败的那次测量会保留原始日志 |
| `clean_build_10000` 很慢 | 10,000 个翻译单元的全量编译加链接本身约占该场景绝大部分墙钟，属正常；检查磁盘与内存余量 |
| `upstream_build` 很慢 | 上游 CMake 源码首次完整构建 `cmake` 目标需要数分钟（`-j8` 下本机约 2 分钟），属正常；它只作为基线构建一次，不再重复 |
| 测量阶段出现网络访问 | 不应发生；检查是否人为设置了 `MAKEFLAGS`/编译器封装脚本 |

## 9. 许可证

CMake 采用 BSD 3-Clause License（Kitware）。本用例自带的工程生成器、计时与解析/报告脚本为本仓库原创，遵循仓库既有许可。
