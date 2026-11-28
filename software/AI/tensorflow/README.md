# TensorFlow 2.20.0 ModelZoo Serving 性能测试

本用例在 openEuler 24.03 LTS SP3 aarch64 压测机上，用私有镜像
`benchmark-infer:v1.0.0` 起**一个**特权容器，在容器内用 Bazel 构建
`predictor_server`，再用镜像自带的 `brpc_client` 对 `din_mmoe` SavedModel 做
Serving 压测。实现按 `TensorFlow-benchmark-Modelzoo 2.0测试指导.pdf` 的流程，
但框架内只运行一个容器、一个 server；PDF 的 12 容器批量版需要另外的编排层。

容器规格：`0-15` CPU（16 vCPU 绑核）、`128g` 内存、`--privileged`、
`--network=host`；两个架构共用同一套脚本，压测机只跑 aarch64（镜像为私有
aarch64 镜像，x86_64 不具备复现条件）。

软件入口为 `tensorflow_test.sh`。Framework 六阶段（`prepare`/`build`/`start`/
`test`/`stop`/`finalize`）与独立入口调用**同一批**函数：
`scripts/builders/base.sh` 负责镜像、源码、资产和 Bazel 构建，
`scripts/stages/` 负责运行检查与正式压测，`scripts/results/` 负责解析 CSV。

调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建
阶段以 40 明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | BoostKit TensorFlow ModelZoo 2.20.0（`boostkit/tensorflow` 分支 `dev_2.20.0`） | 源码 ${PERF_WORK_DIR}/tensorflow，构建出 ${PERF_WORK_DIR}/tensorflow/bazel-bin/predictor_server |
| 容器基础镜像 | 私有归档 `benchmark-infer:v1.0.0`（openEuler + gcc-toolset-14 + Bazel 7.4.1 + Python 3.11 + brpc 客户端） | /home/runner/software/tensorflow/benchmark-infer.tar，校验 SHA-256 后 `docker load` |
| 压测客户端 | 镜像内 `/usr/local/bin/brpc_client`（随镜像分发，仓库内无独立归档） | 容器内，不额外安装 |
| 构建工具 | 镜像内 `bazel 7.4.1`、`/opt/openEuler/gcc-toolset-14/root/usr/bin/gcc` | 容器内，不额外安装 |
| SavedModel | `din_mmoe`（默认）、`bst_mmoe`、`wd_dcn` | /home/runner/software/tensorflow/tf_benchmark/，或从 tf_benchmark.tar.gz 解压 |
| 数据集 | `benchmark_dataset/din_mmoe.tsv`（1.8 GiB）等 | 同上 |
| 离线构建依赖 | Bazel distdir 67 个归档 + repository cache 172 条 | /home/runner/software/tensorflow/download/、bazel-repository-cache/ |

离线资产目录默认 `/home/runner/software/tensorflow`，可用 `--asset-dir` 或
`TF_ASSET_DIR` 覆盖：

```text
/home/runner/software/tensorflow/benchmark-infer.tar         # 14 GiB，镜像归档
/home/runner/software/tensorflow/tf_benchmark.tar.gz         # 20 GiB，模型与数据集
/home/runner/software/tensorflow/tf_benchmark/               # 已解压资产，优先复用
/home/runner/software/tensorflow/tensorflow/                 # 可选，源码（dev_2.20.0）
/home/runner/software/tensorflow/download/                   # Bazel distdir
/home/runner/software/tensorflow/bazel-repository-cache/     # 预热的 Bazel 仓库缓存
```

仓库外用 `Software/tensorflow/` 存档同一批小体积依赖（distdir、repository
cache、源码树），大体积的两个归档只在压测机就位。

## TensorFlow 获取、构建与容器启动

**获取顺序**：公共离线目录 `/home/runner/software/tensorflow/` → 本任务缓存
`${PERF_WORK_DIR}/` → 官网/代码托管站下载。三段都存在时优先用离线目录，只有
缺失时才联网。

| 资产 | 离线路径 | 校验值 | 来源 |
|---|---|---|---|
| 镜像归档 | /home/runner/software/tensorflow/benchmark-infer.tar | 运行时 `sha256sum` 写入 `image.sha256`，并记入 `benchmark_tensorflow.json` 的 `parameters.image_sha256` | 私有归档 |
| 模型与数据集 | /home/runner/software/tensorflow/tf_benchmark.tar.gz | 运行时 `sha256sum` 写入 `assets.sha256` → `parameters.assets_sha256` | 私有归档 |
| 源码 | /home/runner/software/tensorflow/tensorflow/ 或 gitcode 克隆 | `git rev-parse HEAD` 写入 `source-commit.txt` → `parameters.source_commit` | gitcode.com/boostkit/tensorflow，分支 dev_2.20.0 |
| Bazel distdir | /home/runner/software/tensorflow/download/ | 由 Bazel 按 `http_archive` 里的 sha256 校验 | 随存档分发 |
| Bazel repository cache | /home/runner/software/tensorflow/bazel-repository-cache/ | 目录名即 sha256（`content_addressable/sha256/<sha>/file`） | 随存档分发 |

以下是实际命令形态（`${...}` 为上面表格里的取值来源）。

1. 加载镜像。已 `docker load` 过则直接复用，否则从归档加载：

   ```bash
   docker image inspect benchmark-infer:v1.0.0 >/dev/null 2>&1 \
     || docker load --input /home/runner/software/tensorflow/benchmark-infer.tar
   sha256sum /home/runner/software/tensorflow/benchmark-infer.tar > ${PERF_WORK_DIR}/image.sha256
   ```

2. 准备源码。有离线源码就复制（`--reflink=auto` 走写时复制），否则克隆；
   复制后必须存在 `tools/run_serving_benchmark.sh`：

   ```bash
   cp -a --reflink=auto /home/runner/software/tensorflow/tensorflow ${PERF_WORK_DIR}/tensorflow
   # 或：git clone --depth 1 --branch dev_2.20.0 \
   #       https://gitcode.com/boostkit/tensorflow.git ${PERF_WORK_DIR}/tensorflow
   git -C ${PERF_WORK_DIR}/tensorflow rev-parse HEAD > ${PERF_WORK_DIR}/source-commit.txt
   ```

3. 准备模型与数据集。已解压则复用，否则解包 20 GiB 归档：

   ```bash
   tar -xzf /home/runner/software/tensorflow/tf_benchmark.tar.gz -C ${PERF_WORK_DIR}/assets
   test -f ${TF_ASSET_ROOT}/din_mmoe/1/saved_model.pb
   test -f ${TF_ASSET_ROOT}/benchmark_dataset/din_mmoe.tsv
   ```

4. 预热 Bazel 仓库缓存。资产目录只读挂载，缓存复制到工作目录后再交给 Bazel：

   ```bash
   cp -a /home/runner/software/tensorflow/bazel-repository-cache \
         ${PERF_WORK_DIR}/bazel-repository-cache
   ```

5. 创建容器。按测试指导使用单容器、特权模式、`0-15` 绑核、128g 内存；容器以
   Runner 的 UID/GID 运行，`/etc/passwd`、`/etc/group` 只读挂载，让容器内的
   Bazel 能解析用户名并把产物写成 Runner 用户：

   ```bash
   docker run --detach --name "boostkit-tensorflow-aarch64-${PERF_RUN_ID}" \
     --label "boostkit.tensorflow.run-id=${PERF_RUN_ID}" \
     --network=host --privileged --user "$(id -u):$(id -g)" \
     --cpuset-cpus=0-15 --memory=128g \
     --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
     --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
     --mount "type=bind,source=/home/runner/software/tensorflow,target=/home/runner/software/tensorflow,readonly" \
     --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
     --mount type=bind,source=/etc/group,target=/etc/group,readonly \
     benchmark-infer:v1.0.0 sleep infinity
   ```

6. 容器内构建 `predictor_server`。`--action_env=LD_LIBRARY_PATH` 必须保留
   `/opt/openEuler/gcc-toolset-14/root/usr/lib64`，否则 `as` 找不到
   `libopcodes-2.42.so`；TF 2.20 的 `.bazelrc` 固定 `common --noenable_bzlmod`，
   强行开启 bzlmod 会让 `@com_google_protobuf` 同时解析出 27 和 33 两个版本，
   生成的 `duration.pb.h` 与运行时头文件不匹配：

   ```bash
   docker exec -e HOME=${PERF_WORK_DIR}/home -e TMPDIR=${PERF_WORK_DIR}/tmp \
     boostkit-tensorflow-aarch64-${PERF_RUN_ID} sh -c '
       cd '"${PERF_WORK_DIR}"'/tensorflow &&
       bazel --output_user_root=./output build \
         --noenable_bzlmod \
         --repository_cache='"${PERF_WORK_DIR}"'/bazel-repository-cache \
         --cxxopt=-std=c++17 --host_cxxopt=-std=c++17 \
         --copt=-O3 --host_copt=-O3 --copt=-march=armv8.5-a \
         --host_copt=-I/usr/local/include --linkopt=-L/usr/local/lib64 \
         --linkopt=-Wl,-rpath,/usr/local/lib64 \
         --action_env=LD_LIBRARY_PATH=/usr/local/lib64:/opt/openEuler/gcc-toolset-14/root/usr/lib64 \
         --action_env=TF_SYSTEM_LIBS=boringssl,snappy \
         --distdir=/home/runner/software/tensorflow/download \
         --copt=-w --host_copt=-w //:predictor_server'
   test -x ${PERF_WORK_DIR}/tensorflow/bazel-bin/predictor_server
   ```

   构建产物约 240 MiB，5297 个动作；容器 `0-15` 绑核（16 vCPU）下约 35 分钟。

7. 容器内准备：本用例不需要 `dnf` 装包，也不需要改镜像源——Bazel、gcc-toolset-14、
   Python 3.11、brpc 客户端都在镜像内。宿主机只负责 `docker`、`git`、`curl`、
   `tar`、`sha256sum`、`python3` 六个命令（缺失时构建阶段以 30 失败），
   **不向宿主机安装运行时、不修改系统配置**。

- **脚本出处**：`scripts/builders/base.sh`、`scripts/builders/dispatch.sh`

## 数据与运行顺序

1. 前置检查。宿主：`docker info` 可用、六个命令齐全、`/home` 至少留 120 GiB
   （源码 0.5 GiB + Bazel 输出约 40 GiB + 解压资产 25 GiB + 结果）。内存：容器限
   128g，工作集约 60 GiB。
2. 构建阶段（`build`）：执行上一节的步骤 1–7，写出
   `${PERF_ACTUAL_VERSION_FILE}`（内容 `2.20.0`）和 `build_variant.json`。
3. 启动阶段（`start`）：确认容器在跑、标签属于本任务、`predictor_server`、
   `brpc_client`、`din_mmoe/1/saved_model.pb`、`benchmark_dataset/din_mmoe.tsv`
   都存在；缺任一项以 40 失败。
4. 预热 + 正式测量（`test`）：重复 5 次（`TF_REPEAT`），每次重复都重新启动
   server，先 5 秒 warmup 再 30 秒计时，结果写
   `${RESULTS_DIR}/tensorflow-benchmark/rep-<n>/`：

   ```bash
   docker exec -e HOME=${PERF_WORK_DIR}/home \
     boostkit-tensorflow-aarch64-${PERF_RUN_ID} sh -c '
       cd '"${PERF_WORK_DIR}"'/tensorflow &&
       MODEL_NAME=din_mmoe \
       MODEL='"${TF_ASSET_ROOT}"'/din_mmoe/1 \
       DATA='"${TF_ASSET_ROOT}"'/benchmark_dataset/din_mmoe.tsv \
       OUT_DIR='"${RESULTS_DIR}"'/tensorflow-benchmark/rep-1 \
       PORT=8890 THREAD_NUM=16 CLIENT_THREAD_NUM=1 \
       WARMUP=5 DURATION=30 QPS_LIST=565 RUN_MODES=baseline \
       MAX_INFLIGHT=100 REQUEST_MIN_BATCH_SIZE=1 REQUEST_MAX_BATCH_SIZE=100 \
       TF_NUM_INTEROP_THREADS=16 TF_NUM_INTRAOP_THREADS=16 \
       BIN_SERVER='"${PERF_WORK_DIR}"'/tensorflow/bazel-bin/predictor_server \
       BIN_CLIENT=/usr/local/bin/brpc_client SERVER_STARTUP_TIMEOUT=600 \
       sh tools/run_serving_benchmark.sh'
   ```

5. 清理（`stop`）：只按 `boostkit.tensorflow.run-id` 标签删除本次容器，不执行
   `docker prune`；容器日志先落到 `${RESULTS_DIR}/container_runtime.log`。
6. 校验（`finalize`）：解析器必须产出 8 项指标；缺 CSV、缺样本、数值非正都直接
   失败，不补零、不降级。

参数矩阵（两个架构共用同一矩阵；本用例只在 aarch64 上执行）：

| 档位 | Run mode | 目标 QPS | 预热 | 计时 | 重复 | 预计耗时 |
|---|---|---|---|---|---|---|
| 默认 | `baseline` | 565 | 5 s | 30 s | 5 | 约 7 分钟（含 5 次 server 启动） |
| 可扩展 | `baseline dnn opt` | `TF_QPS_LIST` 列表 | 5 s | 30 s | 5 | 每增加一个 mode × QPS 约 +35 秒 |

`TF_MODEL`、`TF_QPS_LIST`、`TF_RUN_MODES`、`TF_WARMUP`、`TF_DURATION`、
`TF_REPEAT` 都可通过环境变量覆盖；磁盘与内存前置检查在 `start` 阶段之前由脚本
自行失败退出，不会静默降级。

- **脚本出处**：`scripts/stages/start.sh`、`scripts/stages/test.sh`、`scripts/stages/stop.sh`

## 指标与产物

每个 `mode × target_qps` 行产生 8 项指标，取 5 次重复的**中位数**；单档位
（`baseline` @ 565）时指标总数为 8 项，按模型 `din_mmoe` 分组、运行模式
`baseline` 作为子组。

| 报告分组 | 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|---|
| `din_mmoe/baseline/qps=565` | `actual_qps` | `results.csv` 的 `actual_qps` 列 | queries/s | 越大越好 |
| 同上 | `total_requests` | `results.csv` 的 `total` 列 | requests | 中性 |
| 同上 | `success` | `results.csv` 的 `success` 列 | requests | 越大越好 |
| 同上 | `failure` | `results.csv` 的 `failure` 列 | requests | 越小越好 |
| 同上 | `dropped` | `results.csv` 无 `dropped` 列时按 `max(total-success-failure,0)` 推导，有该列则直接用 | requests | 越小越好 |
| 同上 | `p99_latency_us` | `results.csv` 的 `p99_latency_us` 列 | us | 越小越好 |
| 同上 | `server_cpu_pct_avg` | `results.csv` 的 `server_cpu_pct_avg` 列（`/proc/<pid>/stat` 采样） | % | 越小越好 |
| 同上 | `server_cpu_cores_avg` | `results.csv` 的 `server_cpu_cores_avg` 列（CPU% / 配额核数） | cores | 越小越好 |

采样与解析规则：`TF_REPEAT=5` 次独立重复，每次重复独立 warmup（5 s）+ 计时
（30 s），原始输出为 `${RESULTS_DIR}/tensorflow-benchmark/rep-<n>/results.csv`；
指标名形如 `din_mmoe/baseline/qps=565/actual_qps`。解析器只读官方
`results.csv`，`value` 写中位数，`sample_values` 保留 5 个原始值，`samples` 记录
样本数，`statistic` 写 `median`；解析失败（缺 CSV、缺样本、`actual_qps<=0`、
`p99<=0`、负值、表头不符）一律以非零退出，绝不补零。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 5 次重复的完整控制台输出（`tee` 累积） |
| `tensorflow-benchmark/results.csv` | 全部重复的汇总 CSV，首列 `rep` |
| `tensorflow-benchmark/rep-<n>/` | 第 n 次重复的 `results.csv`、`results.md`、server/client 日志、CPU 采样 |
| `tensorflow-benchmark/metadata.txt` | 模型、数据、线程、QPS、镜像等元信息 |
| `benchmark_tensorflow.json` | Framework 归一化指标、参数、`summary` 与 `runtime_context` |
| `build_variant.json` | 构建类型（`base`） |
| `container_runtime.log` | 容器日志快照（停止阶段采集） |
| `results.json` / `report.md` | 独立入口生成的最终状态与 Markdown 报告 |

## 独立运行

```bash
bash software/AI/tensorflow/tensorflow_test.sh \
  --version 2.20.0 \
  --variant base \
  --asset-dir /home/runner/software/tensorflow \
  --results-dir /home/runner/tensorflow-results/2.20.0
```

内部实际执行的就是上一节步骤 1–6：`docker run … sleep infinity` 建容器 →
`docker exec … bazel … //:predictor_server` 构建 → `docker exec … sh
tools/run_serving_benchmark.sh` 跑 5 次 → `python3
scripts/results/parse_benchmark.py <out>/tensorflow-benchmark …` 解析 →
`docker stop/rm` 删除本次容器。独立入口默认清理
`${PERF_WORK_DIR}`（路径必须是 `/home/runner/boostkit-perf/tensorflow/local-*`，
否则拒绝清理）；需要保留现场时加 `--keep-workdir`。`--variant optimized`
会在构建阶段以 40 失败，不回落基础版，也不写基线。

## 已知限制

- **只有 aarch64**：`benchmark-infer:v1.0.0` 是私有 aarch64 镜像，x86_64 机器
  无法复现；框架里 `--architecture x86_64` 会因缺少镜像归档在构建阶段失败。
- **离线约束**：压测机只能稳定访问 `gitcode.com` 与 `storage.googleapis.com`，
  `github.com`、`files.pythonhosted.org`、`dl.google.com` 的 DNS/连接经常失败。
  因此 Bazel 依赖必须由 `download/`（distdir）和 `bazel-repository-cache/` 提供，
  两者都缺失时构建会尝试联网并失败。源码仍可从 gitcode 克隆。
- **单容器**：PDF 的 12 容器批量口径没有实现，本用例的指标是单容器单 server；
  不能把单容器数值当作 12 容器批量结果。
- **特权与绑核**：按测试指导保留 `--privileged`、`--cpuset-cpus=0-15`、
  `--memory=128g`，与框架里“不绑核、不限制 CPU/内存”的用例不同；`server_cpu_*`
  指标以 16 vCPU 配额归一化。
- **`optimized` 未实现**：`scripts/builders/optimized.sh` 直接返回 40。
- **构建耗时**：全量 Bazel 构建约 35 分钟，`timeout_minutes` 设 1440，给资产
  解包和 5 次压测留足余量。
