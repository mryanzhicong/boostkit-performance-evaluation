# Python 性能测试说明

本目录从 CPython 官方仓库构建指定版本解释器，并运行官方 `pyperformance`
默认测试集，对比 `base`（原生 CPython）与 `optimized`（CPython + CinderX）
两个变体。

- `base`：仅构建 CPython，不加载任何 JIT 插件。
- `optimized`：用完全相同的 CPython 配置（`--enable-optimizations --with-lto`）
  构建私有解释器，再从 [CinderX](https://gitcode.com/openeuler/cinderx) 源码构建
  并安装 JIT 扩展；测量时启用 CinderX 插件与 AutoJIT。CinderX 只改变 Python
  运行时，不替换 CPython 源码树。

两个变体共用 `scripts/stages/` 下的启动、测试、停止脚本，差异集中在构建阶段和
测量环境变量。软件入口为 `python_test.sh`，Framework 通过 `case.yaml` 调用各阶段。

## 变体与取点

| 项目 | base | optimized |
|---|---|---|
| CPython | `github.com/python/cpython` 标签 `v3.14.3` | 同左（同一标签、同一 configure 选项） |
| 优化组件 | 无 | `gitcode.com/openeuler/cinderx` 的 `master` 分支尖端 |
| 取点形态 | 标签 | 分支尖端；构建时解析为显式 commit 并记录 |
| 记录文件 | `actual-version.txt` | `actual-version.txt`、`cinderx-source.txt`、`build_variant.json` |
| 测量环境 | 不设置 CinderX 变量 | `CINDERX_PLUGIN_ENABLE=1`、`PYTHONJITAUTO=auto:2` |

`optimized` 的取点是可移动的：`case.yaml` 的 `python_optimized.revision` 写
`master`，实际被测 revision 以构建时解析出的 commit 为准。构建脚本把
`ref/branch/head/head_tree/parent/parent_tree/range` 写入
`${RESULTS_DIR}/cinderx-source.txt`，并写入 `build_variant.json` 的
`commit/branch/parent_commit/commit_range`。`start`、`test` 和结果解析阶段
重新读取该记录；记录缺失、ref 不符或分支不符都会以非零状态退出，不会退回原生
CPython，也不会静默跳过优化。

`case.yaml` 的 `test_tools.python_optimized` 使用 `version: "3.14.3"`（被测
CPython 运行时版本）和 `revision: "master"`（CinderX 取点）；构建产物的
`build_variant.json` 才包含精确 commit。

## 构建与安装

`base` 的构建步骤：

1. 从 CPython 官方 Git 仓库浅克隆 `v<版本>` 标签；
2. 在本次任务的 `PERF_WORK_DIR/cpython-source` 中执行配置和编译；
3. 安装到本次任务私有的 `PERF_WORK_DIR/cpython-install`；
4. 校验私有解释器的实际版本、`pip` 与 `ssl`、`zlib`、`ctypes` 模块。

`optimized` 在完成上述步骤后继续：

5. 从 `gitcode.com/openeuler/cinderx` 克隆指定分支/标签/commit，并记录 HEAD
   与父提交；
6. 用 GCC 13+（优先 `/opt/openEuler/gcc-toolset-14/root/usr/bin`）和 CMake/Ninja
   编译 `_cinderx` 扩展，`CMAKE_BUILD_TYPE=Release`；
7. 以 `--no-build-isolation --no-deps --force-reinstall` 安装到私有解释器，
   构建期间强制 `CINDERX_PLUGIN_ENABLE=0`；
8. 校验 CinderX 可导入并写出 `build_variant.json`。

基础构建脚本自动检查并通过 `dnf` 安装缺失依赖；非 root Runner 使用 `sudo -n dnf`。
`base` 需要 `git`、`gcc`、`make`、`python3`、`nproc` 以及 CPython 标准库模块和官方
基准集所需的 `openssl-devel`、`zlib-devel`、`libffi-devel`、`sqlite-devel`、
`bzip2-devel`、`xz-devel`、`readline-devel`、`gdbm-devel`、`uuid-devel`。
`optimized` 还需要 `gcc-c++`、`cmake`、`ninja-build`，以及 GCC 13 以上工具链；
若系统 GCC 低于 13，脚本安装 `gcc-toolset-14-*` 并把 `CC`/`CXX`/`GCOV` 指向它。
CinderX 在 Python 3.14 上默认关闭 PGO/LTO，本用例显式保持关闭并记录；
`CINDERX_LOCAL_DEPS` 可指向本地依赖缓存，`CINDERX_BUILD_JOBS` 控制并发，
`CINDERX_CC`/`CINDERX_CXX` 可覆盖编译器。

CPython 构建命令（两个变体一致）：

```bash
git clone --branch v3.14.3 --depth 1 https://github.com/python/cpython.git cpython-source
cd cpython-source
./configure \
  --prefix="${PERF_WORK_DIR}/cpython-install" \
  --enable-optimizations \
  --with-lto
make -j"$(nproc)"
make install
```

`--enable-optimizations` 启用 PGO，`--with-lto` 启用链接时优化，构建后的实际版本
写入 `actual-version.txt`。

CinderX 构建命令（核心参数）：

```bash
cd "${PERF_WORK_DIR}/cinderx-source"
CC=/opt/openEuler/gcc-toolset-14/root/usr/bin/gcc \
CXX=/opt/openEuler/gcc-toolset-14/root/usr/bin/g++ \
CMAKE_BUILD_TYPE=Release \
CMAKE_BUILD_PARALLEL_LEVEL="$(nproc)" \
CINDERX_PLUGIN_ENABLE=0 \
CINDERX_ENABLE_PGO=0 \
CINDERX_ENABLE_LTO=0 \
  "${PERF_WORK_DIR}/cpython-install/bin/python3" -m pip install \
    --no-build-isolation --no-deps --force-reinstall .
```

## 服务启动

Python 性能测试不启动后台服务。两个变体都检查私有解释器可执行、`--version`、
`ssl`/`zlib`/`ctypes` 导入和 `pip` 可用。`optimized` 额外以
`CINDERX_PLUGIN_ENABLE=1` 启动解释器，先 `import cinderx.jit as jit`，再按 CinderX
实际发布的接口确认 JIT 可用：`cinderx.is_initialized()` 为真、`jit.is_enabled()`
为真，然后用 `jit.force_compile()` 编译一个平凡函数并确认 `jit.is_jit_compiled()`
为真。`cinderx.jit` 没有 `is_available()` 接口（调用会 `AttributeError`），而
`is_enabled()` 只说明 JIT 处于运行状态，所以用一次真实编译证明本地后端确实能产出
并发布机器码。任一检查失败都让启动阶段返回 40，不进入测量。`test` 阶段在同一
解释器配置下用 pyperformance venv 解释器重复同一组检查，失败返回 50。`stop` 阶段
没有待停止的进程。

## 性能测试

两个变体使用同一固定版本的测试套件：

| 组件 | 固定来源 |
|---|---|
| CPython | `https://github.com/python/cpython.git`，标签 `v3.14.3` |
| pyperformance | `1.13.0`，通过华为云 PyPI 安装 |
| CinderX | `https://gitcode.com/openeuler/cinderx`，`master` 尖端（构建时固定 commit） |

`base` 命令与原有用例一致：

```bash
"${PYTHON_BIN}" -m pip install --no-cache-dir \
  --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
  --trusted-host mirrors.huaweicloud.com \
  pyperformance==1.13.0

"${PYTHON_BIN}" -m pyperformance run \
  --warmup 3 \
  --inherit-environ PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY \
  -o "${RESULTS_DIR}/benchmark.json"
```

`optimized` 必须让 pyperformance 的 benchmark worker 看到私有解释器里安装的
CinderX。pyperformance 1.13 会复用 `venv/<解释器标识>` 作为公共虚拟环境，并在
`venv create` 后忽略 `pyvenv.cfg` 的站点包设置；因此脚本显式创建该 venv，把
`include-system-site-packages` 改为 `true`，并用 venv 解释器预检 CinderX，
然后仍从私有解释器发起 `run`（pyperformance 会复用同一个 venv）：

```bash
"${PYTHON_BIN}" -m pyperformance venv create \
  --inherit-environ PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY

sed -i 's/^include-system-site-packages.*/include-system-site-packages = true/' \
  venv/*/pyvenv.cfg

CINDERX_PLUGIN_ENABLE=1 PYTHONJITAUTO=auto:2 "${PYTHON_BIN}" -m pyperformance run \
  --warmup 3 \
  --inherit-environ PIP_INDEX_URL,PIP_TRUSTED_HOST,http_proxy,https_proxy,no_proxy,all_proxy,HTTP_PROXY,HTTPS_PROXY,NO_PROXY,ALL_PROXY,CINDERX_PLUGIN_ENABLE,PYTHONJITAUTO,LD_LIBRARY_PATH \
  -o "${RESULTS_DIR}/benchmark.json"
```

脚本将华为云 PyPI 地址与可信主机写入 `PIP_INDEX_URL`、`PIP_TRUSTED_HOST`，并通过
`--inherit-environ` 传入测试虚拟环境。文档示例的 `--affinity=300` 是单机 CPU 编号，
这里不固定 CPU 编号；两种变体都由测试工具选择可用 CPU，使用相同的采样方式和
默认测试集，不使用 `-b` 限定三项基准。默认测试集耗时可能明显长于三项代表性基准，
任务超时设置为 360 分钟。

`variant=optimized` 的 `--results-dir` 默认位于
`results/<版本>/optimized/<run-id>`，`base` 仍为 `results/<版本>/<run-id>`。
两种变体共用测试负载和指标解析，差异只来自构建产物和测量环境变量。

可以脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/python/python_test.sh \
  --version 3.14.3 --variant base \
  --results-dir /home/runner/boostkit-perf/python/results/3.14.3

bash software/Toolchain/python/python_test.sh \
  --version 3.14.3 --variant optimized \
  --results-dir /home/runner/boostkit-perf/python/results/3.14.3/optimized
```

## 指标

默认测试集中每个 pyperformance benchmark 保留一个指标，不做平均、加权、评分或
跨场景聚合。报告按原始 benchmark 名称对齐两个架构和两个变体；具体项目和数量以
`pyperformance==1.13.0` 的实际输出为准。

| 原始字段 | 报告中的指标名 | 单位 | 优化方向 | 含义 |
|---|---|---:|---|---|
| 所有有效测量值 | `pyperformance <官方 benchmark 名称>: median` | s | 越小越好 | 该官方 benchmark 全部有效测量值的中位执行时间 |

解析时跳过仅含 warmup 的校准记录；其他每条测量值必须是正数且单位可换算为秒。官方
输出缺失、benchmark 重名、无有效测量值或无法换算单位时，测试立即失败。
`optimized` 的结果文件额外在 `parameters.cinderx` 下记录
`repository/ref/commit/commit_tree/branch/parent_commit/parent_tree/commit_range`，
在 `parameters.cinderx_build` 下记录构建类型、PGO/LTO 开关与运行时 JIT 变量；
`base` 的输出结构与原有用例一致。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `build_variant.json`：变体标识；优化版还包含取点 commit、父提交、commit range、
  CinderX 版本、构建类型与工具链；
- `benchmark.json`：pyperformance 生成的官方原始 JSON；
- `benchmark_python.json`：逐项 median 指标、执行命令、预热次数、构建参数、
  取点信息及 pyperformance 运行元数据。

`stop` 阶段不需要停止服务。直接执行入口脚本时，会在结果收集后删除本次自动创建的
工作目录；Framework 执行时，由 Runner 级环境清理移除该任务的隔离工作目录。

## 边界与已知限制

- 优化变体只改容器用户态和被测源码：`dnf` 安装编译依赖、在私有 prefix 安装
  CPython/CinderX、在 `$HOME` 内配置 pip 镜像；不写 `sysctl`、`/proc/sys`、`/sys`，
  不修改 CPU governor、THP、hugepage、tuned 或 BIOS/MSR 参数，不使用特权容器。
- Python 用例当前直接在 Runner 宿主机构建，没有容器启动参数；两个变体的运行时
  启动方式、测量负载和采样参数相同，差异只来自被测运行时。
- CinderX 官方预编译 wheel 以 AArch64 为主；本用例在两种架构上都从源码构建，
  x86_64 需要系统提供 GCC 13+ 或可安装 `gcc-toolset-14-*`。构建耗时明显高于
  原生 CPython，CinderX 本身默认的 PGO/LTO 在 3.14 上关闭。
- CinderX 的 JIT 在测量期间自动编译热点函数；`auto:2` 与官方性能测试文档一致。
  轻量帧、OSR 等运行时开关保持 CinderX 上游默认值，不额外调优。
- 构建阶段需要访问 GitHub、gitcode 和华为云 PyPI；测试阶段创建 venv 时需要
  同一 PyPI 源和代理。两者都不在测量窗口内发起额外网络请求。
- 静态检查只能证明脚本结构与边界；容器/宿主机上的真实构建、JIT 加载和正式
  双架构矩阵仍需在 Runner 上执行。
