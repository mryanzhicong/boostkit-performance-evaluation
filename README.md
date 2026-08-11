# BoostKit Performance Evaluation

面向 x86_64 与 aarch64 的开源软件性能测试 Workflow。当前阶段复用已有测试用例，通过手工维护的 `case.yaml` 和唯一的手动 GitHub Actions Workflow 完成双架构执行、环境清理、结果聚合与对比报告。

## 入口

- 实施设计：`WORKFLOW_IMPLEMENTATION_PLAN.md`
- 软件用例：`software/<category>/<software>/`
- 公共框架：`framework/`
- 公共配置：`config/`
- 手动 Workflow：`.github/workflows/performance-test.yml`

## 本地检查

```bash
uv sync --frozen
uv run python framework/validate_case.py --all
uv run python framework/generate_matrix.py --software all --version all --architecture all --test-mode smoke
uv run pytest framework/verification
```

正式性能测试只允许在专用 Runner 上通过 `workflow_dispatch` 手动启动。

## Runner 标签

Runner 标签只在 `config/defaults.yaml` 中维护，当前映射为：

- x86_64 使用 `PERF_RUNNER_X86_64`。
- aarch64 使用 `PERF_RUNNER_ARM64`。

矩阵生成器读取该配置，Workflow 只消费 `matrix.runner_label`，不存在第二份标签硬编码。无需配置 GitHub Actions Variables。手动触发时 `architecture=all` 是默认值，会同时生成两种架构任务；选择单个架构时只使用对应标签。

Runner 必须是专用机器，推荐由只读金镜像按任务临时创建。金镜像需预装 Docker、Python 3、C/C++ 工具链及当前 7 个用例所需的系统开发库；Workflow 禁止测试脚本通过 apt/dnf 或系统级 pip 改写宿主机。Python 包、缓存和构建目录均放入 `/tmp/boostkit-perf`，任务前后执行全局清理与验收。

## 当前阶段边界

当前只接入已有的 Faiss、hnswlib、OpenViking、PETSc、Protobuf、Rust 和 Snappy 用例。`case.yaml` 由人工维护，没有测试用例生成器；历史示例目录不进入正式 Workflow，也不作为任何代码路径依赖。
