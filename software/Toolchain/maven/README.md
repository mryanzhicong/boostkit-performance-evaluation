# maven

Apache Maven 3.10.0 构建工具性能用例。完整口径为**系统化构建矩阵 + 上游工程 self-build**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **3.10.0** |
| 上游标签 | `apache/maven` `refs/tags/maven-3.10.0` = `01e4f71127bfac5b20fc2aeeeed4311ec132493f` |
| 二进制制品 | `apache-maven-3.10.0-bin.tar.gz`（官方分发包，架构无关）<br>`https://archive.apache.org/dist/maven/maven-3/3.10.0/binaries/apache-maven-3.10.0-bin.tar.gz`<br>SHA-512 `908b1501bfb420bf7c8affb855534a9c407fd6099367bfb9f2f2dcb8e9799102bffb84518cde74c679bd76870247c6528683abdd620581bffa90f95d92d175aa` |
| 源码制品（self-build 用） | `apache-maven-3.10.0-src.tar.gz`<br>`https://archive.apache.org/dist/maven/maven-3/3.10.0/source/apache-maven-3.10.0-src.tar.gz`<br>SHA-512 `5b95db2740e5e11c29ce372541c4e00829ad58ca490749c9810aacb9ea1855166d85734cbf6ed4c178001eddba3719ed912807dfe1aa8f9036f09d862aa1d05c` |
| 运行时 JDK（固定） | Eclipse Temurin **21.0.13+9**（`test_tools.temurin_jdk`） |
| JDK x86_64 | `OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz`<br>`https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz`<br>SHA-256 `d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c` |
| JDK aarch64 | `OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz`<br>`https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz`<br>SHA-256 `e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578` |

Maven 是纯 Java 发行版，**两个架构使用同一归档**，架构差异只体现在固定版本的 JDK 归档选择上。所有下载都核对官方校验值；校验失败即 `build` 失败，不降级、不跳过。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验/安装系统依赖（`curl`、`tar`、`gzip`、`gawk`、coreutils）；Runner 通过 `sudo -n dnf` 补齐，代理来自 `PERF_PROXY`。
2. 解包固定版本 Temurin JDK 到 `$PERF_WORK_DIR/jdk-install`，`JAVA_HOME` 只指向它，不使用 Runner 系统 JDK。
3. 解包 Maven 分发包到 `$PERF_WORK_DIR/maven-install`，`mvn -v` 解析出的实际版本必须等于 `3.10.0`，否则 `build` 失败（框架据 `actual-version.txt` 校验）。
4. 生成确定性的 100 / 1,000 / 10,000 类工程到 `$PERF_WORK_DIR/projects/`。
5. **联网预热**（不计入测量）：用 100 类工程填充私有本地仓库 `$PERF_WORK_DIR/m2repo`；再对上游 Maven 源码执行一次 `package`，完成 self-build 依赖预取。
6. 退出前写出 `build_variant.json`。

离线包约定：将下列文件预置到 `/home/runner/software/maven/` 时优先使用并强制校验，缺失才联网下载：
`apache-maven-3.10.0-bin.tar.gz`、`apache-maven-3.10.0-src.tar.gz`、`OpenJDK21U-jdk_{x64,aarch64}_linux_hotspot_21.0.13_9.tar.gz`。

## 3. 完整测试口径

Maven **没有上游性能基准套件**。官方 `apache/maven-integration-testing` 的 core IT suite 是正确性套件（700+ 用例、按 Maven 版本耦合、不以计时为设计目标），把它当作性能口径会产生不可复现且不可解释的数字，因此本用例不采用，改用以下**系统化矩阵 + 上游工程负载**：

| 场景 | 任务 | 规模 | 说明 |
|---|---|---|---|
| `clean_package_100` | `clean package` | 100 类 | 全量构建 |
| `incremental_package_100` | 改 1 个源文件后 `package` | 100 类 | 增量构建 |
| `noop_package_100` | 无改动 `package` | 100 类 | 无变更构建 |
| `clean_package_1000` | `clean package` | 1,000 类 | 全量构建 |
| `incremental_package_1000` | 改 1 个源文件后 `package` | 1,000 类 | 增量构建 |
| `noop_package_1000` | 无改动 `package` | 1,000 类 | 无变更构建 |
| `clean_package_10000` | `clean package` | 10,000 类 | 全量构建 |
| `incremental_package_10000` | 改 1 个源文件后 `package` | 10,000 类 | 增量构建 |
| `noop_package_10000` | 无改动 `package` | 10,000 类 | 无变更构建 |
| `maven_self_build` | `clean package` | 上游 Maven 全模块 | 上游工程负载（`-DskipTests -Drat.skip -Dmaven.javadoc.skip -Dmaven.source.skip -Dcheckstyle.skip`） |

固定条件：

- 统一 `mvn -B -o -ntp -Dstyle.color=never -Dmaven.repo.local=<私有仓库>`：**全部离线**，排除网络抖动与首次依赖下载；
- 默认 JVM 参数，`MAVEN_OPTS` 为空，不设 `-Xmx`、不加 `-XX` 调优、不加 `-march`；
- 每场景 **1 次预热 + 5 次独立正式测量**，报告**中位数**，同时保留每次样本、最小值、最大值、均值与标准差；
- 增量场景每次只 `touch` 一个源文件，no-op 场景不做任何修改——这两者反映构建工具的真实行为，不人为制造无效工作；
- `maven-compiler-plugin` 的"增量"语义是**有任一源文件变更即整体重编译**（并非逐文件增量），因此 `incremental_package_*` 与 `clean_package_*` 墙钟接近，差异主要来自跳过 `clean` 与复用已解析插件；这是 Maven 的真实行为，不做人为改造。

工程由 `scripts/generate_project.py` 确定性生成（无第三方依赖的纯 jar 工程），源码随用例提交，可离线复现。本机 x86_64 链路验证（`PERF_REPS=1`、热缓存）实测单次消耗：100 类约 1.5–1.9 s，1,000 类约 1.6–2.7 s，10,000 类约 1.9–5.1 s，上游 self-build 约 18 s。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好 | `scripts/run_timed.py` 测得的单次 Maven 子进程墙钟，取 5 次中位数 |
| `<场景>_rss` | `MiB` | 越低越好 | 同一子进程的 `ru_maxrss`，取 5 次中位数 |

共 10 个场景 × 2 项 = 20 个指标，全部由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合；任一场景缺样本、`exit_code != 0`、数值非有限或非正即解析失败，`test` 阶段返回非零，不补零、不估算。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。x86_64 不在本轮适配范围（用户指令），因此本文档与 PR 不提供也不宣称跨架构对比结论。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 运行 → 解析 → 报告），产出**不是**性能结论。
- 脚本保持架构无关：仅用 `uname -m` 选择 JDK 归档，不使用 x86 专用编译参数或 intrinsics。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: maven
version: 3.10.0
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_WORK_DIR=$HOME/maven-work        # 可选；默认 /home/runner/boostkit-perf
export PERF_REPS=5                          # 默认 5；本机链路验证可临时降低并记录
bash software/Toolchain/maven/maven_test.sh \
  --version 3.10.0 --variant base --results-dir "$HOME/maven-results"
```

`optimized` 变体尚未实现：`maven_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base。

可选环境变量（默认全部不设置，CI 走 Maven 自身 POM 声明的官方仓库，不加任何 mirror）：

| 变量 | 作用 |
|---|---|
| `PERF_MAVEN_SETTINGS` | 指向一个 `settings.xml`，构建阶段与测量阶段都会透传 `-s <file>`。仅用于内网/离线环境无法直连 Maven Central 的场合（例如本机 WSL 验证用镜像）；不设置时行为与 CI 完全一致 |
| `PERF_MAVEN_OFFLINE_DIR` → `MAVEN_OFFLINE_DIR` | 覆盖离线包目录，默认 `/home/runner/software/maven` |
| `PERF_REPS` | 独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`runs/`（每次原始日志与计时 JSON）。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 Maven 负载是"固定 100 类 clean package / 增量 package"，属于**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"，其 111 实测值不迁移进仓库、不作为性能结论。本用例把它作为矩阵的一个子集（`clean_package_100` / `incremental_package_100`）保留，但真正的性能证据是包含 1k/10k、no-op 与上游 self-build 且每场景 5 次中位数的完整口径。

## 8. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报哈希不匹配 | 检查 `/home/runner/software/maven/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `mvn -v` 版本不等于 3.10.0 | 预置包版本错误，或 `MAVEN_HOME` 残留旧解包；清理 `$PERF_WORK_DIR/maven-install` |
| 测量阶段离线解析失败 | build 阶段预取不完整（自建工程或 self-build 插件），查看 `command-build.log` |
| `clean_package_10000` 超时 | 检查磁盘与内存余量；该场景单次约 5 s，5 次约 30 s（本机 x86_64 实测） |
| `self_build` 首次预取很慢 | `build` 阶段首次要联网下载约 200 MB 依赖并跑一遍全量 self-build，本机实测约 15 min，属正常 |
| 解析报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`；中途失败的 rep 会保留日志 |

## 9. 许可证

Apache Maven 采用 Apache License 2.0；Temurin JDK 采用 GPLv2 + Classpath Exception。本用例自带的工程生成器与计时/解析脚本为本仓库原创，遵循仓库既有许可。
