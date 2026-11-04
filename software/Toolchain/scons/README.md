# SCons 4.11.1 构建性能用例（Toolchain）

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件 | SCons（纯 Python 构建工具） |
| 版本 | `4.11.1` |
| 制品 | `scons-4.11.1.tar.gz`（GitHub `SCons/scons` tag 源码包，codeload 生成） |
| 制品 SHA-256 | `9087b5068572e9e4d9347c987e3fa5ab0edf3fa84935f7ac5c0508792bb7a776` |
| 运行方式 | 直接从解包源码树执行 `python3 scripts/scons.py`（SCons 本身无需编译） |
| C 编译器 | 平台 `cc`（Runner 为 GCC），版本记录在 `build_info.json.notes` |
| 分类 | Toolchain |

SCons 是纯 Python 实现，因此"实际版本"由 `scripts/scons.py --version` 的
`SCons: v4.11.1.<git-sha>` 解析得到；源码树版本与请求版本不一致返回 40（框架记为
build 30）。不安装 PyPI 包、不联网解析依赖。

## 2. 安装与构建

build 阶段：

1. 依赖命令自检：`curl tar python3 sha256sum awk cc`，`dnf`/`apt-get` 双分支安装
   （`cc` 映射到 `gcc`），装后再次 `command -v` 自检。
2. 取 `scons-4.11.1.tar.gz`：离线目录 → `ghfast.top` → 官方 codeload，每源校验同一
   SHA-256；解包后检查 `scripts/scons.py`、`SCons/` 包与上游 `bench/bench.py`。
3. 执行 `python3 scripts/scons.py --version` 读取实际版本并写入
   `PERF_ACTUAL_VERSION_FILE`。
4. 用 `scripts/generate_project.py` 确定性生成 100 个 C 文件（`src/bench_0001.c` …
   `bench_0100.c`，每个文件一个独立函数）与 `SConstruct`
   （`env.StaticLibrary('build/libbench.a', Glob('src/*.c'))`）。
5. 写 `build_variant.json`。

离线目录：`PERF_SCONS_OFFLINE_DIR`（默认 `/home/runner/software/scons/`），
放置 `scons-4.11.1.tar.gz` 即可离线构建。

## 容器化执行

本用例的构建、启动、测试与清理全部在每次任务专属的 openEuler 24.03 LTS SP4 私有容器内
完成，与 `software/Database/mysql`、`software/Bigdata/ray`、`software/Others/unixbench`
使用同一套容器契约。宿主机只需要 Docker、下载/校验工具与 Framework，不再需要编译器、
Python 与 `dnf` 包。

- 基础镜像：openEuler 24.03 LTS SP4 官方 Docker 归档，优先读取
  `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<arch>.tar.xz` 与同名
  `.sha256sum`，缺失时从
  `https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/<arch>/` 下载；加载后校验
  归档 SHA-256、镜像架构与镜像内 `/etc/os-release`。
- 容器：名字 `boostkit-scons-<arch>-<运行ID>`，标签 `boostkit.scons.run-id=<运行ID>`，使用
  宿主网络；读写挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`，只读挂载用例目录（独立运行时
  例外），容器内路径与宿主完全相同，`${PERF_WORK_DIR}/home` 作为容器内 `HOME`。
- 容器内：`dnf` 安装 `gcc`、`gcc-c++`、`make`、`python3`、`tar`、`gzip`、`diffutils`、
  `findutils`、`coreutils`、`sed`、`gawk`、`grep`、`util-linux`、`file`、`binutils` 与
  `glibc-devel`；SCons 源码解包、`python3 scripts/scons.py --version` 版本探测、
  `scripts/generate_project.py`、全部被测构建（上游 `bench/bench.py`、clean/noop/incremental
  100 文件工程）与计时包装（`scripts/run_timed.py`）都在容器内执行，C 编译器也在容器内。
- 宿主机：只负责下载并校验 SCons 源码包（优先 `/home/runner/software/scons/`）、严格解析
  `results.json` 与清理本任务的容器。结果解析器不进入容器。
- 测量：每条样本由容器内进程直接派生，`docker exec` 的管理开销不进入计时窗口。
- 清理：`stop` 阶段幂等删除本任务容器（标签不符拒绝删除）；取消任务遗留的同软件容器会在
  下一次 build 时按名字前缀清理。

独立运行同样需要 Docker 与可访问的 Docker daemon；不满足时 build 阶段返回 30 并给出提示。

## 3. 完整测试口径

本用例同时覆盖上游自带 bench 计时器与端到端 100 文件构建矩阵。每个场景 1 次预热
+ `PERF_REPS` 次独立测量（正式证据要求 `>=5`，默认 5），每次写
`runs/<scenario>/{warmup,rep<i>}.{log,json}`。

| 场景 | 命令 | 说明 |
|---|---|---|
| `upstream_bench_is_types` | `python3 bench/bench.py bench/is_types.py` | 上游 bench 计时器（`is_types` 片段） |
| `upstream_bench_lvars_gvars` | `python3 bench/bench.py bench/lvars-gvars.py` | 上游 bench 计时器（`LocalVariables/GlobalVariables`） |
| `upstream_bench_dependency_func` | `python3 bench/bench.py bench/dependency-func.py` | 上游 bench 计时器（dependency function） |
| `scons_clean_100` | 清空 `build/`、`.sconsign.dblite` 后 `python3 scripts/scons.py` | 100 个 C 文件全量构建 |
| `scons_noop_100` | 预热后不改源码反复 `python3 scripts/scons.py` | 空闲增量：全部 up-to-date |
| `scons_incremental_one_100` | 每次 `touch` 一个 `.c` 后 `python3 scripts/scons.py` | 单文件增量：重编 1 个目标 |

上游 `bench/` 中另有 `env.__setitem__.py`（本机单次约 21.7 s）、
`benchmark_subst.py` 与 `time_member.py`（退出码非 0，属上游历史脚本与当前
CPython 3 不兼容）。用例**只**登记在 CPython 3 上可完整运行且退出码为 0 的
3 个计时脚本；未通过的脚本不做零填充、不纳入指标，证据见本节说明。

严格性：解析器要求 6 个场景 `rep1..repN.json` 全部存在、退出码 0、墙钟与 RSS 为
有限正数；否则返回 50。每次 clean/inc 构建后还会检查 `build/libbench.a` 存在，
缺失按 50 处理。

## 4. 指标

6 场景 × 2 指标 = 12，外加 `scons_clean_100` 的吞吐指标，共 **13 个指标**：

| 指标 | 单位 | 方向 |
|---|---|---|
| `<scenario>__wall_seconds` | s | lower_is_better |
| `<scenario>__peak_rss_mib` | MiB | lower_is_better |
| `scons_clean_100__files_per_second` | files/s | higher_is_better |

每个指标带 `median`/`mean`/`min`/`max`/`stdev` 与全部样本。RSS 是单次
`python3` 进程（SCons 主进程；其 `cc` 子进程的 `ru_maxrss` 由同一进程组近似计入）
的峰值。

## 5. 架构与证据边界

- 两个架构使用同一份固定源码包与同一套生成语料；C 编译器为各架构原生 `cc`。
- 本地 WSL `x86_64` 只做链路验证；正式性能数据必须来自专用 `aarch64` Runner。
- SCons 是 Python 程序，绝对墙钟强依赖 CPython 版本与解释器构建参数；跨版本对比
  只在同一 CPython 大版本内有效（本用例 build 阶段记录解释器版本）。
- 上游 bench 计时器打印的是"片段耗时"而非端到端；它们只用于观察 SCons 内部
  数据结构的相对开销，我们不解析其输出，只测量整进程墙钟与 RSS。
- 未覆盖：PyPI wheel 安装路径、`-j` 并行构建、SCons 自身测试套件（`runtest.py`）、
  其他 C 编译器（clang）、其他 Python 实现。

## 6. 运行方式

```bash
python3 framework/run_case.py \
  --case software/Toolchain/scons/case.yaml \
  --version 4.11.1 --architecture x86_64 \
  --run-id local-scons-1 --stage build
PERF_REPS=5 python3 framework/run_case.py ... --stage test

# 独立入口
software/Toolchain/scons/scons_test.sh --version 4.11.1 --results-dir /tmp/scons-results

# 负向：未实现的优化变体
PERF_VARIANT=optimized python3 framework/run_case.py ... --stage build   # 期望 30
```

## 7. 故障排查

| 现象 | 原因 / 处理 |
|---|---|
| build 30，`every download source failed` | 三个源（含离线目录）都失败；日志逐条打印尝试路径 |
| build 30，`sha256 mismatch` | 镜像/离线目录里是别的 tag 包，删除后重下 |
| build 30，`missing scripts/scons.py or the SCons package` | 解包不完整（源码包被截断） |
| build 40 → 框架 30，`requested SCons ... but the source tree reports ...` | tag 与版本不符，检查 `SCONS_ARCHIVE_SHA256` |
| build 30，`no C compiler (cc)` | 缺少 gcc；dnf/apt 分支会自动安装 `gcc` |
| test 50，`did not produce build/libbench.a` | 构建失败；`runs/<scenario>/rep<i>.log` 有 SCons 完整输出 |
| test 50，`wall time must be positive` | SCons 启动即失败（如解释器路径错误） |
| 上游 bench 脚本报错 | `env.__setitem__.py`/`benchmark_subst.py`/`time_member.py` 已排除，见第 3 节 |

## 8. 许可证

SCons 使用 MIT License。本用例只下载并运行其官方源码包，不修改 SCons 源码；
生成的 C 语料由本用例脚本生成，无第三方代码。
