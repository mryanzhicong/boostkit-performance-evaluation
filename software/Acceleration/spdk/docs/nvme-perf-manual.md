# SPDK 26.01 单盘 NVMe 性能测试手册（人工执行口径）

> 本文档是 `software/Acceleration/spdk/` 用例的**真实盘附随手册**，不参与流水线自动执行。
> 流水线内跑的是 `bdevperf` + `Malloc` bdev 口径（见 [../README.md](../README.md)）：它不接触任何
> 物理设备，可在私有非特权容器里复现。本手册测量的是**一块独占 NVMe SSD 经 SPDK 用户态驱动**的
> 单盘性能，需要宿主机级权限与设备绑定，只能由人工在预留机器上执行。

本手册测量 **SPDK 用户态 NVMe 驱动路径**在**一块独占 NVMe SSD** 上的单盘性能：物理机先把这块盘
从内核 `nvme` 驱动解绑、交给 `vfio-pci`（或 `uio_pci_generic`），再在特权容器里用 SPDK 自带的
`spdk_nvme_perf` 直接发 I/O，全程绕过内核块层与文件系统。x86_64 与 aarch64 使用完全相同的
命令矩阵与参数，只有 PCIe 地址、核心掩码按机器实际拓扑取值。

**前置条件（缺一不可）**：

1. 机器上有一块**可擦除的数据盘**，且**不是系统盘**（系统盘、`/boot`、`/boot/efi`、swap 所在盘一律排除）；
2. 具备 root 权限，可写 `/proc/sys/vm/nr_hugepages` 并修改 PCI 设备驱动绑定；
3. 盘上数据可丢弃——一轮 60 s 的 1 MiB 顺序写通常写入 60 GB 以上，任何写/混合场景都会覆盖盘上内容。

容器规格：`--privileged`，**不限制 CPU、内存与 NUMA**（未设 `--cpus`/`--cpuset`/`--memory`）。
特权与 `/dev/vfio` 是访问已绑定设备的最小必要条件；容器内以 root 运行（不支持 `--user`，
原因见「已知限制」）。本手册只有 `base` 口径（同盘同参数复测），不涉及 `optimized` 变体。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 SPDK | 上游 tag `v26.01`（`VERSION` 为 `26.01.0`），源码归档 `spdk-26.01.tar.gz`，4,037,233 字节，SHA-256 `3b1e5e409f34ca32eb1b001ad3c9469719eb2586e50339bafb49034e5cca145e` | 容器内 `${PERF_WORK_DIR}/src/spdk`（源码构建时）或镜像内置 `/usr/local/bin`（用官方镜像时） |
| 测量工具 `spdk_nvme_perf` | SPDK 26.01 自带应用，源码 `app/spdk_nvme_perf/perf.c`，随 SPDK 一起构建/打包 | 容器内 `command -v spdk_nvme_perf` 定位；源码构建时为 `${PERF_WORK_DIR}/src/spdk/build/bin/spdk_nvme_perf` |
| 运行时依赖 DPDK / ISA-L | SPDK 的 git 子模块（tarball 不含）：v26.01 固定 `spdk/dpdk` = `e01bfcd05fe39f628392c8b29b880f5692de2224`、`spdk/isa-l` = `6f420b14a1e3e091bc9d15f508a54f82c007483c`；官方镜像已内置 | 源码构建时 `${PERF_WORK_DIR}/src/spdk/dpdk`、`.../isa-l` |
| 容器基础镜像（本手册直用） | `openeuler/spdk:26.01-oe2403sp2`（镜像内置 SPDK 26.01 与 `spdk_nvme_perf`），Docker Hub `openeuler` 命名空间 | 离线机器必须预置 `spdk-26.01-oe2403sp2.tar`（`docker save` 导出），加载后离线可用；归档 SHA-256 在预置时计算并写入记录 |
| 宿主机系统工具 | `lspci`（pciutils）、`lsblk`/`findmnt`（util-linux）、`nvme-cli`（可选，读 `id-ctrl`/`smart-log`） | 只在宿主机做设备识别、大页与绑定检查，不安装到容器内 |

## SPDK 获取、构建与容器启动

### 获取顺序与校验值

按「公共离线目录 → 本次任务缓存 → 官方归档」三段取，任何一段命中都要先过 SHA-256 校验：

| 制品 | 归档名 | 字节 | SHA-256 |
|---|---|---:|---|
| SPDK 26.01 源码 | `spdk-26.01.tar.gz` | 4,037,233 | `3b1e5e409f34ca32eb1b001ad3c9469719eb2586e50339bafb49034e5cca145e` |
| DPDK（v26.01 子模块） | `dpdk-e01bfcd0.tar.gz` | 按上游归档 | 下载后记录 |
| ISA-L（v26.01 子模块） | `isa-l-6f420b14.tar.gz` | 按上游归档 | 下载后记录 |
| SPDK 容器镜像 | `spdk-26.01-oe2403sp2.tar` | 预置时记录 | 预置时记录 |

```bash
OFFLINE="/home/runner/software/spdk"
NAME="spdk-26.01.tar.gz"
SHA="3b1e5e409f34ca32eb1b001ad3c9469719eb2586e50339bafb49034e5cca145e"
mkdir -p "${PERF_WORK_DIR}/acquire"
if [ -s "${OFFLINE}/${NAME}" ]; then
  cp -f "${OFFLINE}/${NAME}" "${PERF_WORK_DIR}/acquire/${NAME}"
else
  curl -fSL --http1.1 --retry 5 --retry-all-errors --connect-timeout 30 \
    -o "${PERF_WORK_DIR}/acquire/${NAME}" \
    "https://codeload.github.com/spdk/spdk/tar.gz/refs/tags/v26.01"
fi
printf '%s  %s\n' "${SHA}" "${NAME}" | (cd "${PERF_WORK_DIR}/acquire" && sha256sum -c -)
tar xzf "${PERF_WORK_DIR}/acquire/${NAME}" -C "${PERF_WORK_DIR}/src"
cat "${PERF_WORK_DIR}/src/spdk-26.01/VERSION"        # 期望 26.01.0
```

### 物理机准备：大页、选盘与绑定

整个准备过程只在一台机器上做一次，测量窗口内不再变化；所有命令都以 root（或 `sudo`）执行。

先固定两个事实：**系统盘是哪块**、**候选盘的 PCIe 地址（BDF）是多少**。BDF 同时用于绑定与
`spdk_nvme_perf -r 'traddr:...'`，写错一个字符就会打到别的盘上。

```bash
# 1) 系统盘与其挂载点（root / boot / efi / swap 都算系统盘）
ROOT_SRC=$(findmnt -no SOURCE /)
BOOT_SRC=$(findmnt -no SOURCE /boot 2>/dev/null || true)
EFI_SRC=$(findmnt -no SOURCE /boot/efi 2>/dev/null || true)
SWAP_SRC=$(swapon --show=NAME --noheadings 2>/dev/null || true)
printf 'root=%s boot=%s efi=%s swap=%s\n' "${ROOT_SRC}" "${BOOT_SRC}" "${EFI_SRC}" "${SWAP_SRC}"

# 2) 每块 NVMe 物理盘 → 型号 / 序列号 / PCIe BDF
for dev in /sys/block/nvme*n1; do
  bdf=$(basename "$(readlink -f "${dev}/device")")
  printf '%-10s %-14s %-24s %s\n' "$(basename "${dev}")" "${bdf}" \
    "$(cat "${dev}/device/model" 2>/dev/null)" "$(cat "${dev}/device/serial" 2>/dev/null)"
done

# 3) 候选盘上有没有分区/挂载/LVM/RAID（有就换一块）
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,SERIAL,MODEL /dev/nvme1n1

# 4) 记录候选盘的裸容量与 SMART 基线（复位后对比，确认盘回到内核驱动）
sudo nvme list
sudo nvme smart-log /dev/nvme1n1 | head -20
```

选择规则（按顺序执行，任何一步不满足就换盘）：

| 优先级 | 判据 | 不满足时 |
|---|---|---|
| 1 | 该盘（含所有子分区）**没有任何挂载点** | 换盘 |
| 2 | 该盘的 BDF **不等于**系统盘的 BDF（由 `lsblk -no PKNAME "$(findmnt -no SOURCE /)"` 反查） | 换盘 |
| 3 | 该盘不在 LVM（`pvs`）、软 RAID（`/proc/mdstat`）、swap 中 | 换盘 |
| 4 | 以上都满足时取**数据最少**的那块：先比已用量（有挂载点的用 `df -B1 --output=used`，无挂载点视为 0），再比分区的数量 | 两者相同取容量更小的盘 |

选择「数据最少」的盘有两个原因：一是写/混合场景会覆盖整盘（4K 随机写、1 MiB 顺序写、70/30 混合
都会写满命名空间），二是同型号多盘里空盘的稳态性能更接近出厂状态，避免把别人的历史数据当成测试变量。

SPDK 的 `setup.sh` 自带一道保护：**带活动挂载点的 NVMe 会被跳过**，但这只是兜底，不能替代人工确认。

把确认结果落成三个变量，后续所有命令只引用这三个变量：

```bash
# 本次要绑定的目标盘（示例：0000:02:00.0）；必须来自上面第 2 步的 BDF 列
export SPDK_TARGET_PCI="0000:02:00.0"
# 系统盘的 BDF：由 root 分区反查所属磁盘，再取该磁盘的 PCIe 地址（不要手抄）
SYS_DISK=$(lsblk -no PKNAME "$(findmnt -no SOURCE /)")
export SPDK_SYSTEM_PCI=$(basename "$(readlink -f "/sys/block/${SYS_DISK}/device")")
# 目标盘设备名，仅用于复位后校验
export SPDK_TARGET_DEV="/dev/nvme1n1"
printf 'target=%s system=%s dev=%s\n' "${SPDK_TARGET_PCI}" "${SPDK_SYSTEM_PCI}" "${SPDK_TARGET_DEV}"

# 硬性拦截：目标盘若是系统盘、或仍有挂载点，立刻中止
[ "${SPDK_TARGET_PCI}" != "${SPDK_SYSTEM_PCI}" ] || { echo "REFUSE: target is the system disk"; exit 1; }
[ -z "$(lsblk -no MOUNTPOINTS "${SPDK_TARGET_DEV}" | tr -d '[:space:]')" ] || { echo "REFUSE: target is mounted"; exit 1; }
```

配置大页内存（DPDK EAL 需要，默认 2 MiB 页，4096 页 = 8 GiB）：

```bash
# 只影响本次测量窗口；不动 /etc/sysctl.d、不写持久化配置
sudo sh -c 'echo 4096 > /proc/sys/vm/nr_hugepages'
grep -E 'HugePages_Total|HugePages_Free|Hugepagesize' /proc/meminfo

# 也可以让 setup.sh 一并分配（HUGEMEM 单位 MB，NRHUGE 覆盖 HUGEMEM）
sudo env HUGEMEM=8192 NRHUGE=4096 HUGENODE=0 ./scripts/setup.sh
```

约束：

- **不要**设 `PERSIST_HUGE=yes`：它会写 `/usr/local/lib/sysctl.d/99-spdk.conf`，属于改系统配置；
- NUMA 机器上大页要落在与目标盘同一个 node（`lspci -vv -s <BDF> | grep NUMA`），否则 I/O 跨 node 访存；
- 大页分配不足说明内存碎片化，要么重启，要么降低 `NRHUGE` 并把实际值写进结果。

绑定目标盘到用户态驱动（只在 SPDK 源码树目录下执行；`DEV_TYPE=NVME` 限定只处理 NVMe，
`PCI_ALLOWED` 精确指定目标盘，`PCI_BLOCKED` 把系统盘再挡一次，`PCI_BLOCKED` 优先级更高）：

```bash
# 绑定前：确认目标盘当前挂在 nvme 内核驱动上
lspci -k -s "${SPDK_TARGET_PCI}" | grep -E 'Kernel driver in use|Kernel modules'

# 绑定（vfio-pci 需要 IOMMU 已开启；未开启时 setup.sh 会退回 uio_pci_generic）
sudo env DEV_TYPE=NVME \
  PCI_ALLOWED="${SPDK_TARGET_PCI}" \
  PCI_BLOCKED="${SPDK_SYSTEM_PCI}" \
  DRIVER_OVERRIDE=vfio-pci \
  HUGEMEM=8192 \
  ./scripts/setup.sh

# 绑定后：驱动必须是 vfio-pci（或 uio_pci_generic），块设备已从内核消失
lspci -k -s "${SPDK_TARGET_PCI}" | grep 'Kernel driver in use'
ls -l "/sys/bus/pci/devices/${SPDK_TARGET_PCI}/driver"
lsblk -o NAME,SIZE,MODEL | grep -c "$(basename "${SPDK_TARGET_DEV}")" || true   # 期望 0

# 容器要用的 vfio 组设备（uio 驱动则是 /dev/uio*）
ls -l /dev/vfio/
./scripts/setup.sh status | grep -A2 "${SPDK_TARGET_PCI}"
```

IOMMU 前置条件（需重启，属于机器级配置，不在单次测量里改）：

| 架构 | 内核参数 | 说明 |
|---|---|---|
| x86_64 | `intel_iommu=on iommu=pt` | 服务器默认常已开启；`iommu=pt` 只对直通设备建映射 |
| aarch64 | SMMU 直通（BIOS 开启 SMMU + 内核 `iommu.passthrough=1`） | 鲲鹏平台未开 SMMU 时只能用 `uio_pci_generic`（无 IOMMU 保护） |

### 容器启动

镜像优先用离线归档加载（离线机器不访问 Docker Hub）：

```bash
docker load -i /home/runner/software/spdk/spdk-26.01-oe2403sp2.tar

# 容器名与标签沿用仓库约定
docker run --detach --name "${SPDK_CONTAINER_NAME}" \
  --label "boostkit.spdk.run-id=${PERF_RUN_ID}" \
  --privileged --network=host \
  --mount type=bind,source=/dev/hugepages,target=/dev/hugepages \
  --mount type=bind,source=/dev/vfio,target=/dev/vfio \
  --mount type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR} \
  --mount type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR} \
  --ulimit memlock=-1:-1 --shm-size=2g \
  "${SPDK_CONTAINER_IMAGE}" sleep infinity

# 自检：工具存在、大页已挂载、vfio 可见、目标设备能被 SPDK 枚举
docker exec "${SPDK_CONTAINER_NAME}" sh -c 'command -v spdk_nvme_perf; grep -c hugetlbfs /proc/mounts; ls /dev/vfio'
docker exec "${SPDK_CONTAINER_NAME}" spdk_lspci 2>/dev/null | head
```

要点：

- `/dev/hugepages` 与 `/dev/vfio` 是宿主设备的绑定挂载，容器内路径必须与宿主一致（DPDK 默认就找这两个路径）；
- `--privileged` 是访问 vfio 组与 DPDK 大页映射的最小条件，容器内因此是 root，**不支持 `--user`**；
- 不需要 `--device`：`/dev/vfio` 整目录挂载即可覆盖新出现的组设备；
- 不设 `--cpus`/`--cpuset`/`--memory`：不限制 CPU、内存与 NUMA，核选择由 `spdk_nvme_perf -c` 的掩码决定。

## 数据与运行顺序

六个场景共用同一块盘、同一个 BDF，逐条串行执行（并发会互相污染，单盘队列深度已足够打满）。
每个场景都是独立的 `spdk_nvme_perf` 进程，退出即释放队列。

| # | 场景名 | 块大小 | 队列深度 | 负载 | 混合比 | 时长 | 说明 |
|---|---|---|---|---|---|---|---|
| 1 | `4k_randread_qd128` | 4,096 B | 128 | `randread` | — | 60 s | 读 IOPS/延迟主指标 |
| 2 | `4k_randwrite_qd32` | 4,096 B | 32 | `randwrite` | — | 60 s | 写放大与 GC 影响最明显 |
| 3 | `4k_randrw_70r30w_qd128` | 4,096 B | 128 | `randrw` | `-M 70`（70% 读） | 60 s | 混合负载 |
| 4 | `1m_read_qd32` | 1,048,576 B | 32 | `read` | — | 60 s | 顺序读带宽 |
| 5 | `1m_write_qd32` | 1,048,576 B | 32 | `write` | — | 60 s | 顺序写带宽（写入量最大） |
| 6 | `1m_randrw_70r30w_qd128` | 1,048,576 B | 128 | `randrw` | `-M 70`（70% 读） | 60 s | 大块混合 |

采样契约：**1 次预热 + 5 次有效采样**，报告各指标中位数并保留全部样本。预热与采样都是 60 s 的
独立进程，单场景约 6 min，六场景约 36 min（不含大页/绑定准备）。

```bash
# 1) 预热：不参与统计，把盘带入稳态（缓存、GC、温控稳定下来）
docker exec "${SPDK_CONTAINER_NAME}" spdk_nvme_perf \
  -q 128 -o 4096 -w randread -t 60 -c 0x1 \
  -r "trtype:PCIe traddr:${SPDK_TARGET_PCI}" \
  > "${RESULTS_DIR}/runs/4k_randread_qd128/rep0.log" 2> "${RESULTS_DIR}/runs/4k_randread_qd128/rep0.err"

# 2) 正式采样：rep1..rep5 依次执行，命令只改日志文件名
for rep in 1 2 3 4 5; do
  docker exec "${SPDK_CONTAINER_NAME}" spdk_nvme_perf \
    -q 128 -o 4096 -w randread -t 60 -c 0x1 \
    -r "trtype:PCIe traddr:${SPDK_TARGET_PCI}" \
    > "${RESULTS_DIR}/runs/4k_randread_qd128/rep${rep}.log" 2> "${RESULTS_DIR}/runs/4k_randread_qd128/rep${rep}.err"
done

# 3) 其余五个场景重复 1)~2)，-q/-o/-w/-M 见上表
```

运行顺序上的硬约束：

- **先读后写**：先跑只读场景（1、4），再跑写/混合场景（2、3、5、6）。写场景会让盘进入「写满 → GC」
  状态，后续读场景的延迟会明显漂移；
- **每轮前记录盘的 SMART 基线**（复位后在宿主侧用 `nvme smart-log` 读 `data_units_written`），
  写进同一目录的 `device_state.json`，否则跨天数据不可比。

失败处理：任一场景退出码非 0、日志里没有 `Total` 行、或 stderr 出现 `error`/`failed`，该场景直接失败，
**不补零、不跳过**，保留 `rep*.log` 与 `rep*.err` 供复盘。

## 指标与产物

`spdk_nvme_perf` 运行结束打印固定格式汇总块（`=` 分隔，最后一行是 `Total`）：

```text
========================================================
                                              Latency(us)
Device Information           :       IOPS      MiB/s    Average        min        max
0000:02:00.0 from core  0:   123456.78     482.25       21.30       9.80     110.40
========================================================
Total                        :   123456.78     482.25       21.30       9.80     110.40
```

只取 `Total` 行（要求全文件**恰好一行**，多了或少了都判失败），按列取 IOPS、MiB/s、Average/min/max
延迟（单位 μs）。手工提取可以直接用 awk：

```bash
# 从一份 rep 日志里取 Total 行的 4 个数值（IOPS / MiB/s / 平均延迟 / 最大延迟）
awk -F: '/^Total/ { split($2, f, " "); printf "%s %s %s %s\n", f[1], f[2], f[3], f[6] }' \
  "${RESULTS_DIR}/runs/4k_randread_qd128/rep1.log"
```

| 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|
| `<scenario>_iops` | `Total` 行第 2 列 | IOPS | 越高越好 |
| `<scenario>_mib_per_s` | `Total` 行第 3 列 | MiB/s | 越高越好 |
| `<scenario>_latency_avg_us` | `Total` 行第 4 列 | μs | 越低越好 |
| `<scenario>_latency_max_us` | `Total` 行第 6 列 | μs | 越低越好 |

**指标总数：6 个场景 × 4 指标 = 24 项**，按场景名分组，两架构同矩阵、同参数、按同名指标配对。
注意这 24 项与流水线内 `bdevperf` 口径的 40 项**不能混算**：一个是真实盘 + 用户态 NVMe 驱动，
一个是 Malloc bdev + 内存，两者只共享软件版本与测量工具语义。

建议的产物布局（人工执行时自行创建）：

| 产物 | 内容 |
|---|---|
| `runs/<scenario>/rep0.log` | 预热轮原始输出（不参与统计） |
| `runs/<scenario>/rep{1..5}.log` | 5 次有效采样的原始输出，`Total` 行来自这里 |
| `runs/<scenario>/rep{1..5}.err` | stderr（I/O 错误、EAL 警告都落这里） |
| `device_state.json` | 盘的型号/序列号/固件、SMART `data_units_written`、大页数量、驱动、BDF |
| `report.md` | 中位数表 + 环境表 |

## 独立运行（手工）

本手册不依赖仓库入口脚本（`spdk_test.sh` 只跑 `bdevperf` 口径）。完整操作就是上文命令按顺序执行：

```bash
# 0) 变量
export SPDK_TARGET_PCI="0000:02:00.0"   # 来自选盘步骤
export SPDK_SYSTEM_PCI="0000:01:00.0"   # 由 root 分区反查得到
export RESULTS_DIR="/home/runner/spdk-nvme-results/26.01"
export PERF_RUN_ID="manual-$(date +%Y%m%d-%H%M%S)"
export SPDK_CONTAINER_NAME="boostkit-spdk-nvme-${PERF_RUN_ID}"
export SPDK_CONTAINER_IMAGE="openeuler/spdk:26.01-oe2403sp2"

# 1) 大页 + 选盘 + 绑定（见「物理机准备」）
# 2) 起容器（见「容器启动」）
# 3) 六个场景 × (预热 + 5 次采样)（见「数据与运行顺序」）
# 4) 提取指标（见「指标与产物」）
# 5) 复位（见「环境复原」）
```

## 环境复原

测量结束必须复位，否则这块盘会一直停在 vfio 驱动下（内核看不到它），机器重启后也无法挂载：

```bash
# 1) 解绑，交回 nvme 驱动
sudo env DEV_TYPE=NVME PCI_ALLOWED="${SPDK_TARGET_PCI}" ./scripts/setup.sh reset

# 2) 校验：驱动回到 nvme，块设备与分区重新出现
lspci -k -s "${SPDK_TARGET_PCI}" | grep 'Kernel driver in use'   # 期望 nvme
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS "${SPDK_TARGET_DEV}"

# 3) 大页清零（reset 不会回收大页）
sudo sh -c 'echo 0 > /proc/sys/vm/nr_hugepages'
grep HugePages_Total /proc/meminfo                                 # 期望 0

# 4) 清理残留映射与容器
sudo ./scripts/setup.sh cleanup
docker rm -f "${SPDK_CONTAINER_NAME}" 2>/dev/null || true
```

若 `reset` 报 `cannot bind to original driver`，用 `lspci -k` 与 `dmesg | tail` 定位，必要时手工
`echo "${SPDK_TARGET_PCI}" | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind` 后再
`echo "${SPDK_TARGET_PCI}" | sudo tee /sys/bus/pci/drivers/nvme/bind`，并在报告里记录这次人工干预。

## 已知限制

- **需要独占可擦写的 NVMe，且不能是系统盘**：本仓库专用 Runner 没有可绑定的盘（流水线内 `bdevperf`
  用例的结论是 I/O 全部落在 Malloc 内存里），因此本手册没有在本仓库自动执行过；数据只对同一块盘、
  同一固件、同一温度窗口可比。
- **破坏性且改宿主机**：大页分配改 `/proc/sys/vm/nr_hugepages`，绑定/解绑改 PCI 设备驱动，属于
  「修改宿主机」，与本仓库「不向宿主机安装、不改系统配置」红线冲突；作业被取消若没走到「环境复原」，
  目标盘会停在 vfio 状态，需要人工复位。
- **容器必须特权且以 root 运行**：`--privileged` + `/dev/vfio` 是访问已绑定设备的最小条件，因此不能
  像其它用例那样加 `--user`；仓库内 redis/rocksdb 的容器测试明确断言「不使用 `--privileged`」，
  本手册是该约定的例外。
- **数值受盘状态支配**：写入会触发 GC 与 SLC 缓存耗尽，同一块盘冷/热状态下的 4K 随机写可能相差数倍；
  「1 次预热 + 5 次采样取中位数」只能压制、不能消除跨天漂移，跨型号比较没有意义。
- **`-c 0x1` 是示例**：只用一个核心发 I/O。不同机器核心编号与 NUMA 关系不同，执行时应按 `lscpu`/`nproc`
  推导掩码并记录，不允许把 `0x1` 当成「标准参数」。
- **`-M` 只对 `rw`/`randrw` 有效**：对 `read`/`write` 传 `-M` 会被忽略并打印提示。

## 与自动化用例的关系

流水线内执行的是 `bdevperf` + `Malloc` bdev 口径（`software/Acceleration/spdk/README.md`），
可在私有非特权容器里复现，用于 SPDK 代码路径的回归；本手册是它的真实盘补充，两者关系：

| 维度 | 流水线用例（bdevperf） | 本手册（spdk_nvme_perf） |
|---|---|---|
| 目标设备 | Malloc bdev（内存） | 独占 NVMe SSD |
| 权限模型 | 私有非特权容器 | `--privileged` + 宿主设备绑定 |
| 可自动化 | 是（六阶段） | 否（人工执行） |
| 指标 | 8 场景 × 5 指标 = 40 项 | 6 场景 × 4 指标 = 24 项 |
| 用途 | 回归基线（同架构可比） | 真实盘性能参考（同盘可比） |

指标数量、场景命名、单位都不同，**不能跨口径比较或合并统计**。
