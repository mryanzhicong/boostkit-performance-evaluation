# rinetd 0.73 性能用例

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
- 容器：名字 `boostkit-rinetd-<arch>-<运行ID>`，标签
  `boostkit.rinetd.run-id=<运行ID>`；使用宿主机网络（因此容器内的 `127.0.0.1` 端口就是
  测量用端口），以 Runner 用户身份运行；只读挂载用例目录，读写挂载
  `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`；不使用 `--privileged`。
- 容器内：`dnf` 安装 `gcc`、`make`、`util-linux`、`python3` 等构建依赖；解包 pinned
  源码、`./configure`/`make`/`make install`、benchmark harness 编译、版本探测、端口挑选、
  rinetd 服务进程、每个样本的 backend server 与计时包装（`scripts/run_timed.py`）均在
  容器内执行。
- 宿主机：只负责下载并校验源码包、严格解析 `benchmark_rinetd.json`、清理本任务的容器。
- 测量：`start` 阶段在容器内拉起 rinetd 并等到两个监听端口就绪；`test` 阶段为每个样本在
  容器内启动 backend server，客户端经容器内计时包装运行，`docker exec` 的管理开销不进入
  计时窗口；采样数量、warmup 数与解析严格性均未改变。
- 清理：`stop` 阶段先停掉容器内的 rinetd 并确认两个监听端口已关闭，再删除本任务容器
  （标签不符拒绝删除）；端口校验使用容器内 `python3`。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出
提示。

## 1. 软件与版本

- 软件：rinetd（TCP/UDP 端口重定向服务器）。
- 版本：**0.73**（`SOFTWARE_VERSION=0.73`）。
- 上游项目：<https://github.com/samhocevar/rinetd>，发布制品为 v0.73 tag 附带的源码归档。
- 实测对象：`rinetd` 二进制的 TCP 转发路径，与同机回环直连对比。

## 2. 上游制品与校验

| 制品 | 文件名 | SHA-256（固定） |
|---|---|---|
| rinetd 源码 | `rinetd-0.73.tar.gz` | `da1fa70e75c2e5906ba55bb05a71da07d1e2a1cc4de2aa9bd30b1f753d8c345a` |

下载顺序（每个来源都必须匹配同一 SHA-256）：

1. 预置离线目录：`${PERF_RINETD_OFFLINE_DIR:-/home/runner/software/rinetd}`；
2. `https://github.com/samhocevar/rinetd/releases/download/v0.73/rinetd-0.73.tar.gz`；
3. GitHub 镜像 `https://gh-proxy.com/https://github.com/.../rinetd-0.73.tar.gz`（与第 2 项同一份字节，已核对 SHA-256 一致；专有 Runner 访问不到 github.com，走镜像）。

全部来源失败时 `build` 退出 **30**，并逐个打印尝试过的 URL 与失败原因。归档是上游 `make dist` 产物，**自带 `configure`**，不需要 autoreconf。

## 3. 安装与构建

`scripts/builders/base.sh`：

1. 校验并解压 `rinetd-0.73.tar.gz` 到 `${PERF_WORK_DIR}/src/rinetd-0.73`；
2. `./configure --prefix=${PERF_WORK_DIR}/rinetd-prefix`、`make -j4`、`make install`；
3. `${PERF_WORK_DIR}/rinetd-prefix/sbin/rinetd -v` 必须输出 `rinetd 0.73`（否则 30），写入 `PERF_ACTUAL_VERSION_FILE`；
4. `gcc -O2 -pthread` 编译 `scripts/bench/rinetd_bench.c` 为 `${PERF_WORK_DIR}/bin/rinetd_bench`。

构建依赖（`dnf`/`apt` 双分支 + 安装后逐个 `command -v` 自检）：`gcc`、`make`、`tar`、`gzip`、`curl`、`coreutils`、`python3`。

## 4. 完整测试口径

### 4.1 固定矩阵（8 场景）

回环地址上的固定矩阵：每个场景由一个 server 进程（sink 或 echo）和一个 client 进程组成，client 要么直连 server 端口（`direct`），要么连到本用例启动的 rinetd 监听端口（`forwarded`）。

| 场景 | 模式 | payload / 请求 | 连接数 | 说明 |
|---|---|---|---|---|
| `throughput_4m_direct` | throughput | 4 MiB | 1 | 单连接 4 MiB 吞吐，直连 |
| `throughput_4m_forwarded` | throughput | 4 MiB | 1 | 单连接 4 MiB 吞吐，经 rinetd |
| `throughput_16m_direct` | throughput | 16 MiB | 1 | 单连接 16 MiB 吞吐，直连 |
| `throughput_16m_forwarded` | throughput | 16 MiB | 1 | 单连接 16 MiB 吞吐，经 rinetd |
| `throughput_4m_8conn_direct` | throughput | 4 MiB × 8 | 8 | 8 并发连接共 32 MiB，直连 |
| `throughput_4m_8conn_forwarded` | throughput | 4 MiB × 8 | 8 | 8 并发连接共 32 MiB，经 rinetd |
| `latency_64b_direct` | latency | 64 B | 1 | 64 B 请求/回显 2000 次 RTT（丢弃前 100 次预热），直连 |
| `latency_64b_forwarded` | latency | 64 B | 1 | 同上，经 rinetd |

### 4.2 端口与进程

- **端口**：start 阶段用 `python3` 绑定 `127.0.0.1:0` 取 4 个空闲端口（2 个 rinetd 监听端口、2 个后端端口），失败时最多重选 5 次；不写死端口，避免与其他作业/并发用例冲突。
- **rinetd 配置**：`${RESULTS_DIR}/rinetd.conf`，`logfile` 指到结果目录；两个映射：吞吐监听→吞吐后端、时延监听→时延后端。
- **进程**：rinetd 用 `setsid ... -f` 前台方式启动（pid 写入 `${RESULTS_DIR}/rinetd.pid`），每场景的 server 进程由 test 阶段拉起并在客户端结束后 `wait` 回收；`stop` 阶段按 pidfile 精确 `SIGTERM`（超时再 `SIGKILL`），并校验两个监听端口已关闭。
- **退出保证**：test 阶段 `trap stop_server EXIT`，任一场景失败也会杀掉本次 server；rinetd 由 stop 阶段统一回收，不按进程名 kill，避免误伤同机其他 agent。

### 4.3 预热与测量

- 每场景 **1 次预热** + **≥5 次独立测量**（`PERF_REPS`，默认 5）；
- 每次测量 client/server 都是新进程；`scripts/run_timed.py` 记录 client 的墙钟与峰值 RSS，原始输出全文写入 `runs/<scenario>/rep<i>.log`，server 输出写 `runs/<scenario>/server-rep<i>.log`；
- 时延场景在 client 进程内额外丢弃前 100 次 RTT（`RINETD_LATENCY_DISCARD`）作为进程内预热，只统计后 2000 次；
- 测量阶段**离线**：制品在 build 阶段下载并校验，test 阶段不访问网络。

### 4.4 严格解析

`scripts/results/parse_benchmark.py` 要求：预热与全部重复样本存在；`exit_code == 0` 且未超时；client 日志中**恰好一行** `RESULT`，其 mode/payload/connections（或 request_bytes/round_trips）必须等于场景声明；吞吐场景的 `bytes` 必须等于 `payload × connections` 且 `bytes_per_second ≈ bytes/seconds`；时延场景 `p99 >= mean`；server 日志恰好一行 `SERVER` 且字节数为正。任一条件不满足 → `test` 退出 **50**，并打印对应日志尾部 40 行；不补零、不插值、不估算。

### 4.5 原始证据

```text
runs/<scenario>/warmup1.log        client 原始输出（含 RESULT 行）
runs/<scenario>/server-warmup1.log server 原始输出（含 LISTENING/SERVER 行）
runs/<scenario>/warmup1.json       client 墙钟与峰值 RSS
runs/<scenario>/rep<i>.log         client 原始输出
runs/<scenario>/server-rep<i>.log  server 原始输出
runs/<scenario>/rep<i>.json        client 墙钟与峰值 RSS
raw-output.log                     全部场景×全部样本的合并原始输出
benchmark_rinetd.json              聚合结果（每指标含全部样本与统计量）
rinetd.conf / rinetd.log / rinetd.pid / ports.env  转发配置与运行证据
```

## 5. 指标（8 场景 × 4 = 32 个）

| 场景类型 | 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|---|
| 吞吐 | `<scenario>.throughput_mib_per_second` | MiB/s | 越高越好 | 客户端测得的有效吞吐（中位数） |
| 吞吐 | `<scenario>.bytes_per_second` | B/s | 越高越好 | 同上，字节单位 |
| 吞吐 | `<scenario>.wall_seconds` | s | 越低越好 | client 进程墙钟（含建连、发送、排空） |
| 吞吐 | `<scenario>.peak_rss_mib` | MiB | 越低越好 | client 进程峰值 RSS |
| 时延 | `<scenario>.rtt_mean_us` | us | 越低越好 | 2000 次 RTT 平均值（中位数跨重复） |
| 时延 | `<scenario>.rtt_p99_us` | us | 越低越好 | 2000 次 RTT 的 p99 |
| 时延 | `<scenario>.wall_seconds` | s | 越低越好 | client 进程墙钟（含 100 次丢弃预热） |
| 时延 | `<scenario>.peak_rss_mib` | MiB | 越低越好 | client 进程峰值 RSS |

每个指标保留全部样本与 `min/max/mean/median/stdev`，报告值为中位数。

## 6. 架构与证据边界

- 支持 `x86_64`/`aarch64`：`configure` 原生检测；`EXPECTED_ARCH` 与 `uname -m` 不一致时 `build` 退出 **20**。
- 全部流量都在 `127.0.0.1` 回环上，衡量的是 rinetd 转发开销，不代表跨机/公网性能；回环带宽极高，绝对 MiB/s 受 socket buffer 与 CPU 影响。
- 直连与转发使用**同一后端端口**、同一 payload 与同一客户端代码，差异只来自是否经过 rinetd。
- 本机（WSL Ubuntu-22.04 x86_64）数字仅代表该机器；Runner 结果以 Actions 产物为准。

## 7. 运行方式

### 7.1 框架六阶段

```bash
SOFTWARE_VERSION=0.73 PERF_REPS=5 python3 framework/run_case.py \
  --case software/Toolchain/rinetd/case.yaml \
  --version 0.73 --architecture x86_64 --run-id local-rinetd --stage prepare
```

### 7.2 独立运行

```bash
software/Toolchain/rinetd/rinetd_test.sh --version 0.73 --variant base --results-dir /tmp/rinetd-results
```

### 7.3 环境变量

| 变量 | 说明 |
|---|---|
| `SOFTWARE_VERSION` | 只支持 `0.73` |
| `PERF_REPS` | 测量重复次数，默认 5（≥5 才满足口径） |
| `PERF_RINETD_JOBS` | 构建并行度，默认 4 |
| `PERF_RINETD_OFFLINE_DIR` | 离线目录，默认 `/home/runner/software/rinetd` |
| `PERF_VARIANT` | `base`（唯一实现）或 `optimized`（显式失败） |

### 7.4 负向验证

`PERF_VARIANT=optimized` 时 `optimized.sh` 只打印错误并 `return 30`，**不**写 `build_variant.json`。

## 8. 故障排查

| 现象 | 处理 |
|---|---|
| `cannot obtain rinetd-0.73.tar.gz` | 检查网络/代理；放进 `${PERF_RINETD_OFFLINE_DIR}`；日志列出全部尝试 URL |
| `SHA-256 mismatch` | 下载截断或镜像被改写；删除 `.part` 重试或换离线目录 |
| `configuring rinetd ... failed` | 看 `logs/configure.log` 尾部 40 行 |
| `built rinetd reports X, requested 0.73` | 归档不是 0.73 |
| `compiling the rinetd benchmark harness failed` | 看 `logs/bench-build.log` |
| `rinetd failed to start after 5 attempts` | 端口被占或 `rinetd.stdout.log` 有配置错误；重跑一般即可 |
| `rinetd is not running; the start stage must succeed first` | start 阶段失败或 rinetd 被外部杀掉；看 `rinetd.stdout.log` |
| `server did not start listening in time` | 端口被并发占用；看 `runs/<scenario>/server-*.log` |
| `scenario ... client failed` | 看 `runs/<scenario>/<label>.log` 尾部 40 行 |

## 9. 许可证

rinetd 使用 GNU GPL v2+。本用例只下载并构建上游归档，不分发其二进制。
