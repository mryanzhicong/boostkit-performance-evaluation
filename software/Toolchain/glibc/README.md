# glibc 性能测试说明

本目录从 GNU 官方发布包构建指定 glibc，并在隔离前缀内运行 glibc 官方
`benchtests`。系统 glibc 不会被替换，也不会使用 `LD_PRELOAD`。Framework 通过
`case.yaml` 调用 `glibc_test.sh` 的 `build`、`start`、`test`、`stop` 四阶段；直接
执行入口脚本可完成同一流程。

当前清单支持 `2.43`、`2.44`，默认版本为 `2.44`。

## 构建与安装

源码包优先读取 Runner 离线目录：

```text
/home/runner/software/glibc/glibc-<版本>.tar.xz
```

不存在离线包时，从 GNU 官方地址下载。当前已声明 SHA-256 的版本为 2.43 和 2.44；
校验失败立即退出。核心获取和校验命令如下：

```bash
curl -fsSL --retry 3 --connect-timeout 30 \
  -o glibc-2.44.tar.xz https://ftp.gnu.org/gnu/glibc/glibc-2.44.tar.xz
sha256sum glibc-2.44.tar.xz
tar -xJf glibc-2.44.tar.xz
```

脚本检查 `gcc`、`make`、`tar`、`xz`、`sha256sum`、`curl`、`python3`、`awk`、
`nproc`、`bison`；缺失时通过 `dnf` 自动安装，非 root Runner 使用 `sudo -n dnf`。
构建和安装都位于任务隔离目录：

```bash
mkdir glibc-build
cd glibc-build
../glibc-src/configure --prefix="${PERF_WORK_DIR}/glibc-install" --disable-werror
make -j"$(nproc)"
make install cross-compiling=yes
```

`make install cross-compiling=yes` 禁止安装过程更新 Runner 的系统动态链接器缓存；
脚本随后用本次构建的 `elf/ldconfig --version` 校验版本，并检查隔离安装目录中的
动态加载器存在。

## 性能测试

`start` 阶段构建所需官方 benchtests，`test` 阶段运行：

```bash
make bench-build \
  BENCHSET="math-benchset stdio-benchset stdio-common-benchset stdlib-benchset string-benchset malloc-simple malloc-tcache malloc-thread" \
  USE_CLOCK_GETTIME=1

make bench \
  BENCHSET="math-benchset stdio-benchset stdio-common-benchset stdlib-benchset string-benchset malloc-simple malloc-tcache malloc-thread" \
  USE_CLOCK_GETTIME=1
```

`USE_CLOCK_GETTIME=1` 使两个架构统一使用 `clock_gettime` 计时，结果单位为 ns，
避免使用不可直接比较的架构相关 cycle 计数。完整 `make bench` 控制台输出保存为
`benchmark_bench.txt`，所有非空官方 `bench-*.out` JSON 输出保存到 `benchtests/`。

可脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/glibc/glibc_test.sh \
  --version 2.44 \
  --results-dir /home/runner/boostkit-perf/glibc/results/2.44
```

## 指标

报告从官方 JSON 输出中选择固定、可直接比较的场景；不把不同 API 平均为综合分数。
所有指标单位为 ns，越小越好。保留的类别和固定场景如下：

| 报告分组 | 原始输出与选取内容 |
|---|---|
| 数学函数 | `bench-math-inlines.out`：`isnan`、`isinf`、`isfinite`、`isnormal` 的 `normal` 输入 `mean` |
| 标准 I/O | `bench-sprintf.out` 的各官方 variant `mean`；`bench-fclose.out` 的 `fclose.duration` |
| 随机数锁 | `bench-random-lock.out` 的每个官方单线程/多线程 variant `results[0]` |
| 字符串与内存 | `memcpy`、`memmove`、`memset`、`strlen`、`strcmp`、`strstr` 各一个固定长度和对齐场景，读取指定 generic 实现的 timing |
| 内存分配 | 64-byte `malloc-simple`、64-byte 优化 `malloc-tcache`、8-thread `malloc-thread` 的官方时间字段 |

字符串与内存的固定输入为：`memcpy` 4096 bytes（align1=0、align2=0、dst>src=0）、
`memmove` 4096 bytes（0、32）、`memset` 4096 bytes（alignment=0、char=0）、
`strlen` 4096 bytes（alignment=0）、`strcmp` 4096 bytes（align1=0、align2=0）、
`strstr`（haystack=4096、needle=64、align_haystack=1、align_needle=11、fail=0）。
若必需输出、固定场景、指定 generic 实现或正数时间缺失，测试直接失败。

## 结果与清理

必需产物为 `benchmark_bench.txt`、`benchmark_glibc.json` 和 `benchtests/` 原始输出
目录。`benchmark_glibc.json` 仅规范化上述官方字段并保留来源文件与字段名。没有
后台服务需要停止；任务结束只移除本次构建的源码、构建目录和隔离安装前缀，不影响
Runner 的系统 glibc。
