# jemalloc 5.4.0 性能测试

本用例在 x86_64、aarch64 上分别构建上游原版 jemalloc 5.4.0，并使用
`malloc_benchmark` 测试三种模式。构建和测试均在本次任务的 openEuler 24.03 LTS SP4
私有容器内执行；容器使用宿主网络，不限制 CPU、内存或 NUMA，不修改宿主机的 jemalloc。

Framework 根据 `case.yaml` 依次调用构建、启动校验、测试和停止函数。
`scripts/builders/base.sh` 是基础版的完整构建脚本；`scripts/builders/optimized.sh`
是调优版占位脚本，选择 `optimized` 后在构建阶段明确失败，不回退基础版。
`scripts/stages/` 负责校验、运行和清理，`scripts/results/` 解析测试工具的原始输出。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| jemalloc | 上游原版 5.4.0，不打补丁；优先读取 Runner 本地预置包，缺失时才从[官方发布页](https://github.com/jemalloc/jemalloc/releases/tag/5.4.0)下载 | 预置包：`/home/runner/software/jemalloc/jemalloc-5.4.0.tar.bz2`；私有安装目录：`${PERF_WORK_DIR}/jemalloc-install/` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}` |
| `malloc_benchmark` | Runner 预置的可执行文件；当前未获得源码和版本号 | 预置于 `/home/runner/software/jemalloc/malloc_benchmark`，运行前复制到 `${PERF_WORK_DIR}/benchmark-tool/` |

两台 Runner 都必须把本机架构的 `malloc_benchmark` 放在上表的同一路径，
并赋予 Runner 用户读取和执行权限。脚本在启动阶段检查 ELF 架构，测试结果记录
工具二进制的 SHA-256。已收到的 `/root/malloc_benchmark` 是 x86_64 文件，不能放到
aarch64 Runner 直接运行。正式跨架构对比前，仍需确认两台机器预置的工具由同一源码
版本构建；SHA-256 因架构不同，不要求相等。

## jemalloc 获取、构建与容器启动

脚本先检查 Docker daemon。基础镜像归档
`openEuler-docker.<架构>.tar.xz` 和同名 `.sha256sum` 优先取上表的公共目录；缺失时
从官方地址下载。校验 SHA-256 后执行 `docker load`，核对镜像架构及容器内
openEuler 版本，不访问 Docker Hub。

每次构建使用容器 `boostkit-jemalloc-<架构>-<运行 ID>`。容器以 Runner 的 UID/GID
运行，把 `${PERF_WORK_DIR}` 原路径挂载进去；命令形态如下：

```bash
docker run --detach --name "${JEMALLOC_CONTAINER}" \
  --label "boostkit.jemalloc.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  "${JEMALLOC_IMAGE}" sleep infinity
```

正式工作流设置 `PERF_PROXY` 时，还会只读挂载
`/home/runner/software/anchors/` 到容器的 `/etc/pki/ca-trust/source/anchors/`，
在容器内执行 `update-ca-trust extract`，再仅在该容器内把 openEuler 仓库地址改为
`repo.huaweicloud.com/openeuler`。未设置代理时不挂载证书，也不更新信任库。
容器内使用 `dnf` 安装 GCC、Make、Tar、Bzip2 等构建依赖。

jemalloc 源码包先检查 `/home/runner/software/jemalloc/jemalloc-5.4.0.tar.bz2`；
该文件存在且非空时直接复制到本次私有目录，不发起源码下载。只有本地包缺失时，
才下载上表的官方发布包。脚本记录实际包的 SHA-256，解压后在容器内执行：

```bash
cd "${PERF_WORK_DIR}/jemalloc-5.4.0"
./configure --prefix="${PERF_WORK_DIR}/jemalloc-install"
make -j"$(nproc)"
make install
```

不加架构专用编译选项，不修改源码。构建后核对私有目录中的
`jemalloc-config --version` 为 5.4.0，且 `lib/libjemalloc.so.2` 存在。
构建成功后保留同一个容器和本次私有工作目录。start 阶段检查该容器仍在运行、
任务标签匹配、库文件可在容器内访问；test 阶段直接复用它，
不会重新执行 `docker load` 或 `docker run`。构建失败时脚本清理已创建的容器。

## 数据与运行顺序

本用例不需要外部数据集。测试阶段复用 build 创建的容器，把预置工具复制到
本次工作目录；先验证 `LD_PRELOAD` 确实加载本次构建的 `libjemalloc.so.2`，
再在容器内依次执行：

```bash
LD_PRELOAD="${PERF_WORK_DIR}/jemalloc-install/lib/libjemalloc.so.2" \
  "${PERF_WORK_DIR}/benchmark-tool/malloc_benchmark" -mode 0 -threads 384 -affinity 0
LD_PRELOAD="${PERF_WORK_DIR}/jemalloc-install/lib/libjemalloc.so.2" \
  "${PERF_WORK_DIR}/benchmark-tool/malloc_benchmark" -mode 1 -threads 384 -affinity 0
LD_PRELOAD="${PERF_WORK_DIR}/jemalloc-install/lib/libjemalloc.so.2" \
  "${PERF_WORK_DIR}/benchmark-tool/malloc_benchmark" -mode 2 -threads 384 -affinity 0
```

三种模式分别是工具输出标示的 All-To-All、Producer & Consumer、Isolated
Threads。每种模式只跑一轮，使用工具默认的对象数量、大小范围、epochs、ages
等参数；`-affinity 0` 不由工具绑核。任一模式退出失败或缺少最终汇总行时，
整个测试失败，不生成部分成功的报告。测试成功后容器保持运行，Framework 的
stop 阶段只移除带本次任务标签的容器；测试失败时脚本提前清理该容器。
原始日志保留在结果目录。

## 指标与产物

解析每个模式最后一行 `Mode: ..., Time: ..., Average RSS: ..., Max RSS: ...,
Average speed: ..., Max speed: ...`，每个模式要求恰好一行。

| 指标 | 原始输出字段 | 单位 | 方向 |
|---|---|---|---|
| 平均速度 | `Average speed` | score | 越大越好 |
| 最大速度 | `Max speed` | score | 越大越好 |
| 耗时 | `Time` | s | 越小越好 |
| 平均驻留内存 | `Average RSS` | GB | 越小越好 |
| 最大驻留内存 | `Max RSS` | GB | 越小越好 |

三种模式各 5 项，共 15 项，报告按 `mode_0`、`mode_1`、`mode_2` 分组。
当前二进制未标明 `speed` 的物理单位，所以报告仅写 `score`，不能解释成
MB/s 或 ops/s。内存和耗时作为辅助对比项；原始输出中的 `Sequence` 数据保留在日志，
不重复列入报告。

| 产物 | 内容 |
|---|---|
| `benchmark_mode_0.log`、`benchmark_mode_1.log`、`benchmark_mode_2.log` | 三种模式的完整原始输出 |
| `benchmark_jemalloc.json` | 15 项指标、384 线程、关闭绑核及工具 SHA-256 |
| `build_variant.json` | 实际构建类型；基础版为 `base` |
| `normalized_result.json`、`report.md` | Framework 校验后生成的标准结果与单架构报告 |

如需在 Runner 上单独核查构建和测试，先从仓库根目录执行：

```bash
bash software/HPC/jemalloc/scripts/builders/base.sh \
  --architecture aarch64 --run-id local-check-1

bash software/HPC/jemalloc/scripts/stages/test.sh \
  --architecture aarch64 --run-id local-check-1 \
  --results-dir /home/runner/boostkit-perf/jemalloc/5.4.0/aarch64/local-check-1/results

PERF_RUN_ID=local-check-1 EXPECTED_ARCH=aarch64 \
  bash software/HPC/jemalloc/scripts/stages/stop.sh
```

这些是构建、测试阶段的独立核查入口，不会自动生成 Framework 报告；正式报告由
Workflow 的 Framework 阶段生成。当前已用 x86_64 工具的极小参数验证真实输出可解析，
并用构造的两架构结果贯通 Framework 标准化、跨架构比较及汇总报告生成；
尚未在两台 Runner 上完成容器实测。
