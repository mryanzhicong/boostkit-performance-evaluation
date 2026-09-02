# OpenJDK 性能测试说明

本用例从 OpenJDK `jdk25u` 的官方标签 `jdk-25.0.4.1-ga` 源码构建
OpenJDK `25.0.4.1`，再以该构建产物运行 jtreg `8.3+1`。跨架构报告的指标为
整轮 jtreg 命令的墙钟耗时（秒），越小越好。

`case.yaml` 将 `build`、`start`、`test`、`stop` 四阶段映射至
`openjdk_test.sh`。也可以直接执行该脚本，获得相同的构建、测试、信息收集和
清理行为。

## 工具与文件来源

所有离线文件均放在 `/home/runner/software/openjdk/`。脚本优先使用离线文件；
缺失时才按下表的官方地址下载。

| 用途 | 离线文件 | 官方来源 | 本次任务内的位置 |
|---|---|---|---|
| 被测 OpenJDK 源码 | `jdk25u-jdk-25.0.4.1-ga.tar.gz` | `https://github.com/openjdk/jdk25u/archive/refs/tags/jdk-25.0.4.1-ga.tar.gz` | `${PERF_WORK_DIR}/openjdk-source` |
| Boot JDK（x86_64） | `OpenJDK25U-jdk_x64_linux_hotspot_25.0.4.1_1.tar.gz` | `${ADOPTIUM_RELEASE_BASE}/jdk-25.0.4.1%2B1/OpenJDK25U-jdk_x64_linux_hotspot_25.0.4.1_1.tar.gz` | `${PERF_WORK_DIR}/boot-jdk` |
| Boot JDK（aarch64） | `OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.4.1_1.tar.gz` | `${ADOPTIUM_RELEASE_BASE}/jdk-25.0.4.1%2B1/OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.4.1_1.tar.gz` | `${PERF_WORK_DIR}/boot-jdk` |
| jtreg | `jtreg-8.3+1.zip` | `https://builds.shipilev.net/jtreg/jtreg-8.3%2B1.zip` | `${PERF_WORK_DIR}/jtreg` |

默认变量：

```bash
OPENJDK_OFFLINE_DIR=/home/runner/software/openjdk
OPENJDK_SOURCE_BASE=https://github.com/openjdk
ADOPTIUM_RELEASE_BASE=https://github.com/adoptium/temurin25-binaries/releases/download
JTREG_DOWNLOAD_URL=https://builds.shipilev.net/jtreg/jtreg-8.3%2B1.zip
```

若要为两种架构预置全部离线文件：

```bash
sudo install -d -o runner -g runner /home/runner/software/openjdk
sudo install -o runner -g runner jdk25u-jdk-25.0.4.1-ga.tar.gz \
  /home/runner/software/openjdk/
sudo install -o runner -g runner OpenJDK25U-jdk_x64_linux_hotspot_25.0.4.1_1.tar.gz \
  /home/runner/software/openjdk/
sudo install -o runner -g runner OpenJDK25U-jdk_aarch64_linux_hotspot_25.0.4.1_1.tar.gz \
  /home/runner/software/openjdk/
sudo install -o runner -g runner jtreg-8.3+1.zip \
  /home/runner/software/openjdk/
```

## 构建

脚本会自动安装缺失的系统构建依赖：Curl、Tar、Python 3、GNU Make、GCC/G++、
Zip/Unzip，以及 Freetype、Fontconfig、ALSA、CUPS、X11 的开发包。仅缺失时才
通过系统包管理器安装。

脚本处理 Boot JDK 的过程为：

```bash
tar -xzf "${PERF_WORK_DIR}/<Temurin 包名>" -C "${PERF_WORK_DIR}"
mv "${PERF_WORK_DIR}"/jdk-* "${PERF_WORK_DIR}/boot-jdk"
"${PERF_WORK_DIR}/boot-jdk/bin/java" -version
"${PERF_WORK_DIR}/boot-jdk/bin/javac" -version
```

它严格校验 Boot JDK 的 Java 版本为 `25.0.4.1`。如已提供同版本的已解压 Boot
JDK，也可设置 `OPENJDK_BOOT_JDK_HOME`，脚本不会下载或解压 Boot JDK 包。

OpenJDK 源码包被解压至 `${PERF_WORK_DIR}/openjdk-source`，构建命令为：

```bash
cd "${PERF_WORK_DIR}/openjdk-source"
bash configure \
  --with-debug-level=release \
  --with-boot-jdk="${PERF_WORK_DIR}/boot-jdk" \
  --prefix="${PERF_WORK_DIR}/jdk" \
  --disable-warnings-as-errors \
  --disable-precompiled-headers
make images
```

`make images` 的产物首先位于：

```text
${PERF_WORK_DIR}/openjdk-source/build/linux-x86_64-server-release/images/jdk
${PERF_WORK_DIR}/openjdk-source/build/linux-aarch64-server-release/images/jdk
```

脚本会将该目录移动到 `${PERF_WORK_DIR}/jdk`，并以以下命令验证实际版本：

```bash
"${PERF_WORK_DIR}/jdk/bin/java" -version
"${PERF_WORK_DIR}/jdk/bin/javac" -version
```

## 测试

jtreg 压缩包解压至 `${PERF_WORK_DIR}/jtreg`，调用入口为：

```bash
"${PERF_WORK_DIR}/jtreg/bin/jtreg"
```

脚本在 OpenJDK 源码根目录执行以下完整命令。`-jdk` 确保测试使用本次源码构建的
JDK；`-w` 和 `-r` 将 jtreg 工作文件和原始报告保存在结果目录。

```bash
cd "${PERF_WORK_DIR}/openjdk-source"
"${PERF_WORK_DIR}/jtreg/bin/jtreg" \
  -jdk:"${PERF_WORK_DIR}/jdk" \
  -w:"${RESULTS_DIR}/jtreg-work" \
  -r:"${RESULTS_DIR}/jtreg-report" \
  -va -ignore:quiet -jit -conc:auto -timeout:5 -tl:3590 \
  test/jdk test/lib-test test/langtools test/jaxp test/hotspot/jtreg test/docs
```

测试目录由 `case.yaml` 的 `JTREG_TEST_ROOTS` 声明；jtreg 版本由
`JTREG_VERSION` 声明。两者均为 Framework 传入入口脚本的环境变量。

## 指标与输出

`jtreg elapsed time` 是上述 jtreg 命令从启动到退出的整轮墙钟耗时，单位为 `s`，
优化方向为越小越好。命令失败时测试阶段直接失败，不产生可通过的空指标。

| 输出 | 内容 |
|---|---|
| `jtreg-output.log` | jtreg 原始控制台输出。 |
| `jtreg-work/` | jtreg 工作目录，保留每项测试执行产生的工作文件。 |
| `jtreg-report/` | jtreg 原始报告目录。 |
| `benchmark_openjdk.json` | 规范化指标、实际命令参数和测试目录。 |

## 独立执行

```bash
bash software/Toolchain/openjdk/openjdk_test.sh --version 25.0.4.1
```

可额外传入 `--results-dir <目录>` 指定结果位置，或 `--keep-workdir` 保留本次
`PERF_WORK_DIR` 以便排查。
