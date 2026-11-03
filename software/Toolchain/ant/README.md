# Apache Ant 1.10.18 构建性能用例（Toolchain）

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件 | Apache Ant |
| 版本 | `1.10.18` |
| 制品 | `apache-ant-1.10.18-bin.tar.gz`（Apache 官方二进制发行版） |
| 制品 SHA-256 | `b45db2fdd76d639301550930d33dd7bc672c9d4fdea0fe8cfd2e6a3518388d59` |
| JDK 基线 | 容器内 `java-21-openjdk-headless`（openEuler 24.03 LTS SP4 固定为 `21.0.12.8-4.oe2403sp4`） |
| 执行环境 | 私有 openEuler 24.03 LTS SP4 容器 `boostkit-ant-<arch>-<run-id>` |
| 分类 | Toolchain |

Ant 是纯 Java 构建工具，本身不编译；用例测量的是"用 Ant 驱动 javac + jar"的构建
性能，因此固定 JDK 是口径的一部分，必须与编译结果一起记录。

## 2. 安装与构建

build 阶段（不编译 Ant 源码，使用官方二进制发行版；全部构建动作在私有容器内完成）：

1. 启动本 run 的私有 openEuler 24.03 LTS SP4 容器（见第 7 节），宿主机只保留
   docker 与下载/校验工具。
2. 容器内 `dnf install -y java-21-openjdk-headless java-21-openjdk-devel tar gzip
   coreutils findutils which`，装后 `command -v java javac` 自检（沙箱已把仓库切到
   华为云 openEuler 镜像）。
3. 宿主机下载并校验 `apache-ant-1.10.18-bin.tar.gz`：离线目录 → 清华/华为云/
   `dlcdn.apache.org` → `archive.apache.org`，每源校验同一 SHA-256；压缩包在容器内
   解包到 `${PERF_WORK_DIR}/ant-install` 并检查 `bin/ant`。
4. 容器内 `readlink -f $(command -v javac)` 解析 `JAVA_HOME`，写入
   `PERF_WORK_DIR/container-jdk-home.txt` 供 start/test 复用；校验 JDK 主版本为 21。
5. 容器内 `ant -version` 读取实际版本写入 `PERF_ACTUAL_VERSION_FILE`，与请求版本
   不一致返回 40（框架记为 build 30）。
6. 容器内 `python3 scripts/generate_project.py` 确定性生成 50/100/200 个 Java 类的
   工程（`src/bench/*.java` + 同一份 `build.xml`），无第三方依赖、不访问网络。
7. 写 `build_variant.json`。

`build.xml` 的 target：`clean`（删除 build/）、`compile`（javac）、`jar`
（打包 `build/bench.jar`）、`clean_jar`（clean 后 jar）。用例直接调用 `jar`/
`compile`，输出目录由测试脚本在计时前清空，因此"clean 构建"包含真实的
javac + jar 全量工作，但不包含 Ant 自己的 `delete` 目标开销。

离线目录：`PERF_ANT_OFFLINE_DIR`（默认 `/home/runner/software/ant/`），只需放
`apache-ant-1.10.18-bin.tar.gz`；JDK 不再从宿主下载，而是由容器内
`dnf install java-21-openjdk-*` 提供（镜像与包版本随固定的 openEuler 镜像确定）。

## 3. 完整测试口径

100 个 Java 类的 clean jar 构建 + 增量构建（空闲）对比为本用例核心口径，另加两组
clean 规模与一组 compile-only 参照。每个场景 1 次预热 + `PERF_REPS` 次独立测量
（正式证据要求 `>=5`，默认 5），逐次写 `runs/<scenario>/{warmup,rep<i>}.{log,json}`。

| 场景 | 命令（等价） | 说明 |
|---|---|---|
| `clean_jar_50` | 清空 build/ 后 `ant jar` | 50 类全量 javac + jar |
| `clean_jar_100` | 同上 | 100 类 |
| `clean_jar_200` | 同上 | 200 类 |
| `clean_compile_100` | 清空 build/ 后 `ant compile` | 100 类仅编译，分离 jar 打包开销 |
| `incremental_noop_100` | 预热后不改源码反复 `ant jar` | 增量空闲：Ant 判定全部 up-to-date |
| `incremental_touch_100` | 每次 `touch` 一个源文件后 `ant jar` | 单文件变更增量：重编 1 个类 + 重打 jar |

严格性：解析器要求 6 个场景 × (`warmup` 不算) `rep1..repN.json` 全部存在、
退出码 0、墙钟与 RSS 为有限正数；任一缺失返回 50。`runs/scenario_meta.json`
记录场景与 `PERF_REPS`，不一致直接失败。

## 4. 指标

6 场景 × 2 指标 = 12，外加 4 个吞吐指标（3 个 clean_jar 规模 + 1 个
clean_compile_100），共 **16 个指标**：

| 指标 | 单位 | 方向 |
|---|---|---|
| `<scenario>__wall_seconds` | s | lower_is_better |
| `<scenario>__peak_rss_mib` | MiB | lower_is_better |
| `clean_jar_<n>__classes_per_second` / `clean_compile_100__classes_per_second` | classes/s | higher_is_better |

每个指标带 `median`/`mean`/`min`/`max`/`stdev` 与全部样本。RSS 是单次 Ant 进程
（含其 fork 的 javac 在 `ru_maxrss` 中的峰值子进程近似）的峰值内存。

## 5. 架构与证据边界

- 两个架构使用同一份固定制品与固定 JDK 版本（JDK 按架构取 x64/aarch64 制品）。
- 本地 WSL `x86_64` 只做链路验证；正式性能数据必须来自专用 `aarch64` Runner。
- 该口径受 JVM 启动与文件系统缓存影响：`incremental_noop_100` 主要反映 Ant 启动
  与 up-to-date 检查开销，`incremental_touch_100` 反映单文件重编译 + 重打包开销。
  跨机器比较时须保证同一 JDK、同一文件系统与同一 `PERF_REPS`。
- 未覆盖：Ant 自带 `ant -diagnostics`、ivy 依赖解析、并发构建（`-j`）、
  Ant 源码构建、其他 JDK 供应商。

## 6. 运行方式

```bash
python3 framework/run_case.py \
  --case software/Toolchain/ant/case.yaml \
  --version 1.10.18 --architecture x86_64 \
  --run-id local-ant-1 --stage build
PERF_REPS=5 python3 framework/run_case.py ... --stage test

# 独立入口
software/Toolchain/ant/ant_test.sh --version 1.10.18 --results-dir /tmp/ant-results

# 负向：未实现的优化变体
PERF_VARIANT=optimized python3 framework/run_case.py ... --stage build   # 期望 30
```

## 7. 容器化执行

- **容器**：每个 run 一个 `boostkit-ant-<arch>-<run-id>`，标签
  `boostkit.ant.run-id=<run-id>`；`start_ant_container` 拒绝复用已存在的同名容器，
  `sweep_ant_stale_containers` 只清理同前缀且标签不属于本 run 的残留容器。
- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，
  缺失时从 `repo.openeuler.org` 下载；校验同名 `.sha256sum`、镜像架构
  （`x86_64→amd64`/`aarch64→arm64`）与 `/etc/os-release` 的 `24.03` 标识后
  `docker load`。
- **挂载**：`PERF_WORK_DIR`（容器 `HOME=$PERF_WORK_DIR/home`、`TMPDIR` 同宿主）、
  `RESULTS_DIR`、用例目录（结果目录在用例目录内时去掉 `readonly`，以便独立入口写
  结果）、`/etc/passwd`、`/etc/group`；网络为 host；容器以宿主 uid:gid 运行，
  不需要 `--privileged`。
- **JDK 与 PATH**：`JAVA_HOME` 来自容器内解析并持久化；所有 Java/Ant 调用都通过
  `ant_container_java_exec(_at)`，显式注入 `JAVA_HOME` 与
  `${JDK_HOME}/bin:${ANT_HOME}/bin:...`，不依赖宿主环境。
- **宿主职责**：docker、下载并校验 Ant 发行包、framework、严格解析器；解包、工程
  生成、版本探测、`run_timed.py` 计时驱动与全部测量子进程都在容器内执行，因此
  `docker exec` 的开销不进入采样窗口。
- **与整机执行的差异**：宿主不再安装 JDK，`java`/`javac`/`ant` 只在容器内可见；
  独立运行 `ant_test.sh` 需要可用的 docker daemon，否则 build 返回 30。
- **清理**：stop 阶段先 `remove_ant_container`（仅本 run 标签，幂等）再清理临时文件；
  test 阶段不启动常驻服务。

## 8. 故障排查

| 现象 | 原因 / 处理 |
|---|---|
| build 30，`every download source failed` | 所有源失败；日志逐条列出尝试过的离线目录与 URL，把固定 SHA 制品放到离线目录即可 |
| build 30，`sha256 mismatch` | 镜像/离线目录里是别的版本，删除后重下 |
| build 30，`requested Ant ... but installed ...` | 下载到了别的版本，检查文件名与 SHA 常量 |
| build 40 → 框架 30，`Ant launcher is not executable` | 解包不完整，检查 `tar` 与磁盘空间 |
| test 50，`scenario ... did not produce build/bench.jar` | 构建失败但被脚本吞掉；看 `runs/<scenario>/rep<i>.log` |
| test 50，`wall time must be positive` | Ant 启动即失败（如 `JAVA_HOME` 无效），日志首行是完整命令 |
| javac `invalid source release: 21` | 容器 JDK 不是 21；build 阶段已强校验 |
| build 30，`an accessible Docker daemon is required` | 宿主机 docker 未安装/未启动 |
| build 30，`container image checksum mismatch` | 镜像归档与 `.sha256sum` 不匹配，删除后重载 |
| 40，`managed container is not running` | 容器被外部删除；重跑 run（新 run-id） |
| 40，`cannot resolve javac inside the private container` | 容器内 JDK 包安装不完整，看 build 日志的 dnf 输出 |

## 9. 许可证

Apache Ant 使用 Apache License 2.0；Eclipse Temurin（OpenJDK）使用 GPLv2 +
Classpath Exception。本用例只下载并运行官方发行版，不修改其源码。
