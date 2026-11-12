# torchvision 0.24.1 官方 INT8 CPU 推理性能测试

本用例在 x86_64、aarch64 上分别安装固定的 CPU 版 PyTorch 2.9.1 +
torchvision 0.24.1，使用参考仓库 `Test/torchvision` 规定的三段 1080p 首帧，
测量官方 INT8 MobileNetV2、MobileNetV3-Large 在 batch 1、单线程、QNNPACK
后端下的前向推理时延。安装、模型构建、下载、抽帧、预处理和输出检查不计时；
计时只覆盖 `model(x)` 前向。核对的参考仓库提交为
`21154155f56328b708e2c78f4ce6bac08101fe68`。

软件入口为 `torchvision_test.sh`。Framework 通过 `case.yaml` 调用
`build → start → test → stop`；独立入口调用同一组函数。`scripts/builders/base.sh`
安装 Python 运行时，`scripts/stages/` 负责容器校验、测试和清理，
`scripts/results/` 负责基准执行、证据和指标转换。`optimized` 构建入口尚未实现，
选中后明确失败。

> 本用例是参考脚本的框架化移植：**固定依赖版本、模型、权重、预处理、线程参数
> 和计时口径逐项保留，但驱动脚本不是逐字执行原 `run_bench.sh`**。差异见“与参考
> 脚本的差异”。

## 软件与测试工具

| 项目 | 来源与版本 | 预置位置 | 容器内位置 |
|---|---|---|---|
| PyTorch | CPU wheel `torch-2.9.1+cpu-cp311-cp311-manylinux_2_28_<arch>.whl`，[官方 CPU 索引](https://download.pytorch.org/whl/cpu/) | `/home/runner/software/torchvision/` | `${PERF_WORK_DIR}/wheels/`，安装到 `${PERF_WORK_DIR}/pydeps` |
| torchvision | PyPI `torchvision==0.24.1` | pip 解析 | `${PERF_WORK_DIR}/pydeps` |
| numpy / pillow | `numpy==2.4.6`、`pillow==13.0.0` | pip 解析 | `${PERF_WORK_DIR}/pydeps` |
| MobileNetV2 INT8 权重 | [mobilenet_v2_qnnpack_37f702c5.pth](https://download.pytorch.org/models/quantized/mobilenet_v2_qnnpack_37f702c5.pth)，SHA-256 `a9225f174880dcd1a662adaa01ea71b06b6a78822d3a4a5a4bd2d4ee5709a8da` | `/home/runner/software/torchvision/weights/`（可选） | `${PERF_WORK_DIR}/torch-cache/hub/checkpoints/` |
| MobileNetV3-Large INT8 权重 | [mobilenet_v3_large_qnnpack-5bcacf28.pth](https://download.pytorch.org/models/quantized/mobilenet_v3_large_qnnpack-5bcacf28.pth)，SHA-256 `5bcacf2876b29c80e6ef777b76ae2a9cbde265af9b51e287c9b7f04a38cb53b1` | 同上 | 同上 |
| 基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | `/home/runner/software/openEuler-24.03-LTS-SP4/` | `docker load` 后的镜像 |

PyTorch wheel 优先从 `/home/runner/software/torchvision/` 读取同名文件；缺失时
从官方 CPU 索引下载到 `${PERF_WORK_DIR}/wheels/`。wheel 按架构固定文件名，下载后
记录 SHA-256 并校验 zip 完整性；没有在上游找到可固定的 wheel SHA-256，因此在
构建日志/`torch-wheel.sha256` 中记录实际值。torchvision、numpy、pillow 从
Huawei PyPI 镜像安装，缺失时回退 pypi.org。

模型权重优先读取 `/home/runner/software/torchvision/weights/` 下的同名文件并
校验上表 SHA-256；缺失时由 torchvision 从官方 URL 下载到本次任务的
`TORCH_HOME`。权重不写入仓库。

## 容器与安装

脚本先检查 Docker daemon。镜像归档和同名 `.sha256sum` 优先取
`/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时才下载；校验 SHA-256、
`docker load` 并核对镜像架构和容器内 `/etc/os-release`。开发环境可用
`TORCHVISION_CONTAINER_IMAGE=<已有镜像>` 指定已加载镜像，脚本仍核对架构和
openEuler 24.03 LTS SP4 版本。

每次运行创建一个带任务标签的容器，名称为
`boostkit-torchvision-<架构>-<运行 ID>`，标签为
`boostkit.torchvision.run-id=<运行 ID>`。容器使用宿主网络，不绑核、不限制
CPU/内存/NUMA；工作目录、结果目录、只读用例脚本目录、视频目录和可选的本地
权重目录挂载到容器内相同绝对路径。

容器内安装 Python 3.11 和 pip，然后：

```bash
python3 -m pip install --target "${PERF_WORK_DIR}/pydeps" \
  --find-links "${PERF_WORK_DIR}/wheels" \
  --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
  --only-binary=:all: \
  "torch==2.9.1+cpu" "torchvision==0.24.1" "numpy==2.4.6" "pillow==13.0.0"
```

构建后执行 `scripts/results/verify_runtime.py`，断言
`torch 2.9.1`、`torchvision 0.24.1`、`numpy 2.4.6`、`pillow 13.0.0`，并把
实际 `torchvision` 版本 `0.24.1` 写入 `PERF_ACTUAL_VERSION_FILE`。

## 数据与运行顺序

两台 Runner 必须预置以下 1920×1080、8-bit YUV420P 素材，至少包含 1 个完整帧：

```text
/home/runner/software/torchvision/video/BQTerrace_1920x1080_60-dianbo.yuv
/home/runner/software/torchvision/video/Film2012_1920x1080_25_8bit_8Mbps.yuv
/home/runner/software/torchvision/video/messi_1920x1080_25_1000.yuv
```

参考校验值（与 x264 历史正式结果一致）：

| 文件 | 字节数 | SHA-256 |
|---|---:|---|
| `BQTerrace_1920x1080_60-dianbo.yuv` | 1,866,240,000 | `5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7` |
| `Film2012_1920x1080_25_8bit_8Mbps.yuv` | 4,665,600,000 | `27d9bc94719516e6224efa0a46abbd64c53c610b7a802ef83b045260d006a1fc` |
| `messi_1920x1080_25_1000.yuv` | 3,110,400,000 | `1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b` |

脚本不生成或下载视频。源文件 SHA-256 写入结果 `parameters`，跨架构比较要求
内容一致。

1. `build`：创建唯一容器，安装 Python 3.11/pip 和固定 CPU 依赖，校验版本。
2. `start`：校验运行时、三段视频和可选本地权重；不启动后台服务。
3. `test`：对每个模型/视频组合做 3 次预热 + 20 次前向计时；记录输出形状、
   有限值、权重 SHA、输入张量 SHA。
4. `stop`：保存容器日志，只停止并删除带本次任务标签的容器。

图像准备与参考脚本一致：从每个 YUV 文件读取首帧，按 BT.709 整数公式转 RGB，
构造 1920×1080 `PIL.Image`，再执行官方 `weights.transforms()` 得到 224×224
输入。模型使用 `torchvision.models.quantization.mobilenet_v2/mobilenet_v3_large
(weights=..., quantize=True)`，`torch.backends.quantized.engine='qnnpack'`，
`torch.set_num_threads(1)`、`torch.set_num_interop_threads(1)`。

## 指标与产物

6 个场景，单位 `ms/image`，方向 `lower_is_better`，上报 20 次均值：

| 视频 | MobileNetV2 | MobileNetV3-Large |
|---|---|---|
| BQTerrace | `BQTerrace_mobilenet_v2_official_int8_b1_c1` | `BQTerrace_mobilenet_v3_large_official_int8_b1_c1` |
| Film2012 | `Film2012_mobilenet_v2_official_int8_b1_c1` | `Film2012_mobilenet_v3_large_official_int8_b1_c1` |
| messi | `messi_mobilenet_v2_official_int8_b1_c1` | `messi_mobilenet_v3_large_official_int8_b1_c1` |

报告按模型分组（`mobilenet_v2`、`mobilenet_v3_large`），视频作为子组
（`BQTerrace`、`Film2012`、`messi`）。每项恰好 3 次预热 + 20 次计时；缺失
场景、失败行、样本数不足、非正/非有限值、CSV 与证据不符、权重/视频 SHA 不符、
输出形状或 top5 异常都会让测试失败。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 正式测试完整控制台输出 |
| `result_bench-torchvision.csv` | 参考格式 CSV（6 行，`scenario,iterations,ms_per_image,status`，值为均值） |
| `benchmark_evidence/evidence.json` | 参数、运行时、6 个场景样本、输出、top5、权重/输入 SHA |
| `benchmark_torchvision.json` | Framework 归一化结果（6 个指标） |
| `torch-wheel.sha256` | 本次 PyTorch wheel 的 SHA-256（私有工作目录） |
| `container_runtime.log` | 停止阶段保存的容器日志 |

脱离 Workflow 执行完整流程：

```bash
bash software/AI/torchvision/torchvision_test.sh \
  --version 0.24.1 \
  --variant base \
  --results-dir /home/runner/torchvision-results/0.24.1
```

素材不在默认目录时可加 `--video-dir` 或设置 `TORCHVISION_VIDEO_DIR`。
独立运行默认清理自身创建的私有工作目录；需要保留现场时加 `--keep-workdir`。

## 与参考脚本的差异

- 参考脚本在宿主机用 root 安装依赖；本用例把依赖、模型构建、下载和测试放进
  同一个私有容器，普通安装/测试使用 Runner UID，仅 RPM 安装使用容器 root。
- 参考脚本使用 `/home/test/Test/video`；本用例按 Runner 约定读取
  `/home/runner/software/torchvision/video`，并允许覆盖。
- 参考脚本使用 `$HOME/.cache/media-bench` 和 `.deps`；本用例每次任务使用
  `${PERF_WORK_DIR}` 私有 wheel/pydeps/TORCH_HOME，不复用半成品。
- 参考脚本的 `bootstrap_env.sh` 负责通用 pip/sysroot；本用例只安装本软件需要的
  Python 3.11/pip 和固定 wheel，容器内仓库地址按镜像策略替换。
- 参考脚本直接打印 CSV；本用例保留同一 CSV，并额外保存 evidence、输出/top5
  和 SHA-256，由独立解析器严格校验后生成 Framework 指标。
- 驱动脚本按框架四阶段重写，但模型、权重 URL、预处理、线程、轮次、计时函数
  和指标口径保持不变。
