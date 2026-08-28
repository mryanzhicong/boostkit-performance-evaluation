# Go 性能测试说明

本目录使用 Go 官方发布的 Linux 预编译二进制包，并运行 Go 官方
`golang.org/x/benchmarks` 的 Go test 基准，对 x86_64 与 aarch64 进行开箱性能
对比。

Framework 通过 `case.yaml` 调用 `golang_test.sh` 的 `build`、`start`、`test`、
`stop` 四阶段；直接执行入口脚本会按相同顺序运行并生成单机结果。

当前清单支持 `1.26.7` 与 `1.27.0`；脚本的默认版本为 `1.27.0`。

## 安装

这里的 `build` 阶段实际是部署官方二进制包，不编译 Go 源码。按目标架构选择：

| 架构 | 包名 |
|---|---|
| `x86_64` | `go<版本>.linux-amd64.tar.gz` |
| `aarch64` | `go<版本>.linux-arm64.tar.gz` |

包的获取顺序如下：

1. Runner 离线目录 `/home/runner/software/golang/<包名>`；
2. Go 官方发布地址 `https://go.dev/dl/<包名>`。

脚本为清单中的每个“版本 + 架构”声明官方 SHA-256。本地包和下载包都按该值在
解压前校验，校验失败立即退出。核心命令形态如下：

```bash
curl -fsSL --retry 3 --connect-timeout 30 \
  -o go1.27.0.linux-amd64.tar.gz \
  https://go.dev/dl/go1.27.0.linux-amd64.tar.gz
sha256sum go1.27.0.linux-amd64.tar.gz
tar -xzf go1.27.0.linux-amd64.tar.gz -C "${PERF_WORK_DIR}/go-install" --strip-components=1
```

解压目标为本次任务私有目录 `${PERF_WORK_DIR}/go-install`。Go 的临时目录、模块
缓存、编译缓存和 GOPATH 位于
`/home/runner/golang-work/<版本>/<架构>/<运行 ID>`，不写入 `/tmp`。脚本执行以下命令，
确认实际版本和二进制架构与清单一致：

```bash
"${PERF_WORK_DIR}/go-install/bin/go" version
"${PERF_WORK_DIR}/go-install/bin/go" env GOARCH
```

脚本检查 `git`、`curl`、`gcc`、`tar`、`gzip`、`sha256sum`、`awk`、`python3`、
`perf`；缺失时通过 `dnf`、`yum` 或 `apt-get` 自动安装。Go 二进制位于
任务私有安装目录。

## 官方测试矩阵

`start` 阶段准备固定提交的官方 benchmarks 仓库：

```text
仓库：https://github.com/golang/benchmarks.git
提交：70693762b6a0d7f393892f0ace40979e3cbe5737
```

脚本从上述 Go 官方组织仓库抓取固定提交。测试阶段采用该提交中
`cmd/bench/gotest.go` 的官方 Go test 基准命令：

```bash
cd "${PERF_WORK_DIR}/go-benchmarks"
"${PERF_WORK_DIR}/go-install/bin/go" test -v -run=none -short -bench=. -count=6 \
  golang.org/x/benchmarks/...
```

该命令覆盖官方仓库中带 benchmark 的 Go test 包；`-short`、`-bench=.` 和
`-count=6` 均与官方 `cmd/bench/gotest.go` 一致。完整原始控制台输出保存为
`benchmark_go_bench.txt`。

可脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/golang/golang_test.sh \
  --version 1.27.0 \
  --results-dir /home/runner/golang-results/1.27.0
```

## 指标

`cmd/bench` 使用标准 Go benchmark 格式。一条原始结果可包含多个“数值 + 单位”
字段，例如：

```text
BenchmarkExample-8  100  12.5 ns/op  4 B/op  2 allocs/op
```

报告保留每个原始字段，不筛选为单一 `ns/op` 指标，也不计算平均值、综合分或相对
评分。为确保跨包、同名 benchmark 和多单位字段能唯一对齐，结构化结果以：

```text
<原始 pkg 标签> :: <原始 Benchmark 名称> :: <原始单位>
```

作为机器唯一键；三个组成部分均逐字来自官方输出。`benchmark_golang.json` 同时
保留 `source_package`、`source_benchmark`、`source_field`、`raw_value` 和
`raw_unit`，因此可定位回原始输出。

优化方向仅由原始单位确定：以 `/s` 或 `/sec` 结尾的吞吐字段为“越大越好”；其他
字段（例如 `ns/op`、`B/op`、`allocs/op`、`total-bytes`）为“越小越好”。同一原始
字段在两个架构上使用相同名称、单位和方向。

## 结果与清理

`case.yaml` 声明以下必需产物：

- `benchmark_go_bench.txt`：官方 Go test 基准命令的完整控制台输出；
- `benchmark_golang.json`：由原始 benchmark 字段规范化后的结构化结果。

Go 基准没有后台服务。`stop` 阶段解除本次任务 Go 运行目录中的只读权限并删除该
目录。独立执行时，脚本还会删除本次任务在
`/tmp/golang-perf/local-<运行 ID>` 创建的私有工作目录；指定
`--keep-workdir` 时保留该目录用于排查。`--results-dir` 指定的结果目录不会被删除。
