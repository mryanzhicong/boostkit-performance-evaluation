# OpenVINO 2026.2.1 ResNet18 FP32 CPU 推理性能测试

本用例把 boostkit 开箱测试材料 `Test/openvino` 移植进框架：在 x86_64、aarch64
上分别安装 OpenVINO 2026.2.1 和固定的 PyTorch/ONNX CPU 依赖，用官方 FP32
ResNet18 导出 ONNX（关闭常量折叠），对三段 1080p 视频首帧做 batch 1、单推理
线程、单 stream、LATENCY 模式的同步推理。导出、编译、下载和输出检查不计时；
计时只覆盖 `request.infer()`。核对的参考仓库提交为
`21154155f56328b708e2c78f4ce6bac08101fe68`。

软件入口为 `openvino_test.sh`。Framework 通过 `case.yaml` 调用
`build → start → test → stop`，独立入口调用同一组函数。`scripts/builders/base.sh`
安装 Python/OpenVINO/ONNX 运行时并预下载 ResNet18 权重，`scripts/stages/start.sh`
导出 ONNX 和三个输入，`scripts/stages/test.sh` 执行正式测试和指标转换，
`scripts/stages/stop.sh` 清理容器。`optimized` 构建入口尚未实现，选中后明确失败。

> 本用例是参考脚本的框架化移植：**固定依赖、模型、权重、预处理、ONNX 导出参数、
> 线程参数和计时口径逐项保留，但驱动脚本不是逐字执行原
> `run_bench.sh`/`install.sh`/`bench.py`**。差异见文末。

## 软件与测试工具

| 项目 | 来源与版本 | 预置位置 | 容器内位置 |
|---|---|---|---|
| OpenVINO | PyPI `openvino==2026.2.1`（x86_64 manylinux_2_28，aarch64 manylinux_2_35） | pip 解析 | `${PERF_WORK_DIR}/pydeps` |
| ONNX | PyPI `onnx==1.19.1` | pip 解析 | `${PERF_WORK_DIR}/pydeps` |
| PyTorch | CPU wheel `torch-2.9.1+cpu-cp311-cp311-manylinux_2_28_<arch>.whl`，[官方 CPU 索引](https://download.pytorch.org/whl/cpu/) | `/home/runner/software/openvino/` | `${PERF_WORK_DIR}/wheels/`，安装到 `${PERF_WORK_DIR}/pydeps` |
| torchvision | x86_64：[CPU wheel](https://download.pytorch.org/whl/cpu/torchvision-0.24.1%2Bcpu-cp311-cp311-manylinux_2_28_x86_64.whl)；aarch64：PyPI `0.24.1` | x86_64 优先 `/home/runner/software/openvino/` | `${PERF_WORK_DIR}/wheels/` 或 pip 解析 |
| numpy / pillow | `numpy==2.4.6`、`pillow==13.0.0` | pip 解析 | `${PERF_WORK_DIR}/pydeps` |
| ResNet18 权重 | [resnet18-f37072fd.pth](https://download.pytorch.org/models/resnet18-f37072fd.pth)，SHA-256 `f37072fd47e89c5e827621c5baffa7500819f7896bbacec160b1a16c560e07ec` | `/home/runner/software/openvino/weights/`（可选） | `${PERF_WORK_DIR}/openvino-torch-cache/hub/checkpoints/` |
| 基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | `/home/runner/software/openEuler-24.03-LTS-SP4/` | `docker load` 后的镜像 |

OpenVINO 的 aarch64 wheel 标记为 `manylinux_2_35_aarch64`；openEuler 24.03 的
glibc 为 2.38，满足要求。x86_64 的 wheel 为 `manylinux_2_28_x86_64`。

PyTorch/torchvision wheel 优先从 `/home/runner/software/openvino/` 读取同名文件；
缺失时从官方 CPU 索引下载到 `${PERF_WORK_DIR}/wheels/`，校验 zip 并记录实际
SHA-256。x86_64 必须使用 torchvision CPU wheel，否则 PyPI wheel 与 CPU torch
会出现 `operator torchvision::nms does not exist`；aarch64 的 CPU 索引没有
torchvision wheel（HTTP 403），使用 PyPI `0.24.1`。numpy、pillow、openvino、onnx
从 Huawei PyPI 镜像安装，失败时回退 pypi.org。

ResNet18 权重在 build 阶段用宿主 `curl` 预下载并校验 SHA-256；优先读取
`/home/runner/software/openvino/weights/`。权重不写入仓库。

## 容器与安装

脚本先检查 Docker daemon。镜像归档和同名 `.sha256sum` 优先取
`/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失才下载；校验 SHA-256、
`docker load` 并核对镜像架构和容器内 `/etc/os-release`。开发环境可用
`OPENVINO_CONTAINER_IMAGE=<已有镜像>` 指定已加载镜像，脚本仍核对架构和
openEuler 24.03 LTS SP4 版本。

每次运行创建一个带任务标签的容器，名称为
`boostkit-openvino-<架构>-<运行 ID>`，标签为
`boostkit.openvino.run-id=<运行 ID>`。容器使用宿主网络，不绑核、不限制
CPU/内存/NUMA；工作目录、结果目录、只读用例脚本目录、视频目录和可选的本地
权重目录挂载到容器内相同绝对路径：

```bash
docker run --detach --name "${OPENVINO_CONTAINER_NAME}" \
  --label "boostkit.openvino.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${OPENVINO_VIDEO_DIR},target=${OPENVINO_VIDEO_DIR},readonly" \
  --mount "type=bind,source=${OPENVINO_WEIGHT_DIR},target=${OPENVINO_WEIGHT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${OPENVINO_CONTAINER_IMAGE}" sleep infinity
```

视频目录和本地权重目录只在实际存在时挂载（脚本里是条件参数）。设置
`PERF_PROXY` 时额外把 `/home/runner/software/anchors/` 挂到容器 CA 目录并执行
`update-ca-trust extract`，只在本次容器内把 openEuler 仓库地址换成
`repo.huaweicloud.com/openeuler`。

镜像准备：

```bash
archive="${OPENVINO_IMAGE_ARCHIVE_DIR}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
printf '%s  %s\n' \
  "$(awk 'NR==1 {print $1}' "${archive}.sha256sum")" "${archive}" | sha256sum -c -

docker load --input "${archive}"
docker image inspect --format '{{.Architecture}}' "${OPENVINO_CONTAINER_IMAGE}"
docker run --rm --network=none "${OPENVINO_CONTAINER_IMAGE}" cat /etc/os-release
```

容器内安装 Python 3.11、pip 和运行时库：

```bash
docker exec --user 0 "${OPENVINO_CONTAINER_NAME}" dnf install -y \
  python3 python3-pip tar gzip xz curl ca-certificates libgomp libstdc++
```

PyTorch CPU wheel 和（仅 x86_64）torchvision CPU wheel：

```bash
curl -fL --retry 3 -o \
  "${OPENVINO_WHEEL_CACHE}/${OPENVINO_TORCH_WHEEL}" \
  "${OPENVINO_TORCH_WHEEL_URL}"

# 仅 x86_64
curl -fL --retry 3 -o \
  "${OPENVINO_WHEEL_CACHE}/${OPENVINO_TORCHVISION_WHEEL}" \
  "${OPENVINO_TORCHVISION_WHEEL_URL}"
```

在容器内安装到私有目录：

```bash
docker exec \
  -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
  -e "PYTHONPATH=${OPENVINO_DEPS_DIR}" \
  -e "TORCH_HOME=${OPENVINO_TORCH_HOME}" \
  "${OPENVINO_CONTAINER_NAME}" \
  python3 -m pip install --disable-pip-version-check --no-input --no-cache-dir \
    --no-warn-script-location --only-binary=:all: \
    --target "${OPENVINO_DEPS_DIR}" \
    --find-links "${OPENVINO_WHEEL_CACHE}" \
    --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
    "torch==2.9.1+cpu" "torchvision==0.24.1+cpu" \
    "openvino==2026.2.1" "onnx==1.19.1" \
    "numpy==2.4.6" "pillow==13.0.0"
```

aarch64 把 `torchvision==0.24.1+cpu` 换成 `torchvision==0.24.1`；Huawei 失败时
回退 pypi.org。ResNet18 权重预下载：

```bash
curl -fL --retry 3 -o \
  "${OPENVINO_TORCH_HOME}/hub/checkpoints/resnet18-f37072fd.pth" \
  https://download.pytorch.org/models/resnet18-f37072fd.pth
printf '%s  %s\n' \
  f37072fd47e89c5e827621c5baffa7500819f7896bbacec160b1a16c560e07ec \
  "${OPENVINO_TORCH_HOME}/hub/checkpoints/resnet18-f37072fd.pth" | sha256sum -c -
```

构建结束前在容器内运行版本检查：

```bash
docker exec \
  -e "PYTHONPATH=${OPENVINO_DEPS_DIR}" \
  -e "TORCH_HOME=${OPENVINO_TORCH_HOME}" \
  "${OPENVINO_CONTAINER_NAME}" \
  python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py"
```

`verify_runtime.py` 断言 `torch 2.9.1`、`torchvision 0.24.1`、`openvino 2026.2.1`、
`onnx 1.19.1`、`numpy 2.4.6`、`pillow 13.0.0`，并把实际 OpenVINO 版本
`2026.2.1` 写入 `PERF_ACTUAL_VERSION_FILE`。

## 数据与运行顺序

两台 Runner 必须预置以下 1920×1080、8-bit YUV420P 素材，至少包含 1 个完整帧：

```text
/home/runner/software/openvino/video/BQTerrace_1920x1080_60-dianbo.yuv
/home/runner/software/openvino/video/Film2012_1920x1080_25_8bit_8Mbps.yuv
/home/runner/software/openvino/video/messi_1920x1080_25_1000.yuv
```

参考校验值（与 x264 历史正式结果一致）：

| 文件 | 字节数 | SHA-256 |
|---|---:|---|
| `BQTerrace_1920x1080_60-dianbo.yuv` | 1,866,240,000 | `5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7` |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | 4,665,600,000 | `27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc` |
| `messi_1920x1080_25_1000.yuv` | 3,110,400,000 | `1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b` |

默认目录缺少完整三件套时，脚本依次回退到
`/home/runner/software/x264/video`、`/home/test/Test/video`，只读使用同一份
素材。源文件 SHA-256 写入结果 `parameters`，跨架构比较要求一致。

1. `build`：创建唯一容器，安装 Python 3.11/pip、OpenVINO/ONNX/PyTorch 依赖，
   预下载 ResNet18 权重并校验。
2. `start`：校验运行时和三个视频；用 `prepare_inputs.py` 导出 ONNX、生成三个
   `.npy` 输入和 `manifest.json`；导出/检查不计时。
3. `test`：校验 manifest 后对三个场景各做 3 次预热 + 20 次同步推理；记录输出
   形状、有限值、输入/模型 SHA；不重新导出模型。
4. `stop`：保存容器日志，按本次任务 label 停止并删除容器。

## 启动、模型准备与就绪检查

`build` 创建的容器在 `start`、`test` 复用，不重新 run/load/install。`start`
执行：

```bash
docker exec \
  -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
  -e "PYTHONPATH=${OPENVINO_DEPS_DIR}" \
  -e "TORCH_HOME=${OPENVINO_TORCH_HOME}" \
  "${OPENVINO_CONTAINER_NAME}" \
  python3 "${SCRIPT_DIR}/scripts/results/verify_runtime.py"

for video in \
  BQTerrace_1920x1080_60-dianbo.yuv \
  Film2012_1920x1080_25_8bit_8Mbps.yuv \
  messi_1920x1080_25_1000.yuv; do
  docker exec "${OPENVINO_CONTAINER_NAME}" test -f "${OPENVINO_VIDEO_DIR}/${video}"
  stat -c '%s %n' "${OPENVINO_VIDEO_DIR}/${video}"
done

docker exec \
  -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
  -e "PYTHONPATH=${OPENVINO_DEPS_DIR}" \
  -e "TORCH_HOME=${OPENVINO_TORCH_HOME}" \
  "${OPENVINO_CONTAINER_NAME}" \
  python3 "${SCRIPT_DIR}/scripts/results/prepare_inputs.py" \
    --video-dir "${OPENVINO_VIDEO_DIR}" \
    --output-dir "${OPENVINO_MEDIA_DIR}" \
    --manifest "${OPENVINO_MANIFEST}"
```

`prepare_inputs.py` 与参考 `prepare.py` 一致：

- 读取每段视频首帧，按 BT.709 整数公式转 RGB，执行
  `weights.transforms()`，保存 `(1,3,224,224)` 的 `.npy`；
- 用 `torchvision.models.resnet18(weights=ResNet18_Weights.DEFAULT).eval()`
  导出 ONNX，参数为 `opset_version=17`、`input_names=['image']`、
  `output_names=['logits']`、`dynamo=False`、`do_constant_folding=False`；
- `onnx.checker.check_model` 后记录 ONNX SHA-256、每个输入 SHA-256、权重 URL/SHA；
- 写出 `manifest.json`，供测试阶段使用，测试阶段不再下载或重新导出。
- `--verify-only` 只校验 manifest、ONNX、`.npy`、视频和 SHA-256。

没有 `sleep` 式就绪判断；版本、视频、ONNX/输入 SHA 全部通过才算 ready。

## 正式测试命令

`test` 在同一个容器内执行：

```bash
docker exec \
  -e "TMPDIR=${TMPDIR}" -e "HOME=${PERF_WORK_DIR}/home" \
  -e "PYTHONPATH=${OPENVINO_DEPS_DIR}" \
  -e "TORCH_HOME=${OPENVINO_TORCH_HOME}" \
  "${OPENVINO_CONTAINER_NAME}" \
  python3 "${SCRIPT_DIR}/scripts/results/run_benchmark.py" \
    --manifest "${OPENVINO_MANIFEST}" \
    --evidence-dir "${OPENVINO_EVIDENCE_DIR}" \
    --csv "${OPENVINO_CSV_PATH}" \
    --iterations 20 --warmup-iterations 3 \
  2>&1 | tee "${RESULTS_DIR}/benchmark_raw.log"
```

测试脚本固定：

1. `OMP_NUM_THREADS=1`、`OMP_THREAD_LIMIT=1`、`OPENBLAS_NUM_THREADS=1`、
   `MKL_NUM_THREADS=1`。
2. 每个场景新建 `ov.Core()`，`compile_model(model, 'CPU', {...})`，配置为
   `INFERENCE_NUM_THREADS=1`、`NUM_STREAMS=1`、`PERFORMANCE_HINT=LATENCY`、
   `INFERENCE_PRECISION_HINT=f32`、`ENABLE_CPU_PINNING=False`；编译不计时。
3. 3 次预热后检查输出形状 `(1,1000)` 和有限值；再执行 20 次
   `request.infer({0: array})`，用 `time.perf_counter_ns()` 计时，均值写入 CSV。
4. 记录 20 个样本、输入/ONNX SHA、OpenVINO 版本、线程/stream/hint、输出和
   top5；失败场景写 `FAIL` 行并以非零退出，不生成成功指标。

测试结束后严格校验并生成 Framework 结果：

```bash
SOFTWARE_VERSION=2026.2.1 EXPECTED_ARCH="${EXPECTED_ARCH}" \
  python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
  "${OPENVINO_CSV_PATH}" \
  "${OPENVINO_EVIDENCE_DIR}/evidence.json" \
  "${RESULTS_DIR}/benchmark_openvino.json"
```

## 停止与清理

`stop` 先保存容器日志，再按本次任务 label 只停止/删除本任务容器：

```bash
docker logs "${OPENVINO_CONTAINER_NAME}" \
  > "${RESULTS_DIR}/container_runtime.log" 2>&1 || true
docker stop --time 30 "${OPENVINO_CONTAINER_NAME}"
docker rm "${OPENVINO_CONTAINER_NAME}"
```

不执行 `docker prune`，不删除其他任务容器、共享镜像、共享 wheel/权重缓存或
真实结果。

## 指标与产物

3 个场景，单位 `ms/image`，方向 `lower_is_better`，上报 20 次均值：

| 视频 | 场景 |
|---|---|
| BQTerrace | `BQTerrace_resnet18_fp32_b1_c1` |
| Film2012 | `Film2012_resnet18_fp32_b1_c1` |
| messi | `messi_resnet18_fp32_b1_c1` |

报告按模型分组（`resnet18`），视频作为子组。缺失场景、失败行、样本数不足、
非正/非有限值、CSV 与证据不符、权重/视频/输入/ONNX SHA 不符、OpenVINO 配置
不符、输出形状或 top5 异常都会让测试失败。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 正式测试完整控制台输出 |
| `result_bench-openvino.csv` | 参考格式 CSV（3 行，`scenario,iterations,ms_per_image,status`，值为均值） |
| `benchmark_evidence/evidence.json` | 参数、运行时、3 个场景样本、输出、top5、输入/模型/权重 SHA |
| `benchmark_openvino.json` | Framework 归一化结果（3 个指标） |
| `torch-wheel.sha256`、`torchvision-wheel.sha256` | x86 wheel 的实际 SHA-256（私有工作目录） |
| `container_runtime.log` | 停止阶段保存的容器日志 |

脱离 Workflow 执行完整流程：

```bash
bash software/AI/openvino/openvino_test.sh \
  --version 2026.2.1 \
  --variant base \
  --results-dir /home/runner/openvino-results/2026.2.1
```

素材不在默认目录时可加 `--video-dir` 或设置 `OPENVINO_VIDEO_DIR`；独立运行默认
清理自身创建的私有工作目录，需要保留现场时加 `--keep-workdir`。

## 与参考脚本的差异

- 参考脚本在宿主机用 root 安装依赖并直接运行；本用例把依赖、ONNX 导出、输入
  准备和测试放进同一个私有容器，普通安装/测试使用 Runner UID，仅 RPM 安装
  使用容器 root。
- 参考脚本使用 `/home/test/Test/video`；本用例按 Runner 约定读取
  `/home/runner/software/openvino/video`，并在不完整时回退 x264/Test 目录。
- 参考脚本使用 `$HOME/.cache/media-bench` 和 `.deps`；本用例每次任务使用
  `${PERF_WORK_DIR}` 私有 wheel/pydeps/TORCH_HOME，不复用半成品。
- 参考脚本的 `bootstrap_env.sh` 负责通用 pip/sysroot；本用例只安装本软件需要的
  Python 3.11/pip 和固定 wheel。
- x86_64 使用 PyTorch CPU 索引中的 torchvision `0.24.1+cpu` wheel，避免 PyPI
  wheel 与 CPU torch 的算子注册不匹配；aarch64 使用 PyPI `0.24.1`。
- 参考脚本在 test 阶段临时调用 `prepare.py`；本用例把导出/输入准备放在 start
  阶段并写 manifest，test 只校验和计时，计时口径不变。
- 参考脚本每个场景启动独立 `worker.py` 进程；本用例在同一进程内为每个场景新建
  `ov.Core()` 和编译模型，测量范围仍只有 `request.infer()`。
- 参考脚本直接打印 CSV；本用例保留同一 CSV，并额外保存 evidence、输出/top5
  和 SHA-256，由独立解析器严格校验后生成 Framework 指标。
