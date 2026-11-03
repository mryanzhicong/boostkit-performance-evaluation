# Scala 3.10.0 编译与运行性能用例（Toolchain）

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件 | Scala 3（`scala3-compiler` 发行版） |
| 版本 | `3.10.0`（周一日期 tag 版，**不是** LTS `3.3.9`） |
| 制品 | `scala3-3.10.0.zip`（GitHub `scala/scala3` release asset） |
| 制品 SHA-256 | `__SCALA_SHA256__` |
| JDK 基线 | 容器内 `java-21-openjdk-headless`/`-devel`（openEuler 24.03 LTS SP4 固定为 `1:21.0.12.8-4.oe2403sp4`；`test_tools.openjdk`）<br>执行环境：私有 openEuler 24.03 LTS SP4 容器 `boostkit-scala-<arch>-<run-id>` |
| 分类 | Toolchain |

版本选择说明：`3.10.0` 是当前稳定线，`3.3.x` 是 LTS 线。两者编译器/库 ABI 不同，
本用例**只**覆盖 `3.10.0`，不与 LTS 混用；若要评估 LTS，需要单独登记一个用例（相同
口径、不同版本），不能复用本用例的结果做对比。

`case.yaml` 的 `versions` 只声明 `3.10.0`；`SOFTWARE_VERSION` 必须是该值，否则 build
阶段取出实际版本后与请求版本不一致，返回 30。

## 2. 安装与构建

build 阶段完成以下步骤（不编译 Scala 编译器本身，使用官方发行版 + 固定 JDK）：

1. 启动本 run 的私有 openEuler 24.03 LTS SP4 容器（见第 7 节「容器化执行」）；宿主只保留 docker 与下载/校验命令（`curl tar unzip python3 sha256sum awk`）。
2. 容器内 `dnf install -y --setopt=install_weak_deps=False java-21-openjdk-headless java-21-openjdk-devel unzip tar gzip coreutils findutils which`（关闭弱依赖：java-devel 的弱依赖 dbus-daemon 在只读 `/etc/passwd` 的容器里装不上），装后 `command -v java/javac/unzip` 自检。
3. 容器内 `readlink -f $(command -v javac)` 解析 `JAVA_HOME` 并写入 `$PERF_WORK_DIR/container-jdk-home.txt`；`java -version` 主版本必须是 21。
4. 取 `scala3-3.10.0.zip`：离线目录 → `ghfast.top` → `gh-proxy.com` → 官方
   GitHub，每一源校验同一固定 SHA-256；**解包在容器内**完成到
   `<work>/scala-install`，检查 `bin/scalac`；并注意 Scala 3.10 发行版布局变化：
   `lib/` 下只有清单式转发 jar，真正的编译器/标准库 jar 位于 `maven2/` 下，用例从
   `maven2/` 中取 `scala3-library_3`、`scala-library`、`tasty-core_3` 组成
   被测程序的 classpath（编译器类路径由 `bin/scalac` 启动器自行补齐）。
5. 容器内执行 `bin/scalac -version` 读取实际版本，写入 `PERF_ACTUAL_VERSION_FILE`；
   与请求版本不一致返回 40（框架记为 build 30）。
6. 容器内用 `scripts/generate_sources.py` 确定性生成固定源码集（20 / 100 / 300 个类，
   只用 Scala 3 标准库），并额外生成 3 个计算负载（`arith`/`collections`/
   `strings`）；这些负载在 build 阶段**在容器内**预编译一次（**不计时**），供测试阶段
   的 run 场景直接执行，保证测量阶段不触发编译。
7. 写 `build_variant.json`：`{"variant":"base","parameters":{"variant":"base"}}`。

离线目录：`PERF_SCALA_OFFLINE_DIR`（默认 `/home/runner/software/scala/`），只需放置
`scala3-3.10.0.zip`（JDK 由容器镜像提供，不再需要离线 JDK 压缩包）。

## 3. 完整测试口径

口径名称：**compile_and_run**。每个场景都是"启动一个子进程执行一次完整命令"，
固定 1 次预热 + `PERF_REPS` 次独立测量（正式证据要求 `PERF_REPS>=5`，默认 5），
每次测量写 `runs/<scenario>/rep<i>.json`（墙钟、峰值 RSS、退出码）与
`runs/<scenario>/rep<i>.log`（完整 stdout/stderr），预热写 `warmup.*`。

| 场景 | 命令 | 说明 |
|---|---|---|
| `compile_20` | `scalac -classpath lib/* -d out src/bench/*.scala` | 20 个类的小项目全量编译（编译前清空输出目录） |
| `compile_100` | 同上 | 100 个类 |
| `compile_300` | 同上 | 300 个类 |
| `run_arith` | `java -cp lib/*:programs/arith bench.Main 40000000` | 预编译的整数循环负载 |
| `run_collections` | `java -cp lib/*:programs/collections bench.Main 400000` | Vector/groupBy/sort/fold 负载 |
| `run_strings` | `java -cp lib/*:programs/strings bench.Main 20` | StringBuilder + 插值字符串负载 |
| `pipeline_compile_and_run` | 先 `scalac` 编译 100 类项目，再用 `java` 执行 | 端到端编译+运行流水线 |

严格性：解析器 `scripts/results/parse_benchmark.py` 要求每个场景的
`rep1..repN.json` 全部存在、`exit_code == 0`、墙钟与 RSS 均为有限正数；否则
test 阶段返回 50，并把失败原因打到 stdout。**不补零、不插值、不降级**。
`runs/scenario_meta.json` 记录场景清单与 `PERF_REPS`，若与实际测量次数不一致直接失败。

## 4. 指标

共 7 个场景 × 2 个必测指标 = 14 个，外加 3 个编译吞吐指标，共 **17 个指标**：

| 指标 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<scenario>__wall_seconds` | s | lower_is_better | 子进程墙钟中位数 |
| `<scenario>__peak_rss_mib` | MiB | lower_is_better | 子进程 `ru_maxrss` 中位数 |
| `compile_<n>__classes_per_second` | classes/s | higher_is_better | 类数 / 墙钟，中位数 |

每个指标同时携带 `median`/`mean`/`min`/`max`/`stdev` 与全部 `samples`。
RSS 是单个被测子进程的峰值，不是整机内存；`compile_*` 场景的 RSS 包含 `scalac`
JVM 峰值。

## 5. 架构与证据边界

- 两个架构使用同一份固定制品（SHA-256 一致），JDK 按架构选择 x64/aarch64 制品。
- 本地 WSL `x86_64` 只做功能与链路验证（六阶段通过、指标可解析），**不是**性能结论。
- 正式数据必须来自专用 `aarch64` Runner；`compile_and_run` 是 JVM 冷启动敏感口径，
  x86_64 与 aarch64 的绝对值不可直接比较。
- 场景矩阵固定：编译规模 20/100/300 类、3 个运行负载、1 条流水线，跨版本对比只在
  该矩阵内有效。
- 未覆盖：增量编译（`-Yincremental`）、Scala 2 交叉编译、REPL、Scala.js/Native、
  依赖下载（本用例编译不访问网络，也不需要任何第三方依赖）。

## 6. 运行方式

```bash
# 在仓库根目录
python3 framework/run_case.py \
  --case software/Toolchain/scala/case.yaml \
  --version 3.10.0 --architecture x86_64 \
  --run-id local-scala-1 --stage prepare

# 依次 build / start / test / stop / finalize
PERF_REPS=5 python3 framework/run_case.py ... --stage test

# 独立入口（不经过框架，等价证据）
software/Toolchain/scala/scala_test.sh --version 3.10.0 --results-dir /tmp/scala-results

# 负向：未实现的优化变体必须显式失败且不写 build_variant.json
PERF_VARIANT=optimized python3 framework/run_case.py ... --stage build   # 期望 30
```

本地注意：本机系统 `cmake` 与本用例无关；需要 `PERF_REPS`（默认 5）、
`PERF_SCALA_OFFLINE_DIR`。构建/测量在 `/home/runner/boostkit-perf/scala/<run-id>`
私有目录内，独立入口默认清理该目录（`--keep-workdir` 保留）。

## 7. 故障排查

| 现象 | 原因 / 处理 |
|---|---|
| build 30，`every download source failed` | 所有下载源（含离线目录）都失败或被代理拦截；日志逐条打印尝试过的路径，把固定 SHA-256 制品放到离线目录即可 |
| build 30，`sha256 mismatch` | 离线目录/镜像里的制品不是固定版本；删除后重下 |
| build 30，`requested Scala ... but installed ...` | 下载到的是别的版本，检查 `SCALA_ARCHIVE_SHA256` 与文件名 |
| build 30，`failed to precompile the ... workload` | 编译器与源集不匹配；日志 `precompile-<workload>.log` 有完整错误 |
| test 50，`missing repetition sample` | 某个 rep 进程没有产出 json（通常是超时或 OOM）；查看 `runs/<scenario>/rep<i>.log` |
| test 50，`wall time must be positive` | 子进程瞬间失败（如 `bin/scalac` 不可执行），日志首行有实际命令 |
| JVM 报内存不足 | 每个测量是独立 JVM；`compile_300` 的 `scalac` 约需 0.5–1 GB，Runner 需保证内存 |
| `unzip: command not found` | dnf/apt 安装分支会装 `unzip`；若包安装失败会返回 30 并打印包管理器输出 |

## 7.1 容器化执行

- **容器**：每个 run 一个 `boostkit-scala-<arch>-<run-id>`，标签
  `boostkit.scala.run-id=<run-id>`；`start_scala_container` 拒绝复用已存在的同名
  容器，`sweep_scala_stale_containers` 只清理同前缀且标签不属于本 run 的残留容器。
- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，
  缺失时从 `repo.openeuler.org` 下载；校验同名 `.sha256sum`、镜像架构与
  `/etc/os-release` 的 `24.03` 标识后 `docker load`。
- **挂载**：`PERF_WORK_DIR`（容器 `HOME=$PERF_WORK_DIR/home`、`TMPDIR` 同宿主）、
  `RESULTS_DIR`、用例目录（结果目录在用例目录内时去掉 `readonly`）、`/etc/passwd`、
  `/etc/group`；网络为 host；容器以宿主 uid:gid 运行，不需要 `--privileged`。
- **JDK 与缓存**：`JAVA_HOME` 来自容器内解析并持久化，`PATH` 由
  `scala_container_env_exec(_at)` 显式注入；Scala 发行版与 classpath 仍固定在
  `$PERF_WORK_DIR` 下（与宿主路径一致，因此 classpath 字符串在容器内可直接使用）。
- **宿主职责**：docker、下载并校验 Scala 发行版归档、framework、严格解析器；
  解包、语料生成、`scalac -version`、负载预编译、`run_timed.py` 计时驱动与全部
  测量子进程都在容器内执行，因此 `docker exec` 开销不进入采样窗口。
- **与整机执行的差异**：宿主不再安装 JDK，`java`/`scalac` 只在容器内可见；独立运行
  `scala_test.sh` 需要可用的 docker daemon，否则 build 返回 30。
- **清理**：stop 阶段先 `remove_scala_container`（仅本 run 标签，幂等）再清理标记文件。

### 7.1.1 容器相关故障排查

| 现象 | 排查 |
|---|---|
| build 30，`container package installation failed` | 多为 dnf 装 java-21-openjdk-devel 时弱依赖 `dbus-daemon` scriptlet 失败（`/etc/passwd` 只读挂载）；确认已带 `--setopt=install_weak_deps=False`，并查看 dnf 输出 |
| build 30，`requested Scala ... but installed <unknown>` | 容器内 `scalac -version` 探测被管道提前关闭（SIGPIPE）导致输出丢失；版本解析必须**先取完整 banner 再过滤**（`scalac_version_output` 已按此实现） |
| build 30，`cannot resolve javac inside the private container` | 容器内 JDK 包未装成功；检查 dnf 段日志与 `command -v javac` 自检输出 |
| test 50，`wall time must be positive` + 容器内 `scalac: command not found` | 测量命令未走 `scala_container_env_exec(_at)`；检查 test 阶段是否全部经容器包装器执行 |

## 8. 许可证

Scala 3（`scala3-compiler`、`scala3-library`）使用 Apache License 2.0；
容器内 OpenJDK 21（openEuler 构建）使用 GPLv2 + Classpath Exception。本用例只下载、安装并
运行这些官方发行版，不修改其源码，仓库中只包含用例脚本与确定性生成的源码语料
（语料由本用例脚本生成，无第三方代码）。
