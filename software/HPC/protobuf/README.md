# Protobuf 性能测试

软件版本 `35.1`，测试所需 Python protobuf 版本 `7.35.1`。入口为 `protobuf_test.sh`，阶段函数及产物见 `case.yaml`。

## 构建与安装

脚本从 [Protocol Buffers 官方仓库](https://github.com/protocolbuffers/protobuf)浅克隆 `v35.1`。缺少命令时使用 `dnf` 安装，`PERF_PROXY` 非空时用于 dnf 代理。构建和安装都在 `PERF_WORK_DIR`：

```bash
git clone --branch v35.1 --depth 1 https://github.com/protocolbuffers/protobuf.git protobuf-source
cmake -S protobuf-source -B protobuf-build -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=<本次任务安装目录>
make -C protobuf-build -j"$(nproc)"
make -C protobuf-build install
```

脚本用私有 `protoc --version` 核对版本；再用 `python3 -m pip install 'protobuf==7.35.1'` 准备 Python 测试环境。

## 测试与指标

`test` 阶段依次运行 `scripts/benchmark_ann.py` 和 `scripts/micro_benchmark.py`，最后由 `scripts/aggregate_results.py` 校验并汇总。必需结果是 `RESULTS_DIR/benchmark_ann.json`、`micro_benchmark.json` 和 `aggregate_results.json`。

场景包括序列化、反序列化、JSON 转换、消息大小变化及 1/2/4/8 线程；报告从 `aggregate_results.json.metrics` 提取原始吞吐量与延迟，单位和优化方向由每个指标记录给出，不跨操作汇总。

独立运行：

```bash
bash software/HPC/protobuf/protobuf_test.sh --version 35.1 --results-dir /home/runner/protobuf-results
```
