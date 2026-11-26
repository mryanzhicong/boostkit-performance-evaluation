---
name: add-optimized-variant
description: "把某个组件的优化方案（优化源码/分支、构建开关、第三方依赖、取点与测量命令变化）接入 boostkit-performance-evaluation 中已有的开箱测试用例，实现可运行的 variant=optimized 构建与测量，并补齐文档、解析与回归测试；只允许改动容器用户态与被测源码，绝不修改 OS/BIOS 参数。"
---

# 优化版开箱测试 Skill

本 Skill 把一个**组件的优化方案**落到仓库里已有用例的 `variant=optimized` 上。交付物不是文档，而是：

- 能用 `framework/run_case.py` 或独立入口按 `build → start → test → stop` 跑通的优化版用例；
- 优化版结果与基础版（`variant=base`）**互不污染**，且两变体的容器启动参数完全一致；
- README、`case.yaml`、解析器和回归测试同步更新，读者不打开脚本也能复现。

参考实现：`software/AI/numpy`（优化版 NumPy 2.4.3 的鲲鹏分支，取点为 master 尖端），完整实现见分支 `numpy_op` 的 `d4fd761e add numpy kp optimize way`（该提交含 9 个文件、约 1400 行改动）；其他分支上 `optimized.sh` 可能仍是“显式返回 10”的桩，用 `scripts/check_optimized_case.py` 判定即可。本 Skill 里出现的函数名、变量名和退出码都以该用例为准；接入其他组件时按同样形态改名，不要照抄 `numpy` 字面量。

`SKILL_DIR` 指本 Skill 所在目录。交付时把 `SKILL.md`、`references/`、`assets/`、`scripts/` 一起带上，不要只留一份摘要。

## 0. 先收齐输入：组件优化方案

**优化方案是输入，不是可以推断的东西。** 开始实现前，按[优化方案输入表](assets/优化方案输入表.md)向用户逐项确认；表里没有、用户也没说的，直接问，不要猜：

| 必填项 | 为什么要 |
|---|---|
| 用例路径（`software/<category>/<software>`） | 决定改哪一套脚本和 case.yaml |
| 方案来源（PR/设计文档/仓库说明） | 后面每条实现都要能回指到方案原文 |
| 优化版仓库、分支、tag 或 commit | 决定取点；三者都没有就必须问 |
| 取点定义与对照点 | 固定 hash、分支尖端、还是 tag；对照点是哪个 commit/分支 |
| 构建开关与第三方依赖 | 例如 KML/HPCKit、专用 FFT 后端、编译器插件；要写明默认是否关闭、缺依赖时怎么办 |
| 测量命令是否变化 | 是否只换取点，还是连测试工具/参数/采样也变 |
| 测量窗口的网络需求 | 工具是否要在测量时联网取包（隔离构建的 pip 依赖） |
| 工具链需求 | 例如 `patchelf`、`ninja`、编译器版本、需要暴露到 PATH 的二进制 |
| 交付产物 | `results/`、`html/`、对照数据，报告里要注明的 commit/版本/机器型号 |
| 明确排除项 | 方案里要求但本次不做的东西，必须写进 README 和交付说明 |
| 验收标准 | 谁来判“优化生效”，用什么指标、什么门槛 |

方案缺取点时**不要**用“最新 master”之类含糊说法替代；方案要求改 OS/BIOS 参数时按第 2 节停下来说明。

## 1. 只读调研，先给结论

动手前把用例读一遍，顺序固定：

1. `case.yaml`：`versions`、`test_tools`、`execution.stages`、`outputs`、`metrics`。
2. `README.md`：现有测量协议、与用户指导的差异、已知限制。
3. `scripts/common.sh`：取点常量、路径约定、`configure_runtime_paths`、`validate_variant`、容器块（**生成块不得手改**）。
4. `scripts/builders/{dispatch,base,optimized}.sh`：`optimized.sh` 现在是不是“显式返回 10”。
5. `scripts/stages/{start,test,stop}.sh` 与 `scripts/results/parse_*.py`：命令怎么拼、结果文件怎么找、解析器硬校验哪些字段。
6. `tests/`：有没有现成断言会把优化版固定成“未实现”。

然后在回复里先给出三件事，再动手：

- base 的完整测量链路（取点 → 构建 → 命令 → 采样 → 结果文件名 → 解析字段）；
- 优化方案与现有链路的逐项对照：**可直接沿用 / 需要适配 / 冲突 / 无证据**；
- 冲突项打算怎么处理（例如“KML 需要宿主 HPCKit，容器内没有 → 默认关闭，README 注明”）。

## 2. 硬边界：不满足就停下

### 2.1 不修改 OS/BIOS 参数

优化逻辑只允许改**容器用户态**和**被测源码**。禁止（可执行行，不是注释）：

- `sysctl`、`/proc/sys`、`/sys`、`--sysctl`；
- CPU governor、`cpupower`、`tuned-adm`、`irqbalance`、`/sys/kernel/mm`、THP、hugepage；
- MSR/BIOS（`wrmsr`、`setpci`、`dmidecode` 写操作）、网卡/固件参数；
- `--privileged`、`--cap-add`、挂宿主 `/proc`、宿主 `/sys`；
- `taskset`/`numactl` 绑核、改宿主 ulimit（容器内 `--ulimit` 属启动参数，两变体必须一致）。

`base` 与 `optimized` 的容器启动命令必须**逐字一致**，唯一区别是容器名/label；差异只能出现在构建阶段脚本里。允许的改动只有：容器内装包、`/usr/local/bin` 下放工具（如 `patchelf`、`ninja`）、`$HOME` 内的 git/pip 配置、构建产物、结果目录。

方案里若确实要求 OS 调优，**停下来问用户**：说明这会破坏“开箱即可比”，默认不采用，并把该条写进 README 的“未采用/未验证”。

### 2.2 其它不可越过

- 不改共用容器块（`scripts/common.sh` 中 `# >>> container-runtime:begin` 段），不复用 `build_<sw>_base`，不依赖 base 阶段的残留产物。
- 不改测试用例清单、不缩采样、不换指标口径；只允许换取点与“为让工具能构建该取点”所必需的适配。
- 不 commit、不 push，除非用户明确要求。

细则见[OS/BIOS 边界](references/os-bios-boundary.md)。

## 3. 实施：固定改这 8 处

详见[优化版构建实现](references/optimized-build.md)，这里只列检查点。

1. **`scripts/builders/optimized.sh`**：从 `base.sh` 拷贝（保持共享函数逐字一致），只改 clone/取点、工具暴露、`build_variant.json` 扩展和 `build_<sw>_optimized` 的步骤顺序。
2. **`scripts/common.sh`**：加优化版取点常量、`<SW>_SOURCE_RECORD`、`<SW>_EXPECTED_*` 全局与导出；加记录读写、期望值加载、测量环境切换（优化版才放开 pip 镜像）、payload 校验改用 `EXPECTED`。
3. **`scripts/stages/start.sh`**：discovery 用 `EXPECTED_COMMIT` 而不是写死的基线 commit。
4. **`scripts/stages/test.sh`**：按 `PERF_VARIANT` 分派命令；结果按 `EXPECTED_COMMIT` 前缀收集；解析阶段导出 `EXPECTED_*`。
5. **`scripts/results/parse_*.py`**：期望 commit 可被 `<SW>_EXPECTED_COMMIT` 覆盖；优化版文档补充 `branch`/`parent_commit`/`commit_range` 等来源字段；基础版输出保持不变。
6. **`case.yaml`**：`test_tools` 增 `<name>_optimized: {version, revision}`（字段只允许 `version`/`revision`）。
7. **`README.md`**：双列写清两变体的取点、构建、测量、差异与已知限制。
8. **`tests/`**：静态断言 + shell 往返 + 解析器用例，且包含“不得碰 OS/BIOS”的回归测试。

## 4. 测量衔接

优化版最容易出错的地方是“命令换了，语义没换”。必须写进 README 并自查：

- 取点三形态：固定 hash（钉常量）、分支尖端（构建阶段解析并写 `<SW>_SOURCE_RECORD`）、tag（解析成 commit 后钉住）。三种形态下 `build_variant.json.commit` 都必须是**实际被测 commit**。
- 命令只换取点/构建方式，不换用例清单与采样。
- 工具语义要核实：例如 asv 0.6.4 的 `--python=same` 与 range 参数互斥，`HEAD~1..HEAD` 经 `git rev-list --first-parent` 只选中尖端一个 commit；这类事实要写进 README，不能凭“看起来跑通了”下结论。
- 结果收集按期望 commit 前缀；父提交/对照 commit 的记录**存在才收集**，缺失不得让整个 test 阶段失败。
- 失败要可见：网络取包失败、构建失败、解析校验失败都必须非零退出，不能降级成“跳过”。

详见[测量衔接](references/measurement-handoff.md)。

## 5. 文档与测试

- README：两变体分开写取点与命令；`与指导的差异` 逐条列原命令/实际命令/理由；`已知限制` 写清网络、工具链、未采用项。
- `case.yaml` 的 `test_tools` 是“被测来源”的唯一登记处；分支名可以做 revision，但要能解析。
- 独立入口 usage 同时覆盖两个变体。
- 测试至少覆盖：优化版构建入口存在且不调用 base；取点记录往返；记录缺失/分支不符返回 30；基础版仍钉死基线；解析器期望 commit 命中/不命中；OS/BIOS 模式零命中。

## 6. 验证

按[验证清单](references/verification.md)分层执行，状态如实标注：

```bash
SKILL_DIR=<本 Skill 目录>
python3 "$SKILL_DIR/scripts/check_optimized_case.py" --case software/AI/<software>
python3 "$SKILL_DIR/scripts/validate_bundle.py"
bash -n software/AI/<software>/scripts/builders/optimized.sh
python3 framework/catalog.py validate        # 接线检查
pytest software/AI/<software>/tests -q       # 需要能在本机跑 Python
```

静态检查通过 ≠ 容器内构建通过 ≠ 正式测试通过。本机缺 Python/Docker 时，只能给出“静态已查、运行期未验证”，并把待验证命令原样列给用户在 Runner/CI 上执行。

## 7. 交付时写什么

1. 改动文件清单（含新增测试与 Skill 自身若有改动）。
2. 实际执行过的命令、退出码与产物路径（`build_variant.json`、`results.json`、`runs/`、`asv/`）。
3. 对应用例的取点：实际 commit、分支、range，以及报告里应标注的 Python 版本与机器型号。
4. OS/BIOS 审计结论（grep 命令与结果）。
5. 未验证/阻塞项，和预计正式耗时。
6. 若用户要求不提交：明确写“未 commit、未 push”。

## 8. 常见坑

| 现象 | 原因 | 处理 |
|---|---|---|
| `asv run <range> --python=same` 报 “No range spec may be specified…” | asv 0.6.4 不允许在既有环境里用 range | 优化版去掉 `--python=same`，让工具按提交自行建环境 |
| 以为 range 会测两个提交 | `git rev-list --first-parent A..B` 只含尖端 | 文档写清单提交语义；对照点仅作来源记录 |
| 隔离构建报找不到 `ninja`/`patchelf` | 工具在测量 venv 里，不在隔离环境 PATH | 构建阶段把二进制装到 `/usr/local/bin` 并记录 |
| 测量时 pip 取不到构建依赖 | 基础版为断网把代理指向黑洞 | 优化版只在测量窗口导出 `PIP_INDEX_URL/PIP_TRUSTED_HOST` |
| 子模块 alternates 克隆失败 | asv 的 checkout 走 `submodule`，需要本地克隆许可 | 容器内 `git config --global protocol.file.allow always`，必要时加镜像 `insteadOf` |
| 校验“版本文件”失败 | 优化分支删除了版本文件 | 用 `import <pkg>; print(__version__)` 校验实际版本 |
| 优化版结果混进基线 | 结果目录没隔离 | 沿用 `results/<version>/optimized/<run-id>` 约定 |
