# hiredis 1.5.0 RESP 解析与命令格式化性能测试

本用例在 `x86_64`、`aarch64` Runner 上从官方源码构建 hiredis 1.5.0 静态库，然后用
**只调用公开 API 的用例自带 harness** 测量三件事：

1. 流式 RESP 回复解析：`redisReaderCreate` / `redisReaderFeed` / `redisReaderGetReply`
   / `freeReplyObject`，即 `redisCommand`、`redisGetReply` 与 `async.c` 共同使用的解析器；
2. 命令格式化：`redisFormatCommand`（printf 风格）与 `redisFormatCommandArgv`（argv 风格）；
3. 上游 `test.c` 中**不依赖 Redis 服务端**的断言子集（分配器注入、命令格式化、回复解析、
   连接错误路径），作为解析/格式化语义的正确性锚点。

目标是让两架构在**同一份源码、同一组确定性 RESP 字节流、同一套调用方式、同一构建参数**
下比较解析器与格式化器的吞吐、进程墙钟时间与峰值内存。网络往返、Redis 服务端性能、
异步/SSL/TLS 与 RESP3 推送回调均不在本用例范围内。

入口为 `hiredis_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也走同一组阶段。基础版构建位于 `scripts/builders/base.sh`，公共常量与
候选 URL 在 `scripts/common.sh`，测量包装在 `scripts/run_timed.py`，每次重复的输出校验在
`scripts/verify_outputs.py`，结果解析与报告在 `scripts/results/`。工作流可选择 `base` 或
`optimized`，默认 `base`；`optimized` 构建尚未实现，选择后会在 build 阶段明确失败
（退出码 30），不会回退到 `base`，也不会写出 `build_variant.json`。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成，与 `software/Database/mysql`、`software/Bigdata/ray`、`software/Others/unixbench`
使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再安装编译器和
`dnf` 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-hiredis-<arch>-<运行ID>`，标签
  `boostkit.hiredis.run-id=<运行ID>`；使用宿主机网络，以 Runner 用户身份运行；只读挂载
  用例目录，读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`；额外授予
  `--cap-add=SYS_ADMIN --cap-add=NET_ADMIN`，因为离线测量模式要在容器内新建网络命名空间
  并把其中的 loopback 拉起（分别需要这两个 capability）；不使用 `--privileged`。
- 容器内：`dnf` 安装 `gcc`、`make`、`python3`、`util-linux` 等构建依赖；解包 pinned 源码、
  `make static`、三个 harness 的编译、版本探测、确定性 RESP fixture 生成、计时包装
  （`scripts/run_timed.py`）与全部被测进程都在容器内执行。
- 宿主机：只负责下载并校验 hiredis 源码包（优先用例内 `fixtures/` 与
  `/home/runner/software/hiredis/`）、严格解析 `results.json`、清理本任务的容器。
  结果解析器与 `scripts/verify_outputs.py` 留在宿主机。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口；
  采样次数、warmup 数与输出校验严格性均未改变。
- 清理：`stop` 阶段先删除本任务容器（标签不符拒绝删除），再检查本任务工作目录下没有
  遗留的被测进程；容器不存在时返回 0，可重复调用。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出
提示。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| hiredis | [GitHub Releases redis/hiredis v1.5.0](https://github.com/redis/hiredis/releases/tag/v1.5.0) 的源码包 `hiredis-1.5.0.tar.gz` | 优先读取 `/home/runner/software/hiredis/hiredis-1.5.0.tar.gz`，缺失时按候选顺序下载；解压到 `${PERF_WORK_DIR}/hiredis-src/` |
| 被测库 | 由该源码包构建的静态库 `libhiredis.a`（上游 `Makefile` 的 `static` 目标） | `${PERF_WORK_DIR}/hiredis-src/libhiredis.a` |
| RESP 回放 harness | 本用例自带 `bench/resp_bench.c`，只调用公开 API | `${PERF_WORK_DIR}/hiredis-bench/resp_bench` |
| 上游本地测试 runner | 本用例自带 `bench/upstream_local_main.c`，`#include` 源码包内未改动的 `test.c` 并只调用其无服务端测试函数 | `${PERF_WORK_DIR}/hiredis-bench/upstream_local` |
| 离线命名空间启动器 | 本用例自带 `bench/netns_loopback_up.c`，在 `unshare -n` 内拉起 `lo` 后 `exec` 被测命令 | `${PERF_WORK_DIR}/hiredis-bench/netns_loopback_up` |
| 字节流生成器 | 本用例自带 `scripts/fixtures/generate_resp_fixtures.py`（固定种子 splitmix64） | `${PERF_WORK_DIR}/fixtures/` |

Runner 通过 `dnf`（Debian/Ubuntu 上为 `apt-get`）安装缺失的 `gcc`、`make`、`tar`、`coreutils`、
`python3`，以及 `curl`/`wget` 之一；安装后会再次自检这些命令，失败则 build 阶段返回 30。
构建只需要 C 编译器与系统 C 库：hiredis 本身不依赖 OpenSSL（`USE_SSL=0`），本用例也不
构建共享库、示例和 SSL 扩展。

Framework 将本次任务的工作目录传给脚本，以下称为 `${PERF_WORK_DIR}`。独立运行时默认位于
`/home/runner/boostkit-perf/hiredis/<运行ID>/`。源码、构建、字节流与临时文件都放在该目录
下；结果写入单独的 `${RESULTS_DIR}`。构建期完成源码下载与校验，测量期所有场景都在
`unshare -n` 新建的网络命名空间内执行，不访问网络。

## hiredis 获取、构建与安装

源码包先从 `/home/runner/software/hiredis/` 读取；没有时依次尝试下表候选。无论来源，
解压前都必须匹配下表的 SHA-256 与字节数。

| 源码包 | SHA-256 | 字节数 |
|---|---|---|
| `hiredis-1.5.0.tar.gz` | `eec7ef8641d221e144a58d5ef8d733c8c75c7fd487097a233aacb4fa33981cfb` | 183116 |

候选顺序（`PERF_HIREDIS_OFFLINE_DIR` 可覆盖第一个目录，`PERF_HIREDIS_MIRROR` 可给非离线
候选加统一前缀）：

```text
${PERF_HIREDIS_OFFLINE_DIR}/hiredis-1.5.0.tar.gz
https://github.com/redis/hiredis/releases/download/v1.5.0/hiredis-1.5.0.tar.gz
https://ghfast.top/https://github.com/redis/hiredis/releases/download/v1.5.0/hiredis-1.5.0.tar.gz
https://gh-proxy.com/https://github.com/redis/hiredis/releases/download/v1.5.0/hiredis-1.5.0.tar.gz
```

GitHub Releases 是 hiredis 的官方二进制/源码分发点；后两个是同一 release 资产的中立镜像
前缀，用于 Runner 无法直连 `github.com` 的情况。**四个候选共用同一个 SHA-256 与字节数**，
任一候选下载后都必须匹配上表，否则丢弃并继续下一个；全部失败时 build 阶段返回 30，
打印完整候选清单与失败原因。Runner 网络不通时请由发布流程把源码包预放到
`/home/runner/software/hiredis/`。

构建命令固定如下（不追加 `-march=native` 等机器相关选项）：

```bash
cd "${PERF_WORK_DIR}/hiredis-src"
make -j"${PERF_HIREDIS_BUILD_JOBS}" static OPTIMIZATION="-O2 -DNDEBUG"
cc -O2 -std=c99 -Wall -Wextra -I. bench/resp_bench.c libhiredis.a -lm \
    -o "${PERF_WORK_DIR}/hiredis-bench/resp_bench"
cc -O2 -std=c99 -Wall -Wextra -I. -Dmain=hiredis_upstream_test_main \
    -DHIREDIS_EXPECT_LOCAL_TESTS=77 bench/upstream_local_main.c libhiredis.a -lm \
    -o "${PERF_WORK_DIR}/hiredis-bench/upstream_local"
cc -O2 -std=c99 -Wall -Wextra bench/netns_loopback_up.c \
    -o "${PERF_WORK_DIR}/hiredis-bench/netns_loopback_up"
"${PERF_WORK_DIR}/hiredis-bench/resp_bench" --version   # 版本自检：应为 1.5.0
```

`PERF_HIREDIS_BUILD_JOBS` 默认 8，本机与其他任务并行时用 `-j4`。版本自检取自
`hiredis.h` 的 `HIREDIS_MAJOR/MINOR/PATCH`，harness 打印出的版本必须等于请求版本，否则
build 返回 30；同时把版本、源码摘要、优化参数、编译器与三个 harness 路径写入
`${PERF_WORK_DIR}/state/build-provenance.txt`。所有 harness 与上游测试 runner 都链接同一份
`libhiredis.a`，保证测量和正确性检查使用的是同一构建产物。

`upstream_local_main.c` 通过 `#define main hiredis_upstream_test_main` 把上游 `test.c`
整体包含进同一个翻译单元，然后只调用以下函数：`test_allocator_injection`、
`test_format_commands`、`test_reply_reader`、`test_blocking_connection_errors`、
`test_free_null`、`test_nonblocking_connect_error_queue`。这些函数覆盖分配器钩子、
`redisFormatCommand*`、回复解析器全部边界、连接错误路径与套接字错误队列；上游其余测试需要
真实 Redis 服务端（TCP/Unix socket/pubsub/监控），不在本用例范围。源码包内 `test.c` 未做
任何修改。

## 测试数据

RESP 字节流由 `scripts/fixtures/generate_resp_fixtures.py` 用固定种子（`20261102`）的
splitmix64 生成，与机器无关；start 阶段每次重新生成，并逐个比对下表字节数、回复数与
SHA-256，任一不一致即 start 返回 20。生成器同时写出 `fixtures.json`，start 与解析器再与
`common.sh` 中固化的常量交叉校验。

| 文件 | 内容 | 字节数 | 回复数 | SHA-256 |
|---|---|---|---|---|
| `pipeline_get.resp` | 100,000 条变长 bulk 字符串回复（GET 管道形状） | 2282319 | 100,000 | `ac15006e70d22fa44d621389ca0748d1603cc7fece210ed5449d1bcafaf63672` |
| `bulk_256k.resp` | 64 条 256 KiB bulk 字符串回复（大 value 读取，内存带宽主导） | 16777920 | 64 | `35a5fa5f11dfe12937afd029d201e2ba1e42003af1d25b5af8db677fb4db3625` |
| `nested_arrays.resp` | 50,000 条两元素数组回复，元素为整数与“整数+bulk”嵌套数组 | 1833348 | 50,000 | `73ec938e1320884f0edbbf9cb013a5942c173ffc33724b09ccb7dca899c2677c` |
| `mixed_types.resp` | 100,000 条简单字符串/错误/整数/空 bulk/nil bulk/空数组循环回复 | 831880 | 100,000 | `5eba8bd264eacb16a4e9137f2061401a7d56f6dff23d71212916d0c3d7a02c2d` |

字节流全部是 RESP2 编码。`reader_fragmented` 场景复用 `pipeline_get.resp`，但把 feed 大小
限制为 1、2、4、…、4096 字节循环递增，用于压测解析器的增量状态机。

## 测试场景

共 8 个场景、3 个指标组。所有场景在测量期都是单进程、单线程、无网络；Parse 类场景把整份
字节流按 64 KiB（fragmented 场景除外）分块喂给同一个 `redisReader`，循环固定次数后释放
全部回复对象。每个场景先跑 1 次 warm-up，再跑 `PERF_REPS` 次独立重复。

| 场景 | 组 | 每次调用的负载 | 循环/迭代次数 | 校验 |
|---|---|---|---|---|
| `reader_pipeline` | `resp_reader` | 回放 `pipeline_get.resp` | 128 | 回复数 = 12,800,000，字节数 = 292,136,832 |
| `reader_bulk` | `resp_reader` | 回放 `bulk_256k.resp` | 256 | 回复数 = 16,384，字节数 = 4,295,147,520 |
| `reader_nested` | `resp_reader` | 回放 `nested_arrays.resp` | 32 | 回复数 = 1,600,000，字节数 = 58,667,136 |
| `reader_mixed` | `resp_reader` | 回放 `mixed_types.resp` | 128 | 回复数 = 12,800,000，字节数 = 106,480,640 |
| `reader_fragmented` | `resp_reader` | 1..4096 字节递增分块回放 `pipeline_get.resp` | 256 | 回复数 = 25,600,000，字节数 = 584,273,664 |
| `format_command` | `command_format` | `redisFormatCommand` 格式化 6 参数 SET 命令 | 1,000,000 | 命令数 = 1,000,000，命令字节数 > 0 |
| `format_argv` | `command_format` | `redisFormatCommandArgv` 格式化 6 参数 SET 命令 | 1,000,000 | 命令数 = 1,000,000，命令字节数 > 0 |
| `upstream_local_suite` | `upstream_suite` | 上游 `test.c` 无服务端断言子集（77 条断言） | 1 | 通过 77、失败 0、跳过 0 |

`reader_*` 场景的有效载荷 = 字节流字节数 × 循环次数；`format_*` 场景的有效载荷 = 迭代
次数。harness 自己打印 `mode=/loops=/bytes=/replies=` 汇总行和 `PERF-CHECK`/`PERF-RESULT`
行；`scripts/verify_outputs.py` 在测量窗口结束后立即用 `common.sh` 的固化常量重新推导
期望值并写 `runs/<scenario>/rep<i>.check`，解析器再逐项核对，因此“回放被截断”“循环次数
被改动”“回复数少算”都会在解析阶段失败，而不是被当成一次有效测量。

`unshare -n` 新建的网络命名空间里 `lo` 默认是 DOWN，而上游 `test_blocking_connection_errors`
与 `test_nonblocking_connect_error_queue` 需要在 `127.0.0.1` 上建立/探测连接，因此
`run_timed.py --offline` 会在命名空间内先执行 `netns_loopback_up` 把 `lo` 拉起，再 `exec`
被测 harness；命名空间里没有其他接口，离线保证不变。

## 指标与统计

每个场景产生三类指标：

| 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<scenario>_wall_s` | s | 越低越好 | 被测子进程的墙钟时间，`time.monotonic()` 围绕 `Popen` 与 `wait` 测量 |
| `<scenario>_rss_mib` | MiB | 越低越好 | 被测子进程的峰值常驻内存，轮询 `/proc/<pid>/status` 的 `VmHWM`（5 ms 间隔） |
| `reader_*_parse_mib_per_second` | MiB/s | 越高越好 | 字节流有效载荷（字节数 × 循环次数）/ 墙钟时间 |
| `reader_*_replies_per_second` | replies/s | 越高越好 | 解析出的回复总数（回复数 × 循环次数）/ 墙钟时间 |
| `format_*_commands_per_second` | commands/s | 越高越好 | 格式化命令数（迭代次数）/ 墙钟时间 |
| `upstream_local_suite_tests_passed` | tests | 越高越好 | 上游无服务端断言通过数，固定为 77（少于 77 即失败） |

每个指标都保留 `median`、`mean`、`min`、`max`、`stdev` 与全部 `samples`。比较用中位数，
样本数 = `PERF_REPS`；正式证据要求 `PERF_REPS >= 5`，`PERF_REPS=1` 仅用于本地链路自检。
峰值内存不用 `getrusage(RUSAGE_CHILDREN)`：从较大的 Python 解释器 fork 出来的子进程会继承
父进程的常驻页，`VmHWM` 属于 `exec` 之后程序自身的地址空间，是更诚实的口径；唯一的底噪是
`unshare` + `netns_loopback_up` 启动器自身的少量页，约 0.6 MiB。

解析器是严格的：场景集合必须与声明完全一致；每个声明的重复必须有 `rep<i>.json`、
`rep<i>.log`、`rep<i>.check`；子进程必须退出码 0、未超时；每个 check 必须 `ok` 且与固化
期望值一致；每个指标必须有限且为正。任何一项不满足都直接失败（test/stop 阶段退出码 50），
不插值、不补零、不跳过。

## 运行方式

Framework 方式（仓库根目录）：

```bash
python3 framework/run_case.py --case software/Toolchain/hiredis/case.yaml \
    --version 1.5.0 --architecture x86_64 --run-id local-1 --stage build
# 之后依次执行 --stage start / test / stop / finalize
```

独立运行方式（不需要 Framework）：

```bash
bash software/Toolchain/hiredis/hiredis_test.sh --version 1.5.0 \
    --results-dir /home/runner/boostkit-perf/hiredis-results
```

常用环境变量：`PERF_REPS`（默认 5）、`PERF_VARIANT`（`base`/`optimized`）、
`PERF_HIREDIS_BUILD_JOBS`（默认 8）、`PERF_HIREDIS_OFFLINE_DIR`、`PERF_HIREDIS_MIRROR`、
`PERF_HIREDIS_ALLOW_ONLINE_MEASUREMENT`（仅在 `unshare -n` 不可用时用于本地诊断，默认 0，
即测量期必须离线）。`--keep-workdir` 可保留工作目录排查问题。

## 本机验证结果

本机为 WSL2 Ubuntu 22.04、x86_64、20 核、23 GiB 内存、gcc 11.4.0，与其他适配任务并行
构建，构建统一 `-j4`。Framework 六阶段流程 `PERF_REPS=5` 连续跑两轮（`final1`、`final2`），
两轮都 `status=passed`、29 个指标、8 个场景、5 个样本。`final2` 阶段耗时：prepare 2 s、
build 5 s、start 0 s、test 24 s、stop 1 s、finalize 0 s。

`final1` 主证据（中位数，5 次独立重复；括号内为 `final2` 相对变化）：

| 场景 | 墙钟 s | 峰值 RSS MiB | 吞吐 |
|---|---:|---:|---|
| `reader_pipeline` | 0.4598 (+5.7%) | 3.9340 | 605.93 MiB/s，27,838,432 replies/s |
| `reader_bulk` | 0.2115 (−7.3%) | 18.2620 | 19,363.67 MiB/s，77,451 replies/s |
| `reader_nested` | 0.2200 (−4.3%) | 3.5000 | 254.34 MiB/s，7,273,355 replies/s |
| `reader_mixed` | 0.4663 (−5.8%) | 2.5510 | 217.76 MiB/s，27,448,373 replies/s |
| `reader_fragmented` | 0.7918 (−5.3%) | 3.8830 | 703.74 MiB/s，32,332,050 replies/s |
| `format_command` | 0.6800 (−4.0%) | 1.8550 | 1,470,627 commands/s |
| `format_argv` | 0.2254 (−0.9%) | 1.7300 | 4,436,577 commands/s |
| `upstream_local_suite` | 0.0059 | 0.6880 | 77 tests，失败 0，跳过 0 |

`final1` 的指标离散度：29 个指标 CV 中位数 3.28%，最大 8.50%（
`upstream_local_suite_rss_mib`，0.56–0.69 MiB 的启动器底噪）；`final2` 在并行负载更轻的
时段运行，CV 中位数 1.12%、最大 36.16%（仍是同一 RSS 底噪），其余指标均 ≤ 5.2%。
两轮中位数差异 ±9% 以内，属于共享宿主机上不同负载时段的正常波动；因此两架构比较必须使用
同一时段、同一 `PERF_REPS` 的数据，跨时段绝对值只做参考。

负向验证：`PERF_VARIANT=optimized` 的 build 阶段退出码 30，输出目录**没有**
`build_variant.json` 与 `results.json`，证明不会静默回退到 base。独立入口在
`/tmp/hiredis-portable-results`（仓库外目录）运行 `PERF_REPS=1` 通过：`status=passed`、
`cleanup_status=passed`、29 个指标、8 个场景，运行后工作目录被清理。所有 Python 脚本
通过 `python3 -B -m py_compile`，所有 shell 脚本通过 `bash -n`，无 BOM、无 CRLF。

## 已知限制与风险

1. **不测网络与 Redis 服务端**：本用例测的是库内解析/格式化，不是端到端请求延迟；上游
   `test.c` 中需要真实 Redis 的测试（连接、超时、pubsub、monitor、SSL 等）不运行，
   `upstream_local_suite` 只覆盖 77 条无服务端断言。RESP3 的 map/set/double/push 类型
   解析断言包含在这 77 条里（上游 `test_reply_reader` 覆盖），但回放字节流本身是 RESP2。
2. **单线程**：所有场景都是单进程单线程，不测多连接并发、pipeline 网络写入或 `async.c`
   事件循环；多线程/多连接扩展性需另立用例。
3. **`unshare -n` 依赖**：测量期要求网络命名空间可用；不可用时 start 阶段返回 20，除非
   显式设置 `PERF_HIREDIS_ALLOW_ONLINE_MEASUREMENT=1` 做本地诊断。命名空间内 `lo` 被
   启动器拉起，断言“离线”指的是不经过命名空间外的任何接口。
4. **`reader_bulk` 是内存带宽敏感项**：2.1 GiB 有效载荷在页缓存中反复解析，峰值 RSS 包含
   16.8 MiB 的字节流缓冲；它衡量大 value 解析的拷贝/分配成本，不等价于磁盘或网络读取速度。
5. **`upstream_local_suite` 的墙钟/RSS 不是性能指标**：该场景只有 77 条断言、约 6 ms，
   墙钟和 RSS 主要反映进程启动与启动器底噪，CV 偏高属正常；它的有效指标是
   `tests_passed=77`。
6. **共享宿主机噪声**：本机与其他适配任务并行，同一配置连续两轮中位数可差 ±9%，
   跨时段比较需谨慎；正式对比应由 CI 在相同时段、相同 `PERF_REPS` 下分别跑两架构。
7. **源码获取**：Runner 通常无法直连 `github.com`，release 资产需预放到
   `/home/runner/software/hiredis/`；镜像前缀可能随第三方可用性变化，但 SHA-256/字节数
   校验不变，错误来源不会被接受。
8. **构建参数固定**：`OPTIMIZATION="-O2 -DNDEBUG"` 与 harness `-O2` 固化在 `common.sh`，
   两架构相同；不追加 `-march=native`，因此结果反映通用编译产物，而不是本机极限值。
