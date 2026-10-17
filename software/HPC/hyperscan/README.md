# Hyperscan 性能测试说明

本目录从 Hyperscan 官方仓库（github.com/intel/hyperscan）克隆 `v5.4.2.1` 标签源码（项目最终
release），使用源码树自带的官方 `tools/hsbench` 基准工具构建并执行正则匹配性能测试。Framework
通过 `case.yaml` 调用 `hyperscan_test.sh` 的四阶段接口；直接执行入口脚本会走同一流程。

当前清单支持 `5.4.2.1`，默认版本 `5.4.2.1`。tag 第 4 段（`.1`）是 release 修订号，库版本号
为 5.4.2（上游 `CMakeLists.txt` 的 `HS_MAJOR/MINOR/PATCH_VERSION`，构建阶段与 tag 交叉校验）。

## 构建与安装

Hyperscan 从官方 GitHub 标签浅克隆（`git clone --branch v5.4.2.1 --depth 1`），以
`git describe --tags --exact-match` 校验标签精确匹配。脚本检查 `git`、`python3`、`cmake`
（≥ 3.10）、`make`、`g++`（≥ 5，源码需 C++11）、`curl`、`tar`、`unzip` 和 `tee`，并要求 runner
核数 ≥ 16（线程阶梯最大值）。所有依赖构建在任务隔离 prefix 中，不做系统安装。

上游构建链有四个外部依赖，全部从官方渠道按固定版本获取并校验：

| 依赖 | 版本 | 来源与校验 |
|---|---|---|
| ragel | 6.10 | 官方 colm.net tarball，SHA-256 校验（git 树不带 configure，tarball 是官方分发形态） |
| OpenSSL | 3.6.4 | 官方 openssl/openssl git tag `openssl-3.6.4`（clone tag 精确匹配校验） |
| Boost | 1.88.0 | 官方 boostorg/boost GitHub release cmake tarball，4MiB 分块下载逐块校验 + 整体 SHA-256 |
| SQLite | 3.53.4 | 官方 sqlite.org amalgamation zip，官方下载页公布的 SHA3-256 校验（python3 hashlib） |

各依赖的集成方式均为上游 CMake 显式支持的路径：

- **OpenSSL 以 shared 形态构建**：官方 `cmake/build_wrapper.sh`（fat runtime 符号重命名）只豁免
  `libcrypto.so` 的符号——`gcc --print-file-name=libcrypto.so` 找不到共享库时，HMAC/EVP 符号会被
  误加 `avx2_`/`corei7_` 前缀导致链接失败；共享构建是官方 wrapper 预期的依赖形态。运行时通过
  `LD_LIBRARY_PATH` 指向隔离 prefix。
- **Boost headers 聚合**：cmake tarball 为 git submodule 布局（headers 分散于
  `libs/<module>/include/boost`），聚合为单一 include 树后经官方 `BOOST_ROOT` 变量传入。
- **SQLite amalgamation 放源码树 `sqlite3/`**：官方 `cmake/sqlite3.cmake` 的 in-tree 检查路径，
  自动构建 `sqlite3_static` 链入 hsbench。
- ragel 安装到 prefix 后经 `PATH` 供上游 CMake 的 `find_program(RAGEL)` 使用。

构建命令（官方 CMake 目标 `hsbench`，连带构建 hs 库 fat runtime 全部微架构变体）：

```bash
PATH=<prefix>/bin:$PATH cmake -S hyperscan-source -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=<prefix> \
  -DBOOST_ROOT=<boost-include> \
  -DBUILD_EXAMPLES=OFF
cmake --build build --target hsbench
```

## 测试数据与性能测试

`start` 阶段部署固定 50 条表达式集（`src/patterns`，官方 pattern 格式 `<id>:/<regex>/<flags>`，
覆盖 literal、字符类、量词、交替、锚点与 i/s/m 标志组合），并以 python3 语料构造器
（官方 `tools/hsbench/scripts/CorpusBuilder.py` 的 python3 等价实现——官方脚本为 python2 语法，
schema（`chunk` 表 + `stream_id` 索引 + vacuum/analyze）与后处理完全一致）从源码树固定文本文件集
（`src/**` 源码、`doc/dev-reference/*.rst`、`examples/*.c|.cc`、`CHANGELOG.md`，tag 固定即内容
固定，约 6.6MB）构造语料数据库：每个输入文件一个 stream，按行对齐切分为 ≤16KiB 块。构造后
冒烟运行 streaming/1 线程/1 次重复场景，校验输出含总吞吐行。

`test` 阶段运行官方 hsbench 的 2 模式 × 3 线程共 6 个场景：

| 场景 | 官方参数 |
|---|---|
| `streaming_t1/t4/t16` | （默认流模式）`-T 0` / `-T 0-3` / `-T 0-15` |
| `block_t1/t4/t16` | `-N` + 同上线程参数 |

每场景按官方默认重复次数 `-n 20`（语料扫描 20 遍，总吞吐按全部扫描字节数计算；`-T` 每核一个
基准线程，吞吐为所有线程聚合）。解析官方输出行 `Mean throughput (overall): N Mbit/sec`（容忍
千分位逗号）。任一场景退出非零、输出行数不为 1 或吞吐非正时测试失败。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/hyperscan/hyperscan_test.sh \
  --version 5.4.2.1 \
  --results-dir /home/runner/boostkit-perf/hyperscan/results/5.4.2.1
```

## 指标

每场景一个指标（`<mode>_t<threads>`，共 6 个，按扫描模式分组）：官方 `Mean throughput
(overall)`，单位 Mbit/s，越大越好。

## 结果与清理

必需产物为 `benchmark_hsbench.json`，包含 6 场景结构化结果与每场景完整原始输出（含官方报告的
表达式数、字节码大小、编译耗时、匹配数等上下文）。没有后台服务需要停止；任务结束只删除本次
运行的源码、依赖 prefix、构建目录、语料数据库和临时文件（限
`/home/runner/boostkit-perf/hyperscan/local-*`）。
