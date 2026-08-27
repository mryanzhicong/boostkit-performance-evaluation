# Zstd 性能测试说明

本目录从 Facebook Zstandard 官方仓库构建指定版本的 `tests/fullbench`，并保留该
程序输出的全部性能场景。Framework 通过 `case.yaml` 调用 `zstd_test.sh` 的四阶段
接口；直接执行该脚本使用相同流程。

当前清单支持 `1.5.6`、`1.5.7`，默认版本为 `1.5.6`。

## 构建与安装

Zstd 从官方 GitHub 标签浅克隆，在任务隔离目录中构建，不安装系统级 Zstd。运行
依赖 `git`、`python3`、`make`、C 编译器、`sed` 和 `tee`；当前脚本只校验这些
命令是否存在，不自动安装缺失依赖。

构建命令为：

```bash
git clone --branch v1.5.6 --depth 1 https://github.com/facebook/zstd.git zstd-source
cd zstd-source/tests
make fullbench
```

构建后必须存在 `zstd-source/tests/fullbench`。脚本从 `lib/zstd.h` 读取版本并校验
与请求版本相同。

## 性能测试

Zstd 没有后台服务。`start` 阶段验证 `fullbench` 可执行；`test` 阶段直接运行：

```bash
./tests/fullbench
```

没有传入额外参数，完全使用 `fullbench` 的默认样本和默认场景。完整原始输出写入
`benchmark_fullbench.json` 的 `raw_output` 字段，解析器读取欢迎行中的版本、样本
字节数，以及每个 `编号#场景: <速度> MB/s` 结果行。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/zstd/zstd_test.sh \
  --version 1.5.6 \
  --results-dir /home/runner/zstd-results/1.5.6
```

## 指标

所有由官方 `fullbench` 输出的场景都会进入报告，不做人为筛选或跨场景汇总。每项
指标名称采用官方场景文本，数值是该行的速度：

| 原始字段 | 单位 | 优化方向 | 说明 |
|---|---:|---|---|
| `<编号>#<场景>: <速度> MB/s` 中的 `<速度>` | MB/s | 越大越好 | 该压缩、解压或内部操作场景的处理速度 |

同一编号和场景若在输出中重复，只保留该组合最后一次出现的结果；缺少版本、样本大小、
性能行或出现非正速度时测试失败。

## 结果与清理

必需产物为 `benchmark_fullbench.json`，其中同时包含全部结构化指标和
`raw_output`。没有后台服务需要停止；任务结束仅清理本次任务创建的隔离工作目录。
