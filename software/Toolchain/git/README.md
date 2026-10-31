# Git 2.56.0 性能测试

本用例在 x86_64、aarch64 Runner 上从 Git 官方仓库构建 release tag `v2.56.0`，使用 Git
上游自带的性能测试套件 `t/perf`（官方 `perf-lib.sh` + 官方脚本）进行开箱性能对比。
**构建与测试全部在 openEuler 24.03 LTS SP4 容器内运行**（基镜像与用法参照 MySQL 用例），
容器不绑核、不绑 NUMA、使用宿主机网络；源码、构建产物和结果目录均通过 bind mount
保存在宿主机本次任务目录。构建遵循上游默认配置（含 Git 的 Rust 组件），不修改源码。

软件入口为 `git_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止阶段；
直接执行入口脚本也使用这些阶段函数。基础版构建位于 `scripts/builders/base.sh`，公共路径在
`scripts/common.sh`，结果处理在 `scripts/results/`。工作流可选择 `base` 或 `optimized`，
默认 `base`；`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Git | 官方仓库 `https://github.com/git/git.git`，release tag `v2.56.0`，提交 `a018953688f1b10bddf91bff8747068f5f4746a4` | 容器内 `--depth 1` 克隆到 `${PERF_WORK_DIR}/git-src`（宿主机同一路径可见） |
| 性能测试套件 | 固定提交内自带的 `t/perf`（`perf-lib.sh`、`run`、`aggregate.perl` 与 `pNNNN-*.sh`） | `${PERF_WORK_DIR}/git-src/t/perf` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载；SHA-256 校验后 `docker load` |
| GNU time | 容器内通过 `dnf` 安装 `time` 包（`/usr/bin/time`，perf-lib 必需；无版本号可核实，`case.yaml` 中记为 `unknown`） | 容器内 `/usr/bin/time` |

容器内通过 `dnf` 安装缺失的构建依赖：`git`、`make`、`gcc`、`perl`、`python3`、`gawk`、
`gettext`、`zlib-devel`、`openssl-devel`、`libcurl-devel`、`expat-devel`、`pcre2-devel`、
`cargo`（会同时安装 `rust`）、`time`、`tar`、`gzip`、`curl`、`findutils`、`diffutils`、
`sed`、`coreutils`、`which`。容器内仓库切换为华为云 openEuler 镜像；启用 `PERF_PROXY`
时，容器挂载代理 CA 证书目录并执行 `update-ca-trust extract`，`dnf`、`git clone` 与
`cargo` 的下载都通过代理。

## 容器

每个任务创建且仅创建一个私有容器 `boostkit-git-<架构>-<run-id>`，带
`boostkit.git.run-id=<run-id>` 归属标签。启动方式：

```bash
docker run --detach --name "${GIT_CONTAINER_NAME}" \
  --label "boostkit.git.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${GIT_CONTAINER_IMAGE}" sleep infinity
```

- 不使用 `--cpus`、`--cpuset-cpus`、`--cpuset-mems`：不绑核、不绑 NUMA。
- `--network=host`：容器直接使用宿主机网络。
- `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 以宿主机原路径挂载，源码、构建产物和所有测试
  结果都落在宿主机指定目录；容器退出后结果仍保留。
- 容器以当前 Runner 用户的 UID/GID 运行，构建产物归属与宿主机一致。
- 镜像归档优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz`，
  其 `.sha256sum` 同样优先本地读取；校验通过后 `docker load`，并核对镜像架构与容器内
  openEuler 版本。
- `stop` 阶段只停止并删除带本任务归属标签的容器，重复调用安全；不清理其他任务或宿主机
  上的服务。

Runner 必须能访问 Docker daemon；`GIT_IMAGE_ARCHIVE_DIR`、`GIT_CA_ANCHORS_DIR` 可指定
其他镜像归档或证书目录。

## 获取、构建与版本核对

以下命令均在私有容器内执行（`container_exec`）：

```bash
git clone --depth 1 --branch v2.56.0 https://github.com/git/git.git /path/to/git-src
git -C /path/to/git-src rev-parse HEAD          # 必须为 a018953688f1b10bddf91bff8747068f5f4746a4
git -C /path/to/git-src describe --tags --exact-match  # v2.56.0
make -C /path/to/git-src -j"$(nproc)" NO_TCLTK=1
/path/to/git-src/bin-wrappers/git --version     # 必须报告 2.56.0
```

实际版本取自容器内的 `git describe --tags --exact-match`（去掉 `v`）和构建产物的
`git --version`，由宿主机写入 `PERF_ACTUAL_VERSION_FILE`，不直接写请求版本。
`NO_TCLTK=1` 只是跳过图形界面，不影响 `t/perf`。

**工作负载仓库**：`t/perf` 默认使用构建目录本身作为基准仓库。本用例使用 `--depth 1`
检出（`git.git` v2.56.0，4854 个工作区文件），两侧架构使用完全相同的检出。深度 1 的
历史使依赖历史遍历的脚本失去代表性，因此固定子集**排除** `p0000`（框架自检）、
`p0001-rev-list`（历史遍历）和 `p0006-read-tree-checkout`（需要 `HEAD^`）；这两个脚本
的结果在浅历史下接近 0，不能反映真实差异。该限制同样适用于两个架构，配对仍然有效。

## 正式测试

`start` 阶段检查容器内工具链、`/usr/bin/time` 与 `t/perf`，并以 `p0002-read-cache.sh`、
1 次重复冒烟运行完整官方执行链，确认可用后清空冒烟结果。`test` 阶段在容器内固定运行
以下官方脚本子集（`GIT_PERF_REPEAT_COUNT=5`，即 upstream 默认的 best-of-5）：

```bash
docker exec "${GIT_CONTAINER_NAME}" sh -c \
  "cd /path/to/git-src/t/perf && GIT_PERF_REPEAT_COUNT=5 ./run . -- \
   p0002-read-cache.sh p0003-delta-base-cache.sh p0004-lazy-init-name-hash.sh \
   p0005-status.sh p0007-write-cache.sh p0008-odb-fsync.sh p0009-diff-pathspec.sh \
   p0071-sort.sh p0090-cache-tree.sh p0100-globbing.sh"
```

`./run .` 由上游脚本自行调用各 `pNNNN-*.sh`，每个子测试内部用 `/usr/bin/time -f
"%E %U %S"` 计时并重复 5 次取最快值；计时结果写入容器内 `t/perf/test-results/`
（bind mount，宿主机同路径可见），完整控制台输出（含 upstream `aggregate.perl`
汇总表）由宿主机 tee 到 `git_benchmark_raw.log`。预计单架构耗时约 15–30 分钟
（镜像加载与容器内依赖安装 5–15 分钟、构建 2–5 分钟、基准 1.5–2 分钟）。

## 指标与产物

每个子测试保留 1 个字段，共 57 个指标（脚本与子测试数量固定于 v2.56.0）：

| 原始字段 | 指标名格式 | 单位 | 方向 |
|---|---|---|---|
| `test-results/<脚本>.<子测试>.result` 的第一个值（Elapsed） | `<脚本>.<子测试>: <官方 description>` | s | 越小越好 |

解析器要求 10 个脚本的 `.subtests` 数量与固定值一致（1/2/2/1/1/16/1/9/12/12），每个
子测试的 `.descr` 与 `.result` 都存在、结果行符合 `HH:MM:SS` 格式、耗时为有限非负数；
缺失、数量不符或解析失败都会使测试失败，不补零、不估算。报告按脚本分组。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `git_benchmark_raw.log` | `t/perf/run` 完整控制台输出与官方汇总表 |
| `git_perf_results/` | `test-results/` 原始 `.subtests`、`.descr`、`.result` 副本 |
| `benchmark_git.json` | 57 个指标、来源字段与固定参数 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从产物读取的实际版本 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段停止并删除本任务的容器（按归属标签校验），无需停止其他服务；宿主机的
`${PERF_WORK_DIR}` 由 Framework 或独立入口清理，`${RESULTS_DIR}` 保留。脱离 Workflow
执行完整流程（宿主机需可访问 Docker daemon）：

```bash
bash software/Toolchain/git/git_test.sh \
  --version 2.56.0 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/git/results/2.56.0
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于该版本下的
`optimized/` 子目录。排错时可加 `--keep-workdir` 保留源码检出与构建产物。
