# gradle

Gradle 9.8.2 构建性能用例。完整口径为**确定性多模块构建矩阵（3 种工作负载 × 3 种类规模）+ 上游 gradle/gradle 源码归档多模块工程负载**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **9.8.2** |
| 版本来源 | 交付手册 `15-Gradle.md` 指定 9.8.2；官方发行版 `gradle-9.8.2-bin.zip` |
| Gradle 发行版 | `gradle-9.8.2-bin.zip`（151,620,138 字节）<br>上游：`https://services.gradle.org/distributions/gradle-9.8.2-bin.zip`<br>镜像：`https://repo.huaweicloud.com/gradle/gradle-9.8.2-bin.zip`（首选）、`https://mirrors.cloud.tencent.com/gradle/gradle-9.8.2-bin.zip`（备选）<br>SHA-256 `21bd5da2de49b642904077f38c0efdc7778e92b3ed0889392dca61b97e389607` |
| JDK 运行时 | **Eclipse Temurin 21.0.13+9**（与本仓库 Maven 用例同一 JDK）<br>x86_64：`OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz` SHA-256 `d7f5d5cf865a2902b70ff549b97586a7d3f234e016f041ab447ea740c7d66d1c`<br>aarch64：`OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz` SHA-256 `e3522e707fc7dbe2a72c30746b1e7068301a0213ecd213d4491f35a14eb55578`<br>上游：`https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.13%2B9/` |
| 源码制品（上游工程负载） | `gradle-9.8.2-source.tar.gz`，GitHub tag 归档（tag `v9.8.2`）<br>`https://codeload.github.com/gradle/gradle/tar.gz/refs/tags/v9.8.2`<br>SHA-256 `54b41c997ff95f61e74ed257e02012ebbc855b3c4c2637837e744a82595f6d8a` |
| 上游负载来源 | 源码归档内 Gradle 官方文档/集成示例工程：`integration-tests/java/incrementalAnnotationProcessing/groovy`（3 模块：`library` / `processor` / `user`，注解处理链路）、`reference/platforms/jvm/incrementalAnnotationProcessing/groovy`（3 模块，同上）；两者都不依赖外部 Maven 仓库 |
| 离线包目录 | `/home/runner/software/gradle`（可用 `PERF_GRADLE_OFFLINE_DIR` 覆盖）；JDK 归档缺失时回退到 `/home/runner/software/maven`（可用 `PERF_GRADLE_JDK_FALLBACK_DIR` 覆盖） |

所有归档在解包前强制核对 SHA-256：不匹配、下载失败、解包失败一律 `build` 失败（返回码 30），不降级、不跳过。

关于校验值来源：本机到 `services.gradle.org` / `downloads.gradle.org` 的直连不可用，发行版实际从华为云镜像取得；其 `.sha256` 旁文件与腾讯云镜像同文件逐字节一致，且与本地复核值相同。仓库记录的是该固定 SHA-256（可用 `PERF_GRADLE_MIRROR` 覆盖镜像前缀），CI 上如官方站点可达同样按此校验值校验，不因下载源不同而放宽。

离线包约定：把下列文件预置到 `/home/runner/software/gradle/` 时优先使用并强制校验，缺失才联网下载：

```text
gradle-9.8.2-bin.zip
gradle-9.8.2-source.tar.gz
OpenJDK21U-jdk_x64_linux_hotspot_21.0.13_9.tar.gz
OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.13_9.tar.gz
```

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验系统依赖（`curl`、`unzip`、`tar`、`sha256sum`、`python3`、`awk`）；Runner 通过 `sudo -n dnf` 补齐缺失包，代理来自 `PERF_PROXY`。
2. 按 `uname -m` 选择 Temurin 21.0.13+9 归档，核对 SHA-256 后解包到 `$PERF_WORK_DIR/jdk-install`；`java -version` 必须是 21.0.13。
3. 解包 `gradle-9.8.2-bin.zip` 到 `$PERF_WORK_DIR/gradle-install`，显式 `chmod +x bin/gradle`（手册明确要求保留 ZIP 内的可执行位），复核 `gradle --version` 报 **9.8.2**。
4. 解包上游源码归档到 `$PERF_WORK_DIR/gradle-source`，复核 `settings.gradle.kts` 存在、三个固定示例工程目录齐全。
5. 用固定 Gradle 生成 100 / 1000 / 10000 类的确定性单模块 Java 工程到 `$PERF_WORK_DIR/projects/project-<n>`（同一生成器、同一模板、固定类名与内容）。
6. 预热共享的 `GRADLE_USER_HOME`（`$PERF_WORK_DIR/gradle-home`）：联网执行一次 100 类工程 `clean build`，使测量阶段不再需要解析任何外部依赖。
7. 把两个上游示例工程复制到 `$PERF_WORK_DIR/upstream-samples/`，用**与测量阶段完全相同的批次脚本**（仅去掉 `--offline`）联网执行一次全量 `build`，把所需插件/依赖元数据写入同一份 `GRADLE_USER_HOME`。批次脚本对每个工程先删除 `build/` 与工程级 `.gradle/` 缓存，保证每次都是全量多模块构建。
8. 冒烟校验（不计入测量）：离线 `clean build` 100 类工程并确认产出 jar；离线跑一遍完整上游批次并确认每个工程 `rc=0`。
9. 退出前写出 `actual-version.txt` 与 `build_variant.json`。

**测量阶段不需要网络**：所有被测命令都带 `--offline`，只读 `$PERF_WORK_DIR` 中已解包的发行版、JDK、工程与已预热的 `GRADLE_USER_HOME`。

## 3. 完整测试口径

### 3.1 为什么不用"上游基准套件"

Gradle 仓库没有面向"构建吞吐/构建耗时"的上游性能基准套件：`gradle/gradle` 自身的 `build` 是发行版发布流水线（需要网络解析大量插件、多 JDK toolchain 与 Kotlin DSL 编译），不可用作确定性测量负载；Gradle 发行的 `-bin` / `-all` 分发包也**不包含**示例工程（`-all` 只有 `bin docs init.d lib src` 等目录）。Gradle 官方的构建性能对比工具是 Gradle Profiler，它面向开发者本地剖析（不产出可比的固定指标），不是仓库内的基准套件。

因此本用例采用手册建议的**确定性构建矩阵 + 上游源码工程负载**：

- 确定性矩阵：同一生成器产出的 Java 工程，固定类数（100 / 1,000 / 10,000），固定三种工作负载（clean 全量、增量、无变更 no-op），固定 Gradle 发行版与 JDK，全程离线，可直接逐字节复现。
- 上游工程负载：从固定 tag `v9.8.2` 的 `gradle/gradle` 源码归档中取 Gradle 官方文档/集成示例的**多模块**工程（`library` + 注解生成器 `processor` + 使用注解的 `user` 三段式链路），用同一 Gradle 发行版执行全量 `build`，覆盖"真实多模块构建 + 注解处理"维度。

上游工程集合的取舍：源码归档里还有 `structuring-builds/composite-builds-basic` 复合构建示例，但它的 `my-utils:string-utils` 声明了 `org.apache.commons:commons-lang3:3.4`，离线测量需要额外把该外部依赖预置进 `GRADLE_USER_HOME`；为保证"测量阶段零联网、依赖集合完全固定"，本用例不含该示例，只用两个零外部依赖的多模块工程。

### 3.2 矩阵

每个场景 **1 次预热 + 5 次独立正式测量**，报中位数，同时保留每次样本、最小值、最大值、均值、标准差。每个度量是一个**独立进程**：`gradle --no-daemon --max-workers=1 --offline --console=plain --no-build-cache`。

| 场景 | 工作负载 | 类数 | 说明 |
|---|---|---:|---|
| `clean_build_100` | `clean build` | 100 | 全量编译 + 打包 |
| `incremental_build_100` | `build` | 100 | 先完整构建，再改写 1 个源文件后编译 |
| `noop_build_100` | `build` | 100 | 先完整构建，再执行无变更构建（全部 up-to-date） |
| `clean_build_1000` | `clean build` | 1,000 | 同上 |
| `incremental_build_1000` | `build` | 1,000 | 同上 |
| `noop_build_1000` | `build` | 1,000 | 同上 |
| `clean_build_10000` | `clean build` | 10,000 | 同上 |
| `incremental_build_10000` | `build` | 10,000 | 同上 |
| `noop_build_10000` | `build` | 10,000 | 同上 |
| `upstream_multiproject_build` | 上游多模块示例 `build` | - | 2 个固定多模块示例工程顺序执行，每次先清理 `build/` 与工程级 `.gradle/` |

共 10 个场景；矩阵 6 个编译型场景 × 3 项指标 + 3 个 no-op 场景 × 2 项指标 + 上游负载 2 项指标 = **26 个指标**。no-op 场景不产出 `classes/s`（它本身不编译）。

生成工程结构固定：`project-<n>` 单模块 Java 工程，`bench` 包下 `Class00001..Class<n>`，每个类含固定常量与确定性计算；`clean build` 产出 `build/libs/matrix-<n>-1.0.0.jar`。增量场景改写 `Class00001` 的修订常量后仅执行 `build`，由 Gradle 增量编译决定实际工作量；no-op 场景先完成一次构建再重复构建，Gradle 必须报告 `:compileJava UP-TO-DATE`。

### 3.3 固定条件

- **Gradle 9.8.2 固定**：发行版 zip 的 SHA-256 固定；`gradle --version` 实测值逐次写入 `actual-version.txt`、`build_info.json` 与 `results.json`。
- **Temurin JDK 21.0.13+9 固定**：`JAVA_HOME` 与 `PATH` 显式指向解包目录，`java -version` 实测值写入证据；不使用 Runner 的默认 JDK。
- **daemon 策略固定**：`--no-daemon`，每次测量启动一个一次性 daemon 进程并在构建结束后退出；两架构一致。指标包含 JVM 启动与单次 daemon 进程开销，与"驻留 daemon 复用"的结果不混用（手册要求的边界）。
- **并行度固定**：`--max-workers=1`，避免 Runner 核数差异混入指标。
- **build cache 关闭**：`--no-build-cache`，且 `GRADLE_USER_HOME` 每轮都是预热后的同一份缓存目录，构建输出每次由任务重算。
- **离线测量**：所有测量命令带 `--offline`；依赖与插件在 build 阶段一次性预热，测量阶段不联网。
- 增量场景的源文件改写和 no-op 场景的"已构建"状态由脚本显式准备（预热+准备不计入指标），每次正式测量前都保证前置状态一致。
- 指标统计为 5 次独立测量的**中位数**；原始样本与完整 stdout+stderr 全部保留。

### 3.4 单架构耗时

本机 x86_64（WSL2，`PERF_REPS=5`，离线包已预置）：`build` 实测约 **33 秒**（解包发行版 / JDK / 源码归档 + 生成工程 + 预热 + 冒烟；若需下载约 215 MB 归档则再加几十秒），`test` 实测约 **6 分 06 秒**（矩阵 54 次独立进程 + 上游批次 6 次，每次约 8 秒），六阶段合计约 **6 分 40 秒**。背景负载较高时可能更久（验证前期同机还有其他用例的测量进程，见第 8 节）；aarch64 专用 Runner 预计 **10–20 分钟**，低于 `timeout_minutes=240` 与 `job_timeout_minutes=270`。

### 3.5 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<task>_<scale>` | `s` | 越低越好 | 该次 Gradle 进程树的外层墙钟，取 5 次中位数 |
| `<task>_<scale>_cps` | `classes/s` | 越高越好 | `类数 / 该次墙钟`，取 5 次中位数（仅 clean/incremental 场景；含 JVM 启动，见边界说明） |
| `<task>_<scale>_rss` | `MiB` | 越低越好 | 该次测量的进程树 `ru_maxrss`，取 5 次中位数 |
| `upstream_multiproject_build` | `s` | 越低越好 | 2 个上游多模块示例工程全量 `build` 批次（含逐工程清理 `build/`、`.gradle/`）的外层墙钟，取 5 次中位数 |
| `upstream_multiproject_build_rss` | `MiB` | 越低越好 | 该批次的进程树 `ru_maxrss`，取 5 次中位数 |

全部 26 个指标由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合；任一场景缺样本、`exit_code != 0`、超时、墙钟或 RSS 非有限或非正、缺少原始日志、日志中没有 `BUILD SUCCESSFUL`、clean/incremental 场景未执行 `:compileJava`、clean 场景未执行 `:clean`、no-op 场景未报告 `:compileJava UP-TO-DATE`、上游批次缺少任一固定示例工程或某个示例 `rc != 0`，均判定解析失败，`test` 阶段返回 50，**不补零、不估算**。

## 4. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 运行 → 解析 → 报告），产出**不是**性能结论。
- 脚本保持架构无关：只用 `uname -m` 选择 JDK 归档，两个架构使用同一份发行版、同一生成器、同一矩阵与同一上游工程集合。
- 负载边界：只覆盖 JVM 单模块/多模块的 `build` 生命周期（编译、打包、注解处理、复合构建配置），**不覆盖** Android/Kotlin/Spring 等需要大量外部插件与网络依赖的生态构建，也不覆盖 daemon 复用的长驻场景（本用例显式 `--no-daemon` 建立基线）。
- 跨架构对比只按同名场景配对；不把不同负载、不同语言/工具的耗时直接排序。

## 5. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: gradle
version: 9.8.2
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_GRADLE_OFFLINE_DIR=/home/runner/software/gradle   # 可选；默认即此路径
export PERF_REPS=5                                            # 默认 5；本机链路验证可临时降低并记录
bash software/Toolchain/gradle/gradle_test.sh \
  --version 9.8.2 --variant base --results-dir "$HOME/gradle-results"
```

`optimized` 变体尚未实现：`gradle_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base，也不写 `build_variant.json`。

可选环境变量：

| 变量 | 作用 |
|---|---|
| `PERF_REPS` | 每个场景的独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |
| `PERF_GRADLE_OFFLINE_DIR` | 覆盖离线包目录，默认 `/home/runner/software/gradle` |
| `PERF_GRADLE_JDK_FALLBACK_DIR` | JDK 归档缺失时的回退目录，默认 `/home/runner/software/maven` |
| `PERF_GRADLE_MIRROR` | 覆盖 Gradle 发行版镜像前缀（排在官方站点之前尝试） |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`results.log`、`runs/`（每场景预热 + 5 次测量的完整原始日志与外层计时 JSON）。框架六阶段运行时另有 `raw-output.log`（`test` 阶段完整控制台输出）与 `.perf-output/` 规范结果。

## 6. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 Gradle 负载是"固定工程 `clean build`，3 次样本"的**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"，其数值不迁移进仓库、不作为性能结论。

本用例保留 `clean build` 作为矩阵子集，但口径更严格：三种类规模、三种工作负载（clean / incremental / no-op）、每场景 1 次预热 + 5 次独立样本取中位数、固定 `--no-daemon --max-workers=1 --offline --no-build-cache`、严格校验每次构建确实完成了预期工作（`:compileJava` 是否执行/是否 up-to-date）；同时新增上游 Gradle 官方示例工程的多模块/复合构建负载。因工程、样本数与工作负载集合不同，本用例数值与旧交付数值不可直接对比。

## 7. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 SHA-256 不匹配 | 检查 `/home/runner/software/gradle/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `build` 报 Gradle 版本不是 9.8.2 | 预置归档版本错误，或 `$PERF_WORK_DIR/gradle-install` 残留旧解包；清理该目录重试 |
| `build` 报 `gradle` 不可执行 | ZIP 解包未保留可执行位；本用例已显式 `chmod +x`，若仍失败检查解包工具 |
| `build` 报上游示例工程缺失 | 源码归档版本不对（应为 tag `v9.8.2`）或解包不完整；清理 `$PERF_WORK_DIR/gradle-source` 重试 |
| `build` 报预热构建失败 | 检查网络（首次预热需要解析少量构建依赖）与镜像可达性；查看控制台中的 Gradle 报错 |
| `test` 报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json` / `rep*.log`；失败的那次测量会保留原始日志 |
| `test` 报 no-op 场景重新编译 | 增量状态被前一个场景污染；检查预热/准备逻辑是否被修改 |
| `test` 报上游示例 `rc != 0` | 查看该次 `rep*.log` 中 `== upstream sample: ... ==` 段落；常见原因是 `GRADLE_USER_HOME` 未预热或磁盘不足 |
| 测量阶段出现网络访问 | 不应发生；检查是否人为去掉 `--offline` 或设置了代理/仓库变量 |

## 8. 验证记录

（x86_64 WSL2，仅链路验证，非性能结论。验证期间同一 WSL 内还并行跑着 lua / jenkins / nextjs 三个用例的测量进程：早期 1 次样本的链路验证里 `clean_build_10000` 出现过 9 s–31 s 的波动（背景负载所致）；正式 5 次样本运行时背景负载已基本消失，主要场景 stdev ≤ 0.11 s，样本仍如实保留、不做剔除。x86_64 数字不迁移为性能结论。）

| 编号 | 验证内容 | 方式 | 结果 |
|---|---|---|---|
| A | 独立入口端到端 | `gradle_test.sh --variant base`，`PERF_REPS=5` | passed；26 指标 / 10 场景；全程 400 秒（build 33 秒 + test 366 秒）；`clean_build_10000` 中位数 9.04 s（5 样本 stdev 0.06） |
| B | 框架六阶段契约 | `framework/run_case.py` 依次 `prepare → build → start → test → stop → finalize`（`PERF_REPS=5`） | 六阶段全绿：`status.json` `status=passed`、`exit_code=0`、`service_stop_status=passed`；`normalized_result.json` 26 指标（`group`/`subgroup` 保留）；框架 `report.md` 442 行；全程 399 秒 |
| C | optimized 变体契约 | 独立入口 `--variant optimized`；框架 `run_case.py --stage build` 且 `PERF_VARIANT=optimized` | 两者均返回 30；`status.json` 记录 `status=failed`、`failed_stage=build`、`exit_code=30`；未写 `build_variant.json` / `results.json`，未回退 base |
| D | 测量阶段离线 | `unshare -n` 无网络命名空间（仅拉起 `lo`）内跑完整独立入口（build + 矩阵 + 上游 + 解析） | 全绿；命名空间内 DNS/外网探测失败（`Could not resolve host`）、`lo` 正常；26 指标 / 10 场景 |
| E | 解析严格性 | 构造缺样本、非零退出、no-op 场景被重新编译、上游样本缺失四类异常 | 四类异常全部返回非零（rc=1）；未改动样本返回 0 |
| F | 目录可移植性 | 用例目录复制到仓库外（`/root/gradle-portable/case`）运行（`PERF_REPS=1`） | passed；26 指标 / 10 场景，生成证据中无仓库路径残留 |
| G | 目录与矩阵注册 | `catalog.validate_catalog()`、`catalog.build_matrix("gradle", "9.8.2", arch)` | 24 个用例全部加载、`errors=[]`；gradle 在 x86_64 / aarch64 各 1 条，`timeout_minutes=240`、`job_timeout_minutes=270`，`case_path` 正确 |

## 9. 许可证

Gradle 采用 Apache License 2.0（Gradle, Inc. 及贡献者）；Eclipse Temurin JDK 采用 GPL v2 + Classpath Exception；上游示例工程随 Gradle 源码归档分发，许可证同 Gradle。本用例自带的工程生成器、计时与解析/报告脚本为本仓库原创，遵循仓库既有许可。
