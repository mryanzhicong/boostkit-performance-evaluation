# flatbuffers 性能评测用例

本目录是 `Toolchain/flatbuffers` 在性能评测框架中的完整用例：固定版本、可复现
的构建方式、固定工作量、统一的测量方式，以及完整的原始证据（每次重复的
stdout/stderr 与时序 JSON）。

## 1. 版本与上游制品

| 项目 | 值 |
|---|---|
| 软件 | FlatBuffers |
| 版本 | `25.12.19` |
| 上游发布标签 | `v25.12.19-2026-02-06-03fffb2` |
| 类别 | `Toolchain` |
| 源码归档 | `flatbuffers-25.12.19.tar.gz`（2,375,289 字节，GitHub tag archive） |
| SHA-256 | `ccbce58684691de1e7d51f5e87786266b37d06ab66e9dfe2d0ec106fe50aace0` |
| 官方地址 | `https://github.com/google/flatbuffers/archive/refs/tags/v25.12.19-2026-02-06-03fffb2.tar.gz` |
| 镜像 | `https://gh-proxy.com/<官方地址>`、`https://ghfast.top/<官方地址>` |

说明：上游 Release 只提供预编译 `flatc` 二进制（Linux/Mac/Windows zip），不提供
源码包，因此源码固定为 GitHub 自动生成的 tag archive。GitHub 不为 tag archive
发布官方校验和，本表的 SHA-256 是本机从官方 tag 下载后计算、并通过 gh-proxy 与
ghfast 两条独立镜像路径 **逐字节复核一致** 的值；Runner 侧同样要求三个候选
（离线目录 → gh-proxy → ghfast → 官方）全部通过同一 SHA-256 与字节数校验，
不一致即拒绝。

## 2. 构建方式

- 在独立工作目录内解压 tag archive，用 CMake 源码构建：
  `-DCMAKE_BUILD_TYPE=Release`、`-DFLATBUFFERS_BUILD_TESTS=OFF`、
  `-DFLATBUFFERS_BUILD_BENCHMARKS=OFF`、`-DFLATBUFFERS_BUILD_SHAREDLIB=OFF`、
  `-DFLATBUFFERS_BUILD_FLATC=ON`、`-DFLATBUFFERS_BUILD_FLATLIB=ON`、
  `-DFLATBUFFERS_INSTALL=OFF`；目标 `flatbuffers flatc`，并行度 `-j4`
  （`PERF_FLATBUFFERS_JOBS` 可覆盖）。
- 用本树构建出的 `flatc` 生成两份头文件：
  上游 schema `benchmarks/cpp/flatbuffers/bench.fbs` → `bench_generated.h`，
  本用例 schema `scripts/bench/driver.fbs` → `driver_generated.h`。
- 用 `c++ -O2 -std=c++17` 编译两个测量程序：
  - `fb_bench_driver`：本用例多规模 builder/accessor 驱动；
  - `fb_upstream_bench`：直接驱动 **未被修改的** 上游
    `benchmarks/cpp/flatbuffers/fb_bench.cpp`（Encode/Decode/Use 接口）。
- 实际版本从 `flatc --version`（输出 `flatc version 25.12.19`）解析并回填
  `build_info.json`；与目标版本不一致时 build 阶段以 40 退出。

## 3. 场景与指标

上游 25.x 已把旧的 `tests/benchmark/cpp/bench.cpp` 迁移到 `benchmarks/cpp`，并且
其 `benchmarks/CMakeLists.txt` 通过 `FetchContent` 在 configure 阶段从 GitHub
拉取 `google/benchmark` 与 `gtest`。Runner 无法依赖该下载，因此本用例：

- 用上游 tag 内的 schema 与 **未修改的** `fb_bench.cpp`，配一个本地 runner
  直接驱动其 `Encode`/`Decode`/`Use` 接口（固定工作量、确定性 checksum）；
- 另加一个本用例自带的、可审查的最小 schema 与驱动，覆盖交付手册要求的
  “固定 builder/accessor、多规模” 负载，并显式声明为本用例代码而非上游套件。

所有场景都是固定工作量、无网络、无输入数据文件；每场景 1 次预热 +
`PERF_REPS` 次独立测量取中位数，墙钟与峰值 RSS 由 `scripts/run_timed.py`
统一产生。

| 场景 | 任务 | 模式 | 元素数 | 迭代 | 固定 checksum |
|---|---|---|---|---|---|
| `builder_1k` | builder_accessor | build | 1,000 | 100,000 | 0 |
| `accessor_1k` | builder_accessor | access | 1,000 | 100,000 | 49,950,000,000 |
| `builder_accessor_1k` | builder_accessor | merged | 1,000 | 100,000 | 49,950,000,000 |
| `builder_accessor_10k` | builder_accessor | merged | 10,000 | 10,000 | 499,950,000,000 |
| `builder_accessor_100k` | builder_accessor | merged | 100,000 | 1,000 | 4,999,950,000,000 |
| `builder_accessor_1m` | builder_accessor | merged | 1,000,000 | 100 | 49,999,950,000,000 |
| `upstream_bench_encode_use` | upstream_benchmark | 上游对象 | — | 10 批 × 10,000 | 每批 `-7035620705617902304` |

`builder_accessor_1k` 与交付手册中的代表负载一致（1000 个 uint32、10000 次
build+access、checksum 4995000000 的 10 倍放大版，checksum 49,950,000,000 是
同一公式按 100,000 次迭代的确定值）；其余场景在保持总工作量可比的前提下改变
payload 规模，用于观察 builder/accessor 随数据规模的行为。

指标共 28 个：

- 墙钟中位数（`s`，越低越好）× 7；
- 峰值 RSS 中位数（`MiB`，越低越好）× 7；
- 编码/访问吞吐（`MiB/s`，越高越好）× 7（驱动自报的实际编码字节数 ÷ 墙钟）；
- 元素处理速率（`elem/s`，越高越好）× 6（元素数 × 迭代数 ÷ 墙钟）；
- 上游 benchmark 迭代速率（`iter/s`，越高越好）× 1（批数 × 每批迭代数 ÷ 墙钟）。

## 4. 证据与失败语义

- 原始证据：`runs/<场景>/warmup.log`、`rep<i>.log`、`rep<i>.json`；
- 严格校验：缺少样本、非数值/NaN/0 值、非零退出、缺少原始日志、缺少固定
  correctness 标记（`mode=… elements=… iterations=…`、`checksum=<预期> expected=<预期>`、
  `encoded_bytes>0`、上游 `checksum_ok=1` 与每批 checksum 固定值）都会让 test
  阶段以 50 退出；失败时把日志尾部 ≥40 行打印到 stdout；
- 驱动在进程内也会校验 checksum，不一致直接非零退出，双重防护；
- `results.json` 由 `scripts/results/parse_benchmark.py` 归一化生成，包含指标值、
  单位、方向、样本列表与每个场景的固定参数；不做零填充或估算。

## 5. 独立运行

```bash
# 六阶段（框架）
python3 framework/run_case.py \
  --case software/Toolchain/flatbuffers/case.yaml \
  --version 25.12.19 --architecture x86_64 --run-id <run-id> --stage build

# 独立入口（不经框架）
bash software/Toolchain/flatbuffers/flatbuffers_test.sh --results-dir /tmp/fb-results
```

常用环境变量：`PERF_REPS`、`PERF_FLATBUFFERS_JOBS`、`PERF_FLATBUFFERS_OFFLINE_DIR`、
`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、`PERF_WORK_DIR`。

`PERF_VARIANT=optimized` 为保留变体：当前实现显式返回 30，不会回退到 base，
也不会生成 `build_variant.json`。

## 6. 容器化执行

每个阶段都在**本次任务专属的 openEuler 24.03 LTS SP4 容器**内执行（容器运行时块由
`adaptation/scripts/add-container-block.py` 从模板写入 `scripts/common.sh`，勿手改标记区）：

- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，缺失时才从
  `repo.openeuler.org` 下载；加载前校验 `.sha256sum`、镜像架构（`x86_64`→`amd64`、
  `aarch64`→`arm64`）以及 `/etc/os-release` 中的 `24.03`。
- **容器名/标签**：`boostkit-flatbuffers-<arch>-<run-id>`，标签
  `boostkit.flatbuffers.run-id=<run-id>`；删除前校验标签，拒绝删除其他任务的容器（返回 60）；
  启动时清理同前缀、run-id 不同的陈旧容器。
- **挂载**：`PERF_WORK_DIR`、`RESULTS_DIR` 与用例目录按相同绝对路径挂入（用例目录只读），
  容器内外路径一致；另挂 `/etc/passwd`、`/etc/group`。容器内以 `dnf` 安装 `cmake`、`gcc`、
  `gcc-c++`、`make`、`tar`、`gzip`、`coreutils`、`findutils`、`diffutils`、`sed`、`gawk`、
  `grep`、`util-linux`、`file`、`glibc-devel`、`binutils`、`python3`；宿主机只保留 Docker 与
  下载/SHA-256 校验工具。
- **职责划分**：宿主机负责源码归档的下载、SHA-256 与大小校验、严格结果解析与产物校验；
  容器内负责解包、CMake 配置/编译、`flatc` 生成头文件、C++ 基准编译、`flatc --version`
  版本判定与构建期冒烟，以及**全部计时样本**——`test` 阶段把 `run_timed.py` 放进容器
  （`flatbuffers_container_exec_at`），每个样本都是容器内子进程，`docker exec` 的管理开销
  不落在测量窗口内。
- **清理**：`stop` 在 `initialize_runtime` 之后先调用 `remove_flatbuffers_container`（幂等，
  容器不存在返回 0），再结束本用例的临时进程。
- **独立运行**：仍需能访问 Docker daemon；宿主机不再需要 cmake/g++ 等构建工具。

## 7. 与手册建议口径的差异

- 手册与任务说明引用的 “上游 `tests/benchmark/cpp/bench.cpp`” 在
  25.12.19 中已不存在：上游把基准迁移到 `benchmarks/cpp`，并依赖
  `google/benchmark` + `gtest` 的 `FetchContent` 下载。本用例保留上游代码路径
  （未修改的 `fb_bench.cpp` + 同一 tag 的 `flatc` 生成头文件），但不引入
  额外网络依赖；同时补一个本用例自带的、可审查的多规模 builder/accessor 驱动，
  以满足交付手册要求的固定 builder/accessor 负载。
- 源码校验和是本地计算并多路复核的值（上游未发布 tag archive 的官方校验和），
  这一点在 README 与 QA 记录中均明确标注，不冒称 “上游官方 SHA-256”。
- 编译参数固定为 `-O2 -std=c++17`，未做 PGO/LTO，便于两侧（x86_64 与 aarch64）
  与后续 optimized 变体对照。
