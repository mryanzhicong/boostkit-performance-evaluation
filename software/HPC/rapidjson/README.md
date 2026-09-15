# RapidJSON 性能测试说明

本目录从 RapidJSON 官方仓库（github.com/Tencent/rapidjson）克隆 `v1.1.0` 标签源码（项目最新
release），使用源码树自带的官方 `test/perftest` 性能测试套件构建并执行基准。Framework 通过
`case.yaml` 调用 `rapidjson_test.sh` 的四阶段接口；直接执行入口脚本会走同一流程。

当前清单支持 `1.1.0`，默认版本 `1.1.0`。

## 构建与安装

RapidJSON 是 header-only 库，无需安装任何系统级组件。脚本从官方 GitHub 标签浅克隆
（`git clone --branch v1.1.0 --depth 1`），以 `git describe --tags --exact-match` 校验标签
精确匹配，并读取上游 `CMakeLists.txt` 的 `LIB_MAJOR/MINOR/PATCH_VERSION`（组成 1.1.0）与请求
版本交叉验证。脚本检查 `git`、`python3`、`cmake`（≥ 3.5）、`make`、`g++`（≥ 5）和 `tee`，缺失时
报错退出，不做系统安装。

官方 perftest 由 googletest 驱动，gtest 为上游仓库 `.gitmodules` 固定的官方 submodule
（`thirdparty/gtest`，googletest release-1.8.0 前的 pinned commit），构建前执行
`git submodule update --init` 拉取，不使用系统 gtest。

构建命令（官方 CMake 目标 `perftest`）：

```bash
cmake -S rapidjson-source -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DRAPIDJSON_BUILD_DOC=OFF \
  -DRAPIDJSON_BUILD_EXAMPLES=OFF \
  -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=ON \
  -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -Wno-error"
cmake --build build --target perftest
```

对官方构建口径的两处适配说明：

1. **`-Wno-error`**：上游 v1.1.0（2016 年）的官方 CI 编译选项含 `-Wall -Wextra -Werror`（由
   CMakeLists 追加，同时含 `-march=native`，均保留）。GCC 7/8 新增的警告类别
   （`-Wimplicit-fallthrough`、`-Wformat-overflow`、`-Wclass-memaccess`）在 2016 年的编译器上
   不存在，会在 v1.1.0 源码上触发 `-Werror` 编译失败。`-Wno-error` 经
   `CMAKE_CXX_FLAGS_RELEASE` 传入（位于追加的 `-Werror` 之后，按编译器选项顺序生效），仅解除
   报错阻断，不改变优化级别（Release `-O3 -DNDEBUG`）与生成代码；警告本身仍打印在构建日志中。
2. **`RAPIDJSON_BUILD_THIRDPARTY_GTEST=ON`**：上游 `FindGTestSrc` 默认将系统 `/usr/src/gtest`
   置于搜索路径中 submodule 之前；该选项将 submodule 优先，保证使用官方 pinned 的 gtest 构建，
   与运行环境无关。`DOC`/`EXAMPLES` 关闭为构建裁剪（doxygen 文档与示例程序与基准无关）。

## 测试数据与性能测试

`start` 阶段在官方数据目录（上游 ctest 注册的 `WORKING_DIRECTORY`，即源码树 `bin/`）冒烟运行
一个跨架构名称稳定的官方测试 `RapidJson.SkipWhitespace_Basic`，校验其通过且报告耗时。

`test` 阶段在 `bin/` 目录下以框架自带参数 `--gtest_repeat=5` 运行官方 perftest 全量测试 5 轮，
共 51 个测试：

| 测试组 | 覆盖内容 | 循环次数 |
|---|---|---:|
| `RapidJson.ReaderParse*`（24 个） | SAX 解析：普通/insitu/迭代/全精度/编码校验 × 官方 `bin/data/sample.json`（687 KiB）；另含 7 类单类型语料（booleans/floats/guids/integers/mixed/nulls/paragraphs，来自 `bin/types/`）与文件流变体 | 1000（类型语料 10000） |
| `RapidJson.DocumentParse*`（9 个） | DOM 解析：MemoryPool/Crt 分配器、insitu、迭代、定长、std::string、EncodedInputStream/AutoUTFInputStream | 1000 |
| `RapidJson.DocumentTraverse/DocumentAccept` | DOM 遍历（成员迭代 / Accept 访问者） | 1000 |
| `RapidJson.Writer*/StringBuffer`（11 个） | 序列化：Writer/PrettyWriter 到 StringBuffer/NullStream（含 7 类类型语料变体）与 StringBuffer 微基准 | 1000（类型语料 10000） |
| `RapidJson.SkipWhitespace*/UTF8_Validate/internal_Pow10/FileReadStream` | 空白跳过（含 strspn 对照）、UTF-8 校验、Pow10、文件流读取 | 1000（Pow10 10^6） |
| `Schema.TestSuite` | JSON Schema draft-4 校验，官方 `bin/jsonschema/tests/draft4/` 语料 | 100000 |

googletest 为每个测试输出一行 wall-clock 耗时（`[ OK ] Suite.Test (N ms)`）。任一测试 FAILED、
样本数与轮数不符、与 `--gtest_list_tests` 官方测试清单比对缺失项、或出现非正耗时时测试失败。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/rapidjson/rapidjson_test.sh \
  --version 1.1.0 \
  --results-dir /home/runner/boostkit-perf/rapidjson/results/1.1.0
```

## 指标

每个官方测试一个指标（`<Suite>.<Test>` 形态，共 51 个），取 5 轮耗时的中位数（`median_ms`），
单位 ms，越小越好；每轮原始耗时保存在 `samples_ms`。x86 上套件按 `-march=native` 探测结果为
SIMD 测试名追加 `_SSE42`/`_SSE2` 后缀（v1.1.0 无 ARM NEON 路径，aarch64 上为无后缀名）；采集侧
统一剥离该后缀以保证跨架构指标名一致，后缀本身保留在各结果的 `simd_suffix` 字段。

## 结果与清理

必需产物为 `benchmark_perftest.json`，包含 51 组结构化结果、逐轮耗时、原始输出以及构建与数据
参数信息。没有后台服务需要停止；任务结束只删除本次运行的源码、构建目录和临时文件（限
`/home/runner/boostkit-perf/rapidjson/local-*`）。
