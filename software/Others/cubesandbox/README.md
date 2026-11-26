# CubeSandbox 0.8.0 性能测试

CubeSandbox 是基于 RustVMM + KVM 的 MicroVM 沙箱系统，本用例度量它在鲲鹏服务器上的**沙箱冷启动性能**：从模板创建沙箱的端到端时延、分位时延与单位时间创建吞吐量。负载由上游官方基准工具 `cube-bench` 驱动，直接调用 CubeAPI 的 `POST /sandboxes`，不经过 SDK，避免把客户端开销混进被测指标。

**本用例宿主直跑（未容器化）**：被度量栈是一套完整的 CubeSandbox 单机 all-in-one 控制面 + 计算面，依赖 ARM64 KVM（`/dev/kvm`）、XFS reflink（`/data/cubelet`）、systemd 托管的组件，以及 CubeVS/eBPF 网络数据面；把它塞进仓库现行的私有非特权容器既拿不到 KVM 设备，也无法接管宿主网络命名空间，因此不设容器运行时（与 `software/Others/unixbench` 的整机直跑处理一致）。宿主侧的一次性准备由用例幂等完成：缺 XFS reflink 卷就在 `/data` 上建一个 loopback XFS 卷，缺 Compose 插件就装插件，缺部署就调用上游 one-click 安装器；**已预装的节点上这些步骤全部跳过**，可用 `scripts/host/prepare-cubesandbox-host.sh` 预先烘焙专用节点。

架构范围：**aarch64**（鲲鹏 950 裸金属，KVM 原生虚拟化）。宿主独占整机，**不限制 CPU、内存或 NUMA**，不设 cgroup 配额——沙箱创建是 CPU + 内存 + IO 混合型负载，配额会直接改变可测吞吐，因此整机独占是复现前提。

入口脚本 `cubesandbox_test.sh` 与 Framework 六阶段（prepare → build → start → test → stop → finalize）共用同一批阶段函数：`build` 编译 `cube-bench` 并核对版本，`start` 校验 / 补齐部署并准备模板，`test` 执行「1 次预热 + 6 次正式采样」，`stop` 清空本用例创建的沙箱并释放自己创建的卷（模板与安装常驻，供复跑复用）。变体分 `base` 与 `optimized`：`base` 测上游默认部署；调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，不会退回基础版。

复现只需一条命令（见「独立运行」）。结果落在 `--results-dir` 指定的目录；Framework 调用时落在 `.perf-output/Others/cubesandbox/0.8.0/aarch64/<run_id>/`。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| CubeSandbox | [TencentCloud/CubeSandbox](https://github.com/TencentCloud/CubeSandbox) tag `v0.8.0`（commit `41748bb78d6384962b4e417ff9215720ea7472fd`），Apache-2.0 | 由 one-click 安装器部署到 `/usr/local/services/cubetoolbox/`（控制面）与 `/data/cubelet/`（沙箱 CoW 存储）；已预装时直接复用 |
| cube-bench | 同一 tag 的 `examples/cube-bench`；`go.mod` 声明 `go 1.25.0`，用例固定 Go 1.25.0 工具链 | 构建阶段编译到 `${PERF_WORK_DIR}/bin/cube-bench`，不进容器（本用例无容器） |
| 模板镜像 | 默认 `cube-sandbox-cn.tencentcloudcr.com/cube-sandbox/sandbox-code:latest`，由 `CUBESANDBOX_TEMPLATE_IMAGE` 覆盖 | 由 `cubemastercli tpl create-from-image` 从镜像仓库拉取，落在 CubeSandbox 自己的 artifact 存储 |
| Docker 与 Compose | Docker Engine 25.0.3、Compose v2.30.3（上游已验证组合） | 宿主既有依赖；one-click 用它们运行内置 MySQL / Redis / MinIO / cube-proxy。缺 Compose 插件时由用例安装 `docker-compose-linux-aarch64` |
| Python | Python 3（仅标准库） | 宿主解析器与清理脚本，读取 cube-bench JSON 报告，不装第三方包 |

`cube-bench` 是上游自带基准工具（Go + goroutine，直连 CubeAPI），本用例不另写压测客户端，只补「采样编排 + 严格解析 + 清理」三层薄封装，保证指标定义与上游 `docs/blog/posts/2026-06-01-cubesandbox-perf-benchmark.md` 一致。

## CubeSandbox 获取、构建与宿主启动

**获取顺序（离线优先）：公共离线目录 `/home/runner/software/cubesandbox/` → `${PERF_WORK_DIR}` 缓存 → 官方 GitHub Release。** 源码与二进制都落在 `${PERF_WORK_DIR}` 下，不写系统目录。**每个资产只下载一次**：首次下载成功后立刻按原文件名转存到 `/home/runner/software/cubesandbox/`（`CUBESANDBOX_ARCHIVE_DIR`），此后所有运行直接复用，不再访问网络。链接慢的节点可以先手工预热一次：

```bash
bash software/Others/cubesandbox/scripts/host/stage-cubesandbox-artifacts.sh
# 默认写入 /home/runner/software/cubesandbox/，已存在且校验通过的资产直接跳过
```

按架构的包与校验值（上游 `v0.8.0` Release 资产与源码包，SHA-256 均在上游发布时固定）：

| 架构 | 资产 | 大小 | SHA-256 |
|---|---|---|---|
| aarch64 | `cube-sandbox-one-click-v0.8.0-arm64.tar.gz` | 223,970,625 B | `a7dcf6faa80416aab323050aac275e3385a3f49778a46256715608a26a4cb4f4` |
| x86_64 | `cube-sandbox-one-click-v0.8.0-amd64.tar.gz` | 305,860,175 B | `06e0cce7b43cbff831504a3cb21687c69841d6be743125bc32a138929b796ad3` |
| 源码（两架构共用） | `CubeSandbox-0.8.0.tar.gz` | 40,894,189 B | `c2de64cb316580492625a12065158264a5bfb3abd096a04ced0c8743fa0ffeae` |
| Go 工具链（aarch64） | `go1.25.0.linux-arm64.tar.gz` | 57,159,737 B | `05de75d6994a2783699815ee553bd5a9327d8b79991de36e38b66862782f54ae` |

以下是实际命令形态（`build` 阶段：取源码校验 → 编译 `cube-bench` → 记录变体）：

```bash
# 1) 取源码并双重校验（大小 + SHA-256），离线目录优先
mkdir -p "${PERF_WORK_DIR}/src"
cp /home/runner/software/cubesandbox/CubeSandbox-0.8.0.tar.gz "${PERF_WORK_DIR}/" || \
  curl -fsSL --retry 3 -o "${PERF_WORK_DIR}/CubeSandbox-0.8.0.tar.gz" \
    https://github.com/TencentCloud/CubeSandbox/archive/refs/tags/v0.8.0.tar.gz
printf '%s  %s\n' "c2de64cb316580492625a12065158264a5bfb3abd096a04ced0c8743fa0ffeae" \
  "${PERF_WORK_DIR}/CubeSandbox-0.8.0.tar.gz" | sha256sum -c -
tar -xzf "${PERF_WORK_DIR}/CubeSandbox-0.8.0.tar.gz" -C "${PERF_WORK_DIR}/src"

# 2) Go 工具链：宿主 go ≥ 1.25 直接用，否则装固定 1.25.0 到工作目录并校验 SHA-256
"${PERF_WORK_DIR}/goroot/go/bin/go" version

# 3) 编译 cube-bench（禁用 CGO，禁止隐式下载新工具链，模块走国内代理）
cd "${PERF_WORK_DIR}/src/CubeSandbox-0.8.0/examples/cube-bench"
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 GOTOOLCHAIN=local \
  GOPROXY=https://goproxy.cn,direct go build -trimpath -buildvcs=false \
  -o "${PERF_WORK_DIR}/bin/cube-bench" .
"${PERF_WORK_DIR}/bin/cube-bench" --help >/dev/null

# 4) 记录变体，供 finalize 与报表引用
printf '{"variant":"base","parameters":{"variant":"base"}}\n' > "${RESULTS_DIR}/build_variant.json"
```

**宿主与部署前置检查**（缺失即失败，退出码 30 / 40，不做降级）：

```bash
[[ "$(uname -m)" == aarch64 ]]                 || exit 30   # 本用例只针对 aarch64
test -c /dev/kvm                               || exit 30   # KVM 字符设备
sudo -n test -r /dev/kvm                       || exit 30   # runner 需可读（kvm 组或免密 sudo）
getconf GNU_LIBC_VERSION | awk '{exit ($2+0 < 2.31)}' || exit 30
findmnt -no FSTYPE /data | grep -qx xfs        || echo "will create a loopback XFS reflink volume"
xfs_info /data | grep -q 'reflink=1'           || echo "reflink required, the case prepares it"
docker version --format '{{.Server.Version}}'  || exit 30
docker compose version                         || echo "will install compose v2.30.3 plugin"
curl -fsS http://127.0.0.1:3000/health          || echo "will run the one-click installer"
sudo -n true                                   || exit 30   # 安装器与卷管理需要免密 sudo
```

宿主职责边界：宿主机提供 **KVM/XFS 内核能力、Docker 运行时、免密 sudo**；用例负责 **Compose 插件、XFS reflink 卷、one-click 部署、Go 工具链、cube-bench 编译、指标解析**。本用例**不向宿主机安装系统包**（不调用 `dnf` / `apt`）、不修改宿主的软件源、信任库与防火墙，也不停止宿主既有业务服务；它只做可回收的宿主准备：往 `/usr/local/lib/docker/cli-plugins/` 放一个静态 Compose 插件、在 `/data` 上挂一个 loopback XFS 卷、用上游 one-click 拉起内置容器。上述准备默认常驻以便复跑（`CUBESANDBOX_TEARDOWN=1` 时 `stop` 阶段用 `down.sh` 回滚），loopback 卷由本用例创建时会在 `stop` 阶段卸载删除。运行期只写 `/data`（模板与沙箱 CoW 层）与 `${PERF_WORK_DIR}`，`stop` 阶段把本用例产生的沙箱清空。

one-click 安装器会接管宿主 `/etc/resolv.conf`（为 `cube.app` 的 split DNS 起本地 CoreDNS，原文件备份到 `${CUBESANDBOX_TOOLBOX_DIR}/coredns/resolv.conf.upstream`）。用例在安装后**立即执行 `down-dns.sh` 并把安装前的 `resolv.conf` 还原**，再校验解析与 CubeAPI：压测路径全部走 `127.0.0.1:3000`，不需要 `cube.app` 域名，因此不必让 runner 长期承担这次 DNS 接管。还原目标只认「安装前」的文件：优先用用例自己写入并打 `.pre-install` 时间戳的备份，其次用安装器的 `resolv.conf.upstream`，两者都拿不到时保持现状而不是把已被改写的文件当原件——实测该 runner 上被改写的文件首位是 `nameserver 169.254.254.53`（不可达），误当原件还原会让每次解析先等 5 s 超时、`actions/upload-artifact` 的 `CreateArtifact` 直接超时失败，属于必须避免的宿主副作用。

- **脚本出处**：`scripts/builders/dispatch.sh`（`build_cubesandbox` → `scripts/builders/base.sh`）、`scripts/common.sh`（`host_preflight`、`ensure_data_volume`、`ensure_docker_compose`、`provision_cubesandbox`、`restore_host_dns`）、`scripts/host/prepare-cubesandbox-host.sh`（管理员预烘焙专用节点）、`scripts/host/stage-cubesandbox-artifacts.sh`（一次性把三个资产预热进离线目录）。

## 数据与运行顺序

1. **环境与部署自检**：确认架构、KVM、免密 sudo、Docker；`/data` 不是 XFS reflink 卷时用 loopback 卷补齐，Compose 插件缺失时安装，CubeAPI 不健康时调用 one-click 安装器（`CUBESANDBOX_ALLOW_PROVISION=0` 则直接失败）。安装后立刻还原宿主 DNS。

   ```bash
   curl -fsS http://127.0.0.1:3000/health
   free -g | awk 'NR==2{exit ($7 < 8)}'                          # 至少 8 GiB 可用内存
   df -BG /data | awk 'NR==2{gsub("G","",$4); exit ($4 < 50)}'   # /data 至少 50 GB 空闲
   ```

2. **模板准备**：`CUBESANDBOX_TEMPLATE_ID` 已给出则直接使用；否则按镜像创建一个专用模板、等待 `READY`，并把返回的 `tpl-` ID 记到 `${RESULTS_DIR}/template_id`（模板创建不计入指标，模板常驻供复跑复用）。模板就绪后先做一次**真实**的单沙箱冒烟（`-n 1`，不是 `--dry-run`：后者只是本地模拟，不访问 CubeAPI），确认 CubeAPI、模板与清理链路都通。

   ```bash
   cubemastercli tpl create-from-image \
     --image "${CUBESANDBOX_TEMPLATE_IMAGE}" \
     --writable-layer-size 1G --expose-port 49999 --probe 49999 --probe-path / \
     | tee "${PERF_WORK_DIR}/template-create.log" | grep -oE 'tpl-[0-9a-zA-Z]+' | head -1 \
     > "${RESULTS_DIR}/template_id"
   cubemastercli tpl list | grep -F "${CUBESANDBOX_TEMPLATE_ID}"      # 等到 READY
   ```

3. **预热**：并发 1 / 20 / 50 各跑 1 次 `cube-bench`（每次 50 次创建），结果丢弃，只用来预热页缓存、JIT 与调度路径。

   ```bash
   cleanup_sandboxes() {
     local ids
     ids="$(cubemastercli cubebox list --all --size 1000 --quiet)" || return 50
     [ -n "${ids}" ] && printf '%s\n' "${ids}" | \
       cubemastercli --address 127.0.0.1 --port 8089 cubebox destroy >/dev/null
     for _ in $(seq 1 60); do
       [ -z "$(cubemastercli cubebox list --all --size 1000 --quiet)" ] && return 0
       sleep 2
     done
     return 50
   }
   for c in 1 20 50; do
     "${CUBE_BENCH}" -c "${c}" -n 100 -w 3 -m create-only --no-tui \
       --api-url http://127.0.0.1:3000 --api-key e2b_000000 \
       -t "${CUBE_TEMPLATE_ID}" > "${RESULTS_DIR}/runs/c${c}/warmup1.log" 2>&1 || exit 40
     cleanup_sandboxes || exit 50
   done
   ```

4. **正式采样**：同样三档并发，每档重复 6 次，逐次落原始日志与 cube-bench JSON 报告；采样之间必须把沙箱清空，否则后一轮会踩到前一轮的容量与内存压力。

   ```bash
   for c in 1 20 50; do
     for i in $(seq 1 6); do
       "${CUBE_BENCH}" -c "${c}" -n 300 -w 3 -m create-only --no-tui \
         --api-url http://127.0.0.1:3000 --api-key e2b_000000 \
         -t "${CUBE_TEMPLATE_ID}" \
         -o "${RESULTS_DIR}/runs/c${c}/rep${i}.json" \
         > "${RESULTS_DIR}/runs/c${c}/rep${i}.log" 2>&1 || exit 40
       cleanup_sandboxes || exit 50
     done
   done
   ```

5. **清理与校验**：再删一次并轮询确认沙箱数为 0（与上游 `tests/perf/cubebench.sh` 的 `destroy_all_sandboxes` 同语义）；失败时保留 `${RESULTS_DIR}/runs/` 原始日志与全部 JSON，不做静默重试。

   ```bash
   cleanup_sandboxes || exit 50
   [ -z "$(cubemastercli cubebox list --all --size 1000 --quiet)" ] || exit 50
   ```

参数矩阵（并发档位与上游一致；请求数按单节点容量下调到 300，墙钟为本仓库 aarch64 runner 实测）：

| 档位 | 并发 | 每次请求数 | 每档采样 | 预计单次墙钟 | 预计整轮耗时 | 磁盘 |
|---|---|---|---|---|---|---|
| `concurrency_1` | 1 | 300 | 1 预热 + 6 采样 | ≈ 20 s（15.4 创建/s，均值 64.9 ms） | ≈ 3.5 min | 模板 1 GiB 可写层 + 每沙箱 ≈ 25 MiB 增量 |
| `concurrency_20` | 20 | 300 | 1 预热 + 6 采样 | ≈ 5.4 s（55.9 创建/s，均值 347.2 ms） | ≈ 3 min | 同上 |
| `concurrency_50` | 50 | 300 | 1 预热 + 6 采样 | ≈ 5.8 s（51.3 创建/s，均值 909.8 ms） | ≈ 5 min | 同上 |

每档之间的沙箱必须清空；`-w 3` 是 cube-bench 内部的 3 轮预热（结果已丢弃），与本用例外层的「1 次预热」是两层独立的预热，不可省略任一层。整轮实测约 16 分钟（含每轮销毁 300 个沙箱的清理时间），`/data` 至少预留 50 GB（多模板场景 200 GB）；用例创建的 loopback 卷默认 200 GB 稀疏文件。

- **脚本出处**：`scripts/stages/start.sh`（`start_cubesandbox_runtime` 校验部署与模板）、`scripts/stages/test.sh`（`run_cubesandbox_benchmarks`）、`scripts/common.sh`（`cleanup_sandboxes`）、`scripts/results/parse_benchmark.py`。

## 指标与产物

`cube-bench` 的 `-o report.json` 输出结构固定：`summary`（`success_rate`、`throughput_qps`、`total_time_s`）、`create`（`count`、`avg`、`p50`、`p95`、`p99`、`max`）、`delete`、`raw`（逐请求明细）。本用例只取创建侧字段，删除侧不参与评分。

| 报告分组 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| `concurrency_1` / `concurrency_20` / `concurrency_50` | `sandbox-create-success-rate-c<并发>` | `summary.success_rate` × 100 | % | 越大越好 |
| `concurrency_1` / `concurrency_20` / `concurrency_50` | `sandbox-create-latency-mean-c<并发>` | `create.avg` | ms | 越小越好 |
| `concurrency_1` / `concurrency_20` / `concurrency_50` | `sandbox-create-latency-p95-c<并发>` | `create.p95` | ms | 越小越好 |
| `concurrency_1` / `concurrency_20` / `concurrency_50` | `sandbox-create-latency-p99-c<并发>` | `create.p99` | ms | 越小越好 |
| `concurrency_1` / `concurrency_20` / `concurrency_50` | `sandbox-create-throughput-c<并发>` | `summary.throughput_qps` | sandboxes/s | 越大越好 |

指标总数 **15 项** = 3 个并发档位 × 5 项指标；指标名带 `-c<并发>` 后缀是因为 Framework 以指标名做主键（不同档位不能重名），分组仍按并发档位（`concurrency_1`、`concurrency_20`、`concurrency_50`）。每项取 6 次采样的中位数写进 `benchmark_cubesandbox.json`，同时保留 6 个原始样本；方向与 `case.yaml` 的 `metrics` 一致。

| 产物 | 内容 |
|---|---|
| `runs/c<并发>/warmup1.log` | 该档预热轮的完整输出，结果丢弃但保留可追溯 |
| `runs/c<并发>/rep1..rep6.log` | 该档 6 次正式采样的控制台输出 |
| `runs/c<并发>/rep1..rep6.json` | cube-bench 导出的原始 JSON 报告（`summary`/`create`/`raw`） |
| `benchmark_cubesandbox.json` | 15 项指标的中位数、单位、方向、来源字段、样本值与分组 |
| `samples.json` | 每项指标的 6 个原始样本（不聚合，供 benchstat 复算） |
| `results.json` | 独立运行的最终报告（含环境、版本、指标与状态） |
| `status.json` | 状态摘要：`status`、`failed_stage`、`cleanup_status`、`error` |
| `report.md` | 人读报告：架构、状态、指标表 |
| `build_variant.json` | 变体名与参数（`base`） |
| `template_id` | 本次使用的模板 ID，供复跑复用 |

解析严格性：解析器只做「JSON → 结构化」，**不重测、不补零、不降级**。每个 `rep<i>.json` 必须存在且含 `summary` 与 `create` 段、`summary.successful + summary.errors == 300`（与 `-n` 一致）、`create.count == summary.successful`（cube-bench 只为成功的创建记录时延）、`raw` 条数等于 `300`、`success_rate` 在 `(0, 1]` 内；6 个样本缺一即退出 40，出现多余样本同样失败。某档 `success_rate < 1` 时如实记录并在报表标注失败请求数，不重跑掩盖。

## 独立运行

```bash
bash software/Others/cubesandbox/cubesandbox_test.sh \
  --version 0.8.0 --variant base \
  --results-dir /home/runner/cubesandbox-results/0.8.0 \
  --keep-workdir
```

内部实际执行的三段命令（与 Framework 六阶段调用同一批函数）：

```bash
# 构建：编译 cube-bench + 写 build_variant.json
"${PERF_WORK_DIR}/goroot/go/bin/go" version
cd "${PERF_WORK_DIR}/src/CubeSandbox-0.8.0/examples/cube-bench" && \
  CGO_ENABLED=0 go build -trimpath -buildvcs=false -o "${CUBE_BENCH}" .

# 测量：三档并发 × (1 预热 + 6 采样)，每次 300 次创建，create-only
"${CUBE_BENCH}" -c 50 -n 300 -w 3 -m create-only --no-tui \
  --api-url http://127.0.0.1:3000 --api-key e2b_000000 \
  -t "${CUBE_TEMPLATE_ID}" -o "${RESULTS_DIR}/runs/c50/rep1.json"

# 解析：原始 JSON → 指标（严格，缺样本即失败）
python3 software/Others/cubesandbox/scripts/results/parse_benchmark.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --warmups 1 --samples 6 --levels 1,20,50 --total 300 \
  --version 0.8.0 --architecture aarch64 --variant base
```

`--keep-workdir` 保留 `${PERF_WORK_DIR}`（含源码、Go 工具链与二进制）便于复跑；`optimized` 结果落 `…/optimized/` 子目录且不更新基线；选择 `--variant optimized` 会在构建阶段明确失败（见「已知限制」）。

## 已知限制

- **不支持容器化**：CubeSandbox 需要 `/dev/kvm`、XFS reflink、systemd 托管与宿主网络命名空间内的 eBPF/TAP 数据面，且 one-click 会改写宿主 `cube.app` 的 split DNS；仓库现行私有容器模型（不加特权、不接管宿主网络）无法承载，故本用例整机直跑，与 `unixbench` 的处理方式一致。
- **optimized 变体尚未实现**：`scripts/builders/optimized.sh` 只做占位并在被选中时明确失败（退出 40），不会退回 `base`，结果也不会写入 `…/optimized/`。
- **一次运行会准备宿主**：首次在干净 runner 上运行时，用例会安装 Compose 插件、创建 loopback XFS 卷、调用 one-click 安装器并拉起内置容器；这些动作幂等且安装前会备份 `resolv.conf`，装完立即还原。希望完全不改宿主时，先用 `scripts/host/prepare-cubesandbox-host.sh` 预烘焙节点，或设 `CUBESANDBOX_ALLOW_PROVISION=0` 让用例在缺部署时直接失败。
- **只覆盖单机 all-in-one**：多节点集群（`install-compute.sh` + `ONE_CLICK_CONTROL_PLANE_IP`）不在本用例范围内；集群的跨节点调度时延需要单独的用例与拓扑说明。
- **模板镜像需可达**：默认镜像在腾讯云 TCR（实测 runner 可连通），完全离线的节点必须在 `/home/runner/software/cubesandbox/` 预置等价 OCI 镜像并用 `CUBESANDBOX_TEMPLATE_IMAGE` 指过去；镜像不可达时 `start` 阶段退出 40，不跳过模板直接压测。
- **与 BoostKit 文档的版本差异**：`docs/zh/cubesandbox_deployment_user_guide.md` 验证的组合是 CubeSandbox v0.5.1 + Python SDK 0.5.0；本用例固定 **v0.8.0**（当前稳定 Release，ARM64 资产齐备），并用上游 `v0.8.0` 自带的 cube-bench 与默认参数，跨版本比较数值时需注意组件与模板差异。
- **单节点沙箱容量约 400**：`host.quota` 全为 0 时 cubelet 按宿主 CPU/内存自动推算可用额度，本仓库 384 vCPU / 1505 GiB 的 runner 在累计约 400 个并发沙箱后会返回 `ret_code 130597 / no more resource`（实测：预热 100 个未清理时，第 400 次创建开始全部 HTTP 500）。因此每轮采样固定 **300 次创建**（`CUBESANDBOX_TOTAL`），预热只做 **50 次**（`CUBESANDBOX_WARMUP_TOTAL`），每轮结束即销毁本用例创建的沙箱；要压更高并发需先扩节点或调大 cubelet `host.quota`，不要靠跳过清理硬撑。
- **压测会清空沙箱**：`create-only` 模式会累积沙箱，本用例在每轮采样后取 `cubemastercli cubebox list --all --size 1000 --quiet` 的 ID 并 `cubemastercli cubebox destroy` 批量删除（等价于上游 `tests/perf/cubebench.sh` 的 `destroy_all_sandboxes`）。**节点必须独占**，不得与其他业务或他人压测共用，否则会误删其沙箱；模板不删除，常驻复用。
- **6 次采样是置信区间下限**：`benchstat` 需要 ≥ 6 个样本才能给出 p 值，因此固定 6 次而非 5 次；样本更少时只报中位数，不给显著性结论。
- **Go 与模块代理是硬前置**：`examples/cube-bench/go.mod` 声明 `go 1.25.0`（上游 README 写的 “Go 1.21+” 已过时），低于 1.25 的工具链会尝试联网下载新工具链，离线 runner 上会直接失败；用例因此固定 Go 1.25.0、设 `GOTOOLCHAIN=local`，并默认走 `https://goproxy.cn,direct`（可用 `CUBESANDBOX_GOPROXY` 覆盖，多个代理用空格分隔并依次重试）。完全离线时需预置 module cache。
- **下载链路决定首跑时长**：本仓库 ARM64 runner 实测 GitHub Release 直连约 18 KB/s、`gh-proxy.com` 约 99 KB/s、`ghfast.top` 约 217 KB/s，而华为云/阿里云的 Go 镜像可达数十 MB/s；因此三个资产（224 MB one-click、41 MB 源码、57 MB Go）**只下载一次**，成功后立即落盘到 `/home/runner/software/cubesandbox/` 并校验大小与 SHA-256，后续运行全部走离线目录（可用 `CUBESANDBOX_ARCHIVE_DIR` 改路径）。节点首次预热用 `bash scripts/host/stage-cubesandbox-artifacts.sh`。Compose 插件同样会从镜像下载 62 MB 二进制并缓存为 `docker-compose-linux-aarch64`。
- **CLI 位置不写死**：one-click 把 `cubemaster`/`cubemastercli` 装到可配置的安装前缀，通常软链到 `/usr/local/bin`；用例按 `PATH → /usr/local/bin → /usr/local/sbin → /usr/local/services/*/bin → /opt/cubesandbox/bin → find` 的顺序解析，找不到时在日志里直接报错，不会静默跳过清理。
- **`/data` 只释放自己创建的卷**：只有当本次运行写下 `${RESULTS_DIR}/data_volume` 时，`stop` 才会卸载 loopback 卷并删除镜像文件；节点上预装的 `/data` 保持原样。
- **沙箱网段必须避开宿主**：上游默认 `192.168.0.0/18` 与多数办公网/`docker0` 重叠，安装器的 CIDR 预检会直接失败（实测 runner 上就撞到 `default CubeSandbox network CIDR '192.168.0.0/18' conflicts with existing host network`）。用例在安装前用 `ip addr`/`ip route` 枚举宿主网段，从 `10.240.0.0/16 → 10.241.0.0/16 → 10.242.0.0/16 → 172.28.0.0/16 → 172.29.0.0/16 → 192.168.128.0/17` 里挑第一个不重叠的网段，通过 `CUBE_SANDBOX_NETWORK_CIDR` 传给安装器并记录到 `${RESULTS_DIR}/sandbox_network_cidr`；需要固定网段时直接设 `CUBESANDBOX_NETWORK_CIDR`。
- **cube-proxy 的 fd 上限**：`cube-proxy` 用 OpenResty，模板写的是 `worker_processes auto` + `worker_rlimit_nofile 100000`；本仓库 runner 上的容器只有 `RLIMIT_NOFILE=1024`（dockerd 内置默认，`/etc/docker/daemon.json` 不存在），nginx 无法把上限提到 100000（`setrlimit ... Operation not permitted`），在 384 vCPU 上按 `auto` 起 384 个 worker 时，每个 worker 的 `reuseport` 监听套接字就会把 1024 个描述符耗尽，容器反复输出 `socket() 0.0.0.0:9090 failed (24: No file descriptors available)`，`cube-sandbox-cube-proxy.service` 永远停在 `start-post`，安装器的 quickcheck 因此报 `expected systemd unit not active`。用例在安装前用 `ONE_CLICK_RUN_QUICKCHECK=0` 跳过安装器自带的 120 s 检查，安装后把 `${CUBESANDBOX_TOOLBOX_DIR}/cubeproxy/nginx.conf.template`（及已渲染的 `nginx.conf`）的 `worker_processes auto;` 改成 `worker_processes ${CUBESANDBOX_PROXY_WORKERS}`（默认 16）并重启该 unit，然后用用例自己的就绪门（关键 unit 全部 active + `CubeAPI /health` 返回 200，最长 180 s）判定安装成功。`CUBESANDBOX_PROXY_WORKERS` 可覆盖；节点若已把容器 nofile 调整到 ≥ 4096，用例检测到后不会改配置。
- **cgroup 版本**：上游文档要求 cgroup v2；若 runner 只有 cgroup v1，安装器可能失败，此时 `start` 阶段退出 40 并在日志里保留安装器输出，不做降级。

## 与参考材料的关系

- 部署与 ARM64 适配步骤改编自 BoostKit《CubeSandbox 鲲鹏适配和优化 用户指南》（`boostkit/cloud-native` 仓库 `docs/zh/cubesandbox_deployment_user_guide.md`）。
- 指标定义、并发档位与参数（`-c/-n/-w/-m create-only`）对齐上游官方基准报告 [CubeSandbox Core Operations Performance Benchmark Report](https://github.com/TencentCloud/CubeSandbox/blob/master/docs/blog/posts/2026-06-01-cubesandbox-perf-benchmark.md)，模板制作命令对齐 [模板文档](https://github.com/TencentCloud/CubeSandbox/blob/master/docs/zh/guide/templates.md)。
- 上游 `tests/perf/cubebench.sh` 是同类自动化脚本，本用例没有直接调用它（它会执行 3.x/4.x 全部场景并删除节点上所有沙箱），只复用了它的清理语义与矩阵参数。

## 故障排查

| 现象 | 处理 |
|---|---|
| `start` 退出 30，`/dev/kvm` 不存在 | 宿主机未开启 KVM 或未暴露设备；确认 `lsmod \| grep kvm`、`/dev/kvm` 字符设备，以及 BIOS/云主机嵌套虚拟化开关 |
| `xfs_info` 无 `reflink=1` | `/data` 不是 XFS 或未开 reflink；用例会自动建 loopback 卷，若 `losetup`/`mount` 被策略禁止则需管理员按 prepare 脚本处理 |
| one-click 安装失败 | 查看 `${PERF_WORK_DIR}/one-click-install.log`；常见原因是 cgroup v1、镜像仓库不可达、缺少 `resolvectl`/NetworkManager（可设 `CUBE_PROXY_DNSMASQ_MODE=standalone`） |
| 安装器报 `default CubeSandbox network CIDR '192.168.0.0/18' conflicts with existing host network` | 用例会自动挑选不冲突的 `/16`；要手工指定时设 `CUBESANDBOX_NETWORK_CIDR=10.240.0.0/16` 之类的空闲网段 |
| 安装器报 `expected systemd unit not active: cube-sandbox-cube-proxy.service` | 容器 `nofile` 只有 1024，OpenResty 按 `worker_processes auto` 起满核 worker 时 fd 不足（日志里是 `socket() 0.0.0.0:9090 failed (24: No file descriptors available)`）；把 `nginx.conf.template` 的 `worker_processes` 改成 8~16 并重启 unit，或调大容器 ulimit（`CUBESANDBOX_PROXY_WORKERS` 控制前者） |
| `cubemastercli: command not found` | 说明安装器没有真正执行完（常见于 one-click 包下载/解压失败）；用例按安装前缀解析 CLI，仍找不到时先看 `one-click-install.log`，再确认 `/usr/local/bin` 下是否有 `cubemaster*` |
| `curl /health` 失败但 systemd 显示 active | 控制面依赖 MySQL/Redis/内置 MinIO 未起来；按上游 one-click 文档检查 `cube-sandbox-support*.service` 与 `docker ps` |
| `cube-bench` 大量 `context deadline exceeded` | 并发档位超过宿主机容量（`host.quota` 限制或内存不足）；按上游文档调大 cubelet `host.quota`，或降低 `CUBESANDBOX_LEVELS` |
| 模板长时间不 `READY` | 镜像拉取失败或 `--probe` 端口未就绪；查看 `/data/log/CubeVmm/vmm.log` 与模板构建日志后重试 |
| `stop` 后仍有沙箱 | 清理按 `cubemastercli cubebox list --all --size 1000 --quiet` + `cubemastercli cubebox destroy` 逐个删除；若列表读不到，先确认 CubeMaster 健康再重试，避免残留影响后续压测 |
| 安装后宿主解析异常 | 用例会在安装后执行 `down-dns.sh` 并还原 `resolv.conf`；若中断，优先用 `${CUBESANDBOX_TOOLBOX_DIR}/coredns/resolv.conf.upstream`（安装器自己备份的原件）手工还原，其次才用 `${PERF_WORK_DIR}/resolv.conf.before-cubesandbox`（缺 `.pre-install` 标记说明它不是安装前抓的） |

## 许可证

CubeSandbox 采用 Apache-2.0（含若干第三方组件，详见上游 `LICENSE`）；`cube-bench` 与被复制进本用例的解析逻辑同样遵循该许可证。
