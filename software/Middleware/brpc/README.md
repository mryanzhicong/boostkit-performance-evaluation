# BRPC 性能测试说明

本目录构建 Apache BRPC 的指定发布版本，并使用仓库内 `example/http_c++` 的
`http_server` 和 `benchmark_http` 做单机 HTTP RPC 开箱性能对比。Framework 通过
`case.yaml` 调用 `brpc_test.sh` 的 `build`、`start`、`test`、`stop` 四个阶段；直接
执行入口脚本会使用相同流程。

当前清单仅声明 `1.17.0`。测试流量在同一台 Runner 的 `127.0.0.1` 上闭环，不测
跨主机网络、网卡或 Baidu 标准 RPC 协议的吞吐。

## 构建与安装

BRPC 从官方 GitHub 标签浅克隆，在任务隔离目录中以 Release 模式构建；不安装
系统级 BRPC。缺少命令或开发头文件时，入口脚本会通过 `dnf`（非 root 时使用
`sudo -n dnf`）安装。依赖包括 CMake、GCC/G++、Protobuf、OpenSSL、gflags、
LevelDB 和 gperftools。

核心构建命令如下：

```bash
git clone --branch 1.17.0 --depth 1 https://github.com/apache/brpc.git brpc-source
cmake -S brpc-source -B brpc-source/build \
  -DCMAKE_BUILD_TYPE=Release -DWITH_DEBUG_SYMBOLS=OFF -DBUILD_BRPC_TOOLS=OFF
cmake --build brpc-source/build -j "$(nproc)"

cmake -S brpc-source/example/http_c++ -B brpc-source/example/http_c++/build \
  -DCMAKE_BUILD_TYPE=Release
cmake --build brpc-source/example/http_c++/build -j "$(nproc)" \
  --target benchmark_http --target http_server
```

为兼容当前 Protobuf/Abseil，脚本仅对官方 HTTP 示例的独立 CMake 配置补充 C++17
及 Abseil 链接信息；BRPC 库本身仍按上述官方 CMake 方式构建。构建结果必须存在：

```text
brpc-source/build/output/lib/libbrpc.a
brpc-source/example/http_c++/build/http_server
brpc-source/example/http_c++/build/benchmark_http
```

## 服务与性能测试

`start` 阶段启动官方 `http_server`，只绑定 `127.0.0.1:18010`，并以 `/status`
确认服务就绪：

```bash
./http_server -port 18010 \
  -certificate cert.pem -private_key key.pem
curl -fsS http://127.0.0.1:18010/status
```

`test` 阶段使用官方 `benchmark_http` 请求 `/HttpService/Echo`。默认先预热 5 秒，
终止并丢弃预热进程的全部统计；然后重新启动客户端，使用 50 线程进行 60 秒正式
测试。核心命令如下：

```bash
./benchmark_http \
  -thread_num 50 \
  -url 127.0.0.1:18010/HttpService/Echo \
  -dummy_port 18888

curl -fsS http://127.0.0.1:18888/vars/client_*
```

`benchmark_http` 的 dummy server 暴露客户端 `LatencyRecorder` 的 bvar；脚本在
正式测试结束前抓取 `/vars/client_*`，保存为 `bvar_vars.txt`，随后停止客户端和
服务器。可通过环境变量调整线程数、时长、预热时间及端口：
`BENCHMARK_HTTP_THREAD_NUM`、`BENCHMARK_HTTP_DURATION_S`、
`BENCHMARK_HTTP_WARMUP_S`、`HTTP_SERVER_PORT`、`BENCHMARK_DUMMY_PORT`。

可脱离 Workflow 执行完整流程：

```bash
bash software/Middleware/brpc/brpc_test.sh \
  --version 1.17.0 \
  --results-dir /home/runner/brpc-results/1.17.0
```

## 指标

指标均取自官方 `benchmark_http` 的 `client` `LatencyRecorder` bvar，不改名、不做
跨指标聚合。`benchmark_brpc.json` 仅将原始标量写入 Framework 格式。

| 原始 bvar 字段 | 单位 | 优化方向 | 含义 |
|---|---:|---|---|
| `client_qps` | requests/s | 越大越好 | 客户端每秒完成请求数 |
| `client_count` | requests | 越大越好 | 正式测量期累计请求数 |
| `client_latency` | us | 越小越好 | 延迟记录器的平均延迟 |
| `client_max_latency` | us | 越小越好 | 最大延迟 |
| `client_latency_80`、`client_latency_90`、`client_latency_99`、`client_latency_999`、`client_latency_9999` | us | 越小越好 | P80、P90、P99、P99.9、P99.99 延迟 |

## 结果与清理

必需产物为 `bvar_vars.txt`（原始 bvar 输出）和 `benchmark_brpc.json`（结构化指标）。
独立运行还会保存 `results.log`、构建/环境信息及单架构报告。`stop` 阶段向客户端和
服务器发送 `TERM`，15 秒内未退出才发送 `KILL`，随后删除仅属于本任务的工作目录。
