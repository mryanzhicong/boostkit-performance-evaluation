# expat 性能评测用例

本目录是 `Toolchain/expat` 在性能评测框架中的完整用例：固定版本、可复现的
构建方式、确定性语料、统一的测量方式，以及完整的原始证据（每次重复的
stdout/stderr 与时序 JSON）。

## 1. 版本与上游制品

| 项目 | 值 |
|---|---|
| 软件 | expat（libexpat） |
| 版本 | `2.9.0` |
| 类别 | `Toolchain` |
| 源码归档 | `expat-2.9.0.tar.xz`（534,052 字节） |
| SHA-256 | `1e6371862cc31999b368c3b89b49994f0677e1bab5f1b2b85ae3741f5d803051` |
| 官方地址 | `https://github.com/libexpat/libexpat/releases/download/R_2_9_0/expat-2.9.0.tar.xz` |
| 镜像 | `https://gh-proxy.com/...`、`https://ghfast.top/...`（前缀官方地址，字节一致） |

libexpat 的正式发布归档只发布在 GitHub Releases（项目没有独立下载站）。
本机实测三条独立下载路径（gh-proxy、ghfast、github.com 直连）得到的文件
**SHA-256 完全相同**，均等于上表值。Runner 侧的候选顺序为：离线目录
`/home/runner/software/expat/`（`PERF_EXPAT_OFFLINE_DIR` 可覆盖）→ gh-proxy →
ghfast → 官方地址。每个候选都必须通过同一个 SHA-256 校验，字节不同即拒绝。

## 2. 构建方式

- 在独立工作目录内解压源码，**源码树内构建**（`./configure` + `make`）。
- 固定配置：`--prefix=<work>/expat-install --disable-shared --enable-static
  --without-docbook --without-examples`，`CFLAGS="-O2 -pipe"`。
- 固定并行度 `-j4`（`PERF_EXPAT_JOBS` 可覆盖）。
- `make -j4` 构建静态库、`xmlwf` 与上游 benchmark；随后 `make -j4 check`
  构建 `tests/runtests` 并执行一次上游测试套件作为 build 阶段自检（必须出现
  `Checks: 5196, Failed: 0`）。
- 实际版本从 `xmlwf --version`（输出形如 `xmlwf using expat_2.9.0`）解析并回填
  `build_info.json`；与目标版本不一致时 build 阶段以 40 退出。

## 3. 场景与指标

所有语料由 `scripts/generate_corpus.py` 确定性生成，`manifest.json` 记录每个
文件的精确字节数与 SHA-256；测量阶段只读本地文件，外部 DTD 场景只读取同目录的
`external.dtd`，不需要网络。

| 场景 | 任务 | 语料 / 驱动 | 说明 |
|---|---|---|---|
| `xmlwf_parse_wide` | parse | `wide.xml`（≈9.6 MB） | 10 万条记录的大文档解析（`xmlwf -t`） |
| `xmlwf_parse_huge` | parse | `huge.xml`（≈38.9 MB） | 40 万条记录的超大文档解析 |
| `xmlwf_parse_namespaced` | parse | `namespaced.xml`（4 命名空间） | 命名空间处理（`xmlwf -n -t`） |
| `xmlwf_parse_entities` | parse | `entities.xml`（≈11.3 MB） | 实体密集文档：30 万次内部实体引用 |
| `xmlwf_parse_external_dtd` | parse | `dtd_ext.xml` + `external.dtd` | 外部 DTD 处理（`xmlwf -p -t`） |
| `upstream_runtests` | upstream_suite | 上游 `tests/runtests` | 必须输出 `Checks: 5196, Failed: 0` |
| `upstream_benchmark_wide` | upstream_benchmark | `tests/benchmark` + `wide.xml` | 缓冲 8192、20 次迭代，必须打印固定汇总行 |
| `upstream_benchmark_namespaced` | upstream_benchmark | `tests/benchmark -n` + `namespaced.xml` | 命名空间感知的 benchmark 路径 |

每个场景 1 次预热 + `PERF_REPS` 次独立测量（正式证据 `PERF_REPS=5`），取中位数。
指标共 26 个：

- 墙钟中位数（`s`，越低越好）× 8；
- 峰值 RSS 中位数（`MiB`，越低越好）× 8；
- 解析吞吐（`MiB/s`，越高越好）× 7（5 个 xmlwf 场景按语料字节数，2 个 benchmark
  场景按「字节数 × 迭代次数」）；
- 上游测试速率（`tests/s`，越高越好）× 1（固定 5196 项检查 ÷ 墙钟）；
- 上游 benchmark 自报的每次解析平均耗时（`s`，越低越好）× 2（`*_avg_s`）。

## 4. 证据与失败语义

- 原始证据：`runs/<场景>/warmup.log`、`rep<i>.log`、`rep<i>.json`；所有测量由
  `scripts/run_timed.py` 统一产生（单子进程、完整输出落盘、墙钟 + `ru_maxrss`）。
- 严格校验：缺少样本、非数值/NaN/0 样本、非零退出、缺少原始日志、日志中缺少
  固定正确性标记（`Checks: 5196, Failed: 0`、benchmark 固定汇总行、
  `Average time per loop:` 必须恰好出现一次）都会让 test 阶段以 50 退出；
  失败时把日志尾部 ≥40 行打印到 stdout。
- `results.json` 由 `scripts/results/parse_benchmark.py` 归一化生成，包含指标值、
  单位、方向、样本列表与参数；不做零填充或估算。

## 5. 独立运行

```bash
# 六阶段（框架）
python3 framework/run_case.py \
  --case software/Toolchain/expat/case.yaml \
  --version 2.9.0 --architecture x86_64 --run-id <run-id> --stage build

# 独立入口（不经框架）
bash software/Toolchain/expat/expat_test.sh --results-dir /tmp/expat-results
```

常用环境变量：`PERF_REPS`、`PERF_EXPAT_JOBS`、`PERF_EXPAT_OFFLINE_DIR`、
`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、
`PERF_WORK_DIR`。

`PERF_VARIANT=optimized` 为保留变体：当前实现显式返回 30，不会回退到 base，
也不会生成 `build_variant.json`。

## 6. 容器化执行

每个阶段都在**本次任务专属的 openEuler 24.03 LTS SP4 容器**内执行（容器运行时块由
`adaptation/scripts/add-container-block.py` 从模板写入 `scripts/common.sh`，勿手改标记区）：

- **镜像**：优先使用本地归档
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz`，缺失时才从
  `repo.openeuler.org` 下载；加载前校验 `.sha256sum`、镜像架构（`x86_64`→`amd64`、
  `aarch64`→`arm64`）以及 `/etc/os-release` 中的 `24.03`。
- **容器名/标签**：`boostkit-expat-<arch>-<run-id>`，标签 `boostkit.expat.run-id=<run-id>`；
  删除前校验标签，拒绝删除其他任务的容器（返回 60）；启动时清理同前缀、run-id 不同的陈旧容器。
- **挂载**：`PERF_WORK_DIR`、`RESULTS_DIR` 与用例目录按相同绝对路径挂入（用例目录只读），
  容器内外路径一致；另挂 `/etc/passwd`、`/etc/group`。容器内以 `dnf` 安装 `gcc`、`make`、
  `tar`、`xz`、`gzip`、`coreutils`、`findutils`、`diffutils`、`sed`、`gawk`、`grep`、
  `util-linux`、`file`、`glibc-devel`、`binutils`、`python3`；宿主机只保留 Docker 与
  下载/SHA-256 校验工具。
- **职责划分**：宿主机负责源码归档下载与 SHA-256 校验、严格结果解析与产物校验；容器内负责
  解包、`configure`/`make`/`make check`、语料生成（`generate_corpus.py`）、`xmlwf` 与上游
  `tests/benchmark` 冒烟自检，以及**全部计时样本**——`test` 阶段把 `run_timed.py` 放进容器
  （`expat_container_exec_at`），每个样本都是容器内子进程，`docker exec` 的管理开销不落在
  测量窗口内。
- **清理**：`stop` 在 `initialize_runtime` 之后先调用 `remove_expat_container`（幂等，容器
  不存在返回 0），再检查是否残留运行标记。
- **独立运行**：仍需能访问 Docker daemon；宿主机不再需要 gcc/autotools/python3 解析依赖
  之外的构建工具。

## 7. 与手册建议口径的差异

- 手册建议的上游 `xmlwf` 与 `tests/benchmark` 均已覆盖：`xmlwf` 覆盖大文件、
  命名空间、实体密集与外部 DTD 四条路径，`tests/benchmark` 覆盖普通与命名空间
  感知两种配置，并额外记录其自报的每次解析平均耗时。
- 上游测试套件不在测量阶段重复跑 `make check`，而是直接运行构建出的
  `tests/runtests`（固定 5196 项检查、0 失败），避免 autotools 包装层带来的
  额外噪声；`make check` 仅在 build 阶段作为一次性自检。
- 实体密集语料控制在 30 万次内部实体引用、扩展比约 2.6 倍以内，以避开
  expat 2.9.0 的 billion-laughs 放大保护（`XML_BLAP`）触发阈值；这属于有意的
  安全边界，而不是把解析工作量调小。
