# UnixBench 6.0.1 性能测试（KVM 参考虚拟机）

本用例在 x86_64、aarch64 上分别运行上游 UnixBench 6.0.1 的完整系统指数测试。
与旧实现不同，**构建和测试都不在容器内执行，而是在本次任务专属的 KVM 虚拟机内执行**，
以对齐「预置条件」中 32 vCPU 绑核、64 GiB 2M 大页、固定 NUMA 节点的参考环境。

软件入口为 `unixbench_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、
测试和停止函数；独立入口也调用同一组函数。`scripts/builders/base.sh` 负责构建参考
虚拟机并在其中编译 UnixBench，`scripts/stages/` 负责虚拟机校验、测试和清理，
`scripts/results/` 负责解析官方报告。`optimized` 构建入口尚未实现，选择后在构建阶段明确失败。

## 参考环境与预置条件的对应关系

| 预置条件 | 本用例的实现 |
|---|---|
| 2M 大页 | 虚拟机内存由宿主 2M hugepage 直接支撑（`<hugepages><page size='2048'/></hugepages>` + `memfd`），不使用 `RAM` 后备内存 |
| 32 vCPU | 虚拟机固定 32 vCPU；x86_64 绑定宿主 `24-39,216-231`（NUMA 1 内 16 个物理核 × 2 SMT），aarch64 绑定宿主 `96-127`（NUMA 1 内 16 个物理核 × 2 SMT） |
| NUMA 绑定 | `<numatune><memory mode='strict' nodeset='1'/></numatune>`，vCPU、emulator、内存全部落在同一宿主 NUMA 节点 |
| 64 GiB 内存 | `<memory>67108864 KiB</memory>`，启动时一次性分配 32768 个 2M 大页 |
| 操作系统 | openEuler 24.03 LTS SP4 cloud 镜像（`/home/libvirt-images/boostkit-unixbench-golden-<arch>.qcow2`），构建阶段读取虚拟机 `/etc/os-release` 并校验 `VERSION_ID="24.03"` |
| UnixBench 版本 | 上游 v6.0.1 固定归档（SHA-256 `e52257ae…e31faa`），`Run` 中 `version = "6.0.1"` |
| `make all` | `make -C /root/byte-unixbench-6.0.1/UnixBench -j32`，使用上游默认编译选项，不修改源码 |
| `./Run` 副本数 | 上游 `Run` 的系统测试组 `maxCopies => 0`，实际等价于「按 CPU 数」，在本虚拟机内为 32 个副本；无需、也没有修改 `Run` |
| BIOS SRIOV / HIBOOST | 属于宿主机 BIOS 事实，不由用例修改；两台参考机型的 BIOS 配置见 PR 说明 |

每台 Runner 首次使用前执行一次宿主准备脚本（见下节），生成 golden 镜像并注入 SSH 公钥；
之后每次运行只创建 qcow2 overlay，不重新安装系统。

## 宿主准备（Runner 一次性）

```bash
sudo bash software/Others/unixbench/scripts/host/prepare-vm-host.sh
```

脚本完成以下工作：

1. 安装 `libvirt`、`qemu-kvm`、`virt-install`、`qemu-img`、`xorriso`、`nbd` 相关包，
   启动并 enable `libvirtd`，确认 `/dev/kvm` 与 `default` NAT 网络可用。
2. 下载对应架构的 openEuler 24.03 LTS SP4 cloud 镜像（或复用已有文件），
   放到 `/home/libvirt-images/`，并做 SHA-256 校验。
3. 生成 Runner 到虚拟机的 SSH 密钥 `/home/runner/software/unixbench/vm/id_ed25519`，
   通过 `qemu-nbd` 挂载镜像，注入 `root` 的 `authorized_keys`、关闭密码登录、
   设置主机名、关闭 SELinux enforcing、确保 sshd 与 NetworkManager 开机自启。
4. 清理临时挂载，保留 golden 镜像供每次运行创建 overlay。

脚本幂等：镜像已存在且已注入公钥时不会重复下载。`UNIXBENCH_VM_IMAGE_DIR` 可覆盖镜像目录。

## 虚拟机生命周期（每次运行）

构建阶段执行以下步骤：

1. 校验宿主具备 `virsh`/`qemu-img`/`ssh`、`/dev/kvm`、golden 镜像和 SSH 私钥，
   且 `sudo -n virsh version` 可用（Runner 已配置免密 sudo）。
2. 清理上一次异常中断遗留的 `boostkit-unixbench-*` 虚拟机与本 run 之外的 overlay。
3. 在宿主 NUMA 1 上把 2M 大页数提升到 32768（64 GiB），等待 `free_hugepages` 达标。
4. 用 `qemu-img create -b golden` 创建本次专属 overlay，渲染并 `virsh define` 如下规格的虚拟机：

```bash
virsh define "${UNIXBENCH_VM_RUN_DIR}/vm.xml"   # 名称 boostkit-unixbench-<架构>-<运行 ID>
virsh start  "boostkit-unixbench-<架构>-<运行 ID>"
```

虚拟机使用 libvirt `default` NAT 网络，脚本通过 DHCP lease 自动发现 IP，
等待 SSH 就绪后记录到 `${PERF_WORK_DIR}/vm-state.env`，供后续阶段复用。
每次运行的控制台日志写入 `/home/libvirt-images/runs/<运行 ID>/console.log`。

5. 虚拟机内用 `dnf install --setopt=install_weak_deps=False` 安装 GCC、Make、Perl、
   `perl-Time-HiRes` 等依赖；源码归档优先取
   `/home/runner/software/unixbench/v6.0.1.tar.gz`，缺失时下载上游 v6.0.1 归档，
   校验固定 SHA-256 后通过 `scp` 传入虚拟机并解压。
6. 在虚拟机内 `make -C /root/byte-unixbench-6.0.1/UnixBench -j32`，核对 `Run` 版本
   与 `pgms/dhry2reg`，并把实际版本写入结果目录。

启动阶段校验虚拟机仍在运行、`nproc` 为 32、编译产物与 `Time::HiRes` 可用；
测试阶段在虚拟机内执行官方完整命令，停止阶段销毁并 undefine 本次虚拟机、删除 overlay、
释放大页，因此 `stop` 幂等且可安全重跑。

网络代理：正式工作流若设置 `PERF_PROXY`，虚拟机内 `dnf`/`curl` 会通过
`192.168.122.1`（宿主 virbr0 地址）访问该代理；未设置时直连。

## 数据与运行顺序

1. 在虚拟机内确认编译产物和 Perl `Time::HiRes` 可用。
2. 在虚拟机内进入 `UnixBench` 目录，执行上游完整默认命令：

   ```bash
   ./Run
   ```

3. `Run` 先测试 1 个副本，再按检测到的 CPU 数（32）测试多副本。测试包含官方
   系统指数的 12 个子项，包括三项 File Copy I/O；不传 `-i`、`-c` 或子项名，
   保留上游默认迭代次数和各子项参数。
4. 解析两个完整档位的原始结果和指数。停止阶段销毁本次虚拟机并释放宿主大页。

该命令和副本规则来自上游 [UnixBench 使用说明](https://github.com/kdlucas/byte-unixbench/blob/v6.0.1/UnixBench/USAGE)。
脚本仅通过以下上游环境变量指定文件位置，不改变测试口径：

| 变量 | 设置值 | 用途 |
|---|---|---|
| `UB_RESULTDIR` | `/root/unixbench-results/unixbench-official`（虚拟机内） | 保存官方文本报告、HTML 和日志 |
| `UB_TMPDIR` | `/root/unixbench-results/tmp`（虚拟机内） | File Copy 的临时数据位于虚拟机磁盘，不使用 `/tmp` |
| `UB_OUTPUT_FILE_NAME` | `unixbench-index` | 固定官方报告文件名 |

测试结束后把官方报告拷回 `${RESULTS_DIR}/unixbench-official/unixbench-index`。

## 指标与产物

每个副本档位要求以下完整结果：

| 指标 | 官方报告来源 | 单位 | 方向 |
|---|---|---|---|
| 12 项子指数 | `System Benchmarks Index Values` 中各子项的 `INDEX` 列 | index | 越大越好 |
| 系统总指数 | `System Benchmarks Index Score` | index | 越大越好 |

单副本和多副本各 13 项，共 26 项。原始测量值与采样数保留在上游原始报告中，
解析器核对原始测量值与指数表的 `RESULT` 列，但不另列为对比指标；采样由上游
`./Run` 自行处理。报告按实际副本数分组，本用例固定为 `1 copy` 与 `32 copies`；
解析器要求多副本档位必须等于参考虚拟机的 32 vCPU 数。子项缺失、只生成
`Partial Index`、或副本数不符合参考环境时，测试直接失败。

| 产物 | 内容 |
|---|---|
| `unixbench-official/unixbench-index` | 上游官方文本报告（从虚拟机拷回） |
| `vm-environment.txt` | 宿主大页/机型信息、`virsh dumpxml`、虚拟机 `os-release`/`lscpu`/`meminfo`/cmdline 证据；构建阶段还强制校验 `VERSION_ID="24.03"` |
| `benchmark_unixbench_raw.log` | 完整控制台输出 |
| `benchmark_unixbench.json` | 26 项指数指标、实际副本数与虚拟机参数 |
| `build_variant.json` | 本次选择的构建类型 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

脱离 Workflow 执行完整流程（需在具备 KVM 的 Runner 上以 `runner` 用户执行）：

```bash
bash software/Others/unixbench/unixbench_test.sh \
  --version 6.0.1 \
  --variant base \
  --results-dir /home/runner/unixbench-results/6.0.1
```

独立运行可加 `--keep-workdir` 保留本次私有目录排查问题；默认清理该工作目录，
但保留传入的结果目录。`optimized` 目前仅验证入口会明确失败，不运行性能测试。

## 与旧容器方案、上游 master 的差异

- **容器 → 虚拟机**：旧方案在 `--network=host` 容器内执行，共享宿主内核、不绑核、
  按 384 个 CPU 生成 384 副本；新方案在 32 vCPU 绑核、64 GiB 2M 大页的虚拟机内生成
  32 副本。两者结果不可横向比较，历史结果继续保留在 performance-results 中，不做清理。
- **操作系统**：预置条件要求 openEuler 24.03 LTS SP1；仓库现有基础镜像为 SP4，
  本用例沿用 SP4，并在 PR 中记录该偏差。
- **UnixBench 版本**：预置条件正文来自上游 master 文档，但其 `Run` 的
  `maxCopies => 0`（按 CPU 数）与 6.0.1 完全一致，`sed 16 => nproc` 对两者都是空操作；
  本用例保持 6.0.1 不变。
- **SRIOV / HIBOOST**：属于宿主 BIOS 与网卡配置，不在用例脚本内修改。
