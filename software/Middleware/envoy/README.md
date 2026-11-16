# Envoy 1.38.6 性能测试

本用例在 x86_64、aarch64 上使用 Envoy 官方 v1.38.6 Release 二进制，在
**本次任务私有的 openEuler 24.03 LTS SP4 容器**中启动 Envoy 服务，并在同一
容器内运行 k6 压测客户端，测试 HTTPS 直接响应和反向代理两个场景。

容器规格固定为 **4 CPU、8 GiB（4U8G）**：`--cpus=4`，CPU 集合与 NUMA
内存节点按当前 runner 的 affinity 和 sysfs 拓扑读取，不写死 CPU 区间；每个
NUMA 节点最低的 4 个 CPU 保留给系统进程，容器取紧随其后的 4 个 CPU（Blue
aarch64 上为 4、5、6、7），避免系统负载落在 0-3 上影响测量。
`--memory=8g`，Docker 支持 swap accounting 时追加 `--memory-swap=8g`。
容器使用 `--network=host`，服务端口由运行 ID 派生，避免与其他任务冲突。

入口脚本是 `envoy_test.sh`；Framework 通过 `case.yaml` 调用 build、start、
test、stop 四个阶段，独立入口和 Framework 使用同一批阶段函数。变体可选择
`base`、`optimized`，默认 `base`。基础版部署官方 Release 二进制；
`optimized` 入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，
选择后会在构建阶段明确失败，不会退回基础版。

本次正式证据只派发 aarch64 Blue；x86_64 代码路径保留，但**不派发 x86_64
Blue**。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 容器基础镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档（[x86_64](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/x86_64/)、[aarch64](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/aarch64/)） | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`；使用同名 `.sha256sum` 校验 SHA-256 后 `docker load` |
| Envoy | [Envoy v1.38.6 Release](https://github.com/envoyproxy/envoy/releases/tag/v1.38.6) | `${PERF_WORK_DIR}/envoy-install/envoy` |
| k6 | [k6 v2.2.0 Release](https://github.com/grafana/k6/releases/tag/v2.2.0) | `${PERF_WORK_DIR}/tools/k6` |
| TLS 证书 | 本次任务在宿主机用 OpenSSL 生成的自签名证书 | `${PERF_WORK_DIR}/runtime/tls.crt`、`tls.key` |
| 结果解析 | 仓库内 `run_k6_benchmark.py`，在容器内执行、宿主机汇总 | `${PERF_WORK_DIR}/reference/` 与 `${RESULTS_DIR}` |

## Envoy 获取、构建与容器启动

本用例不编译 Envoy 源码，直接使用官方 Release 二进制。获取顺序固定为：

1. 公共离线目录 `/home/runner/software/envoy/`；
2. 本次任务缓存 `${PERF_WORK_DIR}`；
3. 前两者都没有时，从官方 Release URL 下载。

两个架构的资产名和脚本内固定 SHA-256 如下。离线文件、缓存和下载结果都必须
匹配对应架构的校验值，否则在构建阶段失败。

| 架构 | Envoy 资产 | Envoy SHA-256 | k6 资产 | k6 SHA-256 |
|---|---|---|---|---|
| `x86_64` | `envoy-1.38.6-linux-x86_64` | `9b68557ccb2ef587c0374bfca75b01966ca3c6b59d96663fd7557b496e0c7ad1` | `k6-v2.2.0-linux-amd64.tar.gz` | `b5a8003c86f35f5cd5ceef1490312c48e587696c94d998cefc6d7b3b4cb1597d` |
| `aarch64` | `envoy-1.38.6-linux-aarch_64` | `e90eff416e94eaa8b5812196d17918635e8dc0b0e12d11ef7e0fee2c0a6bdca7` | `k6-v2.2.0-linux-arm64.tar.gz` | `4ecd64cadcc792402d16293836115480419c4447c032858f564852d98f1bf54c` |

以下是实际命令形态。`<Envoy 文件>`、`<k6 归档>` 取上表中对应架构的值；
设置 `PERF_GITHUB_DOWNLOAD_PROXY` 时，下载地址会拼接该代理。

```bash
# 1. 获取并校验 Envoy Release 二进制
curl -fsSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/envoy-install/envoy" \
  "https://github.com/envoyproxy/envoy/releases/download/v1.38.6/<Envoy 文件>"
sha256sum "${PERF_WORK_DIR}/envoy-install/envoy"
chmod 0755 "${PERF_WORK_DIR}/envoy-install/envoy"
"${PERF_WORK_DIR}/envoy-install/envoy" --version

# 2. 获取、校验并解包 k6
curl -fsSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/tools/<k6 归档>" \
  "https://github.com/grafana/k6/releases/download/v2.2.0/<k6 归档>"
sha256sum "${PERF_WORK_DIR}/tools/<k6 归档>"
tar -xzf "${PERF_WORK_DIR}/tools/<k6 归档>" -C "${PERF_WORK_DIR}/tools"
install -m 0755 "${PERF_WORK_DIR}/tools/k6-v2.2.0-linux-<amd64 或 arm64>/k6" \
  "${PERF_WORK_DIR}/tools/k6"
"${PERF_WORK_DIR}/tools/k6" version

# 3. 准备 openEuler 24.03 LTS SP4 镜像
sha256sum -c "${ENVOY_IMAGE_ARCHIVE_DIR}/openEuler-docker.<arch>.tar.xz.sha256sum"
docker load -i "${ENVOY_IMAGE_ARCHIVE_DIR}/openEuler-docker.<arch>.tar.xz"
docker image inspect "${ENVOY_CONTAINER_IMAGE}" --format '{{.Id}} {{.Architecture}}'
```

### 服务启动

`start` 阶段先在 `${PERF_WORK_DIR}/runtime/` 生成三个 Envoy 配置和自签名
证书，再按下面的参数启动任务私有容器。容器内只安装运行 Envoy 和 k6 所需的
`python3`、`bash`、`libstdc++`，安装前把容器内 openEuler 仓库切换到华为
镜像源，并注释原 `meta` 元数据地址；这些修改只发生在本次容器内。

```bash
docker run --detach --name "${ENVOY_CONTAINER_NAME}" \
  --label "boostkit.envoy.run-id=${PERF_RUN_ID}" \
  --cpus=4 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
  --memory=8g --memory-swap=8g \
  --network=host --user "$(id -u):$(id -g)" \
  --ulimit nofile=1048576:1048576 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=/etc/passwd,target=/etc/passwd,readonly" \
  --mount "type=bind,source=/etc/group,target=/etc/group,readonly" \
  "${ENVOY_CONTAINER_IMAGE}" sleep infinity

docker inspect --format \
  '{{.HostConfig.NanoCpus}}|{{.HostConfig.CpusetCpus}}|{{.HostConfig.CpusetMems}}|{{.HostConfig.Memory}}' \
  "${ENVOY_CONTAINER_NAME}"
```

Docker daemon 不支持 swap accounting 时不传 `--memory-swap`；8 GiB 的 cgroup
内存上限始终会写入并核对。容器名格式为
`boostkit-envoy-<arch>-<run-id>`，标签为
`boostkit.envoy.run-id=${PERF_RUN_ID}`；停止阶段只处理标签和 run ID 都匹配的
容器。

端口**由运行 ID 派生**：`select_envoy_port_base()` 对 `PERF_RUN_ID` 执行
`cksum`，在 `20000-49999` 范围内取一个 10 端口块；运行开始后把六个实际端口
写入 `${RUNTIME_DIR}/ports.env`，配置、就绪探测和 k6 都读取同一文件，不使用
固定端口。

| 进程 | 端口变量 | 用途 |
|---|---|---|
| HTTP backend | `${ENVOY_BACKEND_PORT}` | 返回固定 `200 OK` 的本地后端 |
| backend admin | `${ENVOY_BACKEND_ADMIN_PORT}` | backend 管理接口 |
| HTTPS direct | `${ENVOY_DIRECT_PORT}` | TLS 入口，直接返回 `200 OK` |
| direct admin | `${ENVOY_DIRECT_ADMIN_PORT}` | direct 管理接口 |
| HTTPS proxy | `${ENVOY_PROXY_PORT}` | TLS 入口，转发到本地 backend |
| proxy admin | `${ENVOY_PROXY_ADMIN_PORT}` | proxy 管理接口 |

三个 Envoy 进程都在容器内启动，日志写到 `${PERF_WORK_DIR}/runtime/`：

```bash
docker exec -d --user "$(id -u):$(id -g)" \
  --env "TMPDIR=${TMPDIR}" "${ENVOY_CONTAINER_NAME}" \
  bash -c "exec '${ENVOY_BIN}' \
    --config-path '${RUNTIME_DIR}/<backend|direct|proxy>.yaml' \
    --disable-hot-restart > '${RUNTIME_DIR}/<name>.log' 2>&1"

# 宿主机只做 HTTPS 就绪探测
curl --silent --show-error --fail --insecure "https://127.0.0.1:${ENVOY_DIRECT_PORT}/"
curl --silent --show-error --fail --insecure "https://127.0.0.1:${ENVOY_PROXY_PORT}/"
```

- **宿主职责边界**：宿主机只负责下载/校验 Envoy 和 k6、生成自签名证书、
  准备结果目录、运行结果解析；不向宿主机安装 Envoy 服务，不在宿主机启动
  Envoy/k6 进程，不修改宿主机系统配置、信任库或软件源。容器内缺运行库时
  只在本次容器内用 `dnf` 安装。
- **独立运行依赖 Docker**：Docker daemon 不可用时，构建/启动阶段以 30/40
  退出码失败，不会回退到宿主机直跑。
- **与整机直跑的差异**：服务端和 k6 客户端都在容器内，使用
  `--network=host` 共享宿主网络栈，因此回环地址与直跑一致；差异主要是
  4 CPU、8 GiB 配额和容器内固定的 nofile 上限。

## 数据与运行顺序

测试不需要外部数据集。以下命令按顺序执行；两个架构使用同一套参数。所有
端口从 `${RUNTIME_DIR}/ports.env` 读取，不能写成固定数字。

1. **准备镜像和 Release 资产**：校验 SHA-256、`docker load` 镜像，确认
   `${ENVOY_BIN}`、`${K6_BIN}` 可执行，并写入 `actual-version.txt`。

```bash
sha256sum -c "${ENVOY_IMAGE_ARCHIVE_DIR}/openEuler-docker.<arch>.tar.xz.sha256sum"
docker load -i "${ENVOY_IMAGE_ARCHIVE_DIR}/openEuler-docker.<arch>.tar.xz"
"${ENVOY_BIN}" --version
"${K6_BIN}" version
```

2. **启动容器和服务**：按 4U8G 参数创建容器，生成 `ports.env`，启动
   backend/direct/proxy 三个 Envoy，并等待两个 HTTPS 入口就绪。

```bash
docker run --detach --name "${ENVOY_CONTAINER_NAME}" \
  --label "boostkit.envoy.run-id=${PERF_RUN_ID}" \
  --cpus=4 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
  --memory=8g --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  "${ENVOY_CONTAINER_IMAGE}" sleep infinity
bash -c 'source "${RUNTIME_DIR}/ports.env"; curl --fail --insecure \
  "https://127.0.0.1:${ENVOY_DIRECT_PORT}/"'
bash -c 'source "${RUNTIME_DIR}/ports.env"; curl --fail --insecure \
  "https://127.0.0.1:${ENVOY_PROXY_PORT}/"'
```

3. **运行 k6 负载**：在容器内执行 `run_k6_benchmark.py`，依次测量 direct 和
   proxy；每个场景 30 个虚拟用户、持续 20 秒，关闭连接复用，TLS 校验跳过。

```bash
docker exec -i --user "$(id -u):$(id -g)" \
  --env "SOFTWARE_VERSION=${SOFTWARE_VERSION}" \
  --env "EXPECTED_ARCH=${EXPECTED_ARCH}" \
  --env "PERF_VARIANT=base" --env "TMPDIR=${TMPDIR}" \
  "${ENVOY_CONTAINER_NAME}" python3 - \
  --k6 "${K6_BIN}" \
  --direct-url "https://127.0.0.1:${ENVOY_DIRECT_PORT}/" \
  --reverse-url "https://127.0.0.1:${ENVOY_PROXY_PORT}/" \
  --output "${RESULTS_DIR}/benchmark_envoy.json" \
  --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" \
  < software/Middleware/envoy/scripts/results/run_k6_benchmark.py
```

4. **停止和清理**：按标签停止并删除本任务容器，复制三个 Envoy 日志到结果
   目录，再清理本次私有运行配置。

```bash
docker stop --time 30 "${ENVOY_CONTAINER_NAME}"
docker rm "${ENVOY_CONTAINER_NAME}"
cp "${PERF_WORK_DIR}/runtime/backend.log" "${RESULTS_DIR}/envoy-backend.log"
cp "${PERF_WORK_DIR}/runtime/direct.log" "${RESULTS_DIR}/envoy-direct.log"
cp "${PERF_WORK_DIR}/runtime/proxy.log" "${RESULTS_DIR}/envoy-proxy.log"
rm -rf "${RUNTIME_DIR}"
```

5. **校验规范化输出**：`run_k6_benchmark.py` 已检查两个场景都有正吞吐且
   `http_req_failed.rate` 为零；这里只确认 JSON 可解析、原始日志非空，报告由
   Framework 在 finalize 阶段生成。

```bash
python3 -m json.tool "${RESULTS_DIR}/benchmark_envoy.json" >/dev/null
test -s "${RESULTS_DIR}/benchmark_envoy_raw.log"
```

| 场景 | 目标地址 | VUs | 时长 | 连接复用 |
|---|---|---:|---:|---|
| `direct_response` | `https://127.0.0.1:${ENVOY_DIRECT_PORT}/` | 30 | 20 s | 关闭 |
| `reverse_proxy` | `https://127.0.0.1:${ENVOY_PROXY_PORT}/` | 30 | 20 s | 关闭 |

两个架构使用相同矩阵。当前用例对每个场景执行一次 20 秒测量，没有预热轮次
和多轮重复采样，因此结果用于同一 runner 上的容器规格对比，不用于计算
benchstat 置信区间；该限制在「已知限制」中明确写出。

## 指标与产物

每个场景从 k6 官方 summary JSON 取四项指标，两个场景合计 **8 项**（单架构
报告 8 项；跨架构只配对名称和参数都相同的这 8 项）。报告按场景分组，分组名
分别为 `HTTPS direct response` 和 `HTTPS reverse proxy`。

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `direct_response :: http_reqs.count` | `direct_response` 的 k6 `http_reqs.count` | requests | 越大越好 |
| `direct_response :: http_reqs.rate` | 同上 summary 的 `http_reqs.rate` | requests/s | 越大越好 |
| `direct_response :: http_req_duration.avg` | 同上 summary 的 `http_req_duration.avg` | ms | 越小越好 |
| `direct_response :: http_req_duration.p(95)` | 同上 summary 的 `http_req_duration.p(95)` | ms | 越小越好 |
| `reverse_proxy :: http_reqs.count` | `reverse_proxy` 的 k6 `http_reqs.count` | requests | 越大越好 |
| `reverse_proxy :: http_reqs.rate` | 同上 summary 的 `http_reqs.rate` | requests/s | 越大越好 |
| `reverse_proxy :: http_req_duration.avg` | 同上 summary 的 `http_req_duration.avg` | ms | 越小越好 |
| `reverse_proxy :: http_req_duration.p(95)` | 同上 summary 的 `http_req_duration.p(95)` | ms | 越小越好 |

指标名、单位和方向与 `case.yaml` 的 `metrics` 一致；`case.yaml` 通过
`benchmark_envoy.json` 的 `results` 集合读取，不在这里重新定义。

| 产物 | 内容 |
|---|---|
| `benchmark_envoy_raw.log` | 两个场景的完整 k6 控制台输出，测试失败时保留 |
| `benchmark_direct_response_summary.json` | direct 场景的 k6 原始 summary |
| `benchmark_reverse_proxy_summary.json` | proxy 场景的 k6 原始 summary |
| `benchmark_envoy.json` | 规范化后的 8 项指标，供 Framework 生成报告 |
| `build_variant.json` | `base` 变体和 Envoy/k6 实际版本 |
| `status.json` | 阶段、退出码和 cleanup 状态 |
| `report.md` | Framework 生成的单架构性能报告 |

解析器严格要求：summary 缺失、指标字段缺失、吞吐不为正、或
`http_req_failed.rate` 非零都会失败；缺样本/多样本不会补零，也不会静默降级。
停止阶段即使清理失败也会先执行删除和日志保留，再由 `status.json` 标记
`cleanup_status`。

## 独立运行

需要可访问的 Docker daemon：

```bash
bash software/Middleware/envoy/envoy_test.sh \
  --version 1.38.6 \
  --variant base \
  --results-dir /home/runner/envoy-results/1.38.6
```

工作目录默认位于 `/home/runner/boostkit-perf/envoy/local-<运行 ID>`，正常
结束后清理，结果目录保留；加 `--keep-workdir` 可保留工作目录排查问题。
`optimized` 未实现，选择后构建阶段返回 30，不会退回 `base`。

入口内部实际展开的关键命令如下（与 Framework 阶段相同）：

```bash
# 1. 下载/校验 Release 资产
sha256sum "${PERF_WORK_DIR}/envoy-install/envoy"
"${ENVOY_BIN}" --version

# 2. 创建 4U8G 容器
docker run --detach --name "${ENVOY_CONTAINER_NAME}" \
  --label "boostkit.envoy.run-id=${PERF_RUN_ID}" \
  --cpus=4 --cpuset-cpus="${cpu_set}" --cpuset-mems="${numa_node}" \
  --memory=8g --network=host --user "$(id -u):$(id -g)" \
  "${ENVOY_CONTAINER_IMAGE}" sleep infinity

# 3. 容器内执行 k6 驱动
docker exec -i "${ENVOY_CONTAINER_NAME}" python3 - \
  --k6 "${K6_BIN}" \
  --direct-url "https://127.0.0.1:${ENVOY_DIRECT_PORT}/" \
  --reverse-url "https://127.0.0.1:${ENVOY_PROXY_PORT}/" \
  --output "${RESULTS_DIR}/benchmark_envoy.json" \
  --raw-output "${RESULTS_DIR}/benchmark_envoy_raw.log" \
  < software/Middleware/envoy/scripts/results/run_k6_benchmark.py

# 4. 校验输出并清理
python3 -m json.tool "${RESULTS_DIR}/benchmark_envoy.json" >/dev/null
test -s "${RESULTS_DIR}/benchmark_envoy_raw.log"
docker rm --force "${ENVOY_CONTAINER_NAME}"
```

## 已知限制

- 需要 Docker daemon；无 daemon 时构建/启动阶段直接失败，不会回退到宿主机
  直跑。
- 当前每个场景只有一次 20 秒 k6 测量，没有 1 次预热 + 至少 5 次有效采样，
  因此不能给出 benchstat 置信区间；容器规格对比使用同一 runner 的成对数据，
  不把单次结果解释为统计显著差异。
- `optimized` 尚未实现，选择后构建阶段明确失败，不会退回基础版。
- 本次正式证据只跑 aarch64 Blue；x86_64 代码路径保留，但不派发 x86_64
  Blue，因此 x86_64 不应被当作正式性能证据。
- 测试使用本次任务生成的自签名证书，k6 明确跳过 TLS 校验；这不是生产 TLS
  配置的评测。
- Envoy 进程由 `docker exec -d` 启动，异常退出依赖就绪探测和 k6 失败上报，
  不保留宿主机 PID 文件。
