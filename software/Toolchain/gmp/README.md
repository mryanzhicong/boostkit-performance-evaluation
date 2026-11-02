# GNU GMP 6.3.0 性能用例

## 1. 软件与版本

- 软件：GNU GMP（GNU Multiple Precision Arithmetic Library），多精度整数/有理数/浮点运算库。
- 版本：**6.3.0**（`SOFTWARE_VERSION=6.3.0`，用例声明的唯一版本）。
- 上游项目：<https://gmplib.org/>，发布归档来自 GNU 主站 `https://ftp.gnu.org/gnu/gmp/`。
- 实测对象：上游自带的 `tune/speed` 基准程序（源码位于 `tune/speed.c`），以固定 routine + 固定操作数尺寸逐项测量。

## 2. 上游制品与校验

| 制品 | 文件名 | SHA-256（固定） |
|---|---|---|
| 源码归档 | `gmp-6.3.0.tar.xz` | `a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898` |

下载顺序（任一来源都必须匹配同一 SHA-256，否则继续下一个）：

1. 预置离线目录 `${PERF_GMP_OFFLINE_DIR:-/home/runner/software/gmp}/gmp-6.3.0.tar.xz`；
2. 国内镜像 `mirrors.tuna.tsinghua.edu.cn/gnu/gmp/`、`mirrors.huaweicloud.com/gnu/gmp/`；
3. 官方 `ftp.gnu.org/gnu/gmp/`、`ftpmirror.gnu.org/gmp/`。

全部来源失败时 `build` 退出 **30**，并把每个尝试过的 URL（以及失败原因）打印到 job 日志。

## 3. 安装与构建

构建全程在 `PERF_WORK_DIR` 内完成，**不写系统目录、不修改宿主 GMP**：

```text
${PERF_WORK_DIR}/src/gmp-6.3.0/      解压后的上游源码树
${PERF_WORK_DIR}/prefix/             GMP 私有安装前缀（include/、lib/）
```

步骤（`scripts/builders/base.sh`）：

1. 校验并解压 `gmp-6.3.0.tar.xz`；
2. `./configure --prefix=${PERF_WORK_DIR}/prefix --disable-shared --enable-static`；
3. `make -j${PERF_GMP_JOBS:-4}`（日志 `logs/make.log`）；
4. `make -C tune speed`（构建上游基准，日志 `logs/speed-build.log`）；
5. `make install`（日志 `logs/install.log`）；
6. 用源码树 `gmp.h` 中的 `__GNU_MP_VERSION*` 宏核对实际版本，写入 `PERF_ACTUAL_VERSION_FILE`；不等于请求版本时 `build` 退出 **30**。

依赖（构建期，`dnf`/`apt` 双分支，安装后逐个 `command -v` 自检）：`gcc`、`make`、`tar`、`xz`、`curl`、`coreutils`（`sha256sum`/`awk`/`sed`）。GMP 自身不依赖第三方库。

## 4. 完整测试口径

### 4.1 场景矩阵（9 个，全部来自上游 `tune/speed`）

每个场景一次进程只测 **一个 routine + 一个操作数尺寸**，避免 `speed` 在多尺寸模式下的内部换算影响可比性。尺寸单位与上游 `-s` 一致：`mpn_*` 为 limb 数，`mpz_*` 为 bit 数。

| 场景 | routine | `-s` | 单位 | 说明 |
|---|---|---|---|---|
| `mpn_mul_n_512` | `mpn_mul_n` | 512 | limbs | 低层乘法（小操作数，基线） |
| `mpn_mul_n_2048` | `mpn_mul_n` | 2048 | limbs | 低层乘法（中操作数，Karatsuba 区间） |
| `mpn_mul_n_8192` | `mpn_mul_n` | 8192 | limbs | 低层乘法（大操作数，Toom/FFT 区间） |
| `mpn_sqr_4096` | `mpn_sqr` | 4096 | limbs | 低层平方 |
| `mpn_add_n_8192` | `mpn_add_n` | 8192 | limbs | 低层加法（内存带宽基线） |
| `mpn_div_qr_2n_2048` | `mpn_div_qr_2n` | 2048 | limbs | 低层除法（2n 除以 n，中操作数） |
| `mpn_div_qr_2n_8192` | `mpn_div_qr_2n` | 8192 | limbs | 低层除法（2n 除以 n，大操作数） |
| `mpz_add_2048` | `mpz_add` | 2048 | bits | 高层整数加法（中操作数） |
| `mpz_add_8192` | `mpz_add` | 8192 | bits | 高层整数加法（大操作数） |

### 4.2 预热与测量

- 每场景 **1 次预热**（`runs/<scenario>/warmup1.{log,json}`）+ **≥5 次独立测量**（`rep1..repN`，`PERF_REPS` 控制，默认 5）。
- **收敛重试**：`tune/speed` 每次测量要求 4 个计时值落在 1% 内，否则上游自己放弃该次测量并打印 `n/a`（`speed_measure() could not get 4 results within 1.0%`）。在共享/繁忙主机上这属于测量失败而非被测程序异常，因此用例对**同一次重复**最多重试 `PERF_GMP_ATTEMPTS`（默认 6）次；只有上游未产生数值时才重试，不挑选数值，重试过程以 `<label>.attempt<i>.{log,json}` 留档，最终记录的墙钟/RSS 属于被采纳的那次尝试。全部尝试仍失败 → `test` 退出 **50**。
- 每次测量都是**独立进程**，由 `scripts/run_timed.py` 包一层：记录墙钟（`wall_seconds`）与子进程峰值 RSS（`max_rss_mib`），原始 stdout/stderr 全文写入 `rep<i>.log`。
- 测量阶段**离线**：制品在 `build` 阶段下载并校验，`test` 阶段不再访问网络。

### 4.3 严格解析

`scripts/results/parse_benchmark.py` 逐场景读取全部样本，并要求：

- 预热与全部重复样本存在（缺任一 → 失败）；
- 每个样本 `exit_code == 0` 且未超时；
- 日志中存在且仅存在一行 `<size> <seconds>` 数据行，`size` 必须等于场景声明值，`seconds` 必须为 `(0, 60)` 内的有限数；
- 墙钟、RSS 为正有限数。

任一条件不满足 → 解析器非零 → `test` 退出 **50**（不补零、不插值、不估算）。失败时 job 日志打印对应 `runs/<scenario>/<label>.log` 尾部 40 行。

### 4.4 原始证据

```text
runs/<scenario>/warmup1.log   上游 tune/speed 原始输出
runs/<scenario>/warmup1.json  墙钟与峰值 RSS
runs/<scenario>/rep<i>.log    第 i 次测量的原始输出
runs/<scenario>/rep<i>.json   第 i 次测量的墙钟与峰值 RSS
raw-output.log                全部场景×全部样本的合并原始输出
benchmark_gmp.json            聚合结果（每个指标含全部样本与统计量）
```

## 5. 指标（9 场景 × 4 = 36 个）

| 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<scenario>.ops_per_second` | ops/s | 越高越好 | 上游报告的单次调用耗时的倒数（中位数） |
| `<scenario>.ns_per_op` | ns/op | 越低越好 | 上游报告的单次调用耗时（中位数） |
| `<scenario>.wall_seconds` | s | 越低越好 | 整个 `speed` 进程的墙钟（含进程启动/数据生成开销） |
| `<scenario>.peak_rss_mib` | MiB | 越低越好 | `speed` 进程峰值 RSS |

每个指标都保留**全部样本**、`min/max/mean/stdev`，报告值为**中位数**。

## 6. 架构与证据边界

- 支持 `x86_64` 与 `aarch64`：GMP 的 `configure` 原生检测 CPU 并启用对应汇编（x86_64 为 `mpn/x86_64`，aarch64 为 `mpn/arm64`）；`EXPECTED_ARCH` 与实际 `uname -m` 不一致时 `build` 退出 **20**。
- 本机（WSL Ubuntu-22.04，x86_64）验证数字只代表该机器；Runner 结果以 Actions 产物为准。
- 测量的是 **GMP 库本身的算术吞吐**（CPU 密集型、单线程），不含 I/O、网络与多进程扩展性；同机不同负载会影响绝对值，因此必须看同一轮内的场景相对关系。
- GMP `tune/speed` 的计时精度由上游自行标定（日志首行 `overhead ... precision ... CPU freq ...` 记录该标定结果），本用例直接采用上游报告值，不做二次换算。

## 7. 运行方式

### 7.1 框架六阶段

```bash
SOFTWARE_VERSION=6.3.0 \
PERF_REPS=5 \
python3 framework/run_case.py \
  --case software/Toolchain/gmp/case.yaml \
  --version 6.3.0 --architecture x86_64 \
  --run-id local-gmp --stage prepare
# 依次执行 build / start / test / stop / finalize
```

### 7.2 独立运行

```bash
software/Toolchain/gmp/gmp_test.sh --version 6.3.0 --variant base --results-dir /tmp/gmp-results
```

### 7.3 环境变量

| 变量 | 说明 |
|---|---|
| `SOFTWARE_VERSION` | 只支持 `6.3.0` |
| `PERF_REPS` | 测量重复次数，默认 5（≥5 才满足口径） |
| `PERF_GMP_JOBS` | 构建并行度，默认 4 |
| `PERF_GMP_OFFLINE_DIR` | 预置离线目录，默认 `/home/runner/software/gmp` |
| `PERF_GMP_ATTEMPTS` | 单次重复的最大尝试次数，默认 6（仅对上游 `n/a` 收敛失败重试） |
| `PERF_VARIANT` | `base`（唯一实现）或 `optimized`（显式失败） |

### 7.4 负向验证

`PERF_VARIANT=optimized` 时 `optimized.sh` 只打印错误并 `return 30`，**不**写 `build_variant.json`，防止回退到基础版。

## 8. 故障排查

| 现象 | 处理 |
|---|---|
| `cannot obtain gmp-6.3.0.tar.xz` | 检查网络/代理；把归档放进 `${PERF_GMP_OFFLINE_DIR}`；日志会列出全部尝试过的 URL |
| `SHA-256 mismatch` | 下载被截断或镜像被改写；删除 `.part` 后重试，或换离线目录 |
| `GMP configure failed` | 看 `logs/configure.log` 尾部（会自动打印 40 行）；常见原因是缺 `gcc`/`make`/`xz` |
| `building GMP tune/speed failed` | `tune/speed.c` 需要完整构建产物；确认 `logs/make.log` 无错误后再看 `logs/speed-build.log` |
| `built GMP reports X, requested 6.3.0` | 源码树 `gmp.h` 版本宏不符，说明归档不是 6.3.0 |
| `must contain exactly one '<size> <seconds>' data line` | `speed` 参数或输出格式变化；检查 `runs/<scenario>/rep1.log` |

## 9. 许可证

GMP 使用 GNU LGPL v3（部分文件为 GPL v2/v3）。本用例只下载并构建上游归档，不分发其二进制。
