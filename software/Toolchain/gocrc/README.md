# gocrc 1.24.6 CRC32 Castagnoli 性能测试（openEuler golang 优化版）

本用例测量 Go 运行时 `hash/crc32` 包中 Castagnoli 多项式（硬件 CRC32 指令路径）的
微基准性能：**在同一个私有 openEuler 24.03 LTS SP4 容器内**用官方 Go 1.23.0 作为
`GOROOT_BOOTSTRAP` 自举编译 openEuler 优化版 golang `go1.24.6`，再用编译出的
go1.24.6 工具链测量基准并输出 benchstat 统计报告。**AMD EPYC 9654（x86_64）与
Kunpeng 950（aarch64）执行完全相同的步骤**，命令按本机架构自动选择 `amd64`/`arm64`；
Blue 正式证据只跑 aarch64（不派发 x86_64 Actions），x86_64 仅用于本地功能自测。

> 1.23.0 只作为编译 go1.24.6 的引导工具链，**不参与测量、不作为用例版本**；
> 用例版本与全部指标均为 1.24.6。

## 固定流程（两种环境一致）

1. **安装官方 Go 1.23.0（仅 bootstrap）**
   - 宿主机下载 `go1.23.0.linux-<amd64|arm64>.tar.gz`（优先 `mirrors.aliyun.com/golang`，
     回退 `go.dev/dl`，并按官方 SHA-256 校验；可预置在 `GO_OFFLINE_DIR`）；
   - 容器内 root 身份 `tar -C /usr/local -xzf go1.23.0.linux-<arch>.tar.gz`；
   - `PATH=/usr/local/go/bin:$PATH`、`GOPATH=$HOME/go`、`GOTOOLCHAIN=local`，
     `go version` 必须为 `go1.23.0 linux/<arch>`；该工具链随后只用于 `make.bash`。
2. **下载优化后代码并编译**
   - 宿主机 `git clone https://gitcode.com/openeuler/golang.git` 到
     `${PERF_WORK_DIR}/golang-src`，`git checkout go1.24.6`（记录 commit）；
     容器内不装 git：`git` 的 dnf 事务会拉入 dbus-daemon，而只读 `/etc/passwd`
     下其 rpm scriptlet 会失败；
   - 该目录以 bind mount 出现在容器内 `/home/local/golang`（与手册路径一致）；
   - 容器内 `export GOOS=linux; export GOARCH=<amd64|arm64>;
     export GOROOT_BOOTSTRAP=/usr/local/go; cd /home/local/golang/src; ./make.bash`；
   - `PATH=/home/local/golang/bin:$PATH`、`GOPATH=$HOME/go`、`GOTOOLCHAIN=local`，
     `go version` 必须为 `go1.24.6 linux/<arch>`。
3. **测试**
   - 用 go1.24.6 执行 `go install golang.org/x/perf/cmd/benchstat@latest`
     （`GOPATH/bin/benchstat`）；
   - 用 go1.24.6 跑一次
     `go test hash/crc32 -run='^$' -bench='CRC32/poly=Castagnoli/size=(4|32)kB' -cpu=1`：
     1 次 warmup + 6 次测量采样（`-count`），中位数与全部样本都保留；
   - `benchstat benchmark_go1.24.6.txt` 生成统计报告 `benchstat.txt`。

## 容器契约

- 每个 run 一个容器：`boostkit-gocrc-<arch>-<run-id>`，host network，与 runner 相同的
  uid/gid，`--ulimit nofile=1048576:1048576`；
- 挂载本次 `PERF_WORK_DIR`（Go 工具链、缓存、源码树）、`RESULTS_DIR`、用例目录（只读），
  以及 `${PERF_WORK_DIR}/golang-src` → `/home/local/golang`；
- 容器内 `dnf install --setopt=install_weak_deps=False` 安装
  `tar gzip coreutils findutils which ca-certificates gcc`（宿主机 `/etc/passwd` 只读，
  必须关闭弱依赖；不装 git）；
- `stop` 阶段幂等删除容器并清理私有 Go 运行时缓存、GOPATH 与源码树，不遗留容器或 root 文件。

容器公共块位于 `scripts/common.sh` 的 `container-runtime` 标记区间，由
`adaptation/scripts/add-container-block.py` 生成，不要手改该区间。

## 指标与结果

每个场景（4 kB / 32 kB × `align=0/1`，共 4 项）产出 1 个指标：

| 指标 | 含义 | 单位 | 方向 |
|---|---|---|---|
| `crc32_castagnoli_<size>kb_align<n>` | openEuler golang go1.24.6 中位数 | ns/op | 越低越好 |

Go 1.24 的 `CRC32/poly=Castagnoli` 微基准包含 `align=0/1` 两组子基准；解析器要求
「4 项 × 6 次」完整集合（若工具链只有 4kB/32kB 两项，则要求「2 项 × 6 次」），
缺项/多项/非正值/benchstat 报告缺失一律失败，绝不补零。

结果目录（`RESULTS_DIR`）内容：

| 文件 | 内容 |
|---|---|
| `build_variant.json` | 本次变体标签 + bootstrap/测量工具链版本 + 架构 |
| `bootstrap-go-version.txt` | 引导工具链 `go version` 原始输出（1.23.0，不参与测量） |
| `measured-go-version.txt` | 被测工具链 `go version` 原始输出（1.24.6） |
| `source-commit.txt` | openEuler golang 源码 commit |
| `benchstat-version.txt` | benchstat 二进制模块信息 |
| `warmup-go1.24.6.log` | warmup 轮原始 stdout |
| `benchmark_go1.24.6.txt` | 6 次测量原始 stdout |
| `benchstat.txt` | benchstat 统计报告（均值/置信区间） |
| `benchmark_go.json` | 严格解析后的 4 个指标（中位数 + 全部样本）、工具链版本、benchstat 路径 |
| `runs/crc32-castagnoli/rep<i>.{json,log}` | 每次采样记录与原始行 |
| `toolchain-version.txt` | 被测工具链版本（1.24.6） |
| `actual-version.txt` | Framework 版本契约文件，固定为用例版本 1.24.6 |
| `compiler-identity.txt` | 容器内 gcc 版本 |

## 独立运行

```bash
bash software/Toolchain/gocrc/gocrc_test.sh \
  --version 1.24.6 --results-dir /home/runner/boostkit-perf/gocrc-results
```

可选环境变量：`GO_OFFLINE_DIR`（离线归档目录）、`GO_OPTIMIZED_REPO`、
`GO_OPTIMIZED_BRANCH`、`GO_BOOTSTRAP_VERSION`、`GO_GOPROXY`、`WARMUP_REPS`、
`MEASURE_REPS`、`PERF_WORK_DIR`、`EXPECTED_ARCH`。Framework 通过 `case.yaml` 调用
同一组阶段函数；`base`/`optimized` 下拉框只作为结果标签——一次运行只测量 go1.24.6。

## 已知限制

- 构建需要网络访问 `gitcode.com`（源码克隆）、`mirrors.aliyun.com`（Go 归档）与
  `repo.huaweicloud.com`（benchstat 模块）；离线 Runner 需预置 Go 归档与源码目录；
- 微基准使用 `-cpu=1`，衡量单核 CRC32 吞吐，不使用多核并发；
- Blue 正式证据只派发 aarch64；x86_64（AMD 9654）用本地 WSL 自测功能链路或手工执行
  同一 `gocrc_test.sh`。
