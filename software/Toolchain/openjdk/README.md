# OpenJDK 性能测试说明

本用例安装 OpenJDK 官方 GA 预编译二进制包，并运行同版本 OpenJDK 源码树
`test/micro` 中声明的 JMH 微基准，用于比较 `x86_64` 与 `aarch64` 的开箱
运行性能。

Framework 通过 `case.yaml` 调用 `openjdk_test.sh` 的 `build`、`start`、`test`
和 `stop` 四阶段。单独执行入口脚本会使用相同顺序完成安装、测试、环境收集
和清理。

## 安装

支持的版本由 `case.yaml` 的 `versions` 声明。脚本先从以下目录读取官方二进制
包，文件名必须与官方发布包一致：

```text
/home/runner/software/openjdk/openjdk-<版本>_linux-x64_bin.tar.gz
/home/runner/software/openjdk/openjdk-<版本>_linux-aarch64_bin.tar.gz
```

未找到离线包时，脚本从 `jdk.java.net` 的官方 GA 地址下载。两种来源都会根据
脚本中声明的官方 SHA-256 校验。JDK 被解压到本次任务的工作目录，实际版本由：

```bash
"${JDK_HOME}/bin/java" -version
```

校验。

脚本会自动安装缺失的通用依赖：Git、Curl、Tar、Python 3、Awk、Sed、Grep 和
Tee。

当前版本的官方包名如下：

| 版本 | x86_64 | aarch64 |
|---|---|---|
| `25.0.2` | `openjdk-25.0.2_linux-x64_bin.tar.gz` | `openjdk-25.0.2_linux-aarch64_bin.tar.gz` |
| `26.0.2.1` | `openjdk-26.0.2.1_linux-x64_bin.tar.gz` | `openjdk-26.0.2.1_linux-aarch64_bin.tar.gz` |

脚本实际使用的在线安装命令形态如下：

```bash
curl -fL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/<官方包名>" \
  "https://download.java.net/java/GA/<发布目录>/GPL/<官方包名>"
sha256sum "${PERF_WORK_DIR}/<官方包名>"
tar -xzf "${PERF_WORK_DIR}/<官方包名>" -C "${PERF_WORK_DIR}"
mv "${PERF_WORK_DIR}"/jdk-* "${PERF_WORK_DIR}/jdk"
"${PERF_WORK_DIR}/jdk/bin/java" -version
```

例如，为 aarch64 Runner 预置 `26.0.2.1` 离线包：

```bash
sudo install -d -o runner -g runner /home/runner/software/openjdk
sudo install -o runner -g runner openjdk-26.0.2.1_linux-aarch64_bin.tar.gz \
  /home/runner/software/openjdk/
sha256sum /home/runner/software/openjdk/openjdk-26.0.2.1_linux-aarch64_bin.tar.gz
```

## 测试

测试源码来自与被测 JDK 版本相匹配的官方更新仓库（`jdk25u` 或 `jdk26u`）的
tag。优先使用本地 Git 镜像：

```text
/home/runner/software/openjdk/jdk25u.git
/home/runner/software/openjdk/jdk26u.git
```

不存在时才从 `https://github.com/openjdk` 稀疏克隆所需的 `test/micro` 目录。
JMH 1.37 及其依赖也优先从 `/home/runner/software/openjdk/` 读取；缺失时从
Maven Central 下载并校验 SHA-256。

可按以下方式在 Runner 上预置源码镜像和 JMH 依赖，以避免测试时下载：

```bash
sudo install -d -o runner -g runner /home/runner/software/openjdk
sudo -u runner git clone --mirror https://github.com/openjdk/jdk26u \
  /home/runner/software/openjdk/jdk26u.git

cd /home/runner/software/openjdk
curl -fLO https://repo.maven.apache.org/maven2/org/openjdk/jmh/jmh-core/1.37/jmh-core-1.37.jar
curl -fLO https://repo.maven.apache.org/maven2/org/openjdk/jmh/jmh-generator-annprocess/1.37/jmh-generator-annprocess-1.37.jar
curl -fLO https://repo.maven.apache.org/maven2/org/apache/commons/commons-math3/3.6.1/commons-math3-3.6.1.jar
curl -fLO https://repo.maven.apache.org/maven2/net/sf/jopt-simple/jopt-simple/5.0.4/jopt-simple-5.0.4.jar
```

对于 `25.0.2`，将上述 `jdk26u.git` 替换为 `jdk25u.git`。每次执行仍会根据
`case.yaml` 声明的 JMH 版本和脚本内置 SHA-256 校验这些 Jar。

当前测试矩阵在 `case.yaml` 的 `OPENJDK_BENCH_CLASSES` 和
`OPENJDK_BENCH_SOURCES` 中声明，分别列出官方原始类名和对应源码文件：

```text
org.openjdk.bench.java.lang.ArrayCopy
org.openjdk.bench.java.lang.ArrayClone
org.openjdk.bench.java.lang.StringDecode
org.openjdk.bench.java.lang.StringEncode
org.openjdk.bench.java.lang.StringBuilders
org.openjdk.bench.java.lang.ArraysSort
org.openjdk.bench.java.util.HashMapBench
```

脚本使用该 JDK 的 `javac` 编译这些官方源码，并由 JMH 执行：

```bash
"${JDK_HOME}/bin/java" \
  --add-opens=java.base/java.io=ALL-UNNAMED \
  -cp "${BENCH_JAR}:<jmh 运行依赖>" \
  org.openjdk.jmh.Main \
  "<官方类名>[.]" ... \
  -rf json \
  -rff "${RESULTS_DIR}/jmh-result.json"
```

JMH 采用各官方类自身声明的 `@BenchmarkMode(Mode.AverageTime)` 和
`@OutputTimeUnit`。脚本会先列出匹配项，运行后严格校验列表与结果中的基准名称
一致。

## 指标与输出

每个指标名称保留 JMH 的原始 benchmark 名称；存在参数时追加 JMH 参数，例如：

```text
org.openjdk.bench.java.lang.ArrayCopy.copy(size=10)
```

指标来源是 `jmh-result.json` 的 `primaryMetric.score`。原始单位可为 `ns/op`、
`us/op` 或 `ms/op`，报告统一换算为 `us/op`，优化方向为越小越好。

- `benchmark_list.txt`：开始阶段列出的官方 JMH 测试项。
- `benchmark_micro.txt`：JMH 原始控制台输出。
- `jmh-result.json`：JMH 原始结构化结果。
- `benchmark_openjdk.json`：严格规范化后的指标结果。

## 独立执行

```bash
bash software/Toolchain/openjdk/openjdk_test.sh --version 26.0.2.1
```

可通过 `--results-dir <目录>` 指定结果位置，或通过 `--keep-workdir` 保留本次
任务的工作目录以供排查。
