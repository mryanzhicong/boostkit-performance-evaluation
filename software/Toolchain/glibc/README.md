# glibc 2.44 性能测试

本用例在 x86_64、aarch64 上分别从 GNU 官方源码构建 glibc 2.44，运行其自带的
`memcpy`、`memcmp` benchtests，比较相同场景的执行时间。源码、构建产物和安装文件
均位于本次任务的私有目录，不替换 Runner 的系统 glibc。测试不绑核。

软件入口为 `glibc_test.sh`。Framework 根据 `case.yaml` 分别调用构建、启动、测试
和停止阶段；直接运行入口脚本也执行同一流程。正式和开发工作流可选择 `base`、
`optimized`；目前只有 `base` 可运行，`optimized` 构建入口尚未实现，选择后会明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| glibc | [GNU glibc 2.44 官方源码包](https://ftp.gnu.org/gnu/glibc/glibc-2.44.tar.xz) | `${PERF_WORK_DIR}/glibc-src`、`glibc-build`、`glibc-install` |
| benchtests | 随同一份 glibc 2.44 源码提供 | `${PERF_WORK_DIR}/glibc-build/benchtests` |

`scripts/builders/base.sh` 负责源码获取与构建，`scripts/stages/` 负责 benchtests 的
准备和运行，`scripts/results/parse_benchmark.py` 从官方输出中提取指标。
缺少 `gcc`、`make`、`bison` 等必需命令时，构建脚本通过 `dnf` 安装对应系统包；
普通 Runner 用户调用 `sudo -n dnf install -y <缺失的包>`。启用 `PERF_PROXY` 时，
脚本将代理地址传给 `dnf` 的 `--setopt=proxy=...`。

## 源码获取、构建与安装

脚本先检查 `/home/runner/software/glibc/glibc-2.44.tar.xz`。本地包不存在时，从
GNU 官方地址下载到 `${PERF_WORK_DIR}`。两种来源都必须通过相同的 SHA-256 校验：

```text
37f600f2bef3c5e8300147059568b2a2e40a7ad6ccc65ce942556d49429cc667
```

校验后，脚本把源码解压为 `${PERF_WORK_DIR}/glibc-src`，应用
[`scripts/glibc-2.44-benchtests.patch`](scripts/glibc-2.44-benchtests.patch)，再在独立
构建目录中执行以下命令。补丁只让官方 `USE_CLOCK_GETTIME` 计时方式在结果中标记为
`clock_gettime_ns`，并保留公开 `memcpy`、`memcmp` 函数的结果入口；不修改被测函数实现。

```bash
mkdir -p "${PERF_WORK_DIR}/glibc-build"
cd "${PERF_WORK_DIR}/glibc-build"
unset LD_LIBRARY_PATH
"${PERF_WORK_DIR}/glibc-src/configure" \
  --prefix="${PERF_WORK_DIR}/glibc-install" \
  --disable-werror \
  --without-selinux \
  CC=gcc CFLAGS=-O3
make -j"$(nproc)"
make install cross-compiling=yes
```

安装前缀只在本次任务目录内。`cross-compiling=yes` 使安装步骤不更新 Runner 的
系统动态链接器缓存。脚本随后检查私有动态加载器，并用本次构建的
`glibc-build/elf/ldconfig --version` 核对实际版本为 2.44。

## 测试准备与运行顺序

两架构均以 `USE_CLOCK_GETTIME=1` 构建官方 benchtests，使用
`clock_gettime(CLOCK_MONOTONIC)` 的纳秒值计时。启动阶段只构建下列三个目标，
并要求 `bench-timing-type` 返回 `clock_gettime_ns`：

```bash
make -C "${PERF_WORK_DIR}/glibc-src/benchtests" \
  objdir="${PERF_WORK_DIR}/glibc-build" USE_CLOCK_GETTIME=1 \
  "${PERF_WORK_DIR}/glibc-build/benchtests/bench-timing-type" \
  "${PERF_WORK_DIR}/glibc-build/benchtests/bench-memcpy" \
  "${PERF_WORK_DIR}/glibc-build/benchtests/bench-memcmp"

"${PERF_WORK_DIR}/glibc-build/benchtests/bench-timing-type"
```

测试阶段顺序执行两个程序，各运行一次；完整 JSON 输出分别保存到
`${RESULTS_DIR}/benchtests/`：

```bash
"${PERF_WORK_DIR}/glibc-build/benchtests/bench-memcpy" \
  > "${RESULTS_DIR}/benchtests/bench-memcpy.out"
"${PERF_WORK_DIR}/glibc-build/benchtests/bench-memcmp" \
  > "${RESULTS_DIR}/benchtests/bench-memcmp.out"
```

执行后解析器检查输出非空、计时类型、函数入口与指标数值；缺少任一要求的场景即
测试失败，不会将其他场景代替。停止阶段没有后台服务需要关闭。

## 指标与产物

只取两个长度、两个公开函数，共四项指标。`align1=0`、`align2=0` 表示两地址
均按 0 偏移对齐；`memcpy` 取 `dst > src=0`，`memcmp` 取相等输入 `result=0`。

| 函数 | 长度 | 官方结果中的场景 | 报告指标数 | 单位与方向 |
|---|---:|---|---:|---|
| `memcpy` | 2048、4096 字节 | `align1=0, align2=0, dst > src=0` | 2 | ns/调用，越小越好 |
| `memcmp` | 2048、4096 字节 | `align1=0, align2=0, result=0` | 2 | ns/调用，越小越好 |

解析器从官方 JSON 的 `functions.<函数>.results[].timings[]` 中选取公开函数对应的
时间值。`benchmark_glibc.json` 保存四项结构化指标及每项的原始文件、字段路径；
`benchmark_bench.txt` 记录实际执行命令，`benchtests/` 保留两份完整官方输出，
`build_variant.json` 记录构建类型。Framework 读取 `benchmark_glibc.json`，按
`memcpy`、`memcmp` 分组生成单架构及跨架构报告。

脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/glibc/glibc_test.sh \
  --version 2.44 \
  --variant base \
  --results-dir /home/runner/glibc-results/2.44
```

独立运行时，工作目录默认位于 `/home/runner/boostkit-perf/glibc/local-<运行 ID>`；
正常结束后清理，结果目录保留。排查构建或测试失败时可加 `--keep-workdir` 保留
工作目录。Framework 运行时，工作目录由 Framework 分配在
`/home/runner/boostkit-perf/glibc/<版本>/<架构>/<运行 ID>/`。
