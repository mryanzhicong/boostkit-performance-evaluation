# 适配验收：每一层实际证明什么

验收要写出**执行环境、命令、退出码、看到的真实产物**。本文件中的 `lance` 仅示范命令形态，新软件替换分类、名称、版本和用例测试目录。不要把静态检查写成“构建已验证”，也不要为查一个接线错误运行数小时性能矩阵。

本机运行实际构建、容器启动、短测试或失败路径演练前，先用 `mktemp -d /tmp/software-adapt.XXXXXXXX` 创建本次私有目录，将测试用的工作目录、结果目录及容器写入挂载指向其中；测试命令可引用仓库中的脚本，但不得在仓库目录中执行这类测试或把其产物写入仓库。`pytest`、语法检查、清单校验等常规代码测试可以在仓库根目录执行。清理时只处理本次明确创建的 `/tmp` 目录及容器，不触碰共享缓存和真实结果。

## 第 1 层：静态接线和语法

在仓库根目录执行；先将 `SKILL_DIR` 设为**实际存放本 Skill 的绝对目录**，不假设它在 `/root` 或当前仓库：

```bash
SKILL_DIR=/实际路径/adapt-container-software
python3 "$SKILL_DIR/scripts/validate_bundle.py"
python3 "$SKILL_DIR/scripts/check_adapter.py" \
  software/AI/lance/case.yaml
python3 framework/catalog.py validate
python3 framework/catalog.py matrix \
  --software lance --version 13.0.0 --architecture all --pretty
python3 -m pytest -q software/AI/lance/tests
```

`check_adapter.py` 只查目录、阶段函数、输出映射和 Shell 语法；它不能证明 `docker exec` 真的构建、测试，也不能证明指标正确。测试目录不存在时应新增针对性的测试，不得把不存在的测试说成通过。`matrix` 要确认版本、架构、工作流选择能找到用例。检查各相关 Workflow 的软件选项、变体和结果持久化/上传分段逻辑；不要误改不在本任务范围内的工作流。

最低限度的自动测试覆盖：

1. 真实原始输出能解析出期望的场景、指标、单位和方向；缺失、重复、不可能的数值、非零失败计数应拒绝。
2. `base/optimized` 分流；未实现的 optimized 明确失败，不写成功的 `build_variant.json`。
3. 已存在同名容器或 label 不符时不覆盖、不删除；失败路径也会调用 `stop`。
4. `start/test` 重算并使用 build 的容器名；不要在测试代码里 mock 出一个与实际 Docker 行为矛盾的“成功”。
5. 本地包/数据缓存：完整且校验正确时不联网；缺失或半成品时才下载/生成；失败后不会留下可被误判的缓存。验证子容器结果路径与宿主解析器读取的是同一路径。
6. 使用真实或保真的双架构输出调用 `framework/generate_comparison.py`，核对指标身份、单位、场景数量和 `resolved workload parameters`；不要等正式测试跑完才发现结构不一致。

README 还需做一次人工逐项复核：将容器启动选项与创建脚本、依赖/构建命令与 `build`、服务命令与 `start`、完整 benchmark 命令及参数与 `test`、清理范围与 `stop` 对照；将数据、预热、轮次、线程、时长、输出字段与用户原指导对照。对每个条件分支确认 README 已说明触发条件和实际命令。任何仅写“在容器内运行”“参考上游脚本”、省略 Docker 挂载/网络/资源选项或 benchmark 关键参数的文档都不能算完成。

## 第 2 层：容器内构建烟测

仅在有 Docker 的可控机器/Runner 上执行，先确定镜像和离线包来源。针对本次用例运行 `prepare` 与 `build`，或使用独立入口的**短模式**（若软件确有短模式）。执行过程中核对：

```bash
docker ps --filter 'label=boostkit.<软件>.run-id=<run-id>'
docker inspect --format '{{.State.Running}} {{.Config.Image}} {{.Config.User}}' '<本任务容器名>'
docker exec '<本任务容器名>' sh -c 'uname -m; id; printf "HOME=%s\n" "$HOME"; pwd; ulimit -n'
```

再查看构建日志，确认编译器/构建工具的命令确实经过 `docker exec`，不是宿主机构建；在容器内运行程序自己的 `--version`（实际语法按软件而定），核对 `PERF_ACTUAL_VERSION_FILE`。检查镜像架构、发行版、两个 bind mount、产物及构建缓存的 UID/GID、代理/CA 是否只作用于容器。检查 `HOME` 是否为本任务可写目录；只看 `docker run --user` 不够，仍要核对实际构建命令是否改回 root。若只完成构建，结论必须写“构建通过，正式性能测试未跑”。

构建烟测还须沿正式测试路径检查测试工具及运行依赖：所需 Python 模块能 import、共享库能加载、协议编译器能找到标准 include、数据集清单通过验证。容器构建若需要联网，分别验证 `docker build` 与 `docker exec`，而不是只证明宿主 `curl` 或容器 `--network=host` 可用。对不同架构镜像分别 inspect，避免 amd64 镜像在 ARM 上到执行阶段才报 `exec format error`。

## 第 3 层：阶段复用、失败收口和短测试

独立入口或 Framework 分阶段执行时，记录 `build` 后的容器 ID；`start`、`test` 前后应仍为**同一个 ID**，而非同名新容器。用真实可执行的短负载验证正式命令的调用路径、完整日志落盘、解析器输出；不能用另一套脚本的数字填充结果。若无短模式，至少单独验证 build/start/stop 和解析器样例，明确 test 未验证。

长测试前还要确认进度日志可在 `RESULTS_DIR` 实时查看，服务健康检查能区分“仍运行”和“无资源/零工作线程”，阶段超时高于已确认的最坏用例时间。短测不可擅自改变正式负载定义；任何预热、采样次数和数据量差异都记录为仅用于烟测。

分别触发可控的失败路径，例如缺数据、容器未运行、benchmark 返回非零、原始结果缺一项。核对 `stop` 被调用、只清理本任务 label 的容器、`RESULTS_DIR` 与诊断日志仍在。独立入口的 `--keep-workdir` 应保留私有目录；默认也不能删除调用者自行传入的工作目录。**不要为了测试失败路径删除用户的真实结果或共享离线包。**

在前述本次 `/tmp` 私有目录中，容器实际构建后用 `find`/`stat` 定位不属于 Runner UID/GID 的文件与不可遍历目录，尤其检查 Bazel `output/`、安装缓存和子容器输出。再以 Runner 身份执行与 Framework 相同边界的目录清理，确认退出码为 0 且无 `Permission denied`；失败路径也要验证。若只在 root 身份清理成功，必须判为未通过，并修正容器用户、私有 `HOME` 或 root 步骤的限定收口，而非修改全局清理脚本掩盖问题。

## 第 4 层：正式 Runner 验收

用户要求正式性能数字时，再在目标 Runner 上执行完整矩阵。先检查单架构的版本、原始日志、每项指标、结果文件、停止和持久化；有跨架构对比要求才跑第二架构。固定测试负载应保持一致；机器拓扑差异记录在运行上下文或指标身份中，不能强行把 CPU 数写成相同值。最终汇总前确认 `resolved workload parameters` 与指标名能配对，避免长跑完才因结构不一致失败。

正式工作流应在用例 `stop/finalize` 后保存完整结果到 Runner 持久目录，再由上传工作流传输；若上传失败，优先从持久结果恢复，不能默认重跑耗时测试。若未实际在 Runner 上运行，明确写“未做端到端验证”，不要声称本地静态测试等于 Runner 成功。

交付清单：当前分支及提交状态；修改的目录/文件；实际执行的每层验证和观察结果；产物所在目录；未验证的架构或长测试；用户可直接使用的下一步命令。
