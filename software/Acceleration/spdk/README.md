# SPDK v26.09 性能评估用例

> **证据边界（先读）**：本用例测量的是 **SPDK 用户态块存储栈路径**（`bdevperf` → bdev 层 → `Malloc` bdev），
> 而不是物理 SSD/NVMe 的性能。专用 Runner 没有 NVMe 盘，`Malloc` bdev 的 I/O 全部落在内存中，
> 因此 IOPS、带宽、延迟都**不能**用来评价任何存储介质、也不代表真实盘阵性能。
> 它只适合验证 SPDK v26.09 能否在该架构上构建、启动并跑通完整测量链路，以及跟踪 SPDK/DPDK 自身代码路径的回归。

## 1. 版本与来源

| 项目 | 值 |
|---|---|
| 软件 | SPDK |
| 用例版本（`case.yaml`） | `26.09`（由构建产物 `include/spdk/version.h` 的 MAJOR/MINOR 得到） |
| 上游完整版本 | `26.09.0`（源码 `VERSION` 文件，构建时校验） |
| 上游 tag | `v26.09`，`https://github.com/spdk/spdk` |
| SPDK 归档 SHA-256 | `b0206d47bf0859daf6b195a438d0433644bcdb0cf6dca5d143cdf285a21506dc` |
| SPDK 源码树 SHA-256 | `8174a666e91dd7c3e98060346083e9eac6d3593f375520cd88c73e0d35fadaa9` |
| DPDK | SPDK 固定子模块 `https://github.com/spdk/dpdk`，commit `37a1a9b926b4678141931f2f22e7a877b5b565c2`，版本 `26.03.0` |
| DPDK 归档 / 源码树 SHA-256 | `6b4ba309717c8ebcfb0c56922ce24ffb12227632decdd2c2f05a0279a6bf5b96` / `e19de03312f467bd7603eb0a2fa91ae32bc71a3c270e59dfbb1334f6a3acb98d` |
| ISA-L | SPDK 固定子模块 `https://github.com/intel/isa-l`，commit `7c3479e0a9dac17f448603ec1ad64c7c625f530c` |
| ISA-L 归档 / 源码树 SHA-256 | `591b0d3e6a679286493fd01eaae7d6de922cbdcf6c02d4ebe6f1a8ef53600f6f` / `0ae8ad7907d5426f59871b697e121451855f38db36a30d75151287d7187a5bd5` |

**统一的来源校验方式**：三个制品都先解包成源码树，再计算"规范化源码树 SHA-256"
（`find . -type f -print0 | LC_ALL=C sort -z | xargs -0 -n 200 sha256sum | sha256sum`，
相对路径、按字节序排序、固定分批），并与上表固定值比较。镜像站可能对归档重新打包
（gitee 的 `repository/archive` 与 GitHub codeload 字节不同），但源码树内容相同，
因此**每个候选来源都用同一个固定 SHA-256 校验**；归档本身的 SHA-256 也会记录到
`build-meta.json` 便于追溯。

获取顺序（逐个尝试，失败就换下一个，每次失败都打印 URL 和实际摘要）：

1. 预置离线目录（首选，Runner 上由运维预置）：`/home/runner/software/spdk/`
   `spdk-v26.09.tar.gz`、`dpdk-37a1a9b926b4678141931f2f22e7a877b5b565c2.tar.gz`、
   `isa-l-7c3479e0a9dac17f448603ec1ad64c7c625f530c.tar.gz`（可用 `PERF_SPDK_OFFLINE_DIR` 覆盖目录）
2. SPDK：`gh-proxy.com` → `gitee.com/mirrors/spdk/repository/archive/v26.09.tar.gz` → 官方 GitHub codeload
3. DPDK：`gh-proxy.com` → 官方 GitHub codeload（该 fork commit 只存在于 GitHub）
4. ISA-L：`gh-proxy.com` → `gitee.com/mirrors/isa-l` → 官方 GitHub codeload

如果全部候选都不可用或摘要不匹配，`build` 阶段以 **30** 退出，并打印尝试过的每个 URL。

## 1.1 容器化执行

本用例的解包、依赖安装、SPDK/DPDK/ISA-L 构建、DPDK 运行档探测与 bdevperf 测量全部在每次
任务专属的 **openEuler 24.03 LTS SP4 私有容器**内完成，与 `software/Database/mysql`、
`software/Bigdata/ray`、`software/Others/unixbench`、`software/Acceleration/eigen` 使用
同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再安装编译器、meson、
CMake 或 dnf 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`（必须为 24.03）。
- 容器：名字 `boostkit-spdk-<arch>-<运行ID>`，标签 `boostkit.spdk.run-id=<运行ID>`，使用
  宿主网络，以 Runner 用户身份运行（`--user $(id -u):$(id -g)`，
  `--ulimit nofile=1048576:1048576`）；只读挂载用例目录，读写挂载 `${PERF_WORK_DIR}` 与
  `${RESULTS_DIR}`，容器内路径与宿主完全相同。
- 容器内：`dnf --setopt=install_weak_deps=False` 安装工具链、meson/ninja、Python 模块、
  autotools、`nasm`、`numactl-devel`、`libuuid-devel`、`libaio-devel` 等（清单见 2.1），
  随后执行三个归档的解包与规范化源码树 SHA-256 校验、`./configure`、`make`（含树内
  DPDK/ISA-L 子构建）、SPDK 版本自证、DPDK 运行档探测（`--no-huge -s 512` 等）、
  bdevperf 测量矩阵与 GNU `time` 计时。`${PERF_WORK_DIR}/home` 作为容器内 `HOME`，
  `build-meta.json` 的编译器版本取自容器。
- 宿主机：只负责下载并校验三个归档（优先 `/home/runner/software/spdk/`，可用
  `PERF_SPDK_OFFLINE_DIR` 覆盖）、调用 Framework、在宿主机执行严格解析
  （`scripts/results/parse_benchmark.py report` 不进入容器）、清理本任务的容器。
- 测量与测量口径：容器内 `parse_benchmark.py drive` 只负责把每条样本跑出来并落盘原始日志 +
  GNU time 计时工件；所有字段级严格校验（唯一 total 行、每个 job 行、p99、fail/timeout=0、
  job IOPS 与 total 一致、峰值 RSS）都在宿主机 `report` 里做，容器无法自证通过。
  `docker exec` 的管理开销不落在计时窗口内：计时来自容器内 GNU time 记录的 bdevperf 进程
  墙钟与峰值 RSS。
- DPDK 运行档：默认沿用无 hugepage 的 `--no-huge -s <MB>` 档位；若容器内 DPDK EAL 因
  capability/共享内存受限而失败，按 `SPDK_CONTAINER_EXTRA_ARGS=(--cap-add=IPC_LOCK)` 或
  `--shm-size` 逐档尝试，并把最终生效的档位写进 `runtime.json` 的 `profile`/`eal_args`
  与 `benchmark_spdk.json` 的 `runtime_context`。
- 清理：`stop` 阶段先在容器内结束本 run 的 bdevperf，再幂等删除本任务容器（标签不符时拒绝
  删除并返回 60）；取消任务遗留的同软件容器会在下一次 build 时按名字前缀 + 运行 ID 清理。
- 本地验证：x86_64 WSL 上用 `PERF_REPS=1` 跑通六阶段（prepare/build/start/test/stop/
  finalize 全部 0），容器删除后 `docker ps -a` 无残留；只验证链路，不作为性能证据。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 2. 安装与构建

构建全部落在本次任务的私有工作目录 `PERF_WORK_DIR`（默认
`/home/runner/boostkit-perf/spdk/local-<run-id>`），不写系统目录、不安装 SPDK 到 `/usr/local`。

### 2.1 系统依赖（容器内 dnf）

构建全部落在本次任务的私有工作目录 `PERF_WORK_DIR`（默认
`/home/runner/boostkit-perf/spdk/local-<run-id>`），不写系统目录、不安装 SPDK 到 `/usr/local`。
依赖安装也在同一个私有容器内完成：`prepare_spdk_build_container` 先启动容器，再用

```bash
dnf -y --skip-broken --setopt=install_weak_deps=False \
    --setopt=proxy=${PERF_PROXY} install <清单>
```

安装（`--skip-broken` 与关闭弱依赖都是必需的：后者避免 `java-devel`/`shadow`/`libutempter`/
`dbus-daemon` 之类弱依赖的 rpm scriptlet 去执行 `groupadd`/`useradd`，而容器块把
`/etc/passwd`、`/etc/group` 只读挂载）。安装后逐个自检必需命令与 Python 模块，缺失就明确
报错（`build` 退出 30），不会静默继续。宿主机不再有 apt 分支：镜像固定为 openEuler。

依赖清单按 SPDK v26.09 的 `scripts/pkgdep.sh` / `scripts/pkgdep/*.sh` 与本用例的
configure 开关逐项对齐：

| 用途 | 容器内 dnf 包名 |
|---|---|
| C/C++ 工具链与 make | `gcc gcc-c++ make` |
| 构建系统 | `meson ninja-build pkgconf` |
| 构建脚本解释器 | `python3 python3-devel python3-pip` |
| SPDK RPC 代码生成：`scripts/genrpc.py` 的 `jinja2` / `yaml` / `tabulate` | `python3-jinja2 python3-pyyaml python3-tabulate` |
| DPDK meson 构建：`dpdk/buildtools/meson.build` 声明 `python3_required_modules = ['elftools']` | `python3-pyelftools` |
| ISA-L autotools 构建 | `autoconf automake libtool` |
| ISA-L x86_64 汇编器（aarch64 用 gas，不需要） | `nasm`（仅 x86_64） |
| DPDK EAL NUMA | `numactl-devel` |
| SPDK UUID | `libuuid-devel` |
| `bdev_aio` 模块 | `libaio-devel` |
| `lib/util/md5.c` 的 OpenSSL 头文件（`openssl/md5.h`，与 `--without-crypto` 无关） | `openssl-devel` |
| 下载、摘要与计时工具 | `findutils coreutils curl tar gzip time util-linux` |

CUnit / ncurses / json-c / cmocka 只被单元测试、`app/` 与 vfio-user 路径引用，本用例已
`--disable-tests --disable-unit-tests --disable-apps --without-vfio-user`，因此**故意不安装**。
包管理器安装失败不会立即判死：命令自检和 Python 模块自检失败才会以 `build` 退出 30 结束，
安装日志尾部会打到 job 日志。

### 2.1.1 Python 模块自举

SPDK 构建期实际依赖的 Python 模块（已按源码逐个核对，不是猜测）：

- `scripts/genrpc.py`：`yaml`、`jinja2`、`tabulate`（在 `include/Makefile` 里生成
  `include/spdk_internal/rpc_autogen.h`，aarch64 的 Actions 首跑就是缺 `jinja2` 挂在
  这一步）；
- DPDK `dpdk/buildtools/meson.build`：`elftools`（meson 构建期检查）。

解析顺序（全部在容器内进行）：容器 `python3` 已具备全部模块 → 使用；否则 `dnf` 安装上表对应
的 `python3-*` 包；否则 `python3 -m pip install`（清华 / 华为云 / PyPI 镜像依次尝试；PEP 668
环境自动加 `--break-system-packages`）。每一档结束后都执行
`python3 -c 'import jinja2, yaml, tabulate, elftools'` 自检；全部失败时打印缺失模块清单、
容器解释器版本与安装日志尾部，`build` 退出 **30**。宿主机 venv 不参与 SPDK 构建。

### 2.2 构建命令

以下命令都在容器内、以 `${PERF_WORK_DIR}` 为工作目录执行（`spdk_container_exec_at`）：

```bash
cd "$PERF_WORK_DIR/src/spdk"           # SPDK v26.09 源码树，已放入 dpdk/ 与 isa-l/
./configure --disable-tests --disable-unit-tests --disable-apps --disable-examples \
  --without-crypto --without-isal-crypto --without-dpdk-compressdev \
  --without-ocf --without-xnvme --without-vfio-user --without-rbd \
  --without-fsdev --without-avahi --without-golang --without-sma --without-nvme-cuse
make -j6                                # 只构建 SPDK 库/模块（含树内 DPDK、ISA-L）
make -j6 -C examples/bdev/bdevperf      # 只构建本用例实际运行的 bdevperf
```

- 构建范围：`--disable-examples` 让默认目标不编译其他示例；随后显式构建
  `examples/bdev/bdevperf`。最终产物只有 `build/examples/bdevperf`（静态链接 SPDK 库）
  与 `build/lib/libspdk_*.a`，不编译 `app/`、其他示例或单元测试。
  `build-meta.json` 的 `build.targets` 记录这两个构建目标。
- 注意：顶层 `make <目标名>` 会把目标透传到所有子目录，不能用来只构建某个子目录
  （`make module` 会报 `No rule to make target 'module'`）；正确做法是先默认目标、再
  `make -C examples/bdev/bdevperf`。
- DPDK 作为 SPDK 树内 `dpdk/` 子模块由 `dpdkbuild` 用 meson/ninja 构建（静态库），
  只编译 SPDK 需要的核心库。
- ISA-L 作为树内 `isa-l/` 子模块由 `isalbuild` 构建（x86_64 用 nasm，aarch64 用 gas）。
- 架构分支：x86_64 用 DPDK 原生指令集；aarch64 用 `-Dplatform=generic` 兜底（当
  `dpdk/config/arm/armv8_machine.py` 不可用时显式传入）。
- 产物：`build/examples/bdevperf`（静态链接 SPDK 库）以及 `build/lib/libspdk_*.a`。
- 实际版本从产物读取：解析 `include/spdk/version.h` 的 MAJOR/MINOR（`26.09`），并校验
  源码 `VERSION` 为 `26.09.0`；写入 `$PERF_ACTUAL_VERSION_FILE`。请求版本与产物版本不一致时
  `build` 以 **30** 退出。

本次本机（WSL Ubuntu 22.04 宿主 + openEuler 24.03 SP4 容器，x86_64，20 核，`-j6`）完整
`build` 阶段实测 3–6 分钟（含容器内 dnf 装依赖、下载与 SHA-256 校验、configure、
DPDK/ISA-L/SPDK 编译；区间来自本机与其它适配任务共享 20 核时的多次实测）。

## 3. 完整测试口径

### 3.1 测量流程

1. `start` 阶段在容器内用 1 秒的 `bdevperf` 冒烟运行探测可用的 DPDK 运行档（Runner 无
   hugepage，优先 `--no-huge -s 512`，失败再试 `-s 1024` / 默认大页），把成功档写入
   `PERF_WORK_DIR/runtime.json`，`test` 阶段复用同一档，保证所有测量运行参数一致。
2. 每个场景先跑 **1 次预热**（结果丢弃），再跑 **5 次独立正式测量**（`PERF_REPS` 可覆盖）。
3. 每个测量进程独占运行 5 秒（`PERF_SPDK_DURATION`，允许 5–10 秒），
   两次测量之间进程完全退出，互不共享缓存状态。
4. 报告值为 **5 个样本的中位数**，同时保留全部样本与 `min/max/mean/stdev`。
5. 测量阶段**离线**：`test` 阶段清除所有代理变量，解析器不做任何网络访问、不下载任何东西。
6. 容器边界：`parse_benchmark.py drive` 在容器内只负责跑样本并记录原始日志 + GNU time
   计时（墙钟、峰值 RSS）；`parse_benchmark.py report` 在宿主机完成全部严格校验与汇总。

原始证据（`$RESULTS_DIR/`）：

```text
runs/<scenario>/warmup.log     预热原始输出
runs/<scenario>/warmup.json    预热计时（start/finish/duration/exit code/peak RSS）
runs/<scenario>/rep<i>.log     第 i 次正式测量原始输出
runs/<scenario>/rep<i>.json    第 i 次正式测量的命令、计时、退出码、峰值 RSS
benchmark_raw.txt              以上全部日志的拼接（便于人工复核）
benchmark_spdk.json            结构化指标 + 样本 + 统计量 + 场景参数
```

### 3.2 场景矩阵（8 个场景，每场景单次 5 秒）

| 场景 | 读写模式 | I/O 大小 | 队列深度 | bdev 数 | 混读比例 |
|---|---|---|---|---|---|
| `randread_bs4k_qd1_single` | randread | 4 KiB | 1 | 1 | — |
| `randread_bs4k_qd32_single` | randread | 4 KiB | 32 | 1 | — |
| `randread_bs4k_qd128_single` | randread | 4 KiB | 128 | 1 | — |
| `randwrite_bs4k_qd32_single` | randwrite | 4 KiB | 32 | 1 | — |
| `randrw_bs4k_qd32_single` | randrw | 4 KiB | 32 | 1 | 70% 读 |
| `randread_bs64k_qd32_single` | randread | 64 KiB | 32 | 1 | — |
| `randread_bs128k_qd32_single` | randread | 128 KiB | 32 | 1 | — |
| `randread_bs4k_qd32_multi4` | randread | 4 KiB | 32 | 4 | — |

- 单 bdev 场景：`-m 0x1` 单核；多 bdev 场景：4 个 `Malloc` bdev + 4 个 job + `-m 0xF`。
- 每个 bdev 固定 16 MiB（512 字节逻辑块 × 32768 块），I/O 在 bdev 内随机分布。
- 每个场景参数由 `-j`（FIO 风格 job 文件）+ 命令行共同固定；解析器会核对 bdevperf 输出的
  `workload`、`depth`、`IO size` 与声明一致，不一致直接失败。

### 3.3 严格解析（不补零、不估算）

`scripts/results/parse_benchmark.py` 对每次运行强制校验：

- 进程退出码为 0；超时（`duration + 120s`）直接失败。
- 输出里 `Total` 汇总行**恰好 1 次**，job 行与 job 头**恰好等于 bdev 数**，
  延迟摘要中每个 job 的 `99.00000%` 分位行**都必须在**。
- 所有数值必须有限且为正；`Fail/s`、`TO/s` 必须为 0；job 运行时长与请求时长偏差 ≤ 1 秒。
- `Total` IOPS 与各 job IOPS 之和偏差 ≤ 1%；`min ≤ average ≤ max`；`p99 ≥ min`。
- 样本数必须等于请求重复数（默认 5）；缺样本、NaN、负值、缺失字段 → `test` 阶段退出 **50**。

## 4. 指标

8 场景 × 5 指标 = **40 个指标**，每个指标是 5 次独立测量的中位数：

| 指标名（后缀） | 单位 | 方向 | 原始字段 |
|---|---|---|---|
| `<scenario> / IOPS` | IOPS | higher_is_better | `bdevperf` 汇总表 Total 行 IOPS 列 |
| `<scenario> / MiB/s` | MiB/s | higher_is_better | 汇总表 Total 行 MiB/s 列 |
| `<scenario> / avg_latency_us` | us | lower_is_better | 汇总表 Total 行 Average 延迟列 |
| `<scenario> / p99_latency_us` | us | lower_is_better | 延迟摘要 `99.00000%` 分位行，多 job 取最大值 |
| `<scenario> / peak_rss_mib` | MiB | lower_is_better | `/proc/<pid>/status` 的 `VmHWM`，50 ms 采样 |

注意事项：

- **p99 的精度由 bdevperf 延迟直方图分桶决定**：SPDK 在延迟摘要中为每个 cutoff 打印
  累计占比首次达到该 cutoff 的桶上界（单位 us），不是逐 I/O 精确排序分位。
  这是 SPDK 自带的统计口径，本文档不另行估算，解析器只做严格读取。
- **峰值 RSS** 是对 bdevperf 进程生命周期内 `VmHWM` 的轮询最大值，包含 DPDK 普通页内存
  与 Malloc bdev 数据区，不是"SPDK 库本身"的内存占用。
- 多 bdev 场景的 IOPS/带宽是 4 个 job 的总和（`Total` 行），p99 取 4 个 job 的最大值。

## 5. 架构与证据边界

| 项目 | 说明 |
|---|---|
| 测量对象 | SPDK 用户态块栈路径（`bdevperf` → bdev 层 → `Malloc` bdev） |
| 不是测量对象 | NVMe/SSD/HDD 性能、内核块栈性能、网络存储性能 |
| bdev 类型 | `Malloc`（纯内存），Runner 无 NVMe 盘，不使用物理设备 |
| 大页 | Runner 无 hugepage 预留，运行档优先 `--no-huge`（普通页后备），`-H` 关闭非大页数据缓冲限制 |
| 架构差异 | 本机验证为 x86_64；Actions 正式运行在 aarch64 Runner。两架构的绝对数值不可横向比较 |
| 并发度 | 单 bdev 场景 1 核、多 bdev 场景 4 核，跨架构保持一致 |
| 内存容量 | 每场景 bdev 数据区 16 MiB（多 bdev 共 64 MiB），DPDK 普通页后备 512/1024 MiB |

因此本用例的结论只覆盖"构建 → 启动 → 测量 → 解析 → 报告 → 清理"链路的正确性，
以及同架构同机型的相对回归；**不能**作为 SPDK 存储性能的对外指标。

## 6. 运行方式

### 6.1 Framework 六阶段

```bash
PERF_REPS=5 python3 framework/run_case.py \
  --case software/Acceleration/spdk/case.yaml \
  --version 26.09 --architecture x86_64 \
  --run-id local-$(date +%Y%m%dT%H%M%S) \
  --stage prepare   # 依次 build / start / test / stop / finalize
```

环境变量契约：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`RESULTS_DIR`、`PERF_RUN_ID`、
`PERF_WORK_DIR`、`PERF_ACTUAL_VERSION_FILE`；可选 `PERF_REPS`、`PERF_SPDK_DURATION`、
`PERF_SPDK_BUILD_JOBS`、`PERF_SPDK_OFFLINE_DIR`、`PERF_PROXY`。

退出码：参数/架构错 **20**，构建失败 **30**，测量/解析失败 **50**，清理失败 **60**；
`optimized` 变体未实现，固定返回 **30** 且不写 `build_variant.json`。

### 6.2 独立入口

```bash
# 本地冒烟（1 次测量，仅验证链路）
PERF_REPS=1 bash software/Acceleration/spdk/spdk_test.sh \
  --version 26.09 --variant base --results-dir /root/spdk-smoke

# 正式口径（1 预热 + 5 次测量）
bash software/Acceleration/spdk/spdk_test.sh --version 26.09 --variant base
```

## 7. 故障排查

| 现象 | 原因与处理 |
|---|---|
| `build` 退出 30，日志列出所有尝试过的 URL | 网络/镜像不可达或摘要不匹配。把三个归档放进 `PERF_SPDK_OFFLINE_DIR`（默认 `/home/runner/software/spdk/`）后重试；文件名见 §1 |
| `build` 退出 30，`required container command is missing` | 容器内 dnf 未装全依赖（仓库不可达或 `--skip-broken` 跳过了包）。看 `${PERF_WORK_DIR}/logs/distro-packages.log`，按 §2.1 手动补装 |
| `build` 退出 30，`ModuleNotFoundError: jinja2`/`tabulate`/`yaml`/`elftools` | 容器内发行版包缺失且 pip 镜像不可用；按 §2.1.1 在容器内安装 `python3-jinja2 python3-pyyaml python3-tabulate python3-pyelftools`，或修正镜像源 |
| `build` 退出 30，`requested SPDK ... but the built artifact reports ...` | 请求版本与本用例固定的 v26.09 不一致，或构建产物被污染 |
| `start` 退出 20，`no DPDK runtime profile worked` | DPDK EAL 无法在容器内初始化，看 `$RESULTS_DIR/smoke-test.log`。常见原因：CPU 不足 4 核、内存不足、容器缺 `IPC_LOCK`/共享内存。可设 `SPDK_CONTAINER_EXTRA_ARGS=(--cap-add=IPC_LOCK)` 或 `--shm-size=2g` 后重试，并把生效档位记录到 `runtime.json` |
| `start` 退出 20，`needs at least 4 CPUs` | 多 bdev 场景要求容器内至少 4 个 CPU |
| `test` 退出 50，`expected N samples`/`reported ...` | 样本缺失或 bdevperf 参数漂移；检查 `runs/<scenario>/rep<i>.log`，不要用其它数字代替 |
| `test` 退出 50，`bdevperf exited with ...` | 例如 Malloc bdev 内存分配失败：减小 bdev 大小或提高 `-s`；日志中的 JSON-RPC 错误会指明原因 |
| `test` 退出 50，`timing record ... invalid`/`has no peak RSS` | 容器内 GNU `time` 记录缺失或损坏；确认容器内 `/usr/bin/time` 存在且 `runs/` 可写 |
| `stop` 退出 60 | PID 文件指向的进程已不是本次的 bdevperf（被外部复用/替换），或容器标签不属于本 run，需要人工确认后清理 |
| 本地数值波动大 | 本机与其他构建任务共享 CPU；正式证据以专用 Runner 的 Actions 运行为准 |

## 8. 许可证

- SPDK：BSD-3-Clause（`LICENSE`）
- DPDK：BSD-3-Clause 及部分例外（`dpdk/license/`）
- ISA-L：BSD-3-Clause（`isa-l/LICENSE`）

本用例只下载上述上游源码并本地编译，不分发二进制；新增的脚本与文档按仓库许可证发布。
