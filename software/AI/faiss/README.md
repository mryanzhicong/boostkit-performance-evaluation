# Faiss 性能测试

支持版本：`1.14.2`、`1.14.3`，默认 `1.14.3`。脚本入口为 `faiss_test.sh`，Framework 阶段函数见 `case.yaml`。

## 构建与安装

脚本只在缺依赖时用 `dnf` 安装构建命令，`PERF_PROXY` 非空时传给 dnf 的 `proxy` 选项。NumPy 2.4.6 和 setuptools 80.9.0 安装到本次任务的 `python-dependencies`，不会安装系统级 Faiss。

从 [Faiss 官方仓库](https://github.com/facebookresearch/faiss)浅克隆版本标签，构建目录位于 `PERF_WORK_DIR/faiss-build`。核心命令：

```bash
git clone --branch v1.14.3 --depth 1 https://github.com/facebookresearch/faiss.git faiss-source
cmake -B faiss-build -S faiss-source -DFAISS_ENABLE_GPU=OFF -DFAISS_ENABLE_PYTHON=ON -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE="$(command -v python3)"
make -C faiss-build -j"$(nproc)" faiss
make -C faiss-build -j"$(nproc)" swigfaiss
```

脚本还构建 Python 绑定，并通过导入的 Faiss 版本校验请求版本。所有源码、构建和依赖文件均留在本次隔离工作目录中。

## 测试与指标

`test` 阶段依次运行 `python3 scripts/benchmark_ann.py` 和 `python3 scripts/benchmark_micro.py`。默认生成固定随机种子数据：10 万条、128 维，K=10，重复 1 次；脚本顶部的 `DATA_SCALE`、`DATA_DIM`、`ITERATIONS`、`K` 控制规模。

ANN 测试覆盖 IndexFlatL2、IndexIVFFlat、IndexHNSWFlat。必需产物 `benchmark_ann.json` 和 `benchmark_micro.json` 位于 `RESULTS_DIR`；报告从前者提取每类索引的构建时间（s，越低越好）、查询吞吐量（queries/s，越高越好）、单次查询延迟（µs，越低越好）和 recall@K（比例，越高越好）。微测试原始结果保留在后者，不作为跨架构比较指标。

独立运行示例：

```bash
bash software/AI/faiss/faiss_test.sh --version 1.14.3 --results-dir /home/runner/faiss-results
```
