# BoostKit Performance Evaluation

面向 x86_64 与 aarch64 的开源软件性能测试 Workflow。软件清单由人工维护，唯一的手动 GitHub Actions Workflow 负责双架构执行、环境清理、结果聚合与对比报告。

## 入口

- 实施设计：`WORKFLOW_IMPLEMENTATION_PLAN.md`
- 软件用例：`software/<category>/<software>/`
- 公共框架：`framework/`
- 公共配置：`config/`
- 手动 Workflow：`.github/workflows/performance-test.yml`

## 本地检查

```bash
python3 -m pip install "PyYAML>=6.0,<7.0" "pytest>=8.0,<9.0"
python3 framework/validate_case.py --all
python3 framework/generate_matrix.py --software all --version all --architecture all
python3 -m pytest framework/verification
```

当前接入 Redis 一个软件，配置 `7.4.10`、`8.0.0` 和 `8.0.6` 三个版本。默认矩阵为三个版本分别运行 x86_64 与 aarch64，共 6 个正式任务。

每个矩阵任务由 Workflow 显式编排：准备环境、裸机构建安装、校验安装结果、启动服务、执行性能测试、停止服务、收集并标准化报告、全局清理。各软件入口实现同一套分阶段接口，Workflow 不包含软件名称判断。

正式性能测试只允许在专用 Runner 上通过 `workflow_dispatch` 手动启动。

## Runner 标签

Runner 标签只在 `config/defaults.yaml` 中维护，当前映射为：

- x86_64 使用 `PERF_RUNNER_X86_64`。
- aarch64 使用 `PERF_RUNNER_ARM64`。

矩阵生成器读取该配置，Workflow 只消费 `matrix.runner_label`，不存在第二份标签硬编码。无需配置 GitHub Actions Variables。手动触发时 `architecture=all` 是默认值，会同时生成两种架构任务；选择单个架构时只使用对应标签。

Runner 必须是专用裸机，预装 Python 3.11+、PyYAML 6.x 和软件清单明确要求的编译依赖。性能任务直接在裸机编译安装，禁止测试脚本在任务期间通过 apt/dnf 或系统级 pip 改写宿主机。源码、安装前缀、缓存、数据和构建目录均必须放入 `/tmp/boostkit-perf`，任务前后执行全局清理与验收。

## 当前阶段边界

当前只接入 `software/Database/redis`。Redis 用例由 `/root/redis` 的已有代码人工适配，不复制历史结果，也不提供测试用例生成器。Workflow 直接执行唯一一套正式参数。
