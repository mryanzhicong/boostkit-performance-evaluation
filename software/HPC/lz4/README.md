# LZ4 性能测试说明

本目录从 LZ4 官方仓库构建 `tests/fullbench`，以固定提交的 Silesia Corpus 构造
`silesia.tar`，并运行四条明确的压缩/解压命令。Framework 通过 `case.yaml` 调用
`lz4_test.sh` 的四阶段接口；直接执行入口脚本会走同一流程。

当前清单支持 `1.9.3`、`1.10.0`，默认版本为 `1.9.4`。

## 构建与安装

LZ4 从官方 GitHub 标签浅克隆，在任务隔离目录中构建，不安装系统级 LZ4。脚本会
检查 `git`、`python3`、`make`、C 编译器、`sed` 和 `tee`；缺失时通过 `dnf` 自动
安装对应依赖，非 root Runner 使用 `sudo -n dnf`。

构建使用官方 fullbench 目标：

```bash
git clone --branch v1.10.0 --depth 1 https://github.com/lz4/lz4.git lz4-source
cd lz4-source
make -C tests fullbench
```

构建后必须存在 `tests/fullbench`，版本从 `lib/lz4.h` 读取并与请求版本校验。

## 测试数据与性能测试

`start` 阶段从 GitHub 仓库
`https://github.com/MiloszKrajewski/SilesiaCorpus.git` 获取固定提交
`3f3fa2cdbbb3795c903b74e774acb309e1360337`，验证 12 个原始成员的尺寸和 MD5，
按固定顺序打包为 `silesia.tar`。生成后的 tar SHA-256 也写入结果，保证两种架构
使用相同输入。

`test` 阶段执行以下四条命令。`--no-prompt` 禁用交互，`-i3` 表示每项至少循环
3 秒；`-B4` 是 64 KiB 块，`-B7` 是 4 MiB 块：

```bash
./tests/fullbench --no-prompt -i3 -B4 -c1 silesia.tar
./tests/fullbench --no-prompt -i3 -B4 -d4 silesia.tar
./tests/fullbench --no-prompt -i3 -B7 -c1 silesia.tar
./tests/fullbench --no-prompt -i3 -B7 -d4 silesia.tar
```

其中 `-c1` 对应 `LZ4_compress_default`，`-d4` 对应 `LZ4_decompress_safe`。四条命令
各自的完整原始输出保存在 `benchmark_fullbench.json` 相应结果的 `raw_output` 字段。

可脱离 Workflow 执行完整流程：

```bash
bash software/HPC/lz4/lz4_test.sh \
  --version 1.10.0 \
  --results-dir /home/runner/boostkit-perf/lz4/results/1.10.0
```

## 指标

报告按上述四条命令分组，每组仅提取对应官方函数行的 `MB/s` 速度，不对四组求
平均或综合评分。所有指标越大越好。

| 命令分组 | 选取的官方行 | 单位 |
|---|---|---:|
| `-B4 -c1` | `1-LZ4_compress_default` | MB/s |
| `-B4 -d4` | `4-LZ4_decompress_safe` | MB/s |
| `-B7 -c1` | `1-LZ4_compress_default` | MB/s |
| `-B7 -d4` | `4-LZ4_decompress_safe` | MB/s |

压缩场景还原样记录输入大小、压缩后大小和压缩百分比；这些是结果上下文，不作为
跨架构性能指标。任一命令未产生唯一且正数的目标速度时测试失败。

## 结果与清理

必需产物为 `benchmark_fullbench.json`，包含四组结构化结果、每组原始输出以及
Silesia 数据校验信息。没有后台服务需要停止；任务结束只删除本次运行的源码、
数据集和工作目录。
