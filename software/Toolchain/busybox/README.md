# BusyBox 1.38.0 applet 性能测试

本用例在 `x86_64`、`aarch64` Runner 上从官方源码构建 BusyBox 1.38.0（上游默认配置
`defconfig`），再用构建出的多调用二进制逐个 applet 执行固定负载：`sha256sum` 哈希、
`sort -n` 数值排序、`grep -c` 模式计数、`sed` 替换、`awk` 聚合、`gzip -6` 压缩、
`tar -czf` 归档与 `cut` 字段提取。目标是让两架构在**同一份源码、同一组确定性语料、
同一套命令**下比较单个 applet 的吞吐与内存开销。

入口为 `busybox_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止
阶段；直接执行入口脚本也使用这些阶段。基础版构建位于 `scripts/builders/base.sh`，公共
路径与常量在 `scripts/common.sh`，测量包装在 `scripts/run_timed.py`，每次重复的输出校验在
`scripts/verify_outputs.py`，结果解析与报告在 `scripts/results/`。工作流可选择 `base` 或
`optimized`，默认 `base`；`optimized` 构建尚未实现，选择后会在 build 阶段明确失败
（退出码 30），不会回退到 `base`，也不会写出 `build_variant.json`。

本用例只测单 applet 的进程级行为（每次测量 = 一次 applet 调用），不测 shell 交互、
`ash` 启动速度或 GCC/glibc 版本差异；BusyBox 的 applet 实现来自固定源码包，因此两架构
比较的是同一份 C 源码在不同架构上的编译产物。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| BusyBox | [官方发布点 busybox.net](https://busybox.net/downloads/) 的 1.38.0 源码包 `busybox-1.38.0.tar.bz2` | 优先读取 `/home/runner/software/busybox/busybox-1.38.0.tar.bz2`，缺失时下载；构建并安装到本次任务私有目录 |
| 被测 applet | 随 1.38.0 源码包构建的多调用二进制中的 `sha256sum`、`sort`、`grep`、`sed`、`awk`、`gzip`、`tar`、`cut` | `${PERF_WORK_DIR}/busybox-install/bin/busybox`，命令形态为 `busybox <applet>` |
| 语料生成器 | 本用例自带 `scripts/fixtures/generate_fixtures.py`（固定种子） | `${PERF_WORK_DIR}/fixtures/` |

Runner 通过 `dnf`（Debian/Ubuntu 上为 `apt-get`）安装缺失的 `gcc`、`make`、`tar`、
`bzip2`、`coreutils`、`python3`，以及 `curl`/`wget` 之一；安装后会再次自检这些命令，
失败则 build 阶段返回 30。构建只需要 C 编译器与系统 C 库：BusyBox 静态自带所需代码，
不需要 zlib、libreadline 或 `xz`。

Framework 将本次任务的工作目录传给脚本，以下称为 `${PERF_WORK_DIR}`。独立运行时默认位于
`/home/runner/boostkit-perf/busybox/<运行ID>/`。源码、构建、安装、语料与临时文件都放在
该目录下；结果写入单独的 `${RESULTS_DIR}`。测量命令在 `unshare -n` 新建的网络命名空间内
执行，构建期已把源码包下载并校验完毕，测量期不需要网络。

## BusyBox 获取、构建与安装

源码包先从 `/home/runner/software/busybox/` 读取；没有时依次尝试下表候选。无论来源，
解压前都必须匹配下表的 SHA-256 与字节数。

| 源码包 | SHA-256 | 字节数 |
|---|---|---|
| `busybox-1.38.0.tar.bz2` | `34f9ea6ff8636f2c9241153b9114eefa9e65674a45318ae1ef95bb5f31c53bb2` | 2695723 |

候选顺序（`PERF_BUSYBOX_OFFLINE_DIR` 可覆盖第一个目录，`PERF_BUSYBOX_MIRROR` 可给非离线
候选加统一前缀）：

```text
${PERF_BUSYBOX_OFFLINE_DIR}/busybox-1.38.0.tar.bz2
https://busybox.net/downloads/busybox-1.38.0.tar.bz2   # 官方发布点（权威来源）
http://busybox.net/downloads/busybox-1.38.0.tar.bz2
https://www.busybox.net/downloads/busybox-1.38.0.tar.bz2
```

busybox.net 是上游唯一官方分发点；本用例没有引入第三方镜像，离线包由发布流程预先放到
`/home/runner/software/busybox/`。所有候选都不可用时，build 阶段返回 30 并打印完整候选
清单与失败原因。

源码解压到 `busybox-src/`，在源码目录内用上游默认配置构建，安装到 `busybox-install/`：

```bash
cd "${PERF_WORK_DIR}/busybox-src"
make defconfig
make -j"${PERF_BUSYBOX_BUILD_JOBS}"
make CONFIG_PREFIX="${PERF_WORK_DIR}/busybox-install" install
"${PERF_WORK_DIR}/busybox-install/bin/busybox" | head -1   # 版本自检
```

`defconfig` 是源码树里的静态文件，两架构得到完全相同的 applet 集合与代码路径；
`PERF_BUSYBOX_BUILD_JOBS` 默认 8，本机与其他任务并行时用 `-j4`。`CFLAGS` 固定为
`-O2 -DNDEBUG`（写入 `build-provenance.txt` 与结果参数），不追加 `-march=native` 等
机器相关选项。构建后在 `busybox | head -1` 的横幅中读出 `v1.38.0`，去掉 `v` 前缀写入
`${RESULTS_DIR}/actual-version.txt`，与请求版本不一致则 build 返回 30；同时用
`busybox --list` 检查 8 个必需 applet 全部存在。横幅里的构建时间戳不参与比较。

`make install` 只创建 BusyBox 二进制与部分符号链接，本用例不依赖符号链接：所有场景
统一以 `busybox <applet>` 形式调用，保证两架构命令完全一致。

## 测试数据

测试语料由 `scripts/fixtures/generate_fixtures.py` 用固定种子（`20261102`）的 splitmix64
生成，与机器无关；start 阶段每次重新生成，并逐个比对下表字节数、行数与 SHA-256，任一
不一致即 start 返回 20。生成器同时算出 sed/cut 输出的期望摘要、grep 期望命中行数与 awk
期望聚合值，写进 `fixtures.json`，start 与解析器再与 `common.sh` 中固化的常量交叉校验。

| 文件 | 内容 | 字节数 | SHA-256 |
|---|---|---|---|
| `corpus_text.txt` | 900,000 行带单词与 `tag=` 标签的文本 | 53259531 | `bc19c8c081631054f1b9eeb00e7aaa216ca3f48464dd300adf19180f44d9ccc6` |
| `gzip_input.txt` | `corpus_text.txt` 的前 400,000 行（行对齐） | 23667205 | `5f13276f7e51af288bb732bf84e1c5bd5f7d5279ba3b66716f5e9f709eb28280` |
| `sort_input.txt` | 1,000,000 行 `8 位数值键 + kNNN` 记录（最大键 99999457） | 14000000 | `8b1700b34099bc29eb860d4fc031bc4809d5518615da40ca12a4d0ec15e2ab3f` |
| `tar_tree/` | 16,000 个小文本文件（每个 100 行，合计 56,000,000 字节） | 56000000 | 内容摘要 `db57e877c451b5c02265f5536b38605e47e80e76f6781d3adabbd4c18fd9997d` |

语料中 `tag=alpha` 的命中行数在生成时固化为 **87913**；`sed` 输出（`alpha→ALPHA`、
`beta→BETA`）摘要为 `f95546057b16fc3117f1405029399152b1616790db86ba38ce8f748cd3ccc09f`；
`cut -d " " -f 1,3` 输出摘要为 `fc5000daaba27a9190e8ddd2379d5c0f5f6a57de75328ce03c32e35e4a0ec1ab`；
`awk '{s+=length($0)} END{print s}'` 的期望结果为 **52359531**（字节总数 − 900000 个换行）。
任一不符即判测试失败（退出码 50），不做“跑完就算”的宽松处理。

## 场景与命令

共 8 个场景，全部使用上游 applet，语料与命令固定；每次测量都是一个 applet 子进程
（`unshare -n` 内运行），1 次预热 + `PERF_REPS` 次独立重复：

| 场景 | 命令（核心部分） | 说明 |
|---|---|---|
| `sha256sum_hash` | `busybox sha256sum corpus_text.txt`（同一路径重复 8 次） | 顺序哈希 8×53,259,531 字节；期望每行摘要都等于语料摘要 |
| `sort_numeric` | `busybox sort -n sort_input.txt` | 100 万行数值排序；期望 `sort -n -c` 通过且行数不变 |
| `grep_count` | `busybox grep -c tag=alpha corpus_text.txt` | 全语料模式计数；期望恰好 87913 |
| `sed_substitute` | `busybox sed 's/alpha/ALPHA/g;s/beta/BETA/g' corpus_text.txt` | 两处全局替换；期望输出摘要匹配 |
| `awk_aggregate` | `busybox awk '{s+=length($0)} END{print s}' corpus_text.txt` | 逐行长度聚合；期望 52359531 |
| `gzip_compress` | `busybox gzip -6 -c gzip_input.txt` | deflate 压缩 23,667,205 字节；期望解压回原文摘要 |
| `tar_gzip_create` | `busybox tar -czf ARCHIVE -C tar_tree .` | 归档 16,000 个文件并 gzip 压缩；期望 16001 个条目（含 `.`） |
| `cut_fields` | `busybox cut -d " " -f 1,3 corpus_text.txt` | 两字段提取；期望输出摘要匹配 |

`sha256sum` 场景把同一文件路径重复 8 次作为参数，单进程内完成 8 遍哈希，避免为“足够长的
测量窗口”生成额外大文件；`sha256sum` 会为每个参数各输出一行摘要，因此天然校验了全部
8 遍的输出。

`sort`/`sed`/`gzip`/`cut` 的输出较大，`run_timed.py` 用 `--stdout-file` 把子进程 stdout
直接写入 `${PERF_WORK_DIR}/out/`，测量窗口内不做任何解析；`sha256sum`/`grep`/`awk`
只输出摘要、计数或聚合值，直接留在 `runs/<场景>/rep<i>.log` 中。

每次重复结束后、测量窗口之外，`scripts/verify_outputs.py` 立即校验该次输出，并把紧凑
报告写到 `runs/<场景>/rep<i>.check`（`PERF-CHECK name=... expected=... actual=...
status=ok` 与 `PERF-RESULT status=ok`），随后删除大输出文件以控制磁盘占用。校验包括
摘要、计数、聚合值、`sort -c` 顺序检查、gzip 解压回原文摘要、tar 条目数等，全部是
applet 自己的输出，不是“只看退出码”。

## 指标与方向

每个场景产出 2 项基础指标（墙钟、峰值 RSS）与 1–2 项工作负载指标，共 28 项；主指标是
墙钟与吞吐，峰值 RSS 用于约束内存开销。所有指标取 `PERF_REPS=5` 次独立重复的中位数，
同时保留全部样本与 min/max/mean/stdev。

| 指标类别 | 单位 | 方向 | 说明 |
|---|---|---|---|
| `<场景>_wall_s` | 秒 | 越小越好 | 一次测量进程的墙钟时间 |
| `<场景>_rss_mib` | MiB | 越小越好 | 测量进程的峰值 RSS（`VmHWM`） |
| `sha256sum_hash_hash_mib_per_second` | MiB/s | 越大越好 | 8 × 语料字节 / 墙钟 |
| `sort_numeric_sorted_lines_per_second` | 行/s | 越大越好 | 1,000,000 行 / 墙钟 |
| `sort_numeric_sorted_lines` | 行 | 越大越好 | 排序后行数（期望 1,000,000，顺序由 `sort -c` 校验） |
| `grep_count_matched_lines` | 行 | 越大越好 | 命中行数（期望 87913） |
| `grep_count_scan_mib_per_second` | MiB/s | 越大越好 | 语料字节 / 墙钟 |
| `sed_substitute_sed_mib_per_second` | MiB/s | 越大越好 | 语料字节 / 墙钟 |
| `awk_aggregate_aggregate_value` | 字节 | 越大越好 | 行长度聚合值（期望 52359531） |
| `awk_aggregate_aggregate_mib_per_second` | MiB/s | 越大越好 | 语料字节 / 墙钟 |
| `gzip_compress_gzip_mib_per_second` | MiB/s | 越大越好 | 输入字节 / 墙钟 |
| `tar_gzip_create_archive_entries` | 文件 | 越大越好 | 归档条目数（期望 16001） |
| `tar_gzip_create_archive_mib_per_second` | MiB/s | 越大越好 | 树内容字节 / 墙钟 |
| `cut_fields_cut_mib_per_second` | MiB/s | 越大越好 | 语料字节 / 墙钟 |

吞吐指标统一由“固定输入字节数 / 整个进程墙钟”计算，不使用 applet 内部可能被量化的
计时；Applet 的输出校验值作为常量指标进入结果，便于在 `results.json` 中直接核对两侧
是否处理了同一份工作负载。

参数（`parameters`）只包含与机器无关的量：变体、重复次数、离线标志、源码 SHA-256、
构建配置名（`defconfig`）、CFLAGS、并行度、语料字节/行数、tar 树文件数、固定期望值、
fixture SHA-256 等；CPU、编译器、网络模式、实际版本横幅等环境信息放在
`runtime_context`，不参与跨架构参数签名。

## 数据与运行顺序

1. **build**：安装依赖，取得并校验源码包，`make defconfig`、编译、安装，检查 8 个必需
   applet，校验实际版本，写 `build_variant.json` 与构建溯源信息。
2. **start**：生成语料并逐个校验字节数/行数/SHA-256 与 `fixtures.json` 的期望值，探测
   测量期能否用 `unshare -n` 隔离网络，把结果写入
   `${BUSYBOX_STATE_DIR}/measurement-network-mode.txt`。
3. **test**：对 8 个场景依次跑 1 次预热 + `PERF_REPS` 次独立重复；每次重复都由
   `scripts/run_timed.py` 包一层，执行完立刻把墙钟、峰值 RSS、退出码写入
   `runs/<场景>/rep<i>.json`，完整 stdout/stderr 写入 `runs/<场景>/rep<i>.log`（大输出
   写到任务私有 `out/` 目录），预热的对应文件为 `warmup.log`/`warmup.json`。随后
   `scripts/verify_outputs.py` 校验输出并写 `rep<i>.check`，全部通过后才由
   `scripts/results/parse_benchmark.py` 归一化为 `results.json`，同时把全部日志与校验
   报告汇总为 `raw-output.log`。
4. **stop**：确认没有遗留被测进程（只按 `${PERF_WORK_DIR}` 标记精确清理），删除临时
   目录与 `out/`，返回 60 表示清理失败。
5. **finalize**：由 Framework 完成；独立运行时由 `scripts/results/standalone_runtime.py`
   写出 `report.md` 与 `standalone_summary.json`。

测量期离线是硬约束：默认所有测量命令都在 `unshare -n` 内运行，若 Runner 不支持
`unshare`，start 阶段直接失败，除非显式设置
`PERF_BUSYBOX_ALLOW_ONLINE_MEASUREMENT=1`（此时报告中必须说明）。构建期不测量，允许
联网取源码。

解析器是严格的：场景集合必须与上表完全一致；每个声明的重复样本、日志与校验报告必须
存在；退出码非 0、超时、缺校验项、校验值不等于 `common.sh` 的固定值、指标非有限正数、
日志出现 `NaN`/段错误标记——任一情况 test 阶段返回 50，**不填充、不插值、不以 0 补齐
样本**。失败时输出 40 行日志尾部辅助定位。

退出码约定：10 参数错误、20 start、30 构建、50 test/stop、60 finalize。

独立运行示例：

```bash
bash software/Toolchain/busybox/busybox_test.sh \
  --version 1.38.0 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/busybox/results/1.38.0
```

需要排查时可加 `--keep-workdir` 保留源码、构建与语料目录；默认独立运行结束会清理自己的
`${PERF_WORK_DIR}`。正式证据要求 `PERF_REPS=5`，`PERF_REPS=1` 只用于本地链路自检
（脚本会打印告警）。

## 容器化执行

每个阶段都在**本次任务专属的 openEuler 24.03 LTS SP4 容器**内执行（容器运行时块由
`adaptation/scripts/add-container-block.py` 从模板写入 `scripts/common.sh`，勿手改标记区）：

- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，缺失时才从
  `repo.openeuler.org` 下载；加载前校验 `.sha256sum`、镜像架构（`x86_64`→`amd64`、
  `aarch64`→`arm64`）以及 `/etc/os-release` 中的 `24.03`。
- **容器名/标签**：`boostkit-busybox-<arch>-<run-id>`，标签 `boostkit.busybox.run-id=<run-id>`；
  删除前校验标签，拒绝删除其他任务的容器（返回 60）；启动时清理同前缀、run-id 不同的陈旧容器。
- **能力与网络**：`BUSYBOX_CONTAINER_EXTRA_ARGS=(--cap-add=SYS_ADMIN --cap-add=NET_ADMIN)`
  （在容器块标记之前声明）——`SYS_ADMIN` 用于创建网络命名空间，`NET_ADMIN` 用于在命名空间
  内配置接口（审计用例统一给两个 cap，避免 `lo` 拉不起来时静默失败）。容器使用
  `--network=host`，但测量仍默认包在 `unshare -n` 中，`start` 阶段在**容器内**探测
  `unshare -n`，探测失败时沿用原有 `PERF_BUSYBOX_ALLOW_ONLINE_MEASUREMENT` 语义。
- **挂载**：`PERF_WORK_DIR`、`RESULTS_DIR` 与用例目录按相同绝对路径挂入（用例目录只读），
  容器内外路径一致；另挂 `/etc/passwd`、`/etc/group`。容器内以 `dnf` 安装 `gcc`、`make`、
  `tar`、`gzip`、`bzip2`、`xz`、`coreutils`、`findutils`、`sed`、`gawk`、`grep`、
  `util-linux`、`file`、`glibc-devel`、`binutils`、`python3`；宿主机只保留 Docker 与
  下载/SHA-256 校验工具。
- **职责划分**：宿主机负责源码归档下载与 SHA-256 校验、`run_timed.py` 的严格解析与输出校验；
  容器内负责解包、`make defconfig`/编译/安装、applet 列表与版本探测、语料生成
  （`generate_fixtures.py`）、以及**全部计时样本**——`test` 阶段通过
  `busybox_container_exec_at` 在容器内启动被测 applet，`docker exec` 的管理开销不落在测量
  窗口内。
- **清理**：`stop` 在 `initialize_runtime` 之后先调用 `remove_busybox_container`（幂等，容器
  不存在返回 0），再按原有标记精确清理被测进程。
- **独立运行**：仍需能访问 Docker daemon 且允许 `--cap-add=SYS_ADMIN`；宿主机不再需要
  gcc/make/python3 构建工具。

## 已知限制与风险

- **共享 Runner 的噪声**：本机验证时同一 WSL 有多个任务并行构建与测量，短场景
  （`awk`、`cut`、`grep` 约 0.2–0.3 s）的变异系数明显高于长场景（`sort` ~1.1 s、
  `tar -czf` ~1.1 s）；aarch64 专用 Runner 应为独占环境，若共享请关注 `stdev`。
- **峰值 RSS 的固定底噪**：峰值取自 `/proc/<pid>/status` 的 `VmHWM`，从 `unshare`
  子进程继承的约 1.7–2.0 MiB 启动足迹会抬高小 applet 的读数（实测 2.5–2.9 MiB）；
  `sort` 因缓冲区分配达到约 48 MiB，是 8 个场景中唯一明显受内存影响的。跨架构比较时
  底噪相同，但绝对值不是 applet 独占内存。
- **`sha256sum` 的硬件加速**：1.38.0 的 `defconfig` 启用 `SHA256_HWACCEL`（通过内核
  AF_ALG 使用硬件 SHA-256），哈希吞吐因此可达 GB/s 量级，0.25–0.30 s 的测量窗口较短；
  该指标反映的是“applet + 内核加密实现”的端到端吞吐，不是纯软件 SHA-256 速度。若两侧
  内核能力不同，该项差异可能来自内核而非 BusyBox。
- **tar 归档的内容差异**：`tar -czf` 会写入文件 mtime，归档自身字节不可逐字节跨平台
  比较，因此只校验条目数（16001）与归档非空；树内容摘要单独校验。
- **单个 applet 的进程启动开销**：每场景一次进程启动（约 5–15 ms）计入墙钟，短场景中
  占比可达 5%；这是“一次 applet 调用”的真实成本，不做扣除。
- **`optimized` 变体未实现**：选择后会立刻以 30 失败，不会静默回退。
