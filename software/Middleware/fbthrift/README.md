# fbthrift 性能测试说明

本目录测试 fbthrift 官方五仓同步发布组合（`2026.09.14.00`，folly、
fizz、wangle、mvfst、fbthrift 同 dated tag `v2026.09.14.00`），在隔
离工作目录内从官方源码构建全链依赖，以上游
`thrift/perf/cpp2` 官方基准工具（官方 IDL + 官方 server + 官方
client）为基准，进行 x86_64 与 aarch64 开箱性能对比。软件入口为
`fbthrift_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、
`start`、`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段
函数。

当前清单仅声明 fbthrift `2026.09.14.00`。新增版本时，必须确认五个
官方仓库（fbthrift、folly、fizz、wangle、mvfst）都存在对应
`v<版本>` dated tag 并更新本说明与 `case.yaml` 的版本清单。

## 构建与安装

fbthrift 是 Meta 维护的 Apache Thrift C++ 实现，以 GitHub 官方仓库
为分发渠道，且与运行时依赖 folly（异步运行时）、fizz（TLS）、
wangle（连接/服务管理）、mvfst（QUIC）按同一 dated tag
`vYYYY.MM.DD.00` 同步发布。这里的“构建”是在隔离工作目录内从五仓
同一 tag 源码构建全链并安装到工作目录私有 prefix（与 dpdk、
spdk、jemalloc 用例的源码构建哲学一致），不在系统范围内安装任何
软件包：

1. 依次在以下位置获取官方源码：

   | 制品 | 官方地址 |
   |---|---|
   | fbthrift `v2026.09.14.00` | `https://github.com/facebook/fbthrift` |
   | folly `v2026.09.14.00` | `https://github.com/facebook/folly` |
   | fizz `v2026.09.14.00` | `https://github.com/facebookincubator/fizz` |
   | wangle `v2026.09.14.00` | `https://github.com/facebook/wangle` |
   | mvfst `v2026.09.14.00` | `https://github.com/facebook/mvfst` |

   全部浅克隆（`git clone --depth 1 --branch v2026.09.14.00`），
   克隆后以 `git describe --tags --exact-match` 校验 tag 精确匹配
   （git tag 语义校验，等价于其它用例的 tarball SHA-256）。

2. 五仓 CMake 构建所需的第三方依赖同样源码构建进同一私有
   prefix（系统缺少任何 devel 包都不影响）：

   | 依赖 | 官方来源 | 版本 |
   |---|---|---|
   | zlib | github.com/madler/zlib | v1.3.1 |
   | xxHash | github.com/Cyan4973/xxHash | v0.8.3 |
   | zstd | github.com/facebook/zstd | v1.5.7 |
   | gflags | github.com/gflags/gflags | v2.2.2 |
   | glog | github.com/google/glog | v0.7.1 |
   | openssl | github.com/openssl/openssl | openssl-3.6.4 |
   | libevent | github.com/libevent/libevent | release-2.1.12-stable |
   | fmt | github.com/fmtlib/fmt | 11.2.0 |
   | double-conversion | github.com/google/double-conversion | v3.3.1 |
   | fast_float | github.com/fastfloat/fast_float | v8.2.9 |
   | libsodium | github.com/jedisct1/libsodium 官方 release tarball | 1.0.22 |
   | boost | github.com/boostorg/boost 官方 release tarball | 1.88.0 |

   其中 boost 使用官方 GitHub release 的 **cmake tarball**
   （`boost-1.88.0-cmake.tar.xz`，SHA-256
   `f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec`，
   与 release 资产旁官方 `.txt` 校验文件一致；下载采用 4MiB
   分块 Range 请求逐块校验拼装——release CDN 偶发中断且 curl
   retry+resume 可能重叠追加损坏文件，分块方式保证可重试且最终
   以 SHA-256 整体校验），并只启用链所需的库——五个编译库
   （context、filesystem、program_options、regex——folly 请求的
   组件，外加 thread——folly 安装的 package config 对下游无条件
   要求）加上 folly/fbthrift 源码直接 include 的全部 header-only
   库（algorithm、container、functional、function_types、
   interprocess、intrusive、iterator、mpl、multi_index、
   preprocessor、range、smart_ptr、sort、uuid、random）；libsodium
   使用官方 release tarball（
   `libsodium-1.0.22.tar.gz`，SHA-256
   `adbdd8f16149e81ac6078a03aca6fc03b592b89ef7b5ed83841c086191be3349`，
   与 download.libsodium.org 官方分发字节一致；fizz 对其为
   `find_package(Sodium REQUIRED)` 硬依赖；tarball 自带预生成
   configure，无需 autotools）。其余依赖按上表 tag 浅克隆并以
   同款 git tag 精确匹配校验。

3. 依赖链按官方依赖顺序逐仓 CMake 构建、安装进私有 prefix：
   `folly → fizz → wangle → mvfst → fbthrift`（每仓
   `-DCMAKE_PREFIX_PATH=<prefix>` 消费前序安装产物；fbthrift 额外
   关闭 `THRIFT_BENCHMARKS`（需 google/benchmark）与
   `THRIFT_PY_DEPRECATED`（需 FB Python 设施））。构建产物为
   `libthriftcpp2` 等共享库与官方 Thrift 编译器 `thrift1`。

4. 基准 harness（`src/`）为上游 `thrift/perf/cpp2` 官方工具源码：
   官方基准 IDL（`if/Api.thrift`、`if/ApiBase.thrift`、
   `if/StreamApi.thrift`）、官方 server（`server/Server.cpp` +
   `server/BenchmarkHandler.h`：ThriftServer +
   BenchmarkHandler）、官方 client（`client/Client.cpp`：每客户端
   线程一个 event base、按权重分布的操作选择、`max_outstanding_ops`
   异步上限）与官方 util 驱动层（`util/`）。桩代码用第 3 步安装的
   官方 `thrift1` 编译器重新生成（`--legacy-strict --gen
   mstch_cpp2:include_prefix=...`，与 fbthrift 仓库内
   `add_fbthrift_cpp_library()` 的调用方式一致）。相对上游的唯一
   偏差：官方 Server/Util 的 **http2 传输分支**（依赖 proxygen，
   不在 fbthrift 标准 CMake 构建内）被移除，保留 header 与 rocket
   两种官方传输；基准场景使用 rocket（fbthrift 旗舰协议栈）。

5. harness 在官方每秒 QPS 统计（`TOTAL QPS:` 行）之外增加了采样式
   往返延迟记录器（`util/QPSStats.h` 的 `LatencyStats`、
   `util/Runner.h` 的 `LoadCallback` 插桩：请求发出记
   `steady_clock` 时间戳、响应到达求差，每 16 次完成采样 1 次、
   上限 8192 个样本，预热窗口后才开始采样；结束时输出一行
   `LATENCY ns | avg: … | p50: … | p99: … | max: … | samples: …`）。
   `steady_clock` 为 CLOCK_MONOTONIC 语义（纳秒、跨架构一致）。

6. 构建依赖 `git`、`curl`、`cmake`（>= 3.20）、`gcc`/`g++`（>= 10，
   C++20）、`make`、`python3`；全部第三方依赖源码构建，无需任何
   系统开发包。fbthrift 官方编译器为手写解析器，不需要
   bison/flex。

## 基准就绪（start）

`start` 阶段先启动基准 server（官方 `Server.cpp`，ThriftServer，
rocket/header 传输，pid 文件管理生命周期），再对三种负载各以最小
配置（1 客户端、3 秒）完整冒烟运行一次官方 client，校验输出包含
`TOTAL QPS:` 统计行与 `LATENCY ns` 汇总行后丢弃冒烟产物并停止
server；`test` 阶段只对已验证的组合计时。

## 性能测试

基准负载为官方 perf IDL 的三个代表性 RPC 操作（均为
request/response 语义，客户端异步发起、`max_outstanding_ops=100`）：

- **noop**：官方 `async_eb noop()`——空请求/空响应往返，纯 RPC
  框架开销路径（序列化最小、事件循环直通）；
- **sum**：官方 `async_eb sum(TwoInts)->TwoInts`——小结构体双端
  序列化/反序列化 + 计算路径；
- **download**：官方同步 `download()->Chunk2`——1KiB（官方
  `chunk_size` 默认值）下行负载，走 server 工作线程路径。

场景矩阵为 3 负载 × 客户端线程阶梯（1/4/16/64，mysql
thread-ladder 风格；每线程一个 event base、一条连接），传输统一为
rocket（`FBTHRIFT_TRANSPORT` 可覆写为 header）。server 的 IO/CPU
线程数默认为全部核数（`FBTHRIFT_SERVER_THREADS=0`）。

每个场景运行预热 5 秒 + 测量 30 秒（`FBTHRIFT_WARMUP_SECONDS`、
`FBTHRIFT_DURATION_SECONDS` 可覆写）：

```bash
${CLIENT_BIN} --host=127.0.0.1 --port=7777 --transport=rocket \
  --num_clients=<N> --<workload>_weight=1 --max_outstanding_ops=100 \
  --chunk_size=1024 --warmup_sec=5 --stats_interval_sec=1 \
  --terminate_sec=35 --logtostderr=true
```

`test` 阶段依次运行 12 个场景（原始输出 `tee` 进
`fbthrift_perf_raw.log`），随后 `scripts/collect_fbthrift_benchmark.py`
把每个场景的客户端日志汇总为 `results.json`：QPS 取测量窗口内逐秒
`TOTAL QPS` 的**中位数**（丢弃前 5 个预热秒），avg RTT / p99 RTT 取
harness 延迟采样器汇总行（unit=ns）。指标方向：QPS 越大越好，RTT
越小越好。

`stop` 阶段停止基准 server（pid 文件，SIGTERM → 20×0.5s →
SIGKILL 回退）并删除基准运行数据目录。

## 版本

- `2026.09.14.00`：当前基线，五仓同 tag lockstep 组合。

版本号即 dated tag 主体；thrift1 无 `--version` 输出，版本记录以
克隆时 `git describe --tags --exact-match` 的精确匹配为准（写入
`actual-version.txt`）。
