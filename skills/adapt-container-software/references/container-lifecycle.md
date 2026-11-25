# Docker 容器的启动、复用与清理

适用场景：编写 `common.sh`、`builders/base.sh`、`stages/{start,test,stop}.sh` 时阅读。此处描述**容器内构建＋同容器测试**，不要照搬现有 MySQL 的宿主机 Sysbench 模式。

## 0. 容器外操作的确认清单

默认只让宿主负责任务编排：管理本任务 Docker 容器、准备私有目录、读预置输入、解析与持久化结果。宿主预置必须与每轮用例分离；涉及宿主安装、系统设置、内核资源或服务重启时，记录命令、影响范围、维护人、回滚方式和用户确认，不能作为构建失败时的临时回退。

凡涉及宿主客户端、子容器、远程压力机或 KVM，先列出每个组件的运行位置、资源限额、网络模式、监听地址/端口、开始和结束计时的位置，以及启动、就绪和清理责任；比较两架构时核对部署拓扑与计时是否等价。用 `--network=host` 时也要说明为何要共享宿主网络；核对端口归属和冲突，不能为了抢占端口杀掉别的任务。

默认只挂载必要输入和任务目录：预置输入只读，写入限定到任务工作和结果目录。Docker socket、特权模式、宿主 PID/IPC、额外设备或能力不是默认配置；确需开放时逐项确认最小授权和清理方法。不要通过挂载整个宿主主目录、传入所有宿主环境变量或将凭据写进镜像、日志或结果来简化配置。

## 1. `build` 前的只读核查

先确认 `docker info` 可访问；`EXPECTED_ARCH` 与 `uname -m` 一致；镜像包、源码包、数据集在 x86_64/aarch64 上分别有对应版本；Runner 的 `PERF_WORK_DIR` 和 `RESULTS_DIR` 可写。用户没有指定限额时，不从其他软件继承 `2U8G`、`8U32G` 或绑核方案。需要 CPU/NUMA 限额时，根据本机拓扑发现可用 CPU，记录最终选中的集合，避免写死机器编号。

使用 openEuler 24.03 LTS SP4 官方离线镜像的用例，读取顺序为：

1. `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz` 和同名 `.sha256sum`。
2. 缺失时才下载对应架构的官方归档到本任务 `PERF_WORK_DIR`；下载失败不能伪装为“本地缓存可用”。
3. 核验 SHA-256，`docker load --input <归档>`，由加载输出得到镜像引用。
4. `docker image inspect` 检查 Docker 架构（`x86_64 → amd64`、`aarch64 → arm64`）；在镜像内读取 `/etc/os-release` 核对发行版。不能直接假定同名 tag 一定是本次加载的镜像。

镜像只在 `build` 阶段准备一次。后续阶段从 `${PERF_WORK_DIR}/container-image.txt` 等私有状态文件读取，或由可确定的规则重算；**不能重新下载、load 或创建容器**。

## 2. 创建唯一的私有容器

容器名包含软件、架构、run ID，例如 `boostkit-demo-x86_64-12345-1`；加归属 label `boostkit.demo.run-id=12345-1`。创建前 `docker container inspect` 检查同名容器，不覆盖别人的容器。宿主和容器内采用相同绝对路径挂载：

```bash
docker run --detach --name "${CONTAINER_NAME}" \
  --label "boostkit.demo.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${CONTAINER_IMAGE}" sleep infinity
```

这只是命令形态，不能照抄 `demo` 或资源选项。普通构建与测试以 Runner 的 UID/GID 执行，避免容器在挂载目录里留下 root 文件。只在容器内安装包、改 repo、更新 CA 时使用 `docker exec --user 0`；`docker exec` 的用户覆盖和环境参数也须逐条核对。容器启动前创建 `${PERF_WORK_DIR}/home` 并确保 Runner 可写；将 `HOME` 显式指向它，不能让工具默认写入 `/root` 或只读的 `/home/runner`。如工具写入 `$CARGO_HOME`、`$RUSTUP_HOME`、`$PIP_CACHE_DIR`、`$XDG_CACHE_HOME` 或 `$TEST_TMPDIR`，也要指向本次私有可写目录。Bazel 等构建器的 output/cache/install 目录即使在 `PERF_WORK_DIR` 下，也必须由 Runner 拥有并可清理。确需 root 构建时，限制其写入本任务目录，在成功、失败和中断收口中修复该目录的属主；不得对共享软件、镜像或数据目录递归改属主。若需要提高文件描述符限额，**在创建容器时**设置 `--ulimit nofile=软限额:硬限额` 并核对容器内 `ulimit -n`，不能以宿主机硬限额推断容器软限额。

`--network=host` 只是共享网络命名空间，**不会传递宿主机代理变量、CA 证书、Git 配置或 pip 配置**。私有 Git 仓库若需 `/home/runner/.gitconfig`，仅在用户同意且文件存在时只读挂载；不能因文件不存在让公开源码下载失败。可预置的数据集也只作为输入读取，生成的索引、数据库文件和测试输出仍放本任务目录。

如果测试框架还会启动子容器（如 ann-benchmarks），同时核对其镜像架构、CPU/内存限额、网络、挂载、输出目录 UID/GID 和清理方式。父容器 `--network=host` 不会自动赋予 `docker build` 或子容器相同网络；镜像构建确实需要联网时，单独决定 `docker build --network=host` 与代理/CA 传递。遇到 `exec format error` 先 inspect 镜像架构，不能当作 Python 包安装失败。

## 3. 容器内网络、依赖和构建

通过 `docker exec` 执行容器内依赖安装与编译。需要企业代理时，把 `PERF_PROXY` 显式传给**需要联网的那条命令**，例如容器内 `dnf --setopt=proxy=...`；不要假定 `sudo` 或 `docker exec` 会继承环境，也不要把认证信息写进公开日志或命令回显。容器需要信任企业 CA 时，可将 `/home/runner/software/anchors/` 只读挂到 `/etc/pki/ca-trust/source/anchors/`，再以容器 root 执行 `update-ca-trust extract`。证书目录不存在时，先判断是否真的需要代理；不自动关闭 TLS 校验。不改宿主机 CA 或系统 repo。

若 openEuler 官方 repo 在该环境不可达，按用户认可的镜像策略**仅修改本次容器内**的 `/etc/yum.repos.d/openEuler.repo`，然后在容器里验证 `dnf makecache`。不要把“源不存在”“证书不被信任”“代理拒绝/连接重置”“DNS 失败”混为一类。没有代理的 Blue/开发工作流应保持直连，不注入空代理或禁用 TLS。

源码/安装包先查 `/home/runner/software/<软件>/` 的本地预置，读取或复制到 `PERF_WORK_DIR`；缺失才从已核实的上游地址下载。校验 SHA-256/tag/提交后，实际的 `make`、`cmake --build`、`mvn`、`pip install` 等**必须通过 `docker exec` 在容器内运行**。如果是官方预编译包，至少在容器内完成部署与版本核验；不要把“宿主机构建后挂进去”说成容器内构建。构建失败保留本任务日志以便定位，`stop` 仍能清理容器。

本地优先不是“目录存在就跳过”。离线数据必须有完整清单、大小/条目和 SHA-256；下载、解包、生成先写本次私有目录。只有明确允许写共享缓存时，才由指定写入方在同一文件系统暂存、校验并原子发布；并发采用互斥或不可变键，已存在的有效缓存不覆盖，失败的临时文件不算命中。不能向非空目录再次 `git clone`。源码站点 403 或私仓无权限时，只能改用已核实的同版本官方归档/镜像，不能换来源却仍报原版本。对 Go、Rust、pip 等依赖缓存，命中则复用，缺项才联网；缓存是否跨架构通用须按二进制 wheel/模块内容实测，不凭路径名推断。下载量大或正式测试要用多个 GB 数据时，先提供预置和验证命令。

安装依赖后，在容器里按实际测试路径做轻量验收：编译期命令、头文件和 protobuf 标准 include 可用；运行期动态库能加载；Python 模块能 import；Go/Rust 工具链与锁定版本可启动。像缺 `numpy`、`tqdm` 或 `google/protobuf/empty.proto` 这类问题应在长测前暴露。Rustup 等安装器应设置私有可写 `HOME`/`RUSTUP_HOME`/`CARGO_HOME` 并禁用修改用户 profile；需要高 `nofile` 的构建在创建容器时配置且实测。排查 `dnf`、pip 或 Git 下载时分别看 DNS、代理连接、TLS 信任、HTTP 状态；不要用 `-k` 或关闭 TLS 校验掩盖原因。

## 4. 阶段生命周期检查表

| 阶段 | 必须做 | 明确不要做 |
|---|---|---|
| `build` | 创建一次容器；容器内装依赖、构建软件和 benchmark；在容器内核对版本，留下可重算的容器名和私有产物。 | 在宿主机偷偷编译后只挂载成品；遇到同名容器直接 `docker rm -f`。 |
| `start` | `docker inspect` 验证名称、running 状态与本任务 label；启动服务或检查无服务用例的程序/数据；有界等待就绪。 | 再次 load 镜像、创建新容器、重编译；用固定 `sleep` 代替就绪检测。 |
| `test` | 再检查同一容器；容器内运行正式命令；保存完整原始数据并严格解析。 | 在宿主机运行压测却称为“全程在容器内”；吞掉管道前段进程的失败码。 |
| `stop` | 先复制/保存诊断日志；停止本任务服务；核对 label 后停/删本任务容器；容器不存在时安全返回。 | 清理结果目录、其他任务容器、共享离线包，或用全局清理代替自身收口。 |

有状态服务的 PID、socket、端口和数据目录均放在 `PERF_WORK_DIR` 并由 run ID 派生。`stop` 可能在 `build` 中途失败后被调用，所以不能假定服务已经启动。多实例时以实例号扩展容器名、端口、数据和日志；缺任何一个维度都可能串扰。停止后 `RESULTS_DIR` 必须留给 Framework finalize、持久化和上传。正式工作流的全局清理发生在用例 `stop/finalize` 之后，故诊断资料必须在清理前复制出来。

普通失败或可处理取消应调用 `stop`；强杀、Runner 掉线等可能让 `stop` 无法运行，不能承诺一定完成。下一次运行或人工回收只有在确认原任务已结束、容器 ID 与本次记录的标签或状态一致时，才在保全可读的诊断资料后定点清理；如果无法确认归属或任务状态，保留并报告，不按名称前缀批量删除。子容器、临时网络/卷以及获准使用的宿主进程也要有可核对的归属记录。

容器内写出的构建产物、缓存和 benchmark 原生结果必须能被宿主 Runner 读取和删除；子容器若以 root 生成文件，不可把无法清理的目录遗留给全局清理。验收时在本次 `/tmp` 烟测目录内，先用容器实际构建命令产生文件，再核对其 UID/GID，最后以 Runner 身份执行真实清理；只检查空目录或以 root 清理不算通过。测试阶段出现镜像加载、容器重建或依赖重装日志，应检查阶段复用，而不是把它当正常输出。上传失败只处理持久化目录中的结果，不重跑已成功的 benchmark；传输限制（代理 403、分块/manifest）属于上传链路，不应污染测试成败判断。
