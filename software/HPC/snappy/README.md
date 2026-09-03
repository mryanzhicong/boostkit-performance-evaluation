# Snappy 性能测试说明

本目录从 Google Snappy 官方仓库构建指定版本，并执行官方
`./build/snappy_benchmark`。Framework 通过 `case.yaml` 调用 `snappy_test.sh` 的
`build`、`start`、`test`、`stop` 四个阶段；直接执行脚本可完成相同流程。

当前清单支持 `1.2.1`、`1.2.2`，默认版本为 `1.2.2`。

## 构建与安装

Snappy 从官方 GitHub 标签浅克隆，在任务隔离目录中构建，不安装系统级 Snappy
包。入口脚本会检查 `git`、`python3`、`cmake`、`make`、`c++` 等命令；缺失时通过
`dnf` 自动安装对应包，非 root Runner 使用 `sudo -n dnf`。

构建沿用官方 README 的步骤，并以 Release 配置生成 benchmark：

```bash
git clone --branch 1.2.2 --depth 1 https://github.com/google/snappy.git snappy-source
cd snappy-source
git submodule update --init
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../
make
```

构建完成后必须存在 `build/snappy_benchmark`，并从 `CMakeLists.txt` 校验实际版本
与请求版本一致。

## 性能测试

Snappy 不启动后台服务。`start` 阶段只验证 `snappy_benchmark` 和仓库自带
`testdata` 可用；`test` 阶段在源码目录运行官方默认命令：

```bash
cd snappy-source
./build/snappy_benchmark
```

该命令的完整控制台输出保存为 `benchmark_google.txt`。解析器从每个
`bytes_per_second=<值><单位>/s` 字段读取吞吐并统一换算为 MiB/s；没有修改官方
benchmark 的运行参数。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/snappy/snappy_test.sh \
  --version 1.2.2 \
  --results-dir /home/runner/boostkit-perf/snappy/results/1.2.2
```

## 指标

报告只保留下列四个官方核心场景的 `bytes_per_second`，名称保持官方 benchmark
名称；所有指标单位为 MiB/s，越大越好。

| 官方场景 | 含义 |
|---|---|
| `BM_ZFlatAll/1` | 平坦数据的压缩场景 1 |
| `BM_ZFlatAll/2` | 平坦数据的压缩场景 2 |
| `BM_UFlatMedley` | 平坦混合数据解压场景 |
| `BM_UValidateMedley` | 带校验的混合数据解压场景 |

若官方输出缺少任一上述场景，测试直接失败，避免空指标或不完整指标进入报告。

## 结果与清理

必需产物为 `benchmark_google.txt`（官方原始输出）和 `benchmark_snappy.json`
（四项结构化吞吐）。没有后台服务需要停止；任务结束时只删除本次运行创建的隔离
工作目录，独立执行会额外保存环境、构建信息、日志与报告。
