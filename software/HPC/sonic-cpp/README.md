# sonic-cpp 性能测试

版本 `1.0.2`。入口 `sonic_cpp_test.sh`；四阶段函数和产物声明见 `case.yaml`。

## 构建

脚本从 [sonic-cpp 官方仓库](https://github.com/bytedance/sonic-cpp)浅克隆 `v1.0.2`，在本次任务的 `PERF_WORK_DIR` 下构建官方 `bench` 目标。缺少基础命令时用 `dnf` 安装；`PERF_PROXY` 非空时用于 dnf 代理。

```bash
git clone --branch v1.0.2 --depth 1 https://github.com/bytedance/sonic-cpp.git sonic-source
cmake -S sonic-source -B sonic-build -DBUILD_BENCH=ON
cmake --build sonic-build --target bench -j
```

脚本核对克隆标签，必要时修正依赖的 gflags 分支引用；构建产物是隔离工作区中的 `benchmark/bench`，不安装到系统。

## 测试与指标

`test` 阶段运行官方 Google Benchmark 程序，重复 5 次并只报告聚合统计：

```bash
./benchmark/bench --benchmark_out_format=json --benchmark_out=<结果目录>/benchmark.json --benchmark_repetitions=5 --benchmark_report_aggregates_only=true
```

`scripts/parse_benchmark.py` 将官方 JSON 归一化为 `benchmark_sonic_cpp.json`。两个 JSON 均为必需产物；报告按官方 benchmark 名称展示耗时（ns，越低越好），保留具体场景，不合成总分。

独立运行：

```bash
bash software/HPC/sonic-cpp/sonic_cpp_test.sh --version 1.0.2 --results-dir /home/runner/sonic-cpp-results
```
