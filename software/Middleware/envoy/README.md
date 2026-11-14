# Envoy 1.38.6 性能测试

本用例在 x86_64、aarch64 上部署 Envoy 官方 Release 二进制包，在 Runner 的
**本次任务私有 openEuler 24.03 LTS SP4 容器**中启动服务与 k6 压测客户端，
测试 HTTPS 直接响应和反向代理两个场景。两架构均为单机开箱测试，不修改
Envoy 源码。软件入口为 `envoy_test.sh`；Framework 通过 `case.yaml` 调用构建、
启动、测试和停止阶段，直接执行入口脚本也使用同一套阶段函数。

正式与开发工作流可选择 `base`、`optimized`，默认 `base`。基础版调用
`scripts/builders/base.sh` 部署官方二进制包；`optimized` 构建入口尚未实现，
选择后会在构建阶段明确失败，不会退回基础版。启动、测试和停止阶段共用
`scripts/stages/`，结果解析在 `scripts/results/run_k6_benchmark.py`。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| 容器基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档（x86_64 / aarch64） | `docker load` 后由 `docker run` 启动 |
| Envoy | [官方 Envoy v1.38.6 Release](https://github.com/envoyproxy/envoy/releases/tag/v1.38.6) | `${PERF_WORK_DIR}/envoy-install/envoy` |
| k6 | [官方 k6 v2.2.0 Release](https://github.com/grafana/k6/releases/tag/v2.2.0) | `${PERF_WORK_DIR}/tools/k6` |
| TLS 证书 | 本次任务由宿主机 OpenSSL 生成的自签名证书 | `${PERF_WORK_DIR}/runtime/tls.crt`、`tls.key` |

构建阶段需要的基础命令缺失时，脚本通过 `dnf` 安装在宿主机；普通 Runner
用户使用 `sudo -n dnf install -y <缺失的包>`。不会向宿主机系统目录安装
Envoy、k6 或容器内运行期组件。

## 容器化执行

- **容器块来源**：`scripts/common.sh` 里的 `container-runtime` 区块由
  `adaptation/scripts/add-container-block.py` 从
  `adaptation/scripts/container-block.template.sh` 生成（标记区间内勿手改），
  与 mysql、ray、unixbench 等容器化用例共用同一份容器契约。
- **镜像来源与校验**：优先读取公共离线目录
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`
  及同名 `.sha256sum`；缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/`
  下载到 `${PERF_WORK_DIR}`。脚本核对 SHA-256 后执行 `docker load`，校验镜像
  内 `/etc/os-release` 为 openEuler 24.03 LTS SP4、镜像架构与目标架构一致；
  每次运行都从归档加载（已加载时 Docker 直接复用现有层），不额外写 ref 文件。
- **容器名与标签**：`boostkit-envoy-<arch>-<run-id>`，标签
  `boostkit.envoy.run-id=<run-id>`。启动前会清掉同一标签前缀下属于其他 run
  ID 的残留容器；停止阶段只停止并删除标签与本任务 run ID 一致的容器，
  标签不符即报错（退出码 60），不会误删其他任务。
- **挂载**：`PERF_WORK_DIR`（容器内同绝对路径，读写）；`RESULTS_DIR`
  （读写）；用例目录 `SCRIPT_DIR`（结果目录不在用例目录下时只读）；
  `/etc/passwd` 与 `/etc/group`（只读）；设置 `PERF_PROXY` 时额外挂载代理 CA
  目录到 `/etc/pki/ca-trust/source/anchors`（只读）。容器内 `HOME` 指向
  `${PERF_WORK_DIR}/home`。
- **文件描述符**：容器显式设置 `--ulimit nofile=1048576:1048576`。Envoy
  启动需要较高 fd 上限，容器默认 1024 会导致 libevent `Too many open files`
  并断言退出，因此该参数是启动成功的必要条件。
- **宿主职责边界**：宿主机只负责下载/校验 Envoy 与 k6、生成自签名证书、
  做 HTTPS 就绪探测、运行结果解析与规范化；不向宿主机安装 Envoy 服务，
  也不在宿主机启动 Envoy 或 k6 进程。
- **与整机直跑的差异**：服务端与压测客户端都在容器内，容器使用
  `--network=host` 共享宿主网络栈，因此 `127.0.0.1` 端口与直跑一致；
  不限制 CPU、内存或 NUMA（不设置 `--cpus`/`--memory`/`--cpuset-*`）。
- **独立运行前置**：需要可访问的 Docker daemon；daemon 不可用或容器
  运行异常时，构建/启动/测试阶段分别以 30/40/50 退出码失败。

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

`start` 阶段先在 `${PERF_WORK_DIR}/runtime/` 生成三个 Envoy 配置和自签名证书，
然后调用公共容器块启动任务私有容器（镜像准备、残留容器清扫、挂载、仓库切换、
fd 上限都由容器块处理），用 `envoy_container_exec_root dnf install` 在容器内补
`python3`、`bash`、`libstdc++`，最后用 `docker exec -d` 启动三个仅监听
`127.0.0.1` 的 Envoy 进程：

| 进程 | 监听端口 | 用途 |
|---|---:|---|
| HTTP backend | 18080 | 返回固定的 `200 OK` |
| HTTPS direct | 19000 | TLS 入口直接返回 `200 OK` |
| HTTPS proxy | 19001 | TLS 入口转发到本地 18080 后端 |

三个进程均使用以下命令形态启动（在容器内执行），日志保存在
`${PERF_WORK_DIR}/runtime/`：

```bash
docker exec -d --user "$(id -u):$(id -g)" \
  --env "HOME=${PERF_WORK_DIR}/home" \
  --env "TMPDIR=${PERF_WORK_DIR}/tmp" "${ENVOY_CONTAINER_NAME}" \
  bash -c "exec '${PERF_WORK_DIR}/envoy-install/envoy' \
    --config-path '${PERF_WORK_DIR}/runtime/<backend|direct|proxy>.yaml' \
    --disable-hot-restart > '${PERF_WORK_DIR}/runtime/<name>.log' 2>&1"
```

启动阶段由**宿主机**用 `curl --insecure` 检查两个 HTTPS 入口均可返回响应，
最多等待约 30 秒；任一入口未就绪则不运行性能测试。端口固定，必须确保没有
其他进程占用。

## 数据与运行顺序

测试不需要外部数据集。测试阶段在容器内生成 `envoy_k6_request.js`，对两个
场景依次执行 k6，每个场景 30 个虚拟用户、持续 20 秒；两架构使用相同参数。
请求脚本设置 `insecureSkipTLSVerify: true`、`noConnectionReuse: true` 和
`noVUConnectionReuse: true`，访问本次任务生成的自签名 HTTPS 服务。

| 顺序 | 场景 | 目标地址 |
|---|---|---|
| 1 | `direct_response` | `https://127.0.0.1:19000/` |
| 2 | `reverse_proxy` | `https://127.0.0.1:19001/` |

测试阶段通过 `docker exec -i` 把 `run_k6_benchmark.py` 送入容器执行，
`ENVOY_TARGET` 分别设置为上表中的地址：

```bash
docker exec -i --user "$(id -u):$(id -g)" \
  --env "HOME=${PERF_WORK_DIR}/home" \
  --env "SOFTWARE_VERSION=1.38.6" --env "EXPECTED_ARCH=<x86_64|aarch64>" \
  --env "PERF_VARIANT=base" --env "TMPDIR=${PERF_WORK_DIR}/tmp" \
  "${ENVOY_CONTAINER_NAME}" python3 - \
  --k6 "${PERF_WORK_DIR}/tools/k6" \
  --direct-url 'https://127.0.0.1:19000/' \
  --reverse-url 'https://127.0.0.1:19001/' \
  --output "${RESULTS_DIR}/benchmark_envoy.json" \
  --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" \
  < software/Middleware/envoy/scripts/results/run_k6_benchmark.py
```

正式计时合计约 40 秒，另加镜像准备、容器依赖安装、启动和结果处理时间。
任一场景的 k6 命令失败、没有有效请求吞吐，或 `http_req_failed.rate`
不为零，测试都会失败。

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
跨架构报告。停止阶段先停止并删除本任务容器（`docker stop --time 30`、
`docker rm`），再把三个 Envoy 进程日志复制为 `envoy-backend.log`、
`envoy-direct.log`、`envoy-proxy.log`，最后清理私有运行配置。

## 独立运行

脱离 Workflow 执行完整流程（需要可用的 Docker daemon）：

```bash
bash software/Middleware/envoy/envoy_test.sh \
  --version 1.38.6 \
  --variant base \
  --results-dir /home/runner/envoy-results/1.38.6
```

独立运行时，工作目录默认位于
`/home/runner/boostkit-perf/envoy/local-<运行 ID>`；正常结束后清理，
结果目录保留。排查失败时可加 `--keep-workdir` 保留工作目录。

## 已知限制

- 需要 Docker daemon；无 daemon 时构建/启动阶段直接失败，不会回退到宿主机直跑。
- 容器内 Envoy 进程由 `docker exec -d` 启动，异常退出依靠就绪探测与 k6
  失败上报，不保留宿主机 PID 文件。
