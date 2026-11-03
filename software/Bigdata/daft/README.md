# Daft 0.7.2 性能测试

本用例在 x86_64、aarch64 Runner 上分别运行 Daft 0.7.2 TPC-H 测试。
安装和测试均在本次任务的 openEuler 24.03 LTS SP4 私有容器内完成；
容器不限制 CPU、内存或 NUMA，也不绑核。每台 Runner 使用自己的持久数据目录；
本机数据不存在时由脚本在本机生成，不需要从另一台机器复制。

软件入口为 `daft_test.sh`。Framework 根据 `case.yaml` 依次调用构建、启动、
测试和停止函数；独立入口也调用同一组函数。`scripts/builders/base.sh` 负责
基础版的完整部署，`scripts/stages/` 负责检查、测试和清理，`scripts/results/`
负责数据校验与结果解析。`optimized` 构建入口尚未实现，选择后在构建阶段失败。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务中的位置 |
|---|---|---|
| Daft | 官方 PyPI `daft[ray]==0.7.2` wheel | `${PERF_WORK_DIR}/venv` |
| TPC-H 查询源码 | [Daft 上游](https://github.com/Eventual-Inc/Daft) `v0.7.2` 的 `benchmarking/tpch/` | `${PERF_WORK_DIR}/daft-source/benchmarking/tpch/` |
| 测试驱动 | 附件原版 [`tpch_driver.py`](scripts/reference/tpch_driver.py) | `${PERF_WORK_DIR}/tpch_driver.py` |
| Python 依赖 | 附件原版 [`requirements.txt`](scripts/reference/requirements.txt) | 本次私有 venv |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`；缺失时下载到 `${PERF_WORK_DIR}` |

本用例**不编译 Daft 源码，也不构建 Docker 镜像**。“构建阶段”指加载基础镜像、
启动容器、安装官方 wheel 和测试依赖、准备 TPC-H 数据。宿主机若缺少下载和
校验所需的基本命令，脚本用 `dnf` 安装缺失的包。

## Daft 获取、安装与容器启动

脚本先检查 Docker daemon，并从公共目录读取
`openEuler-docker.<架构>.tar.xz` 及同名 `.sha256sum`；缺失时从官方目录下载。
校验 SHA-256 后执行 `docker load --input <归档>`，核对镜像架构和容器内的
openEuler 版本，不访问 Docker Hub。

每次运行创建名为 `boostkit-daft-<架构>-<运行 ID>` 的私有容器。
本次工作目录、结果目录和持久数据目录均挂载到容器内的相同路径。
数据首次生成时可写挂载；已有完整数据时只读挂载。容器启动命令形态如下：

```bash
docker run --detach --name "${DAFT_CONTAINER_NAME}" \
  --label "boostkit.daft.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${DAFT_DATA_ROOT},target=${DAFT_DATA_ROOT}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${DAFT_CONTAINER_IMAGE}" sleep infinity
```

上例的数据挂载是首次生成时的形式；复用数据时脚本加 `readonly`。
正式工作流设置 `PERF_PROXY` 时，还把 `/home/runner/software/anchors/`
只读挂载到容器内的 `/etc/pki/ca-trust/source/anchors/`，先执行
`update-ca-trust extract`。随后仅在本次容器内把 openEuler 软件源改为
`repo.huaweicloud.com/openeuler`。没有配置代理时跳过证书挂载和更新。

容器内以 root 执行 `dnf install -y python3 python3-pip git gcc make coreutils
findutils tar gzip procps-ng`，然后以 Runner 用户执行以下安装命令：

```bash
git clone --depth 1 --branch v0.7.2 --filter=blob:none --sparse \
  https://github.com/Eventual-Inc/Daft.git "${PERF_WORK_DIR}/daft-source"
git -C "${PERF_WORK_DIR}/daft-source" sparse-checkout set benchmarking
python3 -m venv "${PERF_WORK_DIR}/venv"
"${PERF_WORK_DIR}/venv/bin/python" -m pip install \
  -i https://mirrors.aliyun.com/pypi/simple/ --only-binary=daft \
  -r "${PERF_WORK_DIR}/requirements.txt"
"${PERF_WORK_DIR}/venv/bin/python" -c 'import daft; print(daft.__version__)'
```

`requirements.txt` 和 `tpch_driver.py` 在安装前从 `scripts/reference/` 复制到
本次工作目录。若 `/home/runner/software/daft/wheels/<架构>/` 有完整离线依赖集，
脚本先从本地安装；缺包时回退到上面的 PyPI 镜像。最后一条命令必须输出
`0.7.2`，并保存实际安装列表 `pip-freeze.txt`。

脚本只稀疏检出上游 `benchmarking/`，避免未构建的 `daft/` 源码遮蔽 wheel。
按照附件，在查询源码的 q13 中将 `col("O_COMMENT").match(` 改为语义相同的
`.regexp(`；差异保存为 `daft-source-patch.txt`。Daft wheel 本身不打补丁。

## 数据与运行顺序

1. `build` 检查本机持久目录 `/home/runner/software/daft/tpch-data/100_0/100/`
   的 `parquet/` 和 `parquet.sha256`。两者均存在则复用；均不存在则在本次容器内
   生成；只有一项或存在未完成的中间数据时，拒绝覆盖并报错。
2. 首次生成数据时，脚本先检查数据盘至少有 150 GB 空余，再从上游源码目录执行：

   ```bash
   "${PERF_WORK_DIR}/venv/bin/python" -m benchmarking.tpch.data_generation \
     --tpch_gen_folder /home/runner/software/daft/tpch-data \
     --scale_factor 100 --generate_parquet
   ```

   生成后写出逐文件 SHA-256 清单，清理本次生成的中间 `.tbl` 文件；不删除
   Parquet 和清单。数据生成日志保存为 `data-generation.log`。
3. `start` 确认私有容器、venv、Parquet 和清单就绪。`test` 再运行
   `scripts/results/verify_data.py`，检查 8 张表、文件集合及逐文件 SHA-256。
4. `test` 在容器内进入 `${PERF_WORK_DIR}/daft-source`，使用私有 venv 执行
   附件原版驱动。测试命令形态如下：

   ```bash
   DAFT_RUNNER=native DAFT_PROGRESS_BAR=0 \
     "${PERF_WORK_DIR}/venv/bin/python" "${PERF_WORK_DIR}/tpch_driver.py" \
     --parquet /home/runner/software/daft/tpch-data/100_0/100/parquet \
     --out "${RESULTS_DIR}" --rounds 4
   ```

5. 同一驱动随后以 `--mode answers` 导出 22 个查询答案。脚本解析
   `timings.jsonl`，要求 22 条查询均完成 4 轮；第 1 轮预热，每条查询取
  第 2–4 轮墙钟时间的中位数。`stop` 只移除本次私有容器，不删除持久数据。

测试不继承代理或 `DAFT_*`、`RAY_*` 调优变量；只设置
`DAFT_RUNNER=native` 和 `DAFT_PROGRESS_BAR=0`。数据集优先使用本机已有文件，
不会在每次运行时重新生成。

## 指标与产物

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `q01/wall_time` 至 `q22/wall_time` | `timings.jsonl` 中第 2–4 轮的中位数 | 秒 | 越小越好 |

报告列出 22 条查询各自的耗时，不把它们合并为单一总分。

| 产物 | 内容 |
|---|---|
| `benchmark_daft_raw.log`、`timings.jsonl` | 完整控制台输出及 4 轮原始计时、错误 |
| `round_1.csv` 至 `round_4.csv` | 附件驱动生成的逐轮 CSV |
| `answers/q01.parquet` 至 `answers/q22.parquet` | 查询答案，供结果留存和正确性核对 |
| `benchmark_daft.json` | 22 项正式指标和数据签名 |
| `data-generation.log` | 首次生成数据时的日志；复用数据时不生成 |
| `daft-source-revision.txt`、`daft-source-patch.txt`、`pip-freeze.txt` | 实际源码提交、q13 差异及 Python 包版本 |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

在当前 Runner 的仓库根目录执行完整流程：

```bash
bash software/Bigdata/daft/daft_test.sh \
  --version 0.7.2 \
  --variant base \
  --results-dir /home/runner/daft-results/0.7.2
```

结果位于 `/home/runner/daft-results/0.7.2/`。独立运行可加 `--keep-workdir`
保留本次私有工作目录排查问题；容器仍会停止并移除。默认清理本次工作目录，
但保留传入的结果目录和 `/home/runner/software/daft/tpch-data/`。

本用例随仓库保留附件原版 [`report.py`](scripts/reference/report.py) 和
[`oob.sh`](scripts/reference/oob.sh) 供核对；正式测试使用原版
`tpch_driver.py`，不执行附件 `oob.sh` 的宿主机 venv 部署命令。
