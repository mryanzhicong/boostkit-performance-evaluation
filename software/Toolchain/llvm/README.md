# LLVM 23.1.4 opt/llc IR 流水线性能用例（Toolchain）

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成。宿主机只需要 Docker、下载/校验工具与 Framework，不再安装 gcc、cmake、ninja 或
python3。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-llvm-<arch>-<运行ID>`，标签 `boostkit.llvm.run-id=<运行ID>`，使用
  宿主网络，以 Runner 用户身份运行；只读挂载用例目录，读写挂载 `${PERF_WORK_DIR}` 与
  `${RESULTS_DIR}`，容器内路径与宿主完全相同。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`cmake`、`ninja-build`、`make`、`python3` 等构建
  依赖（cmake 必须 >= 3.20 并在容器内校验）；`llvm-project-23.1.4.tar.gz`（约 2 GB 解包）
  的解包、cmake 配置、`opt`/`llc` 编译、IR 语料生成、`opt`/`llc` 版本探测与 9 个场景的计时
  包装（`scripts/run_timed.py`）都在容器内执行，`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 宿主机：只负责下载并校验 `llvm-project-23.1.4.tar.gz`（优先
  `/home/runner/software/llvm/`）、写 `build_variant.json`/`actual-version.txt` 与严格解析
  `results.json`；结果解析器不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口；测量期把
  代理指向 `127.0.0.1:9` 证明 opt/llc 全程离线。
- 构建耗时：从源码编译 `opt`、`llc` 是重型构建（默认 `PERF_BUILD_JOBS=6`），`case.yaml`
  的 `timeout_minutes` 因此从 240 提高到 **360**；本地验证可用
  `PERF_LLVM_REUSE_BUILD_DIR` 复用同口径的既有构建树以缩短链路验证时间，CI 不设置该变量，
  始终做完整源码构建。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器会在
  下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件 | LLVM（只使用 `opt` 与 `llc` 两个工具） |
| 版本 | `23.1.4`（tag `llvmorg-23.1.4`） |
| 制品 | `llvm-project-23.1.4.tar.gz`（GitHub `llvm/llvm-project` tag 源码包，codeload 生成） |
| 制品 SHA-256 | `3e1c70b30f623976c2046d94b8eeab6cac536f107914cb4ed7bac572a03131db` |
| 构建目标 | `opt`、`llc`（Release 构建，只保留本机架构后端：x86_64 → `X86`，aarch64 → `AArch64`） |
| 分类 | Toolchain |

**为什么从源码构建而不是用官方预编译包**：`llvmorg-23.1.4` 的 Linux 预编译
制品是 1.1–2.0 GB 的 `.tar.zst`/`.tar.xz`，且上游 release 没有发布对应的
SHA-256 校验文件（`*.tar.xz.sha256` 返回 404），无法按仓库规范做固定校验；
源码包 277 MB、内容由 tag 确定，下载后在 build 阶段计算并固定 SHA-256，构建
结果由 `opt --version` 强校验。因此本用例选择源码构建路径。已知代价：构建
`opt`/`llc` 是长耗时步骤（本机 6 并发实测约 20 分钟），也是 240 分钟超时的主要
风险点；如果 aarch64 Runner 构建超时，如实记录为该环境限制，不做"跳过构建"的
降级。

**与 Clang 用例的关系**：仓库已排除 Clang 编译性能用例，本用例**不**编译任何
C/C++ 源码、不测量 clang 前端，只测量 `opt` 的新 PM 优化流水线与 `llc` 的代码
生成，两者口径不重叠。

## 2. 构建与安装

build 阶段（在私有工作目录内完成，不污染系统）：

1. 依赖自检：`curl tar python3 sha256sum awk cc g++ cmake make`，`dnf`/`apt-get`
   双分支安装（`g++`→`gcc-c++`/`g++`，`make`→`make`），装后再 `command -v` 自检；
   `cmake` 版本必须 ≥ 3.20（LLVM 23 要求）。
2. 取源码包：离线目录（`PERF_LLVM_OFFLINE_DIR`，默认
   `/home/runner/software/llvm/`）→ `ghfast.top` → 官方 codeload，每源校验同一
   SHA-256；解包约 2 GB。
3. CMake 配置：`-G Ninja`（无 ninja 时退回 Unix Makefiles）、`Release`、
   `LLVM_TARGETS_TO_BUILD=<本机架构>`、关闭 tests/benchmarks/examples/docs/
   bindings/terminfo/zlib/zstd/libxml2/libedit/curl/httplib/utils。
4. `cmake --build --target opt llc -j <PERF_BUILD_JOBS|6>`。
5. `opt --version` 解析实际版本写入 `PERF_ACTUAL_VERSION_FILE`（`23.1.4`），
   与请求版本不一致返回 40（框架记为 build 30）。
6. `scripts/generate_ir.py` 生成固定 IR 语料：`arith.ll`/`mem.ll`/`branch.ll`，
   每个模块 200 个函数、使用不透明指针 `ptr` 语法（LLVM 23 唯一支持形式），
   不写 target triple/datalayout，`llc` 使用构建时的本机 triple。
7. 写 `build_variant.json`。

本地联调时可用 `PERF_LLVM_REUSE_BUILD_DIR=<已有 build 目录>` 跳过下载与编译，
直接复用 `bin/opt`、`bin/llc`（该变量**仅**用于本地链路验证，CI 中必须留空）。

## 3. 完整测试口径

`opt`/`llc` 固定 IR pipeline：同一批 `.ll` 输入，按固定的优化级别与 pass 组合
各跑一遍。每个场景 1 次预热 + `PERF_REPS` 次独立测量（正式证据要求 `>=5`，
默认 5），每次写 `runs/<scenario>/{warmup,rep<i>}.{log,json}`。

| 场景 | 命令 | 说明 |
|---|---|---|
| `opt_o0_arith` | `opt -O0 -S arith.ll -o out.opt.ll` | 无优化基线 |
| `opt_o2_arith` | `opt -O2 -S ...` | 默认 O2 流水线 |
| `opt_o3_arith` | `opt -O3 -S ...` | 默认 O3 流水线 |
| `opt_multi_pass_arith` | `opt -passes='default<O2>,loop-vectorize,instcombine,gvn,simplifycfg' -S ...` | 多 pass 组合 |
| `opt_o2_mem` | `opt -O2 -S mem.ll ...` | 内存/别名形态模块 |
| `opt_o2_branch` | `opt -O2 -S branch.ll ...` | 分支/switch 形态模块 |
| `llc_o0_arith` | `llc -O0 arith.ll -o out.s` | 代码生成无优化 |
| `llc_o2_arith` | `llc -O2 arith.ll -o out.s` | 代码生成 O2 |
| `pipeline_o2_arith` | `opt -O2 -S` 后紧接 `llc -O2`（同一被测子进程内） | 端到端流水线 |

严格性：每个 rep 结束后检查输出文件非空（缺失按 50 处理）；解析器要求
`rep1..repN.json` 全部存在、退出码 0、墙钟与 RSS 为有限正数，否则 50。

## 4. 指标

9 场景 × 2 指标 = 18，外加 9 个吞吐指标（200 个函数 / 墙钟），共 **27 个指标**：

| 指标 | 单位 | 方向 |
|---|---|---|
| `<scenario>__wall_seconds` | s | lower_is_better |
| `<scenario>__peak_rss_mib` | MiB | lower_is_better |
| `<scenario>__functions_per_second` | functions/s | higher_is_better |

每个指标带 `median`/`mean`/`min`/`max`/`stdev` 与全部样本。RSS 是单次
`opt`/`llc` 进程的峰值（pipeline 场景为 shell 包装进程等待子进程后的
`ru_maxrss` 峰值近似）。

## 5. 架构与证据边界

- 两架构使用同一份源码包、同一套 IR 语料与同一套构建参数；唯一差异是
  `LLVM_TARGETS_TO_BUILD` 选择本机后端（否则每次构建要双后端，时间翻倍）。
  因此跨架构比较的是"本机后端上的 opt/llc 耗时"，不是同一后端产物。
- 版本对比时 `opt --version` 必须等于请求版本，否则 build 失败，不会静默降级。
- 本地 WSL `x86_64` 只做链路验证；正式性能数据必须来自专用 `aarch64` Runner。
- 构建耗时长：本机 6 并发实测构建阶段约 20 分钟（含解包与 CMake 配置）；
  aarch64 Runner 若核数更少，构建可能接近或超过 240 分钟超时，这属于环境限制，
  结果需如实标注。
- 绝对墙钟受 CPU 频率、内存带宽与 `-j` 并发影响；本用例构建与测量串行执行，
  同一 Runner 上重复运行才有可比性。
- 未覆盖：clang 前端编译、lld 链接、LLVM 自带 `test-suite`/`llvm-test-suite`、
  其他 pass 组合、LTO/ThinLTO、其他目标后端（ARM/WebAssembly 等）。

## 6. 运行方式

```bash
python3 framework/run_case.py \
  --case software/Toolchain/llvm/case.yaml \
  --version 23.1.4 --architecture x86_64 \
  --run-id local-llvm-1 --stage build        # 源码构建 opt/llc，耗时较长
PERF_REPS=5 python3 framework/run_case.py ... --stage test

# 独立入口
software/Toolchain/llvm/llvm_test.sh --version 23.1.4 --results-dir /tmp/llvm-results

# 本地联调：复用已有 LLVM build 目录，跳过下载/编译
PERF_LLVM_REUSE_BUILD_DIR=/root/llvm-work/build \
  software/Toolchain/llvm/llvm_test.sh --results-dir /tmp/llvm-results

# 负向：未实现的优化变体
PERF_VARIANT=optimized python3 framework/run_case.py ... --stage build   # 期望 30
```

## 7. 故障排查

| 现象 | 原因 / 处理 |
|---|---|
| build 30，`every download source failed` | 所有源失败；日志逐条打印离线目录与 URL，把固定 SHA 源码包放到离线目录 |
| build 30，`sha256 mismatch` | 下载的不是 `llvmorg-23.1.4` tag 包，删除后重下 |
| build 30，`requires cmake >= 3.20` | 系统 cmake 过旧；安装新版 cmake（Runner 上可用 `PERF_CMAKE_BIN` 指定） |
| build 30，`extracted archive has no llvm/` | 源码包不完整或被截断 |
| build 40 → 框架 30，`LLVM build of opt/llc failed` | 编译器/内存不足；查看阶段日志（作业会用完整日志） |
| build 40 → 框架 30，`requested LLVM ... but built ...` | 源码包 tag 与版本不符 |
| test 50，`did not produce a non-empty output` | `opt`/`llc` 参数错误；`runs/<scenario>/rep<i>.log` 有 stderr |
| test 50，`wall time must be positive` | 命令立即失败（如二进制不可执行） |
| 构建超时 | aarch64 Runner 核数不足；如实记录，不要用预编译包替代（见第 1 节理由） |

## 8. 许可证

LLVM 使用 Apache License 2.0 with LLVM Exceptions（部分子项目为 MIT/BSD 风格）。
本用例只下载其官方源码包并按固定参数构建 `opt`/`llc`，不修改源码；生成的 IR
语料由本用例脚本生成，无第三方代码。
