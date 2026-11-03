# UnixBench 6.0.1 性能测试

本用例在 x86_64、aarch64 上分别运行上游 UnixBench 6.0.1 的完整系统指数测试。
构建和测试均在本次任务的 openEuler 24.03 LTS SP4 私有容器内执行。
容器不限制 CPU、内存或 NUMA；两台机器各按自身检测到的 CPU 数运行官方默认副本数。

软件入口为 `unixbench_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、
测试和停止函数；独立入口也调用同一组函数。`scripts/builders/base.sh` 负责基础版的
完整构建，`scripts/stages/` 负责容器校验、测试和清理，`scripts/results/` 负责解析
官方报告。`optimized` 构建入口尚未实现，选择后在构建阶段明确失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| UnixBench | [上游 v6.0.1 源码](https://github.com/kdlucas/byte-unixbench/releases/tag/v6.0.1)，固定归档 SHA-256 | `${PERF_WORK_DIR}/byte-unixbench-6.0.1/UnixBench` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载至 `${PERF_WORK_DIR}` |
| 测试工具 | 上述源码自带的 `UnixBench/Run` | 同源码目录，不单独安装 |

容器内通过 `dnf` 安装 GCC、Make、Perl、`perl-Time-HiRes` 等依赖。
不向宿主机安装 UnixBench；宿主机若缺少下载、校验所需的基本命令，脚本会用
`dnf` 安装缺失的包。

## UnixBench 获取、构建与容器启动

脚本先检查 Docker daemon。基础镜像归档和同名 `.sha256sum` 优先取公共目录；
缺失时从上表的官方地址下载对应架构文件。校验 SHA-256 后执行 `docker load`，
再核对镜像架构及容器内的 openEuler 版本。`UNIXBENCH_IMAGE_ARCHIVE_DIR` 可指定
其他离线镜像目录。

每次运行创建一个带任务标签的容器，名称为
`boostkit-unixbench-<架构>-<运行 ID>`。容器使用宿主网络，不绑核、不限制内存；
本次任务的工作目录和结果目录均挂载到容器内的同一路径。命令形态如下：

```bash
docker run --detach --name "${UNIXBENCH_CONTAINER_NAME}" \
  --label "boostkit.unixbench.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${UNIXBENCH_CONTAINER_IMAGE}" sleep infinity
```

正式工作流设置 `PERF_PROXY` 时，脚本还会把
`/home/runner/software/anchors/` 只读挂载到容器的
`/etc/pki/ca-trust/source/anchors/`，并在容器内运行
`update-ca-trust extract`。随后仅在本次容器内把 openEuler 仓库地址换成
`repo.huaweicloud.com/openeuler`，再通过 `dnf` 安装构建和运行依赖。
没有配置代理时不挂载证书目录，也不执行证书更新。

源码归档优先取
`/home/runner/software/unixbench/v6.0.1.tar.gz`；
缺失时下载上游 v6.0.1 归档。脚本校验固定 SHA-256，并把归档放入
`${PERF_WORK_DIR}`。下面的解压与构建命令在私有容器内执行：

```bash
tar -xzf "${PERF_WORK_DIR}/v6.0.1.tar.gz" \
  -C "${PERF_WORK_DIR}"
make -C "${PERF_WORK_DIR}/byte-unixbench-6.0.1/UnixBench" -j"$(nproc)"
```

使用上游 `Makefile` 的默认编译选项，不修改源码、不运行系统级安装。
构建后核对 `UnixBench/Run` 声明的版本和 `pgms/dhry2reg` 可执行文件。

## 数据与运行顺序

1. 在容器内确认编译产物和 Perl `Time::HiRes` 可用。
2. 在容器内进入本次任务的 `UnixBench` 目录，执行上游完整默认命令：

   ```bash
   ./Run
   ```

3. `Run` 先测试 1 个副本，再按检测到的 CPU 数测试多副本。测试包含官方
   系统指数的 12 个子项，包括三项 File Copy I/O；不传 `-i`、`-c` 或子项名，
   保留上游默认迭代次数和各子项参数。
4. 解析两个完整档位的原始结果和指数。停止阶段只移除带本次任务标签的容器。

该命令和副本规则来自上游 [UnixBench 使用说明](https://github.com/kdlucas/byte-unixbench/blob/v6.0.1/UnixBench/USAGE)。
脚本仅通过以下上游环境变量指定文件位置，不改变测试口径：

| 变量 | 设置值 | 用途 |
|---|---|---|
| `UB_RESULTDIR` | `${RESULTS_DIR}/unixbench-official` | 保存官方文本报告、HTML 和日志 |
| `UB_TMPDIR` | `${PERF_WORK_DIR}/unixbench-tmp` | File Copy 的临时数据位于 Runner 持久磁盘，不使用 `/tmp` |
| `UB_OUTPUT_FILE_NAME` | `unixbench-index` | 固定官方报告文件名 |

## 指标与产物

每个副本档位要求以下完整结果：

| 指标 | 官方报告来源 | 单位 | 方向 |
|---|---|---|---|
| 12 项子指数 | `System Benchmarks Index Values` 中各子项的 `INDEX` 列 | index | 越大越好 |
| 系统总指数 | `System Benchmarks Index Score` | index | 越大越好 |

单副本和多副本各 13 项，共 26 项。原始测量值与采样数保留在上游原始报告中，
解析器核对原始测量值与指数表的 `RESULT` 列，但不另列为对比指标；采样由上游
`./Run` 自行处理。报告按实际副本数分组，例如 `1 copy`、
`384 copies`；跨架构只比较名称和副本数都相同的指标。若两台机器 CPU 数不同，
多副本档位不会被强行配对，仍可比较共同的单副本指标。子项缺失、只生成
`Partial Index`，或副本数不符合上游默认规则时，测试直接失败。

| 产物 | 内容 |
|---|---|
| `unixbench-official/` | 上游原始文本、HTML 和日志 |
| `benchmark_unixbench_raw.log` | 完整控制台输出 |
| `benchmark_unixbench.json` | 26 项指数指标和实际副本数 |
| `build_variant.json` | 本次选择的构建类型 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

脱离 Workflow 执行完整流程：

```bash
bash software/Others/unixbench/unixbench_test.sh \
  --version 6.0.1 \
  --variant base \
  --results-dir /home/runner/unixbench-results/6.0.1
```

独立运行可加 `--keep-workdir` 保留本次私有目录排查问题；默认清理该工作目录，
但保留传入的结果目录。`optimized` 目前仅验证入口会明确失败，不运行性能测试。
