# Eigen 5.0.1 性能测试

本用例在 x86_64 与 aarch64 上测量**上游原版 Eigen 5.0.1**（header-only C++ 线性代数库）
的稠密单线程 float 矩阵乘（GEMM）吞吐。被测负载是 pinned 归档内实际存在的上游基准
`bench/bench_gemm.cpp`：它把 `A(m×k) × B(k×n) → C(m×n)` 跑在一组固定矩阵点上，并打印
上游自己的 `eigen cpu ... GFLOPS` 计时行。用例在 44 个固定 `(m, k, n)` 矩阵点上各测一次，
**每个矩阵点只上报一个指标**：该行的 GFLOPS，单位 `GFLOP/s`，方向 `higher_is_better`。

软件入口为 `eigen_test.sh`；Framework 通过 `case.yaml` 调用 `scripts/builders/` 与
`scripts/stages/` 下的同名函数，直接执行入口脚本也复用同一组阶段函数。工作流提供
`base` 与 `optimized` 两个下拉项，默认 `base`；调优版入口
`scripts/builders/optimized.sh` **尚未实现**，选择后在构建阶段明确失败（退出码 30），
不会退回基础版。

## 目标与指标

| 项 | 内容 |
|---|---|
| 目标 | 跟踪 Eigen 稠密 float GEMM kernel 在本架构上的吞吐，并给出 44 个固定矩阵点的逐点读数 |
| 被测负载 | 上游 `bench/bench_gemm.cpp`（未修改），一次编译、逐点运行 |
| 指标 | `gemm_gflops_m<m>_k<k>_n<n>`，44 个；单位 `GFLOP/s`，方向 `higher_is_better` |
| 指标来源 | 上游驱动输出的 `eigen cpu   <sec>s   <GFLOPS> GFLOPS   (<total>s)` 行 |
| 上报值 | 1 次预热 + `EIGEN_REPS` 次独立测量的**中位数**；全样本保留在 `results.json` |
| 不做 | 不报墙钟/峰值 RSS 指标（只作原始证据保留）、不做多编译组对比、不链接 BLAS/LAPACK |

每个矩阵点的上游命令固定为

```bash
gemm_bench -s <m> <n> <k> -t 5 -p 10
```

上游 `-s` 的参数顺序是 **rows / columns / depth**，所以 `(m, k, n)` 的 C(m×n)=A(m×k)·B(k×n)
要传成 `-s m n k`（第三个数是深度 k）。`-t 5` 是上游的 5 次尝试、`-p 10` 是每次尝试内的
10 次重复，驱动打印的是这 5 次尝试中的**最优值**——这正是上游自己给吞吐定口径的方式，
本用例只读取、不改写。

## 版本与来源

| 项目 | 值 |
|---|---|
| 软件 | Eigen 5.0.1（header-only C++ 线性代数库） |
| 上游仓库 | `https://gitlab.com/libeigen/eigen` |
| 源码归档 | `eigen-5.0.1.tar.gz`（2 967 272 字节） |
| 归档 URL | `https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz` |
| 归档 SHA-256 | `e9c326dc8c05cd1e044c71f30f1b2e34a6161a3b6ecf445d56b53ff1669e3dec` |
| 版本自证 | 解包后 `Eigen/Version`：`EIGEN_WORLD_VERSION 3`、`EIGEN_MAJOR_VERSION 5`、`EIGEN_MINOR_VERSION 0`、`EIGEN_PATCH_VERSION 1`、`EIGEN_VERSION_STRING "5.0.1"`；`CHANGELOG.md` 顶部为 `## [5.0.1] - 2025-11-11` |
| 基准入口 | 归档内 `bench/bench_gemm.cpp`（Eigen dense single-thread float GEMM benchmark） |

获取顺序（任一候选都必须是**同一个** SHA-256，先通过校验者生效）：

1. 已缓存并校验过的 `${PERF_WORK_DIR}/downloads/eigen-5.0.1.tar.gz`；
2. Runner 预置离线目录 `PERF_EIGEN_OFFLINE_DIR`（默认 `/home/runner/software/eigen/`），
   按 `eigen-5.0.1.tar.gz` 文件名查找；
3. `PERF_EIGEN_ARCHIVE_URL` 指定的完整 URL；
4. `PERF_EIGEN_MIRROR` 指定的镜像前缀 + pinned 文件名；
5. 官方 `gitlab.com` 直链；
6. `PERF_EIGEN_PROXY_PREFIX`（默认 `https://gh-proxy.com/`）转发同一个官方 URL。

aarch64 Runner 不保证能访问 github.com / 公网，正式流水线以离线目录或镜像为主；全部候选
都失败时构建阶段以退出码 30 结束，并打印**每个尝试过的 URL**与失败原因，不做静默降级。
镜像探测结果：`gitee.com`、`gh-proxy.com` 的对应路径均返回 404，`gitcode.com` 返回的是
5 792 字节 HTML 而非归档，因此只有官方 gitlab.com 与离线目录能提供字节一致的归档；
脚本对每个候选都做 SHA-256 校验来兜住这一点。

## 为什么只测 `bench/bench_gemm.cpp`

- **上游自带、可复核**：`bench_gemm.cpp` 就在 pinned 归档里，未打补丁；编译命令与
  上游源码一一对应，不引入上游之外的算法。
- **有机器可读的吞吐行**：它按上游 `BenchTimer` 打印 `eigen cpu`（CPU 计时）与
  `eigen real`（墙钟）两行 GFLOPS，解析器只固定读取 `eigen cpu` 行即可，不需要自己
  换算或估算。
- **口径单一**：只测 dense float GEMM（`SCALAR float` 默认值），不链接 BLAS、不加
  `-DHAVE_BLAS`、不加 `-DDECOUPLED`，因此数值就是 Eigen 自身 kernel 的吞吐，而不是
  “Eigen + 第三方 BLAS”的组合值。
- **不改用 `bench/spbench`**：`bench/spbench` 是稀疏直接法的 solver 演示（输出
  XML、需要 CHOLMOD/UMFPACK/Pardiso 之类的可选外部 solver 与 Eigen 自带 BLAS/LAPACK
  target 才能做对比），既不是逐 kernel 的吞吐微基准，也会把第三方 solver 混进被测口径，
  与本用例“只测 Eigen 自身 GEMM kernel”的目标不符。
- **一次编译、单翻译单元**：本用例只编译 `bench/bench_gemm.cpp` 与自检程序，不生成多个
  编译组，也不引入 `cmake`，因此构建产物与测量的对应关系可以直接复核。

## 容器化执行

本用例的解包、编译、自检、固定负载与计时包装全部在每次任务专属的 **openEuler 24.03
LTS SP4 私有容器**内完成，与 `software/Database/mysql`、`software/Bigdata/ray`、
`software/Others/unixbench` 使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与
Framework，不再安装编译器、cmake 或 dnf 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构（`amd64`/`arm64`）与镜像内 `/etc/os-release`（必须为 24.03）。
- 容器：名字 `boostkit-eigen-<arch>-<run_id>`，标签 `boostkit.eigen.run-id=<run_id>`，使用
  host network，以 Runner 用户（`--user $(id -u):$(id -g)`）运行，`--ulimit
  nofile=1048576:1048576`；只读挂载用例目录（`RESULTS_DIR` 位于用例目录内时改为读写），
  读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，容器内路径与宿主完全相同；`/etc/passwd`
  与 `/etc/group` 以只读方式挂入，`HOME=${PERF_WORK_DIR}/home`、`TMPDIR=${PERF_WORK_DIR}/tmp`。
  配置了 `PERF_PROXY` 时额外只读挂载 CA 锚点并执行 `update-ca-trust`。Eigen 不需要额外
  capability，因此不设置 `EIGEN_CONTAINER_EXTRA_ARGS`。
- 容器内：`dnf --setopt=install_weak_deps=False`（关闭弱依赖，避免 rpm scriptlet 触碰只读
  `/etc/passwd`）安装 `gcc`、`gcc-c++`、`glibc-devel`、`binutils`、`make`、`tar`、`gzip`、
  `coreutils`、`findutils`、`sed`、`gawk`、`grep`、`util-linux`、`file`、`python3`、`which`；
  仓库被改写为 `repo.huaweicloud.com` 的 openEuler 镜像，`PERF_PROXY` 存在时同时配置 dnf 代理。
- 容器内还执行：归档解包（宿主先做 SHA-256 校验再放进 `${PERF_WORK_DIR}/downloads/`）、
  `bench/bench_gemm.cpp` 编译、自检程序 `scripts/eigen_probe.cpp` 的编译与运行、GEMM 驱动
  的冒烟运行、44 个矩阵点 × (1 次预热 + N 次测量) 的完整测量，以及 `scripts/run_timed.py`
  计时包装。编译器身份（`c++ --version` 首行）与容器镜像信息分别写入
  `${PERF_WORK_DIR}/compiler.txt` 与 `${PERF_WORK_DIR}/container-image.txt`。
- 宿主机：只负责下载并校验归档、调用 Framework、严格解析 `results.json`
  （`scripts/results/parse_benchmark.py` 不进入容器）、清理本任务的容器。宿主机缺少
  `curl`/`sha256sum` 只告警，因为离线归档仍是可用来源。
- 测量：每条样本由容器内进程直接派生（`eigen_container_exec_at "${scratch}" python3
  scripts/run_timed.py ...`），`docker exec` 的管理开销不落在计时窗口内；GFLOPS 完全来自
  容器内驱动的 `eigen cpu` 行，墙钟与峰值 RSS 只作为原始证据写进 `runs/`。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符时拒绝删除并返回 60），随后清理私有
  scratch 目录；取消任务遗留的同软件容器会在下一次 build 时按名字前缀 + 运行 ID 清理。
- 本地验证：x86_64 WSL 上用 `PERF_REPS=1` 跑通六阶段（prepare/build/start/test/stop/
  finalize 全部 0），容器删除后 `docker ps -a` 无残留；只验证链路，不作为性能证据。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 固定流程

1. **宿主下载并校验**：按上面的候选顺序取 `eigen-5.0.1.tar.gz`，逐个候选计算 SHA-256，
   只有等于 `e9c326…3dec` 的文件才落到 `${PERF_WORK_DIR}/downloads/`；离线归档校验失败
   直接判 30，不做降级。
2. **容器内解包与版本自证**：`tar -xzf` 解包到 `${PERF_WORK_DIR}/eigen-source/`（不修改
   上游源码），随后读 `Eigen/Version` 的 `EIGEN_VERSION_STRING`，必须等于 `5.0.1`。
3. **容器内编译一次**：`c++ -std=c++17 -O3 -DNDEBUG -I <source> <source>/bench/bench_gemm.cpp
   -o <work>/probe/gemm_bench`；同一次构建里还编译自检程序
   `scripts/eigen_probe.cpp`（打印版本宏、做一次 64×64 float 乘积与朴素三重循环比对，
   输出 `selftest=ok`）并跑一次 GEMM 冒烟（固定点 `-s 32 8 4 -t 1 -p 1`，要求打印
   `Matrix sizes = 32x4 * 4x8` 与 `eigen cpu ... GFLOPS`）。
4. **测量**：对 44 个矩阵点逐个跑 `gemm_bench -s <m> <n> <k> -t 5 -p 10`，每个点先跑
   1 次预热（丢弃），再跑 `EIGEN_REPS` 次独立测量；每次由 `scripts/run_timed.py` 记录原始
   stdout（`runs/<slug>/<label>.log`）与 wall/RSS/退出码（`runs/<slug>/<label>.json`）。
5. **严格解析**：宿主解析器逐点校验预热与全部测量样本、上游矩阵头、`eigen cpu` 行、正值
   与有限性，然后取中位数写 `results.json`；任一校验失败让 test 阶段返回 50，不补零、
   不插值。

## 测试矩阵（44 个矩阵点）

顺序与 `scripts/common.sh` 的 `EIGEN_GEMM_MATRIX` 完全一致；`A` 是 m×k，`B` 是 k×n，
`C` 是 m×n。

| # | m | k | n |
|---:|---:|---:|---:|
| 1 | 14 | 28 | 16 |
| 2 | 16 | 8 | 4 |
| 3 | 19 | 8 | 4 |
| 4 | 1 | 16 | 16 |
| 5 | 1 | 24 | 16 |
| 6 | 32 | 16 | 8 |
| 7 | 32 | 32 | 8 |
| 8 | 32 | 8 | 4 |
| 9 | 35 | 400 | 400 |
| 10 | 35 | 800 | 1 |
| 11 | 39 | 400 | 400 |
| 12 | 39 | 492 | 1 |
| 13 | 39 | 5 | 1 |
| 14 | 39 | 800 | 1 |
| 15 | 4130 | 104 | 32 |
| 16 | 4130 | 116 | 32 |
| 17 | 4130 | 16 | 1 |
| 18 | 4130 | 32 | 16 |
| 19 | 46 | 492 | 1 |
| 20 | 46 | 5 | 1 |
| 21 | 48 | 18 | 16 |
| 22 | 50 | 100 | 1 |
| 23 | 50 | 1298 | 250 |
| 24 | 50 | 250 | 100 |
| 25 | 50 | 250 | 250 |
| 26 | 59 | 128 | 64 |
| 27 | 59 | 1316 | 2 |
| 28 | 59 | 1316 | 256 |
| 29 | 59 | 1540 | 64 |
| 30 | 59 | 1570 | 128 |
| 31 | 59 | 1570 | 256 |
| 32 | 59 | 16 | 8 |
| 33 | 59 | 256 | 128 |
| 34 | 59 | 30 | 16 |
| 35 | 59 | 32 | 2 |
| 36 | 59 | 48 | 48 |
| 37 | 59 | 48 | 80 |
| 38 | 59 | 64 | 1 |
| 39 | 59 | 64 | 2 |
| 40 | 59 | 64 | 32 |
| 41 | 59 | 64 | 6 |
| 42 | 59 | 8 | 1 |
| 43 | 77 | 20 | 16 |
| 44 | 80 | 36 | 16 |

矩阵点是本用例固定的口径（同上游 GitHub/GitLab 基准常用的 dense GEMM 尺寸集合），
两架构完全相同；新增或删减点会改变指标集合，跨版本对比时必须按同名点配对。

## 指标与结果文件

`results.json` 的结构（由 `scripts/results/parse_benchmark.py` 生成，Framework 的
`benchmark_result`）：

```json
{
  "software": "eigen",
  "version": "5.0.1",
  "variant": "base",
  "architecture": "aarch64",
  "run_id": "...",
  "generated_at": "...",
  "toolchain": {"compiler": "<容器内 c++ --version 首行>"},
  "benchmark": {
    "workload": "upstream Eigen bench_gemm dense float matrix-matrix product",
    "matrix": "m k n",
    "matrix_points": 44,
    "tries": 5,
    "repeats_per_try": 10,
    "warmup_reps": 1,
    "measure_reps": 5
  },
  "results": {
    "gemm_gflops_m14_k28_n16": {
      "source_name": "gemm_gflops_m14_k28_n16",
      "source_benchmark": "Matrix sizes = 14x28 * 28x16",
      "source_field": "eigen cpu GFLOPS",
      "matrix": {"m": 14, "k": 28, "n": 16},
      "value": 27.4,
      "unit": "GFLOP/s",
      "direction": "higher_is_better",
      "samples": 5,
      "sample_values": [27.1, 27.4, 27.6, 27.3, 27.4],
      "sample_summary": {"median": 27.4, "mean": 27.36, "min": 27.1, "max": 27.6},
      "cpu_seconds_sample_values": [0.00101, 0.001, 0.00099, 0.001, 0.001],
      "real_gflops_sample_values": [26.5, 26.8, 27.1, 26.9, 27.0],
      "wall_seconds_sample_values": [0.0031, 0.003, 0.003, 0.0031, 0.003],
      "max_rss_mib_sample_values": [3.4, 3.4, 3.5, 3.4, 3.4],
      "group": "gemm"
    }
  },
  "runs_dir": "runs"
}
```

- `value` = `sample_values` 的中位数，也是唯一进入指标的数值；`group` 固定为 `gemm`，
  `case.yaml` 用 `group_path: group` 归档。
- `sample_values`、`cpu_seconds_sample_values`、`real_gflops_sample_values`、
  `wall_seconds_sample_values`、`max_rss_mib_sample_values` 都是**原始证据**：
  后三者不参与指标，只用于复核噪声与内存占用。
- 解析器不做补零、插值或近似填充；缺预热、缺任一重复、退出码非 0、超时、缺少
  `Matrix sizes = m x k * k x n` 行、缺少/重复 `eigen cpu` 行、值非有限或非正，都让
  test 阶段以退出码 50 失败。

### 结果目录内容

| 文件/目录 | 内容 |
|---|---|
| `results.json` | 44 个 `gemm_gflops_*` 指标（含全部样本与样本统计量）、toolchain、benchmark 参数 |
| `raw-output.log` | 本次运行的合并 stdout/stderr（Framework 的 `benchmark_raw`） |
| `runs/m<m>_k<k>_n<n>/warmup.log`、`rep1.log` … | 每个矩阵点每次运行的完整驱动输出（首行是 `# command:`） |
| `runs/m<m>_k<k>_n<n>/warmup.json`、`rep1.json` … | `run_timed.py` 计时记录：`wall_seconds`、`max_rss_mib`、`exit_code`、`timed_out`、`command` |
| `build_info.json` | 版本自证、归档来源/SHA-256、容器 C++ 编译器身份、上游入口与编译命令 |
| `actual-version.txt` | 从 `Eigen/Version` 读出的实际版本（必须为 `5.0.1`） |
| `compiler.txt`（位于 `${PERF_WORK_DIR}`） | 容器内 `c++ --version` 首行，即本次构建的编译器身份；同一字符串也写入 `results.json` 的 `toolchain.compiler` |
| `container-image.txt`（位于 `${PERF_WORK_DIR}`） | 容器镜像的 `PRETTY_NAME`（记录实际使用的 openEuler 版本） |
| `status.json` | 六阶段收尾状态（passed/failed、失败阶段、退出码、cleanup 状态） |
| `build_variant.json` | 本次构建设变体（`base`，仅 Framework 运行生成） |
| `normalized_result.json`、`report.md` | 仅独立入口生成：归一化指标与 Markdown 报告（44 行 `m/k/n/GFLOP/s` 表） |

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
- 环境变量覆盖：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、
  `PERF_WORK_DIR`、`PERF_REPS`（= `EIGEN_REPS`，默认 5；Blue 正式口径可用 6）、
  `PERF_EIGEN_OFFLINE_DIR`、`PERF_EIGEN_ARCHIVE_URL`、`PERF_EIGEN_MIRROR`、
  `PERF_EIGEN_PROXY_PREFIX`、`PERF_EIGEN_RUN_TIMEOUT`（单次测量超时，默认 1800 秒）、
  `PERF_PROXY`。

退出码约定：参数/架构错误 `20`，构建或版本自证失败 `30`，启动自检失败 `40`，测试或解析
失败 `50`，清理/收尾失败 `60`（独立入口清理失败时返回 `70`）。

## 已知限制

1. **单线程口径**：上游驱动不带 `-fopenmp` 编译，按 Eigen 默认单线程跑 dense float GEMM；
   不绑核、不改调度策略、不设置 CPU governor。多线程/多核吞吐不在本用例口径内。
2. **Blue 只跑 aarch64**：正式证据来自 Blue 工作流的 aarch64 Runner（Kunpeng 950、
   384 vCPU、openEuler 24.03 LTS-SP3）；x86_64（本地 WSL）只做链路与自测，两架构数值
   不可横向比较。
3. **只覆盖 dense float GEMM**：不含 double、复数、GEMV、三角求解、Cholesky、稀疏路径；
   这些路径由其它用例或后续扩展覆盖。
4. **吞吐口径沿用上游**：`eigen cpu` 行是上游 `-t 5 -p 10` 的**最优尝试**值（CPU 计时），
   不是逐次平均；同一矩阵点在同机不同次运行之间会有正常波动，故上报 N 次独立测量的中位数
   并保留全部样本。
5. **矩阵点是固定集合**：44 个点是本用例的口径，跨版本/跨架构对比必须按同名点配对；
   新增点会改变指标集合。
6. **共享宿主时数值会抖**：适配阶段机器同时跑其它任务时，`sample_summary` 的 `stdev`
   会变大；正式证据以专用 Runner 的运行为准。

## 故障排查

| 现象 | 处理 |
|---|---|
| 构建阶段报"所有候选 URL 都失败" | 把归档放到 `PERF_EIGEN_OFFLINE_DIR`（默认 `/home/runner/software/eigen/eigen-5.0.1.tar.gz`），或设 `PERF_EIGEN_ARCHIVE_URL`/`PERF_EIGEN_MIRROR`；SHA-256 必须与上表一致 |
| 构建阶段报 SHA-256 不匹配 | 镜像站可能重新打包了归档（gitee/github 的归档字节不同）；本用例只接受 gitlab.com 的 tag 归档或字节一致的副本 |
| 构建阶段报 Docker daemon 不可用 | 私有容器是唯一的构建环境：需要 `docker` 命令与可访问的 daemon（退出码 30）；确认当前用户有权限操作 Docker |
| 容器内 `dnf install` 失败 | 检查容器网络与 `repo.huaweicloud.com`（脚本已把 `openEuler.repo` 的 `metalink` 注释掉并改指华为镜像）；`PERF_PROXY` 存在时会同时配置 dnf 代理，失败返回 30 |
| `bench/bench_gemm.cpp` 编译失败 | 看 `${PERF_WORK_DIR}/probe/compile-gemm.log`；编译命令就是 `c++ -std=c++17 -O3 -DNDEBUG -I <source>`，需要容器内 `gcc-c++`/`glibc-devel` |
| 启动阶段报自检失败 | 看 `${PERF_WORK_DIR}/logs/start-probe.log`；自检要求打印 `EIGEN_VERSION_STRING=5.0.1` 与 `selftest=ok` |
| 启动阶段报 GEMM 冒烟失败 | 看 `${PERF_WORK_DIR}/logs/start-gemm.log`；必须打印 `eigen cpu ... GFLOPS` 行 |
| test 阶段退出码 50，提示 `Matrix sizes = ...` 不符 | 驱动收到的 `-s` 参数与矩阵点不一致：`-s` 是 rows/columns/depth，即 `-s m n k`（不是 `-s m k n`） |
| test 阶段退出码 50，提示缺少日志/证据 | 检查 `runs/<slug>/` 是否缺少 `warmup` 或某个 `rep<i>`，以及该 `.log` 尾部（失败时脚本会打印最后 40 行） |
| test 阶段退出码 50，提示非正/非有限 GFLOPS | 上游驱动在该矩阵点上打印了异常值；看对应 `runs/<slug>/rep<i>.log`，不要用其它数字代替 |
| 测量数值抖动大 | 确认没有其他编译/测试任务抢占 CPU；本用例不绑核，中位数对偶发噪声不敏感，但 `sample_summary.stdev` 会如实反映 |
| 残留 `boostkit-eigen-*` 容器 | `stop` 会按运行 ID 标签删除本任务容器；被取消的历史容器在下一次 build 时按名字前缀与运行 ID 清理。手工清理时只删除自己运行 ID 的容器，勿批量删除 |

## 许可证

- Eigen 本体为 **MPL-2.0**（`COPYING.MPL2`），另含少量 BSD 风格文件；
- `bench/bench_gemm.cpp` 属于 Eigen 归档（MPL-2.0），本用例**不修改**它，只在容器内编译
  并运行；仓库不复制上游源码，也不分发编译产物；
- 本用例新增的 shell/python/C++ 脚本（`eigen_test.sh`、`scripts/**`）为本项目原创代码，
  随本项目许可证发布。
