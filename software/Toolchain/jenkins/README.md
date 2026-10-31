# jenkins

Jenkins **2.588** 控制器性能用例。完整口径为**控制器启动矩阵 + 构建吞吐矩阵 + REST API 遍历矩阵**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **2.588**（weekly） |
| 官方 war | `jenkins.war`（架构无关，官方发行包）<br>`https://get.jenkins.io/war/2.588/jenkins.war`<br>大小 `52,583,800` 字节<br>SHA-256 `e84790335e973f1c051f32cb1e64808049a31a17dbeaa98014937842710bf37a` |
| 官方校验文件 | `https://get.jenkins.io/war/2.588/jenkins.war.sha256`（内容即上面的 SHA-256，构建阶段强制比对） |
| 备用下载源 | `https://mirrors.huaweicloud.com/jenkins/war/2.588/jenkins.war`<br>`https://mirrors.tuna.tsinghua.edu.cn/jenkins/war/2.588/jenkins.war`<br>`https://mirrors.aliyun.com/jenkins/war/2.588/jenkins.war`<br>镜像只影响下载速度；**校验值始终来自官方**，不一致即 `build` 失败 |
| 运行时 JDK（固定） | Eclipse Temurin **21.0.13+9**（`test_tools.temurin_jdk`） |
| JDK x86_64 | `OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz`<br>`https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz`<br>SHA-256 `d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c` |
| JDK aarch64 | `OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz`<br>`https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz`<br>SHA-256 `e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578` |

Jenkins war 与架构无关，两个架构的差异只体现在固定版本的 JDK 归档选择上。`build` 阶段下载后同时校验**文件大小与 SHA-256**，任一不符即失败，不降级、不跳过。

JDK 选型说明：Jenkins 2.588 支持 Java 17/21/25。本用例固定 **Temurin 21.0.13+9**，与同仓库 Maven 用例使用完全相同的 JDK，使两个 JVM 类用例的 Java 性能基线可直接比较；旧交付冒烟（`14-Jenkins.md`）使用 Temurin 25 的 3 次采样仅作链路验证，不迁移为结论（见第 7 节）。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验/安装系统依赖（`curl`、`tar`、`gzip`、`sha256sum`、`gawk`、coreutils 的 `stat`/`cksum`）；Runner 通过 `sudo -n dnf` 补齐，代理来自 `PERF_PROXY`。
2. 解包固定版本 Temurin JDK 到 `$PERF_WORK_DIR/jdk-21.0.13`，`JAVA_HOME` 只指向它，不使用 Runner 系统 JDK。
3. 校验并落位官方 `jenkins.war`（大小 + SHA-256），用 `java -jar jenkins.war --version` 读取真实版本，必须等于 `2.588`，否则 `build` 失败（框架据 `actual-version.txt` 校验）。
4. **创建初始化 `JENKINS_HOME` 模板**：启动一次控制器直到 REST API 就绪（不计入测量），再干净关机，把该 home 拷贝为 `$PERF_WORK_DIR/jenkins-home-template`。这一步同时证明官方 war 能在固定 JDK 上真实启动。
5. 退出前写出 `build_variant.json`。

工作目录布局（`$PERF_WORK_DIR` 默认 `/home/runner/boostkit-perf/jenkins/local-<run-id>`）：

```text
jenkins.war                  # 校验后的官方 war
downloads/                   # 下载缓存（JDK 压缩包）
jdk-21.0.13/                 # Temurin JDK
jenkins-home-template/       # 已初始化过一次的 JENKINS_HOME 模板
homes/                       # 每次测量前重置出来的 JENKINS_HOME
```

离线包约定：将下列文件预置到 `/home/runner/software/jenkins/` 时优先使用并强制校验，缺失才联网下载：

```text
jenkins.war
OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz
OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz
```

## 3. 完整测试口径

Jenkins **没有上游性能基准套件**。官方测试栈（`jenkins-test-harness`）是正确性框架，按插件依赖与 Jenkins 版本耦合、以断言而非计时为目标，不适合作为性能口径。另一方面，Jenkins war 自身启动、调度 freestyle 构建、遍历 REST API 都是真实工程行为，因此本用例采用以下**确定性矩阵**：

| 场景 | 维度 | 规模 | 测量窗口 | 校验 |
|---|---|---|---|---|
| `startup_cold` | startup | 空 home | 进程启动 → `/api/json` 首次返回 200 | `X-Jenkins` 头 = 2.588 |
| `startup_warm` | startup | 已初始化 home | 同上（跳过首次初始化） | `X-Jenkins` 头 = 2.588 |
| `job_single` | job | 1 个 freestyle shell job | 触发 → 该 build 完成 | build result = SUCCESS |
| `job_throughput_10` | job | 10 个 job | 触发第一个 → 最后一个完成 | 10/10 build = SUCCESS |
| `job_throughput_50` | job | 50 个 job | 同上 | 50/50 build = SUCCESS |
| `api_list_200` | api | 200 个 job | 连续 20 次 `GET /api/json?tree=jobs[name]` | 每次返回 200 个 job |
| `api_scan_200` | api | 200 个 job | 逐个 `GET /job/<name>/api/json` | 200/200 响应且 job 名匹配 |

固定条件：

- **每个场景每次测量都重置 `JENKINS_HOME`**：`startup_cold` 用全新空目录，其余场景从 build 阶段生成的初始化模板拷贝；重复之间不继承任何状态。
- **离线测量**：控制器以 `-Dhudson.model.UpdateCenter.updateCenterUrl=http://127.0.0.1:1/update-center.json` 启动，update site 检查立即得到 connection refused；不安装插件、不访问外网。war 内自带的核心逻辑是唯一被测对象。
- 固定 JVM：`-Xms512m -Xmx512m`、默认 G1，`-Djava.awt.headless=true`；不使用 `--enable-future-java` 或任何实验开关。
- 固定控制器端口：由 run id 派生（`18200 + cksum(run-id) % 2000`），同一 run 内所有重复复用同一端口；`startup_cold`/`startup_warm` 之外场景的服务启动与 job 创建属于**准备阶段，不计入测量窗口**。
- 仅关闭 CSRF（`-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true`）以便驱动通过 REST 创建/触发 job；该开关不改变被测量的启动、调度与 API 序列化路径。
- 每场景 **1 次预热 + 5 次独立正式测量**，报告**中位数**，同时保留每次样本、最小值、最大值、均值与标准差；任一重复缺样本、`exit_code != 0`、超时、wall/RSS 非有限或非正、校验不符即解析失败，不补零、不估算。
- 关闭 setup wizard（`-Djenkins.install.runSetupWizard=false`），home 内无安全域（匿名即管理员），避免登录/令牌校验引入非确定性。

**为什么不把"插件安装"作为独立维度**：离线安装插件必须先从 update center 解析并下载完整的传递依赖闭包（例如 timestamper 依赖 workflow-api/workflow-step-api/commons-lang3-api/antisamy-markup-formatter 等），之后还要重启激活；这样测到的主要是"我们预置的离线插件集合 + 重启"而不是 Jenkins 自身的调度/启动路径，且新增大量外部制品与 SHA-256 固定负担。初始化的 `JENKINS_HOME` 模板已经包含 boot 阶段的 war 解包与核心插件装载成本，`startup_cold` 与 `startup_warm` 的差值即为首次初始化成本。因此本用例不包含插件安装维度，这是有意的口径取舍。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好 | 驱动用 `time.monotonic` 测量的单次窗口墙钟，取 5 次中位数 |
| `<场景>_rss` | `MiB` | 越低越好 | 测量窗口结束时控制器 JVM 的 `/proc/<pid>/status` `VmHWM`，取 5 次中位数 |

共 **7 个场景 × 2 项 = 14 个指标**，全部由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合；日志中的 `RESULT scenario=... wall=... rss_kib=... checks=...` 行必须与 JSON 完全一致，作为样本完整性证据。

RSS 口径说明：只统计**控制器 JVM 自身**的峰值 RSS，不包含 Jenkins 为 shell build 拉起的短生命周期子进程（`sh`）。这是控制器常驻内存的真实口径；子进程内存因构建内容不同而波动，纳入会污染场景间对比。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 启动 → 调度 → 解析 → 报告），产出**不是**性能结论。
- 脚本保持架构无关：仅用 `uname -m` 选择 JDK 归档；war 与 freestyle shell 负载不含架构相关参数或 intrinsics。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: jenkins
version: 2.588
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_WORK_DIR=$HOME/jenkins-work        # 可选；默认 /home/runner/boostkit-perf/jenkins/local-<run-id>
export PERF_REPS=5                             # 默认 5；本机链路验证可临时降低并记录
export JENKINS_OFFLINE_DIR=/home/runner/software/jenkins   # 可选离线包目录
bash software/Toolchain/jenkins/jenkins_test.sh \
  --version 2.588 --variant base --results-dir "$HOME/jenkins-results"
```

`optimized` 变体尚未实现：`jenkins_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base，也不写 `build_variant.json`。

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`runs/`（每场景每次重复的原始日志与驱动 JSON）。成功运行后 `$PERF_WORK_DIR` 会被自动清理（`--keep-workdir` 可保留）。

本机 x86_64 链路验证（`PERF_REPS=5`、热缓存、20 核 WSL）独立入口实测中位数：`startup_cold` 2.11 s / 352 MiB，`startup_warm` 2.13 s / 389 MiB，`job_single` 0.126 s，`job_throughput_10` 0.554 s，`job_throughput_50` 0.847 s，`api_list_200` 0.104 s，`api_scan_200` 2.811 s；全流程约 2.5 分钟（含下载/校验/模板构建）。**注意**：本机同时运行其他交付验证任务时，`startup_cold` 会明显偏高（框架链路验证中有负载时实测中位数 8.7 s），因此 x86_64 数字只用于链路验证，不进入结论。aarch64 预计 3–6 分钟，其中下载官方 war（约 52 MB）与 JDK（约 200 MB）占主导。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 Jenkins 负载是"固定控制器 + 通过 crumb/cookie 创建 freestyle shell job、顺序触发 3 次、验证 SUCCESS"的**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"。其历史值（`startup_readiness` 7.43 s、`shell_job_trigger_to_completion` 0.345 s、`shell_job_duration` 0.279 s）来自 Temurin 25 JRE、3 次采样、带 update site 的联网环境，**不迁移进仓库、不作为性能结论**。

本用例保留冒烟负载的真实语义（启动就绪、shell job 触发到完成），但扩展为 cold/warm 启动、1/10/50 job 吞吐与 200 job REST API 遍历，每场景 5 次独立测量取中位数，并强制校验版本、build 结果与 API 返回数量。

## 8. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 sha256 不匹配 | 检查 `/home/runner/software/jenkins/` 预置 war/JDK 是否与本文档校验值一致；删除损坏缓存重试 |
| `jenkins.war --version` 不等于 2.588 | 预置包版本错误或缓存被覆盖；清理 `$PERF_WORK_DIR/downloads` 与 `jenkins.war` 重试 |
| 控制器启动超时 | 查看 `runs/<场景>/rep<i>.log` 的 Jetty/Jenkins 输出；确认端口未被占用、磁盘与内存余量充足；`startup_cold` 首次启动约 2 s（x86_64） |
| 端口被占用 | 由 run id 派生的端口冲突时，换一个 run id 重跑；`stop` 阶段会清理本 run 遗留的控制器进程 |
| 找不到初始化模板 | 先执行 `build` 阶段；`start.sh` 会明确报错，不会回退 |
| `job_*` 场景 build 未全部 SUCCESS | 查看对应 `rep<i>.log` 中的 build 队列/执行日志；驱动会列出未完成或失败的 job 名 |
| API 场景返回 job 数不符 | 检查 `runs/<场景>/rep<i>.log`；home 内 `jobs/` 配置由驱动逐次重建，若数量异常说明 home 拷贝或驱动被中断 |
| 解析报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`；中途失败的 rep 保留原始日志 |

## 9. 许可证

Jenkins 核心采用 MIT License；Eclipse Temurin 采用 GPLv2 + Classpath Exception。本用例自带的驱动、解析与计时脚本为本仓库原创，遵循仓库既有许可。
