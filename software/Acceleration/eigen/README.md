# Eigen 5.0.1 性能测试

本用例在 x86_64 与 aarch64 上构建**上游原版 Eigen 5.0.1**（header-only），并运行
归档内实际存在的上游基准 `bench/btl`（BTL，通过 Eigen 顶层 CMake 的
`-DEIGEN_BUILD_BTL=ON` 构建）。测试矩阵覆盖对 Eigen 最重要的计算路径：
GEMM、GEMV、三角求解、Cholesky 分解与 AXPY，并在**标量基线组**（上游 BTL 默认
`-g0 -O3 -DNDEBUG`）与**向量化组**（额外加架构原生指令集）之间做对比，因此能直接
看出本机指令集（x86_64 的 AVX2/AVX-512、aarch64 的 NEON/SVE）带来的加速比。

软件入口为 `eigen_test.sh`；Framework 通过 `case.yaml` 调用
`scripts/builders/` 与 `scripts/stages/` 下的同名函数，直接执行入口脚本也使用这些
阶段函数。正式/开发工作流提供 `base` 与 `optimized` 下拉项，默认 `base`；调优版
入口 `scripts/builders/optimized.sh` **尚未实现**，选择后在构建阶段明确失败
（退出码 30），不会退回基础版。

## 版本与来源

| 项目 | 值 |
|---|---|
| 软件 | Eigen 5.0.1（header-only C++ 线性代数库） |
| 上游仓库 | `https://gitlab.com/libeigen/eigen` |
| 源码归档 | `eigen-5.0.1.tar.gz`（2 967 272 字节） |
| 归档 URL | `https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz` |
| 归档 SHA-256 | `e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec` |
| 版本自证 | 解包后 `Eigen/Version`：`EIGEN_WORLD_VERSION 3`、`EIGEN_MAJOR_VERSION 5`、`EIGEN_MINOR_VERSION 0`、`EIGEN_PATCH_VERSION 1`、`EIGEN_VERSION_STRING "5.0.1"`；`CHANGELOG.md` 顶部为 `## [5.0.1] - 2025-11-11` |
| 基准入口 | 归档内 `bench/btl`（BTL = Basic Template Library benchmark），由顶层 `CMakeLists.txt` 的 `add_subdirectory(bench/btl EXCLUDE_FROM_ALL)` 与 `-DEIGEN_BUILD_BTL=ON` 引入 |

获取顺序（任一候选都必须是**同一个** SHA-256，先通过校验者生效）：

1. `PERF_EIGEN_ARCHIVE_URL` 指定的本地/内网归档；
2. `PERF_EIGEN_MIRROR` 指定的镜像前缀；
3. Runner 预置离线目录 `PERF_EIGEN_OFFLINE_DIR`（默认
   `/home/runner/software/eigen/`），按 `eigen-5.0.1.tar.gz` 文件名查找；
4. 上面的官方 gitlab.com URL。

aarch64 Runner 不保证能访问 github.com / 公网，正式流水线以离线目录或镜像为主；
全部候选都失败时构建阶段以退出码 30 结束，并打印**每个尝试过的 URL**与失败原因，
不做静默降级。镜像探测结果：`gitee.com`、`gh-proxy.com` 的对应路径均返回 404，
`gitcode.com` 返回的是 5 792 字节 HTML 而非归档，因此只有官方 gitlab.com 与
离线目录能提供字节一致的归档；脚本对候选逐个做 SHA-256 校验来兜住这一点。

## 容器化执行

本用例的解包、编译、自检、固定负载与计时包装全部在每次任务专属的 **openEuler 24.03
LTS SP4 私有容器**内完成，与 `software/Database/mysql`、`software/Bigdata/ray`、
`software/Others/unixbench` 使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与
Framework，不再安装编译器、CMake 或 dnf 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`（必须为 24.03）。
- 容器：名字 `boostkit-eigen-<arch>-<运行ID>`，标签 `boostkit.eigen.run-id=<运行ID>`，使用
  宿主网络，以 Runner 用户身份运行；只读挂载用例目录，读写挂载 `${PERF_WORK_DIR}` 与
  `${RESULTS_DIR}`，容器内路径与宿主完全相同。Eigen 本身不需要额外 capability，因此
  不设置 `EIGEN_CONTAINER_EXTRA_ARGS`。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`make`、`cmake`、`tar`、`gzip`、`coreutils`、
  `findutils`、`sed`、`gawk`、`grep`、`util-linux`、`file`、`glibc-devel`、`binutils`、
  `python3`、`which`；源码解包、`Eigen/Version` 版本自证、原生指令集探测、两组 BTL
  构建（`btl_eigen3_{matmat,vecmat,adv,linear}`）、自检程序
  （`scripts/eigen_probe.cpp`）与固定维度驱动（`scripts/btl_single_point.cpp`）的编译和
  冒烟运行、以及 `scripts/run_timed.py` 计时包装都在容器内执行。`${PERF_WORK_DIR}/home`
  作为容器内 `HOME`，`compiler.txt` / `cmake.txt` 记录的是容器内实际使用的工具链。
- 宿主机：只负责下载并校验归档（优先 `/home/runner/software/eigen/`）、调用 Framework、
  严格解析 `results.json`（`scripts/results/parse_benchmark.py` 不进入容器）、清理本任务的
  容器。宿主机缺少 `curl`/`sha256sum` 只告警，因为离线归档仍是可用来源。
- 测量：每条样本由容器内进程直接派生（`eigen_container_exec_at "${SCENARIO_WORKDIR}"`），
  `docker exec` 的管理开销不落在计时窗口内；BTL 扫描与固定维度驱动都以容器内 `c++`
  编译产物运行，不混入宿主工具链。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符时拒绝删除并返回 60），随后清理私有
  scratch 目录；取消任务遗留的同软件容器会在下一次 build 时按名字前缀 + 运行 ID 清理。
- 本地验证：x86_64 WSL 上用 `PERF_REPS=1` 跑通六阶段（prepare/build/start/test/stop/
  finalize 全部 0），构建阶段约 40 秒装依赖、45 秒编译两组 BTL，容器删除后
  `docker ps -a` 无残留；只验证链路，不作为性能证据。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 安装与构建

构建阶段在本次任务私有目录
`/home/runner/boostkit-perf/eigen/<版本>/<架构>/<run-id>/` 下完成，不向系统目录安装
任何文件：

```
<work>/eigen-source/       # 校验通过的归档解包目录（不修改上游源码）
<work>/build/o3/           # 标量基线组 BTL 构建树
<work>/build/native/       # 向量化组 BTL 构建树
<work>/probe/              # 版本/指令集自检与固定维度驱动的编译产物
<work>/runs/               # 每次测量的原始输出与计时
<work>/logs/               # 阶段日志
```

编译工具缺失时按发行版分支安装：Runner（`dnf`，必要时带代理）与本地（`apt-get`）
各有一条命令，安装后**再次自检命令是否存在**，仍缺失则以退出码 30 失败并给出需要的
包名。需要的是 C++ 编译器、CMake、make/ninja 与 curl。

两组都用同一份源码树、同一组 BTL targets，只改编译选项：

```bash
# 标量基线组：上游 BTL 自带 -g0 -O3 -DNDEBUG，不追加任何指令集开关
cmake -S "$WORK/eigen-source" -B "$WORK/build/o3" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DEIGEN_BUILD_BTL=ON -DEIGEN_BUILD_TESTING=OFF -DEIGEN_BUILD_DOC=OFF \
  -DEIGEN_BUILD_DEMOS=OFF -DEIGEN_BUILD_BLAS=OFF -DEIGEN_BUILD_LAPACK=OFF \
  -DEIGEN_BUILD_SPBENCH=OFF
cmake --build "$WORK/build/o3" --parallel 6 \
  --target btl_eigen3_matmat btl_eigen3_vecmat btl_eigen3_adv btl_eigen3_linear

# 向量化组：x86_64 用 -march=native；aarch64 先试 -mcpu=native，失败回退 -march=armv8-a+simd
cmake -S "$WORK/eigen-source" -B "$WORK/build/native" \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-march=native" \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DEIGEN_BUILD_BTL=ON -DEIGEN_BUILD_TESTING=OFF -DEIGEN_BUILD_DOC=OFF \
  -DEIGEN_BUILD_DEMOS=OFF -DEIGEN_BUILD_BLAS=OFF -DEIGEN_BUILD_LAPACK=OFF \
  -DEIGEN_BUILD_SPBENCH=OFF
cmake --build "$WORK/build/native" --parallel 6 \
  --target btl_eigen3_matmat btl_eigen3_vecmat btl_eigen3_adv btl_eigen3_linear
```

说明：

- `-DEIGEN_BUILD_BTL=ON` 是唯一必需的上游开关；`bench/btl` 还带
  `cmake_minimum_required(VERSION 2.6.2)`，CMake 4.x 会拒绝该版本声明，因此统一传
  `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`（CMake 3.x 上是无害的“变量未使用”提示）。
- 只构建 `btl_eigen3_*` 四个 target：`matmat`（GEMM）、`vecmat`（GEMV）、
  `adv`（三角求解/Cholesky 等高级 action）、`linear`（AXPY 等 BLAS-1 action）。
- 不构建 `libs/BLAS` 相关 target，也不链接任何 BLAS/LAPACK/Boost；BTL 的 BLAS 对比
  需要额外固定 BLAS 版本，本用例刻意不做，避免把第三方库混进被测口径。
- 并行度由 `PERF_EIGEN_JOBS` 控制（默认 6）：本地 WSL 与其他适配任务并发编译，
  Runner 上可按核数调大。

构建阶段的自检（任一失败即退出码 30）：

| 自检 | 内容 |
|---|---|
| 版本自证 | `Eigen/Version` 的 `EIGEN_VERSION_STRING` 必须等于请求版本，写入 `PERF_ACTUAL_VERSION_FILE`；不一致时失败 |
| 编译期自检 | 用各组选项编译并运行 `scripts/eigen_probe.cpp`：打印版本宏、指令集/向量化宏，并做 64×64 `MatrixXf` 乘法与朴素三重循环比对（容差 1e-2），输出 `selftest=ok` |
| 组差异自检 | 比较两组的预定义宏：x86_64 上向量化组必须比基线组多出指令集宏，否则失败；aarch64 只告警（`-mcpu=native` 的宏增量依赖 CPU） |
| 运行期自检 | 真正运行一次上游 `btl_eigen3_adv`（`-a cholesky`），要求输出 ≥100 行 `MFlops` 结果行，确认 BTL 在当前机器上真的能跑完一次上游扫描 |

## 完整测试口径

测试矩阵 = **2 个构建组 × 5 个 action = 10 个场景**，每个场景两种上游工作负载：

| 项 | 内容 |
|---|---|
| 上游扫描（wall / RSS） | 未修改的上游可执行文件 `btl_eigen3_*`，用上游 `BTL_CONFIG` 只保留一个 action：`-a <action> -t 1 --overwrite`。它执行上游 `NB_POINT=100` 个对数分布维度的完整扫描，`MIN_TIME=0.2` CPU 秒/点 |
| 固定维度（GFLOPS） | `scripts/btl_single_point.cpp`：复用上游 `bench/btl` 的 action 头文件与上游 `Portable_Perf_Analyzer`，把被测维度固定为 128 / 512 / 1024，每次进程只测一个 (action, 维度) |
| 动作 | `gemm`→`matrix_matrix`、`gemv`→`matrix_vector`、`trisolve_matrix`、`cholesky`、`axpy` |
| 采样 | 每项 1 次预热 + `PERF_REPS` 次独立测量，默认 5 次（`PERF_REPS<5` 会告警：仅用于本地联通性验证） |
| 计时 | `scripts/run_timed.py` 包裹每个被测进程，记录 wall clock、退出码、超时与 `ru_maxrss` 峰值 RSS |
| 证据 | 上游扫描：`runs/<组>_<action>/{warmup,rep<i>}.{log,json}`；固定维度：`runs/<组>_<action>/size<维度>/{warmup,rep<i>}.{log,json}` |
| 离线 | 测量阶段不访问网络；归档在构建阶段就已落到私有目录 |

`-t 1` 是用上游 `BTL_CONFIG` 选项固定的“每个维度只做 1 次 BTL 内部尝试”，与
“1 次预热 + 5 次独立进程”叠加后，每个上报值是 5 个独立进程的中位数；不固定
`-t` 则上游默认做 3 次内部尝试并取最小值，会引入上游自身的实现细节差异。

**为什么 GFLOPS 不直接取上游扫描的曲线**：上游 `bench/btl/generic_bench/bench.hh`
在 action 循环外只构造一次 `Perf_Analyzer`，而
`Portable_Perf_Analyzer::eval_mflops()` 会保留 `m_time_action` 与 `_nb_calc`
成员。扫描从**最大维度**开始，一旦该点耗时已 ≥ `MIN_TIME`，后续维度的计时循环被
整体跳过，打印出的 MFlops 全部等于 `nb_op_base(size) / 首次实测时间`——即整条曲线
只有最大维度是真测的。沿用该行为会把“最大维度的耗时”除出来的数字当成 128/512/1024
的吞吐，属于编造数据。因此本用例保留上游可执行文件做 wall/RSS 场景（真实运行、真实
进程耗时），另加固定维度驱动来给每个维度**独立计时**；驱动不复制、不修改上游算法，
只固定维度并输出与上游同格式的 `size = N  MFlops MFlops` 行。

解析器是严格的：缺预热、缺任一重复、退出码非 0、超时、缺少上游结果标记、扫描行数
不等于 100、维度非单调、日志里没有对应测量行、值非有限或非正，任一条都让测试阶段以
退出码 50 失败；**不做任何补零、插值或近似填充**。上游 BTL 在极小维度（size 1 等）
会打印 `0 MFlops`（计时区间太短的浮点比值），这些点不参与任何指标，解析器只记录提示。

## 指标

每个场景产生 5 个指标，10 个场景共 **50 个指标**：

| 指标名 | 单位 | 方向 | 含义 |
|---|---|---|---|
| `<组>_<action>_wall` | s | 越小越好 | 完整上游 BTL 扫描进程的墙钟时间（含上游自身的初始化/校验开销） |
| `<组>_<action>_rss` | MiB | 越小越好 | 该进程树的峰值 RSS（`ru_maxrss`） |
| `<组>_<action>_gflops_128` | GFLOP/s | 越大越好 | 上游 BTL action 在维度 128 的独立测量吞吐（MFlops/1000） |
| `<组>_<action>_gflops_512` | GFLOP/s | 越大越好 | 同上，维度 512 |
| `<组>_<action>_gflops_1024` | GFLOP/s | 越大越好 | 同上，维度 1024 |

上报值 = 独立重复的中位数；`results.json` 同时保留每个指标的 `samples`（全部样本）
与 `min`/`max`/`mean`/`stdev`，`runs/` 下保留每次运行的原始 stdout 与计时 JSON，
便于复核。指标名与 `parameters` 在两架构上完全一致（差异只写入
`runtime_context`），因此可比对性检查（`parameter_signature`）在两架构之间保持相同。

## 架构与证据边界

- **被测对象是上游 Eigen**：源码、构建系统与 BTL action 实现均来自校验过的归档，
  未打补丁；唯一新增的自研代码是 `scripts/btl_single_point.cpp`（固定维度驱动）、
  `scripts/eigen_probe.cpp`（自检）和 `scripts/run_timed.py`（计时外壳），它们在
  构建阶段编译、在测试阶段被显式调用，源码与命令都保留在产物里。
- **两组差异只来自编译选项**：同一源码树、同一 target、同一并行度，基线组使用上游
  BTL 自带选项，向量化组只额外加架构原生指令集开关；实际开关与预定义宏记录在
  `results.json` 的 `runtime_context` 与 `probe/<组>.txt`。
- **没有 BLAS/LAPACK/Boost**：不构建、不链接；因此本用例的 GFLOPS 是 Eigen 自身
  kernel 的吞吐，不是“Eigen + MKL/OpenBLAS”的组合值，也不与任何 BLAS 做对比。
- **aarch64 的向量化组**：`-mcpu=native` 优先，失败回退 `-march=armv8-a+simd`；
  实际生效的开关写入 `<work>/native-flag.txt` 并进入 `runtime_context`，两架构的
  指标名保持一致。
- **本地验证与正式证据**：适配阶段在 x86_64 WSL（20 核 / 23 GB）上用
  `PERF_REPS=1` 跑通六阶段，只验证链路与指标可产出；正式证据是 Runner（aarch64）
  上 `PERF_REPS` 默认 5 次的流水线运行。本地机器与其他适配任务并发编译，绝对数值
  不可与 Runner 横向比较。
- **单进程、单线程**：BTL 与固定维度驱动都是单线程运行，不绑核、不改调度策略、
  不设置 CPU governor；`runtime_before.json` / `runtime_after.json` 记录测量前后的
  governor 与内存，便于确认环境没有漂移。

## 运行方式

Framework（正式流水线走这条）：

```bash
python3 framework/run_case.py \
  --case software/Acceleration/eigen/case.yaml \
  --version 5.0.1 --architecture aarch64 \
  --run-id <run-id> --stage build     # 依次 prepare/build/start/test/stop/finalize
```

独立运行（排查用，自带完整六阶段）：

```bash
bash software/Acceleration/eigen/eigen_test.sh \
  --version 5.0.1 \
  --variant base \
  --results-dir /home/runner/eigen-results
```

- `--version` 只接受 `5.0.1`，其他版本以退出码 20 拒绝；
- `--variant` 只接受 `base`（`optimized` 明确失败，退出码 30）；
- `--keep-workdir` 保留私有工作目录用于排查，默认清理；
- 环境变量覆盖：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、
  `RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`、`PERF_EIGEN_JOBS`、
  `PERF_EIGEN_OFFLINE_DIR`、`PERF_EIGEN_ARCHIVE_URL`、`PERF_EIGEN_MIRROR`、
  `PERF_EIGEN_RUN_TIMEOUT`。

退出码约定：参数/架构错误 `20`，构建或版本自证失败 `30`，测试或解析失败 `50`，
清理/收尾失败 `60`（内部还有 `40` 用于启动阶段自检失败）。

## 故障排查

| 现象 | 处理 |
|---|---|
| 构建阶段报“所有候选 URL 都失败” | 把归档放到 `PERF_EIGEN_OFFLINE_DIR`（默认 `/home/runner/software/eigen/eigen-5.0.1.tar.gz`），或设 `PERF_EIGEN_ARCHIVE_URL`/`PERF_EIGEN_MIRROR`；SHA-256 必须与上表一致 |
| `cmake` 报 `Compatibility with CMake < 3.5 has been removed` | 已默认传 `-DCMAKE_POLICY_VERSION_MINIMUM=3.5`；若自行调用 CMake 需同样传入 |
| 找不到 `btl_eigen3_*` | 确认配置里带 `-DEIGEN_BUILD_BTL=ON`，且构建 target 列表中包含四个 `btl_eigen3_*` target（`EXCLUDE_FROM_ALL` 下的目标不会随默认 target 构建） |
| 向量化组与基线组指标几乎一样 | 看 `runtime_context.group_isa_macros`：若两组宏相同，说明该机器/编译器未启用额外指令集（aarch64 上会告警而不是失败） |
| `-mcpu=native` 不被支持 | 脚本自动回退 `-march=armv8-a+simd`，实际开关见 `<work>/native-flag.txt` |
| 测试阶段退出码 50 且提示缺少日志/证据 | 检查 `runs/<场景>/` 是否缺少 `warmup` 或某个 `rep<i>`，以及 `raw-output.log` 里最后一次失败进程的尾部输出（脚本会打印最后 40 行） |
| 测量数值抖动大 | 确认没有其他编译/测试任务抢占 CPU；本用例不绑核，中位数对偶发噪声不敏感，但 `stdev` 会如实反映 |
| 构建阶段报 Docker daemon 不可用 | 私有容器是唯一的构建环境：需要 `docker` 命令与可访问的 daemon（退出码 30）；确认当前用户有权限操作 Docker |
| 容器内 `dnf install` 失败 | 检查容器网络与 `repo.huaweicloud.com`（脚本已把 `openEuler.repo` 的 `metalink` 注释掉并改指华为镜像）；`PERF_PROXY` 存在时会同时配置 dnf 代理，失败返回 30 |
| 残留 `boostkit-eigen-*` 容器 | `stop` 会按运行 ID 标签删除本任务容器；被取消的历史容器在下一次 build 时按名字前缀与运行 ID 清理。手工清理时只删除自己运行 ID 的容器，勿批量删除 |

## 许可证

- Eigen 本体为 **MPL-2.0**（`COPYING.MPL2`），另含少量 BSD 风格文件；
- 归档内 `bench/btl` 的源文件头声明为 **GPL-2.0-or-later**（BTL 来自 EDF R&D）；
  本用例只在构建阶段编译这些头文件/模板来生成 BTL 可执行文件与固定维度驱动，
  仓库自身不复制其源码，也不分发编译产物；
- 本用例新增的 shell/python/C++ 脚本为本项目原创代码，随本项目许可证发布；
  使用或再分发 BTL 相关产物时需遵守其 GPL-2.0 条款。
