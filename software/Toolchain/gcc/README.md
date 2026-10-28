# GCC 12.5.0、14.4.0 性能测试

本用例在 `x86_64`、`aarch64` Runner 上分别从官方源码构建 GCC，再用各自构建的 GCC
运行 SPEC CPU2017 1.0.5 `intrate`。两侧均运行 384 副本、1 次迭代，报告比较
`SPECrate2017_int_base` 套件总分。独立运行默认使用 GCC 14.4.0。

入口为 `gcc_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也使用这些阶段。基础版构建位于 `scripts/builders/base.sh`，
公共路径在 `scripts/common.sh`，结果解析在 `scripts/results/`。工作流可选择 `base`
或 `optimized`，默认 `base`。`optimized` 构建尚未实现，选择后会明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| GCC | [GNU GCC 官方发布目录](https://gcc.gnu.org/pub/gcc/releases/)中的 12.5.0 或 14.4.0 源码包 | 优先读取 `/home/runner/software/gcc/gcc-<版本>.tar.xz`，缺失时下载；构建并安装到本次任务私有目录 |
| SPEC CPU2017 | 1.0.5 ISO，由使用者提供 | `/home/runner/software/gcc/cpu2017-1.0.5.iso`；本次任务中只读挂载并安装 |
| 架构配置 | 仓库中的完整 SPEC 配置文件 | `x86_64` 使用 `scripts/spec-gcc-x86.cfg`；`aarch64` 使用 `scripts/spec-gcc-aarch64.cfg` |

Runner 必须能读取 SPEC ISO，并能无密码执行 `sudo`，以挂载 ISO、修改测试所需内核参数
和恢复现场。脚本通过 `dnf` 安装缺失的 GCC 构建依赖、`numactl`，并检查 SPEC 工具所需
的 `libnsl.so.1`。SPEC ISO 不由脚本下载。

Framework 将本次任务的工作目录传给脚本，以下称为 `${PERF_WORK_DIR}`。独立运行时默认位于
`/home/runner/boostkit-perf/gcc/local-<运行ID>/`。源码、构建、安装及 SPEC 数据均放在
该目录下；结果写入单独的 `${RESULTS_DIR}`。

## GCC 获取、构建与安装

源码包先从 `/home/runner/software/gcc/` 读取；没有时从对应官方版本目录下载。
无论来源，解压前都必须匹配下表的 SHA-256。

| GCC 版本 | 源码包 | SHA-256 |
|---|---|---|
| 12.5.0 | `gcc-12.5.0.tar.xz` | `71cd373d0f04615e66c5b5b14d49c1a4c1a08efa7b30625cd240b11bab4062b3` |
| 14.4.0 | `gcc-14.4.0.tar.xz` | `752b6f567beac83159c77a7680b1316bdd784738bff9a9d070112c09da90f6d9` |

下载和校验的命令形态如下，`<版本>` 与上表所选版本一致：

```bash
curl -fSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/gcc-<版本>.tar.xz" \
  "https://gcc.gnu.org/pub/gcc/releases/gcc-<版本>/gcc-<版本>.tar.xz" # 仅离线包不存在时
sha256sum "${PERF_WORK_DIR}/gcc-<版本>.tar.xz" # 必须匹配上表
```

脚本把源码解压至 `gcc-src/`，在独立的 `gcc-build/` 中运行：

```bash
cd "${PERF_WORK_DIR}/gcc-build"
"${PERF_WORK_DIR}/gcc-src/configure" \
  --prefix="${PERF_WORK_DIR}/gcc-install" \
  --enable-languages=c,c++,fortran \
  --disable-bootstrap \
  --disable-multilib \
  --disable-nls
make -j"$(nproc)"
make install
```

构建结束后会检查 `gcc-install/bin/` 中的 `gcc`、`g++`、`gfortran` 及实际版本。
SPEC 配置只使用这个私有安装目录中的编译器。

## SPEC CPU2017 安装与配置

测试阶段将 ISO 只读挂载到本次任务的 `data/gcc-<运行ID>/cpu2017-media/`，再调用
ISO 自带的安装器，安装目标为同一任务的 `data/gcc-<运行ID>/cpu2017/`：

```bash
sudo -n mount -o loop,ro /home/runner/software/gcc/cpu2017-1.0.5.iso \
  "${PERF_WORK_DIR}/data/gcc-${PERF_RUN_ID}/cpu2017-media"
cd "${PERF_WORK_DIR}/data/gcc-${PERF_RUN_ID}/cpu2017-media"
env -u SPEC ./install.sh -f -d "${PERF_WORK_DIR}/data/gcc-${PERF_RUN_ID}/cpu2017"
```

脚本把对应架构的完整配置复制到 SPEC 的 `config/`，只改两处：

1. `gcc_dir` 指向本次任务的 `gcc-install/`。
2. `label` 为 `<所选 GCC 版本>-base`，例如 `12.5.0-base`。

其余编译参数、移植性选项、输出目录、NUMA 绑核和条件分支均保留配置文件原值。
实际运行的配置副本也保存到结果目录。两份架构配置分别维护，不把一侧配置强行套用到另一侧。

## 数据与运行顺序

SPEC ISO 自带测试程序和输入数据，无需另行准备数据集。每个架构按以下顺序运行：

1. 构建并验证所选 GCC，挂载及安装 SPEC。
2. 保存当前 ASLR 值，将 `/proc/sys/kernel/randomize_va_space` 设为 `0`，向
   `/proc/sys/vm/drop_caches` 写入 `3`。
3. 进入 SPEC 安装目录，加载 `shrc` 并运行 `intrate`。
4. 复制 SPEC 原始结果，解析套件总分；停止阶段恢复 ASLR、卸载 ISO，并清理本次任务的
   SPEC 数据目录。

实际测试命令按架构选择配置文件：

```bash
cd "${PERF_WORK_DIR}/data/gcc-${PERF_RUN_ID}/cpu2017"
source ./shrc

# x86_64
runcpu --config=spec-gcc-x86.cfg intrate -n 1 -C 384

# aarch64
runcpu --config=spec-gcc-aarch64.cfg intrate -n 1 -C 384
```

两条 `runcpu` 命令是二选一，不是在同一台机器上连续执行。`-n 1` 为 1 次迭代；
`-C 384` 将配置中的副本数覆盖为 384。配置中的 `submit` 仍生效：当前配置按序将副本
绑定到 CPU 0–383，并使用 `numactl --localalloc`。Runner 必须允许使用这些 CPU 编号。

## 指标与产物

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `SPECrate2017_int_base` | SPEC 官方 `intrate` 文本结果中的套件总分 | 比值 | 越大越好 |

`-n 1` 的结果通常标为 `Est. SPECrate2017_int_base`，属于估算值，不是可提交的
SPEC 正式成绩。报告只收集这一项套件总分；11 个子测试的原始数据保留在 SPEC 结果中。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `raw-output.log` | `runcpu` 控制台原始输出 |
| `spec-install.log` | SPEC 安装器输出 |
| `spec-results/` | SPEC 生成的原始结果文件 |
| `benchmark_gcc.json` | 套件总分、来源及实际测试命令 |
| `spec-gcc-x86.cfg` 或 `spec-gcc-aarch64.cfg` | 本次测试实际使用的配置 |
| `spec-build-logs/` | SPEC 测试程序构建失败时保留的 `make*.out` |

SPEC 的原始输出位于
`${PERF_WORK_DIR}/data/gcc-<运行ID>/cpu2017/result/gnu/<版本>-base/result/`，
脚本将其复制到 `${RESULTS_DIR}/spec-results/`。停止阶段只清理本次运行标记的 SPEC
数据目录，不删除预置 ISO 或结果目录。

独立运行示例：

```bash
bash software/Toolchain/gcc/gcc_test.sh \
  --version 14.4.0 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/gcc/results/14.4.0
```

测试 GCC 12.5.0 时，将 `--version` 改为 `12.5.0`，并指定独立结果目录。
需要排查构建时可加 `--keep-workdir` 保留 GCC 源码、构建和安装目录；SPEC 数据仍由停止阶段清理。
