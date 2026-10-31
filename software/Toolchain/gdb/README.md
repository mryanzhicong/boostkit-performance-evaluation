# GDB 18.1 性能测试

本用例在 `x86_64` 与 `aarch64` Runner 上分别**从官方源码构建 GDB 18.1**（隔离 prefix），
再用**确定性生成的 C 程序 + GDB 命令脚本 + GDB Python 脚本 + 上游 testsuite 固定子集**
执行 10 个场景、每个场景 1 次预热 + 5 次独立测量。指标为墙钟耗时（s，越低越好）与进程组
峰值 RSS（MiB，越低越好），报告各场景中位数，并保留全部样本的 min/max/mean/stdev 与原始
`rep<i>.{log,json}`。测量阶段完全离线。

入口为 `gdb_test.sh`；Framework 通过 `case.yaml` 调用构建、启动、测试、停止四个阶段函数。
基础逻辑位于 `scripts/builders/base.sh`（源码获取、依赖安装、configure/make/install），
工作负载与元数据位于 `scripts/fixtures/`，计时与解析位于 `scripts/`、`scripts/results/`。

## 1. 与手册（16-GDB）的对应关系

手册给定的公开套件/方法是 **GDB `gdb.perf` + 固定符号程序 batch 符号加载及断点**，指标为
符号加载 s、断点响应 s、RSS；交付实际执行的代表负载是「固定小型 `-g -O0` C 程序，batch
设置函数断点并读取符号，不启动 inferior」，只测进程 + 符号加载开销（交付结果
`symbol_load_breakpoint = 0.01177606 s`，3 个样本）。

本用例把这个口径扩展为**完整测试矩阵**，并把手册建议的上游负载 `gdb.perf` 之外的上游
testsuite 固定子集纳入正确性 + 计时门禁：

| 手册要求 | 本用例实现 |
|---|---|
| 固定小型 `-g -O0` C 程序、batch 符号加载 | `symbol_load_1000`（1000 个带调试信息的全局函数，`gdb -batch -ex quit`） |
| 固定符号程序上的断点响应 | `breakpoint_set_200`（50000 函数二进制上设置 200 个函数断点，不启动 inferior） |
| 符号规模扩展 | `symbol_load_50000`（50000 函数）、`info_functions_10000`（10000 函数全符号遍历） |
| RSS 指标 | 每个场景同时记录峰值 RSS |
| 公开套件 `gdb.perf` / 上游负载 | `upstream_testsuite_python`：上游 GDB 18.1 testsuite 固定子集 `gdb.python/py-symbol.exp`、`py-value.exp` 与 `gdb.base/break.exp` 的官方 `.exp` 用例（离线运行，PASS ≥ 12 且 unexpected failures = 0） |

固定子集的 3 个 `.exp` 都是自包含的经典用例（不依赖 SystemTap `sys/sdt.h` 等可选头文件），
因此 Runner 只需 C 编译器、Python 与 DejaGnu。构建阶段会记录该子集在本机的基线 PASS 数
（x86_64 验证机为 573），解析器按「PASS ≥ 12 且 unexpected failures = 0」判定；不同架构或
不同可选特性下 PASS 数可能略有差异，但失败数必须为 0。

`gdb.perf` 的用例依赖 tcl/tk 图形栈且不是「单进程一次 batch」的形态，无法在两端稳定地
以相同输入离线重复；因此上游负载采用同一上游仓库、同一版本的 testsuite 固定子集，并明确
说明它只覆盖 3 个测试文件，不代表 GDB 全量测试套件耗时。除上游子集外，所有输入都是本用例
自带 MIT 许可的生成代码，不称为上游完整套件。

## 2. 软件、源码与校验

| 项目 | 来源与版本 | 说明 |
|---|---|---|
| GDB | [GNU GDB 官方发布目录](https://ftp.gnu.org/gnu/gdb/) 的 `gdb-18.1.tar.xz` | 优先读取预置的 `/home/runner/software/gdb/gdb-18.1.tar.xz`；缺失时依次尝试清华 TUNA、中科大 USTC、`ftp.gnu.org` 镜像 |
| 源码 SHA-256 | `cd9fc3fe2b47743840e42c1592d3d87f8302eb18639c0b8b4ba0898002e2348f` | 22,158,720 字节；构建阶段在解压前强制校验 |
| 源码签名 | 同名 `.tar.xz.sig` | GNU 只发布**分离的 GPG 签名**、不发布 SHA-256 文件；镜像未提供可信校验文件时，本用例把下载得到的归档 SHA-256 固定在上表中，同时保存 `.sig` 并记录其 SHA-256 以便后续审计；Runner 无 GDB 签名公钥环，因此签名本身不做密码学验证 |
| 上游 testsuite | 同一 `gdb-18.1` 源码包内的 `gdb/testsuite/gdb.python/` | 固定 3 个 `.exp` 测试文件，随机化种子与 objdir 由 DejaGnu 自身管理 |
| 测试 C 程序 | 本用例 `scripts/fixtures/generate_fixtures.py` 生成 | MIT 许可，SHA-256 固定于 `fixtures/fixtures.json` |

镜像说明：`ftp.gnu.org` 在部分网络不可达，因此默认顺序是「预置本地文件 → TUNA → USTC →
官方 ftp」。无论来自哪里，均先比对上表 SHA-256 与字节数，不一致立即失败（构建阶段返回
非 0），不会在未校验的源码上继续构建。

## 3. 构建依赖与源码构建

构建阶段先用 `dnf`（RHEL/openEuler 系）或 `apt-get`（Debian/Ubuntu 系）补齐缺失的构建
依赖，已安装的包不会重复安装。依赖列表：

```text
gcc gcc-c++ make tar xz coreutils curl python3 python3-devel
gmp-devel mpfr-devel dejagnu texinfo findutils          # dnf
gcc g++ make tar xz coreutils curl python3 python3-dev
libgmp-dev libmpfr-dev dejagnu texinfo findutils        # apt-get
```

GDB 与 `libgmp`/`libmpfr` 动态链接（`--with-system-gmp --with-system-mpfr`），Python 支持
来自 `--with-python=python3`（GDB Python API 是测量场景之一）；`runtest` 来自 DejaGnu，
供上游 testsuite 子集使用。`texinfo` 仅用于兜底，构建与测试都设置 `MAKEINFO=true` 跳过
文档生成，因此文档不是构建阻塞项。

构建过程（`scripts/builders/base_helpers.sh`）：

```bash
tar -xJf gdb-18.1.tar.xz -C "${PERF_WORK_DIR}"        # 校验 SHA-256 后解压
cd "${PERF_WORK_DIR}/gdb-build"
MAKEINFO=true "${PERF_WORK_DIR}/gdb-src/configure" \
  --prefix="${PERF_WORK_DIR}/gdb-install" \
  --with-python=python3 \
  --disable-binutils --disable-gas --disable-ld --disable-gprof --disable-gold \
  --disable-sim --disable-tui --without-guile --without-intel-pt \
  --with-system-gmp --with-system-mpfr --disable-nls
make -j"$(nproc)" MAKEINFO=true
make install MAKEINFO=true
```

只构建 `gdb` 本身（关闭 binutils/gas/ld/gprof/gold/sim/TUI/guile/Intel PT），
安装到本次任务私有 prefix，不替换系统 GDB。构建结束后用
`gdb --version` 校验实际版本必须等于请求版本 `18.1`，否则构建阶段失败（Framework 退出码
30 的语义仍保留给「不支持的变体」）；实际版本写入 `actual-version.txt`，构建耗时
（configure/make/install 分段）写入 `build_provenance.json` 与构建日志，不计入任何指标。

本地 x86_64（20 核）实测：configure ≈ 1 s、`make -j20` ≈ 109 s、install ≈ 2 s，合计约
2 分钟；aarch64 Runner 核数更少，按 10–25 分钟预留。`case.yaml` 的阶段超时为 240 分钟。

## 4. 确定性负载与完整场景矩阵

所有输入由 `scripts/fixtures/generate_fixtures.py` 生成，生成器与产物的 SHA-256 固定在
`fixtures/fixtures.json`，构建阶段重新生成后逐字节比对，测量开始前再次比对，因此任何
「换了输入却没换预期」的情况都会失败。

| 输入 | 规模 | 用途 |
|---|---|---|
| `symbols_1000.c` / `symbols_10000.c` / `symbols_50000.c` | 1000 / 10000 / 50000 个带调试信息的全局函数 | 符号表规模矩阵 |
| `steps_500.c` | 1 个函数含 600 条语句 | 单步执行 |
| `deep_2000.c` | 递归 2000 层 + 叶子函数 | 深栈回溯、core 文件 |
| `breakpoints.cmd` | 200 条 `break fn_XXXXX` | 断点设置 |
| `steps.cmd` | `break main` + `run` + 500 条 `step`（`set trace-commands on`） | 单步 500 次，日志可精确计数 |
| `python_eval.py` | `gdb.lookup_global_symbol` 查找 5000 个符号 | GDB Python API |
| `deep_2000.core` | 由构建出的 GDB 在 `crash_here` 断点处 `generate-core-file` 生成 | core 文件加载 + `bt` |

固定编译参数：`-g -O0 -fno-omit-frame-pointer -fno-inline -fno-optimize-sibling-calls`
（保证调试信息完整、递归不内联、`bt` 帧数稳定）。编译产物与 core 文件的字节数/摘要作为
evidence 记录，不进入指标参数。

| 场景 | 负载 | 独立证据（解析器强制校验） |
|---|---|---|
| `startup_version` | `gdb --version` | GDB 版本横幅 = 18.1 |
| `symbol_load_1000` | `gdb -batch -ex 'info functions fn_00042' -ex quit symbols_1000`（交付代表负载形态） | `info functions` 输出中包含被查询的 `fn_00042` 符号行 |
| `symbol_load_50000` | `gdb -batch -ex 'info functions fn_49975' -ex quit symbols_50000` | 同上（`fn_49975`） |
| `breakpoint_set_200` | `gdb -batch -x breakpoints.cmd symbols_50000` | 日志中 `Breakpoint` 行数 = 200 |
| `step_500` | `gdb -batch -x steps.cmd steps_500` | `+step` 追踪行数 = 500 |
| `info_functions_10000` | `gdb -batch -ex 'info functions' symbols_10000 \| wc -l` | 行数 ≥ 10000 |
| `python_eval_5000` | `gdb -batch -x python_eval.py symbols_50000` | `[gdb-py-eval] looked_up=5000 found=5000` |
| `backtrace_deep_2000` | `gdb -batch -ex 'break crash_here' -ex run -ex bt deep_2000 \| wc -l` | 行数 ≥ 2000 |
| `core_backtrace_2000` | `gdb -batch -ex bt deep_2000 deep_2000.core \| wc -l` | 行数 ≥ 2000，core 文件存在且非空 |
| `upstream_testsuite_python` | `make check-gdb RUNTESTFLAGS="gdb.python/py-symbol.exp gdb.python/py-value.exp gdb.base/break.exp"` | `gdb.sum` 中 PASS ≥ 12、unexpected failures = 0、无 `FAIL:`/`ERROR:` 行 |

每个场景同时也是 2 个指标：`<场景>`（秒）与 `<场景>_rss`（MiB），共 20 个指标。

### 为什么这样设计

- **覆盖手册与交付负载，同时避免单点结论**：交付代表负载只测一次小程序的符号加载，
  本用例保留该形态（`symbol_load_1000`）并把符号规模扩到 5 万，另外覆盖断点插入、单步、
  符号遍历、Python API、深栈回溯、core 加载与上游 testsuite，避免把「符号加载快」直接
  当成「GDB 快」。
- **不启动 inferior 与启动 inferior 的场景分开报告**：`symbol_load_*`、`breakpoint_set_200`
  不启动 inferior，只测符号读取与断点插入；`step_500`、深栈与 core 场景才涉及 inferior。
  报告不把它们混为一个「断点延迟」。
- **上游负载同时是正确性门禁**：上游 testsuite 子集每个样本都要求 0 个 unexpected
  failures，若 GDB 被构建坏或被测坏，指标不会产生。
- **可复核的独立证据**：断点数、单步数、符号查找数、回溯行数都是日志里可数的事实，不是
  用期望值反推的结论；解析器发现证据不足、样本缺失、非 0 退出、超时、NaN/0 值时直接让
  测试阶段失败。

## 5. 采样、离线与指标

- 每个场景先执行 1 次预热（`runs/<场景>/warmup.{log,json}`，不计入统计），再执行
  `PERF_REPS` 次独立测量（默认 5，`runs/<场景>/rep<i>.{log,json}`）。
- 每个样本在独立子进程中执行，墙钟用单调时钟测量，RSS 取该子进程组的峰值
  `ru_maxrss`；样本之间不共享 GDB 进程，也不复用上一次的 `gdb.sum`（每次运行前删除）。
- 指标值取中位数，同时保存 `samples/min/max/mean/stdev`；不把分钟、百分比或吞吐量与耗时
  混排。
- 测量阶段离线：私有 `HOME`（不读取 `~/.gdbinit`）、`LC_ALL=C`、`TZ=UTC`、
  `DEBUGINFOD_URLS=""`（禁止 debuginfod 联网）、`http(s)_proxy` 指向不可达地址；
  构建阶段完成后测量阶段不再需要任何网络。
- `PERF_REPS` 可覆盖；`GDB_BUILD_JOBS` 可覆盖构建并行度（只影响构建耗时，不影响指标）。

## 6. 变体（optimized）

本用例没有「优化版」变体：被测对象是 GDB 对调试信息/断点的处理开销，给 GDB 自身换一个
`-O` 级别并不是对工作负载的优化。因此 `--variant optimized` 会打印明确原因并返回
**30**（「变体不可用」），且不会写出 `build_variant.json`；base 变体使用上游默认
`CFLAGS`（`-g -O2`）构建官方发行版。

## 7. 运行方式

独立复现（在用例目录的副本中也可运行）：

```bash
cd software/Toolchain/gdb
software/Toolchain/gdb/gdb_test.sh --results-dir /tmp/gdb-results
# 可选：PERF_REPS=5 GDB_BUILD_JOBS=8；--keep-workdir 保留工作目录排查
```

Framework 调用（GitHub Actions）：

```bash
python3 framework/run_case.py --case software/Toolchain/gdb/case.yaml \
  --version 18.1 --architecture aarch64 --run-id <run-id> --stage build
# 依次 start / test / stop / finalize
```

结果目录包含：`build_info.json`（Framework 的 7 个字段）、`build_provenance.json`
（源码 URL/SHA-256、签名摘要、configure 参数、构建分段耗时、宿主工具链）、
`results.json`（20 个指标的完整统计与参数）、`runs/`（每场景的原始日志与样本 JSON）、
`status.json`、`normalized_result.json`、`report.md`。

## 8. 架构中立性与证据边界

- `results.json.parameters` 只包含两端一致的值：版本、源码 SHA-256、configure 选项（不含
  绝对路径）、固定编译参数、fixture 的 SHA-256、各场景命令描述、固定 testsuite 列表与
  阈值、重复次数/预热次数、离线标记。两端的参数对象与
  `sha256({software, version, parameters})` 必须相等，`compare_pair` 才能配对。
- 只作为 evidence、绝不进入参数的：宿主编译器版本、编译后二进制与 core 的字节数/摘要、
  构建耗时、绝对工作目录、GDB 安装 prefix。这些值本身随架构与机器变化，进入参数会让
  跨架构比较失败。
- 不宣称的内容：未运行 GDB 全量 testsuite（只运行 3 个固定 `.exp`）；`breakpoint_set_200`
  不代表断点命中后被调试程序的执行速度；`step_500` 是 500 条单步命令的总墙钟，不是单条
  指令级延迟；`info_functions`/`bt` 的行数是证据，不把行数当指标；`core` 文件由本用例
  被测 GDB 自身生成，core 加载场景的耗时包含该 core 的解析成本。
- 噪声：所有场景串行执行；若同机还有其他构建/测试任务（例如并行验证其他软件），
  `build_*`-type 的毫秒级场景与上游 testsuite 场景可能出现可察觉的波动，报告保留全部样本
  以便复核；预热样本不参与统计，正式结论以中位数与样本分布为准。
- 该架构以外的机器只做功能与链路验证，不作为性能结论；正式性能证据来自 GitHub Actions
  `Blue: Manual performance evaluation` 的 aarch64 运行。
