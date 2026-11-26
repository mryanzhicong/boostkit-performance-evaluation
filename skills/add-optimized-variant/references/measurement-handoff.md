# 测量衔接

“换源码”只是第一步。优化版必须让 `build → start → test → stop` 在**新的取点**上继续可测量，并且结果可解释、可复核。

## 1. 取点的三种形态

| 形态 | 构建阶段做什么 | 记录什么 | 典型坑 |
|---|---|---|---|
| 固定 hash | 校验 checkout 的 commit/tree | commit、tree | 方案给的 hash 不存在或需要 force-push 后重建 |
| 分支尖端 | 拉分支、确认分支名、解析 `HEAD` 与 `HEAD~1` | branch、head、head_tree、parent、parent_tree | 尖端会移动，必须记录实测 commit，报告按 commit 而非 run-id 引用 |
| tag | 解析 tag 指向的 commit 并钉住 | tag、commit、tree | 轻量 tag / annotated tag 的 `^{commit}` 解析不同 |

共同要求：

- `build_variant.json.commit` 与解析器期望值一致，且是**实际被测**的 commit；
- 记录文件（`<sw>-source.txt`）由构建阶段写、启动/测试阶段读；记录缺失时返回 30，错误信息要写明“先运行 build 阶段”；
- 校验 `<SW>_EXPECTED_TREE` 时不只看 commit，防止同名分支被强推。

## 2. 命令替换原则

只换**取点**，不换**测量内容**：

- 用例清单、`-b`/`--bench`、预热量、轮次、采样、并发保持一致；
- 换的是“测哪份源码”和“为构建这份源码所必需的适配”（环境创建、工具链、镜像）；
- 任何为了“跑得更快”而缩减采样的改动都属于缩小测试范围，必须写进 README 并经用户同意。

## 3. 工具兼容性核查（换工具/换版本时逐条确认）

以下以 asv 0.6.4 为例，换成 pytest-benchmark、hyperfine、自研 runner 时找对应机制：

1. **range 与既有环境互斥**：`asv run <range> --python=same` 在 0.6.4 直接报错 “No range spec may be specified if benchmarking in an existing environment”。优化版必须让工具自行建环境（去掉 `--python=same`），或放弃 range、直接用 `--set-commit-hash`。
2. **range 语义**：`get_hashes_from_range` 用 `git rev-list --first-parent A..B`，因此 `HEAD~1..HEAD` 只含 `HEAD` 一个提交；`HEAD~1` 仅作排除端。文档必须写清单提交语义，不能宣称测了父提交。
3. **隔离构建**：`build_command` 通常是 `python -m build --wheel`（无 `--no-isolation`），构建依赖从索引下载，且 `meson-python` 需要 PATH 上有 `patchelf` 与 `ninja`。测量 venv 里的二进制要显式装到 `/usr/local/bin`。
4. **依赖获取**：基础版为断网把代理指向 `127.0.0.1:9`；优化版测量窗口需要取包时必须撤掉黑洞并导出 `PIP_INDEX_URL`/`PIP_TRUSTED_HOST`（只对优化版，基础版保持不变）。
5. **子模块/本地克隆**：工具 checkout 时会 `git submodule update --init --recursive`，需要 `git config --global protocol.file.allow always`；GitHub 不可达时按既有镜像方案设 `url.<mirror>.insteadOf`。
6. **版本校验**：优化分支可能没有版本文件（如 master 上没有 `numpy/version.py`），改用 `import <pkg>; print(__version__)`。
7. **结果文件命名**：常见为 `<commit短哈希>-<machine>.json`；收集时按 `${EXPECTED_COMMIT:0:8}-*.json` 匹配，并校验 `commit_hash` 字段。
8. **对照点**：父提交/基线的原始记录**存在才收集**（例如同一结果目录里有父提交文件），缺失不得让 test 阶段失败；若需要父提交数值，另跑一次明确的取点，不要假设 range 会带出来。

## 4. 失败可见性

以下任何一条都必须非零退出，不得降级为“跳过”：

- 取点解析失败、分支不符、记录缺失；
- 依赖下载失败、子模块初始化失败、构建失败；
- 工具返回非零（`tee` 管道要保留原退出码）；
- 结果文件缺失、commit 不匹配、样本数不足、指标非有限正数。

## 5. 结果产物

- `results/<version>/optimized/<run-id>/`：`build_variant.json`、`results.json`、`runs/`（原始结果、benchmarks、machine、samples、日志）、`asv/`（`results/` + `html/`）。
- 报告写明：实际 commit（含 range）、Python 版本、机器型号、asv/工具版本、是否启用可选项（如 KML）。
- 需要对照时，`results.json` 里可带 `branch`、`parent_commit`、`commit_range`，但指标只覆盖被测 commit；不要在同一份 `results` 里混入父提交的数值。
