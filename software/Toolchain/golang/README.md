# Go 1.26.9 性能测试

本用例比较上游官方 Go 1.26.9 在 x86_64 与 aarch64 上的开箱性能。测试工具是 Go 项目的 [Bent](https://pkg.go.dev/golang.org/x/benchmarks/cmd/bent)；基准清单取自《Go基准测试集及测试方法》的 20 项、15 个 suite。只运行一个 `Baseline` 配置，不构建或测试 `goservicesopt`，也不启用该文档的 `feat` 编译开关。

## 安装

`build` 阶段优先读取 `/home/runner/software/golang/go1.26.9.linux-<amd64|arm64>.tar.gz`；若不存在，则从 `https://go.dev/dl/` 下载相同文件。下载包和离线包均以脚本内声明的官方 SHA-256 校验，解压到本次任务的 `${PERF_WORK_DIR}/go-install`，然后检查 `go version` 与架构。

脚本检查 `git`、`curl`、`gcc`、`tar`、`gzip`、`sha256sum`、`awk`、`python3` 和 `nproc`；缺失时通过 `dnf` 安装。Go 的模块缓存、编译缓存、GOPATH 和临时文件位于 `${PERF_WORK_DIR}/runtime`，不使用 Runner 的系统 Go 测量性能。

如需复用预下载的 Bent 模块，在每台 Runner 上把 `bent-go1.26.9-modules.tar.gz` 解压到固定目录：

```bash
mkdir -p /home/runner/software/golang/bent-modules
tar -xzf bent-go1.26.9-modules.tar.gz -C /home/runner/software/golang/bent-modules
```

解压后应存在 `/home/runner/software/golang/bent-modules/cache/download`，且 `runner` 用户可读取。脚本把它复制到本次私有缓存，先用仅访问本地文件的 Go 代理验证 Bent 安装和 15 个 suite 的 `go get`。验证通过就跳过网络预取；若缓存不完整，才按下述网络代理逐项补齐，再做一次离线验证。验证通过后，正式 Bent 运行只访问本次私有缓存，不会中途联网。可用 `BENT_MODULE_CACHE_DIR` 指定其他已解压目录，其下仍须是 `cache/download`。

## 测试

`test` 阶段使用本次安装的 Go 执行：

```bash
go install golang.org/x/benchmarks/cmd/bent@v0.0.0-20261009192853-4a545adeb0d5
bent -I
bent -B benchmarks.toml -C configurations.toml -N 15 -L .bent-stamps.log
```

`bent -I` 在私有工作目录初始化工具文件。脚本随后把 [benchmarks.toml](scripts/benchmarks.toml) 和 [suites.toml](scripts/suites.toml) 复制到该目录；它们固定了附件列出的 20 个基准名称、筛选正则、15 个第三方 suite 及其版本。MinIO 的发布标签固定为同一提交的 Go 伪版本，使其可从离线缓存解析。`configurations.toml` 由脚本生成：

```toml
[[Configurations]]
  Name = "Baseline"
  RunEnv = ["GOGC=100", "GOMAXPROCS=<本机 nproc 实际值>"]
  Root = "<本次任务的 go-install 目录>"
```

`-N 15` 表示每项运行 15 轮。测试不绑核；两个架构各用自己的 `nproc`，原始 benchmark 名称中的并发度后缀保留。若后缀不同，不会改名强行对齐。

缓存不完整时，正式测试优先通过华为云 Go 模块镜像补齐，失败时回退到 `goproxy.cn`；开发工作流设置 `PERF_DIRECT_NETWORK=true`，补齐时使用 `GOPROXY=direct`。本地核验仅在缓存副本中运行，离线 Bent 阶段使用该缓存的 `file://` Go 代理。Bent 不开启详细命令回显，避免把代理认证信息写入测试日志。

## 指标与结果

Bent 原生 `bench/<runstamp>.Baseline.stdout` 保存为 `benchmark_go_bench.txt`。脚本对 20 项逐一检查：每项必须有恰好 15 条正数 `ns/op` 原始测量，取中位数作为报告值；缺项、多项或出现不同源 benchmark 时测试失败。指标名称包含 Bent 的原始 shortname、原始 benchmark 名称（含并发后缀）和 `ns/op`，数值越低越好。

结果目录保存：

| 文件 | 内容 |
|---|---|
| `bent-run.log` | Bent 安装与运行的控制台日志。 |
| `benchmark_go_bench.txt` | Bent 原始 `.stdout`，包含每项 15 轮测量。 |
| `benchmark_golang.json` | 20 项 `ns/op` 中位数及原始名称。 |
| `benchmarks.toml`、`suites.toml`、`configurations.toml` | 本次实际使用的配置副本。 |

Framework 依次调用 `build`、`start`、`test`、`stop`；`stop` 删除本次私有 Go 运行目录。也可在目标机器独立执行：

```bash
bash software/Toolchain/golang/golang_test.sh \
  --version 1.26.9 \
  --results-dir /home/runner/boostkit-perf/golang/results/1.26.9
```
