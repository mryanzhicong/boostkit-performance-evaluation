# Ultrascan 5.8.0 性能测试

本用例从源码构建 **Ultrascan 5.8.0**（鲲鹏社区 Hyperscan 分支）及其官方基准工具
`hsbench`，在预置的 7 个规则集和 6 个 SQLite 语料上运行 **9 个 block 模式场景**，
每个场景取 `hsbench` 的 **Mean throughput (overall)**（Mbit/s）作为独立指标。

- 正式证据只跑 **aarch64**（Kunpeng 950）；x86_64 仅用于本地功能自测，Blue 不派发
  x86_64，报告里也不把两架构的绝对值直接比较。
- 容器不限制 CPU、内存或 NUMA；每个任务使用独立的 openEuler 24.03 LTS SP4 容器。
- 入口脚本为 [`ultrascan_test.sh`](ultrascan_test.sh)，Framework 六阶段与独立运行共用
  `scripts/builders`、`scripts/stages` 中的同一批函数。
- `base` 是唯一实现的变体；调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，
  选择后会在构建阶段明确失败并返回 30，不会退回基础版。
- 数据不随仓库提交：13 个输入文件预置在 `/home/runner/software/Ultrascan`，由
  [`benchmark/dataset-lock.json`](benchmark/dataset-lock.json) 固定大小、CRC32/SHA-256
  和规则条数。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | Ultrascan 5.8.0，Tag `Ultrascan-v5.8.0`，commit `2a2ab98890e878b6ff297f2ffe4cd2e14330b498`；<https://gitcode.com/boostkit/Ultrascan> | 源码归档 `${PERF_WORK_DIR}/ultrascan-source`；归档优先从 `/home/runner/software/Ultrascan/Ultrascan-v5.8.0-2a2ab98.tar.gz` 读取，缺失时宿主 `git clone` |
| 测量工具 `hsbench` | 同源码 `tools/hsbench`，CMake **Release**，`--target hsbench` | `${PERF_WORK_DIR}/build/bin/hsbench` |
| 字节码工具 `hsdump` | 同源码 `tools/hsdump`，CMake **Debug**（`DUMP_SUPPORT`），仅用于兼容 `-U` 场景 | `${PERF_WORK_DIR}/build-debug/bin/hsdump`；输出 `${PERF_WORK_DIR}/dump_output/dump/db.raw` |
| 测试数据集 | 李旭 2026-11-16 邮件附件 `ultrascan-data.zip`，2,206,083,993 B；7 个规则集 + 6 个 SQLite 语料 | 预置目录 `/home/runner/software/Ultrascan`（可用 `PERF_ULTRASCAN_DATA_DIR` 覆盖）；校验清单 [`benchmark/dataset-lock.json`](benchmark/dataset-lock.json) |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |

`snort_literals` 和 `gutenberg.db` 与 Intel 官方 hsbench-samples 中的同名文件逐字节一致
（SHA-256 分别为 `ac54e998…44ee`、`b1d621f8…18a6`），因此 2 个官方兼容场景仍可与旧结果
对照；其余规则集和语料来自本次邮件附件，不能与 Intel 官方样本混称。

## Ultrascan 获取、构建与容器启动

### 1. 获取源码

宿主机按以下顺序获取源码，任何一步都必须通过 commit/归档 SHA-256 校验：

```bash
# 1) 公共离线目录（优先）
/home/runner/software/Ultrascan/Ultrascan-v5.8.0-2a2ab98.tar.gz
# 2) 本任务缓存
${PERF_WORK_DIR}/ultrascan-source
# 3) 最后才 clone（gitcode，失败再试 gitee）
git clone --depth 1 --branch Ultrascan-v5.8.0 \
  https://gitcode.com/boostkit/Ultrascan.git "${PERF_WORK_DIR}/ultrascan-source"
```

归档 SHA-256 固定为
`b0ad7d0126585581e93f621d1295066e7becf6d59c2179916c74e84e67f29b9b`；clone 回退还要求
`HEAD == 2a2ab98890e878b6ff297f2ffe4cd2e14330b498`。若旧 Runner 只有
`/home/runner/software/ultrascan`，源码归档会回退到该目录读取；数据集仍优先使用
`/home/runner/software/Ultrascan`。解包和构建全部在容器内完成。

### 2. 预置数据集

把 `ultrascan-data.zip` 解压后的 **内容** 放到（推荐摊平；脚本也兼容 ZIP 自带的 `ultrascan-data/` 一层）：

```text
/home/runner/software/Ultrascan/
  alexa200.db
  gutenberg.db
  qiming.db
  wanan_1byte.db
  wanan_2-4.db
  wanan_clone.db
  snort_literals
  snort_pcres
  teakettle_2500
  启明核心规则集
  短规则规则集
  短规则规则集1byte
  美亚规则集
```

也可以保留 ZIP 内的 `ultrascan-data/` 目录，脚本会自动识别
`.../Ultrascan/ultrascan-data/<files>`：

```bash
unzip -q ultrascan-data.zip -d /home/runner/software/Ultrascan
# 或把内容摊平：
# mv /home/runner/software/Ultrascan/ultrascan-data/* /home/runner/software/Ultrascan/
```

数据集只校验、不复制；2.5 GB 的 `wanan_clone.db` 不会进入 `${PERF_WORK_DIR}`。校验命令形态：

```bash
python3 software/Acceleration/ultrascan/scripts/prepare_dataset.py verify \
  --root /home/runner/software/Ultrascan \
  --lock software/Acceleration/ultrascan/benchmark/dataset-lock.json \
  --manifest "${PERF_WORK_DIR}/dataset-manifest.json"
```

校验内容包括：每个文件的大小、CRC32（小文件另有 SHA-256）、SQLite `chunk(id, stream_id,
data)` schema，以及 `COUNT(*)` / `SUM(LENGTH(data))` / `COUNT(DISTINCT stream_id)`。
任何不一致都会在 build 阶段返回 30，不会带病测量。

### 3. 容器创建

以下是实际命令形态：

```bash
docker run --detach --name "${ULTRASCAN_CONTAINER_NAME}" \
  --label "boostkit.ultrascan.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --ulimit nofile=1048576:1048576 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${ULTRASCAN_OFFLINE_DIR},target=${ULTRASCAN_OFFLINE_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${ULTRASCAN_CONTAINER_IMAGE}" sleep infinity
```

容器以 Runner 用户身份运行，不设 CPU/内存配额，使用宿主网络；数据目录只读挂载，容器内
路径与宿主完全相同。容器内先切换本次容器的 openEuler 镜像源，再 `dnf` 安装 `cmake`、
`make`、`gcc`、`gcc-c++`、`ragel`、`python3`、`boost-devel`、`sqlite-devel`、
`pkgconf-pkg-config`、`unzip`、`tar`、`curl`、`coreutils`、`diffutils`、`findutils`、
`time`、`glibc-devel`、`glibc-common`、`binutils`、`which`、`gzip`、`util-linux` 等依赖；
不安装 `git`，源码归档由宿主校验后交给容器。宿主只负责下载/校验源码归档和调用 Docker，
**不向宿主机安装任何软件包，也不修改宿主机的镜像源或 CA 配置**。

### 4. 构建

```bash
# Release hsbench（被测二进制）
cmake "${SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_EXAMPLES=OFF -DBUILD_CHIMERA=OFF
cmake --build . --target hsbench -j "${JOBS}"

# Debug hsdump（只用于旧口径 -U 场景的 DUMP_SUPPORT）
cmake "${SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_EXAMPLES=OFF -DBUILD_CHIMERA=OFF
cmake --build . --target hsdump -j "${JOBS}"

# 兼容场景的通用字节码
hsdump -e "${ULTRASCAN_DATA_ROOT}/snort_literals" -N -U \
  -o "${PERF_WORK_DIR}/dump_output"
```

构建完成后用 `hsbench -e .../snort_literals -c .../gutenberg.db -N -n 1` 做冒烟扫描，从
`Hyperscan info: Version: 5.8.0` 自证实际版本；再用 `-U dump/db.raw` 验证通用字节码可加载。

## 数据与运行顺序

### 场景矩阵

`benchmark/scenarios.json` 声明 9 个场景；7 行矩阵与邮件 xlsx 一一对应，前 2 行为旧口径
兼容场景：

| # | 场景 key | `-e` 规则集 | `-c` 语料 | `-n` | `-G` |
|---|---|---|---|---|---|
| 1 | `hsbench_rules_block` | `snort_literals` | `gutenberg.db` | 1 | — |
| 2 | `hsbench_ubc_block` | `snort_literals`（`-U dump/db.raw`） | `gutenberg.db` | 1 | — |
| 3 | `hsbench_teakettle_2500_gutenberg_block` | `teakettle_2500` | `gutenberg.db` | 1000 | `allowLily:1` |
| 4 | `hsbench_snort_pcres_alexa200_block` | `snort_pcres` | `alexa200.db` | 100 | `allowLily:1` |
| 5 | `hsbench_snort_literals_alexa200_block` | `snort_literals` | `alexa200.db` | 200 | `allowLily:1` |
| 6 | `hsbench_qiming_core_qiming_block` | `启明核心规则集` | `qiming.db` | 200 | `allowLily:1;allowNeoFdr:1` |
| 7 | `hsbench_short_rules_wanan_clone_block` | `短规则规则集` | `wanan_clone.db` | 100 | `allowLily:1` |
| 8 | `hsbench_short_rules_1byte_wanan_1byte_block` | `短规则规则集1byte` | `wanan_1byte.db` | 100 | `allowLily:1` |
| 9 | `hsbench_meiya_wanan_2_4_block` | `美亚规则集` | `wanan_2-4.db` | 100 | `allowLily:1` |

x86_64 本地功能自测与 aarch64 正式证据使用**同一矩阵**，只有架构和运行位置不同。
所有规则场景的实际命令形态：

```bash
hsbench -e "${ULTRASCAN_DATA_ROOT}/<rule>" \
  -c "${ULTRASCAN_DATA_ROOT}/<corpus>" \
  -N -n <iterations> [-G '<overrides>']
```

`-N` 是 block 模式，`-n` 是 hsbench 的测试迭代次数（不是外层重复次数）。`-G` 通过
Ultrascan 的 `hs_set_grey_overrides()` 设置编译期 Grey 参数，本项目使用的 Release
`hsbench` 支持该参数；它只影响规则编译，不影响已序列化的 `-U` 场景。

### 执行顺序

1. **build**：启动私有容器 → 校验预置数据集 → 解包/版本自证 → Release `hsbench` →
   Debug `hsdump` → 生成 `dump/db.raw` → 冒烟扫描 → 写 `build-state.json`。实际命令：

   ```bash
   # 数据校验（容器内执行；宿主路径与容器内完全相同）
   python3 "${SCRIPT_DIR}/scripts/prepare_dataset.py" verify \
     --root "${ULTRASCAN_DATA_ROOT}" \
     --lock "${SCRIPT_DIR}/benchmark/dataset-lock.json" \
     --manifest "${PERF_WORK_DIR}/dataset-manifest.json"

   # Release hsbench / Debug hsdump / 通用字节码
   cmake "${SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Release \
     -DBUILD_EXAMPLES=OFF -DBUILD_CHIMERA=OFF
   cmake --build "${BUILD_DIR}" --target hsbench -j "${JOBS}"
   cmake "${SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Debug \
     -DBUILD_EXAMPLES=OFF -DBUILD_CHIMERA=OFF
   cmake --build "${DUMP_BUILD_DIR}" --target hsdump -j "${JOBS}"
   "${HSDUMP_BIN}" -e "${ULTRASCAN_DATA_ROOT}/snort_literals" -N -U \
     -o "${DUMP_OUTPUT_ROOT}"
   ```

2. **start**：校验容器、数据集、`hsbench`、`hsdump` 和 `db.raw` 仍可用；本用例没有后台
   服务，`start` 只做就绪检查。实际命令：

   ```bash
   docker exec "${ULTRASCAN_CONTAINER_NAME}" test -x "${HSBENCH_BIN}"
   docker exec "${ULTRASCAN_CONTAINER_NAME}" test -x "${HSDUMP_BIN}"
   docker exec "${ULTRASCAN_CONTAINER_NAME}" test -f "${DUMP_DB}"
   ```

3. **test**：容器内按 9 个场景依次执行 **1 次预热 + `PERF_REPS` 次独立测量**
   （`PERF_REPS` 默认 5），每条样本记录原始 stdout、GNU time 墙钟和峰值 RSS。实际命令：

   ```bash
   # 由 drive 为每个预热/正式样本拼出的命令，外层由 /usr/bin/time -v 包裹
   /usr/bin/time -v -o ".rep1.time" \
     "${HSBENCH_BIN}" -e "${ULTRASCAN_DATA_ROOT}/teakettle_2500" \
     -c "${ULTRASCAN_DATA_ROOT}/gutenberg.db" -N -n 1000 -G 'allowLily:1'
   ```

4. **report**：宿主机严格解析每条样本，校验版本、block 模式、规则表达式数、语料
   bytes/blocks、匹配数一致性、吞吐为正，再对每个场景的 `PERF_REPS` 个值取中位数。
   实际命令：

   ```bash
   python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" report \
     --runs-dir "${RESULTS_DIR}/runs" \
     --raw-output "${RESULTS_DIR}/benchmark_hsbench.txt" \
     --output "${RESULTS_DIR}/results.json" \
     --dataset-manifest "${PERF_WORK_DIR}/dataset-manifest.json" \
     --version "${SOFTWARE_VERSION}" \
     --architecture "$(uname -m)" \
     --warmups "${PERF_ULTRASCAN_WARMUPS}" \
     --reps "${PERF_REPS}"
   ```

5. **stop**：按 run-id 标签删除本任务容器；标签不符时拒绝删除并返回 60。实际命令：

   ```bash
   docker rm -f "${ULTRASCAN_CONTAINER_NAME}"
   ```


运行目录固定为：

```text
${RESULTS_DIR}/runs/<scenario>/warmup1.{log,json}
${RESULTS_DIR}/runs/<scenario>/rep1.{log,json} ... repN.{log,json}
${RESULTS_DIR}/benchmark_hsbench.txt
${RESULTS_DIR}/results.json
```

`PERF_REPS` 和 `PERF_ULTRASCAN_WARMUPS` 可调，但正式证据至少要求 1 次预热 + 5 次有效
测量；`PERF_REPS=6` 可满足 benchstat 的置信区间输入要求。

## 指标与产物

每个场景产出 **1 条**指标，共 **9 条**；数值为对应场景 `PERF_REPS` 次独立测量的中位数：

| 指标 | 来源 | 单位 | 方向 | 分组 |
|---|---|---|---|---|
| `hsbench_rules_block_mean_throughput_mbit_s` | `Mean throughput (overall)` | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_ubc_block_mean_throughput_mbit_s` | `Mean throughput (overall)` | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_teakettle_2500_gutenberg_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_snort_pcres_alexa200_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_snort_literals_alexa200_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_qiming_core_qiming_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_short_rules_wanan_clone_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_short_rules_1byte_wanan_1byte_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |
| `hsbench_meiya_wanan_2_4_block_mean_throughput_mbit_s` | 同上 | Mbit/s | 越大越好 | `hsbench` |

指标总数：**9 条**（每个场景 1 条）；分组规则：全部归入 `hsbench` 组，不按架构或规则集拆分。
只产出 `Mean throughput (overall)`；`Time spent scanning`、`Overall block rate`、匹配数、
bytecode size、peak heap/RSS、墙钟等只作为原始证据保留，不进入性能指标。

主要产物：

| 产物 | 说明 |
|---|---|
| `${PERF_WORK_DIR}/build-state.json` | 源码 tag/commit、归档 SHA-256、数据集 root/zip/每个文件的摘要、Release/Debug 构建、`db.raw` SHA-256、编译器 |
| `${PERF_WORK_DIR}/dataset-manifest.json` | 数据集逐文件大小、CRC32/SHA-256、规则条数、SQLite 语料 bytes/blocks/streams |
| `runs/<scenario>/…` | 每个场景的预热和正式样本，含实际命令行、退出码、墙钟、峰值 RSS |
| `benchmark_hsbench.txt` | 9 个场景全部原始 hsbench 输出 |
| `results.json` | 9 条指标、样本值、中位数/均值/最小/最大值、场景矩阵、数据集摘要 |
| `report.md` / `status.json` | 仅独立运行模式生成；Framework 模式由框架生成任务级报告 |

解析器严格失败：缺样本、样本数多于声明、退出码非 0、超时、版本/模式不符、规则表达式数
不符、语料 bytes/blocks 不符、重复样本间匹配数或 bytecode 不一致、吞吐非正，都会返回 50；
绝不补零或用默认值。

## 独立运行

```bash
cd /mnt/d/workspace/Performance_evaluation/work/ultrascan/repo
wsl.exe -d Ubuntu-22.04 -u root bash -c '
  cd /mnt/d/workspace/Performance_evaluation/work/ultrascan/repo
  software/Acceleration/ultrascan/ultrascan_test.sh \
    --variant base \
    --results-dir /home/runner/boostkit-perf/ultrascan/manual-$(date +%s)
'
```

入口内部实际执行的关键命令：

```bash
# 1. 创建任务容器（完整 --mount 见 2.3 节）
docker run --detach --name "${ULTRASCAN_CONTAINER_NAME}" \
  --label "boostkit.ultrascan.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${ULTRASCAN_OFFLINE_DIR},target=${ULTRASCAN_OFFLINE_DIR},readonly" \
  "${ULTRASCAN_CONTAINER_IMAGE}" sleep infinity

# 2. 容器内测量（drive 负责 9 场景 ×（1 预热 + N 正式））
docker exec --workdir "${PERF_WORK_DIR}" "${ULTRASCAN_CONTAINER_NAME}" \
  env LC_ALL=C LANG=C TZ=UTC \
  python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" drive \
  --hsbench "${HSBENCH_BIN}" \
  --dataset-root "${ULTRASCAN_DATA_ROOT}" \
  --dataset-manifest "${PERF_WORK_DIR}/dataset-manifest.json" \
  --dump-db "${DUMP_DB}" \
  --runs-dir "${RESULTS_DIR}/runs" \
  --warmups "${PERF_ULTRASCAN_WARMUPS}" \
  --reps "${PERF_REPS}"

# 3. 宿主严格解析并写 results.json
python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" report \
  --runs-dir "${RESULTS_DIR}/runs" \
  --raw-output "${RESULTS_DIR}/benchmark_hsbench.txt" \
  --output "${RESULTS_DIR}/results.json" \
  --dataset-manifest "${PERF_WORK_DIR}/dataset-manifest.json" \
  --version "${SOFTWARE_VERSION}" --architecture "$(uname -m)" \
  --warmups "${PERF_ULTRASCAN_WARMUPS}" --reps "${PERF_REPS}"
```

常用环境变量：

| 变量 | 默认值 | 说明 |
|---|---|---|
| `PERF_REPS` | `5` | 每个场景的正式测量次数 |
| `PERF_ULTRASCAN_WARMUPS` | `1` | 每个场景的预热次数 |
| `PERF_ULTRASCAN_DATA_DIR` | `/home/runner/software/Ultrascan` | 预置数据集目录 |
| `PERF_ULTRASCAN_OFFLINE_DIR` | `/home/runner/software/Ultrascan` | 数据集目录；源码归档也优先从这里读取 |
| `PERF_ULTRASCAN_LEGACY_DIR` | `/home/runner/software/ultrascan` | 旧 Runner 的源码归档/数据回退目录，仅在上面的目录没有对应文件时使用 |
| `PERF_ULTRASCAN_BUILD_JOBS` | `nproc`（上限 16） | 容器内编译并行度 |
| `PERF_ULTRASCAN_MEASUREMENT_TIMEOUT` | `3600` | 单条 hsbench 样本超时秒数 |

只想做链路自测时，可给 `parse_benchmark.py drive/report` 传 `--scenario <key>`；正式
结果不得使用该过滤参数。

## 已知限制

1. **正式证据只跑 aarch64**：Kunpeng 950 是唯一正式口径；x86_64 仅本地六阶段功能自测，
   不派发 Blue，也不把两架构绝对值直接比较。
2. **数据必须预置**：2.05 GB 压缩包/3.44 GiB 解压内容不随仓库提交，Runner 必须提前把
   内容放到 `/home/runner/software/Ultrascan`；缺失时 build 直接返回 30。
3. **大语料单线程耗时长**：`wanan_clone.db` 2.54 GB × `-n 100`，单样本可能达到分钟级；
   正式调度要预留 360 分钟超时，并按 1 预热 + 5 测量执行。
4. **`-G` 是 Ultrascan 私有 Grey 参数**：`allowLily` / `allowNeoFdr` 的具体引擎选择属于
   实现细节，本用例只固定 xlsx 给出的字符串，不对其内部语义作额外承诺。
5. **矩阵不是全交叉**：9 个场景是按 xlsx 选定的组合，不能把某个规则集/语料的结论外推到
   其他组合。
6. **兼容 `-U` 场景仍存在**：前 2 个旧口径场景保留用于和既有 PR/基线对照；7 行新矩阵
   不包含 `-U` 场景。
7. **aarch64 构建机指令调优**：Release 构建默认 `-march=native`，`hsbench` 会按构建机
   CPU 调优；跨机型比较必须在同一机型重跑。

## 故障排查

| 现象 | 可能原因 | 处理 |
|---|---|---|
| build 退出 30，`dataset directory is missing` | 数据没有放到 `/home/runner/software/Ultrascan` | 解压 `ultrascan-data.zip`，把 13 个文件直接放入该目录 |
| build 退出 30，`size mismatch` / `CRC32 mismatch` / `SHA-256 mismatch` | 数据被截断、改写过或只放了一部分 | 重新解压/重新上传，保持 `benchmark/dataset-lock.json` 的大小和摘要 |
| build 退出 30，SQLite schema 不符 | 文件不是 hsbench corpus，或放错目录 | 确认 `chunk(id, stream_id, data)` 表存在 |
| test 退出 50，`Expression count` 不符 | 规则文件被替换，或 hsbench 版本不符 | 对照 `dataset-lock.json` 的 `expressions`，在目标架构重跑 |
| test 退出 50，`Corpus size` 不符 | 语料被替换，或 `--dataset-root` 指到旧目录 | 检查 `dataset-manifest.json` 与 `/home/runner/software/Ultrascan` |
| 样本超时 | `wanan_clone.db` + `-n 100` 在慢盘/慢 CPU 上超过 3600 s | 检查磁盘和 CPU，必要时仅在调试时降低 `-n`，正式结果不得改矩阵 |
| `-G` 报 invalid grey overrides | 使用了旧版/非 Ultrascan 的 hsbench | 用本用例构建的 5.8.0 `hsbench`，确认 `hs_set_grey_overrides` 存在 |

## 许可证

Ultrascan 及其 `hsbench`/`hsdump` 遵循上游仓库许可证；本用例只新增测试编排、数据校验和
结果解析代码。数据集由邮件提供，仅用于本仓库的性能评测，不随代码再分发。
