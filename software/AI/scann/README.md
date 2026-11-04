# ScaNN 1.4.2 性能测试

本用例在 x86_64、aarch64 上分别安装官方 ScaNN 1.4.2 wheel，使用固定提交的
ann-benchmarks 测试五个公开数据集。正式测试采用参考指南附录的 batch 命令：
每个数据集构建一次索引、并行查询一轮。两架构使用相同数据、配置和命令，
各自使用机器可用的 CPU；不使用定制版 ScaNN。

软件入口为 `scann_test.sh`。Framework 通过 `case.yaml` 依次调用构建、启动、
测试和停止脚本；独立入口也调用相同阶段。`scripts/builders/base.sh` 准备
官方 wheel 和测试环境，`scripts/stages/` 执行阶段，
`scripts/results/run_benchmark.py` 生成配置、执行测试并读取结果。
`optimized` 尚未实现，选择后在构建阶段明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| ScaNN | [PyPI 官方 wheel](https://pypi.org/project/scann/1.4.2/)，1.4.2，CPython 3.9 | 本次任务构建的 `ann-benchmarks-scann-<架构>-<运行 ID>` 镜像 |
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
docker build --rm --network=host \
  --build-arg "RUN_UID=$(id -u)" --build-arg "RUN_GID=$(id -g)" \
  -t "${SCANN_IMAGE_TAG}" \
  -f "${PERF_WORK_DIR}/ann-benchmarks/Dockerfile.scann" \
  "${PERF_WORK_DIR}/ann-benchmarks"
docker run --rm --entrypoint python "${SCANN_IMAGE_TAG}" -c \
  'import os, scann; from importlib.metadata import version; print(version("scann"), f"{os.getuid()}:{os.getgid()}")'
```

构建使用宿主机网络，以便容器内的 `pip` 使用宿主机的 DNS 和网络出口。
第二条命令必须输出 `1.4.2 <Runner UID>:<Runner GID>`；版本或身份不符即失败。
镜像名带本次运行 ID；生成的 `config.yml` 使用相同名称，避免并行任务
共用镜像。镜像内安装固定版本的 NumPy 2.0.2、h5py 3.12.1 等依赖；
不会编译 ScaNN 源码。

### 3. 测试容器如何启动

`start` 阶段检查虚拟环境、`run.py` 和镜像版本，不常驻启动测试容器。
`test` 阶段由上游 `run.py` 经 Docker SDK 为每个数据集创建一个临时容器，
运行结束后由上游移除。容器配置如下：

| 项目 | 实际配置 |
|---|---|
| 镜像 | 本次任务的 `ann-benchmarks-scann-<架构>-<运行 ID>` |
| 网络 | `host` |
| 挂载 | 上游 `ann_benchmarks/` 只读、`data/` 只读、`results/` 可写 |
| CPU | batch 模式使用上游设置的全部 CPU 集合；不额外设置 CPU 配额 |
| 内存 | 上游按宿主机可用内存设置容器上限 |
| 用户 | 镜像默认使用构建时传入的 Runner UID/GID，结果文件可由 Runner 清理 |

ScaNN 适配器继承上游 `BaseANN.batch_query()`，以线程池并发调用单条
`query()`，不是 ScaNN 原生批量查询。两架构的 batch 口径相同，但可用 CPU
数可能不同；报告不将其解释为固定核数对比。`stop` 阶段移除本次私有镜像 tag。

正式工作流设置 `PERF_PROXY` 时，下载和构建命令使用该代理；脚本从
`/home/runner/software/anchors/` 复制 CA 证书到本次构建上下文，
镜像内执行 `update-ca-certificates`。未设置代理时不复制证书、不传代理参数。

## 数据与运行顺序

### 1. 准备五个数据集

脚本依次读取以下文件；本地缺失时从 `https://ann-benchmarks.com/<数据集>.hdf5` 下载到同一个持久目录，不从 `/tmp` 读取测试数据。

| 数据集文件 | 大小约 | 构建参数 `[叶数, AVQ 阈值, 块维度, 距离函数]` | 查询参数 `[搜索叶数, 重排序数]` |
|---|---:|---|---|
| `fashion-mnist-784-euclidean.hdf5` | 217 MB | `[500, NaN, 4, squared_l2]` | `[11, 75]` |
| `sift-128-euclidean.hdf5` | 501 MB | `[2000, NaN, 2, squared_l2]` | `[33, 235]` |
| `glove-100-angular.hdf5` | 463 MB | `[2000, 0.2, 2, dot_product]` | `[180, 230]` |
| `gist-960-euclidean.hdf5` | 3.6 GB | `[2000, NaN, 4, squared_l2]` | `[221, 670]` |
| `deep-image-96-angular.hdf5` | 3.6 GB | `[2000, 0.2, 2, dot_product]` | `[18, 230]` |

数据目录默认为 `/home/runner/software/scann/data/`，可通过 `SCANN_DATA_ROOT`
指定其他持久目录。脚本先用本地文件；
缺失时才从 `https://ann-benchmarks.com/<数据集>.hdf5` 下载到该持久目录。
五份文件合计约 8.4 GB，建议运行前离线备齐。手工准备示例：

```bash
mkdir -p /home/runner/software/scann/data
cd /home/runner/software/scann/data
for ds in fashion-mnist-784-euclidean sift-128-euclidean glove-100-angular \
          gist-960-euclidean deep-image-96-angular; do
  curl -fL --retry 3 -o "${ds}.hdf5" "https://ann-benchmarks.com/${ds}.hdf5"
done
sha256sum ./*.hdf5
```

五个文件均需放在该目录，文件名与表格完全一致。脚本核对 HDF5 的
`train`、`test`、`neighbors`、`distances`，记录文件大小、形状、查询数与
SHA-256。两架构同名文件的 SHA-256 必须相同，否则不应跨架构比较。
`NaN` 是上游配置中的 AVQ 阈值写法，不是测试结果。

### 2. 生成配置并运行上游测试

脚本为每个数据集生成一份 `os-configs/<数据集>/scann/config.yml`，
只包含表中的一组构建参数和一组查询参数。随后将持久数据目录以绝对路径
软链到本次私有 ann-benchmarks 的 `data/`，并按以下顺序调用上游 `run.py`：

```bash
cd "${PERF_WORK_DIR}/ann-benchmarks"
for ds in fashion-mnist-784-euclidean sift-128-euclidean glove-100-angular \
          gist-960-euclidean deep-image-96-angular; do
  "${PERF_WORK_DIR}/annb-venv/bin/python" run.py \
    --dataset "$ds" \
    --definitions "os-configs/$ds" \
    --algorithm scann --runs 1 --timeout 86400 --batch --force
done
```

本用例采用参考指南附录 C 的正式命令。各参数含义如下：

| 参数 | 作用 |
|---|---|
| `--runs 1` | 每个数据集执行一轮查询 |
| `--timeout 86400` | 上游单场景超时为 86400 秒 |
| `--batch` | 使用上游多线程批量查询口径 |
| `--force` | 不复用本次目录中的旧结果 |

不执行参数寻优或额外场景。每个数据集结束后，脚本要求恰好生成一份
ScaNN HDF5 结果；仅有 `run.py` 退出码为 0 不算成功。

### 3. 读取结果并清理

上游原始结果保存在本次任务的
`${PERF_WORK_DIR}/ann-benchmarks/results/<数据集>/10/scann/*.hdf5`。
脚本逐一校验五份结果、复制到 `${RESULTS_DIR}/ann-benchmarks-results/`，
再生成 `${RESULTS_DIR}/benchmark_scann.json`。运行中的控制台输出同时写入
`${RESULTS_DIR}/ann-benchmarks-logs/<数据集>.log`；单项日志逐行刷新。
`stop` 阶段只移除本次私有镜像 tag，上游临时容器由 `run.py` 自行移除。

## 指标与产物

每个数据集的原始结果由上游写在 `results/<数据集>/10/scann/*.hdf5`。解析器读取这份文件的属性，并生成以下五项指标：

| 指标 | 原始结果来源或计算方式 | 单位 | 方向 |
|---|---|---|---|
| Recall@10 | 返回的 10 个距离与数据集真值第 10 个距离比较，容差 `1e-3` | ratio | 越大越好 |
| QPS | `1 / best_search_time` | queries/s | 越大越好 |
| 建索引时间 | `build_time` | s | 越小越好 |
| 平均候选数 | `candidates` | count | 仅展示 |
| 索引内存增量 | `index_size` | kB | 仅展示 |

五个数据集各五项，共 **25 项**。Recall@10 使用上游 `plot.py` 的
`k-nn` 规则（第 10 个真值距离加 `1e-3`），QPS 使用相同的
`1 / best_search_time` 公式；报告不生成图像。上游 batch 实现将整批耗时
平均分摊到每条 `times`，没有真实的逐条延迟，所以不将这些数值报告为
P50/P95/P99/P99.9。

报告按数据集分组，跨架构只配对同名指标。解析前要求原始结果满足：

- 算法为 ScaNN，`count=10`，`run_count=1`，`batch_mode=true`；
- 查询数和结果形状与对应数据集一致，数值有效；
- 五个数据集全部完成，且两架构使用相同参数和同名数据文件的 SHA-256。

任何一项不满足即测试失败，不输出部分成功报告。两架构的 CPU 数由各自机器
决定，不强行固定；因此这里比较的是同一 batch 配置下的整机结果。

| 产物 | 内容 |
|---|---|
| `ann-benchmarks-results/<数据集>/` | 五个上游原始 HDF5 结果 |
| `ann-benchmarks-logs/<数据集>.log` | 五个上游 `run.py` 控制台日志 |
| `benchmark_scann.json` | 25 项结构化指标、数据 SHA-256 和测试参数 |
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
