# jenkins

Jenkins **2.588** 控制器性能用例。完整口径为**控制器启动矩阵 + 构建吞吐矩阵 + REST API 遍历矩阵**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **2.588**（weekly） |
| 官方 war | `jenkins.war`（架构无关，官方发行包）<br>`https://get.jenkins.io/war/2.588/jenkins.war`<br>大小 `52,583,800` 字节<br>SHA-256 `e84790335e973f1c051f32cb1e64808049a31a17dbeaa98014937842710bf37a` |
| 官方校验文件 | `https://get.jenkins.io/war/2.588/jenkins.war.sha256`（内容即上面的 SHA-256，构建阶段强制比对） |
| 备用下载源（war） | 顺序：预置离线包 → `mirrors.huaweicloud.com/jenkins` → `mirrors.tuna.tsinghua.edu.cn/jenkins` → `mirrors.aliyun.com/jenkins` → `gh-proxy.com` / `ghfast.top` 代理的 GitHub release → 官方 `get.jenkins.io`（最后一个）。镜像只影响下载速度；**校验值始终是上表的固定 SHA-256**，任一源不符即丢弃并尝试下一个，全部失败则 `build` 退出 30 并打印所有尝试过的 URL |
| 运行时 JDK（容器内） | **`java-21-openjdk-headless`/`-devel`**（openEuler 24.03 LTS SP4 固定为 `1:21.0.12.8-4.oe2403sp4`；`test_tools.openjdk`，实际版本作为运行上下文记录）<br>不再从宿主下载 JDK 归档 |
| 执行环境 | 私有 openEuler 24.03 LTS SP4 容器 `boostkit-jenkins-<arch>-<run-id>`（控制器 JVM 也运行在容器内） |

Jenkins war 与架构无关，两个架构的差异只体现在容器镜像与容器内 JDK 包的架构适配上。`build` 阶段下载后同时校验**文件大小与 SHA-256**，任一不符即失败，不降级、不跳过。

JDK 选型说明：Jenkins 2.588 支持 Java 17/21/25。本用例固定容器内 **OpenJDK 21**（与同仓库 Maven/Scala/Gradle 用例同一容器基线），使 JVM 类用例的 Java 基线可直接比较；旧交付冒烟（`14-Jenkins.md`）使用 Temurin 25 的 3 次采样仅作链路验证，不迁移为结论（见第 7 节）。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 启动本 run 的私有 openEuler 24.03 LTS SP4 容器（见第 8 节「容器化执行」）；宿主只保留 docker 与下载/校验工具（`curl`、`tar`、`gzip`、`sha256sum`、`gawk`、coreutils 的 `stat`/`cksum`/`timeout`、`python3`）。
2. 容器内 `dnf install -y --setopt=install_weak_deps=False java-21-openjdk-headless java-21-openjdk-devel tar gzip coreutils findutils which procps-ng`（关闭弱依赖：java-devel 的弱依赖 dbus-daemon 在只读 `/etc/passwd` 的容器里装不上），装后 `command -v java/javac/pgrep` 自检。
3. 容器内 `readlink -f $(command -v javac)` 解析 `JAVA_HOME` 并写入 `$PERF_WORK_DIR/container-jdk-home.txt`；`java -version` 主版本必须是 21。`JAVA_HOME` 最终只指向容器 JDK。
4. 校验并落位官方 `jenkins.war`（大小 + SHA-256，宿主下载），**在容器内**用 `java -jar jenkins.war --version` 读取真实版本（带 120 s 硬超时），必须等于 `2.588`，否则 `build` 失败（框架据 `actual-version.txt` 校验）。
5. **创建初始化 `JENKINS_HOME` 模板**：**在容器内**启动一次控制器直到 REST API 就绪（不计入测量），再干净关机，把该 home 拷贝为 `$PERF_WORK_DIR/jenkins-home-template`。这一步同时证明官方 war 能在容器 JDK 上真实启动；整步有 `JENKINS_TEMPLATE_TIMEOUT_SECONDS`（默认 240 s）硬超时，超时/失败会打印 `runs/template/prepare.log` 尾部 40 行。
6. 退出前写出 `build_variant.json`。

### 网络与超时策略（Runner 现实约束）

> 背景：aarch64 自建 Runner **无法稳定访问 github.com / get.jenkins.io**，且连接会被"黑洞"（既不完成也不 RST，而不是快速失败）。Actions 运行 `41389053397` 的 build 阶段就卡在 Temurin JDK 的 GitHub 下载上（日志停在 `downloading https://github.com/adoptium/...`，46 分钟无输出后被人工取消）。因此本用例把"下载 + 启动"全部改成**有界**行为：

| 环节 | 约束 | 默认值 / 环境变量 |
|---|---|---|
| 单个下载源 | `timeout` 外层 + `curl --max-time` + `--connect-timeout 10` + 低速检测（<20 KB/s 持续 30 s 即中止） | `JENKINS_DOWNLOAD_ATTEMPT_SECONDS=240`、`JENKINS_STALL_BYTES_PER_SECOND=20000`、`JENKINS_STALL_SECONDS=30` |
| 全部下载源合计 | 共享预算；耗尽立即失败并打印已尝试 URL | `JENKINS_DOWNLOAD_BUDGET_SECONDS=480` |
| 整个 build 阶段 | 各步骤前检查剩余预算；耗尽 → 退出 30（Framework 记为 build 失败） | `JENKINS_BUILD_BUDGET_SECONDS=600`（≈10 分钟） |
| `jenkins.war --version` | 硬超时 | `JENKINS_VERSION_PROBE_TIMEOUT_SECONDS=120` |
| 模板控制器启动 | 驱动 SIGALRM 看门狗 + 外层 `timeout`；失败打印驱动日志尾部 40 行 | `JENKINS_TEMPLATE_TIMEOUT_SECONDS=240` |
| 单个测量样本 | 驱动 SIGALRM 看门狗（可优雅停控制器）+ 外层 `timeout`；失败打印样本日志尾部 40 行 | `JENKINS_DRIVER_TIMEOUT_SECONDS=300` |
| 整个 test 阶段 | 共享预算；耗尽 → 退出 50 | `JENKINS_TEST_BUDGET_SECONDS=2400` |

所有下载**先落 `.part` 再改名**，每次落位后用固定 SHA-256 复核；校验失败的文件立即删除，不会进入下一步。外网完全不可达时，build 会在分钟级内以退出码 30 结束，并在日志里列出每个尝试过的来源，而不是挂起。

工作目录布局（`$PERF_WORK_DIR` 默认 `/home/runner/boostkit-perf/jenkins/local-<run-id>`）：

```text
jenkins.war                  # 校验后的官方 war
downloads/                   # 下载缓存
container-jdk-home.txt       # 容器内解析出的 JAVA_HOME
jenkins-home-template/       # 已初始化过一次的 JENKINS_HOME 模板
homes/                       # 每次测量前重置出来的 JENKINS_HOME
```

离线包约定：将下列文件预置到 `/home/runner/software/jenkins/` 时优先使用并强制校验，缺失才联网下载：

```text
jenkins.war
```

JDK 由容器镜像提供，不再需要离线 JDK 归档。

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
- **有界失败**：下载、版本探测、模板启动、单个样本与整个 test 阶段都有硬超时/预算（见第 2 节表）；任一超时立即失败并打印对应日志尾部 40 行，不会无限等待。解析仍 fail-closed：缺样本、超时、非零退出、wall/RSS 非有限或非正、校验不符 → `test` 退出 50，不补零不插值。
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
- 脚本保持架构无关：仅用 `uname -m` 选择容器镜像归档；war 与 freestyle shell 负载不含架构相关参数或 intrinsics。

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

本机 x86_64 链路验证（`PERF_REPS=5`、热缓存、20 核 WSL）独立入口实测中位数：`startup_cold` 2.11 s / 352 MiB，`startup_warm` 2.13 s / 389 MiB，`job_single` 0.126 s，`job_throughput_10` 0.554 s，`job_throughput_50` 0.847 s，`api_list_200` 0.104 s，`api_scan_200` 2.811 s；全流程约 2.5 分钟（含下载/校验/模板构建）。**注意**：本机同时运行其他交付验证任务时，`startup_cold` 会明显偏高（框架链路验证中有负载时实测中位数 8.7 s），因此 x86_64 数字只用于链路验证，不进入结论。

aarch64 正式运行的时间预期（有界）：`build` 在镜像可达时通常 **2–5 分钟**（Temurin 约 200 MB + war 约 52 MB 下载 + 模板启动）；若镜像不可达，最迟在 **10 分钟 build 预算**内以退出码 30 明确失败并打印所有尝试 URL。`test` 矩阵（7 场景 × (1 预热 + 5 样本)）在 aarch64 上预计 **5–10 分钟**，整个 job 远低于 240 分钟上限。Actions 运行 `41389053397` 曾因 JDK 的 GitHub 下载无界挂起 46 分钟，现已改为有界（见第 2 节"网络与超时策略"）。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 Jenkins 负载是"固定控制器 + 通过 crumb/cookie 创建 freestyle shell job、顺序触发 3 次、验证 SUCCESS"的**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"。其历史值（`startup_readiness` 7.43 s、`shell_job_trigger_to_completion` 0.345 s、`shell_job_duration` 0.279 s）来自 Temurin 25 JRE、3 次采样、带 update site 的联网环境，**不迁移进仓库、不作为性能结论**。

本用例保留冒烟负载的真实语义（启动就绪、shell job 触发到完成），但扩展为 cold/warm 启动、1/10/50 job 吞吐与 200 job REST API 遍历，每场景 5 次独立测量取中位数，并强制校验版本、build 结果与 API 返回数量。

## 8. 容器化执行

- **容器**：每个 run 一个 `boostkit-jenkins-<arch>-<run-id>`，标签
  `boostkit.jenkins.run-id=<run-id>`；`start_jenkins_container` 拒绝复用已存在的
  同名容器，`sweep_jenkins_stale_containers` 只清理同前缀且标签不属于本 run 的残留容器。
- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，
  缺失时从 `repo.openeuler.org` 下载；校验同名 `.sha256sum`、镜像架构与
  `/etc/os-release` 的 `24.03` 标识后 `docker load`。
- **挂载**：`PERF_WORK_DIR`（容器 `HOME=$PERF_WORK_DIR/home`、`TMPDIR` 同宿主）、
  `RESULTS_DIR`、用例目录（结果目录在用例目录内时去掉 `readonly`）、`/etc/passwd`、
  `/etc/group`；网络为 host（控制器监听 `127.0.0.1:<run-id 派生端口>`）；容器以宿主
  uid:gid 运行，不需要 `--privileged`。
- **服务生命周期**：本用例是服务型用例——`test` 阶段**在容器内**逐样本启动
  `jenkins.war` 控制器、等待 `/api/json` 就绪、驱动 REST 负载、再从容器内
  `/proc/<pid>/status` 读 `VmHWM`，最后停控制器；`start` 阶段只校验容器内的 JDK、
  war 与初始化模板可用，不常驻服务。
- **JDK 与 HOME**：`JAVA_HOME` 来自容器内解析并持久化；`JENKINS_HOME` 模板与每次
  样本 home 都在 `$PERF_WORK_DIR` 下（挂载目录），因此默认不写入容器可写层。
- **宿主职责**：docker、下载并校验 `jenkins.war`、framework、严格解析器；版本探测、
  模板启动、驱动与全部控制器 JVM 都在容器内执行。
- **与整机执行的差异**：宿主不再安装 JDK，`java` 只在容器内可见；独立运行
  `jenkins_test.sh` 需要可用的 docker daemon，否则 build 返回 30。
- **清理**：stop 阶段顺序为「先停服务、再删容器」——先在容器内 `pkill` 残留控制器
  （仅匹配本 run 派生端口），再 `remove_jenkins_container`（仅本 run 标签，幂等），
  最后清理 `homes/`。

### 8.1 容器相关故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 `container package installation failed` | 多为 dnf 装 java-21-openjdk-devel 时弱依赖 `dbus-daemon` scriptlet 失败（`/etc/passwd` 只读挂载）；确认已带 `--setopt=install_weak_deps=False`，并查看 dnf 输出 |
| `cannot resolve javac inside the private container` | 容器内 JDK 包未装成功；检查 dnf 段日志与 `command -v javac` 自检输出 |
| 版本探测输出被截断、war 版本报空 | 管道提前关闭导致容器内 JVM 被 SIGPIPE 杀死；探测必须**先取完整输出再解析**（本用例 `jenkins_container_env_exec ... --version` 整段捕获） |
| 控制器就绪超时 | 容器网络为 host，`127.0.0.1:<端口>` 应可直连；查看 `runs/<场景>/rep<i>.log` 是否 Jetty 绑定失败，并确认端口未被宿主其他进程占用 |
| stop 后仍有 `boostkit-jenkins-*` 容器 | `remove_jenkins_container` 只删本 run 标签；`docker ps -a --filter name=boostkit-jenkins-` 查看残留，属其他 run 的容器不要手工删 |
| stop 报 `refusing to remove` (rc=60) | 同名容器标签属于其他 run，说明 run-id 冲突；换 run id 重跑 |

## 9. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 长时间无输出 | 已改为有界：下载有单源超时/低速检测/总预算，模板启动与版本探测各有硬超时。若仍看到长时间无输出，说明 Runner 侧 `timeout`/`curl` 不可用（`require_commands` 会先失败）或日志未流式输出 |
| `build` 退出 30 且日志以 `ERROR: every download source failed` 结束 | 列出每个已尝试 URL；检查 Runner 到 `mirrors.huaweicloud.com` / `mirrors.tuna.tsinghua.edu.cn` / `get.jenkins.io` 的连通性，或把 war/JDK 预置到 `/home/runner/software/jenkins/`（离线包优先且同样校验 SHA-256） |
| `downloading ...` 后出现 `WARNING: download attempt failed or timed out` | 该源不可达、超时或低于 20 KB/s 被中止，会自动尝试下一个源，属预期行为 |
| 单样本超时（`did not complete within ... hard timeout`） | 驱动看门狗在 `JENKINS_DRIVER_TIMEOUT_SECONDS` 后终止样本并停控制器；`runs/<场景>/<label>.log` 尾部会打印到 job 日志，可据此判断是控制器启动慢还是 job 卡住 |
| `build` 报 sha256 不匹配 | 检查 `/home/runner/software/jenkins/` 预置 war/JDK 是否与本文档校验值一致；删除损坏缓存重试 |
| `jenkins.war --version` 不等于 2.588 | 预置包版本错误或缓存被覆盖；清理 `$PERF_WORK_DIR/downloads` 与 `jenkins.war` 重试 |
| 控制器启动超时 | 查看 `runs/<场景>/rep<i>.log` 的 Jetty/Jenkins 输出；确认端口未被占用、磁盘与内存余量充足；`startup_cold` 首次启动约 2 s（x86_64） |
| 端口被占用 | 由 run id 派生的端口冲突时，换一个 run id 重跑；`stop` 阶段会清理本 run 遗留的控制器进程 |
| 找不到初始化模板 | 先执行 `build` 阶段；`start.sh` 会明确报错，不会回退 |
| `job_*` 场景 build 未全部 SUCCESS | 查看对应 `rep<i>.log` 中的 build 队列/执行日志；驱动会列出未完成或失败的 job 名 |
| API 场景返回 job 数不符 | 检查 `runs/<场景>/rep<i>.log`；home 内 `jobs/` 配置由驱动逐次重建，若数量异常说明 home 拷贝或驱动被中断 |
| 解析报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`；中途失败的 rep 保留原始日志 |
| 容器相关 | 先看第 8.1 节；`docker ps -a --filter name=boostkit-jenkins-` 不应有本 run 的残留容器 |

## 10. 许可证

Jenkins 核心采用 MIT License；容器内 OpenJDK 21（openEuler 构建）采用 GPLv2 + Classpath Exception。本用例自带的驱动、解析与计时脚本为本仓库原创，遵循仓库既有许可。
