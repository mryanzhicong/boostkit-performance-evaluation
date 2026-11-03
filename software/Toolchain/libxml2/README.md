# libxml2 性能评测用例

本目录是 `Toolchain/libxml2` 在性能评测框架中的完整用例：固定版本、可复现的
构建方式、确定性语料、统一的测量方式，以及完整的原始证据（每次重复的
stdout/stderr 与时序 JSON）。

## 1. 版本与上游制品

| 项目 | 值 |
|---|---|
| 软件 | libxml2 |
| 版本 | `2.15.4` |
| 类别 | `Toolchain` |
| 源码归档 | `libxml2-2.15.4.tar.xz`（3,177,444 字节） |
| SHA-256 | `98087fd181d9070724f3fbc65c7377db03038eb92bd882374daff44940138821` |
| 官方地址 | `https://download.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.tar.xz` |
| 字节一致镜像 | `https://mirrors.nju.edu.cn/gnome/sources/libxml2/2.15/libxml2-2.15.4.tar.xz`、`https://ftp.gnome.org/sources/libxml2/2.15/libxml2-2.15.4.tar.xz` |

三个候选地址必须得到同一个 SHA-256，任何字节不同的镜像都会被拒绝。离线
Runner 可以预置归档到 `/home/runner/software/libxml2/libxml2-2.15.4.tar.xz`
（或用 `PERF_LIBXML2_OFFLINE_DIR` 指向其他目录），预置文件同样要校验 SHA-256。

## 2. 构建方式

- 在独立工作目录内解压源码，**源码树内构建**（`./configure` + `make`）。
- 固定配置：`--prefix=<work>/libxml2-install --disable-shared --enable-static
  --without-python --without-zlib --without-iconv --without-icu
  --disable-dependency-tracking`，`CFLAGS="-O2 -pipe"`。
- 固定并行度 `-j4`（`PERF_LIBXML2_JOBS` 可覆盖），构建完成后额外执行
  `make -j4 runtest runsuite` 生成上游测试驱动。
- 不执行 `make install`：被测二进制 `xmllint`、`runtest`、`runsuite` 直接从构建
  目录运行，避免安装步骤影响测量。
- 实际版本从 `xmllint --version` 输出的数字编码（`21504` → `2.15.4`）解码并
  回填 `build_info.json`；与目标版本不一致时 build 阶段以 40 退出。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成，与 `software/Database/mysql`、`software/Bigdata/ray`、`software/Others/unixbench`
使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再需要编译器与
`dnf` 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-libxml2-<arch>-<运行ID>`，标签 `boostkit.libxml2.run-id=<运行ID>`，
  使用宿主网络；读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，只读挂载用例目录（独立运行
  时例外），容器内路径与宿主完全相同，`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`make`、`python3`、`tar`、`xz`、`gzip`、
  `diffutils`、`findutils`、`coreutils`、`sed`、`gawk`、`grep`、`util-linux`、`file`、
  `binutils` 与 `glibc-devel`；源码解压与构建（`./configure` + `make` + `make runtest
  runsuite`）、XML 语料生成、`xmllint`/`runtest`/`runsuite` 冒烟、版本解码、编译器标识与
  计时包装（`scripts/run_timed.py`）全部在容器内执行。
- 宿主机：只负责下载并校验源码包（优先 `/home/runner/software/libxml2/`）、读取语料清单与
  产物路径、严格解析 `results.json` 与清理本任务的容器。结果解析器不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器会在
  下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 3. 场景与指标

全部场景均使用生成器 `scripts/generate_corpus.py` 产生的**确定性语料**
（写入 `manifest.json` 记录字节数与 SHA-256），测量时用 `--nonet` 禁用网络，
语料不含外部实体，因此测量阶段完全离线。

| 场景 | 任务 | 语料 | 说明 |
|---|---|---|---|
| `xmllint_parse_wide` | parse | `wide.xml`（≈9.6 MB） | 10 万条记录的大文档解析（树模式） |
| `xmllint_parse_huge` | parse | `huge.xml`（≈38.9 MB） | 40 万条记录的超大文档解析 |
| `xmllint_parse_deep` | parse | `deep.xml`（深度 2000，`--huge`） | 深层嵌套文档解析（libxml2 默认上限 256，`--huge` 抬到 2048） |
| `xmllint_parse_namespaced` | parse | `namespaced.xml`（4 个命名空间） | 命名空间密集文档解析 |
| `xmllint_dtd_validate` | dtd_validate | `dtd.xml`（6 万条记录，内部 DTD） | DTD 校验路径（`--valid`） |
| `xmllint_sax_namespaced` | sax | `namespaced.xml` | SAX 事件驱动路径（`--sax`，不建树） |
| `xmllint_repeat_wide` | repeat | `repeat.xml`（≈4.8 MB）× 100 次 | `--repeat` 固定 100 次解析，抑制启动开销占比 |
| `xmllint_xpath_wide` | xpath | `wide.xml` | XPath `count(//item)`，必须等于 100000 |
| `upstream_runtest` | upstream_suite | 上游 `test/`+`result/` | 上游 `runtest` 驱动，必须输出 `Total 3886 tests, no errors` |
| `upstream_runsuite` | upstream_suite | 上游 `test/`+`result/` | 上游 `runsuite` 驱动，必须输出 `Total 1471 tests, no errors` |

每个场景 1 次预热 + `PERF_REPS` 次独立测量（正式证据 `PERF_REPS=5`），
取中位数。指标共 30 个：

- 墙钟中位数（`s`，越低越好）：10 个场景各 1 个；
- 峰值 RSS 中位数（`MiB`，越低越好）：10 个场景各 1 个；
- 解析吞吐（`MiB/s`，越高越好）：8 个 `xmllint` 场景，按语料真实字节数除以
  墙钟计算（`repeat` 按 100 次解析的总字节数）；
- 上游测试速率（`tests/s`，越高越好）：2 个上游驱动，按固定测试总数除以墙钟。

## 4. 证据与失败语义

- 原始证据：`runs/<场景>/warmup.log`、`rep<i>.log`、`rep<i>.json`；所有测量
  由 `scripts/run_timed.py` 统一产生（单子进程、完整输出落盘、墙钟 +
  `ru_maxrss`）。
- 严格校验：缺少样本、非数值/NaN/0 样本、非零退出、缺少原始日志、日志中缺少
  固定正确性标记（XPath 计数、上游 `Total N tests, no errors`）都会让 test
  阶段以 50 退出；失败时把日志尾部 ≥40 行打印到 stdout。
- `results.json` 由 `scripts/results/parse_benchmark.py` 归一化生成，包含
  指标值、单位、方向、样本列表与参数；不做零填充或估算。

## 5. 独立运行

```bash
# 六阶段（框架）
python3 framework/run_case.py \
  --case software/Toolchain/libxml2/case.yaml \
  --version 2.15.4 --architecture x86_64 --run-id <run-id> --stage build

# 独立入口（不经框架）
bash software/Toolchain/libxml2/libxml2_test.sh --results-dir /tmp/libxml2-results
```

常用环境变量：`PERF_REPS`、`PERF_LIBXML2_JOBS`、`PERF_LIBXML2_OFFLINE_DIR`、
`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、
`PERF_WORK_DIR`。

`PERF_VARIANT=optimized` 为保留变体：当前实现显式返回 30，不会回退到 base，
也不会生成 `build_variant.json`。

## 6. 与手册建议口径的差异

- 手册建议包含上游 `testSAX`；上游 2.15.4 的 `check_PROGRAMS` 中已不存在
  `testSAX`（`runtest`/`runsuite`/`testapi` 等保留），因此 SAX 路径改用
  `xmllint --sax` 覆盖，并在本文件与 QA 文档中记录该偏差。
- `make check` 在本环境会因上游 `check-local`（xstc/XML Schema 测试集）以 2 退出，
  故场景直接运行 `./runtest` 与 `./runsuite` 两个驱动，二者均需打印固定
  `Total N tests, no errors` 汇总行。
- 手册建议的固定 XML 解析与 `xmllint --repeat` 均已覆盖；`--repeat` 固定
  100 次以降低进程启动开销占比。
