# simdjson 性能测试说明

本目录从 simdjson 官方仓库（github.com/simdjson/simdjson）克隆 `v4.6.11` 标签源码（项目最新
release），使用源码树自带的官方 Google Benchmark 套件构建并执行基准。Framework 通过
`case.yaml` 调用 `simdjson_test.sh` 的四阶段接口；直接执行入口脚本会走同一流程。

当前清单支持 `4.6.11`，默认版本 `4.6.11`。

## 构建与安装

simdjson 从官方 GitHub 标签浅克隆（`git clone --branch v4.6.11 --depth 1`），以
`git describe --tags --exact-match` 校验标签精确匹配，并读取官方头文件
`include/simdjson/simdjson_version.h` 的 `SIMDJSON_VERSION` 宏（"4.6.11"）与请求版本交叉验证。
脚本检查 `git`、`python3`、`cmake`（≥ 3.14）、`make`、`g++`（≥ 7，源码需 C++17）和 `tee`，缺失时
报错退出，不做系统安装。

基准框架与语料均由官方 CMake 在 configure 阶段经 CPM 从上游 CMakeLists.txt 中固定的 URL 下载：
google/benchmark **v1.9.5**（官方依赖清单固定 tag 的 zip）与 simdjson-data 官方语料仓库（固定到
精确 commit `351949906abd...` 的 zip——commit 固定即内容固定，等价于其他用例对 tarball 的
SHA-256 校验）。语料含 twitter.json、gsoc-2018.json、numbers.json。configure 阶段需要网络访问。

构建命令（官方 CMake 目标，源码零修改）：

```bash
cmake -S simdjson-source -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DSIMDJSON_DEVELOPER_MODE=ON \
  -DSIMDJSON_COMPETITION=OFF \
  -DSIMDJSON_GOOGLE_BENCHMARKS=ON
cmake --build build --target bench_parse_call bench_dom_api
```

对官方构建口径的 CMake 开关选择说明（均为上游定义的开关，非代码改动）：

1. **`SIMDJSON_DEVELOPER_MODE=ON`**：上游 CMake 在该开关关闭时只构建库本身（configure 输出明示
   "Building only the library"），benchmark/tests/tools 目标全部跳过；开启它是构建官方基准目标的
   官方途径。
2. **`SIMDJSON_COMPETITION=OFF`**：跳过可选竞品库（yyjson、rapidjson、sajson 等）的下载与构建。
   该链条服务于对比基准 `bench_ondemand`（json2msgpack 跨库对比），本用例测 simdjson 本身，
   `bench_ondemand` 不在范围内。
3. **`SIMDJSON_GOOGLE_BENCHMARKS=ON`**：即官方默认（允许下载时），获取 google/benchmark v1.9.5。

## 测试数据与性能测试

`start` 阶段分别冒烟运行 `bench_parse_call --benchmark_filter=unicode_validate_twitter` 与
`bench_dom_api --benchmark_filter=twitter_count`（各 2 次重复），校验退出码与输出。

`test` 阶段以 google-benchmark 官方 CLI 运行两个套件全量测试（`--benchmark_repetitions=10
--benchmark_report_aggregates_only=true --benchmark_format=json`，与上游吞吐测试源码级
`->Repetitions(10)` 一致），共 33 个官方测试：

| 套件 | 覆盖内容 | 测试数 |
|---|---|---:|
| `bench_parse_call` | twitter.json/gsoc-2018.json 的 DOM 解析、minify、UTF-8 校验吞吐（官方 Gigabytes/docs 速率计数器），空文档 error_code/exception 四条错误路径微基准 | 9 |
| `bench_dom_api` | DOM 序列化（minify/to_string/string_builder，含 Gigabytes 计数器）、元素恢复、numbers.json 扫描（error_code/exception/type/load 变体）、twitter.json 元素访问任务（两种 API 风格）、代理对解析 | 24 |

采集器从 JSON 输出提取每个测试的 **median cpu_time**（10 次重复取中位数），统一换算为 ns（越小
越好）；官方 `Gigabytes`/`docs` 速率计数器按测试保留在 `gigabytes_per_s`/`docs_per_s` 字段作为
上下文（如本机 x86 验证运行中 parse_twitter ≈ 2.9 GB/s、fast_minify_twitter ≈ 7.5 GB/s、
unicode_validate_twitter ≈ 35 GB/s，与 simdjson 公开数据一致）。任一测试 FAILED、与
`--benchmark_list_tests` 官方清单比对缺失、重复数不符或出现非正耗时时测试失败。CLI 重复数驱动
时 google-benchmark 会在测试名后追加 `/repeats:N` 后缀，采集侧剥离以保持官方测试名。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/simdjson/simdjson_test.sh \
  --version 4.6.11 \
  --results-dir /home/runner/boostkit-perf/simdjson/results/4.6.11
```

## 指标

每个官方测试一个指标（`<suite>/<test>` 形态，共 33 个，按套件分组），取 10 次重复的 median
cpu_time（`value`，单位 ns，越小越好）；原始耗时与重复数保存在各结果的 `raw_value`/
`repetitions` 字段。

## 结果与清理

必需产物为 `benchmark_googlebench.json`，包含 33 组结构化结果、官方速率计数器上下文以及构建
与语料参数信息。没有后台服务需要停止；任务结束只删除本次运行的源码、构建目录（含 CPM 下载的
依赖与语料）和临时文件（限 `/home/runner/boostkit-perf/simdjson/local-*`）。
