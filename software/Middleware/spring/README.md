# Spring Framework 性能测试说明

本目录测试 Spring Framework 官方 Maven Central 制品（`7.0.9`），以官方
WebFlux 函数式（WebFlux Fn）`POST /echo` 端点为基准负载，进行 x86_64
与 aarch64 开箱性能对比。软件入口为 `spring_test.sh`，Framework 通过
`case.yaml` 调用其 `build`、`start`、`test`、`stop` 四个阶段；直接
执行该脚本也使用同一套阶段函数。

当前清单仅声明 Spring Framework `7.0.9`。新增版本时，必须同时在
`spring_test.sh` 的 `spring_artifact_info` 中声明全部 14 个官方 jar 的
Maven 坐标与 SHA-256，不能跳过校验。

## 构建与安装

Spring Framework 是以 Maven Central 为官方分发渠道的库，这里的“构建”
是布置官方制品并编译基准应用，不从源码构建 Spring，也不安装任何系统
级 Spring 软件包：

1. 依次在以下位置获取官方 `org.springframework:spring-webflux` 及其
   运行时依赖闭包（共 14 个纯 Java jar，双架构通用；依赖清单取自
   spring-webflux / spring-web / spring-context 官方 pom，并经本地
   实测跑通）：

   | 制品 | Maven 坐标 | 版本 |
   |---|---|---|
   | spring-webflux | `org.springframework:spring-webflux` | 7.0.9 |
   | spring-web | `org.springframework:spring-web` | 7.0.9 |
   | spring-test | `org.springframework:spring-test` | 7.0.9 |
   | spring-context | `org.springframework:spring-context` | 7.0.9 |
   | spring-aop | `org.springframework:spring-aop` | 7.0.9 |
   | spring-expression | `org.springframework:spring-expression` | 7.0.9 |
   | spring-beans | `org.springframework:spring-beans` | 7.0.9 |
   | spring-core | `org.springframework:spring-core` | 7.0.9 |
   | reactor-core | `io.projectreactor:reactor-core` | 3.8.7 |
   | micrometer-observation | `io.micrometer:micrometer-observation` | 1.16.7 |
   | micrometer-commons | `io.micrometer:micrometer-commons` | 1.16.7 |
   | reactive-streams | `org.reactivestreams:reactive-streams` | 1.0.4 |
   | jspecify | `org.jspecify:jspecify` | 1.0.0 |
   | commons-logging | `commons-logging:commons-logging` | 1.3.5 |

   说明：`spring-context`（及其依赖 spring-aop、spring-expression）在
   spring-webflux 官方 pom 中为 optional，但运行时为 `HandlerStrategies`
   （`LocaleContextHolder`）所必需；`spring-test` 携带官方
   `MockServerWebExchange` / `MockServerHttpRequest` 驱动 API（Spring
   官方框架测试所用的同一设施）；`reactor-core` / `micrometer` /
   `reactive-streams` / `jspecify` / `commons-logging` 为官方 pom 声明
   的非可选依赖闭包。

   获取顺序：`/home/runner/software/spring/` 本地离线包 → 任务工作
   目录已缓存副本 → 官方 Maven Central 下载。

2. 逐一以 `spring_artifact_info` 中声明的 SHA-256 校验（校验值取自
   官方发布制品），失败立即退出。这 14 个 jar 覆盖 WebFlux Fn 端到端
   管道的完整开箱运行时（与 tomcat 用例只部署官方发行版、netty /
   grpc-java 用例只部署官方 jar 闭包的哲学一致），不引入任何 HTTP
   服务器实现（Reactor Netty / Tomcat 等），被测对象始终是 Spring
   Framework 管道本身。

3. JVM 运行时沿用 flink/netty/grpc-java 用例方式：使用系统 JDK（缺失
   时通过 `dnf` 安装 `java-21-openjdk-devel`），要求 Java 17 或更新
   （Spring Framework 7.0 官方基线）。JVM 以固定堆 `-Xms2g -Xmx2g`
   （`JVM_HEAP_SIZE` 可覆盖）运行，其余 JVM、Spring 与 Reactor 选项
   保持默认（默认 HandlerStrategies、默认消息编解码器、默认
   Schedulers），即开箱配置。

4. 基准应用源码位于
   `src/main/java/org/boostkit/performance/spring/SpringEchoBenchmark.java`
   （flink/netty/grpc-java 用例的同款方式），以 `javac` 针对官方 jar
   编译，不引入任何额外依赖：

   ```bash
   javac -encoding UTF-8 -cp "${PERF_WORK_DIR}/spring-lib/*" -d "${PERF_WORK_DIR}/classes" \
     src/main/java/org/boostkit/performance/spring/SpringEchoBenchmark.java
   ```

5. 通过官方公开版本 API（`org.springframework.core.SpringVersion`）验证
   版本：

   ```bash
   java -cp "spring-lib/*:classes" org.boostkit.performance.spring.SpringEchoBenchmark --version
   # 输出必须包含 spring-version=7.0.9
   ```

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/spring
sudo install -o runner -g runner spring-webflux-7.0.9.jar spring-web-7.0.9.jar \
  spring-test-7.0.9.jar spring-context-7.0.9.jar spring-aop-7.0.9.jar \
  spring-expression-7.0.9.jar spring-beans-7.0.9.jar spring-core-7.0.9.jar \
  reactor-core-3.8.7.jar micrometer-observation-1.16.7.jar \
  micrometer-commons-1.16.7.jar reactive-streams-1.0.4.jar \
  jspecify-1.0.0.jar commons-logging-1.3.5.jar \
  /home/runner/software/spring/
sha256sum /home/runner/software/spring/*.jar
```

## 基准就绪（start）

Spring 基准没有常驻服务，也没有网络监听（exchange 全部在进程内驱动）。
`start` 阶段以最小配置（并发 64、8 驱动线程、1KiB 消息、预热 1 秒 +
测量 2 秒）完整冒烟运行一次基准链路（函数式路由、exchange 驱动、回显
校验、JSON 报告），校验报告字段全部为正后丢弃冒烟产物；`test` 阶段只
对已验证的组合计时。

## 性能测试

基准负载采用 Spring 官方文档的 WebFlux 函数式端点模式（WebFlux Fn）：
`RouterFunctions.route().POST("/echo", ...)` 注册一个把请求负载原样
回显的 handler，经 `RouterFunctions.toWebHandler()` 构建完整 WebFlux
处理链。每个“请求”通过官方 `spring-test` 制品中的
`MockServerWebExchange` / `MockServerHttpRequest` 驱动（Spring 官方
框架测试所用的同一设施），完整经过框架管道：路由匹配、ServerRequest
构建、请求体解码（ByteArrayDecoder）、handler 调用、响应序列化与
Reactive 调度，但不含任何网络传输——被测对象是 Spring Framework
管道本身，而非第三方 HTTP 服务器栈（与 netty / grpc-java 用例专注
各自官方栈的哲学一致）。

负载形态：固定数量驱动线程（默认 16，`SPRING_DRIVERS` 可覆盖）通过
信号量窗口维持全局固定并发（并发阶梯档位即 in-flight exchange 数）；
每个 exchange 完成后立即补充下一个。请求为固定大小帧：
`[序列号 8B][发送纳秒时间戳 8B][零填充]`，客户端校验回显序列号并按
1/1024 全局节拍采样 RTT；任何序列号不匹配、长度不匹配或 exchange
错误即判失败。

场景矩阵以 mysql 用例的阶梯方式组织：**消息大小（1KiB / 16KiB）×
并发 exchange 数（128 / 256 / 512 / 1024）**，共 8 组，每组独立
JVM 进程（预热 5 秒 + 测量 30 秒，`SPRING_WARMUP_SECONDS` /
`SPRING_DURATION_SECONDS` 可覆盖）：

```bash
java -Xms2g -Xmx2g -cp "spring-lib/*:classes" \
  org.boostkit.performance.spring.SpringEchoBenchmark \
  --message-size 1024 --concurrency 128 --drivers 16 \
  --warmup-seconds 5 --duration-seconds 30 \
  --scenario "echo 1KiB" --output benchmark/runs/echo-1k-c128.json
```

每组运行输出一个 JSON 报告，完整控制台输出保留为
`spring_echo_raw.log`，全部报告由 `scripts/collect_spring_benchmark.py`
校验（场景、消息大小、并发数与文件名一致，所有数值为正）并汇总为
`results.json`。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/spring/spring_test.sh \
  --version 7.0.9 \
  --results-dir /home/runner/boostkit-perf/spring/results/7.0.9
```

## 指标

每个“场景 + 并发档位”组合保留 3 个字段，不做平均、加权或跨场景
聚合。总计为：

```text
2 个消息大小场景 × 4 个并发档位 × 3 个指标 = 24 个指标
```

| 基准字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `exchanges_per_second` | `Spring echo <场景> --concurrency=<并发数>: exchanges/s` | exchanges/s | 越大越好 | 每秒完成的 WebFlux echo exchange 数 |
| `avg_rtt_ms` | `Spring echo <场景> --concurrency=<并发数>: avg RTT` | ms | 越小越好 | 采样 exchange 的平均往返时延 |
| `p99_rtt_ms` | `Spring echo <场景> --concurrency=<并发数>: p99 RTT` | ms | 越小越好 | 采样 exchange 往返时延的 99 分位 |

报告按消息大小场景（echo 1KiB / echo 16KiB）分组；每个场景中再按
并发 exchange 数展示吞吐与两项时延，便于在相同负载下比较 x86_64 与
aarch64。基准参数（WebFlux Fn 管道、驱动线程数、预热与测量时长）
记录在 `results.json` 的 `parameters` 部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `spring_echo_raw.log`：8 组运行的原始控制台输出；
- `results.json`：24 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务（基准生命周期在各测量进程内），仅
移除本次任务的基准数据目录（运行报告与冒烟产物）。Standalone 模式
结束时还会删除本次任务专属的 `/home/runner/boostkit-perf/spring/local-*`
工作目录（含官方 jar、编译类文件与运行数据）；Framework 随后执行
Runner 级环境清理。
