# GNU libmpc 1.4.1 性能用例

## 1. 软件与版本

- 软件：GNU MPC（Multiple Precision Complex Library），基于 GMP 与 MPFR 的复数多精度库。
- 版本：**1.4.1**（`SOFTWARE_VERSION=1.4.1`）。
- 上游项目：<https://www.multiprecision.org/mpc/>，发布归档来自 GNU 主站 `https://ftp.gnu.org/gnu/mpc/`。
- 依赖：**GMP 6.3.0** 与 **MPFR 4.2.2**（均固定版本，构建到本用例自己的私有前缀，与 GMP/MPFR 用例互不共享）。
- 实测对象：固定口径 libmpc harness（`scripts/bench/mpc_bench.c`），只调用 MPC/MPFR/GMP 公共 API。

## 2. 上游制品与校验

| 制品 | 文件名 | SHA-256（固定） |
|---|---|---|
| libmpc 源码 | `mpc-1.4.1.tar.xz` | `91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931` |
| MPFR 依赖源码 | `mpfr-4.2.2.tar.xz` | `b67ba0383ef7e8a8563734e2e889ef5ec3c3b898a01d00fa0a6869ad81c6ce01` |
| GMP 依赖源码 | `gmp-6.3.0.tar.xz` | `a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898` |

下载顺序（每个来源都必须匹配同一 SHA-256）：

1. 预置离线目录：`${PERF_LIBMPC_OFFLINE_DIR:-/home/runner/software/libmpc}`（GMP/MPFR 归档还会查 `${PERF_MPFR_OFFLINE_DIR:-/home/runner/software/mpfr}` 与 `${PERF_GMP_OFFLINE_DIR:-/home/runner/software/gmp}`）；
2. 国内镜像 `mirrors.tuna.tsinghua.edu.cn/gnu/{mpc,mpfr,gmp}/`、`mirrors.huaweicloud.com/gnu/{mpc,mpfr,gmp}/`；
3. 官方 `ftp.gnu.org/gnu/...`、`ftpmirror.gnu.org/...`。

全部来源失败时 `build` 退出 **30**，并逐个打印尝试过的 URL 与失败原因。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成，与 `software/Database/mysql`、`software/Bigdata/ray`、`software/Others/unixbench`
使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再需要编译器与
`dnf` 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-libmpc-<arch>-<运行ID>`，标签 `boostkit.libmpc.run-id=<运行ID>`，使用
  宿主网络；读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，只读挂载用例目录（独立运行时
  例外），容器内路径与宿主完全相同，`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`make`、`m4`、`tar`、`xz`、`diffutils`、
  `findutils`、`coreutils`、`sed`、`gawk`、`grep`、`util-linux`、`file`、`binutils`、
  `glibc-devel` 与 `python3`；GMP、MPFR、libmpc 的解包、`configure`、`make`、
  `make install`、`mpc_bench` 编译、版本探测与计时包装（`scripts/run_timed.py`）全部在容器内
  执行。
- 宿主机：只负责下载并校验三个源码包（优先 `/home/runner/software/{libmpc,mpfr,gmp}/`）、
  读取容器内产生的头文件版本、严格解析 `benchmark_mpc.json` 与清理本任务的容器。结果解析器
  不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器会在
  下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 3. 安装与构建

全程在 `PERF_WORK_DIR` 内，**互不共享**私有前缀：

```text
${PERF_WORK_DIR}/src/gmp-6.3.0/      GMP 依赖源码
${PERF_WORK_DIR}/gmp-prefix/         GMP 私有前缀
${PERF_WORK_DIR}/src/mpfr-4.2.2/     MPFR 依赖源码
${PERF_WORK_DIR}/mpfr-prefix/        MPFR 私有前缀
${PERF_WORK_DIR}/src/mpc-1.4.1/      libmpc 源码
${PERF_WORK_DIR}/mpc-prefix/         libmpc 私有前缀
${PERF_WORK_DIR}/bin/mpc_bench       固定口径基准程序
```

步骤（`scripts/builders/base.sh`）：

1. 校验并解压 GMP 6.3.0，`./configure --prefix=.../gmp-prefix --disable-shared --enable-static`、`make -j4`、`make install`；
2. 校验并解压 MPFR 4.2.2，`./configure --prefix=.../mpfr-prefix --with-gmp=.../gmp-prefix --disable-shared`、`make -j4`、`make install`；
3. 校验并解压 libmpc 1.4.1，`./configure --prefix=.../mpc-prefix --with-gmp=.../gmp-prefix --with-mpfr=.../mpfr-prefix --disable-shared`、`make -j4`、`make install`；
4. 用 `mpc-prefix/include/mpc.h` 的 `MPC_VERSION_STRING` 核对版本（≠1.4.1 → 30），写入 `PERF_ACTUAL_VERSION_FILE`；
5. `gcc -O2` 编译 `scripts/bench/mpc_bench.c`，静态链接私有前缀的 `libmpc`/`libmpfr`/`libgmp`；
6. 冒烟运行一次 harness，确认链接到的 libmpc 版本。

构建依赖（`dnf`/`apt` 双分支 + 安装后逐个 `command -v` 自检）：`gcc`、`make`、`tar`、`xz`、`curl`、`coreutils`。

## 4. 完整测试口径

### 4.1 场景矩阵（8 个）

每个场景一次进程只测一个 routine + 一个精度；操作数为固定种子的 8 组随机复数（实部、虚部均在 `[0,1)` 后再平移到 `[0.5,1.5)`、`[-0.5,0.5)`），先校准到 ≥50 ms CPU 时间的迭代数，再测一次并报 `ops/s`。

| 场景 | routine | 精度（bit） | 说明 |
|---|---|---|---|
| `mpc_mul_256` | `mpc_mul` | 256 | 小精度复数乘法 |
| `mpc_mul_1024` | `mpc_mul` | 1024 | 中精度复数乘法 |
| `mpc_mul_4096` | `mpc_mul` | 4096 | 大精度复数乘法 |
| `mpc_sqr_1024` | `mpc_sqr` | 1024 | 复数平方 |
| `mpc_div_1024` | `mpc_div` | 1024 | 复数除法 |
| `mpc_pow_256` | `mpc_pow` | 256 | 复数幂（复指数） |
| `mpc_pow_1024` | `mpc_pow` | 1024 | 复数幂（复指数，大精度） |
| `mpc_exp_256` | `mpc_exp` | 256 | 复数指数 |

### 4.2 上游 tools/bench 的对应关系

libmpc 自带 `tools/bench`（`mpcbench`，`make bench` 构建）。它**不支持选择算子/精度**，一次运行会跑完固定的全部算子集合，无法支撑"每场景 1 预热 + 5 次独立测量"。因此本用例用同口径 harness：

- 同样的随机操作数、同样的 CPU 时间度量（`CLOCK_PROCESS_CPUTIME_ID`）、同样以 ops/s 为单位；
- 区别只有"可选择一个 routine + 一个精度"和"单次运行时间有界（约 50 ms 校准 + 一次测量）"；
- harness 只调用公共 API（`mpc_mul`/`mpc_sqr`/`mpc_div`/`mpc_pow`/`mpc_exp`）。

### 4.3 预热与测量

- 每场景 **1 次预热** + **≥5 次独立测量**（`PERF_REPS`，默认 5），每次测量都是独立进程；
- `scripts/run_timed.py` 记录墙钟与子进程峰值 RSS，原始输出全文写入 `runs/<scenario>/rep<i>.log`；
- 测量阶段**离线**：制品在 build 阶段下载并校验，test 阶段不访问网络。

### 4.4 严格解析

`scripts/results/parse_benchmark.py` 要求：预热与全部重复样本存在；`exit_code == 0` 且未超时；日志中**恰好一行** `RESULT`，其 routine/precision 必须等于场景声明；`iterations ≥ 1`、`cpu_seconds > 0`、`ops_per_second` 为正有限数且 < 1e12。任一条件不满足 → `test` 退出 **50**，并打印对应日志尾部 40 行；不补零、不插值、不估算。

### 4.5 原始证据

```text
runs/<scenario>/warmup1.log    harness 原始输出（含 VERSION 行与 RESULT 行）
runs/<scenario>/warmup1.json   墙钟与峰值 RSS
runs/<scenario>/rep<i>.log     第 i 次测量原始输出
runs/<scenario>/rep<i>.json    第 i 次测量的墙钟与峰值 RSS
raw-output.log                 全部场景×全部样本的合并原始输出
benchmark_mpc.json             聚合结果（每指标含全部样本与统计量）
```

## 5. 指标（8 场景 × 4 = 32 个）

| 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<scenario>.ops_per_second` | ops/s | 越高越好 | harness 测得的每秒操作数（中位数） |
| `<scenario>.ns_per_op` | ns/op | 越低越好 | `1e9 / ops_per_second`（中位数） |
| `<scenario>.wall_seconds` | s | 越低越好 | 进程墙钟（含启动、随机数生成、校准） |
| `<scenario>.peak_rss_mib` | MiB | 越低越好 | 进程峰值 RSS |

每个指标保留全部样本与 `min/max/mean/median/stdev`，报告值为中位数；`iterations` 与 `cpu_seconds_samples` 也记录在 `benchmark_mpc.json` 中便于核对测量窗口。

## 6. 架构与证据边界

- 支持 `x86_64`/`aarch64`：三个包的 `configure` 原生检测 CPU；`EXPECTED_ARCH` 与实际 `uname -m` 不一致时 `build` 退出 **20**。
- 本机（WSL Ubuntu-22.04 x86_64）数字仅代表该机器；Runner 结果以 Actions 产物为准。
- 测量的是 libmpc 单线程复数算术吞吐，CPU 绑定/频率策略会影响绝对值；`ops/s` 来自进程 CPU 时间（不受调度等待影响），`wall_seconds` 才包含调度等待。
- 精度和操作数已固定，但 GMP/MPFR 版本会显著影响 libmpc 性能；本用例固定 GMP 6.3.0 + MPFR 4.2.2。

## 7. 运行方式

### 7.1 框架六阶段

```bash
SOFTWARE_VERSION=1.4.1 PERF_REPS=5 python3 framework/run_case.py \
  --case software/Toolchain/libmpc/case.yaml \
  --version 1.4.1 --architecture x86_64 --run-id local-libmpc --stage prepare
```

### 7.2 独立运行

```bash
software/Toolchain/libmpc/libmpc_test.sh --version 1.4.1 --variant base --results-dir /tmp/libmpc-results
```

### 7.3 环境变量

| 变量 | 说明 |
|---|---|
| `SOFTWARE_VERSION` | 只支持 `1.4.1` |
| `PERF_REPS` | 测量重复次数，默认 5（≥5 才满足口径） |
| `PERF_LIBMPC_JOBS` | 构建并行度，默认 4 |
| `PERF_LIBMPC_OFFLINE_DIR` | libmpc 离线目录，默认 `/home/runner/software/libmpc` |
| `PERF_MPFR_OFFLINE_DIR` / `PERF_GMP_OFFLINE_DIR` | 依赖离线目录 |
| `PERF_VARIANT` | `base`（唯一实现）或 `optimized`（显式失败） |

### 7.4 负向验证

`PERF_VARIANT=optimized` 时 `optimized.sh` 只打印错误并 `return 30`，**不**写 `build_variant.json`。

## 8. 故障排查

| 现象 | 处理 |
|---|---|
| `cannot obtain mpc-1.4.1.tar.xz` | 检查网络/代理；放进 `${PERF_LIBMPC_OFFLINE_DIR}`；日志列出全部尝试 URL |
| `cannot obtain mpfr-4.2.2.tar.xz` / `gmp-6.3.0.tar.xz` | 同上，依赖归档查找顺序为 libmpc 离线目录 → 依赖离线目录 → 镜像 → 官方 |
| `SHA-256 mismatch` | 下载截断或镜像被改写；删除 `.part` 重试或换离线目录 |
| `configuring libmpc ... failed` | 看 `logs/configure.log` 尾部 40 行；确认 GMP/MPFR 前缀已安装（`logs/mpfr-*.log`、`logs/gmp-*.log`） |
| `compiling the libmpc benchmark harness failed` | 看 `logs/bench-build.log`；检查 `mpc-prefix/include/mpc.h` 与静态库 |
| `built libmpc reports X, requested 1.4.1` | 归档不是 1.4.1，或 `--with-gmp/--with-mpfr` 指向错误前缀 |
| `must contain exactly one RESULT line` | harness 输出被截断/被额外输出污染；看 `runs/<scenario>/rep1.log` |

## 9. 许可证

libmpc 使用 GNU LGPL v3+；MPFR 使用 GNU LGPL v3+；GMP 使用 GNU LGPL v3（部分 GPL v2/v3）。本用例只下载并构建上游归档，不分发其二进制。
