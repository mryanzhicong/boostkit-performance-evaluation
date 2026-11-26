# R 4.6.2 性能测试用例

本用例属于 **Toolchain** 类别，按仓库适配契约（`case.yaml` 的 shell-functions 六阶段：
prepare/build/start/test/stop/finalize）实现，输出 `build_variant.json`、`raw-output.log`、
`results.json` 与 `runs/` 原始样本。正式性能证据来自 GitHub Actions
`Blue: Manual performance evaluation` 的 aarch64 运行；本机 x86_64 只做功能与链路验证。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成。宿主机只需要 Docker、下载/校验工具与 Framework，不再安装 gcc、gfortran、readline
或 libcurl 等构建依赖。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-r-<arch>-<运行ID>`，标签 `boostkit.r.run-id=<运行ID>`，使用宿主
  网络，以 Runner 用户身份运行；只读挂载用例目录，读写挂载 `${PERF_WORK_DIR}` 与
  `${RESULTS_DIR}`，容器内路径与宿主完全相同。
- 容器内：`dnf` 安装 `gcc`、`gcc-gfortran`、`make`、`pcre2-devel`、`zlib-devel`、
  `bzip2-devel`、`xz-devel`、`libcurl-devel`、`openssl-devel`、`time`（GNU time 的
  `/usr/bin/time -f %M` 用于峰值 RSS）与 `python3`；R 源码解包、`./configure`、
  `make -j`、`make install`、BLAS/版本探测与 16 个场景的计时包装
  （`scripts/run_timed.py`）都在容器内执行，`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 宿主机：只负责下载并校验 `R-4.6.2.tar.gz`（优先 `/home/runner/software/r/`）、写
  `build_variant.json`/`actual-version.txt` 与严格解析 `results.json`；结果解析器不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口；工作负载
  只用内置 reference BLAS/LAPACK，测量期把代理指向 `127.0.0.1:9` 证明全程离线。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器会在
  下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 1. 版本与制品来源

| 项目 | 值 |
|---|---|
| 目标版本 | **R 4.6.2** |
| 官方源码 | `https://cran.r-project.org/src/base/R-4/R-4.6.2.tar.gz` |
| SHA-256 | `c297040f6392b1dac6e5c0eb398422cfdaedf540ae2205edb9ad0d10cb10ee00`（CRAN 未发布该 tarball 的 `.sha256`/`.md5` 附件，该值由官方归档计算并在每次下载/离线副本上复核） |
| 源码大小 | 39,925,606 字节 |
| 离线预置目录 | `/home/runner/software/r/R-4.6.2.tar.gz` |
| 镜像顺序 | `PERF_R_SOURCE_MIRROR` → 清华 TUNA → 阿里云 → 官方 cran.r-project.org，每个源都校验同一 SHA-256 |

构建依赖：`gcc`、`gfortran`、`make`、`tar`、`curl`、PCRE2 / zlib / bzip2 / xz 头文件。
Runner `dnf install gcc gcc-gfortran make tar curl bzip2 xz pcre2-devel zlib-devel bzip2-devel xz-devel`；
Ubuntu `apt-get install gcc gfortran make tar curl bzip2 xz-utils libpcre2-dev zlib1g-dev libbz2-dev liblzma-dev`，
安装后逐条自检。

## 2. 安装与构建（固定口径）

```bash
./configure --prefix=<workdir>/r-install \
    --without-x --without-recommended-packages --disable-java \
    --without-readline --without-libcurl
make -j4
make install
```

- 仅构建 R 核心与 base 包：不装推荐包（`--without-recommended-packages`），不依赖 X11、
  readline、libcurl，减少环境差异。
- **BLAS/LAPACK 使用 R 源码自带的内部 reference BLAS**：本用例不安装、不链接任何系统 BLAS
  （如 OpenBLAS/MKL）。构建后执行 `extSoftVersion()["BLAS"]` 记录实际值并写入
  `build_variant.json` 的 `blas` 字段，同时记录 `R.version$version.string`。
- 构建日志保留在 `<workdir>/build/{configure,make,install}.log`，失败时打印尾部 40 行并以
  `30` 退出。

## 3. 完整测试口径（16 场景 × 2 指标）

每场景**预热 1 次 + 5 次独立测量**，取中位数；`results.json` 保留全部样本与
min/max/mean/stdev。测量阶段完全离线，工作负载为仓库内 `benchmarks/bench.R`，每个场景输出
确定性的 `RESULT scenario=... checksum=...`，解析阶段逐场景核验。

| 场景 | 维度 | 规模 | 口径 |
|---|---|---|---|
| `crossprod_small/large` | blas | 400 / 1200 | `crossprod()` 双精度矩阵乘（内部 reference BLAS dgemm） |
| `matvec_small/large` | blas | 500 / 1500 | 矩阵 × 向量（dgemv） |
| `solve_small/large` | blas | 300 / 900 | 正定线性方程组求解（内部 LAPACK） |
| `vector_arith_small/large` | vector | 5M / 20M | `sqrt`/除法/求和向量运算 |
| `sort_small/large` | vector | 1M / 4M | 均匀随机 double 排序 |
| `lapply_small/large` | calls | 200k / 800k | `lapply` 逐元素调用 |
| `paste_small/large` | strings | 200k / 800k | `paste0` 字符串拼接并统计长度 |
| `rowsum_small/large` | matrix | 20000×100 / 40000×100 | `rowSums()` 矩阵行求和 |

指标：墙钟中位数（s，lower_is_better）+ 进程峰值 RSS 中位数（MiB，lower_is_better）。
RSS 由 GNU `/usr/bin/time -f %M` 读取被测进程本身；墙钟由 `scripts/run_timed.py` 测量。

严格解析：缺样本 / 非零退出 / 超时 / wall 或 RSS 非正 / 校验和不符 / 多出场景目录 →
`test` 阶段退出 `50`，不补零、不插值。

## 4. 架构边界

- aarch64（鲲鹏 / Blue runner）为正式性能证据；x86_64 本机运行只验证契约、六阶段流程和
  校验和，不作为性能结论。
- 浮点场景（BLAS/LAPACK 与 `sum`）采用 `1e-9` 相对容差：同一 reference BLAS 实现下结果稳定，
  但不同架构的浮点累加顺序可能带来末位差异；整数场景（`lapply`、`paste` 长度）要求完全一致。
- BLAS 版本固定为 R 源码内置 reference 实现，因此结果可逐版本比较，不随系统 BLAS 变化。

## 5. 运行方式

框架（等价于 CI）：

```bash
python3 framework/run_case.py \
  --case software/Toolchain/r/case.yaml \
  --version 4.6.2 --architecture aarch64 --run-id <run-id> \
  --stage prepare|build|start|test|stop|finalize
```

独立入口（可在仓库外运行）：

```bash
cd software/Toolchain/r
PERF_REPS=5 bash r_test.sh --results-dir /tmp/r-results
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`（`base`/`optimized`）、
`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`（默认 5）、`PERF_R_OFFLINE_DIR`、
`PERF_R_SOURCE_MIRROR`、`BENCH_BUILD_JOBS`。`optimized` 变体保留：显式返回 `30`，
不写 `build_variant.json`，不回落 base。

## 6. 实测记录（x86_64，仅链路验证）

见本条目 `adaptation/qa/36-r-QA.md`：本机六阶段耗时、16 场景中位数样本、5 重复一致性、
负向 `optimized`=30 与并发噪声说明。

## 7. 故障排查

- **configure 失败**：检查 `build/configure.log`；R 需要 gfortran、PCRE2、zlib/bzip2/xz 头文件。
- **make 失败**：检查 `build/make.log`；`-j4` 为并行上限。
- **BLAS 异常**：确认未安装系统 BLAS；`extSoftVersion()["BLAS"]` 应为内部 reference BLAS。
- **下载慢/失败**：优先离线目录；镜像同样校验 SHA-256。
- **校验和不符**：对比 `runs/<scenario>/rep*.log` 的 `RESULT` 行与
  `benchmarks/scenarios.psv` 的提交值。

## 8. 许可证

R 采用 GPL-2 / GPL-3（见源码包 `COPYING`）；本目录自写的 benchmark 脚本与适配脚本跟随仓库
既有用例的 MIT 许可。
