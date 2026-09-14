# Apache Tomcat 性能测试说明

本目录测试 Apache Tomcat 官方二进制发行版，运行于固定版本的 Eclipse
Temurin GA JDK 之上，并使用官方 k6 发布版作为负载发生器，对静态文件
与官方自带 servlet 进行 x86_64 与 aarch64 开箱性能对比。软件入口为
`tomcat_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 Tomcat `11.0.25`（主线最新版）。新增版本时，必须同时
在 `tomcat_test.sh` 中声明官方发行包文件名及其 SHA-512，不能跳过校验。

## 构建与安装

这里的“构建”是部署官方二进制发行版并布置固定的 JVM 运行时，不从源码
编译 Tomcat，也不安装系统级 Tomcat 软件包：

1. 从官方地址 `https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.25/bin/
   apache-tomcat-11.0.25.tar.gz` 获取发行包（依次使用
   `/home/runner/software/tomcat/` 本地离线包、当前任务工作目录中的
   同名缓存包、官方下载地址）；
2. 使用清单中声明的官方 SHA-512 校验包完整性（发行包为纯 Java 归档，
   双架构通用），校验失败立即退出；
3. 解压到本次任务的 `PERF_WORK_DIR/tomcat`，并用固定 JVM 运行时验证
   版本：

   ```bash
   "${JAVA_BIN}" -version   # Temurin 25.0.4.1 GA
   "${JAVA_BIN}" -cp "${TOMCAT_HOME}/lib/catalina.jar" \
     org.apache.catalina.util.ServerInfo   # Server version: Apache Tomcat/11.0.25
   ```

JVM 运行时采用 Eclipse Temurin GA `jdk-25.0.4.1+1`（openjdk 用例引导
JDK 的同款来源），按架构选择官方预编译包并以 SHA-256 校验，解压到
`PERF_WORK_DIR/jdk`，不触碰系统 Java。负载发生器 k6 复用 envoy/nginx
用例的获取方式：官方 GitHub Release 预编译二进制 `k6 v2.2.0`（按架构
选择，SHA-256 校验；支持 `PERF_GITHUB_DOWNLOAD_PROXY` 下载代理，同样
可从 `/home/runner/software/tomcat/` 离线预置）。

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/tomcat
sudo install -o runner -g runner apache-tomcat-11.0.25.tar.gz \
  /home/runner/software/tomcat/
sudo install -o runner -g runner \
  OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.4.1_1.tar.gz \
  /home/runner/software/tomcat/
sha512sum /home/runner/software/tomcat/apache-tomcat-11.0.25.tar.gz
```

## 服务启动

`start` 阶段组装并启动一个一次性 Tomcat 实例：

1. 在任务私有 `PERF_WORK_DIR/catalina-base` 组装 `CATALINA_BASE`：复制
   官方 `conf/` 与 `webapps/`（ROOT、docs、examples、host-manager、
   manager，保持官方发行版原样）；
2. 对官方 `server.xml` 仅注入本次任务的端口（HTTP 与 shutdown 端口均由
   运行 ID 稳定派生，与 mysql/nginx 用例相同的 cksum 派生方式），其余
   配置保持官方默认（连接器 `maxThreads=200`、`maxConnections=8192`、
   `acceptCount=100` 等均为官方出厂值）；
3. 生成确定性静态文件：`file-1k.bin`（1 KiB）与 `file-100k.bin`
   （100 KiB），内容为零填充，放在默认 ROOT 应用下，逐文件校验字节数；
4. JVM 以固定堆 `-Xms1g -Xmx1g`（`JVM_HEAP_SIZE` 可覆盖）启动，避免
   堆动态扩展引入噪声，其余 JVM 选项保持默认；
5. 启动前先探测端口，若已有服务在监听则拒绝启动；启动后轮询就绪，
   并逐场景冒烟：两个静态文件按字节校验，官方 examples webapp 的
   `HelloWorldExample` servlet 要求 HTTP 200。

核心启动与冒烟命令如下（路径、端口由任务运行时生成）：

```bash
export CATALINA_BASE="${PERF_WORK_DIR}/catalina-base"
export CATALINA_HOME="${PERF_WORK_DIR}/tomcat"
export CATALINA_PID="${CATALINA_BASE}/tomcat.pid"
export CATALINA_OPTS="-Xms1g -Xmx1g"
export JAVA_HOME="${PERF_WORK_DIR}/jdk"
"${CATALINA_HOME}/bin/startup.sh"

curl -sf "http://127.0.0.1:${TOMCAT_PORT}/file-1k.bin" | wc -c      # == 1024
curl -sf -o /dev/null \
  "http://127.0.0.1:${TOMCAT_PORT}/examples/servlets/servlet/HelloWorldExample"
```

## 性能测试

测试采用固定版本的官方负载发生器，以 mysql 用例的并发阶梯方式执行。
场景覆盖 Servlet 容器的两类核心负载：

| 场景 | 负载来源 |
|---|---|
| `static 1KiB` / `static 100KiB` | 默认 ROOT 应用下的确定性静态文件 |
| `servlet hello` | 官方 examples webapp 自带的 `HelloWorldExample` servlet |

正式流程如下：

1. 三个场景每档并发按 128、256、512、1024 VU 阶梯执行（对应 mysql 的
   线程阶梯）；
2. 每次运行固定时长 30 秒（`K6_DURATION_SECONDS` 可覆盖），HTTP
   keepalive 连接复用（k6 默认行为，且每个 VU 持有独立 cookie jar，
   servlet 的 session 语义即每 VU 一个会话）；
3. k6 汇总导出为 JSON，保留 `http_reqs.rate`、`http_req_duration.avg`、
   `http_req_duration.p(95)` 三个字段，要求 `http_req_failed.rate`
   必须为 0（任何失败请求即判失败）；
4. 完整控制台输出保留为 `tomcat_k6_raw.log`，结构化结果汇总为
   `results.json`。

实际执行命令形态如下：

```bash
k6 run --vus 128 --duration 30s \
  --summary-export benchmark_servlet_hello_vus128_summary.json \
  tomcat_k6_request.js  # TOMCAT_TARGET=http://127.0.0.1:<port>/examples/servlets/servlet/HelloWorldExample
```

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/tomcat/tomcat_test.sh \
  --version 11.0.25 \
  --results-dir /home/runner/boostkit-perf/tomcat/results/11.0.25
```

## 指标

每个“场景 + 并发档位”组合保留 3 个字段，不做平均、加权或跨场景聚合。
总计为：

```text
（2 个静态场景 + 1 个 servlet 场景）× 4 个并发档位 × 3 个指标 = 36 个指标
```

| k6 汇总字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `http_reqs.rate` | `k6 <场景> --vus=<并发>: RPS` | requests/s | 越大越好 | 每秒完成的请求数 |
| `http_req_duration.avg` | `k6 <场景> --vus=<并发>: avg latency` | ms | 越小越好 | 请求延迟平均值 |
| `http_req_duration.p(95)` | `k6 <场景> --vus=<并发>: p95 latency` | ms | 越小越好 | 请求延迟 95 分位 |

报告按场景（static 1KiB / static 100KiB / servlet hello）分组；每个
场景中再按并发 VU 数展示 RPS 与两项延迟，便于在相同负载下比较 x86_64
与 aarch64。测试工具及其固定版本（Temurin JDK `25.0.4.1`、k6 `2.2.0`）
会同时列在报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `tomcat_k6_raw.log`：k6 原始控制台输出（含每档运行的完整输出）；
- `results.json`：36 个结构化指标及其来源文件名。

`stop` 阶段优先通过官方 `shutdown.sh`（5 秒宽限）优雅关闭本次实例，
必要时对 `CATALINA_PID` 执行 SIGTERM→SIGKILL 兜底，确认端口不可达后
移除本次 `CATALINA_BASE`（配置、webapps 与日志）。Standalone 模式结束
时还会删除本次任务专属的 `/home/runner/boostkit-perf/tomcat/local-*`
工作目录（含 Tomcat 发行版、JDK 与 k6）；Framework 随后执行 Runner 级
环境清理。
