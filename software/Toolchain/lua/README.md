# lua

Lua 5.5.1 解释器性能用例。完整口径为**系统化负载矩阵 + 上游官方测试套件**：从官方源码构建 PUC Lua（不启用 LuaJIT），覆盖计算、分配/GC、数据结构、字符串、字节码编译与上游测试套件六个维度，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **5.5.1** |
| 上游发布 | `https://www.lua.org/ftp/lua-5.5.1.tar.gz`（2026-07-24，398,643 字节） |
| 源码 SHA-256 | `1c4b4068d67061f2a2231ad2b5422e77acea1487ea9890f6320af614f4373dce` |
| 官方校验来源 | `https://www.lua.org/ftp/` 的 `checksum (sha256)` 列与 `https://www.lua.org/download.html`；本用例在下载后强制核对 |
| 上游测试套件 | `https://www.lua.org/tests/lua-5.5.1-tests.tar.gz`（2026-07-24，150,553 字节） |
| 测试套件 SHA-256 | `da07b543872dc0bb2ff12aabd0c248578d78df3eb6b67efdc537a46d455c7f31` |
| 解释器 | 由上述源码构建的 PUC Lua 5.5.1（`lua` + `luac`），**不使用 LuaJIT、不加载第三方 C 模块** |
| 构建工具链 | Runner 系统 `gcc -std=gnu99` / `make`（版本未固定，逐次运行写入 `build_info.json` 的构建命令与 `runtime_context`） |

lua.org 是唯一的官方制品来源；两个架构使用**同一份源码归档**，差异只来自各架构的编译器与 CPU。官方 `lua.org` 与其 `tests/` 目录均提供 SHA-256，本用例对**源码归档与测试套件归档都强制校验**，校验失败、下载失败、解包失败一律使 `build` 阶段非零退出（框架映射为 30），不降级、不跳过。

离线包约定：把下列文件预置到 `/home/runner/software/lua/` 时优先使用并强制校验，缺失才联网下载：

```text
lua-5.5.1.tar.gz
lua-5.5.1-tests.tar.gz
```

受限网络下可设置 `PERF_LUA_SOURCE_MIRROR` / `PERF_LUA_TESTSUITE_MIRROR`，指向一个直接存放上述归档的目录（例如内网制品库）；默认只用官方地址。**本机验证时实测 lua.org 可达，而 tuna/aliyun 镜像并不收录 lua.org 的 5.5.1 归档（均返回 404），因此没有把镜像写入默认下载顺序。**

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验/安装系统依赖（`curl`、`tar`、`gzip`、`sha256sum`、`gawk`、`make`、`gcc`、`python3`、`find`、`sed`、coreutils、GNU `time` 的 `/usr/bin/time`）；Runner 通过 `sudo -n dnf` 补齐，代理来自 `PERF_PROXY`。`/usr/bin/time` 只用于读取被测进程自身的 `%M`（峰值 RSS），不可用则 `build` 明确失败而不是换用不准确的替代测量。
2. 取源码归档与官方测试套件归档，核对 SHA-256 后分别解包到 `$PERF_WORK_DIR/lua-src`（源码树）与 `$PERF_WORK_DIR/lua-tests`（测试套件）。
3. 在源码树执行确定性目标 **`make linux`**（`src/Makefile` 的 `Linux linux` 目标：`SYSCFLAGS="-DLUA_USE_LINUX"`、`SYSLIBS="-Wl,-E -ldl"`；编译器 `CC=gcc -std=gnu99`，`CFLAGS=-O2 -Wall -Wextra`）。不使用 `linux-readline`、不传自定义 `-march`、不注入 `CFLAGS/LDFLAGS`。
4. 运行产物自己的 `lua -v` 与 `luac -v`，把解析出的实际版本写入 `PERF_ACTUAL_VERSION_FILE`；实际版本必须等于 `5.5.1`，否则 `build` 失败（框架据 `actual-version.txt` 强制校验）。
5. 用 `scripts/generate_sources.py` 确定性生成 12,000 个 Lua 模块 + `main.lua` 到 `$PERF_WORK_DIR/generated/luac`，并把生成器报告的期望校验和与 `benchmarks/scenarios.psv` 中提交的期望值比对，不一致即 `build` 失败。
6. 冒烟：确认全部负载脚本可被 `loadfile` 加载，并运行一次小规模算术核对其校验和；退出前写出 `build_variant.json`。

构建日志留在 `$PERF_WORK_DIR/lua-build.log`；构建产物（`lua-src`、`lua-tests`、`generated`）留在本次任务的私有工作目录，供后续阶段复用。**测量阶段不联网**：Lua 本身与官方测试套件都是自包含的，矩阵不下载任何内容。

## 3. 完整测试口径

### 3.1 为什么不是"上游性能套件 + 短周期冒烟"

Lua 上游没有性能基准套件。官方 `lua-5.5.1-tests.tar.gz` 是**正确性/鲁棒性测试**（basic 套件的全部断言 + 大量错误注入与内存边界用例），其设计目标是覆盖语言与 C API 的边界，而不是可比较的耗时；complete/internal 套件还要求现场编译 `testes/libs` 的 C 库、或用 `ltests` 调试版重编 Lua，机器相关且可能因系统 C 库差异失败。把它当作唯一性能口径会产生不可复现、不可解释的数字。

因此本用例采用**系统化负载矩阵**：负载是本仓库提交的、可逐行审查的纯 Lua 程序（`benchmarks/*.lua`），覆盖 6 个维度；同时把上游官方 basic 测试套件作为第 10 个场景纳入矩阵（测的是"完整跑一遍官方正确性套件"的墙钟，输出必须是 `final OK`），既保留上游负载又避免把正确性套件当成微基准。手册建议的 lua-bench/Benchmarks Game 方向以 nbody / fannkuch-redux / spectral-norm / binary-trees 四个经典算法落地（自行实现，不引入外部依赖）。

### 3.2 矩阵

每个场景 **1 次预热 + 5 次独立正式测量**（`PERF_REPS` 默认 5），报告**中位数**，同时保留每次样本、最小值、最大值、均值与标准差。所有场景单线程、单进程。

| 场景 | 维度 | 规模 | 负载 | 确定性校验 |
|---|---|---|---|---|
| `arithmetic_loop_100000000` | compute | 100,000,000 次循环 | 固定整数模运算累加（手册"固定循环算术核"维度的扩展） | 整数校验和精确匹配 |
| `nbody_500000` | compute | 500,000 步 | 五体太阳系 N-body 双精度模拟 | 能量值，相对误差 ≤ 1e-9 |
| `fannkuch_10` | compute | 10! 全排列 | fannkuch-redux 翻转计数 | 整数校验和精确匹配 |
| `spectral_norm_800` | compute | 800×800 | A^T A 的 10 次幂迭代 | 特征值，相对误差 ≤ 1e-9 |
| `binary_trees_16` | allocation_gc | 深度 16 | 自底向上树分配与遍历 | 节点计数校验和精确匹配 |
| `table_build_1000000` | data_structure | 100 万整数键 + 100 万字符串键 | 哈希表构造、遍历、条目计数 | 整数校验和精确匹配 |
| `string_churn_1000000` | string | 100 万次 | 拼接、`table.concat`、模式替换、`string.format` | 整数校验和精确匹配 |
| `gc_stress_15000` | gc | 15,000 轮 | 表/闭包/字符串分配抖动 + 每 10 轮显式 full GC | 整数校验和精确匹配 |
| `luac_compile_12000` | compile | 12,000 个模块 | `luac -o out.luac module_*.lua main.lua` 一次编译；编译产物另行加载执行校验 | 编译产物可加载且校验和精确匹配 |
| `official_test_suite` | upstream | 上游 basic 套件 | `lua -e "_U=true" all.lua`（官方 5.5.1 测试套件） | 输出必须含 `final OK` |

共 **10 个场景 × 2 项指标 = 20 个指标**。每个场景的规模、期望校验和与容差都提交在 `benchmarks/scenarios.psv`；任何一次测量的校验和与提交值不符（整数精确、浮点相对 1e-9）、退出码非零、超时、原始日志缺失，`test` 阶段即失败，**不补零、不估算、不把失败样本剔除后重跑**。

浮点场景（nbody、spectral-norm）使用 1e-9 相对容差，因为不同架构的 `libm`/`sqrt` 末位可能相差 1 ulp；同一架构上重复测量结果逐位一致，容差只用于跨架构比对，不用于掩盖实现错误（1e-9 远小于任何有效负载差异）。

### 3.3 固定条件

- 解释器为 PUC Lua 5.5.1，**禁用 LuaJIT**；不设置 `LUA_INIT`、`LUA_PATH`、`LUA_CPATH`，每次测量都由 `scripts/run_timed.py` 以干净子进程启动。
- GC 使用 Lua 默认增量 GC 与默认参数；只有 `gc_stress` 在负载内部按固定节奏调用 `collectgarbage("collect")`（脚本内容的一部分，两架构一致）。不调用 `collectgarbage("setpause"/"setstepmul")`。
- 墙钟统一由 `scripts/run_timed.py` 在子进程外测得（`time.monotonic`）；峰值 RSS 由 GNU `time -f %M` 从被测 Lua/luac 进程自身的 rusage 读取（测试套件场景只统计 `lua` 进程本身，不含其短生命周期子进程），避免以 Python 包装器的内存作为下限。
- `luac_compile` 的 12,000 个模块由 `scripts/generate_sources.py` 确定性生成（内容只依赖模块序号），生成器期望校验和与矩阵提交值在 build 阶段强制比对；测量只覆盖 `luac` 编译进程，编译产物的加载执行校验在计时窗口外进行。
- 测量阶段不联网、不设 `MAKEFLAGS`、不注入编译器缓存或 `LD_PRELOAD`；固定单进程单线程，不使用 `taskset` 之外的绑核参数。
- 原始证据完整保留：`RESULTS_DIR/runs/<场景>/warmup.{log,json}` 与 `rep<i>.{log,json}`（`luac` 场景另有 `rep<i>.validation.log`）。

### 3.4 单架构耗时（本机 x86_64 WSL2 实测）

`PERF_REPS=5` 六阶段实测：`build` 约 10 s（源码解包/编译 + 12,000 个模块生成，离线包已预置；首次含下载约 30 s），`test` 约 **75–80 s**，六阶段合计 **约 1.5–2 分钟**；aarch64 专用 Runner 预计 3–5 分钟，远低于 `timeout_minutes: 180`。各场景单次墙钟（中位数）约为：arithmetic 0.85 s、nbody 0.7 s、fannkuch 1.35 s、spectral 0.8 s、binary_trees 1.65 s、table 1.9 s、string 1.4 s、gc 1.2 s、luac 0.3 s、官方套件 0.6 s。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好（`lower_is_better`） | `scripts/run_timed.py` 测得的单次被测进程墙钟，取 5 次独立测量的中位数 |
| `<场景>_rss` | `MiB` | 越低越好（`lower_is_better`） | 同一被测进程的 `%M`（GNU time 读取的峰值 RSS），取 5 次中位数 |

20 个指标全部由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合，并做以下强校验：场景目录集合必须与 `scenarios.psv` 完全一致（不允许多余/缺失场景）、每个场景 5 个样本齐全、`exit_code == 0`、`timed_out == false`、原始日志非空、wall/RSS 为有限正数、工作负载校验和与提交值一致。任一条件不满足即解析失败，`test` 阶段返回非零。

`case.yaml` 用 `metrics.collection` 动态提取指标（`path: results`、`name_path: source_name`、`value_path: value`、`unit_path: unit`、`direction_path: direction`、`group_path: scenario`），每个场景的 `s` 与 `_rss` 指标归入同一 group，报告按场景成对展示。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`，`variant=base`，`version=5.5.1`。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 运行 → 解析 → 报告），产出**不是**性能结论，也不用于跨架构排序。
- 脚本保持架构无关：仅用 `uname -m` 校验 `EXPECTED_ARCH`，两个架构使用同一份源码归档、同一个 `make linux` 目标、同一套负载脚本、同一采样与解析流程。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: lua
version: 5.5.1
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_REPS=5                          # 默认 5；本机链路验证可临时降低并记录
export PERF_WORK_DIR=$HOME/lua-work         # 可选；默认 /home/runner/boostkit-perf
bash software/Toolchain/lua/lua_test.sh \
  --version 5.5.1 --variant base --results-dir "$HOME/lua-results"
```

`optimized` 变体尚未实现：`lua_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base，也不写 `build_variant.json`。

可选环境变量：

| 变量 | 作用 |
|---|---|
| `PERF_REPS` | 每个场景的独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |
| `LUA_OFFLINE_DIR` | 离线包目录，默认 `/home/runner/software/lua` |
| `PERF_LUA_SOURCE_MIRROR` | 源码归档镜像目录（直接包含 `lua-5.5.1.tar.gz`）；默认只用官方 lua.org |
| `PERF_LUA_TESTSUITE_MIRROR` | 测试套件归档镜像目录（直接包含 `lua-5.5.1-tests.tar.gz`）；默认只用官方 lua.org |
| `LUA_GENERATED_MODULES` | `luac` 场景生成的模块数，默认 12000；修改后需同步 `benchmarks/scenarios.psv` |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`results.log`、`raw-output.log`、`runs/`（每场景预热 + 5 次测量的完整原始日志、计时 JSON 与 `luac` 校验输出）。框架六阶段运行时另有 `command-*.log` 与 `test` 阶段的 `raw-output.log`。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 Lua 负载是"200 万次整数模运算累加，1 次预热 + 3 次样本"，属于**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"，其 111 实测值（`arithmetic_loop_2m = 0.01767324 s`）不迁移进仓库、不作为性能结论。

本用例保留该代表负载的计算维度，但把规模扩展到 **1 亿次**（本机单次约 0.9 s）：2,000 万次以下的纯整数循环单次仅约 20 ms，低于可信性能测量下限，会把计时噪声放大成"结论"。矩阵在此基础上扩展到 Benchmarks Game 经典算法、分配/GC、数据结构、字符串/模式匹配、`luac` 编译与上游官方测试套件，形成可复现的完整口径；旧的 2M 冒烟值与本矩阵指标不可直接比较。

## 8. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 SHA-256 不匹配 | 检查 `/home/runner/software/lua/` 预置包是否与本文档的官方校验值一致；删除损坏缓存重试 |
| `build` 报下载失败 | 确认 lua.org 可达；受限网络下预置离线包或设置 `PERF_LUA_SOURCE_MIRROR` / `PERF_LUA_TESTSUITE_MIRROR`，日志会打印尝试过的每个路径与 URL |
| `lua -v` 版本不是 5.5.1 | 预置归档版本错误，或工作目录残留旧解包；清理 `$PERF_WORK_DIR/lua-src` 重跑 |
| `make linux` 失败 | 查看 `$PERF_WORK_DIR/lua-build.log`；确认 `gcc`/`make` 可用，系统缺少 `-ldl` 头文件时安装 glibc-devel |
| `build` 报生成源码校验和不一致 | `scripts/generate_sources.py` 或 `benchmarks/scenarios.psv` 被改动后未同步；恢复后再跑 |
| `test` 报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`；失败或超时的那次测量会保留原始日志 |
| `test` 报校验和不符 | 负载或解释器被改动；对照 `benchmarks/scenarios.psv` 的期望值与本机日志，不要用"重跑直到通过"规避 |
| 浮点场景跨架构相对误差报警 | 容差为 1e-9；先确认两架构都构建同一归档、同一 `make linux`，再检查是否误用了不同编译器优化选项 |
| `luac_compile_12000` 变慢或报参数过长 | 检查 `getconf ARG_MAX`；12,000 个模块的参数总量约 0.7 MB，低于常见 2 MB 上限；不要通过增大 `LUA_GENERATED_MODULES` 规避 |
| 官方测试套件输出无 `final OK` | 查看 `runs/official_test_suite/rep<i>.log`；确认套件归档版本与 5.5.1 一致，且未被 `PERF_LUA_TESTSUITE_MIRROR` 指向旧版本 |

## 9. 许可证

Lua 5.5.1 采用 MIT License（Lua.org, PUC-Rio），官方测试套件使用同一许可证。`benchmarks/*.lua`、`scripts/generate_sources.py`、`scripts/run_timed.py`、`scripts/results/*.py` 为本仓库原创负载与工具，遵循仓库既有许可。
