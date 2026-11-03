# Daft 0.7.2 TPC-H 性能测试

本用例在当前这一台 Runner 上，按其实际架构运行官方 Daft 0.7.2。
测试依据为随用例提供的《Daft 0.7.2 开箱性能对比测试指导（TPC-H）》；
正式口径为 **SF100、native runner、22 条查询、4 轮**，第 1 轮预热，
每条查询取其余 3 轮墙钟时间的中位数，单位为秒，越低越好。
TPC-H 数据在当前 Runner 的持久目录生成一次，后续任务复用；每次测试前逐文件核验 SHA-256。
容器不设置 CPU/内存限额，也不绑核或修改 Daft 引擎。

## 软件与工具

| 项目 | 来源与版本 | 本次任务的位置 |
|---|---|---|
| Daft | 官方 PyPI wheel `daft==0.7.2` | `${PERF_WORK_DIR}/venv` |
| TPC-H 查询 | [Daft 上游](https://github.com/Eventual-Inc/Daft) `v0.7.2` 的 `benchmarking/tpch/` | `${PERF_WORK_DIR}/daft-source/benchmarking/tpch/` |
| 多轮测试驱动 | 附件原版 `tpch_driver.py`，仓库内[副本](scripts/reference/tpch_driver.py) | `${PERF_WORK_DIR}/tpch_driver.py` |
| 依赖 | 附件原版 [requirements.txt](scripts/reference/requirements.txt) | 私有虚拟环境 |
| 系统镜像 | openEuler 24.03 LTS SP4 官方 Docker 归档 | 本次私有容器 |

只稀疏检出上游 `benchmarking/`，避免未构建的 `daft/` 源码遮蔽已安装的 wheel。
按照附件，在**测试查询源码**的 q13 中将
`col("O_COMMENT").match(` 改为语义相同的 `.regexp(`；Daft wheel 不打补丁。
该变更作为 `daft-source-patch.txt` 归档，报告参数也明确标记。

`base` 使用上述官方 wheel；`optimized` 尚未实现，选择后会明确失败。
工作流只需选择当前 Runner 对应的一个架构；本次没有第二台 Runner。

## 目录与环境

| 内容 | 目录或变量 | 说明 |
|---|---|---|
| 本次任务 | `PERF_WORK_DIR=/home/runner/boostkit-perf/daft/<版本>/<架构>/<run-id>` | Framework 提供；源码、虚拟环境、临时文件在此 |
| 正式结果 | `RESULTS_DIR=.perf-output/Bigdata/daft/<版本>/<架构>/<run-id>` | Framework 提供；日志、JSON 和报告在此 |
| 持久数据 | `DAFT_DATA_ROOT=/home/runner/software/daft/tpch-data` | 当前 Runner 保存一次；已有完整数据时容器只读挂载 |
| 官方镜像缓存 | `/home/runner/software/openEuler-24.03-LTS-SP4/` | 优先本地归档及 `.sha256sum`，缺失时下载 |
| 代理证书 | `/home/runner/software/anchors/` | 仅配置 `PERF_PROXY` 时挂载入容器 |
| 可选离线 wheel | `/home/runner/software/daft/wheels/<架构>/` | 同架构、同 Python 版本的完整依赖集；缺包时回退 PyPI 镜像 |

需要可用的 Docker daemon、容器镜像、GitHub/PyPI 访问及持久磁盘。
默认数据 SF100 的 Parquet 约 31 GB；首次生成还需约 110 GB 中间 CSV 空间，
脚本在生成前要求数据盘至少有 150 GB 空余。容器使用宿主网络，测试只读取本地数据。
宿主机需有 `curl`、`sha256sum`、`docker`、`python3`；容器内用 `dnf` 安装
Python、Git、gcc、make 等，不修改宿主机 Python 或仓库配置。

## 数据准备：当前 Runner 自动完成

正常运行 Framework 工作流或下文的 `daft_test.sh` 即可，无需另行运行数据准备命令。
`build` 阶段先检查本机持久数据目录：

| 当前状态 | 行为 |
|---|---|
| Parquet 与 `parquet.sha256` 均不存在 | 在本次私有容器内调用上游数据生成模块，随后生成清单；正式测试前校验 |
| 两者均存在 | 复用；正式测试前逐文件校验 SHA-256 |
| 只存在其中之一，或留下未完成的中间数据 | 报错并保留现场，不覆盖或当作完整数据使用 |

首次生成使用上游原始命令：

```bash
python -m benchmarking.tpch.data_generation \
  --tpch_gen_folder /home/runner/software/daft/tpch-data \
  --scale_factor 100 --generate_parquet
```

产物位于 `/home/runner/software/daft/tpch-data/100_0/100/parquet/`，
清单位于同级 `parquet.sha256`，生成日志写入本次结果目录的 `data-generation.log`。
清单写出后，脚本清理本次生成的中间 `.tbl` 文件；不删除 Parquet 和清单。
如需在当前 Runner 手动复核数据，可执行：

```bash
python3 software/Bigdata/daft/scripts/results/verify_data.py \
  /home/runner/software/daft/tpch-data/100_0/100/parquet \
  /home/runner/software/daft/tpch-data/100_0/100/parquet.sha256
```

校验脚本检查 8 张表、文件集合及逐文件 SHA-256。清单签名写入本次结果参数。
首次生成可能耗时较长；以后复用本机持久数据，无需重复生成。

## 构建与启动

`build` 调用 `scripts/builders/dispatch.sh` 的 `build_daft`。
基础版在本次私有目录中加载 openEuler 24.03 LTS SP4 镜像，校验镜像的
SHA-256、架构及系统版本后启动容器：

```bash
docker run --detach --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=/home/runner/software/daft/tpch-data,target=/home/runner/software/daft/tpch-data" \
  <已验证的openEuler镜像> sleep infinity
```

上例展示首次生成数据时的可写挂载；复用完整数据时脚本加 `readonly`。
实际脚本还设置本次运行 ID 的容器名和标签，并在配置 `PERF_PROXY` 时挂载代理 CA。
随后在容器内执行 `dnf install`、稀疏检出上游 `v0.7.2`、
`python3 -m venv`、`pip install -r requirements.txt`。
容器内的 openEuler 软件源改为华为镜像站；代理仅用于安装和下载阶段。
构建完成后从已安装的 `daft.__version__` 读取实际版本，必须为 `0.7.2`。

`start` 阶段重新定位私有容器，确认数据和清单存在；`test` 开始前逐文件校验。
`stop` 只删除带有本次运行 ID 标签的容器，不清理或修改持久数据。

## 正式测试与结果

`test` 阶段再次校验数据后，在容器内从上游源码目录调用**附件原版驱动**：

```bash
DAFT_RUNNER=native python /home/runner/boostkit-perf/daft/<本次任务>/tpch_driver.py \
  --parquet /home/runner/software/daft/tpch-data/100_0/100/parquet \
  --out "${RESULTS_DIR}" --rounds 4
```

实际使用私有 venv 的 Python，不继承代理、`DAFT_*` 或 `RAY_*` 调优变量；
只显式设置 `DAFT_RUNNER=native` 和 `DAFT_PROGRESS_BAR=0`。
驱动复用上游 `answers.py` 查询及 `MetricsBuilder.collect_metrics` 计时，
每条查询结束即写 `timings.jsonl`。某查询失败会继续记录其余查询，
但整个阶段最终失败，不会生成缺项的成功报告。

| 输出 | 内容 |
|---|---|
| `benchmark_daft_raw.log` | 驱动的完整控制台输出 |
| `timings.jsonl` | 4 轮 × 22 条原始墙钟时间及错误 |
| `round_1.csv` 至 `round_4.csv` | 附件驱动生成的上游格式 CSV |
| `answers/q01.parquet` 至 `q22.parquet` | 附件驱动导出的查询结果，供结果留存与正确性核对 |
| `benchmark_daft.json` | 22 项正式指标与数据签名 |
| `pip-freeze.txt` | 容器内实际安装的 Python 包版本 |
| `daft-source-revision.txt`、`daft-source-patch.txt` | 上游提交与 q13 兼容补丁原文 |
| `normalized_result.json`、`report.md` | Framework 生成的归一化结果与单架构报告 |

指标名为 `q01/wall_time` 至 `q22/wall_time`，每项取第 2–4 轮中位数，
单位为秒，`lower_is_better`。当前单架构报告列出 22 项查询用时。
仓库保留附件 `report.py` 的[原版副本](scripts/reference/report.py)供核对；
Framework 不把双机倍率混进本次单架构指标。
附件的 [`oob.sh`](scripts/reference/oob.sh) 也原样保留供核对；
其宿主机 venv 部署命令不用于本容器工作流。

## 独立运行与检查

在当前 Runner 的仓库根目录执行：

```bash
bash software/Bigdata/daft/daft_test.sh \
  --version 0.7.2 --variant base \
  --results-dir /home/runner/daft-results/0.7.2
```

独立入口与 Framework 调用同一组阶段函数，产生 `results.json`、
`status.json` 和 `report.md`。排障时加 `--keep-workdir` 保留容器以外的工作文件。
正常结束时仅删除本次 `local-<run-id>` 工作目录，不删除数据目录。

本用例与附件的区别仅在执行载体和结果接入：正式安装、测试均在私有
openEuler 容器内；附件是在宿主机私有 venv 中执行。上游查询、驱动、
SF100、轮数、预热和中位数口径保持一致。可选的 Ray runner 不在本次正式矩阵中。
