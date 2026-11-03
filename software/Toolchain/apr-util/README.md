# APR-util 1.6.5 base64 编解码性能测试

本用例在 `x86_64`、`aarch64` Runner 上从官方源码构建 **APR 1.7.5** 与
**APR-util 1.6.5** 静态库，然后用**只调用公开 API 的用例自带 harness** 测量两件事：

1. 公开的 base64 编解码器：`apr_base64_encode_len` / `apr_base64_encode_binary` 与
   `apr_base64_decode_len` / `apr_base64_decode_binary`，覆盖 64 B、1 KiB、64 KiB、
   1 MiB 四种负载；
2. 上游自带的可移植测试程序 `test/testall`，作为其余 APR-util 功能的正确性锚点
   （字符串匹配、URI、UUID、桶、密码哈希、MD4/MD5/SHA1、DBD/DMB、日期、XML、编码转换、
   队列、资源池、SipHash 等 19 个模块）。

目标是让两架构在**同一份源码、同一组确定性负载、同一套调用方式、同一构建参数**下比较
base64 编解码吞吐、进程墙钟时间与峰值内存。APR-util 的可选外部依赖（LDAP、MySQL、
PostgreSQL、SQLite、ODBC、Oracle、OpenSSL/crypto、gdbm、ndbm、Berkeley DB）全部关闭；
APR-util 1.6.5 无法关闭 expat，因此使用源码包内**自带的 expat**，构建完全自包含。

入口为 `apr-util_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止
阶段；直接执行入口脚本也走同一组阶段。公共常量与候选 URL 在 `scripts/common.sh`，
测量包装在 `scripts/run_timed.py`，每次重复的输出校验在 `scripts/verify_outputs.py`，
结果解析与报告在 `scripts/results/`。工作流可选择 `base` 或 `optimized`，默认 `base`；
`optimized` 构建尚未实现，选择后会在 build 阶段明确失败（退出码 30），不会回退到
`base`，也不会写出 `build_variant.json`。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| APR | [Apache APR 1.7.5](https://archive.apache.org/dist/apr/apr-1.7.5.tar.bz2) 源码包 `apr-1.7.5.tar.bz2` | 优先读取 `/home/runner/software/apr-util/apr-1.7.5.tar.bz2`，缺失时按候选顺序下载；解压到 `${PERF_WORK_DIR}/apr-src/` |
| APR-util | [Apache APR-util 1.6.5](https://archive.apache.org/dist/apr/apr-util-1.6.5.tar.bz2) 源码包 `apr-util-1.6.5.tar.bz2` | 同上目录；解压到 `${PERF_WORK_DIR}/apr-util-src/` |
| 被测库 | 静态库 `libapr-1.a` 与 `libaprutil-1.a`（安装前缀 `${PERF_WORK_DIR}/apr-install/`） | `apr-install/lib/` |
| base64 harness | 本用例自带 `bench/base64_bench.c`，只调用公开 API | `${PERF_WORK_DIR}/apr-util-bench/base64_bench` |
| 上游测试程序 | 源码包内未修改的 `test/testall`（在源码树中构建） | `${PERF_WORK_DIR}/apr-util-src/test/testall` |
| 离线命名空间启动器 | 本用例自带 `bench/netns_loopback_up.c`，在 `unshare -n` 内拉起 `lo` 后 `exec` 被测命令 | `${PERF_WORK_DIR}/apr-util-bench/netns_loopback_up` |
| 负载生成器 | 本用例自带 `scripts/fixtures/generate_payloads.py`（固定种子 splitmix64） | `${PERF_WORK_DIR}/fixtures/` |

所有构建依赖都由任务专属容器内的 `dnf` 安装：`gcc`、`gcc-c++`、`make`、`tar`、
`bzip2`、`diffutils`、`coreutils`、`findutils`、`sed`、`gawk`、`grep`、`util-linux`、
`file`、`glibc-devel`、`expat-devel`、`binutils`、`python3`；安装失败则 build 阶段返回 30。
宿主机只保留 Docker、下载/校验工具（`curl`、`sha256sum`、`tar`、`python3`）与结果解析器。
构建只需要 C 工具链与系统 C 库，不需要任何外部服务或数据库。

以下称 Framework 传给脚本的工作目录为 `${PERF_WORK_DIR}`；独立运行时默认位于
`/home/runner/boostkit-perf/apr-util/<运行ID>/`。源码、构建、负载与临时文件都放在该
目录下；结果写入单独的 `${RESULTS_DIR}`。构建期完成源码下载与校验，测量期所有场景都在
`unshare -n` 新建的网络命名空间内执行，不访问网络。

## 获取、构建与安装

每个源码包都先从 `/home/runner/software/apr-util/` 读取；没有时依次尝试
`https://archive.apache.org/dist/apr/` 与 `https://dlcdn.apache.org/apr/`。无论来源，
解压前都必须匹配下表的 SHA-256 与字节数。

| 源码包 | SHA-256 | 字节数 |
|---|---|---|
| `apr-1.7.5.tar.bz2` | `cd0f5d52b9ab1704c72160c5ee3ed5d3d4ca2df4a7f8ab564e3cb352b67232f2` | 898264 |
| `apr-util-1.6.5.tar.bz2` | `96de1dd6f6a0476d2d2e7964926d8c1ddc3bb0e210e1b1812d3ba5a454a392e2` | 442045 |

两个候选（离线目录、`archive.apache.org`、`dlcdn.apache.org`）共用同一 SHA-256 与
字节数；任一候选验证失败即丢弃并继续下一个；全部失败时 build 阶段返回 30，打印完整
候选清单与失败原因。Runner 网络不通时请由发布流程把两个源码包预放到
`/home/runner/software/apr-util/`。

构建命令固定如下（不追加 `-march=native` 等机器相关选项）：

```bash
cd "${PERF_WORK_DIR}/apr-src"
CFLAGS="-O2 -DNDEBUG" ./configure --prefix="${APR_PREFIX}" \
    --disable-shared --enable-static
make -j"${PERF_APR_UTIL_BUILD_JOBS}"
make install

cd "${PERF_WORK_DIR}/apr-util-src"
CFLAGS="-O2 -DNDEBUG" ./configure --prefix="${APR_PREFIX}" \
    --with-apr="${APR_PREFIX}" \
    --disable-shared --enable-static \
    --without-ldap --without-mysql --without-pgsql --without-sqlite3 \
    --without-sqlite2 --without-odbc --without-oracle \
    --without-openssl --without-crypto \
    --without-gdbm --without-ndbm --without-berkeley-db
make -j"${PERF_APR_UTIL_BUILD_JOBS}"
make install

cd "${PERF_WORK_DIR}/apr-util-src/test"
make testall
```

说明：

- APR 1.7.5 先构建并安装到 `${APR_PREFIX}`，APR-util 通过 `--with-apr` 链接它；
  两者都是静态库，harness 与 testall 使用同一份构建产物。
- APR-util 1.6.5 的 `configure` 不接受 `--disable-shared/--enable-static`（会给出
  “unrecognized options” 警告），但静态库 `.a` 始终会构建；该警告不影响结果。
- `test/testall` 必须在 `test/` 目录下运行（`testxml` 等模块按相对路径读取数据），
  因此测量时用 `run_timed.py --cwd` 指定工作目录。这也是一处上游行为，用例未做修改。
- 版本自检：harness `--version` 输出 `apu=1.6.5 apr=1.7.5`；APR-util 版本必须等于请求
  版本，APR 必须是固定 pin 的 1.7.5，否则 build 返回 30。版本、两个源码包摘要、configure
  选项、优化参数、编译器与各 harness 路径写入
  `${PERF_WORK_DIR}/state/build-provenance.txt`。
- `PERF_APR_UTIL_BUILD_JOBS` 默认 8，本机与其他任务并行时用 `-j4`。

## 测试数据

负载由 `scripts/fixtures/generate_payloads.py` 用固定种子（`20261102`）的 splitmix64
字节流生成，与机器无关；start 阶段每次重新生成，并逐个比对下表字节数与 SHA-256，任一
不一致即 start 返回 20。生成器同时写出 `payloads.json`，start 与解析器再与
`common.sh` 中固化的常量交叉校验。

| 文件 | 内容 | 字节数 | SHA-256 |
|---|---|---|---|
| `payload_64.bin` | 64 B 伪随机负载 | 64 | `cb42edf62dc3629773106aa8b0797a977b2cb1decab8d4ba267200c25c42c9de` |
| `payload_1024.bin` | 1 KiB 伪随机负载 | 1024 | `ad6b5ef2138fee2f4e3804413a59bb6630de5618c199da967c414b0f84989193` |
| `payload_65536.bin` | 64 KiB 伪随机负载 | 65536 | `9d86408ce481394c9eb77a3869803d473e602024a0d94a1ffa0995bda0251f15` |
| `payload_1048576.bin` | 1 MiB 伪随机负载 | 1048576 | `bccd1a6e54881be19a93a1afa5ed4e369f8ca6b870d429cd45d0153617e179d0` |

## 测试场景

共 9 个场景、3 个指标组。所有场景在测量期都是单进程、单线程、无网络；每个场景先跑
1 次 warm-up，再跑 `PERF_REPS` 次独立重复。

| 场景 | 组 | 负载 | 循环次数 | 校验 |
|---|---|---|---|---|
| `base64_encode_64b` | `base64_encode` | 64 B payload | 20,000,000 | 编码长度 = 89，输出字节数 = 88×循环数，roundtrip |
| `base64_encode_1kib` | `base64_encode` | 1 KiB payload | 1,000,000 | 编码长度 = 1369，输出字节数 = 1368×循环数，roundtrip |
| `base64_encode_64kib` | `base64_encode` | 64 KiB payload | 24,000 | 编码长度 = 87385，输出字节数 = 87384×循环数，roundtrip |
| `base64_encode_1mib` | `base64_encode` | 1 MiB payload | 1,200 | 编码长度 = 1398105，输出字节数 = 1398104×循环数，roundtrip |
| `base64_decode_64b` | `base64_decode` | 64 B payload 的编码串 | 16,000,000 | 解码长度 = 64，解码字节数 = 64×循环数，roundtrip |
| `base64_decode_1kib` | `base64_decode` | 1 KiB payload 的编码串 | 800,000 | 解码长度 = 1024，解码字节数 = 1024×循环数，roundtrip |
| `base64_decode_64kib` | `base64_decode` | 64 KiB payload 的编码串 | 15,000 | 解码长度 = 65536，解码字节数 = 65536×循环数，roundtrip |
| `base64_decode_1mib` | `base64_decode` | 1 MiB payload 的编码串 | 800 | 解码长度 = 1048576，解码字节数 = 1048576×循环数，roundtrip |
| `upstream_testall` | `upstream_suite` | 上游 `test/testall` 全部可移植模块（19 个） | 1 | 通过模块数 = 19、失败 = 0、出现 `All tests passed.` |

编码长度按上游 `apr_base64_encode_len()` 的定义推导：`((len + 2) / 3 * 4) + 1`，
即**包含结尾 NUL**；`apr_base64_encode_binary()` 的返回值就是这个长度。吞吐指标只统计
负载字节数，不含 NUL。解码场景在测量窗口前先把 payload 编码一次，窗口内只重复解码。

harness 自己打印 `mode=/payload_bytes=/loops=/...` 汇总行和 `PERF-CHECK`/`PERF-RESULT`
行；`scripts/verify_outputs.py` 在测量窗口结束后立即用 `common.sh` 的固化常量重新推导
期望值并写 `runs/<scenario>/rep<i>.check`，解析器再逐项核对，因此“负载被截断”“循环次数
被改动”“roundtrip 失败”“testall 少跑模块”都会在解析阶段失败，而不是被当成一次有效
测量。

`unshare -n` 新建的网络命名空间里 `lo` 默认是 DOWN，而上游 `testall` 的 memcache /
redis 连接测试需要 `127.0.0.1` 的行为与正常系统一致，因此 `run_timed.py --offline` 会在
命名空间内先执行 `netns_loopback_up` 把 `lo` 拉起，再 `exec` 被测程序；命名空间里没有
其他接口，离线保证不变。

## 指标与统计

每个场景产生三类指标：

| 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<scenario>_wall_s` | s | 越低越好 | 被测子进程的墙钟时间，`time.monotonic()` 围绕 `Popen` 与 `wait` 测量 |
| `<scenario>_rss_mib` | MiB | 越低越好 | 被测子进程的峰值常驻内存，轮询 `/proc/<pid>/status` 的 `VmHWM`（5 ms 间隔） |
| `base64_{encode,decode}_<size>_mib_per_second` | MiB/s | 越高越好 | 负载字节数 × 循环次数 / 墙钟时间 |
| `upstream_testall_tests_passed` | modules | 越高越好 | 上游 testall 通过的模块数，固定为 19 |

每个指标都保留 `median`、`mean`、`min`、`max`、`stdev` 与全部 `samples`。比较用中位数，
样本数 = `PERF_REPS`；正式证据要求 `PERF_REPS >= 5`，`PERF_REPS=1` 仅用于本地链路自检。
峰值内存不用 `getrusage(RUSAGE_CHILDREN)`：从较大的 Python 解释器 fork 出来的子进程会
继承父进程的常驻页，`VmHWM` 属于 `exec` 之后程序自身的地址空间，是更诚实的口径；唯一的
底噪是 `unshare` + 启动器自身的少量页，约 0.6–0.7 MiB。

解析器是严格的：场景集合必须与声明完全一致；每个声明的重复必须有 `rep<i>.json`、
`rep<i>.log`、`rep<i>.check`；子进程必须退出码 0、未超时；每个 check 必须 `ok` 且与固化
期望值一致；每个指标必须有限且为正。任何一项不满足都直接失败（test/stop 阶段退出码 50），
不插值、不补零、不跳过。

## 运行方式

Framework 方式（仓库根目录）：

```bash
python3 framework/run_case.py --case software/Toolchain/apr-util/case.yaml \
    --version 1.6.5 --architecture x86_64 --run-id local-1 --stage build
# 之后依次执行 --stage start / test / stop / finalize
```

独立运行方式（不需要 Framework）：

```bash
bash software/Toolchain/apr-util/apr-util_test.sh --version 1.6.5 \
    --results-dir /home/runner/boostkit-perf/apr-util-results
```

常用环境变量：`PERF_REPS`（默认 5）、`PERF_VARIANT`（`base`/`optimized`）、
`PERF_APR_UTIL_BUILD_JOBS`（默认 8）、`PERF_APR_UTIL_OFFLINE_DIR`、
`PERF_APR_UTIL_MIRROR`、`PERF_APR_UTIL_ALLOW_ONLINE_MEASUREMENT`（仅在 `unshare -n`
不可用时用于本地诊断，默认 0，即测量期必须离线）。`--keep-workdir` 可保留工作目录排查。

## 容器化执行

每个阶段都在**本次任务专属的 openEuler 24.03 LTS SP4 容器**内执行，宿主机只负责
Docker、源码包的下载/SHA-256 校验、Framework 与严格解析器。容器由
`scripts/common.sh` 里的统一运行时块管理（由 `adaptation/scripts/add-container-block.py`
生成，勿手工编辑标记区）：

- **镜像**：`/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`；
  本地归档优先，缺失时才从 `repo.openeuler.org` 下载。加载前校验 `.sha256sum`、镜像
  架构（`x86_64`→`amd64`、`aarch64`→`arm64`）与 `/etc/os-release` 中的 `24.03`。
- **容器名/标签**：`boostkit-apr-util-<arch>-<run-id>`，标签
  `boostkit.apr_util.run-id=<run-id>`；删除前校验标签，拒绝删除其他任务的容器（返回 60）。
- **挂载**：`PERF_WORK_DIR`、`RESULTS_DIR` 与用例目录（只读）按**相同绝对路径**挂入，
  因此容器内外路径一致；另挂 `/etc/passwd`、`/etc/group` 以保留 runner 的 UID/GID。
- **特权**：`APR_UTIL_CONTAINER_EXTRA_ARGS=(--cap-add=SYS_ADMIN --cap-add=NET_ADMIN)`。
  测量要求每条样本在 `unshare -n` 新建的网络命名空间里运行：创建命名空间需要
  `CAP_SYS_ADMIN`，而新命名空间里 `lo` 默认是 DOWN，拉起它（`SIOCSIFFLAGS`）还需要
  `CAP_NET_ADMIN`——两者缺一都会让上游 `testall` 的连接错误路径用例静默失败。start 阶段
  用容器内实际启动器 `unshare -n ${APR_UTIL_NETNS_PREP}` 探测 `lo` 的 `IFF_UP` 位，
  只有真正可用时才记录 `network mode=unshare`；若仍不可用，按既有语义处理。
- **宿主/容器职责**：宿主机做源码下载与校验、解析器与结果校验；容器内做 `dnf` 安装、
  解包、`configure`/`make`/`make install`、`testall` 与 harness 编译、负载生成、版本探测、
  `unshare -n` 探测，以及**整个计时驱动**（`run_timed.py` 在容器内启动被测子进程，
  `docker exec` 的开销不进入采样窗口）。
- **清理**：stop 阶段先 `remove_apr_util_container`（幂等，容器不存在返回 0），再做残留
  进程检查与临时文件清理；启动时会清理同前缀、run-id 不同的陈旧容器。
- **独立运行**：不再要求在宿主机安装编译器或依赖，但必须能访问 Docker daemon；
  Framework 方式与独立入口方式都需要 docker。`test/testall` 仍在容器内 `test/` 目录运行。

## 本机验证结果

本机为 WSL2 Ubuntu 22.04、x86_64、20 核、23 GiB 内存、gcc 11.4.0，与其他适配任务并行
构建，构建统一 `-j4`。Framework 六阶段流程 `PERF_REPS=5` 连续跑两轮（`final5`、`final6`），
两轮都 `status=passed`、27 个指标、9 个场景、3 个分组、5 个样本。`final5` 阶段耗时：
build 9 s、start 9 s、test 96 s、stop 1 s、finalize 1 s（`final6` 为 9/10/102/1/1 s）。

`final5` 主证据（中位数，5 次独立重复；括号内为 `final6` 相对变化）：

| 场景 | 墙钟 s | 峰值 RSS MiB | 吞吐 MiB/s |
|---|---:|---:|---:|
| `base64_encode_64b` | 0.4668 (−0.3%) | 2.0550 | 2615.19 (+0.3%) |
| `base64_encode_1kib` | 0.3624 (−1.3%) | 2.0620 | 2694.48 (+1.3%) |
| `base64_encode_64kib` | 0.5402 (−0.6%) | 2.3320 | 2776.73 (+0.6%) |
| `base64_encode_1mib` | 0.4356 (+0.9%) | 5.1840 | 2755.01 (−0.9%) |
| `base64_decode_64b` | 0.6730 (−0.7%) | 2.2190 | 1451.15 (+0.7%) |
| `base64_decode_1kib` | 0.4346 (−0.2%) | 2.0590 | 1797.61 (+0.2%) |
| `base64_decode_64kib` | 0.5231 (−1.5%) | 2.3870 | 1792.32 (+1.5%) |
| `base64_decode_1mib` | 0.4545 (−1.9%) | 6.5590 | 1760.29 (+1.9%) |
| `upstream_testall` | 9.5919 (+2.2%) | 6.0780 | 19 modules，失败 0 |

`final5` 的工作负载指标 CV 中位数 2.43%、最大 3.43%；全部指标 CV 中位数 2.43%、最大
20.49%（`upstream_testall_wall_s`，6.16–11.14 s）。`final6` 工作负载 CV 中位数 1.00%、
最大 2.67%，`upstream_testall_wall_s` CV 30.07%（5.89–13.07 s）。两轮中位数差异除
`base64_decode_64b_rss_mib`（−7%，2.06 MiB 底噪水平）外都在 ±2.2% 以内；testall 的墙钟
时间主要花在上游 memcache/redis 连接失败的**重试等待**上（命名空间内没有服务），因此
绝对值和 CV 都比编解码场景大，这是上游测试程序的固有行为，不是测量噪声。

负向验证：`PERF_VARIANT=optimized` 的 build 阶段退出码 30，`status.json` 为
`status=failed, failed_stage=build, exit_code=30`，输出目录**没有** `build_variant.json`
与 `results.json`，证明不会静默回退到 base。独立入口在 `/tmp/apr-util-portable-results`
（仓库外目录）运行 `PERF_REPS=1` 通过：`status=passed`、`cleanup_status=passed`、
27 个指标、9 个场景，运行后工作目录 `/home/runner/boostkit-perf/apr-util/local-*`
被清理。所有 Python 脚本通过 `python3 -B -m py_compile`，所有 shell 脚本通过 `bash -n`，
`case.yaml` 通过 YAML 解析，无 BOM、无 CRLF。

## 已知限制与风险

1. **只测 base64 与上游可移植测试**：APR-util 的 APR-util DBD 驱动、LDAP、数据库、
   OpenSSL/crypto、gdbm/ndbm/Berkeley DB 等可选功能在构建时关闭，因此不测量；APR 的
   文件/套接字 I/O、线程与内存池不在本用例范围（只作为 base64 与 testall 的底层）。
2. **`testall` 的墙钟时间不是性能指标**：它包含上游 memcache/redis 连接失败的重试等待
   （约 6–13 s，随内核连接超时与调度波动），有效指标是 `tests_passed=19`；正式比较不应
   把 `upstream_testall_wall_s` 当作吞吐结论。
3. **`unshare -n` 依赖**：测量期要求在**任务专属容器内**能够创建网络命名空间（容器需要
   `--cap-add=SYS_ADMIN`）；不可用时 start 阶段记录 `unavailable` 并在结果上下文中注明，
   除非显式设置 `PERF_APR_UTIL_ALLOW_ONLINE_MEASUREMENT=1` 做本地诊断。命名空间内 `lo`
   被启动器拉起，断言“离线”指的是不经过命名空间外的任何接口。
4. **短场景的进程启动占比**：64 B / 1 KiB 场景单次运行约 0.36–0.67 s，进程启动与
   harness 初始化（APR 初始化、读负载、roundtrip 自检）约占几毫秒，计入墙钟；这是
   “一次进程调用”的真实成本，未做扣除。
5. **1 MiB 场景是缓存带宽敏感项**：负载在页缓存内反复编解码，峰值 RSS 包含 1 MiB
   负载与 1.33 MiB 编码缓冲；它衡量的是编解码器拷贝/查表成本，不等价于磁盘或网络吞吐。
6. **共享宿主机噪声**：本机与其他适配任务并行，两轮中位数虽在 ±2.2% 内，但 testall
   墙钟 CV 可达 30%；正式对比应由 CI 在相同时段、相同 `PERF_REPS` 下分别跑两架构。
7. **源码获取**：Runner 通常无法直连 Apache 镜像站点，两个源码包需预放到
   `/home/runner/software/apr-util/`；镜像可用性会变，但 SHA-256/字节数校验保证错误
   来源不会被接受。
8. **构建参数固定**：`-O2 -DNDEBUG` 固化在 `common.sh`，两架构相同；不追加
   `-march=native`，因此结果反映通用编译产物，而不是本机极限值。APR-util 1.6.5 的
   expat 使用源码包自带副本，两架构一致。
