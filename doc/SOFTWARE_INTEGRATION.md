# 软件测试接入指南

新软件放在 `software/<category>/<software>/`。Framework 分阶段调用 `scripts/` 下的函数；独立入口运行同一组函数。`base` 与 `optimized` 只在构建阶段分流，后续启动、测试、解析使用同一套实现。

文中的 `example`、`1.0.0`、下载地址、校验值和指标名均为示例。接入时须替换为核实过的真实值。

按以下顺序接入：

1. 确定软件版本、正式测试命令、数据集和指标，写软件 README。
2. 注册软件，写 `case.yaml`，声明每个阶段的入口和必需结果。
3. 在 `common.sh` 接收运行变量并计算私有路径。
4. 分别实现基础版、调优版构建；在 `dispatch.sh` 中选择其一。
5. 实现共用的 `start`、`test`、`stop`、解析器和独立入口。
6. 做静态校验、独立运行、双架构报告验收。

实际调用链：

```text
工作流选择 base/optimized → build（只调用对应构建脚本）
                         → start → test → stop → Framework 归一化与报告
```

Framework 对每个阶段启动新的 Shell 进程。因此跨阶段状态必须保存在本次任务的私有目录，不能只存于 Shell 变量。

## 1. 确定测试并编写软件 README

先确定两个架构都能获取的版本和正式测试命令，再写 `software/<category>/<software>/README.md`：

| 项目 | README 中要写的内容 |
|---|---|
| 软件版本与来源 | 源码 tag、提交或二进制包地址；离线包文件名与校验值。 |
| 构建或安装 | 实际执行的命令、安装位置、读取产物版本的命令。 |
| 测试工具 | 来源、版本、准备命令和最终 benchmark 命令。 |
| 测试负载 | 数据集、请求或迭代数、并发、预热、预计内存、磁盘和运行时间。 |
| 结果解析 | 原始输出文件、选取的原始字段、单位和优化方向。 |

如果并发度随机器核数变化，记录实际并发度，并在指标身份中保留这一差异。跨架构报告只配对同一测试项。

## 2. 注册软件并填写 `case.yaml`

以 `HPC/example` 为例：

1. 在 `config/categories.yaml` 的 `HPC` 列表中追加 `- example`。
2. 创建 `software/HPC/example/README.md`、`case.yaml` 和独立入口 `example_test.sh`。
3. 按以下目录拆分脚本；`optimized.sh` 暂未实现时，必须明确失败，不能回退基础版。
4. 在清单中填写 `category: HPC`、`name: example`，与注册名和目录名保持一致。

```text
software/HPC/example/
├── README.md
├── case.yaml
├── example_test.sh
└── scripts/
    ├── common.sh
    ├── builders/
    │   ├── base.sh
    │   ├── dispatch.sh
    │   └── optimized.sh
    ├── stages/
    │   ├── start.sh
    │   ├── test.sh
    │   └── stop.sh
    └── results/
        ├── parse_benchmark.py
        └── standalone_runtime.py
```

| 文件 | 谁调用 | 职责 |
|---|---|---|
| `scripts/common.sh` | 其余 Shell 脚本通过 `source` 加载 | 校验变体、接收环境变量、计算本次任务路径。 |
| `scripts/builders/dispatch.sh` | Framework 的 `build` 阶段、独立入口 | 根据 `PERF_VARIANT` 选择一个构建函数，成功后记录变体。 |
| `scripts/builders/base.sh`、`optimized.sh` | `dispatch.sh` | 各自从零完成软件及测试工具构建。 |
| `scripts/stages/start.sh`、`test.sh`、`stop.sh` | Framework 对应阶段、独立入口 | 两种构建共用同一测试负载和清理流程。 |
| `scripts/results/` | `test.sh`、独立入口 | 从原始输出提取指标；独立运行时生成本地报告。 |
| `example_test.sh` | 开发者直接运行 | 解析命令行、依次调用阶段函数、处理失败与收口。 |

固定指标的清单可按下例填写，所有脚本和函数名都须实际存在：

```yaml
name: example
category: HPC
enabled: true
versions:
  - "1.0.0"
test_tools:
  example_benchmark:
    version: "1.0.0"
execution:
  type: shell-functions
  stages:
    build:
      script: scripts/builders/dispatch.sh
      function: build_example
    start:
      script: scripts/stages/start.sh
      function: start_example
    test:
      script: scripts/stages/test.sh
      function: run_example_benchmarks
    stop:
      script: scripts/stages/stop.sh
      function: stop_example
  timeout_minutes: 180
outputs:
  build_variant:
    path: build_variant.json
    stage: build
    format: json
    required: true
  benchmark_raw:
    path: benchmark_raw.txt
    stage: test
    format: text
    required: true
  benchmark_result:
    path: benchmark.json
    stage: test
    format: json
    required: true
metrics:
  source: benchmark_result
  definitions:
    throughput:
      path: results.throughput
      unit: ops/s
      direction: higher_is_better
```

上例要求 `benchmark.json` 至少包含 `{"results":{"throughput":123.4}}`，且数值来自正式测试输出。填写清单时逐项核对：

- `outputs.path` 相对于 `RESULTS_DIR`；必需文件由对应阶段写出且非空，JSON 根节点为对象。
- `metrics.source` 指向必需的 JSON 输出；指标值为有限数值。
- `direction` 填 `higher_is_better`、`lower_is_better` 或 `neutral`。
- `test_tools` 填实际工具。版本固定时填确切版本；使用随软件构建的工具可填“与被测软件版本一致”；使用 `dnf` 或 `@latest` 动态安装的工具，应如实注明版本未固定及来源；来源也无法核实时填 `unknown`。

固定指标的实际案例：[Snappy 的 `case.yaml`](../software/HPC/snappy/case.yaml)。它用 `metrics.definitions` 将官方 benchmark 名称逐项映射到 JSON 数值路径。

测试项数量随工具输出变化时，将上例的 `metrics.definitions` 换成 `metrics.collection`。例如，对于 `{"results":{"case_a":{"value":123.4},"case_b":{"value":98.7}}}`：

```yaml
metrics:
  source: benchmark_result
  collection:
    path: results
    value_path: value
    unit: ops/s
    direction: higher_is_better
```

动态指标清单按输出结构填写：

- `results` 为非空对象；对象键 `case_a`、`case_b` 是指标名。
- 名称位于对象内部字段时，增加 `name_path`。
- 按场景分表时，增加 `group_path`；二维表格参照 [MySQL 的 `case.yaml`](../software/Database/mysql/case.yaml)。

动态指标的实际案例：[LZ4 的 `case.yaml`](../software/HPC/lz4/case.yaml)。它用 `metrics.collection` 提取测试项，并用 `group_path` 按执行命令分组。

软件默认值和负载参数在脚本中维护。

## 3. 在 `scripts/common.sh` 中初始化必需变量

Framework 每次调用阶段函数都会通过环境变量传入运行路径和版本。工作流另外传入 `PERF_VARIANT`；直接运行时默认为 `base`。`common.sh` 须读取并保留这些值，只有独立运行时才设置默认路径。

`SCRIPT_DIR` 从 `scripts/common.sh` 向上一级计算，指向软件目录；`SOFTWARE_NAME` 固定为注册名。

| 变量 | Framework 自动传入值 | 独立运行默认值 |
|---|---|---|
| `SOFTWARE_VERSION` | 任务选择的版本 | 已在 `case.yaml.versions` 声明并验证的版本。 |
| `PERF_VARIANT` | 工作流下拉选择的 `base` 或 `optimized` | `base`；可用 `--variant` 覆盖。 |
| `EXPECTED_ARCH` | `x86_64` 或 `aarch64` | `uname -m` 的实际架构，并在构建前校验。 |
| `PERF_RUN_ID` | 本次任务 ID | 唯一的 `local-<UTC时间>-<进程号>`。 |
| `PERF_WORK_DIR` | `/home/runner/boostkit-perf/<software>/<version>/<architecture>/<run_id>/` | `/home/runner/boostkit-perf/<software>/` 下本次运行独占的子目录。 |
| `RESULTS_DIR` | 仓库下 `.perf-output/<category>/<software>/<version>/<architecture>/<run_id>/` | 基础版为 `<软件目录>/results/<version>/<run_id>/`，调优版为 `<软件目录>/results/<version>/optimized/<run_id>/`；可由调用者指定。 |
| `PERF_ACTUAL_VERSION_FILE` | `PERF_WORK_DIR/actual-version.txt` | `RESULTS_DIR/actual-version.txt`。 |
| `TMPDIR` | `PERF_WORK_DIR/tmp` | `PERF_WORK_DIR` 下的私有临时目录。 |

工作流的任务目录仍由 Framework 管理，不在脚本中追加 `optimized/`。正式归档会按所选变体把调优版放在版本目录的 `optimized/` 下；上表的默认结果目录仅用于独立运行。

将以下初始化放在 `scripts/common.sh` 中：

- 将 `example` 改为当前软件的注册名。
- 将 `1.0.0` 改为已验证的默认版本。
- `build`、`start`、`test` 阶段需要工作路径时调用 `initialize_runtime`。有状态服务的 `stop` 阶段也须重新计算路径；是否创建目录按清理需要决定。

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOFTWARE_NAME="example"
SOFTWARE_VERSION="${SOFTWARE_VERSION:-1.0.0}"
PERF_VARIANT="${PERF_VARIANT:-base}"
EXPECTED_ARCH="${EXPECTED_ARCH:-$(uname -m)}"
PERF_RUN_ID="${PERF_RUN_ID:-}"
PERF_WORK_DIR="${PERF_WORK_DIR:-}"
RESULTS_DIR="${RESULTS_DIR:-}"
PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-}"

validate_variant() {
    case "${PERF_VARIANT}" in
        base|optimized) ;;
        *) printf 'invalid variant: %s\n' "${PERF_VARIANT}" >&2; return 10 ;;
    esac
}

configure_runtime_paths() {
    validate_variant || return $?
    if [[ -z "${PERF_RUN_ID}" ]]; then
        PERF_RUN_ID="local-$(date -u '+%Y%m%dT%H%M%SZ')-$$"
    fi
    [[ "${PERF_RUN_ID}" =~ ^[A-Za-z0-9._-]+$ ]] || return 10
    if [[ -z "${RESULTS_DIR}" ]]; then
        if [[ "${PERF_VARIANT}" == optimized ]]; then
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/optimized/${PERF_RUN_ID}"
        else
            RESULTS_DIR="${SCRIPT_DIR}/results/${SOFTWARE_VERSION}/${PERF_RUN_ID}"
        fi
    fi
    PERF_WORK_DIR="${PERF_WORK_DIR:-/home/runner/boostkit-perf/${SOFTWARE_NAME}/local-${PERF_RUN_ID}}"
    PERF_ACTUAL_VERSION_FILE="${PERF_ACTUAL_VERSION_FILE:-${RESULTS_DIR}/actual-version.txt}"
    TMPDIR="${PERF_WORK_DIR}/tmp"
    export SOFTWARE_VERSION EXPECTED_ARCH PERF_VARIANT PERF_RUN_ID PERF_WORK_DIR RESULTS_DIR
    export PERF_ACTUAL_VERSION_FILE TMPDIR
}

initialize_runtime() {
    configure_runtime_paths || return $?
    mkdir -p "${PERF_WORK_DIR}" "${RESULTS_DIR}" "${TMPDIR}"
}
```

每个阶段在新的 Shell 进程中运行。文件放置规则如下：

| 内容 | 目录 |
|---|---|
| 跨阶段的构建产物、配置、PID 和数据 | `PERF_WORK_DIR`。下一阶段从文件重新读取。 |
| 源码、安装、虚拟环境、缓存、高 I/O 数据、临时文件、服务 socket 和日志 | `PERF_WORK_DIR` 的子目录。 |
| 清单声明的原始输出和结构化结果 | `RESULTS_DIR`。 |

## 4. 实现构建分流和共用阶段

### 4.1 基础版：`scripts/builders/base.sh`

`base.sh` 的 `build_example_base()` 是完整的基础版安装流程。它从空的本次任务目录开始，完成以下工作：

1. 调用 `initialize_runtime`，核对 `EXPECTED_ARCH` 与本机架构、请求版本与支持版本。
2. 检查并安装缺失的构建依赖。
3. 优先读取 `/home/runner/software/example/` 下的本地源码或安装包；缺失时从已核实的地址下载。
4. 验证来源、版本和校验值，在 `PERF_WORK_DIR` 构建或安装软件及测试工具。
5. 运行产物自己的版本命令，将实际版本写入 `PERF_ACTUAL_VERSION_FILE`。

不能仅把请求版本写进版本文件：必须从实际安装或构建的产物读取。构建产物须留在 `PERF_WORK_DIR`，供后续阶段复用。完整实例可看 [Faiss 基础版构建脚本](../software/AI/faiss/scripts/builders/base.sh)。

安装缺失的系统依赖时：

- root 用户运行 `dnf install`；非 root Runner 运行 `sudo -n dnf`。
- 配置了 `PERF_PROXY` 时，向 dnf 传入 `--setopt=proxy=...`。

例如：

```bash
require_commands() {
    local packages=() dnf_options=()
    command -v cc >/dev/null 2>&1 || packages+=(gcc)
    command -v make >/dev/null 2>&1 || packages+=(make)
    command -v curl >/dev/null 2>&1 || packages+=(curl)
    if ! command -v sha256sum >/dev/null 2>&1 || \
       ! command -v tee >/dev/null 2>&1; then
        packages+=(coreutils)
    fi
    command -v python3 >/dev/null 2>&1 || packages+=(python3)
    (( ${#packages[@]} > 0 )) || return 0
    [[ -z "${PERF_PROXY:-}" ]] || dnf_options+=("--setopt=proxy=${PERF_PROXY}")
    if [[ "$(id -u)" -eq 0 ]]; then
        dnf "${dnf_options[@]}" install -y "${packages[@]}"
    else
        sudo -n dnf "${dnf_options[@]}" install -y "${packages[@]}"
    fi
}
```

获取安装包时按以下顺序：

1. 从 `/home/runner/software/<software>/` 读取预置离线包；该目录只作为输入。
2. 离线包不存在时，将网络下载文件保存到 `PERF_WORK_DIR`。
3. 按已核实的校验值验证，再在 `PERF_WORK_DIR` 中解包、构建和安装。

例如：

```bash
EXAMPLE_RELEASE_URL="<official-release-base-url>"
EXPECTED_SHA256="<verified-64-character-sha256>"
archive_name="example-${SOFTWARE_VERSION}.tar.gz"
archive="${PERF_WORK_DIR}/${archive_name}"
if [[ -f "/home/runner/software/${SOFTWARE_NAME}/${archive_name}" ]]; then
    cp "/home/runner/software/${SOFTWARE_NAME}/${archive_name}" "${archive}"
else
    curl -fSL --retry 3 -o "${archive}" "${EXAMPLE_RELEASE_URL}/${archive_name}"
fi
printf '%s  %s\n' "${EXPECTED_SHA256}" "${archive}" | sha256sum -c -
```

`EXAMPLE_RELEASE_URL` 和 `EXPECTED_SHA256` 须对应所选版本、架构的官方发布信息。源码仓库型软件在 `PERF_WORK_DIR` 克隆指定 tag 或提交，并核对实际提交。

### 4.2 调优版：`scripts/builders/optimized.sh`

`build_example_optimized()` 也必须从空的本次任务目录完成依赖、源码、构建、安装和实际版本校验。它可以调用 `common.sh` 中两种构建都需要的辅助函数，但不能先运行 `build_example_base()`，也不能依赖基础版构建产物。若调优涉及补丁或插件，只作用于本次任务的私有副本，并在软件 README 中写明来源、版本和调用命令。

调优版尚未实现时，保留入口并明确失败：

```bash
build_example_optimized() {
    printf 'optimized example build is not implemented\n' >&2
    return 30
}
```

这样选择 `optimized` 后不会悄悄运行基础版。未实现的调优版也不应生成 `build_variant.json`。

### 4.3 构建分发：`scripts/builders/dispatch.sh`

`scripts/builders/dispatch.sh` 是 `case.yaml` 唯一的构建入口。它按变体只调用一个完整构建函数；构建成功后写出供报告核对的 `build_variant.json`：

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

build_example() {
    validate_variant || return $?
    case "${PERF_VARIANT}" in
        base)
            source "${SCRIPT_DIR}/scripts/builders/base.sh"
            build_example_base || return $?
            ;;
        optimized)
            source "${SCRIPT_DIR}/scripts/builders/optimized.sh"
            build_example_optimized || return $?
            ;;
    esac
    initialize_runtime || return $?
    printf '{"variant":"%s","parameters":{"variant":"%s"}}\n' \
        "${PERF_VARIANT}" "${PERF_VARIANT}" > "${RESULTS_DIR}/build_variant.json"
}
```

`build_variant.json` 的内容示例为 `{"variant":"base","parameters":{"variant":"base"}}`。其中 `parameters.variant` 会进入归一化结果，用于确认两个架构选择了相同构建方式。实际性能负载参数仍由 benchmark 结果 JSON 的 `parameters` 记录。

### 4.4 共用阶段：`scripts/stages/`

`base.sh`、`optimized.sh`、三个阶段脚本都先 `source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"`。每个阶段在新 Shell 中运行，须重新计算路径并从文件读取所需状态。

| 函数 | 操作 | 必须留下的内容 |
|---|---|---|
| `build_example` | 分发到基础版或调优版完整构建；在 `PERF_WORK_DIR` 获取、构建或安装并校验版本。 | 从产物读取实际版本，写入 `PERF_ACTUAL_VERSION_FILE`；成功后写出 `build_variant.json`。 |
| `start_example` | 初始化路径；服务型软件启动并有界等待就绪，无服务软件准备数据或确认 benchmark 可执行。 | 服务 PID、socket 等放在私有目录。 |
| `run_example_benchmarks` | 初始化路径，运行 README 中确定的正式命令并严格解析。 | `RESULTS_DIR/benchmark_raw.txt` 和 `RESULTS_DIR/benchmark.json`。 |
| `stop_example` | 停止本软件启动的服务，核对进程退出；无服务软件安全收口。 | 重复调用也能成功收口。 |

例如，`scripts/stages/start.sh` 可以检查构建产物；有服务的软件还须启动本次任务的服务并在限定时间内确认就绪：

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

start_example() {
    initialize_runtime || return $?
    [[ -x "${PERF_WORK_DIR}/install/bin/example-benchmark" ]] || {
        printf 'benchmark executable is missing\n' >&2
        return 40
    }
}
```

例如，`scripts/stages/test.sh` 调用正式 benchmark，再调用本目录解析器：

```bash
#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"

run_example_benchmarks() {
    initialize_runtime || return $?
    "${PERF_WORK_DIR}/install/bin/example-benchmark" --iterations 3 \
        2>&1 | tee "${RESULTS_DIR}/benchmark_raw.txt" || return 50
    python3 "${SCRIPT_DIR}/scripts/results/parse_benchmark.py" \
        "${RESULTS_DIR}/benchmark_raw.txt" "${RESULTS_DIR}/benchmark.json" || return 50
}
```

`--iterations 3` 只是示例，必须换成 README 中核实的正式测试参数。`common.sh` 启用 `set -o pipefail`，使 benchmark 失败能从上述管道返回非零。`stop_example()` 应只停止本任务启动的服务；失败路径也会调用它，因此要能重复执行。

### 4.5 解析器与独立入口

`scripts/results/parse_benchmark.py` 从原始输出生成清单声明的 `benchmark.json`，须完成：

- 校验指标齐全、唯一，且数值有效。
- 将跨架构固定负载写入 JSON 的 `parameters`，机器相关值写入 `runtime_context`；不要把不同并发度强行改成同名指标。
- 保留原始指标名称、单位及必要换算的依据，使结果可追溯。

上例 `benchmark.json` 的最小有效结构是 `{"results":{"throughput":123.4}}`；只有从真实 benchmark 输出解析出该数值，才可写入。`benchmark_raw.txt` 应保留完整原始输出，不能只保存提取出的数字。动态指标可参照 [LZ4 的结果处理脚本](../software/HPC/lz4/scripts/results/run_lzbench.py)。

独立入口 `example_test.sh` 加载 `dispatch.sh`、三个阶段脚本，并从 `scripts/results/` 调用报告处理脚本。脚本加载时只定义变量和函数。直接执行时，`main()` 须：

1. 接受 `--version`、`--variant base|optimized` 和 `--results-dir`，先校验变体。
2. 按顺序调用同一组阶段函数。
3. 在成功或失败后停止服务、校验结果，并清理本次创建的私有工作目录。

入口顶部及末尾形式如下。完整的参数解析、失败收口和报告生成可参照 [LZ4 独立入口](../software/HPC/lz4/lz4_test.sh) 的 `main()` 和 `run_lz4_standalone()`：

```bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/builders/dispatch.sh"
source "${SCRIPT_DIR}/scripts/stages/start.sh"
source "${SCRIPT_DIR}/scripts/stages/test.sh"
source "${SCRIPT_DIR}/scripts/stages/stop.sh"

# 此处实现 main()：解析 --version、--variant、--results-dir；
# 依次调用 build_example、start_example、run_example_benchmarks、stop_example。
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
```

独立入口保留 `RESULTS_DIR` 供检查，失败时返回非零退出码。复制到项目外后，仍使用该软件目录内的脚本和解析器完成测试。

## 5. 校验并验收

先在仓库根目录执行静态检查。示例中的路径和名称须替换为当前软件：

```bash
bash -n software/HPC/example/example_test.sh
bash -n software/HPC/example/scripts/common.sh \
  software/HPC/example/scripts/builders/*.sh \
  software/HPC/example/scripts/stages/*.sh
python3 -m compileall -q software/HPC/example/scripts
python3 framework/catalog.py validate
python3 framework/catalog.py matrix --software example --version 1.0.0 --architecture all --pretty
python3 -m pytest -q framework/tests
```

在专用 Runner 上依次验证：

1. 验证 `--variant optimized` 在未实现时明确失败，且不写 `build_variant.json`、不回退基础版。
2. 直接运行基础版脚本，指定持久结果目录。
3. 将完整软件目录复制到项目外，重跑独立入口。

例如：

```bash
bash software/HPC/example/example_test.sh --version 1.0.0 --variant optimized \
  --results-dir /home/runner/example-results/optimized-check
bash software/HPC/example/example_test.sh --version 1.0.0 --variant base \
  --results-dir /home/runner/example-results/1.0.0
cp -a software/HPC/example /home/runner/example-standalone-check
bash /home/runner/example-standalone-check/example_test.sh --version 1.0.0 --variant base \
  --results-dir /home/runner/example-results/standalone-check
```

第一条命令仅适用于尚未实现调优构建的情况，预期非零退出；调优构建完成后应改为验证其真实产物与独立结果目录。基础版成功后，检查指定结果目录至少包含：

| 文件 | 核对内容 |
|---|---|
| `build_variant.json` | `variant` 和 `parameters.variant` 都是 `base`。 |
| `benchmark_raw.txt` | 完整 benchmark 原始输出，非空。 |
| `benchmark.json` | 指标非空，名称、值、单位可追溯至原始输出。 |
| `results.json`、`report.md` | 独立入口生成的状态、指标和单架构报告。 |

随后分别在 x86_64、aarch64 上执行同版本正式任务，核对：

- 两个架构的实际产物版本和完整原始输出。
- `build_variant.json` 与选择一致；基础版和调优版结果路径不混用。
- `case.yaml` 声明的结果、指标单位、固定参数和实际并发度。
- 双架构报告是否只对齐同一测试项。
- 失败测试后的服务退出状态和私有工作目录清理结果。
