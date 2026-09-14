# Netty 性能测试说明

本目录测试 Netty 官方 Maven Central 制品（`4.2.18.Final`，Stable
Recommended），以官方 echo 服务器模式为基准负载，进行 x86_64 与
aarch64 开箱性能对比。软件入口为 `netty_test.sh`，Framework 通过
`case.yaml` 调用其 `build`、`start`、`test`、`stop` 四个阶段；直接执行
该脚本也使用同一套阶段函数。

当前清单仅声明 Netty `4.2.18.Final`。新增版本时，必须同时在
`netty_test.sh` 的 `netty_artifact_sha256` 中声明三个官方 jar 的
SHA-256，不能跳过校验。

## 构建与安装

Netty 是以 Maven Central 为官方分发渠道的库，这里的“构建”是布置官方
制品并编译基准应用，不从源码构建 Netty，也不安装任何系统级 Netty
软件包：

1. 依次在以下位置获取三个官方 jar（纯 Java 归档，双架构通用）：

   | 制品 | 官方地址 |
   |---|---|
   | `netty-common` | `https://repo1.maven.org/maven2/io/netty/netty-common/4.2.18.Final/` |
   | `netty-buffer` | `https://repo1.maven.org/maven2/io/netty/netty-buffer/4.2.18.Final/` |
   | `netty-transport` | `https://repo1.maven.org/maven2/io/netty/netty-transport/4.2.18.Final/` |

   获取顺序：`/home/runner/software/netty/` 本地离线包 → 任务工作目录
   已缓存副本 → 官方 Maven Central 下载。

2. 逐一以清单中声明的 SHA-256 校验（校验值取自官方发布制品），失败
   立即退出。官方声明 Netty 核心无强制外部依赖，这三个 jar 即覆盖
   默认 NIO 传输的完整运行时（与 tomcat 用例只部署官方发行版、mysql
   只部署官方 tarball 的哲学一致）。

3. JVM 运行时沿用 flink 用例方式：使用系统 JDK（缺失时通过 `dnf`
   安装 `java-17-openjdk-devel`），要求 Java 11/17/21/25。JVM 以固定
   堆 `-Xms2g -Xmx2g`（`JVM_HEAP_SIZE` 可覆盖）运行，其余 JVM 与
   Netty 选项保持默认（NIO 传输、默认事件循环线程数、默认内存池与
   自适应接收缓冲），即开箱配置。

4. 基准应用源码位于
   `src/main/java/org/boostkit/performance/netty/EchoBenchmark.java`
   （flink 用例 PassThroughJob 的同款方式），以 `javac` 针对官方 jar
   编译，不引入任何额外依赖：

   ```bash
   javac -cp "${PERF_WORK_DIR}/netty-lib/*" -d "${PERF_WORK_DIR}/classes" \
     src/main/java/org/boostkit/performance/netty/EchoBenchmark.java
   ```

5. 通过 jar 内置的官方版本清单（`io.netty.util.Version`）验证版本：

   ```bash
   java -cp "netty-lib/*:classes" org.boostkit.performance.netty.EchoBenchmark --version
   # 输出必须包含 netty-common=4.2.18.Final
   ```

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/netty
sudo install -o runner -g runner netty-common-4.2.18.Final.jar \
  netty-buffer-4.2.18.Final.jar netty-transport-4.2.18.Final.jar \
  /home/runner/software/netty/
sha256sum /home/runner/software/netty/*.jar
```

## 基准就绪（start）

Netty 没有常驻服务。`start` 阶段先确认任务端口（由运行 ID 稳定派生，
与 mysql/nginx 用例相同的 cksum 派生方式）没有被占用（拒绝复用已有
监听），然后以最小配置（8 连接、1KiB 消息、预热 1 秒 + 测量 2 秒）
完整冒烟运行一次基准链路（echo 服务器、客户端流水线、分帧、JSON 报
告），校验报告字段全部为正后丢弃冒烟产物；`test` 阶段只对已验证的
组合计时。

## 性能测试

基准负载采用 Netty 官方 echo 服务器模式（官方入门示例的核心形态）：
服务端把收到的缓冲原样写回、`readComplete` 时统一 flush；客户端与
服务端运行在同一 JVM 内通过回环 TCP 通信（与 envoy 用例相同的单机
基准形态）。每条连接维护固定深度的流水线窗口（默认 8，`NETTY_PIPELINE`
可覆盖），消息为固定大小分帧：`[序列号 8B][发送纳秒时间戳 8B][零填充]`，
客户端据此重组回环字节流，统计吞吐并按 1/1024 确定性采样回环 RTT。

场景矩阵以 mysql 用例的阶梯方式组织：**消息大小（1KiB / 16KiB）×
并发连接数（128 / 256 / 512 / 1024）**，共 8 组，每组独立 JVM 进程
（预热 5 秒 + 测量 30 秒，`NETTY_WARMUP_SECONDS` / `NETTY_DURATION_SECONDS`
可覆盖）：

```bash
java -Xms2g -Xmx2g -cp "netty-lib/*:classes" \
  org.boostkit.performance.netty.EchoBenchmark \
  --port <端口> --message-size 1024 --connections 128 --pipeline 8 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "echo 1KiB" --output benchmark/runs/echo-1k-c128.json
```

任何连接异常或零消息即判失败（对应 k6 用例 `http_req_failed.rate`
必须为 0 的严格性）。每组运行输出一个 JSON 报告，完整控制台输出保留
为 `netty_echo_raw.log`，全部报告由 `scripts/collect_netty_benchmark.py`
校验（场景、消息大小、连接数与文件名一致，所有数值为正）并汇总为
`results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/netty/netty_test.sh \
  --version 4.2.18.Final \
  --results-dir /home/runner/boostkit-perf/netty/results/4.2.18.Final
```

## 指标

每个“场景 + 连接档位”组合保留 3 个字段，不做平均、加权或跨场景聚合。
总计为：

```text
2 个消息大小场景 × 4 个连接档位 × 3 个指标 = 24 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `messages_per_second` | `netty echo <场景> --connections=<连接数>: messages/s` | messages/s | 越大越好 | 每秒完成的回环消息数 |
| `avg_rtt_ms` | `netty echo <场景> --connections=<连接数>: avg RTT` | ms | 越小越好 | 采样消息的平均回环时延 |
| `p99_rtt_ms` | `netty echo <场景> --connections=<连接数>: p99 RTT` | ms | 越小越好 | 采样消息回环时延的 99 分位 |

报告按消息大小场景（echo 1KiB / echo 16KiB）分组；每个场景中再按
并发连接数展示吞吐与两项时延，便于在相同负载下比较 x86_64 与
aarch64。基准参数（传输 NIO 默认、流水线深度、预热与测量时长）记录
在 `results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `netty_echo_raw.log`：8 组运行的原始控制台输出；
- `results.json`：24 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（基准服务器生命周期在各测量进程内），
仅移除本次任务的基准数据目录（运行报告与冒烟产物）。Standalone 模式
结束时还会删除本次任务专属的 `/home/runner/boostkit-perf/netty/local-*`
工作目录（含官方 jar、编译类文件与运行数据）；Framework 随后执行
Runner 级环境清理。
