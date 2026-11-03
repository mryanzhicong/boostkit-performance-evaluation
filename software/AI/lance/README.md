# Lance 13.0.0 SIFT-1M 性能测试

本用例在 x86_64、aarch64 上使用同一个上游 Lance `v13.0.0` 标签。构建和测试都在本次任务的 openEuler 24.03 LTS SP4 私有容器内进行；不限制容器 CPU、内存，不绑核，也不添加架构专用编译特性。测试采用 [上游 `benchmarks/sift`](https://github.com/lance-format/lance/tree/v13.0.0/benchmarks/sift) 的 IVF-PQ 索引与 `metrics.py` 查询矩阵。

软件入口为 `lance_test.sh`；Framework 按 `case.yaml` 调用 `scripts/builders/dispatch.sh` 和 `scripts/stages/`。`base` 构建上游原版；`optimized` 尚未实现，选择后明确失败，不会回退到基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Lance Python 扩展 | [上游源码](https://github.com/lance-format/lance/tree/v13.0.0) `v13.0.0`，用 Maturin 的 release 模式编译 | `${PERF_WORK_DIR}/lance-13.0.0`；私有 Python 环境 `${PERF_WORK_DIR}/venv` |
| SIFT 测试脚本 | 同一上游标签的 `benchmarks/sift/index.py`、`metrics.py` | 上游源码目录内，不修改 |
| SIFT-1M 数据 | [TexMex SIFT](http://corpus-texmex.irisa.fr/) 的 `sift.tar.gz` | 优先读取 `/home/runner/software/lance/sift.tar.gz`，否则下载到 `${PERF_WORK_DIR}` |
| 容器镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载 |

## 构建与容器

脚本读取 `openEuler-docker.<架构>.tar.xz` 和对应 `.sha256sum`，校验后执行 `docker load --input "${ARCHIVE}"`，再核对镜像架构与容器内系统版本。`${LANCE_CONTAINER_IMAGE}` 是实际加载出的镜像名，不从 Docker Hub 拉取。容器名为 `boostkit-lance-<架构>-<运行 ID>`。`${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 以原路径挂载，使用当前 Runner 用户的 UID/GID 和宿主机网络；不限制 CPU 或内存，也不向宿主机安装 Lance、Rust 或 Python 包。

Runner 上存在 `/home/runner/.gitconfig` 时，脚本将它只读挂载到容器内同一路径，
并设置 `GIT_CONFIG_GLOBAL=/home/runner/.gitconfig`，使容器内的 Git 读取该配置。
文件不存在时跳过挂载和环境变量，继续使用容器内默认的 Git 配置；
不会修改宿主机配置。

如果正式工作流设置 `PERF_PROXY`，容器会只读挂载 `/home/runner/software/anchors/` 到容器信任库，运行 `update-ca-trust extract`，并在容器的 `dnf` 中使用该代理。容器内的 openEuler 仓库地址改为 `repo.huaweicloud.com/openeuler`；这些修改不触及宿主机。无代理时不挂载证书，也不为命令设置代理。Runner 必须能够访问 Docker daemon。

下面是同时存在代理证书和 `/home/runner/.gitconfig` 时的容器启动命令形态；
没有代理时去掉证书目录的 `--mount` 和证书更新命令，没有 Git 配置文件时去掉
对应的 `--mount`。`${LANCE_CA_ANCHORS_DIR}` 默认是 `/home/runner/software/anchors`，
`${LANCE_CONTAINER_IMAGE}` 来自上面的 `docker load`：

```bash
docker run --detach --name "${LANCE_CONTAINER_NAME}" \
  --label "boostkit.lance.run-id=${PERF_RUN_ID}" --network=host \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount "type=bind,source=${LANCE_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly" \
  "${LANCE_CONTAINER_IMAGE}" sleep infinity

docker exec --user 0 "${LANCE_CONTAINER_NAME}" update-ca-trust extract
docker exec --user 0 "${LANCE_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
```

脚本只在该容器存在 `/etc/yum.repos.d/openEuler.repo` 时执行上述换源命令。随后用 `docker exec --user 0` 在容器内安装系统依赖，再用 `docker exec` 以 Runner 的 UID/GID 构建和测试。执行结束后先 `docker stop`，再 `docker rm`；删除前核对 `boostkit.lance.run-id` 与本次运行 ID 一致。宿主机挂载的工作目录和结果目录不会随容器删除。

基础版的关键命令形态如下，均在私有容器中执行：

```bash
dnf install -y gcc gcc-c++ make cmake pkgconf-pkg-config openssl-devel \
  python3 python3-devel python3-pip tar gzip curl ca-certificates git zlib-devel
git clone --depth 1 --branch v13.0.0 \
  https://github.com/lance-format/lance.git "${PERF_WORK_DIR}/lance-13.0.0"
python3 -m venv "${PERF_WORK_DIR}/venv"
"${PERF_WORK_DIR}/venv/bin/python" -m pip install --upgrade pip maturin
"${PERF_WORK_DIR}/venv/bin/python" -m pip install \
  'numpy>=1.22' 'pyarrow>=14' pandas ml_dtypes 'torch>=2.0'
curl -fSL https://rsproxy.cn/rustup-init.sh -o "${PERF_WORK_DIR}/rustup-init.sh"
sh "${PERF_WORK_DIR}/rustup-init.sh" -y --no-modify-path \
  --profile minimal --default-toolchain none
# 从上游 rust-toolchain.toml 读取 channel（v13.0.0 为 1.98.1）。
"${PERF_WORK_DIR}/cargo/bin/rustup" toolchain install 1.98.1 --profile minimal
cd "${PERF_WORK_DIR}/lance-13.0.0/python"
"${PERF_WORK_DIR}/venv/bin/maturin" develop --release
```

实际脚本还设置私有 `CARGO_HOME`、`RUSTUP_HOME`，使 Rust 工具链及编译缓存留在 `${PERF_WORK_DIR}`。`--no-modify-path` 阻止安装器修改容器内 `/home/runner/.profile`；构建命令会自行把私有 Cargo 目录加入 `PATH`。脚本从上游 `rust-toolchain.toml` 读取版本，显式安装并检查 `rustc --version`，成功后才调用 Maturin；工具链下载失败会停在该步骤并显示 rustup 的原始错误，而不是只显示 Maturin 的概括性报错。不启用额外的 `fp16kernels`、GPU 或架构专用选项。构建后检查 `pylance` 的实际版本为 `13.0.0`，记录上游提交到 `source-commit.txt`，并将实际 Python 依赖版本写入 `python-dependencies.txt`。

Rust 下载使用 [RsProxy](https://rsproxy.cn/)：容器内执行命令时固定设置
`RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup`、`RUSTUP_DIST_SERVER=https://rsproxy.cn`，
分别供 rustup 安装器和上游指定的工具链下载使用。脚本在本次私有目录
`${PERF_WORK_DIR}/cargo/config.toml` 写入以下 Cargo 稀疏索引配置，供依赖下载使用：

```toml
[source.crates-io]
replace-with = "rsproxy-sparse"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"

[net]
git-fetch-with-cli = true
```

以上配置不写入 Runner 宿主机，也不修改上游 Lance 源码；若 Runner 需要企业代理，
原有 `PERF_PROXY` 仍会传给容器内下载命令。GitHub 源码克隆不经过 Rust 镜像。

容器内所有 `pip` 命令默认使用华为云 PyPI 镜像 `https://repo.huaweicloud.com/repository/pypi/simple`，缓存位于本次任务的 `${PERF_WORK_DIR}/pip-cache`。如需指定其他 PyPI 源，在启动前设置 `LANCE_PYPI_INDEX_URL`。该设置仅影响 Python 包下载；Rust 和 Cargo 使用上面的固定镜像。

## 数据准备与测试

本地 `sift.tar.gz` 是优先来源。缺失时脚本先尝试 TexMex HTTPS 地址，失败后尝试上游文档给出的 FTP 地址。下载文件只存于本任务私有目录。解压前检查归档路径，并核对 `sift_base.fvecs` 与 `sift_query.fvecs`。脚本记录两个原始文件的 SHA-256；跨架构汇总要求它们相同。

`prepare_sift.py` 按 TexMex `.fvecs` 的逐记录维度头读取 100 万条 128 维底库向量和 1000 条查询向量，然后调用上游 `lance.write_dataset` 生成 `sift1m.lance`、`sift_query.lance`。没有直接调用仓库的 `datagen.py`：它只跳过文件开头的一个维度头，后续记录的维度头会被当作向量值。写入时沿用上游的 `max_rows_per_group=8192` 和 `max_rows_per_file=1048576`，避免解析修正之外再引入存储布局差异。不修改上游 Lance 或 `index.py`、`metrics.py` 的测试逻辑。

正式命令在上游 `benchmarks/sift` 目录执行：

```bash
python index.py "${PERF_WORK_DIR}/data/sift1m.lance" -i 256 -p 16 -c vector
python metrics.py "${PERF_WORK_DIR}/data/sift1m.lance" \
  "${RESULTS_DIR}/benchmark_sift.csv" -i 256 -p 16 -s 1000 \
  -q "${PERF_WORK_DIR}/data/sift_query.lance" -k 1
```

`metrics.py` 使用上游固定的 6 个 `nprobes` 值（1、10、25、50、75、100）和 7 个 `refine_factor` 值（无、1、10、20、30、40、50），共 42 个场景；每个场景查询 1000 个向量，计算 `Recall@1` 和平均查询时间。索引建立与真值计算是测试准备，不计入查询时间。上游脚本对这 42 个场景各执行一次，当前用例不额外重复或筛选结果。

### 与上游示例的差异

| 差异 | 当前做法与原因 |
|---|---|
| 源码版本 | 你提供的链接指向会持续更新的 `main`；固定同一仓库的 `v13.0.0`，使两架构构建相同版本。 |
| 测试范围 | 上游示例还包含 GIST-1M；这里只选择 SIFT-1M，避免把不同数据集混入同一测试口径。 |
| 数据转换 | 用 `prepare_sift.py` 代替上游 `datagen.py`，因为 `.fvecs` 的每条向量都有维度头，而上游脚本只跳过首条维度头。保留原始向量值、`id`/`vector` 字段及上游写入布局参数。由此得到的数据不同于直接运行上游 `datagen.py` 的结果，不能与后者产生的性能数字直接比较。 |
| 真值文件 | 上游示例单独运行 `gt.py`；本用例不生成该文件，因为实际执行的原版 `metrics.py` 会自行计算真值，且不读取 `gt.py` 的输出。 |
| 执行环境 | 在每次任务的私有容器中构建、测试，隔离两台 Runner 的软件依赖；不修改被测 Lance 源码。 |
| 结果整理 | 原版 `metrics.py` 的 CSV 完整保留；额外解析为 Framework 使用的 JSON，校验 42 个场景，便于两架构按同名指标比较。 |

索引和查询仍执行 `v13.0.0` 的原版 `index.py`、`metrics.py`；命令中的 `-c vector`、`-s 1000` 是显式写出上游默认值，不改变上游示例的索引与查询参数。

## 结果与报告

| 结果 | 位置 | 用途 |
|---|---|---|
| 上游 CSV | `${RESULTS_DIR}/benchmark_sift.csv` | 保留 `metrics.py` 的全部 42 行原始结果 |
| 原始日志 | `${RESULTS_DIR}/benchmark_sift.log` | 索引构建和查询过程输出 |
| 归一化指标 | `${RESULTS_DIR}/benchmark_lance.json` | 84 条指标，供 Framework 的单架构和跨架构报告读取 |
| 数据身份 | `benchmark_lance.json` 的 `parameters` | 原始数据 SHA-256、向量数、维度和完整测试参数 |

每个场景分别报告 `recall_at_1`（比例，越高越好）与 `mean_query_time`（秒/查询，越低越好）。解析器校验 CSV 必须恰好包含 42 个不重复场景，且值为有效数；缺失任意场景即失败，不会把不完整数据标成成功。

## 独立执行

在仓库根目录运行；Runner 需具备 Docker 权限，测试期间保留足够的磁盘与内存空间：

```bash
bash software/AI/lance/lance_test.sh \
  --version 13.0.0 --variant base \
  --results-dir /home/runner/lance-results
```

独立入口依次构建、检查、测试、停止容器，并在结果目录写出 `results.json`、`status.json` 和 `report.md`。数据与构建目录默认位于 `/home/runner/boostkit-perf/lance/local-<运行 ID>/`；正常结束后清理该私有目录。需要检查源码或中间数据时添加 `--keep-workdir`。Framework 分阶段调用时，目录由 Framework 分配，脚本不会清理 Framework 管理的目录。
