# Ray 2.55.1 单机开箱性能测试

本用例在 x86_64、aarch64 各一台 Runner 上分别运行**官方原版 Ray 2.55.1**。Ray 安装和单机 Shuffle 测试均在本次任务的 openEuler 24.03 LTS SP4 私有容器内完成。没有使用 UB-Ray、补丁、远端 worker 或跨节点网络传输。因此报告衡量的是**单机 Shuffle**，不能解释为双机传输性能。

测试用例参考[《端到端测试指导手册：鲲鹏950 vs AMD 9654》](https://gitcode.com/gcw_Y0OblA3C/UB_based_Modification_Ray/blob/release-prep%2Fv1.5/test_documents/%E7%AB%AF%E5%88%B0%E7%AB%AF%E6%B5%8B%E8%AF%95%E6%8C%87%E5%AF%BC%E6%89%8B%E5%86%8C_%E9%B2%B2%E9%B9%8F950_vs_AMD9654.md)的官方 Ray 基线与 G5 Shuffle 档。双机档位中的每节点 16 CPU 改为单节点 16 CPU；保留官方脚本、50×80 MB 负载和 1 次预热＋7 次正式运行。单节点 object store 设为 16 GiB，对应原双节点合计容量。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Ray | PyPI 官方 `ray==2.55.1` Python 3.11 wheel；若有匹配架构的本地 wheel，优先使用 | 容器内 `${PERF_WORK_DIR}/ray-venv` |
| Shuffle 用例 | [Ray `ray-2.55.1` 标签的原始 `shuffle_test.py`](https://github.com/ray-project/ray/blob/ray-2.55.1/release/nightly_tests/shuffle/shuffle_test.py)，SHA-256 为 `38bac871b718d2192e325054bb0fadaad2c29b07263c893a083e15de564c55f6` | `${PERF_WORK_DIR}/shuffle_test.py` |
| 基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/` |
| Python | 容器内 openEuler `python3` 3.11 与 `python3-pip` | 容器内 `${PERF_WORK_DIR}/ray-venv` |

宿主机只需 Docker 和下载、校验工具。构建阶段先校验基础镜像归档及同名 `.sha256sum`，执行 `docker load`，再核对镜像架构和 openEuler 版本。每次任务创建带运行 ID 标签的独立容器，挂载 `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}`。容器使用宿主网络，不限制 CPU 或内存；额外设置 `--shm-size=20g`，供 16 GiB Ray object store 使用。只移除带本次任务标签的容器。

正式工作流设置 `PERF_PROXY` 时，容器只读挂载 `/home/runner/software/anchors/` 到证书锚点目录，并在容器内更新 CA；同时只在该容器内将 openEuler 仓库地址换为华为镜像。容器内通过 `dnf` 安装 Python 3.11、pip 和 `coreutils`。没有配置代理时不挂载证书，也不更新 CA。

Ray wheel 和测试脚本优先读取宿主机 `/home/runner/software/ray/` 下的 `ray-2.55.1-cp311-cp311-manylinux2014_<架构>.whl` 与 `shuffle_test.py`，复制到本次任务目录；缺失时下载。两架构 wheel 分别按 PyPI 发布的 SHA-256 校验，脚本也按固定 SHA-256 校验。随后在容器内创建私有虚拟环境并安装 wheel 及其依赖。不会在宿主机安装 Ray 或 Python。

## 构建与测试

Framework 的 `build` 阶段调用 `scripts/builders/dispatch.sh`。`base` 在容器内完整安装官方 Ray，并在容器内用 `import ray; print(ray.__version__)` 核对实际版本；`optimized` 暂未实现，会明确失败。容器镜像与生命周期函数集中在 `scripts/common.sh`，与 UnixBench 相同；后续 `start`、`test`、`stop` 共用。

`start` 在容器内检查 16 个可用 CPU 和 `/dev/shm` 至少 16 GiB 可用空间，不足时失败，不把 object store 悄悄放到 `/tmp`。容器将宿主机 `${PERF_WORK_DIR}/ray-temp` 单独挂载为容器内 `/r`，`test` 以 `/r` 作为 Ray `_temp_dir`；这样 Unix socket 路径足够短，而会话文件和日志仍保存在本次任务目录。测试注入官方用例所需的 `RAY_ADDRESS` 和 `TEST_OUTPUT_JSON`，运行原脚本：

```bash
python shuffle_test.py --num-partitions 50 --partition-size 80000000
```

正式运行前预热一次；随后正式运行七次。每轮最多 1800 秒，任何一轮失败、超时、缺少官方 JSON 或 `shuffle_time` 无效，整个测试失败，不用其余轮次凑数。测试进程在退出时关闭本次本地 Ray；`stop` 收集本次 Ray 日志并移除本次容器，不操作其他任务的容器或 Ray 进程。

## 指标与产物

| 文件 | 内容 |
|---|---|
| `${RESULTS_DIR}/shuffle-rounds/round-*.json` | 官方脚本逐轮写出的原始 JSON，含预热轮 |
| `${RESULTS_DIR}/benchmark_ray_raw.log` | 官方用例完整标准输出和错误输出 |
| `${RESULTS_DIR}/benchmark_ray.json` | 每轮耗时、固定负载参数及正式七轮中位数 |
| `${RESULTS_DIR}/ray-logs/` | 本次 Ray 的 raylet、GCS 日志（若已产生） |

报告只有 `shuffle_time` 一项，单位秒，越低越好。该值是**官方脚本 JSON 中 `shuffle_time` 的七次正式运行中位数**；预热轮保留但不计入。官方脚本的计时包含启动 benchmark 子进程等开销；本用例没有将其伪称为指导手册另行计算的 `shuffle_time_pure_s`。两架构以相同名称和固定负载对齐，机器硬件信息另外记录。

## 独立运行

在 Runner 上从仓库根目录执行：

```bash
bash software/Bigdata/ray/ray_test.sh \
  --version 2.55.1 --variant base \
  --results-dir /home/runner/ray-results/2.55.1
```

需要保留本次虚拟环境和 Ray 临时目录以排查时加 `--keep-workdir`；它不会保留容器。独立入口调用与 Framework 相同的构建、启动、测试、停止函数，并生成 `results.json`、`normalized_result.json`、`status.json` 和 `report.md`。Framework 分配的 `${PERF_WORK_DIR}` 由 Framework 清理；独立入口仅清理自己创建的私有工作目录。
