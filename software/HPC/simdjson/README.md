# simdjson 4.6.11 性能测试

本用例在 x86_64、aarch64 上分别构建上游原版 simdjson 4.6.11 的官方 JSON 解析基准：
DOM 命令行工具 `parse`、`parse_stream`，以及 Google Benchmark 套件 `bench_parse_call`、
`bench_dom_api`、`bench_ondemand`。构建与测量都在本次任务专属的 openEuler 24.03 LTS SP4
私有容器内执行；容器使用宿主网络，**不限制 CPU、内存或 NUMA**，测量进程也不绑核。

Framework 根据 `case.yaml` 依次调用构建、启动校验、测试和停止函数；软件入口为
`simdjson_test.sh`，独立入口调用同一组阶段函数。基础版 `base` 按上游默认 Release 口径构建；
`optimized` 变体尚未实现——上游 v4.6.11 只有 NEON 内核、没有 SVE/SVE2 内核，选择该变体时
构建阶段明确失败（`return 30`），不退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| simdjson | 上游原版 tag `v4.6.11`，官方归档 `simdjson-v4.6.11.tar.gz`，6,709,400 字节，SHA-256 `61d948fc24f0d793829ad658058e7597d064988a89b4607ea02e401a82df98ff`；不打补丁 | 公共离线目录 `/home/runner/software/simdjson/`；容器内解压到 `${PERF_WORK_DIR}/simdjson-4.6.11` |
| Google Benchmark | 上游 tag `v1.9.5` 源码归档 `benchmark-v1.9.5.zip`，347,679 字节，SHA-256 `68c9c65cee4864db42c3af9ff5b5cfa32ce1b01d9653136c5f4ff96e18a9b8f2`；只用于三个 `bench_*` 套件 | 同一离线目录；容器内解压到 `${PERF_WORK_DIR}/deps/benchmark-1.9.5` |
| 官方测试语料 simdjson-data | 固定 commit `351949906abde446f0314bf79606fb5d884f5be7` 归档 `simdjson-data-3519499.zip`，7,188,926 字节，SHA-256 `a2623f4cbe5ee988c00ff26549dd0e7738b25938fd4d6e5f1f7d10faf748a884` | 同一离线目录；解压到 `${PERF_WORK_DIR}/deps/simdjson-data-3519499`，其 `jsonexamples/` 作为 `SIMDJSON_BENCHMARK_DATA_DIR` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/)，按架构取 `openEuler-docker.<arch>.tar.xz`，同目录 `.sha256sum` 校验 | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |
| 容器内构建依赖 | `cmake`(≥3.14)、`gcc`、`gcc-c++`、`make`、`unzip`、`tar`、`python3`、`findutils`、`curl` | 全部在容器内用 `dnf` 安装，不向宿主机安装 |

三份归档在 x86_64 与 aarch64 上完全相同，因此校验值表只有一组；基础镜像按架构各自取归档。

## simdjson 获取、构建与容器启动

脚本先确认 Docker daemon 可用（`docker info` 失败时构建阶段返回 30，并提示先启动 daemon）。
基础镜像归档 `openEuler-docker.<arch>.tar.xz` 与同名 `.sha256sum` 优先取上表的公共目录，
缺失时才从官方地址下载；校验后 `docker load`，再核对镜像架构与容器内发行版：

```bash
ARCH="$(uname -m)"                                  # x86_64 / aarch64
IMAGE_DIR="/home/runner/software/openEuler-24.03-LTS-SP4"
ARCHIVE="${IMAGE_DIR}/openEuler-docker.${ARCH}.tar.xz"
if [ ! -s "${ARCHIVE}" ]; then
  ARCHIVE="${PERF_WORK_DIR}/openEuler-docker.${ARCH}.tar.xz"
  curl -fSL --retry 3 --connect-timeout 30 -o "${ARCHIVE}.part" \
    "https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${ARCH}/openEuler-docker.${ARCH}.tar.xz"
  curl -fSL --retry 3 --connect-timeout 30 -o "${ARCHIVE}.sha256sum" \
    "https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${ARCH}/openEuler-docker.${ARCH}.tar.xz.sha256sum"
  mv "${ARCHIVE}.part" "${ARCHIVE}"
fi
( cd "$(dirname "${ARCHIVE}")" && sha256sum -c "$(basename "${ARCHIVE}").sha256sum" )
docker load -i "${ARCHIVE}"
docker run --rm --network=none "${SIMDJSON_CONTAINER_IMAGE}" cat /etc/os-release
```

`/etc/os-release` 的 `VERSION_ID` 必须是 `24.03`，镜像架构必须是 `x86_64`→`amd64`、
`aarch64`→`arm64`；本用例不访问 Docker Hub。

每次构建使用容器 `boostkit-simdjson-<架构>-<运行 ID>`，以 Runner 的 UID/GID 运行，
把工作目录、结果目录按原路径挂载进去，用例目录按只读方式挂载：

```bash
docker run --detach --name "${SIMDJSON_CONTAINER_NAME}" \
  --label "boostkit.simdjson.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${SIMDJSON_CONTAINER_IMAGE}" sleep infinity
```

容器内先安装依赖；正式工作流设置 `PERF_PROXY` 时，还会把 `/home/runner/software/anchors/`
只读挂到 `/etc/pki/ca-trust/source/anchors/`，在容器内执行 `update-ca-trust extract`，
再把 openEuler 仓库地址改为 `repo.huaweicloud.com/openeuler`。未设置代理时不挂载证书、
不改仓库地址：

```bash
dnf install -y --setopt=install_weak_deps=False \
  cmake gcc gcc-c++ make unzip tar python3 findutils curl
```

源码与语料按「公共离线目录 → 本次工作目录 → 官方地址」的顺序获取，三份文件都强制校验
SHA-256；离线目录缺失且下载不可用时构建阶段返回 30，不会跳过校验继续构建：

```bash
OFFLINE="/home/runner/software/simdjson"
mkdir -p "${PERF_WORK_DIR}/downloads" "${PERF_WORK_DIR}/deps"
for name in simdjson-v4.6.11.tar.gz benchmark-v1.9.5.zip simdjson-data-3519499.zip; do
  if [ -s "${OFFLINE}/${name}" ]; then
    cp -f "${OFFLINE}/${name}" "${PERF_WORK_DIR}/downloads/${name}"
  else
    case "${name}" in
      simdjson-v4.6.11.tar.gz) url="https://codeload.github.com/simdjson/simdjson/tar.gz/refs/tags/v4.6.11" ;;
      benchmark-v1.9.5.zip)    url="https://codeload.github.com/google/benchmark/zip/refs/tags/v1.9.5" ;;
      *)                       url="https://codeload.github.com/simdjson/simdjson-data/zip/351949906abde446f0314bf79606fb5d884f5be7" ;;
    esac
    curl -fSL --retry 3 --connect-timeout 30 -o "${PERF_WORK_DIR}/downloads/${name}.part" "${url}"
    mv "${PERF_WORK_DIR}/downloads/${name}.part" "${PERF_WORK_DIR}/downloads/${name}"
  fi
done
( cd "${PERF_WORK_DIR}/downloads" && sha256sum -c sha256sums.txt )
tar xzf "${PERF_WORK_DIR}/downloads/simdjson-v4.6.11.tar.gz" -C "${PERF_WORK_DIR}"
unzip -q "${PERF_WORK_DIR}/downloads/benchmark-v1.9.5.zip" -d "${PERF_WORK_DIR}/deps"
unzip -q "${PERF_WORK_DIR}/downloads/simdjson-data-3519499.zip" -d "${PERF_WORK_DIR}/deps"
```

构建使用一个只做「按上游目标编译官方 `benchmark/*.cpp`」的 CMake 工程：库本体仍由 simdjson
自己的 `CMakeLists.txt`（`SIMDJSON_DEVELOPER_MODE=OFF`）构建，官方 benchmark 源文件由
`scripts/benchmarks/CMakeLists.txt` 生成同名的五个可执行文件，编译选项与上游开发者模式一致
（`Release`、`-std=c++17`、`-pthread`）。唯一额外选项是 `-ffp-contract=off`：基准套件用
「精确 double 相等」比对自己与 DOM 参考实现累加的 `rating * reviews`，aarch64 的 FMA 是基线
指令，GCC 会把该累加合并成 fused multiply-add，使两条实现的舍入结果不同，上游便报
`result incorrect`（x86_64 基线没有 FMA，所以本地不出现）。这个累加只用于结果校验，禁用合并
让两个平台逐位一致，不修改解析代码，也不改变上游 `-O3` 设置。这样 configure 阶段不需要联网
下载 CPM、Google Benchmark 或语料，完全不改动 simdjson 源码：

```bash
cmake -S "${SCRIPT_DIR}/scripts/benchmarks" -B "${PERF_WORK_DIR}/build" \
  -DCMAKE_BUILD_TYPE=Release \
  -DSIMDJSON_SRC="${PERF_WORK_DIR}/simdjson-4.6.11" \
  -DGOOGLE_BENCHMARK_SRC="${PERF_WORK_DIR}/deps/benchmark-1.9.5" \
  -DSIMDJSON_DATA_DIR="${PERF_WORK_DIR}/deps/simdjson-data-3519499/jsonexamples"
cmake --build "${PERF_WORK_DIR}/build" -j "$(nproc)" \
  --target parse parse_stream bench_parse_call bench_dom_api bench_ondemand
```

构建后核对五个可执行文件存在、`libsimdjson.a` 已生成，并用最小迭代做冒烟解析；冒烟要求
`parse` 返回 0 且输出行包含三个正的 GB/s 值，否则构建阶段失败、不进入测量：

```bash
"${PERF_WORK_DIR}/build/parse" -n 10 -t \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/twitter.json"
```

构建完成后把实际版本（`include/simdjson/simdjson_version.h` 中 `SIMDJSON_VERSION` 的 4.6.11、
编译器标识）、三份归档的 SHA-256、五个二进制的 SHA-256、容器镜像名写入 `build_variant.json`，
并保留同一个容器供测试阶段复用。**宿主机只做下载、SHA-256 校验、Docker 调用和结果解析**；不向宿主机安装任何
软件包，也不修改宿主机的镜像源、信任库或系统配置。受限网络下可用
`SIMDJSON_DOCKER_EXTRA_ARGS` 追加 `docker run` 参数（例如 `--add-host` 指定内网镜像地址）；
Blue 的 aarch64 Runner 使用默认镜像源，不需要该变量。

- **脚本出处**：`scripts/common.sh`、`scripts/builders/dispatch.sh`、`scripts/builders/base.sh`、
  `scripts/builders/optimized.sh`、`scripts/stages/start.sh`、`scripts/benchmarks/CMakeLists.txt`。

## 数据与运行顺序

测试数据全部来自两份已校验归档：DOM 工具读取源码树内 `jsonexamples/`（与 simdjson-data
中同名文件逐字节一致），三个 Google Benchmark 套件读取 simdjson-data 的 `jsonexamples/`
（`gsoc-2018.json`、`numbers.json` 等只存在于该语料包）。不需要额外数据集，也不写 `$HOME`。

执行顺序固定为：

1. **启动校验**：确认容器仍在运行、`boostkit.simdjson.run-id` 标签与本次运行 ID 一致，五个
   二进制与语料文件都可读，工作目录剩余空间足够。
2. **预热 1 次**：在容器内按下面的命令形态各执行一遍，输出落到 `runs/<scenario>/rep0.log`，
   只记录、不参与统计。
3. **正式采样 5 次**：同样 5 个进程，每次都是独立进程；每个进程的标准输出落到
   `runs/<scenario>/rep<i>.log`、标准错误落到 `runs/<scenario>/rep<i>.err`（DOM 工具的进度条
   和 `parse_stream` 的摘要行在标准错误，只有标准输出的数据行参与解析），解析后再为每轮写出
   `runs/<scenario>/rep<i>.json`（`i` 从 1 开始）。
4. **严格解析**：宿主机执行 `scripts/results/parse_benchmark.py`，生成 66 项指标与中位数。
5. **清理**：停止阶段按 `boostkit.simdjson.run-id` 标签移除本次容器，保留结果目录；
   `--keep-workdir` 时保留工作目录。

每次采样都在容器内按下面的固定命令形态各执行一遍：

```bash
"${PERF_WORK_DIR}/build/parse" -n 1000 -t \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/twitter.json" \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/citm_catalog.json"
"${PERF_WORK_DIR}/build/parse_stream" \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/amazon_cellphones.ndjson"
"${PERF_WORK_DIR}/build/bench_parse_call" \
  --benchmark_min_time="${SIMDJSON_BENCH_MIN_TIME}" \
  --benchmark_out="${RESULTS_DIR}/runs/bench_parse_call/rep${i}.json" --benchmark_out_format=json
"${PERF_WORK_DIR}/build/bench_dom_api" \
  --benchmark_min_time="${SIMDJSON_BENCH_MIN_TIME}" \
  --benchmark_out="${RESULTS_DIR}/runs/bench_dom_api/rep${i}.json" --benchmark_out_format=json
"${PERF_WORK_DIR}/build/bench_ondemand" \
  --benchmark_min_time="${SIMDJSON_BENCH_MIN_TIME}" \
  --benchmark_out="${RESULTS_DIR}/runs/bench_ondemand/rep${i}.json" --benchmark_out_format=json
```

| # | 场景组 | 工具 / 套件 | 语料 | 参数 | 每轮参考耗时 |
|---|---|---|---|---|---|
| 1 | `dom_parse` | `benchmark/dom/parse` | `twitter.json`、`citm_catalog.json` | `-n 1000 -t` | < 3 s |
| 2 | `dom_parse_stream` | `benchmark/dom/parse_stream` | `amazon_cellphones.ndjson` | 上游默认（100 档 batch，每档 5 次） | 5 – 10 s |
| 3 | `bench_parse_call` | Google Benchmark | `twitter.json`、`gsoc-2018.json` | `--benchmark_min_time=1s` | 30 – 45 s |
| 4 | `bench_dom_api` | Google Benchmark | `twitter.json`、`numbers.json` | `--benchmark_min_time=1s` | 20 – 30 s |
| 5 | `bench_ondemand` | Google Benchmark | `twitter.json`、`amazon_cellphones.ndjson` 等 | `--benchmark_min_time=1s` | 25 – 40 s |

两个架构使用**同一矩阵**、同一语料、同一参数，只有架构和运行位置不同。预热轮次不参与统计，
但同样落盘（`rep0`）。`SIMDJSON_BENCH_MIN_TIME` 默认 `1s`，可整体覆盖；`PERF_REPS` 默认 5，
必须 ≥5。工作目录约 200 MB（源码 29 MB、语料 27 MB、依赖与构建产物），结果目录按
「每组每轮一个日志 + 一个 JSON」估算不足 5 MB；磁盘不足时构建阶段先报错，不进入测量。

测量完成后由宿主机执行严格解析，不重新测量、不补零：

```bash
python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
  --runs-dir "${RESULTS_DIR}/runs" \
  --results-dir "${RESULTS_DIR}" \
  --version "${SOFTWARE_VERSION}" \
  --architecture "$(uname -m)" \
  --variant "${PERF_VARIANT}" \
  --run-id "${PERF_RUN_ID}" \
  --warmups "${SIMDJSON_WARMUPS}" --reps "${PERF_REPS}"
```

停止阶段只移除带本次运行标签的容器；容器名与标签绑定运行 ID，因此 `stop` 幂等、可安全重跑。

## 指标与产物

| 报告分组 | 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|---|
| `dom_parse` | `dom_parse_twitter_gb_per_s`、`dom_parse_twitter_stage1_gb_per_s`、`dom_parse_citm_catalog_gb_per_s`、`dom_parse_citm_catalog_stage1_gb_per_s` | `parse -t` 每行最后三个数值中的「全阶段 GB/s」与「Stage 1 GB/s」 | GB/s | 越大越好 |
| `dom_parse_stream` | `dom_parse_stream_amazon_cellphones_gb_per_s` | `parse_stream` 标准错误里的 `Best speed: <值>...` 行（100 档 batch 的最优值） | GB/s | 越大越好 |
| `bench_parse_call` | `bench_parse_call_<行名>_ns`（9 项） | `--benchmark_out` JSON 中该行 `cpu_time`（10 次内层重复的 `median` 聚合；无聚合时取迭代行） | ns | 越小越好 |
| `bench_dom_api` | `bench_dom_api_<行名>_ns`（24 项） | 同上 | ns | 越小越好 |
| `bench_ondemand` | `bench_ondemand_<行名>_ns`（28 项） | 同上 | ns | 越小越好 |

指标总数 **66 项**：`dom_parse` 4 项 + `dom_parse_stream` 1 项 + `bench_parse_call` 9 项 +
`bench_dom_api` 24 项 + `bench_ondemand` 28 项。分组规则：DOM 两个工具按工具名分组，三个
Google Benchmark 套件按套件名分组；行名去掉 Google Benchmark 的 `/repeats:10`、`/manual_time`
等后缀，再把空格与 `/:<>()` 等字符归一化为 `_`（例如 `amazon_cellphones<simdjson_ondemand<THREADED>>`
→ `bench_ondemand_amazon_cellphones_simdjson_ondemand_THREADED_ns`）。基准行清单在
`fixtures/benchmarks.json` 中固定，少一行或重复一行都判失败，不会静默丢弃。

每项指标取 5 次采样（每次采样是独立进程）的中位数写入结果，全部 6 个样本（含预热）保留在
`runs/` 下，供复核与后续统计。`dom_parse_stream` 的「最优 batch 档位」只作为 evidence 记录，
不参与跨架构配对。

| 产物 | 内容 |
|---|---|
| `build_variant.json` | 构建变体、三份归档的 SHA-256、五个二进制 SHA-256、编译器、容器镜像 |
| `raw-output.log` | 两个 DOM 工具与三个套件全部轮次的原始输出汇总（按场景与轮次分段） |
| `benchmark_google.json` | 三个 Google Benchmark 套件的合并原始 JSON（逐轮追加，不覆盖） |
| `benchmark_simdjson.json` | 66 项指标、采样数、中位数与原始值；`case.yaml` 的 `metrics.source` |
| `runs/<scenario>/rep<i>.log`、`rep<i>.err`、`rep<i>.json` | 每次采样的标准输出、标准错误与解析后的样本，不覆盖、不丢弃 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

解析严格性：缺样本、多样本、同一指标出现两次、数值不是有限正数、DOM 行缺少 GB/s 列、
Google Benchmark JSON 缺少 `benchmark` 行或 `cpu_time` 非正，任一情况都让测试失败；解析器
绝不补零、不降级，失败时保留全部原始输出以便定位。

## 独立运行

在已安装 Docker、且具备离线目录或网络代理的 Runner 上，从仓库根目录执行：

```bash
bash software/HPC/simdjson/simdjson_test.sh \
  --version 4.6.11 \
  --variant base \
  --results-dir /home/runner/simdjson-results/4.6.11
```

内部实际执行的命令展开如下（与 Framework 六阶段完全一致，只是路径来自参数）：

```bash
docker run --detach --name "${SIMDJSON_CONTAINER_NAME}" \
  --label "boostkit.simdjson.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  "${SIMDJSON_CONTAINER_IMAGE}" sleep infinity
docker exec "${SIMDJSON_CONTAINER_NAME}" dnf install -y --setopt=install_weak_deps=False \
  cmake gcc gcc-c++ make unzip tar python3 findutils coreutils which diffutils gzip
docker exec "${SIMDJSON_CONTAINER_NAME}" cmake "\${PERF_WORK_DIR}/build" ...   # 见「获取、构建与容器启动」
docker exec "${SIMDJSON_CONTAINER_NAME}" "${PERF_WORK_DIR}/build/parse" -n 1000 -t \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/twitter.json" \
  "${PERF_WORK_DIR}/simdjson-4.6.11/jsonexamples/citm_catalog.json"
python3 software/HPC/simdjson/scripts/results/parse_benchmark.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --version 4.6.11 --architecture "$(uname -m)" --variant base --run-id "${PERF_RUN_ID}"
docker rm -f "${SIMDJSON_CONTAINER_NAME}"
```

入口同样支持 `--keep-workdir` 保留本次私有目录以便排查；`optimized` 变体会在构建阶段
明确失败，不会生成任何「优化版」结果。

- **脚本出处**：`simdjson_test.sh`、`scripts/results/standalone_runtime.py`。

## 已知限制

- **`optimized` 未实现**：上游 v4.6.11 只有 NEON/AVX 等内核，没有 SVE/SVE2 内核；要得到
  SVE2 口径需要应用 boostkit 的 `kunpeng_opti_sve2.patch`（基于上游 `c2f25ab`）。本用例只
  适配上游原版，选择 `optimized` 时构建阶段 `return 30` 并说明原因，不退回基础版。
- **不绑核、不设配额**：与仓库 `jemalloc`、`libavif` 用例一致（`boostkit` 参考材料用
  `numactl -C <cpu>` 绑定单核）。因此本用例的绝对值不能与参考材料中的数字直接比较；
  跨架构只配对同名同参数的指标。
- **构建路径与上游开发者模式的差异**：官方 `SIMDJSON_DEVELOPER_MODE=ON` 会在 configure
  阶段用 CPM 从 GitHub 下载 CPM 脚本、Google Benchmark 与语料。本用例把这一步换成离线
  等价的 CMake 工程（同一批官方源文件、同一 Release 编译选项、同一数据目录），
  **未修改 simdjson 源码**；`scripts/benchmarks/CMakeLists.txt` 只负责生成同名的五个
  可执行文件。
- **`bench_stream_formats` 不在上游 v4.6.11**：`boostkit` 安装指南列出的该目标在本版本
  不存在，因此不纳入；流式解析能力由 DOM `parse_stream` 覆盖。
- **测量时长参数**：参考材料用 `--benchmark_min_time=3s`，本用例默认 `1s`（外层还有 1 次
  预热 + 5 次采样），可用 `SIMDJSON_BENCH_MIN_TIME` 覆盖为 3s 复现参考口径。
- **语料来源**：`twitter.json`、`citm_catalog.json`、`amazon_cellphones.ndjson` 在源码树与
  simdjson-data 中逐字节一致；`gsoc-2018.json`、`numbers.json` 等只来自固定 commit 的
  simdjson-data 归档。
- **容器内无 `perf` 事件权限时**，`parse -t` 只输出 3 个 GB/s 列（不输出周期/指令列）；
  解析器同时兼容有/无事件两种列宽，指标口径不变。
- **aarch64 的结果校验差异**：`bench_ondemand` 的 `amazon_cellphones` 行会用精确 double
  相等比对 ondemand 与 DOM 参考实现累加的品牌评分。aarch64 的 FMA 是基线指令，GCC 会合并
  该累加导致两条实现舍入不同、上游报 `result incorrect`（首次 aarch64 运行失败即此原因）。
  用例在 harness 中加 `-ffp-contract=off` 消除该差异；解析器的严格性不变——任何
  `error_occurred` 行仍然让 test 阶段 `return 50`。
