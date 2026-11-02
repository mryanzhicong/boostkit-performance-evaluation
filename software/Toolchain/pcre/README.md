# PCRE 8.45 性能测试

本用例在 `x86_64`、`aarch64` Runner 上从官方源码构建 PCRE（Perl Compatible Regular
Expressions）8.45 的 8-bit 库，再运行上游 `pcretest`、`pcregrep` 与 `RunTest` 以及本用例
自带的固定负载，覆盖字面量匹配、回溯、UTF-8 匹配、DFA 匹配、JIT 编译执行与编译期开销。
目标是让两架构在**同一份源码、同一组固定输入、同一套命令**下比较匹配吞吐与延迟。

入口为 `pcre_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也使用这些阶段。基础版构建位于 `scripts/builders/base.sh`，公共路径与
常量在 `scripts/common.sh`，测量包装在 `scripts/run_timed.py`，结果解析与报告在
`scripts/results/`。工作流可选择 `base` 或 `optimized`，默认 `base`；`optimized` 构建
尚未实现，选择后会在 build 阶段明确失败（退出码 30），不会回退到 `base`，也不会写出
`build_variant.json`。

PCRE1（8.45）与 PCRE2 是两条独立的代码线。本用例只测 PCRE1 8.45：构建、`pcretest`
与 `pcregrep` 都来自该源码包，不使用系统预装的 PCRE2。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| PCRE | [官方发布镜像 ftp.exim.org](https://ftp.exim.org/pub/pcre/) 的 8.45 源码包 `pcre-8.45.tar.gz` | 优先读取 `/home/runner/software/pcre/pcre-8.45.tar.gz`，缺失时下载；构建并安装到本次任务私有目录 |
| `pcretest` | 随 8.45 源码包构建的上游工具 | `${PERF_WORK_DIR}/pcre-install/bin/pcretest` |
| `pcregrep` | 随 8.45 源码包构建的上游工具 | `${PERF_WORK_DIR}/pcre-install/bin/pcregrep` |
| `RunTest` | 源码包自带的上游测试套件 | `${PERF_WORK_DIR}/pcre-src/RunTest` |
| `pcre_bench` | 本用例自带的 MIT 许可固定负载（`benchmark/pcre_bench.c`） | `${PERF_WORK_DIR}/pcre-bench/pcre_bench` |

Runner 通过 `dnf`（Debian/Ubuntu 上为 `apt-get`）安装缺失的 `gcc`、`make`、`tar`、
`coreutils`、`python3`，以及 `curl`/`wget` 之一；安装后会再次自检这些命令，失败则
build 阶段返回 30。构建只需要 C 编译器与系统 C 库，不需要 readline、libedit 或 zlib：
配置时已关闭它们，`pcretest` 的读入、编辑与 `pcregrep` 的压缩支持因此不可用，但不影响
本用例的命令行与计时行为。

Framework 将本次任务的工作目录传给脚本，以下称为 `${PERF_WORK_DIR}`。独立运行时默认位于
`/home/runner/boostkit-perf/pcre/<运行ID>/`。源码、构建、安装、fixtures 与临时文件都放在
该目录下；结果写入单独的 `${RESULTS_DIR}`。测量命令在 `unshare -n` 新建的网络命名空间内
执行，构建期已把源码包下载并校验完毕，测量期不需要网络。

## PCRE 获取、构建与安装

源码包先从 `/home/runner/software/pcre/` 读取；没有时依次尝试下表候选。无论来源，
解压前都必须匹配下表的 SHA-256 与字节数。

| 源码包 | SHA-256 | 字节数 |
|---|---|---|
| `pcre-8.45.tar.gz` | `4e6ce03e0336e8b4a3d6c2b70b1c5e18590a5673a98186da90d4f33c23defc09` | 2096552 |

候选顺序（`PERF_PCRE_OFFLINE_DIR` 可覆盖第一个目录，`PERF_PCRE_MIRROR` 可给非离线候选
加统一前缀）：

```text
${PERF_PCRE_OFFLINE_DIR}/pcre-8.45.tar.gz
https://ftp.exim.org/pub/pcre/pcre-8.45.tar.gz          # 官方发布镜像（权威来源）
https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/download
https://downloads.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.gz
https://master.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.gz?viasf=1
```

下载与校验的命令形态如下：

```bash
curl -fSL --retry 2 --retry-delay 3 --connect-timeout 15 --max-time 300 \
  -o "${PERF_WORK_DIR}/downloads/pcre-8.45.tar.gz" \
  "https://ftp.exim.org/pub/pcre/pcre-8.45.tar.gz"   # 仅离线包不存在时
sha256sum "${PERF_WORK_DIR}/downloads/pcre-8.45.tar.gz"  # 必须匹配上表
```

所有候选都不可用时，build 阶段返回 30 并打印完整候选清单与失败原因。源码解压到
`pcre-src/`，在源码目录内就地构建（PCRE 8.45 的 `configure` 支持 out-of-tree，但就地
构建与上游文档一致，且避免 `RunTest` 对源码树路径的额外假设），安装到
`pcre-install/`：

```bash
cd "${PERF_WORK_DIR}/pcre-src"
./configure --prefix="${PERF_WORK_DIR}/pcre-install" \
  --enable-utf --enable-unicode-properties --enable-jit \
  --disable-shared --enable-static \
  --disable-pcretest-libreadline --disable-pcretest-libedit \
  --enable-pcre8 --disable-pcre16 --disable-pcre32
make -j"${PERF_PCRE_BUILD_JOBS}" all
make install
```

`PERF_PCRE_BUILD_JOBS` 默认 8；本机与其他任务并行时用 `-j4`。配置参数固定在
`scripts/common.sh`，两架构完全一致；`CFLAGS` 固定为 `-O2 -DNDEBUG`，不追加
`-march=native` 等机器相关选项，保证两架构参数签名一致。构建后用
`pcre-config --version` 读出实际版本写入 `${RESULTS_DIR}/actual-version.txt`，
与请求版本不一致则 build 返回 30；同时检查 `pcretest`、`pcregrep`、`pcre-config`、
`libpcre.a` 都存在。

`pcre_bench` 由 build 阶段用刚安装的静态库编译，命令与产物路径都写入
`build-provenance.txt`：

```bash
cc -O2 -std=c99 -Wall -Wextra -Werror \
  -I "${PERF_WORK_DIR}/pcre-install/include" \
  benchmark/pcre_bench.c \
  -L "${PERF_WORK_DIR}/pcre-install/lib" -lpcre \
  -o "${PERF_WORK_DIR}/pcre-bench/pcre_bench"
```

## 测试数据

测试输入由 `scripts/fixtures/generate_fixtures.py` 用固定种子的 splitmix64 生成，
与机器无关；start 阶段每次重新生成并逐个比对下表 SHA-256，任一不一致即 start 返回 20。
因此输入不是“预置数据”，而是可复现的确定性语料，两侧 Runner 得到的字节完全相同。

| 文件 | 内容 | SHA-256 |
|---|---|---|
| `pcretest_literal.txt` | 6 个模式 / 13 条数据行的 `pcretest` 输入 | `47d7ac545b3a5b052a8ff30391b29f757e02ae8bc6cfb86dd94fc0454f9c5260` |
| `pcretest_backtrack.txt` | 3 个回溯模式 / 3 条数据行（17×`a` 的灾难性回溯） | `dda0f0d0e80395cd0a535d79fb6fd0d22b1f3d843b55ae8d8e914d56642bed46` |
| `pcretest_utf8.txt` | 4 个 UTF-8/Unicode 模式 / 4 条数据行 | `49b9895ec5b47ecc36e1980af67e30bc08540381b5c060cba8e2f8af7246eb66` |
| `pcretest_dfa.txt` | 3 个 DFA 模式 / 5 条数据行 | `e284e13bc16c8bde4e7a5d494287a79e9d9da8360dcbcc29e63b96b7aa8a4e19` |
| `scan_patterns.txt` | `pcregrep` 扫描用的 8 个模式 | `3f067bb24e13505eecc085aef18dfbf0ff4ef519e30f8d286f726746d5b735be` |
| `scan_corpus.txt` | 57,499,392 字节（54.8 MiB）确定性命中语料 | `1a4ad1797740481f4643fe08302911e872ca95994f7376f738b9b32052db458c` |

`scan_corpus.txt` 的 8 个模式命中行数在生成时固化为
`[49892, 50029, 175259, 199638, 261, 99935, 50068, 100018]`，合计 **725100**；
`pcregrep` 扫描脚本逐模式用 `pcregrep -c` 统计并与该值比对，任一行数不符即判测试失败
（退出码 50），不做“跑完就算”的宽松处理。

## 场景与命令

共 12 个场景，全部使用上游工具或本用例自带负载，固定迭代次数（迭代次数是负载常量，
不随机器变化）：

| 场景 | 命令（核心部分） | 说明 |
|---|---|---|
| `pcretest_timing_literal` | `pcretest -q -T -t 300000 pcretest_literal.txt` | 上游 `pcretest` 逐模式、逐数据行循环 300000 次 |
| `pcretest_timing_backtrack` | `pcretest -q -T -t 600 pcretest_backtrack.txt` | 灾难性回溯输入，单次约 3–5 ms |
| `pcretest_timing_utf8` | `pcretest -q -T -t 1200000 pcretest_utf8.txt` | UTF-8 与 Unicode 属性匹配 |
| `pcretest_dfa` | `pcretest -q -T -t 300000 -dfa pcretest_dfa.txt` | DFA 匹配（`-dfa`，无捕获开销） |
| `upstream_runtest` | `./RunTest 1 2 4 5 6 7 8 9 10 11 12 14 15 16` | 上游自检套件 14 个测试，期望 36 个 `OK` |
| `pcre_exec_literal` | `pcre_bench literal 10000000` | `pcre_exec` 字面量匹配 1000 万次 |
| `pcre_exec_backtrack` | `pcre_bench backtrack 600` | `^(a+)+[bc]` 对 17×`a` 的回溯 600 次 |
| `pcre_exec_utf8` | `pcre_bench utf8 12000000` | UTF-8 模式匹配 1200 万次 |
| `pcre_exec_dfa` | `pcre_bench dfa 5000000` | `pcre_dfa_exec` 500 万次 |
| `pcre_exec_jit` | `pcre_bench jit 60000000` | `pcre_study` + JIT 编译后的执行 6000 万次 |
| `pcre_compile` | `pcre_bench compile 3000000` | `pcre_compile` 编译 300 万次 |
| `pcregrep_scan` | `pcregrep_scan.sh <fixtures> 725100` | 8 个模式各扫一遍 54.8 MiB 语料 |

`RunTest` 的子集说明：测试 3（Locale-specific）依赖 Runner 的 locale 数据，测试 13
只在“未编译 JIT 支持”时运行；本构建启用 JIT，且两架构 locale 不强求一致，故固定排除
这两项，其余 14 个 8-bit 测试全部运行，期望 36 个 `OK` 且零失败。解析器要求
`OK` 数不少于 36、且日志中不出现失败标记。

`pcre_bench` 每个模式在计时前先做一次命中校验，输出
`PERF-CHECK name=... expected=... actual=... status=ok`，全部通过后才打印
`PERF-RESULT status=ok`；解析器要求每个场景的必需自检项齐备且为 `ok`，否则判失败。
`pcretest` 场景要求 `Execute time` 行数等于该输入的数据行数、`Compile time` 行数等于
模式数（DFA 场景用 `-TM`，只要求 `Total execute time` 汇总行且不计编译）。

## 指标与方向

每个场景产出 3 项指标，共 46 项；主指标是墙钟与工作负载吞吐，峰值 RSS 用于约束内存
开销。所有指标取 5 次独立重复（`PERF_REPS=5`）的中位数，同时保留全部样本与
min/max/mean/stdev。

| 指标类别 | 单位 | 方向 | 说明 |
|---|---|---|---|
| `<场景>_wall_s` | 秒 | 越小越好 | 一次测量进程的墙钟时间 |
| `<场景>_rss_mib` | MiB | 越小越好 | 测量进程的峰值 RSS（`VmHWM`） |
| `pcretest_*_matches_per_second` | matches/s | 越大越好 | 迭代次数 × 数据行数 / 墙钟 |
| `pcretest_*_compiles_per_second` | compiles/s | 越大越好 | 迭代次数 × 模式数 / 墙钟 |
| `upstream_runtest_tests_ok` | tests | 越大越好 | 通过的 `OK` 断言数（期望 36） |
| `pcre_exec_*_match_ns_per_op` / `_dfa_ns_per_op` | ns/op | 越小越好 | 上游 `pcretest` 的自计时或 harness 计时，见下 |
| `pcre_compile_compile_ns_per_op` | ns/op | 越小越好 | 单次 `pcre_compile` 平均耗时 |
| `pcre_exec_*_ops_per_second` / `pcre_compile_compiles_per_second` | ops/s | 越大越好 | harness 的 `CLOCK_MONOTONIC` 吞吐 |
| `pcregrep_scan_matched_lines` | lines | 越大越好 | 扫描命中行数（期望 725100，两侧必须相等） |
| `pcregrep_scan_scan_mib_per_second` | MiB/s | 越大越好 | 语料字节 × 模式数 / 墙钟 |

`pcretest` 自带的 `Execute time` 精度只有 0.1 µs 且对单次调用量化严重，因此只作为
`raw-output.log` 中的证据，不作为指标：`pcretest` 的吞吐指标一律用“迭代次数 × 操作数 /
整个进程墙钟”计算，避免使用被量化的内部计时。`pcre_bench` 的 ns/op 由 harness 在固定
循环外用 `CLOCK_MONOTONIC` 测得，迭代次数写进 `PERF-CONFIG` 行并在参数中固化。

参数（`parameters`）只包含与机器无关的量：变体、重复次数、离线标志、源码 SHA-256、
configure 选项、CFLAGS、并行度、固定迭代次数、fixture SHA-256、期望命中行数等；CPU、
编译器、网络模式等环境信息放在 `runtime_context`，不参与跨架构参数签名。

## 数据与运行顺序

1. **build**：安装依赖，取得并校验源码包，配置、编译、安装 PCRE，编译 `pcre_bench`，
   校验实际版本，写 `build_variant.json` 与构建溯源信息。
2. **start**：生成 fixtures 并逐个校验 SHA-256，检查 `pcretest`/`pcregrep`/`RunTest`
   可用，探测测量期能否用 `unshare -n` 隔离网络，把结果写入
   `${PCRE_STATE_DIR}/measurement-network-mode.txt`。
3. **test**：对 12 个场景依次跑 1 次预热 + `PERF_REPS` 次独立重复；每次重复都由
   `scripts/run_timed.py` 包一层，执行完立刻把墙钟、峰值 RSS、退出码写入
   `runs/<场景>/rep<i>.json`，完整 stdout/stderr 写入 `runs/<场景>/rep<i>.log`，
   预热的对应文件为 `warmup.log`/`warmup.json`。随后校验并通过目录
   `scripts/results/parse_benchmark.py` 归一化为 `results.json`，同时把全部日志汇总为
   `raw-output.log`。
4. **stop**：确认没有遗留被测进程（只按 `${PERF_WORK_DIR}` 标记精确清理），删除临时
   目录，返回 60 表示清理失败。
5. **finalize**：由 Framework 完成；独立运行时由 `scripts/results/standalone_runtime.py`
   写出 `report.md` 与 `standalone_summary.json`。

测量期离线是硬约束：默认所有测量命令都在 `unshare -n` 内运行，若 Runner 不支持
`unshare`，start 阶段直接失败，除非显式设置
`PERF_PCRE_ALLOW_ONLINE_MEASUREMENT=1`（此时参数里 `offline` 记录为 false，报告中
必须说明）。构建期不测量，允许联网取源码。

解析器是严格的：场景集合必须与上表完全一致；每个声明的重复样本与日志必须存在；
退出码非 0、超时、缺指标行、指标非有限正数、自检非 `ok`、`RunTest` 有失败或 `OK` 数
不足、`pcregrep` 命中行数与固定值不符、日志出现 `** Failed`/`NaN`/段错误标记——
任一情况 test 阶段返回 50，**不填充、不插值、不以 0 补齐样本**。失败时输出 40 行
日志尾部辅助定位。

退出码约定：10 参数错误、20 start、30 构建、50 test/stop、60 finalize。

独立运行示例：

```bash
bash software/Toolchain/pcre/pcre_test.sh \
  --version 8.45 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/pcre/results/8.45
```

需要排查时可加 `--keep-workdir` 保留源码、构建与 fixtures 目录；默认独立运行结束会清理
自己的 `${PERF_WORK_DIR}`。正式证据要求 `PERF_REPS=5`，`PERF_REPS=1` 只用于本地链路
自检（脚本会打印告警）。

## 已知限制与风险

- **共享 Runner 的噪声**：本机验证时同一 WSL 有 6 个任务并行构建，单样本
 变异系数（stdev/median）一度达到 13%–37%，明显高于安静机器。aarch64 专用 Runner
  应为独占环境；若必须共享，建议用 `PERF_REPS` 提高重复次数并关注 `stdev`。
- **峰值 RSS 的固定底噪**：峰值取自 `/proc/<pid>/status` 的 `VmHWM`，从 `unshare`
  子进程继承的约 1.7 MiB 启动足迹会抬高小负载的读数（`pcre_bench` 约 2.0 MiB、
  `pcretest` 约 2.2–2.3 MiB、`pcregrep` 约 3.4 MiB）。跨架构比较时该底噪相同，
  但绝对值不是进程独占内存。
- **回溯场景对 CPU 敏感**：`pcre_exec_backtrack` 单次约 3–5 ms，600 次在慢机上可能
  接近 5 s；若 aarch64 明显更慢，可下调迭代次数，但必须同步修改 `common.sh` 与本文档，
  并保持两侧一致。
- **`pcretest` 自计时的量化**：0.1 µs 精度只用作证据，不进入指标；主指标依赖整进程
  墙钟，因此包含进程启动与 fixtures 读取开销（相对 1.5–4 s 的循环可忽略）。
- **JIT 不可用时**：`pcre_exec_jit` 场景会因 `pcre_config(PCRE_CONFIG_JIT)` 为 0 而
  自检失败并返回非 0，test 阶段判失败；PCRE 8.45 的 JIT 在 x86_64 与 aarch64 均受支持，
  目前不需要降级路径。
- **`optimized` 变体未实现**：选择后会立刻以 30 失败，不会静默回退。
