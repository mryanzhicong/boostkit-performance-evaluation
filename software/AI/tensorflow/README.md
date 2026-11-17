# TensorFlow ModelZoo 2.0 Serving 性能测试

本用例加载私有 `benchmark-infer:v1.0.0` 镜像，构建 `predictor_server`，对
`din_mmoe` SavedModel 执行一轮 Serving 压测。测试数据来自 `tf_benchmark.tar.gz`
中的模型和 `benchmark_dataset`。实现按
`TensorFlow-benchmark-Modelzoo 2.0测试指导.pdf` 的流程，但框架内只运行
**一个私有容器、一个 server**；PDF 的 12 容器批量版需要另外的编排层。

软件入口为 `tensorflow_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、
测试和停止函数；`scripts/builders/base.sh` 负责镜像、源码、资产和 Bazel 构建，
`scripts/stages/` 负责运行检查和正式压测，`scripts/results/` 负责解析 CSV。
`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| benchmark 镜像 | 私有 `benchmark-infer:v1.0.0` | `/home/runner/software/tensorflow/benchmark-infer.tar`，`docker load` 后使用 |
| TensorFlow 源码 | [boostkit/tensorflow](https://gitcode.com/boostkit/tensorflow)，分支 `dev_2.20.0` | `${PERF_WORK_DIR}/tensorflow`；也可预置 `/home/runner/software/tensorflow/tensorflow/` |
| SavedModel | `din_mmoe`（默认）、`bst_mmoe`、`wd_dcn` | `/home/runner/software/tensorflow/tf_benchmark/` 或从 `tf_benchmark.tar.gz` 解压 |
| 数据集 | `benchmark_dataset/din_mmoe.tsv` 等 | 同上 |
| 压测工具 | 镜像内 `/usr/local/bin/brpc_client` 和 Bazel | 不额外安装 |

所有私有资产放在同一目录，默认：

```text
/home/runner/software/tensorflow/benchmark-infer.tar
/home/runner/software/tensorflow/tf_benchmark.tar.gz
/home/runner/software/tensorflow/tensorflow/        # 可选，源码
/home/runner/software/tensorflow/download/          # 可选，Bazel distdir
```

脚本优先复用已加载镜像和已解压资产，否则 `docker load` 和 `tar -xzf`。镜像、
源码 commit、资产归档的 SHA-256 都写入结果参数。

## 容器

每个任务创建一个带归属标签的容器，名称为
`boostkit-tensorflow-<架构>-<run-id>`。按测试指导使用单容器、特权模式、
`0-15` CPU 和 128g 内存限制：

```bash
docker run --detach --name "${TF_CONTAINER_NAME}" \
  --label "boostkit.tensorflow.run-id=${PERF_RUN_ID}" \
  --network=host --privileged \
  --cpuset-cpus=0-15 --memory=128g \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${TF_ASSET_DIR},target=${TF_ASSET_DIR},readonly" \
  "${TF_IMAGE}" sleep infinity
```

容器内以 root 运行，和测试指导一致；结果目录挂载到宿主机。停止阶段只删除带本次
`boostkit.tensorflow.run-id` 标签的容器，不执行 `docker prune`。

## predictor_server 构建

先确认源码和资产可见，再在容器内执行：

```bash
cd "${PERF_WORK_DIR}/tensorflow"
bazel --output_user_root=./output build \
  --enable_bzlmod=true --experimental_enable_bzlmod \
  --experimental_repo_remote_exec \
  --cxxopt=-std=c++17 --host_cxxopt=-std=c++17 \
  --copt=-O3 --host_copt=-O3 --copt=-march=armv8.5-a \
  --host_copt=-I/usr/local/include --linkopt=-L/usr/local/lib64 \
  --host_linkopt=-L/usr/local/lib64 \
  --linkopt=-Wl,-rpath,/usr/local/lib64 \
  --host_linkopt=-Wl,-rpath,/usr/local/lib64 \
  --action_env=LD_LIBRARY_PATH=/usr/local/lib64:${LD_LIBRARY_PATH:-} \
  --action_env=TF_SYSTEM_LIBS="boringssl,snappy" \
  --distdir=./download --copt=-w --host_copt=-w \
  --check_direct_dependencies=off //:predictor_server
```

`download/` 不存在时脚本不传 `--distdir`，由 Bazel 自行获取依赖；正式运行建议
预置 `download/` 或使用代理。构建产物必须存在：

```text
${PERF_WORK_DIR}/tensorflow/bazel-bin/predictor_server
```

镜像内还必须有 `/usr/local/bin/brpc_client`；缺少任一二进制时构建或启动阶段失败。

## 数据与运行顺序

1. 构建阶段：加载镜像、准备源码和资产、构建 `predictor_server`。
2. 启动阶段：检查容器、`predictor_server`、`brpc_client`、`din_mmoe/1` 和
   `benchmark_dataset/din_mmoe.tsv`。
3. 测试阶段在容器内执行官方 `tools/run_serving_benchmark.sh`，默认参数：

   ```bash
   MODEL_NAME=din_mmoe
   MODEL=${TF_ASSET_ROOT}/din_mmoe/1
   DATA=${TF_ASSET_ROOT}/benchmark_dataset/din_mmoe.tsv
   QPS_LIST=565
   RUN_MODES=baseline
   WARMUP=5
   DURATION=30
   THREAD_NUM=16
   CLIENT_THREAD_NUM=1
   MAX_INFLIGHT=100
   REQUEST_MIN_BATCH_SIZE=1
   REQUEST_MAX_BATCH_SIZE=100
   TF_NUM_INTEROP_THREADS=16
   TF_NUM_INTRAOP_THREADS=16
   BIN_SERVER=${PERF_WORK_DIR}/tensorflow/bazel-bin/predictor_server
   BIN_CLIENT=/usr/local/bin/brpc_client
   ```

   官方脚本启动 server、等待 `is serving on port=8890`，执行 5 秒 warmup 和 30 秒
   计时，写出 `results.csv`、`results.md`、`run.log`、server/client 日志。
4. 解析器只读取官方 `results.csv`，生成 Framework 指标。

## 指标与产物

每个 `mode × target_qps` 行产生 4 项指标：

| 指标 | 单位 | 方向 |
|---|---|---|
| `actual_qps` | queries/s | 越大越好 |
| `p99_latency_us` | us | 越小越好 |
| `server_cpu_pct_avg` | % | 越小越好 |
| `server_cpu_cores_avg` | cores | 越小越好 |

指标名形如：

```text
din_mmoe/baseline/qps=565/actual_qps
din_mmoe/baseline/qps=565/p99_latency_us
din_mmoe/baseline/qps=565/server_cpu_pct_avg
din_mmoe/baseline/qps=565/server_cpu_cores_avg
```

按模型 `din_mmoe` 分组、运行模式 `baseline` 作为子组。默认只跑 1 个 QPS、1 个
模式；通过 `TF_QPS_LIST`、`TF_RUN_MODES` 可扩展。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 压测完整控制台输出 |
| `tensorflow-benchmark/results.csv` | 官方结果 CSV |
| `tensorflow-benchmark/metadata.txt` | 模型、数据、线程、QPS、镜像和机器信息 |
| `tensorflow-benchmark/run.log` | server/client 运行摘要 |
| `tensorflow-benchmark/` | server/client 日志、CPU 采样和 results.md |
| `benchmark_tensorflow.json` | Framework 归一化指标和参数 |
| `build_variant.json` | 构建类型 |

脱离 Workflow 执行完整流程：

```bash
bash software/AI/tensorflow/tensorflow_test.sh \
  --version 2.20.0 \
  --variant base \
  --asset-dir /home/runner/software/tensorflow \
  --results-dir /home/runner/tensorflow-results/2.20.0
```

独立运行默认清理 `${PERF_WORK_DIR}`；需要保留现场时加 `--keep-workdir`。

## 与 PDF 的差异

- PDF 使用 12 个 server 容器做批量压测；本用例先落地为单容器单 server，指标和
  压测命令保留，容器数量不保留。需要 12 容器版本时应另做编排，不能把单容器结果
  冒充批量结果。
- PDF 的容器使用 `--privileged`、`--cpuset-cpus=0-15`、`--memory=128g`；本用例按
  用户确认保留这些参数，因此与框架其他“不绑核、不限制 CPU/内存”的用例不同。
- PDF 同时支持 `baseline`、`dnn`、`opt`；本用例默认 `baseline`，可通过
  `TF_RUN_MODES` 扩展。
