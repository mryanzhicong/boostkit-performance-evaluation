# GCC 性能测试说明

本用例从 GNU 官方发布的 GCC 源码包构建 C 编译器，并对源码包自带的
`gcc/testsuite/gcc.c-torture/compile` 语料执行编译耗时测试，用于比较
`x86_64` 与 `aarch64` 的开箱编译性能。

Framework 通过 `case.yaml` 调用 `gcc_test.sh` 的 `build`、`start`、`test`、
`stop` 四阶段。直接执行入口脚本会按同一顺序构建、测试、收集环境信息
并清理任务私有目录。

## 构建与安装

测试版本由 `case.yaml` 的 `versions` 声明。脚本优先读取离线包：

```text
/home/runner/software/gcc/gcc-<版本>.tar.xz
```

未找到离线包时，下载 GNU 官方发布包：

```text
https://ftp.gnu.org/gnu/gcc/gcc-<版本>/gcc-<版本>.tar.xz
```

脚本对 tarball 执行已声明的 SHA-256 校验后，在任务私有目录进行
out-of-tree 构建：

```bash
../gcc-<版本>/configure \
  --prefix="${PERF_WORK_DIR}/gcc-install" \
  --enable-languages=c \
  --disable-bootstrap \
  --disable-multilib \
  --disable-nls
make all-gcc -j"$(nproc)"
```

构建后使用 `gcc/xgcc --version` 校验实际 GCC 版本。脚本会自动安装缺失的
构建依赖，包括宿主编译器、Make、GMP、MPFR、MPC、Bison 和 Flex。

## 官方测试

测试语料是每个 GCC 发行包内置的：

```text
gcc/testsuite/gcc.c-torture/compile/*.c
```

脚本以 `case.yaml` 声明的 `GCC_OPT_LEVEL=O2` 对每个官方 C 文件编译三次：

```bash
"${PERF_WORK_DIR}/gcc-build/gcc/xgcc" \
  -B"${PERF_WORK_DIR}/gcc-build/gcc/" \
  -O2 -c "<官方语料文件>.c" -o "<任务私有对象文件>.o"
```

每次耗时使用 `time.monotonic_ns` 记录；同一文件的三个样本取中位数。任何
语料文件编译失败、缺少样本或指标数量不完整都会使测试失败。对象文件写入
`/home/runner/gcc-data/<版本>/<架构>/<运行 ID>/`，停止阶段会仅清理本次运行
的任务专用目录。

## 指标

每个指标名称均为官方 `gcc.c-torture/compile` 语料中的原始 C 文件名，例如
`20020219-1.c`。指标值为该文件三次编译耗时的中位数：

| 指标 | 单位 | 优化方向 |
|---|---|---|
| `<官方文件名>.c` 编译耗时 | s | 越小越好 |

输出文件：

- `benchmark_compile.txt`：每次原始计时记录，格式为 `迭代序号 文件名 纳秒`。
- `compiler-output.log`：原始编译器标准输出和标准错误。
- `benchmark_gcc.json`：指标规范化结果，保留样本数和原始单位。

## 独立执行

```bash
bash software/Toolchain/gcc/gcc_test.sh --version 16.2.0
```

可使用 `--results-dir <目录>` 指定结果位置，或使用 `--keep-workdir` 保留构建
目录供排查。
