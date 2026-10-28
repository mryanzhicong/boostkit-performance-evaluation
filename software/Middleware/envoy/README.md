# Envoy 1.38.6 性能测试

本用例在 x86_64、aarch64 上部署 Envoy 官方 Release 二进制包，在 Runner 裸机的
本次任务私有目录中启动服务，使用同一套 k6 参数测试 HTTPS 直接响应和反向代理。
两架构均为单机开箱测试，不修改 Envoy 源码。软件入口为 `envoy_test.sh`；
Framework 通过 `case.yaml` 调用构建、启动、测试和停止阶段，直接执行入口脚本
也使用同一套阶段函数。

正式与开发工作流可选择 `base`、`optimized`，默认 `base`。基础版调用
`scripts/builders/base.sh` 部署官方二进制包；`optimized` 构建入口尚未实现，
选择后会在构建阶段明确失败，不会退回基础版。启动、测试和停止阶段共用
`scripts/stages/`，结果解析在 `scripts/results/run_k6_benchmark.py`。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| Envoy | [官方 Envoy v1.38.6 Release](https://github.com/envoyproxy/envoy/releases/tag/v1.38.6) | `${PERF_WORK_DIR}/envoy-install/envoy` |
| k6 | [官方 k6 v2.2.0 Release](https://github.com/grafana/k6/releases/tag/v2.2.0) | `${PERF_WORK_DIR}/tools/k6` |
| TLS 证书 | 本次任务通过 OpenSSL 生成的自签名证书 | `${PERF_WORK_DIR}/runtime/tls.crt`、`tls.key` |

缺少基础命令时，脚本通过 `dnf` 安装对应系统包；普通 Runner 用户使用
`sudo -n dnf install -y <缺失的包>`。不会向系统目录安装 Envoy 或 k6。

## Envoy 与 k6 获取、安装

两种软件都优先从 `/home/runner/software/envoy/` 读取对应架构的离线文件；
缺失时从上表中的官方 Release 地址下载。两种来源都核对脚本中固定的 SHA-256，
校验失败即中止。`ENVOY_OFFLINE_DIR` 可指定其他离线目录。

| 架构 | Envoy 离线文件 | k6 离线文件 |
|---|---|---|
| `x86_64` | `envoy-1.38.6-linux-x86_64` | `k6-v2.2.0-linux-amd64.tar.gz` |
| `aarch64` | `envoy-1.38.6-linux-aarch_64` | `k6-v2.2.0-linux-arm64.tar.gz` |

下载和安装的命令形态如下；`<Envoy 文件>`、`<k6 归档>` 为上表对应架构
的文件名。若设置 `PERF_GITHUB_DOWNLOAD_PROXY`，脚本会用它拼接下载地址。

```bash
curl -fsSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/envoy-install/envoy" \
  "https://github.com/envoyproxy/envoy/releases/download/v1.38.6/<Envoy 文件>"
sha256sum "${PERF_WORK_DIR}/envoy-install/envoy"  # 必须与脚本固定值一致
chmod 0755 "${PERF_WORK_DIR}/envoy-install/envoy"

curl -fsSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/tools/<k6 归档>" \
  "https://github.com/grafana/k6/releases/download/v2.2.0/<k6 归档>"
sha256sum "${PERF_WORK_DIR}/tools/<k6 归档>"  # 必须与脚本固定值一致
tar -xzf "${PERF_WORK_DIR}/tools/<k6 归档>" -C "${PERF_WORK_DIR}/tools"
install -m 0755 "${PERF_WORK_DIR}/tools/k6-v2.2.0-linux-<amd64 或 arm64>/k6" \
  "${PERF_WORK_DIR}/tools/k6"
```

实际脚本在下载前检查离线文件；成功后执行私有 Envoy 的 `--version`、
私有 k6 的 `version`，并把 Envoy 实际版本写入 `actual-version.txt`。

## 服务启动

`start` 阶段在 `${PERF_WORK_DIR}/runtime/` 生成三个 Envoy 配置和自签名证书，
然后启动三个仅监听 `127.0.0.1` 的本次任务进程：

| 进程 | 监听端口 | 用途 |
|---|---:|---|
| HTTP backend | 18080 | 返回固定的 `200 OK` |
| HTTPS direct | 19000 | TLS 入口直接返回 `200 OK` |
| HTTPS proxy | 19001 | TLS 入口转发到本地 18080 后端 |

三个进程均使用以下命令形态启动，并将 PID 和日志保存在
`${PERF_WORK_DIR}/runtime/`：

```bash
"${PERF_WORK_DIR}/envoy-install/envoy" \
  --config-path "${PERF_WORK_DIR}/runtime/<backend|direct|proxy>.yaml" \
  --disable-hot-restart
```

启动阶段用 `curl --insecure` 检查两个 HTTPS 入口均可返回响应，最多等待约
30 秒；任一入口未就绪则不运行性能测试。端口固定，必须确保没有其他进程占用。

## 数据与运行顺序

测试不需要外部数据集。脚本生成 `envoy_k6_request.js`，对两个场景依次执行
k6，每个场景 30 个虚拟用户、持续 20 秒；两架构使用相同参数。
请求脚本设置 `insecureSkipTLSVerify: true`、`noConnectionReuse: true` 和
`noVUConnectionReuse: true`，访问本次任务生成的自签名 HTTPS 服务。

| 顺序 | 场景 | 目标地址 |
|---|---|---|
| 1 | `direct_response` | `https://127.0.0.1:19000/` |
| 2 | `reverse_proxy` | `https://127.0.0.1:19001/` |

每个场景的命令形态如下，`ENVOY_TARGET` 分别设置为上表中的地址：

```bash
ENVOY_TARGET="https://127.0.0.1:19000/" \
  "${PERF_WORK_DIR}/tools/k6" run \
  --vus 30 --duration 20s \
  --summary-export "${RESULTS_DIR}/benchmark_direct_response_summary.json" \
  "${RESULTS_DIR}/envoy_k6_request.js"
```

第二个场景使用 `https://127.0.0.1:19001/`，结果文件名改为
`benchmark_reverse_proxy_summary.json`。正式计时合计约 40 秒，另加安装、
启动和结果处理时间。任一场景的 k6 命令失败、没有有效请求吞吐，或
`http_req_failed.rate` 不为零，测试都会失败。

## 指标与产物

每个场景从 k6 的官方 summary JSON 中取四项指标；两个场景合计八项，
报告按场景分表：

| 指标 | k6 来源 | 单位 | 方向 |
|---|---|---|---|
| 请求总数 | `http_reqs.count` | requests | 越大越好 |
| 请求速率 | `http_reqs.rate` | requests/s | 越大越好 |
| 平均请求耗时 | `http_req_duration.avg` | ms | 越小越好 |
| P95 请求耗时 | `http_req_duration.p(95)` | ms | 越小越好 |

`benchmark_envoy_raw.log` 保存两个场景的完整 k6 控制台输出；
`benchmark_direct_response_summary.json` 和
`benchmark_reverse_proxy_summary.json` 保存各自的原始 summary；
`benchmark_envoy.json` 保存规范化后的八项指标，供 Framework 生成单架构和
跨架构报告。停止阶段将三个 Envoy 进程的日志复制为
`envoy-backend.log`、`envoy-direct.log`、`envoy-proxy.log`，然后仅停止
本次任务记录 PID 的进程，清理私有运行配置。

脱离 Workflow 执行完整流程：

```bash
bash software/Middleware/envoy/envoy_test.sh \
  --version 1.38.6 \
  --variant base \
  --results-dir /home/runner/envoy-results/1.38.6
```

独立运行时，工作目录默认位于
`/home/runner/boostkit-perf/envoy/local-<运行 ID>`；正常结束后清理，结果目录
保留。排查失败时可加 `--keep-workdir` 保留工作目录。
