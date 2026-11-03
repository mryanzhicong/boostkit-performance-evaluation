# ScaNN 1.4.2 性能测试

本用例在 x86_64、aarch64 上分别安装 [官方 ScaNN 1.4.2 wheel](https://pypi.org/project/scann/1.4.2/)，使用固定提交的 [ann-benchmarks](https://github.com/erikbern/ann-benchmarks/tree/2e081ad32c1eccab72dcb739ad886c310b90f715) 测试五个公开数据集。ScaNN 和查询程序运行在本次任务的 Python 3.9 私有 Docker 镜像中；宿主机的私有 Python 虚拟环境负责调用上游 `run.py`。两架构使用同一套数据集、配置和查询命令，不使用定制版 ScaNN。

软件入口为 `scann_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、测试和停止函数；独立入口也调用这些阶段。`scripts/builders/base.sh` 负责基础版的完整准备，`scripts/stages/` 负责校验、测试和清理，`scripts/results/run_benchmark.py` 负责生成配置并读取上游 HDF5 结果。`optimized` 构建入口尚未实现，选择后明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| ScaNN | PyPI 官方 wheel，1.4.2，CPython 3.9 | 本次任务构建的 `ann-benchmarks-scann-<架构>-<运行 ID>` 镜像 |
| ann-benchmarks | 上游提交 `2e081ad32c1eccab72dcb739ad886c310b90f715` | `${PERF_WORK_DIR}/ann-benchmarks` |
| 协调端 Python | 宿主机 Python 3.10 或以上；依赖固定版本 | `${PERF_WORK_DIR}/annb-venv` |
| 数据集 | [ann-benchmarks 公开数据集](https://ann-benchmarks.com/) | `/home/runner/software/scann/data/<数据集>.hdf5` |

Runner 必须能使用 Docker daemon，并提供 `git`、`python3` 和 `curl`。脚本不会把 ScaNN 安装到宿主机 Python，也不改系统 Python 环境。

## ScaNN 获取、构建与容器启动

### 1. 获取测试框架和协调端依赖

构建阶段将上游 ann-benchmarks 克隆到本次任务目录，检出并核对指定提交；随后建立宿主机私有虚拟环境。命令形态如下：

```bash
git clone --filter=blob:none https://github.com/erikbern/ann-benchmarks.git \
  "${PERF_WORK_DIR}/ann-benchmarks"
git -C "${PERF_WORK_DIR}/ann-benchmarks" checkout --detach \
  2e081ad32c1eccab72dcb739ad886c310b90f715
python3 -m venv "${PERF_WORK_DIR}/annb-venv"
"${PERF_WORK_DIR}/annb-venv/bin/python" -m pip install \
  -i https://mirrors.aliyun.com/pypi/simple/ \
  numpy==2.2.4 h5py==3.13.0 pyyaml==6.0.2 scikit-learn==1.6.1 \
  matplotlib==3.10.1 docker==7.1.0 psutil==7.0.0 \
  ansicolors==1.1.8 jinja2==3.1.6
```

虚拟环境只用于启动 `run.py`、准备数据和读取结果；它不导入 ScaNN。

### 2. 取得 ScaNN wheel 并构建镜像

脚本优先读取 Runner 持久目录中的本地 wheel。缺失时，Docker 构建通过阿里云 PyPI 镜像下载官方 1.4.2 wheel。

| 架构 | 本地 wheel 路径 | 官方 SHA-256 |
|---|---|---|
| `x86_64` | `/home/runner/software/scann/wheels/x86_64/scann-1.4.2-cp39-cp39-manylinux_2_27_x86_64.whl` | `b34f64f7ed9349cad2d5be9dd90f3b203278fc94d2920bc51e95895ae50b22b0` |
| `aarch64` | `/home/runner/software/scann/wheels/aarch64/scann-1.4.2-cp39-cp39-manylinux_2_27_aarch64.whl` | `7de7e076be04d7c1df19dcbc73770ac25646988aa8a2bdf388c7168c5e13b02e` |

本地 wheel 必须匹配上表 SHA-256；不匹配时失败，不回退到下载。脚本把已校验的 wheel 复制到本次私有构建上下文的 `wheelhouse/`。镜像使用 `python:3.9-slim`，由 `scripts/Dockerfile.scann` 安装 ScaNN 及其固定版本依赖。它只替换 ann-benchmarks 的镜像构建方式，不修改上游 ScaNN 算法模块。

```bash
docker build --rm --network=host -t "${SCANN_IMAGE_TAG}" \
  -f "${PERF_WORK_DIR}/ann-benchmarks/Dockerfile.scann" \
  "${PERF_WORK_DIR}/ann-benchmarks"
docker run --rm --entrypoint python "${SCANN_IMAGE_TAG}" -c \
  'from importlib.metadata import version; import scann; print(version("scann"))'
```

构建使用宿主机网络，以便容器内的 `pip` 使用宿主机的 DNS 和网络出口。第二条命令必须输出 `1.4.2`。镜像名带本次运行 ID；生成的 `config.yml` 使用相同名称，避免并行任务共用镜像。镜像内安装固定版本的 NumPy 2.0.2、h5py 3.12.1 等依赖；不会编译 ScaNN 源码。

测试阶段不直接执行固定的 `docker run` 命令。上游 `run.py` 通过 Docker SDK 创建并清理测试容器，挂载本次任务的 `ann_benchmarks/`、数据目录和结果目录，使用宿主网络。适配脚本不另设 CPU 或内存限制；上游 `run.py` 默认单 worker，把测试容器固定到 CPU 1，并按宿主机可用内存设置容器内存上限。这是上游工具的行为，两个架构均不额外绑核。停止阶段移除本次任务的镜像 tag。

正式工作流如设置 `PERF_PROXY`，宿主机网络命令使用该代理；证书从 `/home/runner/software/anchors/` 复制到本次构建上下文，镜像内更新 CA 信任。未设置代理时跳过证书复制和代理参数。

## 数据与运行顺序

### 1. 准备五个数据集

脚本依次读取以下文件；本地缺失时从 `https://ann-benchmarks.com/<数据集>.hdf5` 下载到同一个持久目录，不从 `/tmp` 读取测试数据。

| 数据集文件 | 距离 | 构建参数 `[n_leaves, AVQ 阈值, 每块维度, 距离函数]` | 查询参数 `[搜索叶数, 重排序数]` |
|---|---|---|---|
| `fashion-mnist-784-euclidean.hdf5` | 欧氏 | `[500, NaN, 4, squared_l2]` | `[11, 75]` |
| `sift-128-euclidean.hdf5` | 欧氏 | `[2000, NaN, 2, squared_l2]` | `[33, 235]` |
| `glove-100-angular.hdf5` | 角距离 | `[2000, 0.2, 2, dot_product]` | `[180, 230]` |
| `gist-960-euclidean.hdf5` | 欧氏 | `[2000, NaN, 4, squared_l2]` | `[221, 670]` |
| `deep-image-96-angular.hdf5` | 角距离 | `[2000, 0.2, 2, dot_product]` | `[18, 230]` |

每个 HDF5 文件都必须含 `train`、`test`、`neighbors` 和 `distances`。脚本记录文件大小、训练集形状、查询数及 SHA-256。两个架构的同名数据集 SHA-256 必须一致，否则不能形成有效对比。`NaN` 是配置中的 AVQ 阈值写法，不是测试结果。

### 2. 生成配置并运行上游测试

脚本为每个数据集生成一份 `os-configs/<数据集>/scann/config.yml`，其中只含上表的一组构建参数和一组查询参数。它将持久数据目录以绝对路径软链到本次私有 ann-benchmarks 的 `data/`，并按以下顺序调用上游 `run.py`：

```bash
cd "${PERF_WORK_DIR}/ann-benchmarks"
for ds in fashion-mnist-784-euclidean sift-128-euclidean glove-100-angular \
          gist-960-euclidean deep-image-96-angular; do
  "${PERF_WORK_DIR}/annb-venv/bin/python" run.py \
    --dataset "$ds" \
    --definitions "os-configs/$ds" \
    --algorithm scann --runs 1 --timeout 86400 --force
done
```

`--runs 1` 表示每个数据集运行一轮查询；`--timeout 86400` 为上游单场景超时参数；`--force` 确保同一次任务重试时不会复用旧 HDF5。测试为非 batch 模式，不运行参数寻优或额外场景。上游返回成功后，脚本还要求每个数据集恰好生成一个有效的 ScaNN HDF5 结果；仅有退出码 0 不算测试成功。

## 指标与产物

每个数据集的原始结果由上游写在 `results/<数据集>/10/scann/*.hdf5`。解析器读取这份文件的属性和查询时间，并生成以下九项指标：

| 指标 | 原始结果来源或计算方式 | 单位 | 方向 |
|---|---|---|---|
| Recall@10 | 返回的 10 个距离与数据集真值第 10 个距离比较，容差 `1e-3` | ratio | 越大越好 |
| QPS | `1 / best_search_time` | queries/s | 越大越好 |
| 建索引时间 | `build_time` | s | 越小越好 |
| 查询延迟 P50/P95/P99/P99.9 | 原始 `times` 的四个百分位，由秒换算为毫秒 | ms | 越小越好 |
| 平均候选数 | `candidates` | count | 仅展示 |
| 索引内存增量 | `index_size` | kB | 仅展示 |

五个数据集各九项，共 45 项。报告按数据集分组；跨架构只配对同名数据集、同名指标，并要求测试配置和数据文件 SHA-256 一致。原始 HDF5 属性还须表明：算法为 ScaNN、`count=10`、`run_count=1`、`batch_mode=false`；字段缺失或无效时测试失败，不输出部分成功报告。

| 产物 | 内容 |
|---|---|
| `ann-benchmarks-results/<数据集>/` | 五个上游原始 HDF5 结果 |
| `ann-benchmarks-logs/<数据集>.log` | 五个上游 `run.py` 控制台日志 |
| `benchmark_scann.json` | 45 项结构化指标、数据 SHA-256 和测试参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `normalized_result.json`、`report.md` | Framework 生成的标准化结果和单架构报告；独立入口也调用 Framework 生成这两个文件 |

脱离 Workflow 执行完整流程：

```bash
bash software/AI/scann/scann_test.sh \
  --version 1.4.2 \
  --variant base \
  --results-dir /home/runner/scann-results/1.4.2
```

独立入口按 `prepare → build → start → test → stop → finalize` 调用 Framework，最终把结果复制到 `--results-dir`。默认清理本次私有工作目录；排错时加 `--keep-workdir` 保留。当前 `optimized` 只会明确报未实现，不运行基础版或性能测试。
