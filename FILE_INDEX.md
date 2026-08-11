# 文件用途索引

本文档覆盖正式目录中的所有文件角色。临时迁移源目录不属于正式实现，Workflow 和框架均不引用它。

## `./`

| 文件 | 用途 |
|---|---|
| `README.md` | 项目入口、正式目录和本地验证命令。 |
| `WORKFLOW_IMPLEMENTATION_PLAN.md` | Workflow 架构、触发范围、Runner、清理、报告和演进方案。 |
| `FILE_INDEX.md` | 正式目录内所有文件的用途索引。 |
| `pyproject.toml` | Python 版本、运行依赖、开发依赖及测试配置。 |
| `uv.lock` | 锁定 Python 依赖，保证控制节点与两种架构安装相同版本。 |
| `.gitignore` | 排除运行产物、缓存、历史结果和临时示例目录。 |

## `.github/workflows/`

| 文件 | 用途 |
|---|---|
| `performance-test.yml` | 唯一入口；只支持 `workflow_dispatch`，校验输入、展开双架构矩阵、选择 Runner、前后全局清理、执行现有用例并汇总报告。 |

## `config/`

| 文件 | 用途 |
|---|---|
| `categories.yaml` | 软件分类白名单，防止目录分类自由扩散。 |
| `defaults.yaml` | 两种默认架构、架构到 Runner 标签的唯一映射、输出/工作根目录和模式超时。 |

## `framework/`

| 文件 | 用途 |
|---|---|
| `validate_case.py` | 校验人工维护的 `case.yaml`，同时禁止 Runner 标签和架构写入软件清单。 |
| `generate_matrix.py` | 按手动输入筛选软件/版本/架构/模式；`all` 默认生成 x86_64 与 aarch64 两组任务。 |
| `context.py` | 定义单个软件、版本、架构任务的不可变运行上下文。 |
| `adapter_base.py` | 为少数无法直接调用的未来用例定义可选适配器接口；当前 7 个用例不需要。 |
| `command_adapter.py` | 通用命令适配器；通过环境变量调用现有测试脚本并检查预期输出。 |
| `run_case.py` | 单任务总控；校验架构、采集环境、执行、规范化结果、生成单任务报告和状态。 |
| `cleanup_environment.sh` | 专用 Runner 全局清理及二次验证；清理所有 Docker 资源和已知用例临时目录。 |
| `process_scanner.py` | 扫描 `/proc` 定位真正引用工作根目录的残留进程，并排除扫描器自身，供全局清理使用。 |
| `mark_cleanup.py` | 把 Workflow 的后置清理结果回写到任务状态和规范化结果；清理失败使用退出码 80。 |
| `collect_environment.py` | 采集测试前后的 OS、CPU、内存、内核等环境快照。 |
| `aggregate_results.py` | 把现有脚本的 `results.json` 等结果转换成统一指标模型。 |
| `generate_comparison.py` | 配对参数一致的 x86_64/aarch64 结果，生成跨架构结果、汇总和 JUnit。 |
| `json_helper.py` | JSON 读取、原子写入和点路径取值的公共函数。 |
| `reporting/single_report.py` | 生成单架构 Markdown 报告，并显示指标优化方向。 |
| `reporting/comparison_report.py` | 生成跨架构 Markdown 对比，说明越大越好、越小越好、目标型和仅展示指标。 |
| `reporting/summary_report.py` | 生成整次手动运行的任务状态汇总。 |
| `reporting/junit_report.py` | 生成供 CI 页面或外部系统消费的 JUnit XML。 |
| `schemas/case.schema.json` | 软件清单数据结构定义。 |
| `schemas/result.schema.json` | 统一结果数据结构定义。 |
| `schemas/environment.schema.json` | 环境快照数据结构定义。 |
| `schemas/status.schema.json` | 任务阶段与失败状态数据结构定义。 |

## `software/<分类>/<软件>/`

每个软件目录均人工维护，不由 Workflow 自动生成。当前分类映射为：`faiss`、`hnswlib`、`openviking` 属于 `AI`，`petsc` 属于 `HPC`，`protobuf` 属于 `Middleware`，`rust` 属于 `Toolchain`，`snappy` 属于 `Others`。

| 文件或文件模式 | 用途 |
|---|---|
| `case.yaml` | 声明软件版本、已有脚本入口、smoke/full 参数、预期输出和指标方向；不得声明架构或 Runner。 |
| `<software>_test.sh` | 当前已有的安装、基准测试和 shUnit2 验证入口；已支持外部 `RESULTS_DIR` 与 `EXPECTED_ARCH`。 |
| `scripts/benchmark_ann.py` | `faiss`、`hnswlib`、`protobuf` 的主要测试负载实现。 |
| `scripts/benchmark_context.py` | `openviking` 的上下文读写测试负载。 |
| `scripts/benchmark_generic.py` | `petsc` 与 `rust` 的通用命令耗时负载。 |
| `scripts/benchmark_compression.py` | `snappy` 的压缩/解压测试负载。 |
| `scripts/micro_benchmark.py` | 各软件的细粒度、并发或补充微基准测试。 |
| `scripts/aggregate_results.py` | 各软件理解自身原始输出并汇总成原有 `results.json`。 |
| `scripts/generate_summary.py` | 把原有 JSON 结果转换为便于人工阅读的文本摘要。 |
| `scripts/json_helper.py` | 原有 Shell 用例读写和断言 JSON 字段的辅助程序。 |
| `scripts/snappy_benchmark.cc` | `snappy` 专用的本地 C++ 基准程序源码。 |
| `results/` | 旧脚本本地运行时的兼容输出目录；不纳入版本库，正式 Workflow 写入根目录 `.perf-output/`。 |

## `framework/verification/`

| 文件 | 用途 |
|---|---|
| `conftest.py` | 将脚本式 `framework/` 模块加入测试导入路径。 |
| `test_cases_and_matrix.py` | 验证 7 个清单、默认双架构 28 任务和手动筛选范围。 |
| `test_command_adapter.py` | 验证已有脚本通过环境变量接入公共输出目录。 |
| `test_results_and_reports.py` | 验证旧结果规范化、指标方向语义和跨架构报告配对。 |

当前阶段没有用例生成器或模板文件；待现有用例在正式 Runner 上稳定运行后再单独设计。
