# E2B 2026.09 性能测试

E2B 是沙箱基础设施（sandbox-as-a-service）的开源实现：控制面负责模板、团队与配额，计算节点用 Firecracker 微虚拟机承载每个沙箱。本用例部署 openEuler 发布的自包含包 `e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm`，用 BoostKit `sandbox-bench` 通过 E2B HTTP API 测量**沙箱创建**的端到端时延、分位数与吞吐，并按并发档位分组报告。

架构范围：**aarch64**（鲲鹏 950 裸金属，KVM 原生虚拟化）。宿主独占整机，**不限制 CPU、内存或 NUMA**，不设 cgroup 配额——被测对象是「控制面 + Firecracker 计算节点 + Harbor 镜像仓库 + Nomad/Consul 编排」的整套栈，每个沙箱固定 2 vCPU / 2048 MiB，配额会直接改变可测吞吐，因此整机独占是复现前提。

入口脚本 `e2b_test.sh` 与 Framework 六阶段（prepare → build → start → test → stop → finalize）共用同一批阶段函数：`build` 装好 RPM 与依赖、编译 `sandbox-bench`，`start` 拉起控制面并构建基准模板，`test` 执行「1 次预热 + 6 次正式采样」，`stop` 清空本用例创建的沙箱（部署常驻，供复跑复用）。变体分 `base` 与 `optimized`：`base` 测上游默认部署；调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，不会退回基础版。

> 本用例是**宿主模式**（host-mode），不是容器化用例：上游只提供裸机安装路径（Firecracker 需要 `/dev/kvm`、宿主 hugepages 与宿主网络），没有任何容器化发行方式。容器六项硬要求在本文中逐项给出等价事实与「不适用」理由，不做留空。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | openEuler 24.03 LTS SP3 发布的 `e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm`（含控制面、模板管理、Nomad/Consul/Harbor 依赖与 `build.sh`/`deploy.sh`） | 安装到宿主机 `/opt/e2b-infra`，工件缓存于 `/home/runner/software/e2b/dl/` |
| 测试工具 | BoostKit `sandbox-bench`（Go module `sandbox-bench2`，`go 1.24`），源码 `boostkit/cloud-native` 的 `pkg/sandbox-bench/bench/`，分支 `br_26.3.0_devel` | 源码缓存为 `/home/runner/software/e2b/src/sandbox-bench-br_26.3.0_devel.tar.gz`，可执行文件 `${PERF_WORK_DIR}/bin/sandbox-bench`（宿主机编译） |
| 沙箱基础镜像 | 被测沙箱的 rootfs 取自 RPM 内置的 `dep/ubuntu-22.04-custom.tar.gz`（71639898 字节，SHA-256 `50bab006afcaa05e00f927bc75ba2c78288734d5adefa3bfe3af1d831991563f`，安装时 `docker load` 成 `ubuntu:22.04-custom`） | 模板构建阶段推送到本地 Harbor `${SERVER_IP}:2900/e2b-orchestration/ubuntu:22.04-custom`，模板 ID 落 `${RESULTS_DIR}/template_id` |
| 容器基础镜像 | **不适用**：本用例不使用 openEuler 容器基础镜像，也没有 `docker run` 被测容器；上游没有容器化部署方式（详见「已知限制」第 1 条） | 无 |
| Go 工具链 | `go1.24.5.linux-arm64.tar.gz`（`sandbox-bench` 的 `go.mod` 要求 1.24） | 缺失时解压到 `/usr/local/go`，归档缓存于 `/home/runner/software/e2b/dl/` |

本用例没有「宿主机编译、不进容器」之外的组件：`sandbox-bench` 客户端跑在宿主机上，通过 loopback 访问控制面 API，指标解析器也跑在宿主机。

## E2B 获取、构建与宿主启动

获取顺序固定为三段：**公共离线目录** `/home/runner/software/e2b/dl/` → **本任务缓存** `${PERF_WORK_DIR}` → **官方下载地址**。命中前两段时不再联网；三个来源都按大小与 SHA-256 双重校验，任一不符立即失败（不降级、不重试到别的版本）。首次预热可用 `bash scripts/host/stage-e2b-artifacts.sh`，它只做下载与校验。

按架构的资产与校验值（上游发布时固定，全部为 aarch64）：

| 架构 | 资产 | 大小（字节） | SHA-256 |
|---|---|---|---|
| aarch64 | `e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm` | 155357261 | `19a5363465e7afeaaab7c9ab3387a6d56a04c69b7b0405eac503a9d9d9f1025c` |
| aarch64 | `harbor-offline-installer-aarch64-v2.13.0.tgz` | 669795545 | `4c2c6b2055e79c364166529349187d5edc78055941ffec3d5b4e70269f778320` |
| aarch64 | `docker-25.0.5.tgz` | 65952372 | `cf3529e0e4d46f83c4c57df4f986df86f011313359d86f33b5bfe6f333f12063` |
| aarch64 | `consul_1.21.4_linux_arm64.zip` | 65632148 | `50a1b6467a038166684fee25b70ebe9d710e154bd5a179f3e07c655c829646ea` |
| aarch64 | `nomad_1.10.4_linux_arm64.zip` | 51166703 | `ebc53a0c232d251f8428d3af45400677c72ec530cc93042d95c60bf34e020169` |
| aarch64 | `firecracker-v1.13.1-aarch64.tgz` | 7239827 | `3ae4006ccb33a068f41d93a9c488cad17356bb9c22418e3c7efc7ca2256a6e84` |
| aarch64 | `go1.24.5.linux-arm64.tar.gz` | 74805101 | `0df02e6aeb3d3c06c95ff201d575907c736d6c62cfa4b6934c11203f1d600ffa` |

以下是实际命令形态（`${E2B_ARCHIVE_DIR}` 默认 `/home/runner/software/e2b`，`${E2B_INSTALL_DIR}` 默认 `/opt/e2b-infra`）：

```bash
# 1) 下载/复用 7 个工件并校验大小与 SHA-256（离线目录优先，命中即跳过下载）
curl -fSL --retry 3 -o "${PERF_WORK_DIR}/e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm" \
  "https://eulermaker.openeuler.openatom.cn/api/ems5/repositories/2403sp3/openEuler%3A24.03-LTS-SP3/aarch64/history/5bce9a46-4aad-11f1-a4a9-fa163e474048/last/Packages/e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm"
printf '%s  %s\n' "19a5363465e7afeaaab7c9ab3387a6d56a04c69b7b0405eac503a9d9d9f1025c" \
  "${PERF_WORK_DIR}/e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm" | sha256sum -c -

# 2) 安装 RPM（幂等：已安装则跳过），并把 6 个依赖归档放进 vendored dep/ 目录
sudo -n rpm -ivh "${PERF_WORK_DIR}/e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm"
sudo -n cp -f "${PERF_WORK_DIR}"/{docker-25.0.5.tgz,harbor-*.tgz,consul_*.zip,nomad_*.zip,firecracker-*.tgz} \
  "${E2B_INSTALL_DIR}/dep/"

# 3) 给共享 runner 打 6 处补丁（详见「已知限制」第 4 条），补丁幂等、可重复执行
sudo -n python3 "software/Others/e2b/scripts/host/patch-e2b-shared-runner.py" \
  --build-sh "${E2B_INSTALL_DIR}/build.sh" --deploy-sh "${E2B_INSTALL_DIR}/deploy.sh"

# 4) 安装依赖与镜像（nginx、dnsmasq、python wheel、Harbor、api/client-proxy 镜像）
sudo -n bash -c "cd '${E2B_INSTALL_DIR}' && bash build.sh --install"

# 5) 编译 sandbox-bench（宿主机 Go 1.24+；模块不联网，源码取自缓存）
cd "${PERF_WORK_DIR}/src/sandbox-bench" && go build -trimpath -o "${PERF_WORK_DIR}/bin/sandbox-bench" .
```

宿主职责边界：宿主机提供 **KVM（`/dev/kvm`）、hugepages、Docker daemon、免密 sudo**；用例负责 **工件缓存与校验、RPM 安装、6 处补丁、`build.sh --install/--start`、模板构建、`sandbox-bench` 编译、指标解析**。与容器化用例不同，本用例确实**会在宿主机安装软件**——这是上游唯一支持的部署方式，安装内容与影响面在「已知限制」第 2 条逐项列清；补丁把其中最危险的三处（替换宿主 Docker、重启 `dockerd`、清空 `iptables`）改成保留宿主现状。

容器六项在本用例的等价事实（逐项对照，不留空）：

| # | 事实 | 本用例的写法 |
|---|---|---|
| 1 | 镜像来源与校验 | 部署面不用容器镜像；沙箱 rootfs 来自 RPM 内置的 `dep/ubuntu-22.04-custom.tar.gz`，安装时 `docker load`，再推送到本地 Harbor（`docker push`，不访问 Docker Hub） |
| 2 | 容器名与标签 | 没有被测容器，故没有 `boostkit.e2b.run-id` 标签与容器名规则；沙箱由控制面按模板 ID 创建，清理走 `DELETE /sandboxes/<id>`（不使用 `docker ps` 匹配） |
| 3 | 挂载 | 无容器挂载；`${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 直接落在宿主机，沙箱内不挂载宿主路径 |
| 4 | 宿主职责边界 | 见上一段：宿主机承担 KVM/hugepages/Docker/sudo，用例承担安装、补丁、模板、客户端与解析；宿主改动清单在「已知限制」第 2 条 |
| 5 | 与整机直跑的差异 | 本用例**就是整机直跑**：客户端 `sandbox-bench` 在宿主机，经 `http://127.0.0.1:3000` 访问控制面；沙箱间通信走 Firecracker 的 tap 设备与宿主转发，不使用 `--network=host`（也没有 `docker run`） |
| 6 | 独立运行依赖 docker | 必须有可用的 Docker daemon（`sudo docker version`），Harbor、api、client-proxy、redis 都以容器运行；缺失时 `start` 退出 30 |

## 数据与运行顺序

1. **准备（build）**：定位/校验 7 个工件 → 安装 RPM → 打补丁 → `build.sh --install` → 编译 `sandbox-bench`，并把实际版本写入 `${PERF_ACTUAL_VERSION_FILE}`。

```bash
# 版本与宿主前置检查：aarch64、/dev/kvm、免密 sudo、docker daemon、python3、curl
uname -m && ls -l /dev/kvm && sudo -n docker version --format '{{.Server.Version}}'
grep -E 'HugePages_Total|Hugepagesize' /proc/meminfo   # Firecracker 需要预先保留 hugepages

# 安装 + 补丁 + 依赖（命令形态见上一节第 2~4 步），随后编译客户端
cd "${PERF_WORK_DIR}/src/sandbox-bench" && go build -trimpath -o "${PERF_WORK_DIR}/bin/sandbox-bench" .
```

2. **启动（start）**：拉起控制面。`deploy.sh` 内部用 `docker exec -it` 初始化数据库，必须有终端，所以整段用 `script -qec` 包一层；`--start` 幂等，已在运行则直接进入健康检查。

```bash
# 伪终端包装（deploy.sh 的 psql 初始化依赖 TTY），超时 2400 秒
sudo -n bash -c "cd '${E2B_INSTALL_DIR}' && timeout 2400 script -qec 'bash build.sh --start' /dev/null"

# 健康检查：控制面 /health 返回 200（最多等 90 × 5 秒）
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/health

# 模板：把 ubuntu:22.04-custom 推进本地 Harbor，再让模板管理器构建（幂等，已 READY 则复用）
sudo -n docker tag ubuntu:22.04-custom "${SERVER_IP}:2900/e2b-orchestration/ubuntu:22.04-custom"
sudo -n docker push "${SERVER_IP}:2900/e2b-orchestration/ubuntu:22.04-custom"
sudo -n env E2B_API_URL=http://127.0.0.1:3000 E2B_API_KEY="$(cat /root/.e2b/config.json | python3 -c 'import json,sys;print(json.load(sys.stdin)["teamApiKey"])')" \
  python3 software/Others/e2b/scripts/template/create_bench_template.py --alias e2b-bench
```

模板必须用 **Ubuntu** 基底：模板管理器的 `provision.sh` 在沙箱内检查 `/etc/os-release`，Debian 基底会直接 `Unsupported OS: debian` 并以 `error waiting for provisioning sandbox: exit status: 1` 失败（实测）。首发构建把镜像层解包后约 2 秒进入 provisioning，Ubuntu 基底约 4 秒转 READY。

占位符取值：`${SERVER_IP}` 是宿主机 LAN 地址（`ip -4 route get 1.1.1.1` 输出里的 `src`，本机为 `192.168.20.14`），安装阶段写入 `/opt/e2b-infra/dep/.env` 的 `export SERVER_IP=`——上游该字段默认为空，而 PostgreSQL、MinIO、Harbor 地址都由它派生；`${E2B_API_KEY}` 取 `/root/.e2b/config.json` 的 `teamApiKey`，`${E2B_TEMPLATE_ID}` 取 `${RESULTS_DIR}/template_id`。

3. **预热**：每个并发档位先跑 1 轮预热（10 次创建），不计入统计，仅用于让模板层进入宿主 page cache、Nomad 分配稳定。

```bash
E2B_API_URL=http://127.0.0.1:3000 E2B_API_KEY="${E2B_API_KEY}" E2B_TEMPLATE_ID="${E2B_TEMPLATE_ID}" \
  "${PERF_WORK_DIR}/bin/sandbox-bench" --platform infra --scenario create \
  --requests 10 --concurrency "${LEVEL}" --rounds 1 --warmup 0 \
  --output "${RESULTS_DIR}/runs/create/c${LEVEL}/warmup1.json"
```

4. **正式采样**：每个档位 6 轮，每轮 60 次创建；每轮结束立即清空本轮沙箱，避免累计内存与 hugepage 占用影响下一轮。

```bash
E2B_API_URL=http://127.0.0.1:3000 E2B_API_KEY="${E2B_API_KEY}" E2B_TEMPLATE_ID="${E2B_TEMPLATE_ID}" \
  "${PERF_WORK_DIR}/bin/sandbox-bench" --platform infra --scenario create \
  --requests 60 --concurrency "${LEVEL}" --rounds 1 --warmup 0 \
  --output "${RESULTS_DIR}/runs/create/c${LEVEL}/rep${i}.json"

# 清理：列出并逐个删除本轮创建的沙箱，直到 GET /sandboxes 返回空数组
curl -sS -H "X-API-Key: ${E2B_API_KEY}" http://127.0.0.1:3000/sandboxes
curl -sS -X DELETE -H "X-API-Key: ${E2B_API_KEY}" http://127.0.0.1:3000/sandboxes/"${SANDBOX_ID}"
```

5. **解析（finalize）**：把 3 档 × 6 轮的 JSON 汇总为 `${RESULTS_DIR}/benchmark_e2b.json`，再由独立入口写 `results.json` / `report.md` / `status.json`。

```bash
python3 software/Others/e2b/scripts/results/parse_benchmark.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --warmups 1 --samples 6 --levels 1,10,20 --scenarios create --total 60 \
  --version 2026.09 --architecture aarch64 --variant base
```

参数矩阵（两个架构用同一矩阵；本用例只有 aarch64）：

| 档位 | 并发 | 每轮创建数 | 预热 | 正式轮数 | 单轮预计耗时 | 峰值内存 |
|---|---|---|---|---|---|---|
| c1 | 1 | 60 | 1 轮 × 10 次 | 6 | 约 25 秒 | 约 2 GiB |
| c10 | 10 | 60 | 1 轮 × 10 次 | 6 | 约 20 秒 | 约 20 GiB |
| c20 | 20 | 60 | 1 轮 × 10 次 | 6 | 约 20 秒 | 约 40 GiB |

前置检查：`/dev/kvm` 存在且可读；宿主预留 hugepages（安装流程按内存比例写入 `nr_hugepages`，实例见「已知限制」第 5 条）；根分区与 `/home` 至少 100 GiB 可用（Harbor 数据卷 + 模板层 + 沙箱可写层）。失败时保留 `${RESULTS_DIR}` 全部原始 JSON 与日志；`stop` 阶段仍会清空沙箱。

磁盘与状态：模板与部署常驻（复跑直接复用），沙箱按轮次创建/删除，`stop` 阶段做最终兜底清理。

- **脚本出处**：`scripts/builders/{dispatch,base}.sh`、`scripts/stages/{start,test,stop}.sh`、`scripts/host/{stage-e2b-artifacts,install-e2b-suite}.sh`、`scripts/template/create_bench_template.py`、`scripts/results/parse_benchmark.py`

## 指标与产物

`create` 场景 3 个并发档位 × 6 项指标 = **18 项**；若显式启用 `snapshot` 场景（`E2B_SCENARIOS=create,snapshot`）则再加 18 项，**共 36 项**。分组规则：`group=concurrency_<档位>`（`concurrency_1` / `concurrency_10` / `concurrency_20`），指标名以 `-c<档位>` 结尾以便框架按名唯一索引。

| 报告分组 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| 各并发档位 | `sandbox-<scenario>-success-rate` | `sandbox-bench` 报告 `summary.success_rate`（×100） | % | 越大越好 |
| 各并发档位 | `sandbox-<scenario>-latency-p50` | 同一报告 `summary.p50_ms` | ms | 越小越好 |
| 各并发档位 | `sandbox-<scenario>-latency-p95` | `summary.p95_ms` | ms | 越小越好 |
| 各并发档位 | `sandbox-<scenario>-latency-p99` | `summary.p99_ms` | ms | 越小越好 |
| 各并发档位 | `sandbox-<scenario>-throughput` | `summary.throughput_per_sec`（成功数 ÷ 整轮 wall 秒） | sandboxes/s | 越大越好 |
| 各并发档位 | `sandbox-<scenario>-delete-latency-p50` | `delete_summary.p50_ms` | ms | 越小越好 |

时延口径：`sandbox-bench` 对每个请求分别记录 `post_ms`（POST /sandboxes 的纯 HTTP 往返）与 `ready_ms`（随后的就绪轮询），`duration_ms = post_ms + ready_ms`，本用例的 `latency-*` 采用 `duration_ms` 分位数，因此同时覆盖「控制面受理」与「沙箱就绪」两段。单位与方向与 `case.yaml` 的 `metrics` 完全一致（`higher_is_better` / `lower_is_better`）。

采样规则：每档 1 次预热 + 6 次正式采样，取 **6 个样本的中位数**（保留全部样本于 `samples.json`）。需要 benchstat 置信区间时 6 个样本已满足 `≥6` 的要求。

解析严格性：解析器只做「原始 JSON → 结构化」，**不重新测量、不补零、不降级**。以下任一情况直接失败（退出码 40）并打印原因：缺 `rep<i>.json` 或 `rep<i>.log`、缺 `warmup<i>.log`、出现多余的 `rep*.json`、`summary.planned` 与 `--total` 不符、`failed`/`not_executed` 非 0、`success_rate < 1.0`、`delete_summary.success_rate < 1.0`、事件数少于计划数、任一请求 `timed_out`、样本数少于 5、预热轮数少于 1。

产物清单：

| 产物 | 内容 | 生成方 |
|---|---|---|
| `runs/<scenario>/c<level>/warmup<i>.{json,log}` | 预热轮原始报告与终端日志 | `test` 阶段 |
| `runs/<scenario>/c<level>/rep<i>.{json,log}` | 正式轮原始报告与终端日志（每轮 60 次创建） | `test` 阶段 |
| `benchmark_e2b.json` | 汇总指标（`results` 字典，18 项）+ 采样参数 + `metric_count` | `parse_benchmark.py` |
| `samples.json` | 每个指标的全部 6 个样本值 | `parse_benchmark.py` |
| `build_variant.json` | 变体与 RPM 版本 | `build` 阶段 |
| `template_id` | 本次使用的模板 ID | `start` 阶段 |
| `build-install.log` / `build-start.log` / `template-create.log` | 安装、启动、模板构建日志 | `build` / `start` 阶段 |
| `system_info.json` / `runtime_before.json` / `runtime_after.json` | 宿主环境与运行前后状态（hugepages、`/dev/kvm`、API 健康、容器列表） | 独立入口 |
| `results.json` / `status.json` / `report.md` | 独立入口的最终结果、状态摘要、可读报告 | 独立入口 |

Framework 六阶段只产出前 6 项；后 3 项由独立入口 `e2b_test.sh` 生成。

## 独立运行

```bash
bash software/Others/e2b/e2b_test.sh \
  --version 2026.09 --variant base \
  --results-dir /home/runner/e2b-results/2026.09
```

内部实际执行的命令（与六阶段同一批函数，逐条摊开）：

```bash
# build：工件校验 → rpm -ivh → dep 归档 → 6 处补丁 → build.sh --install → go build sandbox-bench
sudo -n rpm -ivh "${PERF_WORK_DIR}/e2b-infra-2026.09-3.oe2403sp3.aarch64.rpm"
sudo -n python3 software/Others/e2b/scripts/host/patch-e2b-shared-runner.py \
  --build-sh /opt/e2b-infra/build.sh --deploy-sh /opt/e2b-infra/deploy.sh
sudo -n bash -c "cd /opt/e2b-infra && bash build.sh --install"

# start：控制面（伪终端）+ 健康检查 + 模板 + 1 次冒烟创建
sudo -n bash -c "cd /opt/e2b-infra && timeout 2400 script -qec 'bash build.sh --start' /dev/null"
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3000/health
sudo -n python3 software/Others/e2b/scripts/template/create_bench_template.py --alias e2b-bench

# test：3 档 × (1 预热 + 6 采样)，每轮后清理沙箱
"${PERF_WORK_DIR}/bin/sandbox-bench" --platform infra --scenario create \
  --requests 60 --concurrency 1 --rounds 1 --warmup 0 \
  --output "${RESULTS_DIR}/runs/create/c1/rep1.json"

# 解析：原始 JSON → 指标（严格，缺样本即失败）
python3 software/Others/e2b/scripts/results/parse_benchmark.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --warmups 1 --samples 6 --levels 1,10,20 --scenarios create --total 60
```

可调参数：`--scenarios create[,snapshot]`、`--levels 1,10,20`、`--samples 6`、`--teardown`（`stop` 阶段额外执行 `build.sh --stop`）、`--keep-workdir`。`optimized` 变体未实现，选择后构建阶段返回 40。

## 已知限制

1. **仅 aarch64、且无法在 x86_64 上跑通**：openEuler 只发布 `aarch64` 的 `e2b-infra` RPM 与 Firecracker 二进制，仓库的 x86_64 本地六阶段验收对本用例不成立——本用例的证据只认 aarch64 Blue run（`PERF_RUNNER_ARM64`）。这也是它与其他用例最大的差异。
2. **会在宿主机安装软件（上游唯一途径）**：`build.sh --install` 会 `dnf install nginx dnsmasq`、`pip install e2e==2.9.0 / e2b SDK`、安装 Nomad/Consul/Firecracker 二进制、`docker load` 镜像、把 Harbor 数据写到 `/opt/e2b-infra`，并按内存比例保留 hugepages；`--start` 还会写 `/etc/hosts` 的 `harbor` 条目与 `iptables` OUTPUT 重定向（`127.0.0.1:80 → 3002`）。这些改动随安装常驻，`--teardown` 只停服务不卸载；接受本用例前请确认该 runner 可被独占占用。
3. **离线 runner 无 Docker Hub**：`download.docker.com` 与 `index.docker.io` 在 runner 上不可达（实测 `http=000`）。因此 Docker 静态包取自阿里云镜像，Harbor 安装包经 `gh-proxy.com`，沙箱基底镜像用 RPM 自带的 `ubuntu:22.04-custom` 并从本地 Harbor 拉取；模板构建若引用 `debian`/`ubuntu` 官方标签会因 `index.docker.io` 超时失败。
4. **对上游脚本打了 6 处补丁**（`scripts/host/patch-e2b-shared-runner.py`，幂等）：`install_docker` 保留宿主 Docker（只刷新 compose，不替换 `/usr/bin/dockerd`）；`setenforce 0` 仅在 enforcing 时执行；两处 `systemctl restart docker` 改为 `reload`（避免杀掉宿主既有容器）；删除 `iptables -F`（不清空宿主防火墙规则）；`deploy.sh` 的 `docker exec -it psql` 依赖 TTY（由 `script -qec` 提供）；`seed-db` 交互式询问 `Email:` 改为从 stdin 喂入（否则 33 分钟阻塞且团队 API Key 仍是占位值，`/templates` 会返回 401）。补丁不改变被测栈的任何性能相关参数。
5. **hugepages 与内存**：安装脚本按内存比例保留 hugepages（本机实测 `HugePages_Total=149847`，约 293 GiB / 2 MiB 页）。这是 Firecracker 的硬要求，但会长期减少宿主可用常规内存；跑完后如需归还，执行 `sysctl vm.nr_hugepages=0`。
6. **与 CubeSandbox 用例互斥**：两者都要占用 `:80/:3000/:5432/:9000/:2900` 与宿主 nginx/dnsmasq，且都会改 `iptables`/`/etc/hosts`；同一台 runner 上不可并发，先跑完一个再跑另一个（CubeSandbox 用例会停掉 E2B 的 nomad/consul 单元，E2B 的 Harbor 也会占用 80 端口）。
7. **`optimized` 未实现**：选择后构建阶段明确失败、不退回基础版。
8. **快照/恢复语义**：E2B 的 `snapshot` 是「持久化模板（近似 commit）」，不是内存快照；`rollback` 无端点（预期 404 `no matching operation was found`），`restore` 需要 `--snapshot-id`，`multi-image` 需要 `--images-file`。本用例默认只测 `create`，其余场景按需显式开启，不与 create 的数字并列比较。

## 故障排查

| 现象 | 判断/处理 |
|---|---|
| `start` 退出 30，`/dev/kvm` 不存在 | 宿主未开 KVM 或设备未暴露；确认 `lsmod \| grep kvm`、`/dev/kvm` 字符设备与 BIOS/嵌套虚拟化开关 |
| `build.sh --start` 报 `PostgreSQL 启动失败` | `deploy.sh` 的 `docker exec -it psql` 缺 TTY；必须用 `script -qec` 包装（本用例已内置） |
| `docker push` 报 `unauthorized: project e2b-orchestration not found` | Harbor 首次启动约 50 秒，建项目请求抢跑；补丁已加入健康检查等待，仍出现则手工 `curl http://localhost:2900/api/v2.0/health` 后再 `--start` |
| `/templates`、`/sandboxes` 返回 401 `no rows in result set` | `seed-db` 没有真正导入团队（`Email:` 阻塞未喂入）；检查 `/root/.e2b/config.json` 的 `teamApiKey` 是否为 `e2b_...` 真实值 |
| `template-manager` 任务反复重启（`Terminated Exit Code: 1`）并最终 `Failed due to progress deadline` | 容器日志里是 `failed to listen on port 5008: bind: address already in use`：`build.sh --stop` 只按 `redis`、`/client-proxy`、`/api`、`template-manager` 这几个名字杀进程，`orchestrator` 进程活下来占着 5007/5008/5010/5016。用例在重置后按端口清理仍持有 E2B 专用端口的残留进程，再重新 `--install`/`--start` |
| `/templates` 返回 500 `relation "public.team_api_keys" does not exist` | `build.sh --install` 会重建 PostgreSQL 容器，库因此变空，而 `/health` 仍返回 200。`start` 阶段用团队 Key 探测 `/templates`，非 200 就重跑 `build.sh --start`（其 `deploy.sh` 会重新建表并 seed），不需要手工介入 |
| `run-nomad.sh` 报 `The value for '--consul-token' cannot be empty`，或 `deploy.sh` 报 `This command takes one argument: <path>` | Consul/Nomad 的 ACL token 只在首次 bootstrap 时输出一次；`build.sh --install` 会用 `dep/.env` 覆盖 `/opt/e2b-infra/.env` 把它弄丢，而两者 ACL 库跨重启保留、第二次 bootstrap 必然跳过（`run-nomad.sh` 检测到 leader 就 `skip_bootstrap`），于是 `nomad job run --token $NOMAD_ACL_TOKEN` 把作业文件当成 token 值。用例把两个 token 缓存到 `/home/runner/software/e2b/e2b-acl-tokens.env` 并在每次 install/start 前写回两个 `.env`；两者都拿不到时执行上游的重置路径 `build.sh --stop`（停服务并删除 `/data/consul`、`/data/nomad`、Harbor 卷）→ `--install` → `--start`，重新 bootstrap，只影响本用例自己部署的栈 |
| 模板构建 `failed to pull image ... index.docker.io` | 基底镜像写了 Docker Hub 标签；改用本地 Harbor 的 `ubuntu:22.04-custom` |
| 模板构建 `error waiting for provisioning sandbox: exit status: 1` | 基底不是 Ubuntu（`Unsupported OS: debian`）；换回 `ubuntu:22.04-custom` |
| `sandbox-bench` 大量失败、`start` 冒烟不通过 | 控制面未就绪或模板非 READY；先 `curl /health`，再 `GET /templates` 确认 `buildStatus=ready` |
| 并发档位被拒 | 模板管理器的 `MAX_STARTING_INSTANCES_PER_NODE=30` 是单节点启动上限，本用例档位（≤20）已留余量，不要随意调高 |
| 宿主机上任何 `ip` 命令都刷屏 `Error: Peer netns reference is invalid`，`iptables -S` 输出上万行 | 沙箱网络没有回收：每个沙箱一个 `/var/run/netns/ns-<n>` + `veth-<n>` + 几条 `REDIRECT` 规则，而 `build.sh` 的停止逻辑只有 `umount /var/run/netns/* && rm -f /var/run/netns/*`——`&&` 会让一个 busy 的命名空间把 `rm` 短路掉，且全文没有一处删 veth 或规则。用例在 `stop`/重置时调用 `scripts/host/cleanup-e2b-network.sh`：命名空间按 inode 判断是否还有活进程、veth 按是否还有对应命名空间回收、iptables 用一次 `iptables-save \| 过滤 \| iptables-restore` 重写（逐条 `-D` 在几千条规则下慢到不可用），并顺带清掉退出的 `start-*` 容器、`postgres` 容器和 `--stop` 遗留的 `nomad logmon/executor` 子进程 |
| 每轮压测后 `iptables -t nat -S POSTROUTING` 多出几百条 `-s 10.11.x.y/32 -o <网卡> -j MASQUERADE` | 这是沙箱的出口 SNAT 规则，**不含 veth 名**，vendor 的删除路径和上面的 veth 回收都匹配不到。API 确认 `GET /sandboxes` 为空后，用例执行 `cleanup-e2b-network.sh --sandbox-leftovers` 按 10.11.0.0/16 网段清理（一次实测 2954 条 → 0）。注意这套规则的重写会短暂 flush nat 表，所以只在测完最后一轮之后执行一次，不放在每轮里 |
| 误以为 `start-<uuid>` 容器是沙箱残留，`docker rm -f` 之后控制面挂了 | 这些 `start-<alloc-id>` 容器是 **Nomad 的服务分配**（`NOMAD_JOB_NAME=api/client-proxy/redis/template-manager`），就是 E2B 控制面本身，删掉后 `GET /sandboxes` 全部失败直到 Nomad 重新拉起。清理脚本用 `is_suite_service_container()` 按 `NOMAD_JOB_NAME` 排除它们，只清理已退出的非服务容器 |
| CubeSandbox 跑过之后 E2B 起不来，或 `/data` 变成只读/空间异常 | CubeSandbox 把它的数据镜像 `/home/runner/cubesandbox-data.img` 挂到 `/data`，而 E2B 的 Consul/Nomad 状态也在 `/data` 下（`/data/consul`、`/data/nomad`）。两个用例不能同时在跑，切换前需 `umount /data` 并 `losetup -d` 掉该镜像；E2B 用例的 `stop` 不会去动 `/data` 的挂载（那属于 CubeSandbox），只清理自己创建的 `ns-*`/`veth-*`/规则 |

## 许可证

- E2B（`e2b-infra`）：Apache-2.0（上游 `e2b-dev/infra`）。
- `sandbox-bench`：随 BoostKit `cloud-native` 仓库发布，许可证同上仓库。
