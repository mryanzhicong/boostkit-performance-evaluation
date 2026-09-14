# gRPC-Java 性能测试说明

本目录测试 gRPC-Java 官方 Maven Central 制品（`1.83.1`），以经典的
一元（unary）echo RPC 为基准负载，进行 x86_64 与 aarch64 开箱性能
对比。软件入口为 `grpc_java_test.sh`，Framework 通过 `case.yaml`
调用其 `build`、`start`、`test`、`stop` 四个阶段；直接执行该脚本
也使用同一套阶段函数。

当前清单仅声明 gRPC-Java `1.83.1`。新增版本时，必须同时在
`grpc_java_test.sh` 的 `grpc_artifact_info` 中声明全部 14 个官方
jar 的 Maven 坐标与 SHA-256，不能跳过校验。

## 构建与安装

gRPC-Java 是以 Maven Central 为官方分发渠道的库，这里的“构建”是
布置官方制品并编译基准应用，不从源码构建 gRPC，也不安装任何系统
级 gRPC 软件包：

1. 依次在以下位置获取官方 `io.grpc:grpc-netty-shaded` 传输及其
   运行时依赖闭包（共 14 个纯 Java jar，双架构通用；依赖清单取自
   grpc-netty-shaded 官方 pom 的 compile/runtime 闭包，并经本地
   实测跑通）：

   | 制品 | Maven 坐标 | 版本 |
   |---|---|---|
   | grpc-netty-shaded | `io.grpc:grpc-netty-shaded` | 1.83.1 |
   | grpc-core | `io.grpc:grpc-core` | 1.83.1 |
   | grpc-api | `io.grpc:grpc-api` | 1.83.1 |
   | grpc-stub | `io.grpc:grpc-stub` | 1.83.1 |
   | grpc-context | `io.grpc:grpc-context` | 1.83.1 |
   | grpc-util | `io.grpc:grpc-util` | 1.83.1 |
   | guava | `com.google.guava:guava` | 33.6.0-android |
   | failureaccess | `com.google.guava:failureaccess` | 1.0.3 |
   | error_prone_annotations | `com.google.errorprone:error_prone_annotations` | 2.50.0 |
   | animal-sniffer-annotations | `org.codehaus.mojo:animal-sniffer-annotations` | 1.27 |
   | jsr305 | `com.google.code.findbugs:jsr305` | 3.0.2 |
   | perfmark-api | `io.perfmark:perfmark-api` | 0.27.0 |
   | gson | `com.google.code.gson:gson` | 2.14.0 |
   | annotations | `com.google.android:annotations` | 4.1.1.4 |

   获取顺序：`/home/runner/software/grpc-java/` 本地离线包 → 任务
   工作目录已缓存副本 → 官方 Maven Central 下载。

2. 逐一以 `grpc_artifact_info` 中声明的 SHA-256 校验（校验值取自
   官方发布制品），失败立即退出。`grpc-netty-shaded` 携带 shade
   过的 Netty 传输实现，这 14 个 jar 即覆盖默认开箱 unary RPC 的
   完整运行时（与 tomcat 用例只部署官方发行版、netty 用例只部署
   三个核心 jar 的哲学一致）。

3. JVM 运行时沿用 flink/netty 用例方式：使用系统 JDK（缺失时通过
   `dnf` 安装 `java-17-openjdk-devel`），要求 Java 8 或更新
   （gRPC-Java 官方基线）。JVM 以固定堆 `-Xms2g -Xmx2g`
   （`JVM_HEAP_SIZE` 可覆盖）运行，其余 JVM、gRPC 与 HTTP/2 选项
   保持默认（grpc-netty-shaded 传输、默认流控窗口、默认并发流与
   执行器），即开箱配置。

4. 基准应用源码位于
   `src/main/java/org/boostkit/performance/grpc/GrpcBenchmark.java`
   （flink/netty 用例的同款方式），以 `javac` 针对官方 jar 编译，
   不引入任何额外依赖，不涉及 protobuf 编译器或生成代码（请求用
   普通 byte-array marshaller 编解码）：

   ```bash
   javac -encoding UTF-8 -cp "${PERF_WORK_DIR}/grpc-lib/*" -d "${PERF_WORK_DIR}/classes" \
     src/main/java/org/boostkit/performance/grpc/GrpcBenchmark.java
   ```

5. 通过官方 jar 清单中的实现版本（`grpc-core` 的
   Implementation-Version）验证版本：

   ```bash
   java -cp "grpc-lib/*:classes" org.boostkit.performance.grpc.GrpcBenchmark --version
   # 输出必须包含 grpc-java-version=1.83.1
   ```

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/grpc-java
sudo install -o runner -g runner grpc-netty-shaded-1.83.1.jar grpc-core-1.83.1.jar \
  grpc-api-1.83.1.jar grpc-stub-1.83.1.jar grpc-context-1.83.1.jar \
  grpc-util-1.83.1.jar guava-33.6.0-android.jar failureaccess-1.0.3.jar \
  error_prone_annotations-2.50.0.jar animal-sniffer-annotations-1.27.jar \
  jsr305-3.0.2.jar perfmark-api-0.27.0.jar gson-2.14.0.jar \
  annotations-4.1.1.4.jar \
  /home/runner/software/grpc-java/
sha256sum /home/runner/software/grpc-java/*.jar
```

## 基准就绪（start）

gRPC 基准没有常驻服务。`start` 阶段先确认任务端口（由运行 ID 稳定
派生，与 mysql/netty 用例相同的 cksum 派生方式）没有被占用（拒绝
复用已有监听），然后以最小配置（8 channel、1KiB 消息、预热 1 秒 +
测量 2 秒）完整冒烟运行一次基准链路（gRPC 服务器、channel 流水线、
unary 调用、JSON 报告），校验报告字段全部为正后丢弃冒烟产物；
`test` 阶段只对已验证的组合计时。

## 性能测试

基准负载采用 gRPC 最经典的一元 echo RPC 形态：服务端手工注册
`benchmark.Echo/Send` 一元方法（`ServerCalls.asyncUnaryCall`），
把收到的请求原样应答；客户端与服务端运行在同一 JVM 内通过回环
TCP 通信（与 envoy/netty 用例相同的单机基准形态）。每条 channel
维护固定深度的流水线窗口（默认 8，`GRPC_PIPELINE` 可覆盖），请求
为固定大小帧：`[序列号 8B][发送纳秒时间戳 8B][零填充]`，以
byte-array marshaller 直接收发（不经过 protobuf），客户端校验
回显序列号并按 1/1024 确定性采样回环 RTT；任何序列号不匹配、
长度不匹配或调用错误即判失败。

场景矩阵以 mysql 用例的阶梯方式组织：**消息大小（1KiB / 16KiB）×
并发 channel 数（128 / 256 / 512 / 1024）**，共 8 组，每组独立
JVM 进程（预热 5 秒 + 测量 30 秒，`GRPC_WARMUP_SECONDS` /
`GRPC_DURATION_SECONDS` 可覆盖）：

```bash
java -Xms2g -Xmx2g -cp "grpc-lib/*:classes" \
  org.boostkit.performance.grpc.GrpcBenchmark \
  --port <端口> --message-size 1024 --channels 128 --pipeline 8 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "unary 1KiB" --output benchmark/runs/unary-1k-c128.json
```

每组运行输出一个 JSON 报告，完整控制台输出保留为
`grpc_java_unary_raw.log`，全部报告由
`scripts/collect_grpc_java_benchmark.py` 校验（场景、消息大小、
channel 数与文件名一致，所有数值为正）并汇总为 `results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/grpc-java/grpc_java_test.sh \
  --version 1.83.1 \
  --results-dir /home/runner/boostkit-perf/grpc-java/results/1.83.1
```

## 指标

每个“场景 + channel 档位”组合保留 3 个字段，不做平均、加权或跨
场景聚合。总计为：

```text
2 个消息大小场景 × 4 个 channel 档位 × 3 个指标 = 24 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `calls_per_second` | `gRPC-Java unary <场景> --channels=<channel数>: calls/s` | calls/s | 越大越好 | 每秒完成的一元 RPC 数 |
| `avg_rtt_ms` | `gRPC-Java unary <场景> --channels=<channel数>: avg RTT` | ms | 越小越好 | 采样调用的平均回环时延 |
| `p99_rtt_ms` | `gRPC-Java unary <场景> --channels=<channel数>: p99 RTT` | ms | 越小越好 | 采样调用回环时延的 99 分位 |

报告按消息大小场景（unary 1KiB / unary 16KiB）分组；每个场景中
再按并发 channel 数展示吞吐与两项时延，便于在相同负载下比较
x86_64 与 aarch64。基准参数（传输 grpc-netty-shaded 默认、流水线
深度、预热与测量时长）记录在 `results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `grpc_java_unary_raw.log`：8 组运行的原始控制台输出；
- `results.json`：24 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（gRPC 服务器生命周期在各测量进程
内），仅移除本次任务的基准数据目录（运行报告与冒烟产物）。
Standalone 模式结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/grpc-java/local-*` 工作目录（含官方
jar、编译类文件与运行数据）；Framework 随后执行 Runner 级环境
清理。
