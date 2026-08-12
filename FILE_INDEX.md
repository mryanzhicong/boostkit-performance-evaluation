# 文件用途索引

本文档覆盖正式目录中的所有文件角色。临时迁移源目录不属于正式实现，Workflow 和框架均不引用它。

## `./`

| 文件 | 用途 |
|---|---|
| `README.md` | 项目入口、正式目录和本地验证命令。 |
| `WORKFLOW_IMPLEMENTATION_PLAN.md` | Workflow 架构、触发范围、Runner、清理、报告和演进方案。 |
| `FILE_INDEX.md` | 正式目录内所有文件的用途索引。 |
| `pyproject.toml` | Python 版本、运行依赖、开发依赖及测试配置。 |
| `.gitignore` | 排除运行产物、缓存、历史结果和临时示例目录。 |

## `.github/workflows/`

| 文件 | 用途 |
|---|---|
| `performance-test.yml` | 唯一入口；只支持 `workflow_dispatch`，校验输入、展开双架构矩阵、选择 Runner、前后全局清理、执行启用用例、汇总报告，并把成功结果发布到 `performance-results` 分支。 |

## `config/`

| 文件 | 用途 |
|---|---|
| `categories.yaml` | 软件分类白名单，防止目录分类自由扩散。 |
| `defaults.yaml` | 两种默认架构、架构到 Runner 标签的唯一映射以及输出和工作根目录。 |

## `framework/`

| 文件 | 用途 |
|---|---|
| `validate_case.py` | 校验人工维护的 `case.yaml`，同时禁止 Runner 标签和架构写入软件清单。 |
| `generate_matrix.py` | 按手动输入筛选软件、版本和架构；`all` 默认生成 x86_64 与 aarch64 两组正式任务。 |
| `context.py` | 定义单个软件、版本、架构任务的不可变运行上下文。 |
| `adapter_base.py` | 保留的扩展接口定义；当前 staged command 流程不加载软件专用适配器。 |
| `command_adapter.py` | 通用分阶段命令适配器；实时输出并保存阶段日志，等待正常退出，超时或中断时终止整个子进程组，最终阶段检查预期输出。 |
| `run_case.py` | 单任务阶段控制器；处理 prepare/build/validate/start-service/test/stop-service/collect-report 状态、环境采集和结果标准化。 |
| `cleanup_environment.sh` | 专用裸机 Runner 全局清理及二次验证；清理统一工作根目录、关联进程和挂载点。 |
| `process_scanner.py` | 扫描 `/proc` 定位真正引用工作根目录的残留进程，并排除扫描器自身，供全局清理使用。 |
| `mark_cleanup.py` | 把 Workflow 的后置清理结果回写到任务状态和规范化结果；清理失败使用退出码 80。 |
| `collect_environment.py` | 采集测试前后的 OS、CPU、内存、内核等环境快照。 |
| `aggregate_results.py` | 把现有脚本的 `results.json` 等结果转换成统一指标模型。 |
| `generate_comparison.py` | 配对参数一致的 x86_64/aarch64 结果，在汇总中保留各架构指标，并生成跨架构结果、汇总和 JUnit。 |
| `prepare_result_history.py` | 从架构 Artifact 中提取最终 JSON、文本指标和报告，生成不可变的精简运行历史；仅在双架构成功且显式请求时生成受控基线。构建日志不会进入永久历史。 |
| `publish_result_history.sh` | 把准备好的精简结果提交并推送到独立 `performance-results` 分支，使性能历史不进入主分支，也不依赖 Artifact 保留期限。 |
| `json_helper.py` | JSON 读取、原子写入和点路径取值的公共函数。 |
| `reporting/single_report.py` | 生成单架构 Markdown 报告，并显示指标优化方向。 |
| `reporting/comparison_report.py` | 生成跨架构 Markdown 对比，说明越大越好、越小越好、目标型和仅展示指标。 |
| `reporting/summary_report.py` | 生成整次手动运行的任务状态、单架构指标和跨架构指标汇总。 |
| `reporting/junit_report.py` | 生成供 CI 页面或外部系统消费的 JUnit XML。 |
| `schemas/case.schema.json` | 软件清单数据结构定义。 |
| `schemas/result.schema.json` | 统一结果数据结构定义。 |
| `schemas/environment.schema.json` | 环境快照数据结构定义。 |
| `schemas/status.schema.json` | 任务阶段与失败状态数据结构定义。 |

## `software/`

当前接入 `Database/redis`，其他分类只保留目录结构。每个软件目录均由人工维护，不由 Workflow 自动生成。

| 文件或文件模式 | 用途 |
|---|---|
| `README.md` | 说明分类白名单、未来软件目录结构及人工接入规则。 |
| `<分类>/.gitkeep` | 保存空分类目录；Database 已有 Redis，因此不需要该占位文件。 |
| `<分类>/<软件>/case.yaml` | 声明软件版本、staged command 入口、正式参数、预期输出和指标方向；不得声明架构或 Runner。 |
| `<分类>/<软件>/<software>_test.sh` | 实现 build、validate、start-service、test、stop-service、collect-report 分阶段函数，并接收公共运行上下文。 |
| `<分类>/<软件>/scripts/` | 可选的软件私有基准、结果转换和辅助程序；没有需要时不创建。 |
| `<分类>/<软件>/results/` | 本地兼容输出目录；不纳入版本库，正式 Workflow 写入根目录 `.perf-output/`。 |

## `software/Database/redis/`

| 文件 | 用途 |
|---|---|
| `README.md` | 说明 Redis 用例来源、测试范围、Runner 编译依赖、源码地址配置和指标方向。 |
| `case.yaml` | 配置 Redis 7.4.10、8.0.0、8.0.6 的正式参数、输出和报告指标。 |
| `redis_test.sh` | 将原 Redis 测试脚本拆成 Workflow 调用的六个阶段函数；保留原始 Make 参数和源码树二进制用法，负责校验、服务生命周期、测试和软件级报告。 |
| `scripts/write_version_info.py` | 记录实际 Redis 版本、架构及运行环境。 |
| `scripts/benchmark_redis.py` | 执行 Redis 命令与多并发组合的主性能基准。 |
| `scripts/micro_benchmark.py` | 执行数据大小、客户端并发和持久化模式微基准。 |
| `scripts/aggregate_results.py` | 聚合原始结果并计算 QPS、延迟及客户端并发扩展指标。 |
| `scripts/generate_summary.py` | 生成包含指标优化方向的 Redis 文本摘要。 |

## `framework/verification/`

| 文件 | 用途 |
|---|---|
| `conftest.py` | 将脚本式 `framework/` 模块加入测试导入路径。 |
| `test_cases_and_matrix.py` | 验证 Redis 清单、默认 6 任务矩阵、手动过滤、双架构 Runner 映射和完整分阶段 Workflow。 |
| `test_command_adapter.py` | 验证已有脚本通过环境变量接入公共输出目录。 |
| `test_results_and_reports.py` | 验证旧结果规范化、单架构指标展示、指标方向语义、跨架构报告配对、永久历史和基线更新约束。 |

当前阶段没有用例生成器或模板文件；至少一个人工维护的用例在正式 Runner 上稳定运行后再单独评审是否需要。
