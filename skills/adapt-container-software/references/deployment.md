# 跨 agent 交接与生产验收

本目录是可复制的 Agent Skills 包，不依赖 Codex 的 UI 元数据、插件或专用命令。它**针对 boostkit-performance-evaluation 仓库**，不是任意项目的通用 Docker 教程。不同 agent 的自动发现目录没有统一保证；自动发现不是正确执行的前提。

## 1. 交付完整目录

将 `adapt-container-software/` 整个目录复制到目标 agent 能读取的位置，保留以下结构：

```text
adapt-container-software/
├── SKILL.md
├── assets/适配记录模板.md
├── references/{deployment,container-lifecycle,framework-and-results,verification}.md
└── scripts/{validate_bundle,check_adapter}.py
```

支持 Agent Skills 自动发现的宿主，可将完整目录安装到其**当前项目或用户级 skills 目录**；具体目录由该宿主决定。不能自动发现的 agent，在任务提示中提供 Skill 目录绝对路径，要求它先完整读取 `SKILL.md`，并按其中链接读取适用的参考文件。不要只粘贴 `SKILL.md` 文本而遗漏脚本和参考文件。

## 2. 在目标环境做入场核查

在目标 agent 可访问的 Shell 中设置本包的真实位置，先运行包结构校验：

```bash
SKILL_DIR=/实际路径/adapt-container-software
python3 "$SKILL_DIR/scripts/validate_bundle.py"
```

然后确认 agent 能读取项目仓库，且仓库中存在 `doc/SOFTWARE_INTEGRATION.md`、`framework/catalog.py`、`config/categories.yaml`。`scripts/check_adapter.py` 还需要 Python 3.9+、PyYAML 和 Bash；容器内构建/测试还需要有权限访问 Docker daemon。目标 Runner、镜像/离线包、数据集、私有仓库凭据和网络/CA 按具体任务核对；当前开发机上的可用性不能代替 Runner 验收。

Skill 中的 `/home/runner/...` 是本项目 Runner 的**数据与工作目录约定**，不是 Skill 安装路径。移植到同一项目的不同机器时，先核对这些路径的真实可用性；不要盲目创建系统配置、安装证书或复制私有凭据。

## 3. 授权与生产门槛

开始软件适配时，必须按 `SKILL.md` 从最新 `main` 新建 `adapt-<software>-<version>` 分支，并保护工作区已有改动；若无法安全建分支，先说明阻碍。提交、推送、触发正式流水线、操作共享 Runner 或私有凭据，仍由用户当前任务授权决定。Skill 不赋予这些额外权限。镜像或源码来源不明、两个架构不可用、负载口径不能配对时先说明缺口，不以改版本、禁用 TLS 或缩小正式负载代替解决。

生产验收按 `references/verification.md` 分层记录：包结构与静态接线、真实容器内构建、同一容器跨阶段复用、短测试与失败清理、目标 Runner 正式结果。只有相应层级**真实执行且有产物证据**，才可声称该层级通过。没有双架构正式测试就不能声称跨架构生产验证完成；任何上传失败优先检查持久化结果，不能默认重跑性能测试。

## 4. 建议交接提示

> 请使用位于 `<Skill 目录绝对路径>` 的 `adapt-container-software` Skill 适配本仓库中的 `<软件与版本>`。先完整读取 `SKILL.md` 和当前步骤指向的参考文件，按其中流程工作；在执行前核对仓库现行接入规范，并基于最新 main 新建 adapt-<software>-<version> 分支。报告每层真实验证及未验证的部分，不要把静态检查称为 Runner 验证。未经我明确要求，不要提交、推送或触发长时间正式测试。
