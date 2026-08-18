# 已有测试脚本接入指南

本文只说明如何把已经存在的测试脚本适配成可独立执行、也可接入 BoostKit Performance Evaluation 的软件测试单元。现有脚本是接入起点，不自动视为正确标准；构建方法、性能命令、负载、指标和结果算法必须先经过评审，只有确认有效的部分才原样保留。

测试脚本从零开发、负载选择、命令设计和指标算法设计后续单独维护在 `doc/TEST_SCRIPT_DEVELOPMENT.md`，不与本指南混在一起。

## 适用前提

开始接入前，应当已经具备可以在裸机上完成下列工作的脚本或命令：

- 获取指定版本源码并构建或安装到任务私有目录；
- 启动软件并判断服务是否真正可用，或者为无服务软件准备测试运行时；
- 执行正式性能测试并产生可解析结果；
- 停止服务和释放软件私有资源。

如果现有脚本缺少测试命令、不能产生稳定结果或指标含义尚未确定，应先完成评审。评审认定原性能测试核心不准确时，允许在接入中替换为官方、可复现且已确认的测试实现；不能为了形式上的“原脚本不动”继续使用错误负载或错误指标。

## 接入原则

1. 先审查后保留。版本选择、构建参数、测试负载和指标中已经确认有效的部分保持不变；不准确、不稳定或不可复现的性能核心必须替换并记录差异。
2. 独立执行和 Framework 必须共用同一套构建、运行时准备、性能测试和停止函数，禁止维护两套测试实现。
3. 软件向 Framework 暴露 build、start、test、stop，并保留可独立执行的受保护主入口；独立入口负责本地环境采集、结果校验、报告和私有资源清理。
4. 整个软件目录复制到其他机器后仍应能够完成单机测试，不得反向依赖项目根目录下的 Framework 文件。
5. Framework 只按 `case.yaml` 的通用契约编排，不在 Workflow 或 Framework 中增加按软件名称判断的分支。
6. 所有版本默认在 x86_64 和 aarch64 上执行，软件清单不维护架构或 Runner 标签。

现有参考：

| 软件形态 | 参考目录 | 重点参考内容 |
|---|---|---|
| 有后台服务 | `software/Database/redis` | 服务就绪检查、PID 管理、测试前复验和幂等停止。 |
| 无后台服务的库或工具 | `software/HPC/lz4` | 数据准备、基准入口校验和无服务收口。 |

## 第一步：盘点现有脚本

接入前先记录现有脚本各部分的职责和评审结论，不要不经判断地全部保留或全部重写：

| 现有行为 | 目标阶段 | 适配要求 |
|---|---|---|
| 下载源码、选择版本、编译、安装、产物校验 | build | 保留已经确认的官方命令和必要参数；移除系统级安装、复用未知系统产物等污染行为，输出进入任务私有目录，并从真实产物报告版本。 |
| 启动服务、生成配置、准备数据集、等待就绪 | start | 服务型软件必须等待可用；无服务软件在此准备测试数据和运行时。 |
| 执行性能命令、重复运行、聚合原始结果 | test | 保留已审核负载；未审核或已确认不准确的核心替换为官方、可复现方案。等待全部测试结束，并把必要结果交付到 `RESULTS_DIR`。 |
| 关闭服务、等待退出、释放 socket/PID 等资源 | stop | 必须幂等，能够处理未启动、部分启动、已经退出和重复调用。 |

盘点结果分为三类：

- 确认保留：经过评审的官方构建方式、有效测试参数、已有结果解析和一键入口行为；
- 必须适配：四阶段边界、私有路径、实际版本报告、结构化输出、source 安全和失败清理；
- 允许替换：不准确的自定义性能程序、硬编码环境、固定机器阈值、静默忽略失败、系统级安装和不可复现数据。

如果原脚本是一个从构建一直执行到测试结束的单体入口，应按上述边界拆出四个可独立调用的入口，再由受保护的 `main()` 重新编排同一组函数。无法明确拆分服务生命周期的脚本不能直接接入。

## 第二步：注册软件并创建目录

在 `config/categories.yaml` 的目标分类下登记软件。空分类保持空值，不写 `[]`：

```yaml
categories:
  Database:
    - redis
    - example
```

目录结构：

```text
software/<category>/<software>/
├── case.yaml
├── <software>_test.sh
└── scripts/                 # 软件私有基准、独立环境采集和结果处理工具
```

注册时必须满足：

- 软件名全局唯一，只能属于一个分类；
- 注册名、软件目录名和 `case.yaml` 的 `name` 完全一致；
- 分类名、上一级目录名和 `case.yaml` 的 `category` 完全一致；
- 注册项与实际 `case.yaml` 双向一致；
- 不在软件目录中增加自己的 README，公共接入规则只维护在本文。
- `<software>_test.sh` 直接执行时必须完成构建、运行时准备、测试、停止、必要信息采集、结果校验、报告生成和私有资源清理；被 Framework 加载时只能定义变量和函数。

## 第三步：声明 `case.yaml`

完整模板：

```yaml
name: example
category: Database
enabled: true
versions:
  - "1.0.0"

execution:
  type: shell-functions
  stages:
    build:
      script: example_test.sh
      function: build_example
    start:
      script: example_test.sh
      function: start_example_service
    test:
      script: example_test.sh
      function: run_example_benchmarks
    stop:
      script: example_test.sh
      function: stop_example_service
  timeout_minutes: 180

outputs:
  benchmark_result:
    path: benchmark.json
    stage: test
    format: json
    required: true

metrics:
  source: benchmark_result
  definitions:
    throughput:
      path: benchmark.throughput
      unit: ops/s
      direction: higher_is_better
    latency:
      path: benchmark.latency_ms
      unit: ms
      direction: lower_is_better
```

### 身份和版本

| 字段 | 要求 |
|---|---|
| `name` | 非空软件名，等于目录名和注册名。 |
| `category` | 使用 `config/categories.yaml` 中的分类，并等于目录分类。 |
| `enabled` | 使用 YAML 布尔值；`true` 才进入矩阵。 |
| `versions` | 非空且不重复的字符串列表；必须能与实际构建产物报告的版本逐字匹配。 |

禁止在软件清单中声明 `architectures`、`runner` 或 `runner_label`。所有启用的软件默认展开到 x86_64 和 aarch64；Runner 标签只由 `config/defaults.yaml` 维护。

### 四阶段入口

`execution.type` 只能是 `shell-functions`。`execution.stages` 必须完整且只能包含 build、start、test、stop，每个阶段只能声明：

- `script`：软件目录内已经存在的相对 `.sh` 路径，不能使用绝对路径或 `..`；
- `function`：脚本被加载后能够通过 `declare -F` 找到的合法 Shell 函数名。

四个阶段可以映射到同一个适配脚本，也可以映射到不同脚本。`timeout_minutes` 必须是正整数。

阶段键是固定接口，函数名不是固定接口。函数名应体现软件和职责，例如 `start_example_service`，不要使用难以辨认的 `start`。

### 输出声明

`outputs` 的键是逻辑名称，必须以小写字母开头，只包含小写字母、数字和下划线。每个输出必须声明：

| 字段 | 要求 |
|---|---|
| `path` | `RESULTS_DIR` 下的相对路径，不得为绝对路径、包含 `..` 或与其他输出重复。 |
| `stage` | 实际产生文件的 build、start、test 或 stop 阶段。 |
| `format` | `json`、`text` 或 `binary`；JSON 路径必须以 `.json` 结尾。 |
| `required` | 明确写 `true` 或 `false`。 |

阶段函数返回 0 后，Framework 会立即校验归属于该阶段的输出。必要文件必须存在且非空；JSON 必须合法且根节点为对象。可选文件不存在不会失败，但一旦存在也必须有效。

下列文件由 Framework 在 workflow 模式生成，软件阶段函数不得重复声明或覆盖：

- `build_info.json`；
- `system_info.json`；
- `runtime_before.json`、`runtime_after.json`；
- `status.json`、`normalized_result.json`；
- Markdown、JUnit、跨架构对比和永久历史。

软件独立执行时可以在自己的持久化结果目录生成同名的单机信息和报告文件，但这些逻辑只能由受保护的独立主入口调用，不能在 Framework 的 build、start、test、stop 函数中重复执行。

### 指标声明

`metrics.source` 引用输出逻辑名称，不是文件路径。指标使用 `definitions` 或 `collection` 两种声明方式，二者只能选择一种。

固定指标使用 `definitions`，每个指标必须声明：

- `path`：指标在 JSON 中的点路径；字段可以位于任意层级，不要求名为 `summary`；
- `unit`：非空单位；
- `direction`：`higher_is_better`、`lower_is_better` 或 `neutral`。

单个指标可以用自己的 `source` 覆盖默认来源。指标来源必须是 `required: true` 的 JSON 输出。指标值必须是有限数值；字符串、布尔值、`null`、NaN 和 Infinity 都会失败。

同类指标数量由测试程序决定时使用 `collection`：

```yaml
metrics:
  source: benchmark_result
  collection:
    path: results
    name_path: scenario
    value_path: speed_mbs
    unit: MB/s
    direction: higher_is_better
```

- `path` 指向一个非空 JSON 对象，对象中的每个成员都会生成一个指标；
- `name_path` 指向成员内部的指标名称；省略时使用成员键名；
- `value_path` 指向成员内部的数值；
- `unit` 和 `direction` 应适用于集合中的全部成员。

Framework 会保持集合原有顺序，拒绝空集合、重复名称、缺失路径和非有限数值，并要求同一版本的两个架构产生完全一致的指标集合后才生成跨架构对比。

## 第四步：把已有脚本暴露为四个函数

Framework 的调用链是：

```text
Workflow 传入阶段名
  → Framework 读取 case.yaml
  → source 对应 Shell 脚本
  → 校验声明函数存在
  → 调用该函数并等待正常退出
  → 校验该阶段输出
```

适配优先级如下：

1. 原脚本已经有审核通过的独立函数：保留函数内部核心命令，只增加符合职责的公开函数名并在 `case.yaml` 映射。
2. 原脚本通过参数分发阶段：可以保留分发入口，但必须额外暴露四个 source-safe 函数供 `case.yaml` 直接映射。
3. 原脚本是单体流程：按 build、start、test、stop 边界拆分，由 `main()` 重新编排同一组函数。
4. 原性能核心未通过评审：先替换构建、负载、解析和指标实现，再让独立入口与 Framework 共同调用替换后的唯一实现。

适配脚本被 `source` 时只能初始化变量和定义函数，不能自动执行。允许保留一个独立 `main()`，但必须使用 `BASH_SOURCE` 保护，确保 Framework 加载脚本时不会触发完整流程：

```bash
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
```

`main()` 应直接编排同一组 build、start、test、stop 函数，不能维护另一套构建或性能测试命令。软件阶段仍由 `case.yaml` 显式映射，Framework 不通过脚本参数分发阶段。

### 独立执行要求

把单个软件目录复制到另一台符合依赖要求的机器后，下列命令必须能够运行，不需要项目根目录中的 `framework/`、`config/` 或 Workflow 文件：

```bash
./<software>_test.sh
```

独立入口必须：

- 为本次运行创建唯一工作目录，持久化结果目录与临时工作目录分离；
- 在测试前采集系统身份和运行状态，在测试后再次采集可变运行状态；
- 从真实构建产物记录软件版本；
- 严格校验性能输出和指标，禁止空结果或非数值指标成功退出；
- 生成机器可读结果、状态文件、执行日志和单机 Markdown 报告；
- 无论成功失败都执行 stop，并只清理本次创建的工作目录和进程；
- 不执行 Docker、系统缓存或其他不属于本次运行的全局清理。

独立成功运行至少保留下列内容；软件正式基准文件按 `case.yaml.outputs` 追加：

```text
results/<version>/<run-id>/
├── actual-version.txt
├── <case.yaml 声明的正式输出>
├── build_info.json
├── system_info.json
├── runtime_before.json
├── runtime_after.json
├── results.json
├── status.json
├── results.log
└── report.md
```

独立模式的 `results.json` 和 `report.md` 必须从正式基准输出严格提取指标。指标名称、来源路径、单位和优化方向必须与 `case.yaml.metrics` 一致，并通过自动化测试防止两套声明漂移。失败运行也必须尽可能保留 `status.json`、执行日志、已采集环境和失败报告。

Framework 模式仍由公共 prepare、finalize 和专用 Runner 清理负责权威结果、跨架构对比和历史保存。独立模式的本地辅助逻辑不能改变 `case.yaml` 声明的性能负载或指标语义。

示意适配方式：

```bash
build_example() {
    existing_build_entry
    report_actual_version_from_built_artifact
}

start_example_service() {
    existing_start_entry
    wait_until_existing_service_is_ready
}

run_example_benchmarks() {
    verify_existing_service_is_ready
    existing_test_entry
    convert_existing_result_if_required
}

stop_example_service() {
    existing_stop_entry_if_running
    verify_existing_service_has_stopped
}
```

以上名称表示原脚本中的既有入口或适配动作，不是可直接复制执行的命令。

### build 适配要求

- 保留已经审核确认的源码版本选择、官方构建命令和必要参数；原构建会污染系统、复用未知安装或不能证明产物版本时必须整改；
- 源码、构建树和安装前缀迁移到 `PERF_WORK_DIR`；
- 校验原脚本预期的二进制、库或包确实生成；
- 从实际产物读取版本，写入 `PERF_ACTUAL_VERSION_FILE`；
- 版本文件必须是 UTF-8、非空、无首尾空格的单行值，并与当前 `SOFTWARE_VERSION` 完全一致；
- 不允许直接把 `SOFTWARE_VERSION` 原样写入版本文件来绕过产物校验。

### start 适配要求

- 服务型软件沿用原启动命令，但配置、日志、PID、socket 和数据目录全部迁移到 `PERF_WORK_DIR`；
- 启动后执行有界轮询，只有服务真正可响应时才返回 0；
- 无服务软件把已有的数据下载、解包或运行时准备放在 start，并校验 test 所需入口已就绪；
- start 是唯一允许后台服务跨阶段存活的入口。

### test 适配要求

- 在执行正式测试命令前复验服务或运行时状态；
- 使用评审通过的测试命令、迭代次数、并发、数据规模和固定输入；原脚本中未通过评审的自定义基准或阈值不得因“最小改动”继续保留；
- 等待原测试和聚合过程全部结束后再返回；
- 在函数返回前生成 `case.yaml` 声明的必要输出；
- 不在软件脚本中生成通用 Markdown、跨架构对比或永久历史。

### stop 适配要求

- 沿用原停止方式并等待服务确实退出；
- 能处理未启动、启动到一半、已经退出和重复调用；
- PID 文件存在时校验 PID 合法，不能误杀无关进程；
- stop 完成后确认端口、进程或其他软件资源已释放；
- stop 不负责删除整个 `/tmp/boostkit-perf`，全局删除由 Framework cleanup 完成。

## 第五步：使用 Framework 路径和环境变量

| 变量 | 适配用途 |
|---|---|
| `SOFTWARE_VERSION` | 当前矩阵请求版本。 |
| `EXPECTED_ARCH` | 当前期望架构：x86_64 或 aarch64。 |
| `RESULTS_DIR` | 声明输出的交付目录。 |
| `PERF_WORK_DIR` | 本次软件、版本、架构的隔离工作目录。 |
| `PERF_RUN_ID` | 当前运行编号。 |
| `PERF_PROCESS_TOKEN` | 子进程继承的隔离标识，供清理程序识别。 |
| `PERF_ACTUAL_VERSION_FILE` | build 报告实际版本的 Framework 保留路径。 |
| `TMPDIR` | 任务私有临时目录。 |
| `PIP_CACHE_DIR` | 任务私有 pip 缓存目录。 |
| `XDG_CACHE_HOME` | 任务私有通用缓存目录。 |
| `CARGO_HOME` | 任务私有 Cargo 目录。 |
| `CCACHE_DIR` | 任务私有 ccache 目录。 |

源码、构建、安装、服务数据、测试数据、PID、socket、下载和软件缓存全部迁移到 `PERF_WORK_DIR`；交付结果写入 `RESULTS_DIR`。不得通过 apt、dnf、系统级 pip 或系统目录下的 `make install` 永久修改 Runner。

Workflow 模式下，CPU、OS、内核、Python、GCC、glibc、NUMA、内存和 CPU governor 由 Framework 统一采集，四阶段函数不得重复生成这些公共文件。CPU 型号的唯一采集入口是 `/usr/bin/sudo -n /usr/bin/env LC_ALL=C /usr/bin/lscpu`；性能 Runner 必须按根 README 配置该命令的最小 sudoers 权限。独立模式必须在软件目录内提供等价的本地采集能力，目标机器也必须满足同一权限前置条件；该能力只能由受保护的 `main()` 调用，不能依赖项目根目录中的 Framework 模块。

## 第六步：适配已有结果

如果原脚本已经生成合法 JSON，可以直接声明为 output，并用点路径提取指标。JSON 中指标字段名没有统一要求，例如 `summary.qps`、`benchmark.throughput` 和 `results.latency.p99` 都可以。

如果正式测试实现只生成文本：

1. 保留正式性能命令和原始文本；
2. 在 test 阶段末尾调用薄转换层，把原始结果严格转换为 JSON；
3. 转换失败、匹配数量异常或数值非法时直接失败，不能填 0 或复用旧结果；
4. 将转换后的必要 JSON 作为指标来源，原始文本可作为普通 Artifact 输出。

推荐结果结构：

```json
{
  "parameters": {
    "iterations": 3,
    "dataset_sha256": "固定数据集摘要"
  },
  "runtime_context": {
    "resolved_worker_count": 64
  },
  "benchmark": {
    "throughput": 12345.6,
    "latency_ms": 0.82
  }
}
```

- `parameters` 记录两个架构必须一致的既有测试方案和固定输入；
- CPU 核数推导值等机器相关信息放入 `runtime_context`；
- 固定测试参数仍由原脚本维护，不在 `case.yaml` 再复制一份；
- 两个架构的 `parameters` 不一致时，Framework 拒绝生成跨架构对比；
- `parameters`、`runtime_context` 之外的结果字段名由软件决定，指标位置以 `case.yaml` 为准。

## 第七步：验证适配结果

对 `case.yaml` 声明的全部 Shell 脚本执行语法检查，然后运行公共验证：

```bash
bash -n software/<category>/<software>/<declared-script>.sh

python3 framework/catalog.py validate

python3 framework/catalog.py matrix \
  --software <software> \
  --version all \
  --architecture all \
  --pretty

python3 -m pytest framework/tests
```

矩阵中每个声明版本都应出现 x86_64 和 aarch64 两条记录。辅助 Python 转换程序还应执行语法检查和已有结果样例测试。

还必须验证软件目录自包含：把整个 `software/<category>/<software>` 复制到项目之外的临时位置，从复制后的目录直接执行入口，确认没有导入或调用项目根目录中的 `framework/`、`config/`、Workflow 或其他软件文件。成功和失败路径都要验证结果留存以及私有工作目录清理。

Actions 手动验证顺序：

1. 单软件、单版本、单架构；
2. 同版本的另一个架构；
3. `architecture=all`，确认参数和指标可以跨架构对比；
4. 该软件的全部版本；
5. 默认全量矩阵。

首次接入验证不更新 Baseline。只有双架构结果经过人工确认后，才单独手动更新。

## 常见适配问题

| 现象 | 原因 | 处理方式 |
|---|---|---|
| 注册项或 `case.yaml` 缺失 | 注册表、分类、目录或名称不一致。 | 统一 `config/categories.yaml`、目录和清单身份。 |
| 声明函数不存在 | 入口名不一致，或 source 脚本时函数未定义。 | 保证适配脚本只初始化变量和定义公开函数。 |
| build 未报告实际版本 | 仍沿用原构建流程但没有接 Framework 版本接口。 | 从真实产物解析并写 `PERF_ACTUAL_VERSION_FILE`。 |
| 请求版本与实际版本不同 | 标签、解析格式或版本前缀不一致。 | 修正版本选择或规范化解析，不要直接回写请求值。 |
| 必要输出缺失或为空 | 原脚本仍写旧目录，或聚合尚未结束函数就退出。 | 把交付文件迁移到 `RESULTS_DIR` 并等待完成。 |
| 指标路径不存在 | `case.yaml` 与实际 JSON 层级不一致。 | 以真实结果 JSON 为准修正点路径。 |
| 指标不是有限数值 | 文本转换宽松，产生字符串、空值、NaN 或 Infinity。 | 严格解析并在异常时失败。 |
| 双架构参数不一致 | 把 CPU 数量等机器值写入 `parameters`。 | 机器相关解析值迁移到 `runtime_context`。 |
| start 成功但 test 连接失败 | 原脚本启动后立即返回，没有就绪检查。 | 保留启动命令并增加有界就绪轮询。 |
| stop 或 cleanup 失败 | 停止入口不幂等，或仍有进程引用工作目录。 | 修正 PID/进程管理并确认资源释放。 |
| 直接执行脚本没有结果 | 脚本只定义四阶段函数，没有受保护的 `main()`。 | 增加 source-safe 主入口，并编排与 Framework 相同的四阶段函数。 |
| 复制软件目录后不能运行 | 独立入口导入了项目根目录中的 Framework 文件。 | 把必要的采集、校验和单机报告能力放入软件自己的 `scripts/`，Framework 仅作为外部调用者。 |
| 手动结果与 Workflow 不一致 | 独立入口和 `case.yaml` 调用了不同测试实现。 | 收敛为一套阶段函数和一套指标语义，两个入口共同调用。 |

## 接入完成检查表

- [ ] 已完成原脚本盘点，明确哪些保留、哪些为接口适配、哪些因不准确或不安全而替换；
- [ ] 构建和性能测试核心已经评审，替换内容有明确原因，未盲目保留错误实现；
- [ ] 软件在唯一分类中注册，注册名、目录、`name` 和 `category` 一致；
- [ ] `case.yaml` 声明完整四阶段、正整数超时、必要输出和至少一个指标；
- [ ] 清单不包含架构、Runner 标签或 Framework 保留输出；
- [ ] 四个公开函数可被 source，并等待各自阶段真正完成；
- [ ] 直接执行入口能够编排同一组四阶段函数，完整生成结果、日志、状态和单机报告；
- [ ] 把软件目录复制到项目之外后仍可独立运行，不依赖根目录 Framework；
- [ ] build 从真实产物报告与请求值一致的版本；
- [ ] start 等待就绪，stop 对异常和重复调用保持幂等；
- [ ] 所有运行资源迁移到 `PERF_WORK_DIR`，交付结果迁移到 `RESULTS_DIR`；
- [ ] 原始结果已直接声明或通过薄转换层生成严格 JSON；
- [ ] 固定输入写入 `parameters`，机器相关值写入 `runtime_context`；
- [ ] 指标路径、单位、优化方向和数值类型与实际结果一致；
- [ ] Shell、Catalog、矩阵、Framework 测试和分阶段 Actions 验证全部通过。
- [ ] 独立成功和失败路径都执行 stop，且只清理本次创建的私有工作目录和进程。
