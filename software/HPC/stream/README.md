# STREAM 5.10 性能测试（KVM 参考虚拟机）

本用例在 x86_64、aarch64 上分别运行上游 STREAM 5.10 的内存带宽测试，数组规模固定为
**200M 元素**（`STREAM_ARRAY_SIZE=200000000`，三个数组共约 4.5 GiB），每个内核迭代 10 次。
**构建和测试都不在容器内执行，而是在本次任务专属的 KVM 虚拟机内执行**：虚拟机固定
16 核 32 线程（16C32T）、128 GiB 内存，vCPU 与内存全部绑定在宿主 **NUMA 0** 的核和内存上，
内存由宿主 **2M 大页**直接支撑，对齐「预置条件」中的参考环境。

软件入口为 `stream_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、测试和停止函数；
独立入口调用同一组函数。`scripts/builders/base.sh` 负责创建参考虚拟机并在其中编译 STREAM，
`scripts/stages/` 负责虚拟机校验、测试和清理，`scripts/results/parse_benchmark.py` 严格解析上游
控制台输出。`optimized` 构建入口位于 `scripts/builders/optimized.sh`，**尚未实现**：选择后会在
构建阶段明确失败（退出码 40），不会退回基础版，也不产生任何数字。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | [STREAM](https://github.com/jeffhammond/STREAM) 5.10，固定提交 `6703f7504a38a8da96b353cadafa64d3c2d7a2d3`，归档 SHA-256 `977651ff…203f67` | 宿主缓存 `/home/runner/software/stream/STREAM-6703f750….tar.gz`，缺失时下载到 `${PERF_WORK_DIR}`，校验后 `scp` 进虚拟机 `/root/stream-6703f750/` |
| 编译器 | openEuler 24.03 LTS SP4 仓库的 `gcc`（虚拟机内 `dnf install`，虚拟机无出网时由宿主下载同版本 RPM 后离线安装），`gcc -dumpfullversion -dumpversion` 记录到 `build-info.txt` | 虚拟机内 `/usr/bin/gcc` |
| 参考虚拟机镜像 | [openEuler 24.03 LTS SP4 官方虚拟化镜像](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/virtual_machine_img/)（按架构 `qcow2.xz` + `.sha256sum` 校验） | 优先读取 `/home/libvirt-images/boostkit-stream-golden-<arch>.qcow2`；每次运行只创建 qcow2 overlay，不重装系统 |
| 虚拟化栈 | 宿主 `libvirt` + `qemu-kvm`（`/usr/libexec/qemu-kvm`）、`qemu-img`、`virsh`、`ssh` | 宿主 `/usr/bin`；由 `scripts/host/prepare-vm-host.sh` 一次性安装并校验 `/dev/kvm` |
| 采样与解析 | 本仓库 `scripts/results/parse_benchmark.py`（无第三方依赖） | 宿主 `${SCRIPT_DIR}/scripts/results/` |

本用例**不使用容器**：预置条件要求 2M 大页、固定 NUMA 绑核和 16C32T 的独立内核视图，
这些约束由 libvirt 域直接表达；容器共享宿主内核，无法同时满足大页与绑核语义。
宿主机只承担 libvirt/QEMU、golden 镜像与结果解析，不向宿主机安装被测软件，也不修改宿主机的
软件源、信任库、内核参数或调度配置；STREAM 及其编译依赖全部装在虚拟机内。

## 参考环境与预置条件的对应关系

| 预置条件 | 本用例的实现 |
|---|---|
| 2M 大页 | 虚拟机内存由宿主 2M hugepage 直接支撑（`<hugepages><page size='2048' unit='KiB'/></hugepages>` + `memfd` + `allocation mode='immediate'`），不使用普通匿名内存；128 GiB 需要 65536 个 2M 大页 |
| 16C32T | 虚拟机固定 16 个物理核 × 2 SMT 线程 = 32 vCPU；核按宿主拓扑**动态选取**（见下） |
| NUMA 0 | `<numatune><memory mode='strict' nodeset='0'/></numatune>`，vCPU 与 emulator 全部钉在同一节点的 CPU 集合内 |
| 128 GiB 内存 | `<memory unit='MiB'>131072</memory>`，启动前把 NUMA 0 的 `nr_hugepages` 提升到 65536 个 2M 页 |
| 绑核 | 每个 vCPU 一对一 `<vcpupin>`，`<emulatorpin>` 与 vCPU 同集合，二者都取自 NUMA 0 |
| 操作系统 | openEuler 24.03 LTS SP4 cloud 镜像；构建阶段读取虚拟机 `/etc/os-release` 并强制校验 `VERSION_ID="24.03"` |
| 200M 执行文件 | 虚拟机内 `gcc -O3 -fopenmp -DSTREAM_ARRAY_SIZE=200000000 -DNTIMES=10 -mcmodel=large stream.c -o stream_200M`，未修改源码 |
| `./stream_200M` | 测试阶段在二进制所在目录直接执行，每轮完整控制台输出落盘 |

绑核的 CPU 集合不写死：脚本读取 `/sys/devices/system/node/node0/cpulist` 得到该节点的 CPU 列表，
用 `/sys/devices/system/cpu/cpuN/topology/thread_siblings_list` 把同核 SMT 兄弟合并成物理核，
再取该节点的前 16 个物理核（含其兄弟线程）组成 cpuset。2 socket/4 NUMA 的机型（例如 96 核/节点）
得到 `0-31`；单 NUMA 的机型得到该节点内可用的核；节点内不足 16 核时按实际核数运行并在日志中
写 `WARNING`，`vm-environment.txt` 记录最终 cpuset。

## 宿主准备（Runner 一次性）

```bash
sudo bash software/HPC/stream/scripts/host/prepare-vm-host.sh
```

以下是脚本执行的实际命令形态与顺序：

1. `dnf install -y --setopt=install_weak_deps=False libvirt libvirt-client libvirt-daemon libvirt-daemon-driver-qemu qemu-img virt-install xorriso nbd`，
   必要时补装 `qemu-kvm`，并校验 `/usr/libexec/qemu-kvm` 与 `/dev/kvm` 存在。
2. `systemctl enable --now libvirtd`（无 systemd 的宿主退化为 `/usr/sbin/libvirtd --daemon`），
   `virsh version` 可用，`virsh net-start default` + `virsh net-autostart default`，`virbr0` 为 `192.168.122.1/24`。
3. 打开 `net.ipv4.ip_forward`：虚拟机要通过 `virbr0` 的 NAT 访问软件源安装编译工具链，
   脚本发现该值不为 `1` 时执行 `sysctl -w net.ipv4.ip_forward=1` 并写入
   `/etc/sysctl.d/99-boostkit-qemu-vm.conf` 持久化（Blue 机器实测默认是 `0`，此时虚拟机能拿到
   DHCP 地址、DNS 可用，但出网全部超时）。
4. 下载并按官方 `.sha256sum` 校验镜像，`xz -dkf` 解压后命名为
   `/home/libvirt-images/boostkit-stream-golden-<arch>.qcow2`。
5. 生成 `/home/runner/software/stream/vm/id_ed25519{,.pub}`，用 `qemu-nbd`（无 nbd 模块时退化为
   `qemu-img convert` + `mount -o loop,offset=`）挂载根分区，注入 `root` 的 `authorized_keys`、
   `/etc/ssh/sshd_config.d/99-boostkit.conf`（`PermitRootLogin prohibit-password`、`PasswordAuthentication no`）、
   主机名 `stream-vm`，SELinux 置 `permissive`，随后卸载并把镜像写回 qcow2。

脚本幂等：镜像已存在且已注入当前公钥时直接退出。`STREAM_VM_IMAGE_DIR`、`STREAM_VM_KEY_DIR` 可覆盖默认路径。

- **脚本出处**：`scripts/host/prepare-vm-host.sh`

## 虚拟机生命周期（每次运行）

构建阶段执行以下步骤，全部命令对宿主只读或只操作本次命名的资源：

1. 校验宿主具备 `virsh`、`qemu-img`、`ssh`、`scp`、`sha256sum`、免密 `sudo` 与 `sudo -n virsh version`，
   golden 镜像和 SSH 私钥存在；`STREAM_VM_ACCEL=kvm` 时强制要求 `/dev/kvm`。
2. 清理上一次异常中断遗留的 `boostkit-stream-*` 域与本次运行之外的 overlay 目录。
3. 按拓扑选取 cpuset，记录原始大页池大小，把 NUMA 0 的 `nr_hugepages` 提升到 65536 并等待
   `free_hugepages` 达标（30 秒超时）。
4. `qemu-img create -f qcow2 -F qcow2 -b <golden> <overlay>` 创建本次专属 overlay，渲染并 `virsh define` 如下规格：

```bash
virsh define "${STREAM_VM_RUN_DIR}/vm.xml"     # 域名 boostkit-stream-<架构>-<运行 ID>
virsh start  "boostkit-stream-<架构>-<运行 ID>"
```

```xml
<domain type='kvm'>
  <name>boostkit-stream-aarch64-&lt;run-id&gt;</name>
  <memory unit='MiB'>131072</memory>
  <memoryBacking>
    <hugepages><page size='2048' unit='KiB'/></hugepages>
    <source type='memfd'/><access mode='shared'/>
    <allocation mode='immediate' threads='4'/>
  </memoryBacking>
  <vcpu placement='static'>32</vcpu>
  <cputune>
    <vcpupin vcpu='0' cpuset='0'/> ... <vcpupin vcpu='31' cpuset='31'/>
    <emulatorpin cpuset='0-31'/>
  </cputune>
  <numatune><memory mode='strict' nodeset='0'/></numatune>
  <cpu mode='host-passthrough' check='none' migratable='off'>
    <topology sockets='1' dies='1' clusters='1' cores='16' threads='2'/>
  </cpu>
  ...
</domain>
```

5. 虚拟机使用 libvirt `default` NAT 网络；脚本用 `virsh domifaddr --source lease` 发现 IPv4，
   等 SSH 就绪且 `nproc` 等于预期 vCPU 数后把 `vm_ip` 写入 `${PERF_WORK_DIR}/vm-state.env`；
   控制台日志写 `/home/libvirt-images/runs/<运行 ID>/console.log`。
6. 虚拟机内安装编译工具链，两条路径按虚拟机实际网络情况自动选择，尝试结果写入
   `build-info.txt` 的 `guest_toolchain_source`/`guest_toolchain_install_attempt`：
   - 虚拟机可出网：`dnf install -y --setopt=install_weak_deps=False gcc make tar gzip numactl procps-ng util-linux`，
     镜像元数据不一致时依次重试（原样 → `--refresh` → `--disablerepo='*update*' --setopt=strict=0`）；
   - 虚拟机无出网：宿主用同发行版同架构的 `dnf download --resolve --alldeps` 把上述包及其依赖下载到
     `/home/runner/software/stream/rpms/<arch>/`，打包 `scp` 进虚拟机后
     `dnf install -y --disablerepo="*" --nogpgcheck /root/stream-rpms/*.rpm` 离线安装。
   若工作流设置 `PERF_PROXY`，虚拟机内 `dnf`/`curl` 通过 `192.168.122.1`（宿主 virbr0）访问该代理。
7. 把 `vm-environment.txt` 写入结果目录：宿主加速器、cpuset/核数/线程数、大页池、`virsh dumpxml`
   全文，以及虚拟机内 `os-release`、`lscpu`、`meminfo`、`/proc/cmdline`。

启动阶段重新校验域在运行、SSH 可达、`nproc` 等于 vCPU 数、`stream_200M` 可执行，并写
`service-state.json`。停止阶段 `virsh destroy` + `virsh undefine --nvram`、删除 overlay、
把大页池恢复到本次运行前的页数、删除状态文件，因此 `stop` 幂等且可安全重跑。

- **脚本出处**：`scripts/common.sh`、`scripts/stages/{start,test,stop}.sh`

## STREAM 获取、构建与虚拟机启动

获取顺序固定为三级，每一级都做 SHA-256 校验，任一候选不匹配即换下一个，全部失败才终止：

1. 公共离线目录 `/home/runner/software/stream/STREAM-6703f750….tar.gz`（离线 runner 的预置件）；
2. 本任务缓存 `${PERF_WORK_DIR}/STREAM-6703f750….tar.gz`；
3. 上游 `https://codeload.github.com/jeffhammond/STREAM/tar.gz/6703f7504a38a8da96b353cadafa64d3c2d7a2d3`，
   失败时回退 `https://github.com/jeffhammond/STREAM/archive/6703f750….tar.gz`。

```bash
# 实际命令形态（宿主）
curl -fL --retry 3 --connect-timeout 30 -o "${PERF_WORK_DIR}/STREAM-6703f750....tar.gz.part" \
  "https://codeload.github.com/jeffhammond/STREAM/tar.gz/6703f7504a38a8da96b353cadafa64d3c2d7a2d3"
sha256sum -c <<< "977651ffb22de4f5a2fc8a0d8d647b84f3f007c0a77bbdc36ce583872b203f67  ${PERF_WORK_DIR}/STREAM-6703f750....tar.gz"
tar -tzf "${PERF_WORK_DIR}/STREAM-6703f750....tar.gz" | python3 scripts/results/verify_archive.py
scp -i /home/runner/software/stream/vm/id_ed25519 STREAM-6703f750....tar.gz root@${STREAM_VM_IP}:/root/
```

```bash
# 实际命令形态（虚拟机内，由 vm_exec 执行）
tar -xzf /root/STREAM-6703f750....tar.gz -C /root
cd /root/stream-6703f750 && gcc -O3 -fopenmp -DSTREAM_ARRAY_SIZE=200000000 -DNTIMES=10 \
  -mcmodel=large stream.c -o stream_200M
```

构建完成后校验 `stream_200M` 可执行，并把实际版本、编译参数、gcc 版本、二进制 SHA-256 与字节数
写入 `build-info.txt`；源码内 `Revision: 5.10` 与 `case.yaml` 的版本不一致时直接失败
（退出码 40）。归档目录结构由 `verify_archive.py` 检查：所有条目必须以 `STREAM-<sha>/` 开头、
不含绝对路径或 `..`、且包含 `stream.c`。

aarch64 上上述**原始命令无法链接**：STREAM 的三个 200M 元素数组让 `.bss` 达到约 4.8 GiB，
GCC 12 预编译的 `libgcc.a` 里 `lse-init.o`/`ldadd_4_1.o` 用 `ADRP` 访问该段时超出 ±4 GiB 范围，
报 `relocation truncated to fit: R_AARCH64_ADR_PREL_PG_HI21`。用例保持原始参数不变，仅在链接失败时
（且仅 aarch64）追加 `-mno-outline-atomics` 重试一次，实际生效参数写入 `build-info.txt` 的
`compile_flags`/`compile_extra_flags` 并进入结果 `parameters`；x86_64 仍使用原始命令。

- **脚本出处**：`scripts/builders/base.sh`

## 数据与运行顺序

1. 构建阶段在虚拟机内编译 `stream_200M`（200M 元素 = 3 × 1.6 GB 数组，共约 4.5 GiB）。
2. 测试阶段在同一虚拟机的二进制目录内执行上游默认入口，共 **6 轮**（1 轮预热 + 5 轮有效）：

   ```bash
   # 实际命令形态：vm_exec_shell 把该命令串交给虚拟机登录 shell 执行
   bash -c 'cd /root/stream-6703f750 && ./stream_200M'
   ```

3. 每轮完整控制台输出写 `runs/rep<i>.log`，并按轮次追加到 `benchmark_stream_raw.log`；
   预热轮不进入统计。
4. STREAM 自身对每个内核（Copy/Scale/Add/Triad）迭代 `NTIMES=10` 次，报告的是**排除第 1 次迭代
   后的最好成绩**，这是上游口径，用例不修改。
5. 每轮都必须出现 `STREAM version $Revision: 5.10 $`、`Array size = 200000000 (elements)`、
   `Number of Threads counted = <vCPU 数>`、四行内核结果表和 `Solution Validates`；出现
   `Failed Validation on array` 直接判该轮失败。

| 参数 | 取值 | 来源 |
|---|---|---|
| 数组规模 | 200000000 元素 | 预置条件 |
| 每内核迭代 | 10 | 预置条件 |
| 编译选项 | `-O3 -fopenmp -mcmodel=large` | 预置条件 |
| vCPU | 16 核 × 2 线程 = 32 | 预置条件 16C32T |
| 内存 | 131072 MiB | 预置条件 128G |
| 大页 | 2048 KiB × 65536 | 预置条件 2M 大页 |
| NUMA | 内存与 vCPU 均在 node 0 | 预置条件 |
| 轮次 | 6（1 预热 + 5 有效） | 仓库采样契约 |

## 指标与产物

每个有效轮次产生 8 项数值，跨 5 个有效轮次取**中位数**，另加 3 项负载事实（共 11 项）：

| 指标 | 上游输出列 | 单位 | 方向 |
|---|---|---|---|
| `stream.copy.best_rate` | `Copy:` 行的 `Best Rate MB/s` | MB/s | 越大越好 |
| `stream.copy.avg_time` | `Copy:` 行的 `Avg time` | s | 越小越好 |
| `stream.scale.best_rate` | `Scale:` 行的 `Best Rate MB/s` | MB/s | 越大越好 |
| `stream.scale.avg_time` | `Scale:` 行的 `Avg time` | s | 越小越好 |
| `stream.add.best_rate` | `Add:` 行的 `Best Rate MB/s` | MB/s | 越大越好 |
| `stream.add.avg_time` | `Add:` 行的 `Avg time` | s | 越小越好 |
| `stream.triad.best_rate` | `Triad:` 行的 `Best Rate MB/s` | MB/s | 越大越好 |
| `stream.triad.avg_time` | `Triad:` 行的 `Avg time` | s | 越小越好 |
| `stream.array.size` | `Array size = N (elements)` | elements | 中性 |
| `stream.kernel.iterations` | `Each kernel will be executed N times.` | iterations | 中性 |
| `stream.threads` | `Number of Threads counted = N` | threads | 中性 |

`MB/s` 沿用上游口径（1 MB = 10⁶ 字节）；`Avg time` 取上游打印的每内核平均时间。

| 产物 | 内容 |
|---|---|
| `benchmark_stream_raw.log` | 6 轮完整控制台输出（含轮次头与虚拟机参数），单文件约 20 KB |
| `runs/rep<i>.log` | 第 i 轮原始输出，供复核 |
| `benchmark_stream.json` | 11 项指标 + 每轮逐内核原始值 + 参数与轮次元数据 + raw log 的 SHA-256 |
| `vm-environment.txt` | 宿主 cpuset/大页、`virsh dumpxml` 全文、虚拟机 `os-release`/`lscpu`/`meminfo`/`cmdline` |
| `build-info.txt` | 实际版本、编译参数、gcc 版本、二进制 SHA-256 与大小 |
| `build_variant.json`、`service-state.json` | 变体与虚拟机运行时快照 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

解析严格性：轮次数不足 6、缺任一 `rep<i>.log`、四行内核结果表缺一行、表头缺失、数组规模 ≠ 200000000、
`NTIMES ≠ 10`、OpenMP 线程数 ≠ 虚拟机 vCPU 数、任一轮出现 `Failed Validation`、任一数值非正或非有限，
都会以非零码失败并打印具体文件与原因，**绝不补零、绝不降级为部分指标**。

- **脚本出处**：`scripts/results/parse_benchmark.py`、`scripts/stages/test.sh`

## 独立运行

在具备 KVM 的 Runner 上以 `runner` 用户执行同一批函数（默认工作目录 `/home/runner/boostkit-perf/stream/local-<run-id>`）：

```bash
bash software/HPC/stream/stream_test.sh \
  --version 5.10 \
  --variant base \
  --results-dir /home/runner/stream-results/5.10
```

- `--variant optimized`：构建阶段立即失败（`ERROR: the optimized STREAM build is not implemented`），不产生数字。
- `--results-dir`：指定结果落盘目录；`--keep-workdir` 保留本次私有目录便于排查，默认清理。
- 结果目录内可直接查看 `benchmark_stream.json`、`report.md`、`results.json`、`vm-environment.txt`。
- 基线：本用例不写死任何基准数值，`update_baseline` 由调用方控制，正式结果由流水线写入
  `performance-results` 分支。

## 已知限制

- **虚拟机而非容器**：为使 2M 大页、NUMA 绑核和 16C32T 内核视图成立，本用例在 KVM 虚拟机内运行，
  不使用仓库通用的 openEuler 容器；因此 `docker load` 等容器步骤在本用例中不适用。
- **与整机直跑的差异**：STREAM 在虚拟机内运行，测得的带宽包含虚拟化开销（vCPU 陷入、第二级地址翻译），
  数值低于同硬件整机直跑属正常现象；本用例只用于同机型、同规格虚拟机之间的横向比较。
- **本地链路验证降级为 TCG**：WSL 等无 `/dev/kvm` 的机器上，用例自动退化为 QEMU TCG
  （`<domain type='qemu'>`）、关闭大页并把内存降到可用范围，只用于验证虚拟机创建、SSH、编译、
  执行与解析链路，**这些数字不能作为性能证据**；正式证据取 aarch64 KVM 全规格运行。
- **核数随宿主拓扑**：参考环境是 16C32T；若所选 NUMA 节点的物理核少于 16，用例按实际核数运行并
  记录 `WARNING`，不伪造线程数。x86_64 与 aarch64 的 STREAM 数字跨机器不可横向比较。
- **SMT 依赖**：16C32T 的第二路线程依赖宿主开启 SMT；宿主关闭 SMT 时该节点只能提供 16 线程，
  用例按 16C16T 运行并在 `vm-environment.txt` 记录。
- **大页池共享**：启动前把 NUMA 0 的 `nr_hugepages` 提升到至少 65536，停止阶段恢复到运行前的页数；
  若宿主同时有其他大页使用者，本次运行可能因 `free_hugepages` 不足而在 30 秒后明确失败。
- **不改内核参数**：`/proc/cmdline`、THP、调度器参数均由宿主决定，用例只读取并记录。
- **aarch64 需追加 `-mno-outline-atomics`**：原始编译命令在 aarch64 + GCC 12 上因 `.bss` 超过
  ±4 GiB 而链接失败（`relocation truncated to fit: R_AARCH64_ADR_PREL_PG_HI21`），用例自动追加该
  链接参数重试并在产物中标注；算法、数组规模、`NTIMES`、`-mcmodel=large` 均未改动。
- **未实现 optimized 变体**：`scripts/builders/optimized.sh` 只返回失败，不产生任何数字。
- **网络**：宿主下载只走 GitHub 与 openEuler 官方仓库；离线 runner 依赖
  `/home/runner/software/stream/` 预置归档与 `/home/libvirt-images/` 的 golden 镜像。
- **虚拟机出网依赖宿主转发**：Blue 机器默认 `net.ipv4.ip_forward=0`，此时虚拟机可拿到 DHCP 地址、
  DNS 可用但所有出网连接超时；宿主准备脚本会打开并持久化该开关，未打开且宿主有 `dnf` 时构建阶段
  自动退回「宿主下载 RPM + 虚拟机离线安装」，两者都不可用时明确失败，不跳过编译。
- **无基准数字**：本 README 不写任何未经产物验证的数值。

## 与参考材料的关系

- 上游 STREAM 的编译与执行命令、数组规模（200M）、`NTIMES=10`、`-mcmodel=large` 来自预置条件的
  原文，未做改动；`./stream_200M` 的调用方式与上游 `README` 一致。
- 虚拟机形态、libvirt 域结构与「宿主一次性准备 + 每次运行 overlay」的组织方式沿用 main 分支
  `software/Others/unixbench` 的参考虚拟机实现，以保证同一 Runner 上两类虚拟机用例的行为一致。
- 与旧容器方案（在 `--network=host` 容器内直接跑 STREAM）不可横向比较：容器共享宿主内核、
  不绑核、无法使用 2M 大页；历史结果继续保留在 `performance-results` 中，不做清理。
