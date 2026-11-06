# googletest 性能评测用例

本目录是 `Toolchain/googletest` 在性能评测框架中的完整用例：固定版本、可复现的
构建方式、固定工作量、统一的测量方式，以及完整的原始证据（每次重复的
stdout/stderr 与时序 JSON）。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成，与 `software/Database/mysql`、`software/Bigdata/ray`、`software/Others/unixbench`
使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再安装
CMake、编译器或 `dnf` 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-googletest-<arch>-<运行ID>`，标签
  `boostkit.googletest.run-id=<运行ID>`；使用宿主机网络，以 Runner 用户身份运行；
  只读挂载用例目录，读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，容器内路径与宿主机
  完全相同；容器内 `HOME` 为 `${PERF_WORK_DIR}/home`。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`make`、`cmake`、`python3` 等构建依赖；解包
  release archive、CMake 配置与构建（`gtest`/`gtest_main`/`gtest_unittest`）、三份断言矩阵
  的编译、版本探测、计时包装（`scripts/run_timed.py`）与全部被测进程都在容器内执行。
- 宿主机：只负责下载并校验 GoogleTest release archive（优先
  `/home/runner/software/googletest/`）、严格解析 `results.json`、清理本任务的容器。
  结果解析器不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器
  会在下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出
提示。

## 1. 版本与上游制品

| 项目 | 值 |
|---|---|
| 软件 | GoogleTest（googletest） |
| 版本 | `1.18.0` |
| 类别 | `Toolchain` |
| 源码归档 | `googletest-1.18.0.tar.gz`（894,741 字节，官方 Release asset） |
| SHA-256 | `6e3191c1455468b3fc35a417fb565c1c5071aee1b7e7f85e30cf48a98d37d8b5` |
| 官方地址 | `https://github.com/google/googletest/releases/download/v1.18.0/googletest-1.18.0.tar.gz` |
| 镜像 | `https://gh-proxy.com/<官方地址>`、`https://ghfast.top/<官方地址>` |

该 SHA-256 **等于上游发布值**：GitHub releases API 对
`googletest-1.18.0.tar.gz` 返回的 asset digest 即
`sha256:6e3191c1455468b3fc35a417fb565c1c5071aee1b7e7f85e30cf48a98d37d8b5`，且
gh-proxy、ghfast 两条镜像下载与本机官方下载逐字节一致。Runner 侧候选顺序为：
离线目录 `/home/runner/software/googletest/`（`PERF_GOOGLETEST_OFFLINE_DIR`
可覆盖）→ gh-proxy → ghfast → 官方，每个候选都必须通过同一 SHA-256 与大小校验。

GoogleTest 的公开头文件不导出运行期版本字符串，因此实际版本由两项证据共同确定：
源码归档 SHA-256（= 上游 asset digest），以及解压后源码声明的
`GOOGLETEST_VERSION`（`googletest/CMakeLists.txt` 的 `set(GOOGLETEST_VERSION 1.18.0)`）。
二者一致才视为版本正确，否则 build 阶段以 40 退出。

## 2. 构建方式

- 在独立工作目录内解压官方 release archive，用 CMake 源码构建：
  `-DCMAKE_BUILD_TYPE=Release`、`-DBUILD_GMOCK=OFF`、`-DINSTALL_GTEST=OFF`、
  `-Dgtest_build_tests=ON`（上游默认不构建自身测试，必须显式打开）；目标
  `gtest gtest_main gtest_unittest`，并行度 `-j4`（`PERF_GOOGLETEST_JOBS` 可覆盖）。
- 用 `c++ -O2 -std=c++17 -I googletest/include` 把本用例断言矩阵源码
  `scripts/bench/matrix.cc` 编译三份，链接构建出的 `libgtest.a`：
  `gtest_matrix_1k`（1000 个参数化测试）、`gtest_matrix_10k`（10000 个）、
  `gtest_assertion_loop`（单测试内 500 万个断言）。
- build 阶段 smoke 校验：1000 矩阵必须 `[  PASSED  ] 1000 tests.`，断言循环必须
  打印固定的工作量行，上游 `gtest_unittest` 必须 `[  PASSED  ] 434 tests.`。

## 3. 场景与指标

口径为“固定 1000 个成功断言测试的框架运行开销”（交付手册的代表负载），指标是
框架调度/断言宏/结果输出开销，不是任何业务 CPU 分数。

| 场景 | 任务 | 负载 | 固定正确性标记 |
|---|---|---|---|
| `upstream_gtest_unittest` | upstream_suite | 上游 `gtest_unittest`（434 tests / 104 suites） | `[==========] 434 tests from 104 test suites ran.` + `[  PASSED  ] 434 tests.` |
| `matrix_1k` | assertion_matrix | 1000 个参数化测试，每个 1 个成功断言 | `[gt-matrix] mode=registered registered_tests=1000 assertions=0 rc=0` + `PASSED 1000 tests` |
| `matrix_10k` | assertion_matrix | 10000 个参数化测试 | 同上，registered_tests=10000 |
| `assertion_loop_5m` | assertion_matrix | 1 个测试内 5,000,000 个成功断言 | `[gt-matrix] mode=loop registered_tests=0 assertions=5000000 rc=0` + `PASSED 1 test` |

每个场景 1 次预热 + `PERF_REPS` 次独立测量取中位数，墙钟与峰值 RSS 由
`scripts/run_timed.py` 统一产生（单子进程、完整输出落盘、墙钟 + `ru_maxrss`）。

指标共 16 个：

- 墙钟中位数（`s`，越低越好）× 4；
- 峰值 RSS 中位数（`MiB`，越低越好）× 4；
- 每秒测试数（`tests/s`，越高越好）× 3（上游套件 434、1000 矩阵、10000 矩阵）；
- 每秒断言数（`assertions/s`，越高越好）× 1（500 万断言循环）；
- 每测试微秒数（`us/test`，越低越好）× 3；
- 每断言纳秒数（`ns/assertion`，越低越好）× 1。

所有墙钟包含测试二进制启动与 GoogleTest 初始化开销，这正是“框架运行开销”的
口径；它不拆分进程启动、测试调度与断言求值，也不代表任何业务算法速度。

## 4. 证据与失败语义

- 原始证据：`runs/<场景>/warmup.log`、`rep<i>.log`、`rep<i>.json`；
- 严格校验：缺少样本、非数值/NaN/0 值、非零退出、缺少原始日志、缺少固定
  correctness 标记（上游 434/104 汇总、矩阵 `[gt-matrix]` 工作量行 + `PASSED`
  数量、无 `[  FAILED  ]` 行）都会让 test 阶段以 50 退出；失败时把日志尾部
  ≥40 行打印到 stdout；
- `results.json` 由 `scripts/results/parse_benchmark.py` 归一化生成，包含指标值、
  单位、方向、样本列表与每个场景的固定参数；不做零填充或估算。

## 5. 独立运行

```bash
# 六阶段（框架）
python3 framework/run_case.py \
  --case software/Toolchain/googletest/case.yaml \
  --version 1.18.0 --architecture x86_64 --run-id <run-id> --stage build

# 独立入口（不经框架）
bash software/Toolchain/googletest/googletest_test.sh --results-dir /tmp/gtest-results
```

常用环境变量：`PERF_REPS`、`PERF_GOOGLETEST_JOBS`、`PERF_GOOGLETEST_OFFLINE_DIR`、
`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、`PERF_WORK_DIR`。

`PERF_VARIANT=optimized` 为保留变体：当前实现显式返回 30，不会回退到 base，
也不会生成 `build_variant.json`。

## 6. 与手册建议口径的差异

- 手册的代表负载是“1000 个成功断言测试的框架运行开销”，由 `matrix_1k` 直接覆盖；
  另外保留上游 `gtest_unittest` 作为“上游测试套件”证据，并追加 10000 测试矩阵与
  单测试 500 万断言两个扩展场景，用于观察注册/调度与断言宏两条开销路径。
- 手册记录的执行时间约为 7 ms 量级，本用例的 1000 矩阵同量级（受机器负载影响）。
- 上游测试套件用 `-Dgtest_build_tests=ON` 打开（上游默认不构建自身测试），这是
  构建参数层面的必要设置，不改变被测代码。
- 未做 PGO/LTO，编译参数固定 `-O2 -std=c++17`，便于两侧（x86_64 与 aarch64）
  与后续 optimized 变体对照。
