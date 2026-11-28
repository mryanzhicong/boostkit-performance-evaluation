# DPDK 26.11.0 CPU 侧微基准性能测试

本用例在 x86_64、aarch64 上使用同一个官方 DPDK `26.11.0` LTS 源码包（`-Dplatform=generic`、静态链接最小化 CPU 侧测试构建），在本次任务的 openEuler 24.03 LTS SP4 私有非特权容器内编译并执行 4 项 CPU 侧测试：`hash_perf_autotest`（1 核）、`ring_perf_autotest`（2 核）、`memcpy_perf_autotest`（1 核）与 `mempool_perf_autotest_1core`（1 核）。不使用物理网卡，不配置大页（`--no-pci --no-huge -m 4096 --no-telemetry`），不在容器内使用 `sudo` 或 `numactl --membind`。

软件入口为 `dpdk_test.sh`；Framework 按 `case.yaml` 调用 `scripts/builders/dispatch.sh` 和 `scripts/stages/{start,test,stop}.sh`。`base` 构建上游原版；`optimized` 尚未实现，选择后明确失败，不会回退到基础版，也不会写出 `build_variant.json`。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| DPDK 源码 | [官方 DPDK 26.11.0 源码归档](https://fast.dpdk.org/rel/dpdk-26.11.tar.xz)（官方登记 MD5 `061ed6050c8d0e6c407ce0b270dd39c3`） | 优先读取 `/home/runner/software/dpdk/dpdk-26.11.tar.xz`，缺失时下载至 `${PERF_WORK_DIR}/dpdk-26.11.tar.xz` 并解压到 `${PERF_WORK_DIR}/dpdk-26.11` |
| `dpdk-test` 测试程序 | 随同一源码以 `-Denable_apps=test` 静态构建 | `${PERF_WORK_DIR}/build-cpu/app/dpdk-test` |
| 容器镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}` |

## 构建与容器

脚本通过 `scripts/common.sh` 接收 Framework 传入的 `SOFTWARE_VERSION`（固定 `26.11.0`）、`PERF_VARIANT`（默认 `base`）、`EXPECTED_ARCH`（`x86_64` 或 `aarch64`）、`PERF_RUN_ID`、`PERF_WORK_DIR`、`RESULTS_DIR`、`PERF_ACTUAL_VERSION_FILE`（仅独立运行时补默认值），并计算 `DPDK_CONTAINER_NAME="boostkit-dpdk-${EXPECTED_ARCH}-${PERF_RUN_ID}"` 与私有目录 `${PERF_WORK_DIR}/{home,run,dpdk-26.11,build-cpu,tmp}`。

`build` 阶段先检查 `docker info` 并拒绝覆盖同名容器；读取 `openEuler-docker.<架构>.tar.xz` 及 `.sha256sum`（默认 `DPDK_IMAGE_ARCHIVE_DIR=/home/runner/software/openEuler-24.03-LTS-SP4`，缺失时原子下载），校验 SHA-256 后执行 `docker load --input "${ARCHIVE}"`，核对镜像架构（`x86_64 → amd64`、`aarch64 → arm64`）与容器内 `/etc/os-release` 为 openEuler 24.03 LTS SP4，将镜像引用写入 `${PERF_WORK_DIR}/container-image.txt`。容器使用 Runner UID/GID、宿主机网络、非特权模式、`--ulimit nofile=65535:65535`，并将 `HOME`、`XDG_CACHE_HOME`、`XDG_RUNTIME_DIR`（供 EAL 写入私有 runtime 文件，无需 root）和 `TMPDIR` 指向本次任务私有目录。

```bash
archive="${DPDK_IMAGE_ARCHIVE_DIR}/openEuler-docker.${EXPECTED_ARCH}.tar.xz"
printf '%s  %s\n' "$(awk 'NR==1 {print $1}' "${archive}.sha256sum")" "${archive}" | sha256sum -c -
docker load --input "${archive}"
docker image inspect --format '{{.Architecture}}' "${DPDK_CONTAINER_IMAGE}"
docker run --rm --network=none "${DPDK_CONTAINER_IMAGE}" cat /etc/os-release
```

条件挂载规则：

- 设置 `PERF_PROXY` 时，校验 `${DPDK_CA_ANCHORS_DIR}`（默认 `/home/runner/software/anchors`）存在并只读挂载到 `/etc/pki/ca-trust/source/anchors`，以容器 root 执行 `update-ca-trust extract`，仅向容器内 `dnf` 与联网命令传入代理；无代理时跳过。
- 存在 `/home/runner/.gitconfig` 时只读挂载；不存在时跳过。
- 存在 `${DPDK_OFFLINE_DIR}`（默认 `/home/runner/software/dpdk`）时只读挂载；不存在时跳过。

包含全部可选挂载时的容器创建与初始化命令如下（无对应条件时去掉相应 `--mount` 与证书更新）：

```bash
docker run --detach --name "${DPDK_CONTAINER_NAME}" \
  --label "boostkit.dpdk.run-id=${PERF_RUN_ID}" \
  --network=host \
  --ulimit nofile=65535:65535 \
  --user "$(id -u):$(id -g)" \
  -e "HOME=${PERF_WORK_DIR}/home" \
  -e "XDG_CACHE_HOME=${PERF_WORK_DIR}/home/.cache" \
  -e "XDG_RUNTIME_DIR=${PERF_WORK_DIR}/run" \
  -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount "type=bind,source=${DPDK_CA_ANCHORS_DIR},target=/etc/pki/ca-trust/source/anchors,readonly" \
  --mount type=bind,source=/home/runner/.gitconfig,target=/home/runner/.gitconfig,readonly \
  --mount "type=bind,source=${DPDK_OFFLINE_DIR},target=${DPDK_OFFLINE_DIR},readonly" \
  "${DPDK_CONTAINER_IMAGE}" sleep infinity

# 仅设置 PERF_PROXY 时执行：
docker exec --user 0 "${DPDK_CONTAINER_NAME}" update-ca-trust extract

# 仅容器内存在 /etc/yum.repos.d/openEuler.repo 时执行：
docker exec --user 0 "${DPDK_CONTAINER_NAME}" sed -i \
  -e '/^meta/ s/^\(.*\)$/#\1/g' \
  -e 's/repo.openeuler.org/repo.huaweicloud.com\/openeuler/g' \
  /etc/yum.repos.d/openEuler.repo
```

基础版的关键构建与版本核验命令如下，均在私有容器内执行：

```bash
# 容器内以 root 安装编译与拓扑探测依赖（设置 PERF_PROXY 时追加 --setopt=proxy="${PERF_PROXY}"）
dnf install -y gcc gcc-c++ make meson ninja-build \
  python3 python3-pyelftools pkgconf-pkg-config \
  numactl numactl-devel curl tar xz util-linux

# 以下均在容器内以 Runner UID/GID 执行：
# 校验 meson >= 0.61 与 pyelftools，随后校验 MD5 并解包 dpdk-26.11.tar.xz
tar -xJf "${PERF_WORK_DIR}/dpdk-26.11.tar.xz" -C "${PERF_WORK_DIR}"
cat "${PERF_WORK_DIR}/dpdk-26.11/VERSION"   # 必须为 26.11.0

meson setup "${PERF_WORK_DIR}/build-cpu" "${PERF_WORK_DIR}/dpdk-26.11" \
  --buildtype=release \
  -Dplatform=generic \
  -Ddefault_library=static \
  -Ddeveloper_mode=disabled \
  -Denable_apps=test \
  -Denable_drivers=mempool/ring \
  -Denable_libs=cmdline,hash,mbuf,mempool,ring,net,kvargs,rcu,timer,ptr_compress \
  -Dmax_lcores=detect \
  -Dmax_numa_nodes=detect
ninja -C "${PERF_WORK_DIR}/build-cpu" -j "$(nproc)"

ldd "${PERF_WORK_DIR}/build-cpu/app/dpdk-test"
meson configure "${PERF_WORK_DIR}/build-cpu" > "${RESULTS_DIR}/meson-config.txt"
grep -nE 'RTE_MAX_LCORE|RTE_MAX_NUMA_NODES|RTE_CACHE_LINE_SIZE' \
  "${PERF_WORK_DIR}/build-cpu/rte_build_config.h" > "${RESULTS_DIR}/rte-build-config.txt"

env -u DPDK_TEST -u DPDK_TEST_PARAMS -u DPDK_TEST_SKIP \
  "${PERF_WORK_DIR}/build-cpu/app/dpdk-test" \
  -l "${BUILD_CPU}" --main-lcore="${BUILD_CPU}" \
  --no-pci --no-huge -m 4096 \
  --file-prefix="dpdk-ver-${PERF_RUN_ID}" --no-telemetry \
  -- version_autotest
```

脚本会检查 `dpdk-26.11.tar.xz` 的 MD5 匹配 `061ed6050c8d0e6c407ce0b270dd39c3` 并记录其实际 SHA-256 至 `${RESULTS_DIR}/source-checksum.txt`；构建后在容器内运行 `version_autotest`，核对输出包含 `Test OK` 与 `DPDK 26.11.0` 后才将 `26.11.0` 写入 `${PERF_ACTUAL_VERSION_FILE}`，再由 `dispatch.sh` 写出 `${RESULTS_DIR}/build_variant.json`。

`start` 与 `test` 仅复用该容器（`docker inspect` 同时校验 `State.Running == true` 与 `boostkit.dpdk.run-id == ${PERF_RUN_ID}`）。`stop` 阶段核对归属标签后先将 `docker logs` 保存至 `${RESULTS_DIR}/container.log`，再执行 `docker stop --time 30` 与 `docker rm`；容器不存在时安全返回 0，标签不符时拒绝删除，不触碰 `${RESULTS_DIR}` 或共享离线目录。

## 数据准备与测试

`start` 阶段在同一容器内执行两步就绪检查：

1. 运行 `scripts/results/select_cpus.py --min-cores 2` 解析 `lscpu -p=CPU,CORE,SOCKET,NODE,ONLINE` 与 `/proc/self/status` 的 `Cpus_allowed_list`，在 NUMA 0 同一 socket 上选择 2 个互不重叠的在线**物理核**（同一物理 `CORE` 只取第 1 个逻辑线程，物理核数充足时优先跳过 CPU 0），将选中核号写入 `${PERF_WORK_DIR}/cpu-selection.json` 与 `${RESULTS_DIR}/cpu-selection.json`。
2. 运行带 `--log-level=lib.eal:debug` 的 `version_autotest` 写入 `${RESULTS_DIR}/smoke.log`，验证 `Test OK` 与 `DPDK 26.11.0`，并解析 `TSC frequency is ~<N> KHz` 计算 `tsc_hz = N * 1000` 写入 `${PERF_WORK_DIR}/tsc-hz.txt`：

```bash
docker exec \
  -e "HOME=${PERF_WORK_DIR}/home" \
  -e "XDG_CACHE_HOME=${PERF_WORK_DIR}/home/.cache" \
  -e "XDG_RUNTIME_DIR=${PERF_WORK_DIR}/run" \
  -e "TMPDIR=${PERF_WORK_DIR}/tmp" \
  "${DPDK_CONTAINER_NAME}" \
  env -u DPDK_TEST -u DPDK_TEST_PARAMS -u DPDK_TEST_SKIP \
  "${PERF_WORK_DIR}/build-cpu/app/dpdk-test" \
  -l "${BENCH_CPU}" --main-lcore="${BENCH_CPU}" \
  --no-pci --no-huge -m 4096 \
  --file-prefix="cpu-smoke-${PERF_RUN_ID}" --no-telemetry \
  --log-level=lib.eal:debug \
  -- version_autotest \
  2>&1 | tee "${RESULTS_DIR}/smoke.log"
```

`test` 阶段在同一容器内先采集环境快照（`uname.txt`、`lscpu.txt`、`cpu-topology.txt`、`numa.txt`、`meminfo.txt`、`base-page-size.txt`），随后按以下顺序串行执行 4 项测试（每条命令均通过 `PIPESTATUS[0]` 保留退出码并核对 `Test OK`、无 `Test Failed`）：

```bash
# 1. Hash（单核）：1 次热身（不计入指标）+ 3 轮正式测试
dpdk-test -l "${BENCH_CPU}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
  --file-prefix="cpu-${PERF_RUN_ID}-hash-warmup" -- hash_perf_autotest 2>&1 | tee "${RESULTS_DIR}/logs/hash-warmup.log"
for r in 1 2 3; do
  dpdk-test -l "${BENCH_CPU}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
    --file-prefix="cpu-${PERF_RUN_ID}-hash-run${r}" -- hash_perf_autotest 2>&1 | tee "${RESULTS_DIR}/logs/hash-run${r}.log"
done

# 2. Ring（NUMA 0 两个独立物理核）：1 次热身（不计入指标）+ 3 轮正式测试
dpdk-test -l "${BENCH_PAIR}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
  --file-prefix="cpu-${PERF_RUN_ID}-ring-warmup" -- ring_perf_autotest 2>&1 | tee "${RESULTS_DIR}/logs/ring-warmup.log"
for r in 1 2 3; do
  dpdk-test -l "${BENCH_PAIR}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
    --file-prefix="cpu-${PERF_RUN_ID}-ring-run${r}" -- ring_perf_autotest 2>&1 | tee "${RESULTS_DIR}/logs/ring-run${r}.log"
done

# 3. Memcpy（单核）：1 轮正式测试（上游内置 do_uncached_write 预热）
dpdk-test -l "${BENCH_CPU}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
  --file-prefix="cpu-${PERF_RUN_ID}-memcpy-1core" -- memcpy_perf_autotest 2>&1 | tee "${RESULTS_DIR}/logs/memcpy-1core.log"

# 4. Mempool（单核）：1 轮正式测试
dpdk-test -l "${BENCH_CPU}" --main-lcore="${BENCH_CPU}" --no-pci --no-huge -m 4096 --no-telemetry \
  --file-prefix="cpu-${PERF_RUN_ID}-mempool-1core" -- mempool_perf_autotest_1core 2>&1 | tee "${RESULTS_DIR}/logs/mempool-1core.log"

# 解析全部正式日志并按实测 tsc_hz 将 ticks 换算为 ns
python3 software/HPC/dpdk/scripts/results/parse_benchmark.py \
  --logs-dir "${RESULTS_DIR}/logs" \
  --output "${RESULTS_DIR}/benchmark_dpdk.json" \
  --tsc-hz "${TSC_HZ}" \
  --source-md5 "061ed6050c8d0e6c407ce0b270dd39c3" \
  --source-sha256 "${SOURCE_SHA256}" \
  --cache-line-size "${RTE_CACHE_LINE_SIZE}" \
  --cpu-selection "${PERF_WORK_DIR}/cpu-selection.json" \
  --mem-mb 4096
```

### 与参考指导的差异

| 差异 | 当前做法与原因 |
|---|---|
| 编译平台选项 | 指南主命令用 `-Dplatform=native` 并提示 ARM SoC/GCC 不支持时改用 `-Dplatform=generic`；按确认口径，本基础版两架构统一采用 `-Dplatform=generic`，避免 ARM native 识别差异，保证同口径通用基线。 |
| `enable_libs` 依赖补齐 | 指南 `-Denable_libs` 未列出 `ptr_compress`，但 DPDK 26.11.0 `app/test/meson.build` 中 `test_ring_perf.c` 显式依赖 `ptr_compress`（缺失时 Meson 会跳过编译导致 `ring_perf_autotest` 不可用）；本用例追加 `ptr_compress` 并在构建后校验 4 个测试入口均已编入 `dpdk-test`。 |
| `sudo` 与 `numactl --membind` | 指南在宿主机使用 `sudo numactl --membind=0`；本用例运行于非特权私有容器，设置私有 `XDG_RUNTIME_DIR` 后无需 `sudo`，按确认口径不启用 `numactl --membind`（保持零额外容器安全例外），核号仍固定取自 NUMA 0。 |
| 核心编号选择 | 指南中 `BENCH_CPU=2`、`BENCH_PAIR=2,3` 为示例；本用例在容器内由 `select_cpus.py` 按 `lscpu` 与 `Cpus_allowed_list` 动态选取 NUMA 0 同 socket 独立物理核，并将实际核号记入 `runtime_context`。 |
| Mempool 范围 | 指南列出 1 核 / 2 核 / 4 核并建议“先只执行单核”；按确认口径，本用例包含前 4 项（`hash` 1 核、`ring` 2 核、`memcpy` 1 核、`mempool` 1 核），不包含 2 核/4 核 mempool 长测。 |
| PMU 观测与大页测试 | 指南第 9 节 `perf stat`/`perf record` 与第 10 节 Hugepage 均标明为可选且不与普通页无扰动基线混用，不纳入本用例。 |

## 结果与报告

| 结果 | 位置 | 用途 |
|---|---|---|
| 构建变体与校验 | `${RESULTS_DIR}/build_variant.json`、`${RESULTS_DIR}/source-checksum.txt`、`${RESULTS_DIR}/binary-version.txt` | 记录 `base` 变体、源码 MD5/SHA-256 与二进制自报版本 |
| 构建配置与环境 | `${RESULTS_DIR}/toolchain-versions.txt`、`${RESULTS_DIR}/meson-config.txt`、`${RESULTS_DIR}/rte-build-config.txt`、`${RESULTS_DIR}/cpu-selection.json` | 记录工具链、Meson 配置、`RTE_CACHE_LINE_SIZE` 与选中核心 |
| 烟测与计时频率 | `${RESULTS_DIR}/smoke.log` | 保存 `version_autotest` 输出与 EAL `TSC frequency` 调试日志 |
| 原始基准日志 | `${RESULTS_DIR}/logs/` | 保存全部热身与正式测试原始日志（`hash-warmup/run1..3`、`ring-warmup/run1..3`、`memcpy-1core`、`mempool-1core`）及容器拓扑快照 |
| 归一化指标 | `${RESULTS_DIR}/benchmark_dpdk.json` | 全量结构化指标（约 3,190 项）、跨架构固定 `parameters` 与 `runtime_context` |
| 容器日志 | `${RESULTS_DIR}/container.log` | `stop` 阶段删除容器前保存的 `docker logs` |

原始字段盘点与跨架构换算口径（`ticks → ns` 换算公式：`ns = ticks × 1,000,000,000 / tsc_hz`）：

| 测试入口 | 原始字段 | 处理方式 | 指标数 | 归一化单位与方向 | 说明 |
|---|---|---|---|---|---|
| `hash_perf_autotest` | 5 组锁/桶配置 × 4 组 data/prehash × 10 种 Keysize × 4 操作（Add/Lookup/Lookup_bulk/Delete）+ FBK lookup（ticks/op） | 纳入指标（3 轮中位数） | 801 | `ns/op`，`lower_is_better` | 3 轮原始 ticks 及最小/最大 ns 保留在 `runtime_context.hash_repeats` |
| `ring_perf_autotest` | legacy / elem_16B 的 single/burst/bulk/empty_bulk_deq/two_physical_cores 及 zero-copy 压缩小节（cycles per elem）；`all_worker_nodes`（Total count） | 纳入指标（3 轮中位数） | 93 | cycles 项换算为 `ns/elem`（`lower_is_better`）；`all_worker_nodes` 保留 `ops/100ms`（`higher_is_better`） | `Potential gain from compression (%)` 仅保留在原始日志；3 轮原始值与极值保留在 `runtime_context.ring_repeats` |
| `memcpy_perf_autotest` | 2 种对齐 ×（63 种运行期长度 + 9 种编译期常量）× 4 种缓存场景 ×（`rte_memcpy`、`glibc memcpy`）ticks + 4 项总执行时间 | 纳入指标（1 轮） | 1,156 | 单元格换算为 `ns`（`lower_is_better`）；4 项总耗时保留 `s`（`lower_is_better`） | 括号内百分比差异仅留原始日志；允许 ARM 100 MHz 计时器四舍五入产生 `0` ticks |
| `mempool_perf_autotest_1core` | 3 种缓存模式（`without_cache`、`with_cache`、`with_user_owned_cache`）×（30 项随机 `n_max_bulk` + 350 项固定 `n_get_bulk`/`n_put_bulk`）的 `rate_persec` | 纳入指标（1 轮） | 1,140 | `ops/s`，`higher_is_better` | `CACHE_LINE_BURST = RTE_CACHE_LINE_SIZE / 8`（x86_64 为 8，ARM64 generic 为 16），按真实批量保留不强行合并，其余批量两架构直接 1:1 配对 |

解析器严格校验全部热身和正式日志均包含 `Test OK` 且无 `Test Failed`，核对每套测试的精确条目数、无重复、无非法负数或 NaN/Inf，并仅将两架构完全一致的负载配置写入 `parameters`，机器核号、实际 `tsc_hz`、`RTE_CACHE_LINE_SIZE` 与多轮极值均写入 `runtime_context`。

## 独立执行

在仓库根目录运行；Runner 需具备 Docker 权限并预留至少 5 GiB 内存与 3 GiB 磁盘空间（整套含 `mempool_perf_autotest_1core` 预计约 25–40 分钟）：

```bash
bash software/HPC/dpdk/dpdk_test.sh \
  --version 26.11.0 --variant base \
  --results-dir /home/runner/dpdk-results/26.11.0
```

独立入口依次执行构建、烟测、正式测试、停止容器（失败或中断时同样通过 `EXIT` trap 调用 `stop` 收口），并在结果目录写出 `results.json`、`status.json` 和 `report.md`。数据与构建目录默认位于 `/home/runner/boostkit-perf/dpdk/local-<运行 ID>/`；正常结束后仅清理本次自行创建的私有目录，需要保留排障时添加 `--keep-workdir`。Framework 分阶段调用或调用者显式传入 `PERF_WORK_DIR` 时，脚本不会删除该目录。

> **当前验证状态**：本用例已完成第 1 层静态接线、解析器（基于 DPDK 26.11.0 源码格式）、容器契约单测与双架构对比预检；**真实 openEuler 24.03 LTS SP4 容器内 Meson/Ninja 编译、同一容器跨阶段复用、Runner 清理权限以及 x86_64 / aarch64 正式端到端测试尚未在目标 Runner 上执行**。
