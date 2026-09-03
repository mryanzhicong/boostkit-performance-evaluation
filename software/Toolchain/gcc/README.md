# GCC 性能测试说明

本用例从 GNU 官方发布包构建 GCC，再使用该私有安装的 C/C++ 编译器运行
SPEC CPU2017 v1.0.5 的官方整数吞吐量套件 `intrate`，用于比较 `x86_64` 与
`aarch64` 的开箱性能。

`case.yaml` 将 `build`、`start`、`test`、`stop` 四阶段映射至
`gcc_test.sh`。直接执行入口脚本也会完成构建、测试、环境信息收集和清理。

## 测试文件准备

GCC 源码优先从 Runner 的离线目录读取：

```text
/home/runner/software/gcc/gcc-<版本>.tar.xz
```

不存在时下载 GNU 官方发布包：

```text
https://ftp.gnu.org/gnu/gcc/gcc-<版本>/gcc-<版本>.tar.xz
```

脚本会对已声明版本执行 SHA-256 校验。

SPEC CPU2017 是受许可软件，不从网络下载。请在两台 Runner 上预置同一 ISO，且
保证 `runner` 用户可读：

```text
/home/runner/software/gcc/cpu2017-1.0.5.iso
```

测试脚本需要通过无密码 `sudo` 执行 `mount`、`umount`，以及测试前的内核设置。

## 构建与安装

脚本自动安装缺失的构建依赖，包括宿主 C/C++ 编译器、Make、GMP、MPFR、MPC、
Bison、Flex、Perl、`util-linux` 和 `libnsl`（APT 系统为 `libnsl1`）。两个架构均
安装并校验 `libnsl.so.1`；SPEC ISO 自带的 `specperl` 需要该运行库。

GCC 在本次任务的隔离工作目录中按以下命令构建并安装：

```bash
../gcc-<版本>/configure \
  --prefix="${PERF_WORK_DIR}/gcc-install" \
  --enable-languages=c,c++ \
  --disable-bootstrap \
  --disable-multilib \
  --disable-nls
make -j"$(nproc)"
make install
```

构建完成后，脚本校验：

```bash
"${PERF_WORK_DIR}/gcc-install/bin/gcc" --version
"${PERF_WORK_DIR}/gcc-install/bin/g++" --version
```

实际版本必须与 `case.yaml` 请求版本一致。

## SPEC CPU2017 安装与配置

测试阶段将 ISO 只读挂载到本次任务的数据目录，再使用 ISO 自带的官方安装器：

```bash
mount -o loop,ro \
  /home/runner/software/spec/cpu2017-1.0.5.iso \
  /home/runner/gcc-data/<版本>/<架构>/<运行ID>/cpu2017-media

./install.sh -f -d \
  /home/runner/gcc-data/<版本>/<架构>/<运行ID>/cpu2017
```

安装目录会自动使用 ISO 中与架构对应的官方 GCC 模板：

```text
config/Example-gcc-linux-x86.cfg
config/Example-gcc-linux-aarch64.cfg
```

脚本复制模板为 `config/gcc.cfg`，仅将模板的 `gcc_dir` 改为：

```text
${PERF_WORK_DIR}/gcc-install
```

因此 SPEC 构建每个工作负载时使用的是本次任务构建的 `gcc` 与 `g++`。

## 测试命令

测试前，脚本记录现有 ASLR 值，再依次执行以下系统设置：

```bash
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

停止阶段会恢复测试前的 ASLR 值、卸载 ISO，并清理本次任务的
`/home/runner/gcc-data/<版本>/<架构>/<运行ID>/` 目录。

在 SPEC 安装目录中执行的性能测试命令为：

```bash
source ./shrc
runcpu --config=gcc.cfg --rebuild --copies=16 -n 1 \
  -S fastmath=0 \
  -S jemalloc=2mb \
  -S hugepages=0 \
  intrate
```

`--copies` 在两个架构上均固定为 16，使两侧以相同的并行副本数执行 SPEC rate
基准。实际值写入 `benchmark_gcc.json`，并随结果一起报告。

`fastmath`、`jemalloc` 与 `hugepages` 作为固定的 SPEC 配置变量传入，并写入
结果配置的 `notes010` 字段以便追溯；ISO 自带的 GCC 模板没有将它们映射为额外
的 GCC 选项、jemalloc 预加载或大页配置，脚本不会臆造这些行为。

## 指标与输出

指标为 SPEC 官方定义的 `SPECrate2017_int_base`：整数 Rate 套件的总体吞吐量比值，
覆盖 10 个整数工作负载。数值越大表示吞吐量越高。

| 指标 | 来源字段 | 单位 | 优化方向 |
|---|---|---|---|
| `SPECrate2017_int_base` | SPEC `intrate` 文本结果 | ratio | 越大越好 |

测试成功要求官方文本结果中存在且仅存在一个有效的
`SPECrate2017_int_base` 值；缺失、冲突或非正数都会使测试失败。

输出文件：

- `raw-output.log`：完整 `runcpu` 控制台输出。
- `spec-install.log`：ISO 安装器的原始输出。
- `spec-results/`：SPEC 原始文本、CSV、配置等结果文件。
- `benchmark_gcc.json`：规范化后的官方总分、原始命令和固定参数。

## 独立执行

```bash
bash software/Toolchain/gcc/gcc_test.sh --version 16.2.0
```

可使用 `--results-dir <目录>` 指定持久结果位置，或用 `--keep-workdir` 保留
GCC 构建工作目录供排查。
