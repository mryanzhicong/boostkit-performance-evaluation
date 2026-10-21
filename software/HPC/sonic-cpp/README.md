# sonic-cpp 性能测试

源码固定为上游提交 `69deb02c099361139dd387eb6c7034a4836ce9b3`（简称 `69deb02`）。构建和测试参考
[BoostKit 快速入门](https://atomgit.com/boostkit/sonic-cpp/blob/master/docs/zh/quick_start.md)，
使用 sonic-cpp 自带的 `benchmark/bench`。软件入口为 `sonic_cpp_test.sh`；Framework 通过
`case.yaml` 分别调用构建、启动、测试和停止脚本。直接执行入口脚本也使用这些阶段函数。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 完整构建；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，
不会退回基础版。启动、测试和停止阶段共用 `scripts/stages/` 下的脚本。
`scripts/common.sh` 提供阶段间一致的私有路径约定，结果解析位于 `scripts/results/`。

当前清单仅声明 `69deb02` 一个版本，且上游以提交号为准；新增版本时必须确认上游
提交存在，并保持两种架构使用相同的源码提交和构建选项。

## 构建

脚本将源码克隆到本次任务的私有 `PERF_WORK_DIR/sonic-cpp-source`，检出并核验
`69deb02`，然后构建 benchmark；不会安装或修改系统中的 sonic-cpp。缺少基础构建
命令时使用 `dnf` 安装。

```bash
git clone https://github.com/bytedance/sonic-cpp.git sonic-cpp-source
git -C sonic-cpp-source checkout --detach 69deb02
cmake -S sonic-cpp-source -B build -DBUILD_BENCH=ON
cmake --build build --target bench -j
```

产物是 `build/benchmark/bench`。以上路径由脚本放在本次任务的私有工作目录下。x86_64 和
aarch64 均使用同一提交、同一构建选项；不应用鲲鹏 950 专用补丁，不启用 `ENABLE_SVE2_256`。

## 测试与指标

`test` 阶段在源码目录运行参考文档的 Sonic 场景，最短测量时间为每项 3 秒，不绑核。脚本
额外要求 Google Benchmark 写出 JSON，供 Framework 收集和校验：

```bash
build/benchmark/bench \
  --benchmark_filter=Sonic \
  --benchmark_min_time=3s \
  --benchmark_out_format=json \
  --benchmark_out=<结果目录>/benchmark.json
```

`scripts/results/parse_benchmark.py` 将 JSON 中每项 Sonic 测量的 `cpu_time` 统一换算为
ns，保留原始场景名称、数值和单位，写入 `benchmark_sonic_cpp.json`。报告逐项比较耗时
（越低越好），不计算合成总分。若没有 Sonic 测量、出现重复场景或混入非 Sonic 场景，
测试失败。两个 JSON 都是必需产物。

## 独立运行

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop 并保存相同的
产物。例如：

```bash
bash software/HPC/sonic-cpp/sonic_cpp_test.sh \
  --version 69deb02 --variant base \
  --results-dir /home/runner/boostkit-perf/sonic-cpp/results/69deb02
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`。两种模式应使用不同的
`--results-dir`；不指定时，基础版保留现有结果路径，调优版位于该版本下的 `optimized/`
子目录。目前调优版只验证入口与明确失败行为，不执行性能测试。

正式工作流中基础版的 OBS 与 `performance-results` 路径不变；调优版归档到
`HPC/sonic-cpp/69deb02/optimized/<时间戳_Run ID>/`。两种模式的测试负载和指标解析共用，
构建阶段保存 `build_variant.json` 以标识实际选择。调优版不会更新基础版的
`baseline.json`。
