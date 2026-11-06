# maven

Apache Maven 3.10.0 构建工具性能用例。完整口径为**系统化构建矩阵 + 上游工程 self-build**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **3.10.0** |
| 上游标签 | `apache/maven` `refs/tags/maven-3.10.0` = `01e4f71127bfac5b20fc2aeeeed4311ec132493f` |
| 二进制制品 | `apache-maven-3.10.0-bin.tar.gz`（官方分发包，架构无关）<br>`https://archive.apache.org/dist/maven/maven-3/3.10.0/binaries/apache-maven-3.10.0-bin.tar.gz`<br>SHA-512 `908b1501bfb420bf7c8affb855534a9c407fd6099367bfb9f2f2dcb8e9799102bffb84518cde74c679bd76870247c6528683abdd620581bffa90f95d92d175aa` |
| 源码制品（self-build 用） | `apache-maven-3.10.0-src.tar.gz`<br>`https://archive.apache.org/dist/maven/maven-3/3.10.0/source/apache-maven-3.10.0-src.tar.gz`<br>SHA-512 `5b95db2740e5e11c29ce372541c4e00829ad58ca490749c9810aacb9ea1855166d85734cbf6ed4c178001eddba3719ed912807dfe1aa8f9036f09d862aa1d05c` |
| 运行时 JDK（容器内） | **`java-21-openjdk-headless`/`-devel`**（openEuler 24.03 LTS SP4 固定为 `1:21.0.12.8-4.oe2403sp4`；`test_tools.openjdk`，实际版本作为运行上下文记录）<br>不再从宿主下载 JDK 归档 |
| 执行环境 | 私有 openEuler 24.03 LTS SP4 容器 `boostkit-maven-<arch>-<run-id>` |

Maven 是纯 Java 发行版，**两个架构使用同一归档**，架构差异只体现在容器镜像与容器内 JDK 包的架构适配上。所有下载都核对官方校验值；校验失败即 `build` 失败，不降级、不跳过。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 启动本 run 的私有 openEuler 24.03 LTS SP4 容器（见第 8 节）；宿主只保留 docker 与下载/校验工具（`curl`、`tar`、`gzip`、`sha256sum`、`sha512sum`、`gawk`、coreutils、`python3`）。
2. 容器内 `dnf install -y --setopt=install_weak_deps=False java-21-openjdk-headless java-21-openjdk-devel tar gzip coreutils findutils which`（关闭弱依赖：java-devel 的弱依赖 dbus-daemon 在只读 `/etc/passwd` 的容器里装不上），装后 `command -v java/javac` 自检。
3. 容器内 `readlink -f $(command -v javac)` 解析 `JAVA_HOME` 并写入 `$PERF_WORK_DIR/container-jdk-home.txt`；`java -version` 主版本必须是 21，`JAVA_HOME` 只指向容器 JDK，不使用 Runner 系统 JDK。
4. 容器内解包 Maven 分发包到 `$PERF_WORK_DIR/maven-install`，容器内 `mvn -v` 解析出的实际版本必须等于 `3.10.0`，否则 `build` 失败（框架据 `actual-version.txt` 校验）。
5. 容器内生成确定性的 100 / 1,000 / 10,000 类工程到 `$PERF_WORK_DIR/projects/`。
6. **联网预热**（不计入测量，均在容器内）：用 100 类工程填充私有本地仓库 `$PERF_WORK_DIR/m2repo`（`-Dmaven.repo.local` 显式传入，不使用 `~/.m2`）；再对上游 Maven 源码执行一次 `package`，完成 self-build 依赖预取。
7. 退出前写出 `build_variant.json` 与容器 JDK release 记录（`$PERF_WORK_DIR/container-jdk-release.txt`，供宿主解析器记录运行上下文）。

离线包约定：将下列文件预置到 `/home/runner/software/maven/` 时优先使用并强制校验，缺失才联网下载：
`apache-maven-3.10.0-bin.tar.gz`、`apache-maven-3.10.0-src.tar.gz`（JDK 由容器镜像提供，不需要离线归档）。

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

## 8. 容器化执行

- **容器**：每个 run 一个 `boostkit-maven-<arch>-<run-id>`，标签
  `boostkit.maven.run-id=<run-id>`；`start_maven_container` 拒绝复用已存在的同名
  容器，`sweep_maven_stale_containers` 只清理同前缀且标签不属于本 run 的残留容器。
- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，
  缺失时从 `repo.openeuler.org` 下载；校验同名 `.sha256sum`、镜像架构与
  `/etc/os-release` 的 `24.03` 标识后 `docker load`。
- **挂载**：`PERF_WORK_DIR`（容器 `HOME=$PERF_WORK_DIR/home`、`TMPDIR` 同宿主）、
  `RESULTS_DIR`、用例目录（结果目录在用例目录内时去掉 `readonly`）、`/etc/passwd`、
  `/etc/group`；网络为 host（build 阶段预热依赖需要联网，测量阶段全部 `-o` 离线）；
  容器以宿主 uid:gid 运行，不需要 `--privileged`。
- **JDK 与缓存**：`JAVA_HOME` 来自容器内解析并持久化；私有本地仓库固定为
  `$PERF_WORK_DIR/m2repo`，由 `maven_container_env_exec(_at)` 以
  `-Dmaven.repo.local` 显式传入，既不读宿主的 `~/.m2`，也不会写进容器可写层。
- **宿主职责**：docker、下载并校验 Maven 发行版/源码归档、framework、严格解析器；
  解包、工程生成、`mvn -v`、预热 self-build、`run_timed.py` 计时驱动与全部测量
  子进程都在容器内执行，因此 `docker exec` 开销不进入采样窗口。
- **与整机执行的差异**：宿主不再安装 JDK，`java`/`mvn` 只在容器内可见；独立运行
  `maven_test.sh` 需要可用的 docker daemon，否则 build 返回 30。
- **清理**：stop 阶段先 `remove_maven_container`（仅本 run 标签，幂等）再清理标记文件。

### 8.1 容器相关故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 `container package installation failed` | 多为容器内 dnf 装 java-21-openjdk-devel 时弱依赖 `dbus-daemon` scriptlet 失败（`/etc/passwd` 只读挂载）；确认已带 `--setopt=install_weak_deps=False`，并查看 `docker logs` / `command-build.log` 的 dnf 输出 |
| `requested Maven 3.10.0 but installed: <unknown>` | 容器内 `mvn -v` 探测被管道提前关闭（SIGPIPE）导致输出丢失；版本解析必须**先取完整 banner 再过滤**（本用例 `maven_version_string` 已按此实现） |
| `mvn -v` 版本不等于 3.10.0 | 预置包版本错误，或 `MAVEN_HOME` 残留旧解包；清理 `$PERF_WORK_DIR/maven-install` |
| 解析结果 `jdk_release` 为 `unknown` | 宿主解析器优先读 `$PERF_WORK_DIR/container-jdk-release.txt`；检查 build 阶段是否成功写出该文件 |
| `cannot resolve javac inside the private container` | 容器内 JDK 包未装成功；检查 dnf 段日志与 `command -v javac` 自检输出 |

## 9. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报哈希不匹配 | 检查 `/home/runner/software/maven/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `mvn -v` 版本不等于 3.10.0 | 预置包版本错误，或 `MAVEN_HOME` 残留旧解包；清理 `$PERF_WORK_DIR/maven-install` |
| 测量阶段离线解析失败 | build 阶段预取不完整（自建工程或 self-build 插件），查看 `command-build.log` |
| `clean_package_10000` 超时 | 检查磁盘与内存余量；该场景单次约 5 s，5 次约 30 s（本机 x86_64 实测） |
| `self_build` 首次预取很慢 | `build` 阶段首次要联网下载约 200 MB 依赖并跑一遍全量 self-build，本机实测约 15 min，属正常 |
| 解析报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`；中途失败的 rep 会保留日志 |
| 容器相关 | 先看第 8.1 节；`docker ps -a --filter name=boostkit-maven-` 不应有残留容器（stop 阶段幂等删除） |

## 10. 许可证

Apache Maven 采用 Apache License 2.0；容器内 OpenJDK 21（openEuler 构建）采用 GPLv2 + Classpath Exception。本用例自带的工程生成器与计时/解析脚本为本仓库原创，遵循仓库既有许可。
