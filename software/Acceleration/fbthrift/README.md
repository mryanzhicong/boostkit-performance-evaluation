# fbthrift v2026.10.26.00 性能测试

本用例在 x86_64 与 aarch64 上各自从源码构建上游原版 fbthrift，并用它自带的
上游协议微基准 **ProtocolBench**（Google Benchmark 目标，源码
`thrift/lib/cpp2/test/ProtocolBench.cpp`）测量 Binary / Compact 两种协议的
序列化（write）与反序列化（read）开销。软件入口为 `fbthrift_test.sh`；
Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止脚本，直接执行入口
脚本也复用同一组阶段函数。测量阶段不联网。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 从零构建 pinned 的 fmt → fast_float → google
benchmark → folly → fbthrift 依赖链；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确
返回 30，不会退回基础版，也不会写 `build_variant.json`。启动、测试、停止阶段
共用 `scripts/stages/` 下的脚本，`scripts/common.sh` 负责跨阶段一致的私有
路径、pinned 版本表和多源下载，结果解析在 `scripts/results/`。

## 测试工具与源码

### 上游基准目标

| 项目 | 内容 |
|---|---|
| 基准目标 | `ProtocolBench`，由 `thrift/lib/cpp2/test/CMakeLists.txt` 在 `THRIFT_BENCHMARKS=ON` 时构建并安装到 `<prefix>/bin/ProtocolBench` |
| 基准源码 | `thrift/lib/cpp2/test/ProtocolBench.cpp`（279 行，Google Benchmark `BENCHMARK_MAIN()`） |
| 数据结构 | `thrift/lib/cpp2/test/ProtocolBenchData.thrift`，构建时由同树构建的 `thrift1` 以 `cpp2:frozen2,layouts` 生成 C++ 代码 |
| 链接的库 | `thriftfrozen2`、`thriftprotocol`、`thrifttype`、`Folly::folly`、`benchmark::benchmark` |
| 基准用例总数 | 897 个（`ProtocolBench --benchmark_list_tests=true` 实测） |

选择 ProtocolBench 而不是自写程序的原因：它是 fbthrift 仓库自带的协议层
基准，直接覆盖 `BinaryProtocol` / `CompactProtocol` 等上游协议实现的读写路径，
并且 `thrift/lib/cpp2/test/CMakeLists.txt` 这个目标只依赖协议库与 Folly，
不需要 RPC 栈即可独立构建。本用例没有修改 ProtocolBench.cpp 的任何一行；
`base` 构建阶段会对该文件与 `ProtocolBenchData.thrift` 做 SHA-256 内容
指纹校验（见“构建”一节），保证跑的是 pinned 上游源码。

### 版本与来源

fbthrift 使用**每周日期 tag**（形如 `v2026.10.26.00`），不是 LTS 版本；
GitHub 的 `releases/latest` 长时间停留在 2020 年的旧 release，不能作为选版
依据。本用例锁定的版本以 tag 与提交为准：

| 组件 | 来源与 tag | 提交 / 版本 | 归档 SHA-256 |
|---|---|---|---|
| fbthrift（被测软件） | `facebook/fbthrift`，tag `v2026.10.26.00` | `c7fdfc9a80aa162c3934bf325c8e6ba56d15e845` | `6ad18cfc24297120a536a0ef9c5a84f409c9aa4376057328e8dca9d45587d5a1` |
| folly | `facebook/folly`，tag `v2026.10.26.00` | 同日期周版本 | `b47fe04b804adfb51c65cda6b171505e67b9d1d69621106e54697821d1bf7ebc` |
| fmt | `fmtlib/fmt`，tag `12.1.0` | 12.1.0 | `ea7de4299689e12b6dddd392f9896f08fb0777ac7168897a244a6d6085043fea` |
| fast_float | `fastfloat/fast_float`，tag `v8.0.0` | 8.0.0（header-only） | `f312f2dc34c61e665f4b132c0307d6f70ad9420185fa831911bc24408acf625d` |
| Google Benchmark | `google/benchmark`，tag `v1.9.5` | 1.9.5 | `9631341c82bac4a288bef951f8b26b41f69021794184ece969f8473977eaa340` |

上面 5 个 SHA-256 是**唯一可信来源**：任何候选来源下载后都用同一个 SHA-256
校验，不匹配即丢弃并尝试下一个来源。fmt 12.1.0 与 fast_float 8.0.0、
google benchmark v1.9.5 的版本取自 fbthrift/folly 仓库内
`build/fbcode_builder/manifests/` 的 pin（发版方自己的构建口径），
以避开发行版包过旧的问题（Ubuntu 22.04 自带 fmt 8.1.1、benchmark 1.6.1）。

### 为什么没有构建 fizz / wangle / mvfst / fb303

本用例用 `-DTHRIFT_RPC=OFF` 构建 fbthrift。上游 `build/fbcode_builder/manifests/fbthrift`
明确把 fizz、wangle、mvfst、libsodium 放在 `feature_rpc=on` 才引入的分组里；
`fb303` 不是 fbthrift 的依赖（依赖方向相反）。ProtocolBench 只链接
`thriftfrozen2/thriftprotocol/thrifttype/Folly::folly/benchmark`，不经过 RPC
传输层，因此构建 RPC 栈只会增加构建失败面而不改变被测量路径。同理
`THRIFT_TESTS=OFF`（不需要 GTest）、`THRIFT_PY_DEPRECATED=OFF`（不需要
Python 扩展）。README 与 `dependencies.json` 都如实记录了这一裁剪。

仓库地址与 tag 事实：fizz 的真实仓库是 `facebookincubator/fizz`（`facebook/fizz`
不存在），wangle/fb303/mvfst 在 `facebook/*`；这四者的 `v2026.10.26.00` tag
实测都可下载，所以“RPC 栈不可得”不是省略它们的原因。若后续需要 RPC 服务器
口径，应把 `THRIFT_RPC` 打开、追加 fizz/wangle/mvfst/fb303 与 libsodium 依赖并
重做六阶段验证；本用例只承诺协议序列化/反序列化路径的数值。

### 离线包与多源下载

Runner 上 github.com 不稳定，所以下载按以下顺序进行，每一源都用上表的
SHA-256 校验：

1. 预置离线目录 `PERF_FBTHRIFT_OFFLINE_DIR`（默认 `/home/runner/software/fbthrift/`）；
2. `https://codeload.github.com/<owner>/<repo>/tar.gz/refs/tags/<tag>`；
3. `https://github.com/<owner>/<repo>/archive/refs/tags/<tag>.tar.gz`；
4. `https://gh-proxy.com/https://github.com/...`；
5. `https://ghfast.top/https://github.com/...`；
6. `https://hub.gitmirror.com/https://github.com/...`。

离线目录需要放置的固定文件名：

```text
/home/runner/software/fbthrift/fbthrift-v2026.10.26.00.tar.gz   # 6ad18cfc...
/home/runner/software/fbthrift/folly-v2026.10.26.00.tar.gz      # b47fe04b...
/home/runner/software/fbthrift/fmt-12.1.0.tar.gz                # ea7de429...
/home/runner/software/fbthrift/fast_float-v8.0.0.tar.gz         # f312f2dc...
/home/runner/software/fbthrift/benchmark-v1.9.5.tar.gz          # 9631341c...
```

全部来源失败时 build 阶段返回 30，并在 `command-build.log` 中逐条打印尝试过
的 URL。gitee / gitcode / 清华 / 华为云镜像不托管 GitHub 源码 tag 归档，
无法提供字节一致的 tarball，因此没有列入；列入的代理源是 GitHub archive 的
1:1 转发，可以用同一 SHA-256 校验。系统库（boost/glog/gflags/libevent/
openssl/zlib/zstd/xxhash 等）由发行版包提供，版本记录在构建日志与
`dependencies.json` 中。

## 构建

`build` 阶段在本次任务的私有目录
`/home/runner/boostkit-perf/fbthrift/<version>/<arch>/<run-id>/` 内完成：
源码解包到 `sources/`，下载归档在 `downloads/`，构建树在 `build/`，安装前缀在
`install/`。不向系统目录安装任何组件。

1. 检查 `EXPECTED_ARCH` 与本机架构一致；不一致返回 20。
2. `dnf`（Runner）与 `apt-get`（本地证据机）双分支安装缺失依赖；每个必需头文件
   （boost/glog/gflags/libevent/openssl/zlib/zstd/xxhash/**ICU**）在安装后用编译
   器重新探测，仍缺失则返回 30。`PERF_PROXY` 会传给包管理器与下载用的 curl。
   fmt、fast_float、benchmark 由本用例自建，不依赖发行版包，因此不探测系统版本。
3. **ICU 链接自检**（aarch64 二次失败后新增）：头文件存在不代表能链接，脚本会
   编译一个只引用 `-licuuc -licui18n -licudata` 的最小程序；失败时把 `ld` 的
   原始输出打进 job 日志并返回 30，同时提示安装 `libicu-devel` / `libicu-dev`。
   动机：openEuler 的 Boost CMake 包会把 ICU 以裸 `-licu*` 形式透传给
   `Boost::regex`，而 folly/fbthrift 自身从不调用 `FindICU`，所以“配置阶段
   看不出问题、链接阶段才炸”。详见“依赖”一节和 QA 文档。
4. 要求 cmake ≥ 3.24（fbthrift 的 `cmake_minimum_required`）；系统 cmake 过旧
   时可用 `PERF_CMAKE_BIN` 指定新版，未指定则先尝试用 pip 装一份私有 cmake，
   仍失败返回 30。要求 GCC ≥ 11（folly/fbthrift 的 C++20 构建）。
5. 按来源顺序取 5 个归档并校验 SHA-256，逐个解包并核对顶层目录名
   （`fbthrift-2026.10.26.00` 等），随后校验内容指纹：
   `ProtocolBench.cpp` = `39ade0ce40faaec58f07fafea52b497b4d81d989f04a549201aedf2dadeb8044`，
   `ProtocolBenchData.thrift` = `170e66ce8e0f9e2c6db69bc548e45a9757dc1f5d72594b5744157d01253dabb0`，
   folly `CMakeLists.txt` = `063bc67360f74460e81c43e389a60773befe5637eb40713f84eb4df310bbcd68`。
6. 依次构建并安装：fmt（静态库）→ fast_float（头文件）→ google benchmark（静态库）
   → folly（静态库，`BUILD_TESTS=OFF`）→ fbthrift（`THRIFT_RPC=OFF`、
   `THRIFT_TESTS=OFF`、`THRIFT_BENCHMARKS=ON`、`THRIFT_PY_DEPRECATED=OFF`），
   全程 `Release` + 私有 `CMAKE_INSTALL_PREFIX` 与 `CMAKE_PREFIX_PATH`。
7. 校验 `install/bin/ProtocolBench` 可执行、`--benchmark_list_tests=true` 能列出
   `scripts/scenarios.tsv` 中声明的全部用例，写出实际版本文件与
   `dependencies.json`。

**最终构建目标**：两个第三方项目都构建其默认 all 目标。fbthrift 侧启用
`THRIFT_BENCHMARKS=ON` 后，`thrift/lib/cpp2/test/CMakeLists.txt` 生成
`ProtocolBench`（被测目标），`thrift/lib/cpp/util/test/CMakeLists.txt` 同时生成
`VarintUtilsBench`（上游的另一个基准，也在 install 规则里，因此 `cmake --install`
要求它必须链接成功）。两者都链接 `Folly::folly`，所以都会经过 Boost::regex →
ICU 的链接路径；aarch64 首次失败正是死在 `VarintUtilsBench` 的 ICU 链接上。
本用例**没有**改成 `--target ProtocolBench` 的“只构建一个目标”方案：fbthrift 的
install 规则覆盖全部库与两个 bench，跳过目标会让 `cmake --install` 失败；保留
全量构建可以保证安装树完整、`bin/ProtocolBench` 的 rpath/依赖与上游发布形态一致。

关键命令形式（完整输出见 `command-build.log`）：

```bash
cmake -S "$WORK/sources/folly" -B "$WORK/build/folly" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$WORK/install" -DBUILD_SHARED_LIBS=OFF \
  -DBOOST_LINK_STATIC=ON -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF
cmake --build "$WORK/build/folly" -j "${PERF_BUILD_JOBS:-6}"
cmake --install "$WORK/build/folly"

cmake -S "$WORK/sources/fbthrift" -B "$WORK/build/fbthrift" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$WORK/install" \
  -DCMAKE_PREFIX_PATH="$WORK/install" -DTHRIFT_RPC=OFF -DTHRIFT_TESTS=OFF \
  -DTHRIFT_BENCHMARKS=ON -DTHRIFT_PY_DEPRECATED=OFF
cmake --build "$WORK/build/fbthrift" -j "${PERF_BUILD_JOBS:-6}"
cmake --install "$WORK/build/fbthrift"
```

CMake 生成器在依赖安装**之后**才确定：首次在干净镜像上运行时，dnf/apt 分支会
装上 `ninja-build`，随后解析生成器就能用上 Ninja（否则会退回 `Unix Makefiles`，
aarch64 首次失败那轮的构建日志里就是 `-G Unix Makefiles`）。选择的生成器会写进
`command-build.log` 的 `cmake generator:` 行。

### 依赖（链接行逐项说明）

`build/fbthrift/build.ninja` 里 `ProtocolBench` / `VarintUtilsBench` 的链接行
会按 CMake `find_package()` 的结果出现下列库。本用例的策略是：必需库装对应
`-devel` 包；可选的库**不安装**对应的 `-devel` 包，让 CMake 的
`find_package()` 失败从而不进入链接行（等价于显式关闭，且避免在 Runner 上引入
额外链接面）。ICU 是例外：它不是 folly/fbthrift 的 `find_package` 依赖，却会被
openEuler 的 Boost 包透传到链接行，因此必须装 `-devel` 并用链接自检兜底。

| 链接项 | 来源 / 包（dnf / apt） | 策略 |
|---|---|---|
| `-licuuc -licui18n -licudata` | `libicu-devel` / `libicu-dev` | **必需**，头文件探测 + 链接自检 |
| `-lboost_context -lboost_filesystem -lboost_program_options -lboost_regex` | `boost-devel` / `libboost-all-dev` | 必需（folly 的 `FOLLY_BOOST_COMPONENTS`） |
| `-lglog` | `glog-devel` / `libgoogle-glog-dev` | 必需 |
| `-lgflags` | `gflags-devel` / `libgflags-dev` | 必需 |
| `-levent` | `libevent-devel` / `libevent-dev` | 必需 |
| `-lssl -lcrypto` | `openssl-devel` / `libssl-dev` | 必需 |
| `-lz` | `zlib-devel` / `zlib1g-dev` | 必需 |
| `-lzstd` | `libzstd-devel` / `libzstd-dev` | 必需（fbthrift 的压缩支持） |
| `-lxxhash` | `xxhash-devel` / `libxxhash-dev` | 必需（fbthrift checksum） |
| `-lpthread -ldl -lrt` | glibc | 系统自带 |
| `-lunwind` | `libunwind-devel` / `libunwind-dev` | 不装；未找到则 folly 不链接（aarch64 日志里的 `Could NOT find LibUnwind` 就是这种情况，非致命） |
| `-ldwarf -liberty` | `libdwarf-devel` / `libdwarf-dev`、`libiberty`（binutils/gcc） | 不装；未找到则不链接 |
| `-llzma` | `xz-devel` / `liblzma-dev` | 不装；未找到则不链接 |
| `-lbz2` | `bzip2-devel` / `libbz2-dev` | 不装；未找到则不链接 |
| `-llz4` | `lz4-devel` / `liblz4-dev` | 不装；未找到则不链接 |
| `-lsnappy` | `snappy-devel` / `libsnappy-dev` | 不装；未找到则不链接 |
| `-lsodium` | `libsodium-devel` / `libsodium-dev` | 不装（只在 RPC 栈需要） |
| `-laio` | `libaio-devel` / `libaio-dev` | 不装；未找到则不链接 |
| `-luring` | `liburing-devel` / `liburing-dev` | 不装；未找到则不链接 |
| `-ldouble-conversion` | `double-conversion-devel` / `libdouble-conversion-dev` | 不装；folly 2026 已不再依赖它（本机链接行中没有出现） |
| `libfmt.a`、`libbenchmark.a`、`libfolly.a`、`libthrift*.a` | 本用例自建 | 必需 |

本机 x86_64 实测的链接行还包含 `libunwind/libdwarf/libiberty/libaio/libsnappy/
libsodium/libbz2/liblzma/liblz4`（本地 apt 装了这些 `-dev` 包）；aarch64 Runner
上不装它们，链接行会自动少掉这些项，因此**两边的链接面不同，但这不影响
ProtocolBench 的测量路径**（这些库都不在序列化热路径上）。

### aarch64 Actions 失败与修复（ICU）

第二次 aarch64 运行（run `41406888054`，openEuler 24.03 SP3 / GCC 12.3.1 /
CMake 3.27.9）在 build 阶段退出 30，`6m7s` 处 `VarintUtilsBench` 链接失败：

```text
/usr/bin/ld: cannot find -licudata: No such file or directory
/usr/bin/ld: cannot find -licui18n: No such file or directory
/usr/bin/ld: cannot find -licuuc: No such file or directory
```

根因：Runner 上只有 ICU 运行时包，没有提供 unversioned `.so` 开发符号链接的
`libicu-devel`；而 openEuler 的 Boost CMake 包会把 ICU 作为裸链接项透传给
`Boost::regex`（folly 的必需组件之一），于是配置阶段完全正常、链接阶段才失败。
修复：必需依赖清单加入 `libicu-devel`/`libicu-dev`，并在装机后显式做
`-licuuc -licui18n -licudata` 链接自检；自检失败时打印 `ld` 原始输出并 build 30，
不再等到 6 分钟后才在某个 bench 目标上暴露。


架构差异：`scripts/common.sh` 按 `EXPECTED_ARCH`/`uname -m` 选择基线指令集，
aarch64 用 `-march=armv8-a`，x86_64 用 `-march=x86-64-v2`；两边都不做
host-tuned 优化，保证跨架构各自可复现的基线。jemalloc 由 folly 构建时的
`check_include_file_cxx(jemalloc/jemalloc.h)` 自动探测，脚本不强制启用，实际
结果见构建日志。

实际版本：fbthrift 的 CMake `project()` 固定声明 `VERSION 1.0.0`，安装树里
没有携带日期 tag 的版本文件，因此“实际版本”不能从二进制里读字符串。本用例
用三重证据确认实际版本并从**已验证的构建输入**读取：归档 SHA-256、上述
源码内容指纹、ProtocolBench 用例清单三者一致时，从解包目录名
`fbthrift-2026.10.26.00` 取得实际版本 `2026.10.26.00` 写入
`PERF_ACTUAL_VERSION_FILE`；与请求版本不一致时 build 返回 30。

## 测试与指标

### 场景矩阵

`scripts/scenarios.tsv` 固定 10 个场景，每个场景用锚定正则精确选中 **一个**
ProtocolBench 用例（`^<case>$`），覆盖 2 种协议 × 读/写 × 数据结构：

| 场景 | 分组 | ProtocolBench 用例 | 数据形状 |
|---|---|---|---|
| `binary_write_complex_struct` | Binary / write | `BinaryProtocol_write_ComplexStruct` | int、string、list、map、嵌套 |
| `binary_read_complex_struct` | Binary / read | `BinaryProtocol_read_ComplexStruct` | int、string、list、map、嵌套 |
| `binary_write_big_binary` | Binary / write | `BinaryProtocol_write_BigBinary` | binary（`folly::IOBuf`） |
| `binary_read_big_binary` | Binary / read | `BinaryProtocol_read_BigBinary` | binary（`folly::IOBuf`） |
| `binary_read_large_map_int` | Binary / read | `BinaryProtocol_read_LargeMapInt` | map |
| `compact_write_complex_struct` | Compact / write | `CompactProtocol_write_ComplexStruct` | int、string、list、map、嵌套 |
| `compact_read_complex_struct` | Compact / read | `CompactProtocol_read_ComplexStruct` | int、string、list、map、嵌套 |
| `compact_write_big_binary` | Compact / write | `CompactProtocol_write_BigBinary` | binary（`folly::IOBuf`） |
| `compact_read_big_binary` | Compact / read | `CompactProtocol_read_BigBinary` | binary（`folly::IOBuf`） |
| `compact_read_large_map_int` | Compact / read | `CompactProtocol_read_LargeMapInt` | map |

`ComplexStruct` 依次嵌套 `Empty/SmallInt/BigInt/SmallString/BigString/Mixed`
与 `SmallListInt/BigListInt/LargeListMixed/LargeMapInt/LargeMixed/NestedMap`，
一个用例即可覆盖标量、字符串、list、map 与多层嵌套；`BigBinary` 覆盖
`folly::IOBuf` binary；`LargeMapInt` 单独给出 map 读写证据。解析器会校验矩阵
确实覆盖 Binary+Compact、read+write，以及 int/string/binary/list/map/嵌套
六类数据形状，缺任何一项直接解析失败。

每个用例的数据量是上游 `thrift/lib/cpp2/test/ThriftStructs-inl.h` 里固定构造
的，本用例没有改动：

| 用例 | 上游构造的数据量 |
|---|---|
| `BigBinary` | 10,000 字节的 `folly::IOBuf`。binary 字段的 cpp2 序列化/反序列化走 IOBuf 链/共享，`ns/op` 反映协议封装与 IOBuf 管理开销，不等于 memcpy 带宽 |
| `LargeMapInt` | 1,000,000 个 `i32 → i32` 键值对 |
| `ComplexStruct` | 12 个字段的组合：`SmallInt`、`BigInt`、`SmallString`、`BigString`（10,000 字符）、`Mixed`、`SmallListInt`（10 个）、`BigListInt`（10,000 个）、`LargeListMixed`（1,000,000 个 `Mixed`）、`LargeMapInt`（1,000,000 对）、`LargeMixed`、`NestedMap` 等 |

因此 `ComplexStruct` / `LargeMapInt` 单次操作在毫秒级，`BigBinary` 在几十
纳秒级，两者量级差异来自上游数据构造本身，不是测量误差。

### 测量流程

`start` 阶段校验私有二进制、实际版本文件与用例清单；`test` 阶段：

1. 每场景先跑 `PERF_WARMUP_RUNS`（默认 1）次预热，`--benchmark_min_time=1s`，
   结果丢弃但原始文件保留；
2. 每场景独立跑 `PERF_REPS`（默认 5）次测量，每次一个新进程，
   `--benchmark_min_time=5s`（单场景 5–10 秒）；原始输出写入
   `runs/<scenario>/rep<i>.{log,json,time}`，日志同时汇总到
   `benchmark_raw.txt`；
3. 严格解析成 `benchmark_fbthrift.json`。

`stop` 阶段为幂等空操作：基准在前台运行，不启动常驻服务，失败路径也会调用
stop。

### 指标定义

| 指标后缀 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `__ns_per_op` | `ns/op` | lower_is_better | Google Benchmark JSON 的 `cpu_time`，5 次独立进程取中位数 |
| `__objects_per_second` | `objects/s` | higher_is_better | `1e9 / ns_per_op`（每个样本先换算再取中位数） |
| `__peak_rss_mb` | `MiB` | lower_is_better | GNU time `-v` 的 `Maximum resident set size`，按 MiB 取中位数 |

每个指标在 JSON 中都带 `samples`（全样本）、`statistics`
（median/min/max/mean/stdev）与 `benchmark_case` 溯源字段。**序列化字节数
不可得**：上游 ProtocolBench 不调用 `state.SetBytesProcessed()`，也没有
bytes 计数器，本用例选择不打补丁，因此不派生该指标；`parameters` 中的
`serialized_bytes_per_object` 显式为 `null` 并写明原因，不做估算或伪造。

## 结果解析与输出

`case.yaml` 声明的输出（相对 `RESULTS_DIR`）：

| 输出 | 文件 | 阶段 | 内容 |
|---|---|---|---|
| `build_variant` | `build_variant.json` | build | `{"variant":"base","parameters":{"variant":"base"}}` |
| `benchmark_raw` | `benchmark_raw.txt` | test | 全部测量轮次的完整 ProtocolBench 原始输出 |
| `benchmark_result` | `benchmark_fbthrift.json` | test | 10 场景 × 3 指标 + 全样本/统计 + 场景矩阵 + 依赖记录 |

额外留档（未在 `case.yaml` 声明）：`dependencies.json`（5 个归档的来源与
SHA-256、系统库/编译器信息）、`benchmark_listing.txt`（ProtocolBench 用例
清单）、`runs/`（逐场景逐轮原始文件）。指标通过 `metrics.collection` 从
`results` 动态提取（`name` / `group` / `value` / `unit` / `direction`）。

解析器是严格的：缺少预热或任一轮样本、JSON 缺用例、`cpu_time` 非有限或
≤0、缺 GNU time RSS 记录、场景矩阵少于 6 或多于 10、请求版本与实际版本不符，
都会让 `test` 阶段返回 50，绝不补零或补样本。退出码约定：参数错误 20、
build 30、test 50、清理 60。

## 运行方式

Framework 六阶段（工作流内部同样调用）：

```bash
python3 framework/run_case.py --case software/Acceleration/fbthrift/case.yaml \
  --version 2026.10.26.00 --architecture x86_64 --run-id local-fbthrift \
  --stage prepare|build|start|test|stop|finalize
```

独立运行（自带 system/runtime/build-info/finalize 报告，可拷贝到项目外）：

```bash
bash software/Acceleration/fbthrift/fbthrift_test.sh --version 2026.10.26.00 \
  --variant base --results-dir /home/runner/fbthrift-results
bash software/Acceleration/fbthrift/fbthrift_test.sh --variant optimized \
  --results-dir /home/runner/fbthrift-results/optimized-check   # 预期返回 30
```

常用环境变量：`PERF_REPS`（默认 5）、`PERF_WARMUP_RUNS`（默认 1）、
`PERF_BENCHMARK_MIN_TIME`（默认 5s）、`PERF_WARMUP_MIN_TIME`（默认 1s）、
`PERF_BUILD_JOBS`（默认 6）、`PERF_CMAKE_BIN`、`PERF_PROXY`、
`PERF_FBTHRIFT_OFFLINE_DIR`。

## 已知限制与证据边界

- 本机证据是 x86_64 WSL（Ubuntu 22.04）：只证明构建链路、ProtocolBench 真实
  运行和解析/报告链路可用；aarch64 的绝对值必须在专用 Runner 上重新测量。
- ProtocolBench 共 897 个用例，本用例只固定测 10 个（README 上一节列出），
  不是全量基准，跨版本比较只在同一场景集合内成立。
- `ComplexStruct` 单次操作量很大（本机 x86_64 约 20 ms/op），5 秒内迭代数少，
  受 CPU 频率/邻居负载噪声影响明显；用 5 个独立进程的中位数与全样本缓解，
  但不消除。
- 系统库版本来自发行版（Runner 用 dnf、本地证据机用 apt），boost/glog/gflags/
  libevent/openssl/zstd/xxhash 的具体版本可能不同；`dependencies.json` 与
  `command-build.log` 会记录实际版本，跨架构报告只对齐同一场景的同一指标。
- 日期 tag 是每周滚动版本，没有 LTS；任何重跑都必须用上表 SHA-256 固定归档，
  不能用 `latest` 或浮动分支。
- 共享编译机上并行构建会拉高基线噪声，正式数据应在空载专用 Runner 上采集。

## 参考

- fbthrift 仓库：<https://github.com/facebook/fbthrift>
- ProtocolBench 源码：`thrift/lib/cpp2/test/ProtocolBench.cpp`、`thrift/lib/cpp2/test/CMakeLists.txt`
- ProtocolBench 数据：`thrift/lib/cpp2/test/ProtocolBenchData.thrift`
- fbthrift 依赖清单：`build/fbcode_builder/manifests/fbthrift`
- folly 依赖清单：`build/fbcode_builder/manifests/folly`
