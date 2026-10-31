# PHP 8.5.12 性能测试用例

本用例属于 **Toolchain** 类别，按仓库适配契约（`case.yaml` 的 shell-functions 六阶段：
prepare/build/start/test/stop/finalize）实现，输出 `build_variant.json`、`raw-output.log`、
`results.json` 与 `runs/` 原始样本。正式性能证据来自 GitHub Actions
`Blue: Manual performance evaluation` 的 aarch64 运行；本机 x86_64 只做功能与链路验证。

## 1. 版本与制品来源

| 项目 | 值 |
|---|---|
| 目标版本 | **PHP 8.5.12**（手册 `17-PHP.md` 指定的目标版本） |
| 版本/校验来源 | [php.net releases JSON](https://www.php.net/releases/index.php?json&version=8.5)（`source[].sha256`，核验日期 2026-10-30） |
| 官方源码包 | `https://www.php.net/distributions/php-8.5.12.tar.gz` |
| 源码 SHA-256 | `81a0f450349e84b08eb43faa85f8a4c835684f3cc1c50471775d1317a046c525` |
| 源码大小 | `24,469,403` 字节 |
| 构建依赖 | `gcc`、`make`（官方 release tarball 自带 `configure`，**不需要** re2c/bison/autoconf；`--disable-all` 也不需要 libxml2/sqlite 等扩展头文件） |
| 离线预置目录 | `/home/runner/software/php/php-8.5.12.tar.gz` |

官方 tarball 的校验值来自 php.net 发布的 releases JSON；构建阶段对下载/离线文件逐一核对 `sha256` 和 `24,469,403` 字节大小；不一致立即失败，不做静默降级。

**镜像说明（实测）**：准备阶段尝试过华为云、阿里云、腾讯云、清华 TUNA、中科大 USTC、
南大 NJU、搜狐的 PHP 镜像路径，均返回 404/403 或非压缩内容（例如
`mirrors.huaweicloud.com/php/php-8.5.12.tar.gz` 返回 12,434 字节的错误页）。因此本用例只固化
官方 php.net URL：在 CI 上优先使用 `/home/runner/software/php/` 的离线预置包；本机因 php.net
单线程限速约 400 KB/s，已用可恢复下载（`curl -C -`）取得并校验官方包。

## 2. 构建方式（固定口径）

手册要求「使用该发行源码 `Zend/bench.php`，CLI 最小构建 `--disable-all --enable-cli`」。
本用例固定为：

```bash
./configure --prefix=<workdir>/php-install \
    --disable-all --enable-cli --disable-opcache-jit
make -j"$(nproc)"
make install
```

- **不含** FPM、HTTP SAPI、CGI、第三方扩展；只有 Core/date/hash/json/lexbor/pcre/random/
  Reflection/SPL/standard/uri 等内置组件。
- **OPcache**：PHP 8.5 已把 Zend OPcache 编译进 CLI（`php -m` 显示 `Zend OPcache`，不存在
  独立的 `opcache.so`），因此 `--enable-opcache` 在 8.5 已不是有效 configure 选项；本用例用
  `--disable-opcache-jit` 在构建期固定关闭 JIT，测量时所有场景统一 `-n`（不读 php.ini），
  即 `opcache.enable_cli=0`，两端口径一致。
- 构建完成后执行 `php -v` 解析实际版本，必须等于 `8.5.12`，并写入
  `results/actual-version.txt`；`php -m` 必须包含 `Zend OPcache`。
- `build` 阶段同时生成 include 场景的确定性模块树（`scripts/generate_modules.py`，1000 个
  模块，每个 100 个纯函数 + 500 元素数组字面量），并对 CLI 启动与 include 负载做冒烟校验。

## 3. 完整口径矩阵（9 场景 × 2 指标）

每个场景先预热 1 次（不计入统计），再独立测量 5 次；报告值为 5 个样本的**中位数**，
`results.json` 同时保存全部样本与 min/max/mean/stdev。测量阶段完全离线（本用例没有网络调用）。

| # | 场景 | 维度 | 负载 | 规模 | 校验 |
|---|---|---|---|---|---|
| 1 | `cli_startup` | startup | 编译并执行 1 个最小脚本，测单个 CLI 进程从 fork 到退出的墙钟 | 1 进程 | 整数 `1` |
| 2 | `compute_nbody_100000` | compute | 5 体 n-body（仅 `+ - * / sqrt`），100000 步后的总能量 | 100000 步 | 浮点，`1e-9` 相对容差 |
| 3 | `compute_spectral_norm_400` | compute | 10 次 `A^T A` 幂迭代（N=400）的谱范数 | N=400 | 浮点，`1e-9` 相对容差 |
| 4 | `compute_fannkuch_9` | compute | Heap 算法枚举 n=9 全部 362880 个排列，煎饼翻转；校验和 = 最大翻转数 × 1e6 + 翻转总和 mod 1e6 | n=9 | 整数 `30911505` |
| 5 | `string_churn_400000` | strings | 生成 40 万个格式化字符串、`implode` 后 `crc32` | 400000 | 整数 `1259483823` |
| 6 | `array_hash_400000` | hashing | 40 万字符串键哈希表插入、遍历、局部改写后求和 | 400000 | 整数 `480001400000` |
| 7 | `include_modules_1000` | compile | include 1000 个生成模块（每个 100 函数 + 500 元素数组），调用每模块第 1 个函数并统计数组长度 | 1000 模块 | 整数 `1075312348280` |
| 8 | `upstream_zend_bench` | upstream | **php-src 自带** `Zend/bench.php`（18 个经典子项，来自同一官方 8.5.12 源码包） | 固定源码 | 日志含子项标记 `nestedloop` |
| 9 | `upstream_micro_bench` | upstream | **php-src 自带** `Zend/micro_bench.php`（35 个微基准子项，同一源码包） | 固定源码 | 日志含子项标记 `undef_func()` |

**固定测量条件**

- 每个样本 = 一个新 fork 的 PHP CLI 进程；`scripts/run_timed.py` 用 `time.monotonic` 测外层
  墙钟，用 GNU `time -f %M` 读取该进程峰值 RSS；不并发、不 pin CPU（与两端 CI 保持一致）。
- 统一运行参数：`php -n -d memory_limit=512M <script> <scenario> <scale>`；上游基准为
  `php -n <php-src>/Zend/bench.php`。`-n` 保证不加载任何 php.ini/opcache 配置。
- 任一 rep 退出码非零、超时、样本缺失、wall/RSS 非有限或非正、校验和不符，解析直接失败；
  没有补零、没有估算、没有用预置结果兜底。
- 浮点校验和只在同一版本、同一编译参数下跨架构比较，容差 `1e-9` 相对值（`sqrt` 在 glibc 上
  correctly-rounded，整数场景完全一致）。

**为什么这样设计（无上游完整套件）**

- 手册明确「公开套件/方法：PHP 源码 `Zend/bench.php`、`micro_bench.php`；指标：子项秒数↓；
  CLI 启动另列」。本用例把这两个上游基准作为 upstream 维度原样纳入，只取外层墙钟，脚本内部
  子项时间保留在 `runs/<scenario>/rep*.log`（满足「脚本内部子项也保留在日志」）。
- 上游基准子项是微秒级、且内部自带计时会受插桩影响，因此额外用仓库内自写、确定性、
  可校验的 n-body / spectral-norm / fannkuch / 字符串 / 哈希 / include 负载，覆盖计算、
  内存分配与哈希表、文件编译加载三类引擎路径；每个负载都输出可跨架构复核的校验和。
- **排除 OPcache CLI 开关维度**：本地实测（1000 个富模块）无缓存约 0.61 s、
  `opcache.file_cache_only=1` 首次热缓存后约 0.18 s，但缓存刚完成时的前几次运行分别出现
  0.97 s / 1.51 s，波动远大于 5 样本预算；该维度测到的是“缓存状态”而非引擎稳定性能，故不纳入
  矩阵，只在此说明。
- **排除 composer install 维度**：composer 与依赖缓存不在本交付的离线预置资产中，
  无法保证离线可复现，故不使用。

## 4. 指标与统计口径

- 每个场景 2 个指标：墙钟中位数（`s`，lower_is_better）、进程峰值 RSS 中位数（`MiB`，
  lower_is_better）；`results.json` 的 `results.<scenario>.{samples,min,max,mean,stdev,median}`
  保留全部统计量。
- RSS 只统计被测 PHP 进程本身（GNU `time %M`），不含 shell、wrapper、页面缓存等。
- `results.json.parameters` 记录实际构建参数、`-n`、`memory_limit`、include 模块数、
  上游基准来源、矩阵与维度；`inputs` 记录官方源码 URL/SHA-256/大小。
- 实际版本必须等于请求版本：`actual-version.txt` 写 `8.5.12`；框架 `build_info.json` 再记录一次。

## 5. 架构边界

- aarch64（鲲鹏 / Blue runner）为正式性能证据；x86_64 本机运行只用于验证适配契约、
  六阶段流程、校验和与可移植性，不作为性能结论。
- 上游 `Zend/bench.php` / `micro_bench.php` 为同一官方源码包内的文件，两端使用完全相同内容。

## 6. 运行方式

框架（推荐，等价于 CI）：

```bash
python3 framework/run_case.py \
  --case software/Toolchain/php/case.yaml \
  --version 8.5.12 --architecture aarch64 --run-id <run-id> --stage prepare|build|start|test|stop|finalize
```

独立入口（不依赖 `framework/`，可在仓库外运行）：

```bash
cd software/Toolchain/php
PERF_REPS=5 bash php_test.sh --results-dir /tmp/php-results
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`（`base`/`optimized`）、
`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`（默认 5）、`PHP_OFFLINE_DIR`、
`PERF_PHP_SOURCE_MIRROR`、`PHP_GENERATED_MODULES`（默认 1000）、`PHP_BUILD_JOBS`。
`optimized` 变体目前保留：显式返回 `30`，不写 `build_variant.json`，不回落 base。

## 7. 实测记录（x86_64，仅链路验证，2026-10-31）

框架六阶段运行（`PERF_REPS=5`，18 指标，status=passed；当班有其他交付校验任务并发，
下表为**中位数**，`results.json` 内有全样本）：

| 场景 | 墙钟中位数 (s) | 峰值 RSS 中位数 (MiB) |
|---|---:|---:|
| `cli_startup` | 0.0037 | 10.6 |
| `compute_nbody_100000` | 0.374 | 10.6 |
| `compute_spectral_norm_400` | 0.268 | 10.6 |
| `compute_fannkuch_9` | 0.378 | 10.6 |
| `string_churn_400000` | 0.114 | 151.7 |
| `array_hash_400000` | 0.064 | 42.1 |
| `include_modules_1000` | 0.365 | 123.7 |
| `upstream_zend_bench` | 0.214 | 16.0 |
| `upstream_micro_bench` | 1.016 | 10.7 |

- 手表对照：手册 111 机器上 `Zend_bench` 中位数 0.3230952 s / 3 样本；本用例固定构建参数与
  采样规则不同（5 样本、`-n`、JIT 关闭），该数值只作历史参考，**不迁移**为结论。
- 单架构运行时长（x86_64，20 核）：build ≈ 68 s（configure+make -j20+install+模块生成+冒烟），
  test（5 reps）≈ 21 s，六阶段合计 ≈ 90 s。aarch64 预计 3–6 分钟（官方 tarball 构建 +
  同一矩阵），`timeout_minutes: 240` 留有充分余量。

## 8. 故障排查

- **下载慢/失败**：php.net 单线程限速明显，使用 `curl -C -` 断点续传，或提前把
  `php-8.5.12.tar.gz` 放到 `/home/runner/software/php/`；校验不通过会立即失败，不会用坏包。
- **configure 失败**：先看 `build/configure.log`；本用例只需要 gcc/make，若系统缺 `time`
  包会在 `require_commands` 阶段补装（`/usr/bin/time` 是测 RSS 的硬依赖）。
- **include 场景失败**：确认 `PHP_MODULES_DIR` 指向构建阶段生成的模块目录（默认
  `<workdir>/generated/modules`），且模块数为 1000。
- **校验和不符**：说明源码/编译器/脚本被改动；`runs/<scenario>/rep*.log` 保留原始输出，
  直接对比 `RESULT scenario=... checksum=...` 行。
- **内存不足**：`string_churn`/`include` 需要约 150 MB/124 MB RSS；统一 `-d memory_limit=512M`，
  若 CI 内存更小请同步调整 `memory_limit` 并在 README 记录。

## 9. 许可证

- PHP 本身：PHP License 3.01（见官方源码包 `LICENSE`）。
- 本目录自写的 benchmark 脚本与生成器：跟随仓库既有用例的 MIT 许可；由
  `generate_modules.py` 生成的模块是一次性构建产物，不提交到仓库。
