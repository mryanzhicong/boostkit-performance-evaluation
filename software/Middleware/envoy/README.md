# Envoy 性能测试

本目录适配官方 [envoyproxy/envoy](https://github.com/envoyproxy/envoy) 的单机开箱性能测试。当前固定测试 Envoy `1.38.6`，安装和性能测试均在 Runner 裸机的本次任务隔离目录中进行。

软件入口为 `envoy_test.sh`；Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止脚本。直接执行入口脚本也使用这些阶段函数。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 安装官方 Release 资产；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，
不会退回基础版。启动、测试和停止阶段共用 `scripts/stages/` 下的脚本。
`scripts/common.sh` 提供阶段间一致的私有路径约定，结果解析位于 `scripts/results/`。

## 构建与安装

脚本自动安装缺失的基础命令。Envoy `1.38.6` 与 k6 `2.2.0` 均使用官方 GitHub Release 资产，按固定 SHA-256 校验后保存到本次任务的私有目录。

可预先将官方发布文件放入 Runner，脚本优先使用这些离线文件：

```bash
/home/runner/software/envoy/envoy-1.38.6-linux-x86_64
/home/runner/software/envoy/envoy-1.38.6-linux-aarch_64
/home/runner/software/envoy/k6-v2.2.0-linux-amd64.tar.gz
/home/runner/software/envoy/k6-v2.2.0-linux-arm64.tar.gz
```

对应离线文件不存在时，脚本从 [Envoy v1.38.6 Release](https://github.com/envoyproxy/envoy/releases/tag/v1.38.6) 和 [k6 v2.2.0 Release](https://github.com/grafana/k6/releases/tag/v2.2.0) 下载相同文件；配置 `PERF_GITHUB_DOWNLOAD_PROXY` 时下载地址自动经该代理访问。安装后的 Envoy 位于本次任务私有的 `envoy-install/envoy`，脚本执行 `envoy --version` 校验请求版本，随后记录 `actual-version.txt`。

## 服务启动

`start` 阶段在 `127.0.0.1` 启动三个本次任务私有的 Envoy 进程：

- `18080`：HTTP backend，返回固定 `200 OK`；
- `19000`：HTTPS direct-response；
- `19001`：HTTPS reverse proxy，转发至 `18080` backend。

TLS 证书在本次任务目录中即时生成，仅用于本地压测。两个 HTTPS listener 就绪后才进入测试阶段。

## 性能测试

两个场景均使用 k6 `2.2.0`，执行固定命令参数：

```bash
k6 run --vus 30 --duration 20s --summary-export <summary.json> <request.js>
```

k6 对 `https://127.0.0.1:19000/` 和 `https://127.0.0.1:19001/` 分别执行压测，关闭 HTTP 连接复用并跳过自签名证书校验。因此每次请求都会建立新的 TLS 连接，测量包含 TLS 握手和 Envoy HTTP 处理。

场景与指标如下：

| 场景 | 含义 | 指标 |
|---|---|---|
| HTTPS direct response | Envoy TLS listener 直接返回 200，不访问 upstream | `http_reqs.count`、`http_reqs.rate`、`http_req_duration.avg`、`http_req_duration.p(95)` |
| HTTPS reverse proxy | Envoy TLS listener 转发到本地 Envoy backend | `http_reqs.count`、`http_reqs.rate`、`http_req_duration.avg`、`http_req_duration.p(95)` |

吞吐和请求总数越大越好，平均延迟和 P95 延迟越小越好。`http_req_failed.rate` 必须为零，否则测试直接失败。报告按上述两个场景分别生成表格。原始 k6 控制台输出保存为 `benchmark_envoy_raw.log`，每个场景的官方 summary JSON 也随结果一并保存。失败请求的状态码、错误码及错误信息最多记录每个虚拟用户的前三次；停止服务时将 `envoy-direct.log`、`envoy-proxy.log`、`envoy-backend.log` 复制到结果目录，便于排查。

## 结果与清理

规范化输出是 `benchmark_envoy.json`。停止阶段只终止本次任务记录 PID 的三项 Envoy 进程并删除其隔离运行配置，不会操作 Runner 上的其他服务。

可脱离 Workflow 执行完整流程：

```bash
cd software/Middleware/envoy
bash envoy_test.sh --version 1.38.6 --variant base
```

默认结果目录为 `results/1.38.6/<run-id>/`（调优版位于该版本下的 `optimized/` 子目录）。独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；目前调优版只验证入口与明确失败行为，不执行性能测试。正式工作流中基础版的 OBS 与 `performance-results` 路径不变；调优版归档到 `Middleware/envoy/1.38.6/optimized/<时间戳_Run ID>/`，且不会更新基础版的 `baseline.json`。如需保留构建目录排障：

```bash
bash envoy_test.sh --version 1.38.6 --keep-workdir
```
