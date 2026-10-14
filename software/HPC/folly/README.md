# Folly 2022.11.14.00 性能测试

本用例在 x86_64 和 aarch64 上分别构建上游原版 Folly，并用私有
`AccLibBenchmark/fbthrift_folly_benchmark` 的 `press_server`、`press_client`
做单机 RPC 性能对比。测试工具测量的是由 Folly、Fizz、Wangle、fbthrift
共同实现的 RPC 链路，**不是 Folly 单个函数的微基准**。

## 测试工具与源码

两台 Runner 均须事先将私有仓库放在
`/home/runner/software/folly/AccLibBenchmark`。脚本只读取其中的
`fbthrift_folly_benchmark/` 和 `fb_folly_autobuild/run.py`，不要求 Runner
访问私有 Git 仓库，也不将私有源码提交到当前项目。原目录不会被修改。

| 组件 | 源码与版本 |
|---|---|
| Folly | `https://github.com/facebook/folly.git`，`v2022.11.14.00` |
| Fizz | `https://github.com/facebookincubator/fizz.git`，同日期标签 |
| Wangle | `https://github.com/facebook/wangle.git`，同日期标签 |
| fbthrift | `https://github.com/facebook/fbthrift.git`，同日期标签 |
| 测试工具 | Runner 本地 `AccLibBenchmark/fbthrift_folly_benchmark`，保留本地源码 SHA-256 |

所有源码、构建树和安装前缀都在本次任务的
`/home/runner/boostkit-perf/folly/<版本>/<架构>/<run-id>/` 下。系统缺少的编译工具
和开发包通过 `dnf` 安装；不会将上述四个库安装到系统目录。

## 构建

`build` 阶段按 Folly → Fizz → Wangle → fbthrift 的顺序构建并安装，每步使用
`Release`、共享库和任务私有 `CMAKE_INSTALL_PREFIX`。实际命令及完整输出保存在
`command-build.log`；关键命令形式为：

```bash
cmake -S "$WORK/folly-source" -B "$WORK/folly-build" \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DBUILD_BENCHMARKS=OFF \
  -DCMAKE_LIBRARY_ARCHITECTURE="$(gcc -dumpmachine)" \
  -DCMAKE_INSTALL_PREFIX="$WORK/install/folly"
cmake --build "$WORK/folly-build" --parallel "$(nproc)" # 脚本最多使用 32 路并行
cmake --install "$WORK/folly-build"

# Fizz、Wangle、fbthrift 也分别 cmake 配置、构建、安装到 $WORK/install/<组件>。
# 通过 CMAKE_PREFIX_PATH 关联刚安装的上游库。
```

Folly 此版本在 CMake 未识别出目标架构时默认启用 x86 SSE 源文件；显式传入
GCC 的目标架构可让 aarch64 构建跳过这些文件，无需修改上游源码。

然后将测试工程复制到 `$WORK/fbthrift_folly_benchmark`，用本次构建的
`$WORK/install/fbthrift/bin/thrift1 --gen mstch_cpp2 press.thrift` 生成协议代码，
再执行：

```bash
cmake -S "$WORK/fbthrift_folly_benchmark" \
  -B "$WORK/fbthrift_folly_benchmark/build" \
  -DCMAKE_PREFIX_PATH="$WORK/install/fbthrift:$WORK/install/wangle:$WORK/install/fizz:$WORK/install/folly"
cmake --build "$WORK/fbthrift_folly_benchmark/build" --parallel 32 \
  --target press_server press_client
```

测试工具原源码调用了定制 Folly 的 `IOBuf` 内存池接口，以及定制 RPC
的 io_uring 接口。脚本**仅在复制到本次工作目录的测试工具**中移除这些
接口调用，并规范化其中的 NUL 字符字面量；兼容修改记录在
`$WORK/acclib-compatibility.json`。四个上游库源码及 Runner 上的私有仓库原件
均不修改。两架构执行相同的兼容处理，测试时都使用 `--use_io_uring=false`。

## 测试与指标

`start` 阶段在本机 `127.0.0.1` 启动 `press_server`，设置 40 个 I/O 线程、
40 个 CPU 线程；`stop` 阶段关闭服务端。`test` 阶段读取原始
`AccLibBenchmark/fb_folly_autobuild/run.py` 中的 `DATA_SETUPS`、`CONN_SETUPS`、
`QD_SETUPS` 和固定客户端参数，逐项运行 `press_client`。唯一的运行环境替换是
本地可执行文件路径、`127.0.0.1`/本次端口、取消 NUMA 绑定，并在两架构关闭
`io_uring`。测试不绑核、不启用定制优化。

当前仓库的原始 `run.py` 实际定义 **14 种数据设置 × 4 种连接设置 × 2 种队列深度
= 112 个场景**；每个场景 90 秒，场景间隔 5 秒，纯测试约 2 小时 57 分钟，
另加源码构建时间。脚本不接受缺失字段、无成功请求或客户端非零退出；
出现 RPC 失败时保留该场景，并记录成功率和失败请求数。

每个场景从原始 `press_client` 输出保留八项指标，按数据设置分组展示：

| 指标 | 单位 | 方向 |
|---|---|---|
| Throughput | MB/s | 越大越好 |
| QPS | ops/s | 越大越好 |
| 成功率 | % | 越大越好 |
| 失败请求数 | requests | 参考值，不计算相对性能 |
| 平均延迟 | µs | 越小越好 |
| P99 延迟 | µs | 越小越好 |
| 客户端 CPU 使用率 | % | 参考值，不计算相对性能 |
| 服务端 CPU 使用率 | % | 参考值，不计算相对性能 |

完整客户端输出、实际命令及服务器输出分别保存在 `press_client_raw/`、
`press_client_raw/commands.json`、`press_server.log`；结构化结果是
`benchmark_folly.json`。每个指标名包含数据类型、payload 大小、CPU/I/O 线程数、
连接数和队列深度，确保跨架构只对齐参数完全相同的场景。

独立运行：

```bash
bash software/HPC/folly/folly_test.sh \
  --version 2022.11.14.00 \
  --results-dir /home/runner/folly-results
```
