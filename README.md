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

每个矩阵任务由 Workflow 显式编排：Framework 准备环境，软件依次执行 build、start、test、stop 四个阶段，Framework 再统一校验结果、提取指标、生成报告并执行全局清理。构建后的版本和二进制校验属于 build，软件级结果聚合属于 test；Workflow 不包含软件名称判断。

同一矩阵任务内的阶段严格串行：阶段命令及其输出转发全部结束后才进入下一步。stdout/stderr 实时显示在 Actions 控制台并同时保存为 `command-<stage>.log`；超时或中断会终止整个阶段进程组。只有 `start` 启动并通过就绪检查的被测服务允许保留到后续测试阶段，`stop` 在失败路径中也会执行。

软件 `test` 必须生成清单声明的非空结果文件。Framework `finalize` 负责统一检查 JSON 格式、指标路径、数值类型和有限性；缺失、空文件、`null`、字符串、NaN 或 Infinity 指标都会使任务失败。所有软件进程继承运行隔离标识，清理器同时扫描进程环境、命令行、cwd、exe 和文件描述符，防止后台服务逃逸清理范围。

正式性能测试只允许在专用 Runner 上通过 `workflow_dispatch` 手动启动。

## Runner 标签

Runner 标签只在 `config/defaults.yaml` 中维护，当前映射为：

- x86_64 使用 `PERF_RUNNER_X86_64`。
- aarch64 使用 `PERF_RUNNER_ARM64`。

矩阵生成器读取该配置，Workflow 只消费 `matrix.runner_label`，不存在第二份标签硬编码。无需配置 GitHub Actions Variables。手动触发时 `architecture=all` 是默认值，会同时生成两种架构任务；选择单个架构时只使用对应标签。

Runner 必须是专用裸机，预装 Python 3.11+、PyYAML 6.x 和软件清单明确要求的编译依赖。性能任务直接在裸机编译安装，禁止测试脚本在任务期间通过 apt/dnf 或系统级 pip 改写宿主机。源码、安装前缀、缓存、数据和构建目录均必须放入 `/tmp/boostkit-perf`，任务前后执行全局清理与验收。

## 当前阶段边界

当前只接入 `software/Database/redis`。Redis 用例由 `/root/redis` 的已有代码人工适配，不复制历史结果，也不提供测试用例生成器。Workflow 直接执行唯一一套正式参数。

## 性能数据保存位置

每次手动运行期间，框架先把中间结果写入 Runner 的 `.perf-output/` 目录。该目录只是本次任务的临时工作区，不作为长期存储。

运行成功后，Workflow 会通过三种方式保存结果：

- Workflow Summary：直接查看单架构指标和跨架构对比；
- GitHub Actions Artifact：保存完整原始结果，架构结果保留 30 天，汇总报告保留 90 天；
- `performance-results` 独立分支：永久保存精简后的最终指标、报告和运行元数据，不把性能历史混入主分支。

`performance-results` 分支按以下结构保存：

```text
.
└── <category>/<software>/<version>/
    ├── baseline.json
    └── <run_id>-<attempt>/
        ├── manifest.json
        ├── combined-report.md
        ├── x86_64/
        │   ├── normalized_result.json
        │   ├── report.md
        │   └── results.txt
        ├── aarch64/
        │   ├── normalized_result.json
        │   ├── report.md
        │   └── results.txt
        ├── comparison.json
        └── comparison.md
```

其中 `<run_id>-<attempt>` 与 GitHub Actions 运行及重试次数一一对应，历史目录不可覆盖。构建日志等大文件不提交到结果分支，仍从 Artifact 查看。手动选择 `update_baseline=true` 时，只有 x86_64 和 aarch64 两个架构都成功且清理校验通过，才会更新该版本的 `baseline.json`；单架构运行不会更新基线。
