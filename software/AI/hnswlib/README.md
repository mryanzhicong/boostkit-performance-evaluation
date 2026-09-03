# hnswlib 性能测试

本目录适配官方 [nmslib/hnswlib](https://github.com/nmslib/hnswlib) 的 Python 接口开箱性能测试。当前支持 `0.7.0`、`0.8.0` 和 `0.9.0`；默认版本为 `0.8.0`。

## 构建与安装

`build` 阶段从官方仓库克隆请求版本的精确 tag，例如 `v0.8.0`，并验证 tag。缺失的系统依赖由脚本使用 `dnf` 自动安装：`git`、`gcc-c++`、`python3`、`python3-pip`、`python3-devel` 及基础命令。

Python 构建依赖安装到本次任务私有目录；非 Ubuntu Runner 使用华为云 PyPI 源。固定依赖为：

```text
numpy==2.4.6
setuptools==80.9.0
pybind11==2.13.6
wheel==0.45.1
h5py==3.16.0
```

hnswlib 从已校验的源码安装到任务私有目录，核心安装命令为：

```bash
python3 -m pip install \
  --no-cache-dir --no-build-isolation --no-deps \
  --target <任务目录>/hnswlib-install \
  <hnswlib-源码目录>
```

安装后执行 `import hnswlib, numpy`，并读取包元数据校验实际版本。源码、安装目录、Python 依赖、临时文件和缓存均位于本次任务的私有工作目录。

## 性能测试

`test` 阶段参考鲲鹏 hnswlib 性能用例采用的五个数据集，使用 [ANN-Benchmarks](https://github.com/erikbern/ann-benchmarks) 提供的标准 HDF5 文件，在两种架构上现场执行上游 hnswlib FP32 接口。

数据文件位于本次任务的 `${PERF_WORK_DIR}/data/`；缺失时从 `https://ann-benchmarks.com/<dataset>.hdf5` 下载并保存到该目录。数据目录位于 `/home/runner/boostkit-perf/hnswlib/`，不使用 `/tmp`。

固定测试配置为 HNSW `M=16`、`ef_construction=60`、64 个构建线程、`ef_search=15`、单个查询线程、`k=10`，每个数据集完整查询三轮并取平均 QPS。每个数据集均使用其随 HDF5 文件发布的 top-100 ground truth，按 top-10 计算实际 recall。

| 数据集 | HDF5 文件 | 距离空间 |
|---|---|---|
| Fashion-MNIST | `fashion-mnist-784-euclidean.hdf5` | Euclidean |
| GIST | `gist-960-euclidean.hdf5` | Euclidean |
| SIFT | `sift-128-euclidean.hdf5` | Euclidean |
| GloVe-100 | `glove-100-angular.hdf5` | Angular / cosine |
| DEEP1B | `deep-image-96-angular.hdf5` | Angular / cosine |

每个数据集在报告中独立成表，包含：

| 指标 | 含义 | 优化方向 |
|---|---|---|
| `construction_time` | HNSW 索引构建耗时 | 越小越好 |
| `qps` | 三轮完整查询的平均 QPS | 越大越好 |
| `recall` | top-10 召回率 | 越大越好 |

缺少数据集字段、维度不一致、查询无结果、QPS 无效或召回率超出 `0` 到 `1` 都会使测试失败。

## 结果与独立执行

原始执行输出保存为 `hnswlib_ann_raw.log`，规范化指标保存为 `benchmark_hnswlib.json`。

可脱离 Workflow 执行完整流程：

```bash
cd software/AI/hnswlib
bash hnswlib_test.sh --version 0.8.0
```

默认结果目录为 `results/<版本>/<run-id>/`。排障时可保留任务私有工作目录：

```bash
bash hnswlib_test.sh --version 0.8.0 --keep-workdir
```
