# 框架接入与结果契约

适用场景：建立目录、`case.yaml`、构建变体、阶段脚本、解析器、独立入口和 README 时阅读。字段的最终依据是仓库当前的 `doc/SOFTWARE_INTEGRATION.md` 与 `framework/catalog.py`；不要把此处示例软件名、版本或指标照抄为真实值。

## 1. 先把路径和变量接对

正式工作流逐次调用 `framework/run_case.py --stage prepare|build|start|test|stop|finalize`。`framework/command_adapter.py` 每次向阶段函数传入：

| 变量 | 正式工作流中的意义 | 脚本处理 |
|---|---|---|
| `SOFTWARE_VERSION` | 本任务选定的软件版本 | 核对支持范围和实际构建版本。 |
| `EXPECTED_ARCH` | `x86_64` 或 `aarch64` | 核对宿主机、镜像和源码包架构。 |
| `PERF_RUN_ID` | GitHub run ID 与 attempt | 参与容器名、label、端口和私有目录。 |
| `PERF_WORK_DIR` | `/home/runner/boostkit-perf/<软件>/<版本>/<架构>/<run-id>` | 放源码、构建目录、数据、服务 PID、socket、临时文件。不要自行再拼一层 run ID。 |
| `RESULTS_DIR` | `.perf-output/<分类>/<软件>/<版本>/<架构>/<run-id>` | 放 `case.yaml.outputs` 声明的原始日志和结果 JSON。 |
| `PERF_ACTUAL_VERSION_FILE` | 框架指定的实际版本文件 | 从已构建产物读取版本，再写入这里。 |
| `PERF_VARIANT` | 工作流选择的 `base`/`optimized` | 仅在 `build` 阶段分流；后续阶段复用。 |

`scripts/common.sh` 被每个阶段重新 `source`，其中的路径函数应只由上面变量决定；容器镜像名若无法稳定重算，写入 `${PERF_WORK_DIR}/container-image.txt`，下一阶段读取。独立运行可以为未传入的变量补默认值，但正式工作流传入的值必须保留。`source` 只定义变量和函数，不应立即创建容器或执行构建。

## 2. 文件和 `case.yaml`

注册位置为 `config/categories.yaml`；软件目录、`name` 与 `category` 一致。工作流如果通过下拉列表维护软件名，按用户要求更新相应工作流的选项。先检查哪些工作流是正式、Blue、开发；不要一口气把所有工作流都改了。

最小清单形态如下，`demo`、版本、指标都必须按真实对象替换：

```yaml
name: demo
category: HPC
enabled: true
versions:
  - "1.0.0"
test_tools:
  upstream_benchmark:
    version: "1.0.0"
execution:
  type: shell-functions
  stages:
    build:
      script: scripts/builders/dispatch.sh
      function: build_demo
    start:
      script: scripts/stages/start.sh
      function: start_demo_runtime
    test:
      script: scripts/stages/test.sh
      function: run_demo_benchmark
    stop:
      script: scripts/stages/stop.sh
      function: stop_demo_runtime
  timeout_minutes: 180
outputs:
  build_variant:
    path: build_variant.json
    stage: build
    format: json
    required: true
  benchmark_raw:
    path: benchmark_raw.log
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
  collection:
    path: results
    value_path: value
    unit_path: unit
    direction_path: direction
    group_path: group
```

`outputs.path` 相对 `RESULTS_DIR`。`required: true` 的文件或目录必须真实生成且非空；JSON 根节点为对象。`metrics.source` 必须指向声明的 JSON 输出。动态场景用 `collection`；固定少量指标也可用 `definitions`，参考 `software/HPC/snappy/case.yaml`。不要把不可用字段写进清单，也不要为了让清单通过制造虚构 JSON。

## 3. 构建变体与独立入口

`scripts/builders/dispatch.sh` 是唯一的 build 阶段入口。它调用 `build_demo_base` 或 `build_demo_optimized` 中的**一个**；成功后才写：

```json
{"variant":"base","parameters":{"variant":"base"}}
```

实际版本应从容器内的命令读取，例如 `docker exec <容器> <实际软件> --version`，不能仅由 `SOFTWARE_VERSION` 生成。调优构建未提供时，`optimized.sh` 必须明确非零退出，不调用基础版，也不生成成功变体文件。将来实现调优时，它须独立完成源码、依赖和构建；可共享辅助函数，但不复用上一次基础版的产物。

`<软件>_test.sh` 直接运行时接受 `--version`、`--variant`、`--results-dir`；可提供 `--keep-workdir`。它 `source` 与 Framework 相同的 `dispatch/start/test/stop`，按顺序执行，并用 EXIT trap 在失败或中断时收口。只清理由该入口创建的目录；调用者指定的 `PERF_WORK_DIR` 和 `RESULTS_DIR` 不可擅自删除。可对照 `software/AI/lance/lance_test.sh` 的 `STANDALONE_OWNS_WORK_DIR` 和清理逻辑。

## 4. 指标提取和跨架构报告

完整原始 stdout/stderr 和工具生成的报告先保存到 `RESULTS_DIR`，解析器再生成 `benchmark.json`。结果例子：

```json
{
  "parameters": {"dataset": "已核实的数据集", "requests": 100000},
  "results": {
    "场景A/throughput": {
      "value": 123.4,
      "unit": "ops/s",
      "direction": "higher_is_better",
      "group": "场景A"
    }
  }
}
```

校验指标名唯一、所有必需场景都有、数值有限且满足该工具语义。异常值不能当成功：例如 Nexmark `Cores=0`、UnixBench `Partial Index`、压测工具有请求失败但仍打印吞吐量。保留原始字段名称和换算依据；不能只取“好看”的字段。跨架构固定负载放 `parameters`；实际核数、NUMA 拓扑等机器相关事实不应伪装成相同固定参数，不同线程数应在指标身份中显式区分。对比前用 `framework/generate_comparison.py` 的行为确认可配对性，避免跑几个小时后才发现参数不一致。

在确认指标口径时，用工具的一份**真实输出**逐字段建立“原始字段 → JSON 路径 → 单位/方向 → 报告分组”映射；若输出场景随数据变化，用 collection 保留场景键。不能把自行计算的算术均值标称为官方原始字段，也不能把本应分开的 SPEC 子项、视频/码率、线程档位合并成一个指标。正式测试前用两份代表 x86_64/aarch64 的输出执行一次生成对比报告，检查相同场景能配对、机器核数等环境差异不会造成 `resolved workload parameters differ`，同时不掩盖真正负载差异。

README 以 `software/AI/lance/README.md` 为容器用例结构参考：先说明测什么和容器边界，再给真实来源/离线目录、镜像启动、构建、服务启动（如适用）、正式命令、数据准备、指标及结果位置、独立运行命令。涉及数据库部署、数据准备或客户端单独构建时，再参考 `software/Database/mysql/README.md` 的相应章节，不照搬无关的数据库流程。命令写到开发者能照着执行；原文有不适用步骤时说明原因和替代步骤。
