# Sonic Go 性能测试

本用例在 `x86_64` 和 `aarch64` 上测试 [ByteDance Sonic](https://github.com/bytedance/sonic) `v1.15.2` 的编码、解码与解析性能。两种架构使用相同的源码版本、测试脚本和指标口径。

| 项目 | 当前使用版本或来源 |
|---|---|
| 被测软件 | Sonic 官方 tag `v1.15.2` |
| 测试用 Go 工具链 | 从 [openEuler Go 源码](https://gitcode.com/openeuler/golang) `go1.24.6` 编译 |
| 测试脚本 | 本目录 `scripts/go/sonic_bench.sh` |

## 运行入口

软件入口为 `sonic_go_test.sh`；Framework 通过 `case.yaml` 分别调用构建、启动、测试和停止脚本。直接执行入口脚本也使用这些阶段函数。

正式与开发工作流提供 `base`、`optimized` 下拉选项，默认 `base`。基础版调用
`scripts/builders/base.sh` 完整构建；调优版入口位于
`scripts/builders/optimized.sh`，目前**尚未实现**，选择后会在构建阶段明确失败，
不会退回基础版。启动、测试和停止阶段共用 `scripts/stages/` 下的脚本。
`scripts/common.sh` 提供阶段间一致的私有路径约定，结果解析位于 `scripts/results/`；
`scripts/go/` 保留 `sonic_bench.sh` 与 `build_go.sh`，`scripts/lib_cpu.sh`、
`scripts/lib_gocache.sh` 提供绑核与构建缓存隔离。

也可以在仓库根目录独立执行完整流程：

```bash
bash software/HPC/sonic-go/sonic_go_test.sh --version 1.15.2 --variant base
```

指定结果目录用 `--results-dir <目录>`；排错时用 `--keep-workdir` 保留本次工作目录。未指定结果目录时，脚本将结果写入本用例的 `results/` 子目录（调优版位于该版本下的 `optimized/` 子目录）。独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；目前调优版只验证入口与明确失败行为，不执行性能测试。

正式工作流中基础版的 OBS 与 `performance-results` 路径不变；调优版归档到
`HPC/sonic-go/1.15.2/optimized/<时间戳_Run ID>/`。两种模式的测试负载和指标解析共用，构建阶段保存 `build_variant.json` 以标识实际选择。调优版不会更新基础版的 `baseline.json`。

## 源码、依赖与构建

脚本检查并通过系统 `dnf` 安装缺失的 Git、curl、GCC、tar、gzip、coreutils、gawk、util-linux（`taskset`）和 Python 3。正式工作流保留已配置的企业代理；Go 模块默认访问华为云镜像，网络错误时回退到 `goproxy.cn`。脚本先按 Sonic 工作区各 `go.sum` 中的完整校验记录逐项下载模块，降低同时建立的代理连接数，再执行 `go mod download` 检查完整依赖图。开发工作流设置 `SONIC_GO_PROXY=direct`，从模块源码仓库直连获取。

编译 Go 源码需要一个自举用 Go。脚本优先使用 `PATH` 中已有的 `go`；否则优先读取 `/home/runner/software/golang/go1.27.0.linux-<arch>.tar.gz`，没有离线包时从 `https://go.dev/dl` 下载，并校验 SHA-256。自举 Go 只安装在本次任务的 `${PERF_WORK_DIR}/bootstrap-go`。

`build` 阶段下载两份源码：

```bash
git clone -b go1.24.6 --depth 1 https://gitcode.com/openeuler/golang.git \
  "${PERF_WORK_DIR}/objects/go/src/go1.24.6"
git clone -b v1.15.2 --depth 1 https://github.com/bytedance/sonic.git \
  "${PERF_WORK_DIR}/objects/go/src/sonic"
```

脚本校验 Sonic tag，然后复制 Go 源码树，并在副本中执行本用例的构建脚本：

```bash
repo_dir="$(pwd)"  # 在仓库根目录执行时
cp -a "${PERF_WORK_DIR}/objects/go/src/go1.24.6" \
  "${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default"
cd "${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default"
bash "${repo_dir}/software/HPC/sonic-go/scripts/go/build_go.sh" default
```

`build_go.sh default` 在副本的 `src/` 中运行 Go 官方 `make.bash`，生成私有的 `bin/go`。完整复制源码树是必要的：Go 构建产物依赖同一树中的标准库与工具文件。随后脚本验证 `go version` 为 `go1.24.6`，在 Sonic 源码目录执行 `go mod download`，模块缓存保存在 `${PERF_WORK_DIR}/runtime/module-cache`。源码版本和构建信息写入 `actual-version.txt`、`toolchain_meta.json`。

## 性能测试

`test` 阶段设置工作目录变量后调用测试脚本，指定本次编译的 Go 工具链：

```bash
bash software/HPC/sonic-go/scripts/go/sonic_bench.sh \
  --toolchain go1.24.6-default \
  --result "${RESULTS_DIR}/result-sonic-go1.24.6-default-base.json"
```

测试依次运行 encoder、decoder、parser 三项，每项只跑一次默认模式。两种架构都不设置 `SONIC_USE_SVE_WRAPGOC`、`SONIC_USE_SVE_LINKNAME` 和 `SONIC_ENCODER_USE_VM`；脚本还会清除从外部环境继承的这三个变量。这样比较的是 Sonic 在各架构上的默认实现，而不是 ARM 专有模式与重复的 x86 测试项。

每项测试前执行 `go clean -testcache`，再以 `-run='^$' -benchmem -benchtime=5s` 运行基准。编码和解码分别测试 `./encoder`、`./decoder` 中的 `BenchmarkEncoder_*`、`BenchmarkDecoder_*`；解析测试 `./internal/native` 中的基准。脚本使用 `taskset` 绑定全部可用 CPU，并设置 `SONIC_NO_ASYNC_GC=1` 关闭测试包的后台 GC 循环。

例如，encoder 在 Sonic 源码目录运行的核心命令是：

```bash
env -u SONIC_USE_SVE_WRAPGOC -u SONIC_USE_SVE_LINKNAME \
  -u SONIC_ENCODER_USE_VM SONIC_NO_ASYNC_GC=1 \
"${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default/bin/go" \
  test -run='^$' -benchmem -benchtime=5s \
  -bench='^(BenchmarkEncoder_.*)$' ./encoder
```

实际脚本还设置 `GOTOOLCHAIN=local`，将未指定的 `GOEXPERIMENT` 和 `GOARM64` 置空，并通过 `taskset` 绑定可用 CPU。

## 指标与结果文件

每个基准保留测试对象和名称，模式统一记为 `default`，并提取以下三个原始指标；报告按 `<测试对象>/default` 分组。

| 指标 | 含义 | 优化方向 |
|---|---|---|
| `ns/op` | 单次操作耗时 | 越小越好 |
| `B/op` | 单次操作分配字节数 | 越小越好 |
| `allocs/op` | 单次操作分配次数 | 越小越好 |

指标名格式为 `<测试对象> :: <模式> :: <基准名称> :: <指标>`。原始 `go test` 名称的并发度后缀会在提取时去掉；因此跨架构对比时还应核对机器的 CPU 配置。

| 结果文件（位于 `${RESULTS_DIR}`） | 内容 |
|---|---|
| `benchmark_sonic_go.txt` | 测试阶段控制台输出 |
| `result-sonic-go1.24.6-default-base.json` | 原测试脚本生成的 `runs[]` 和 `results[]` |
| `logs/<用例名>/sonic-bench-*.raw.log` | 三项测试各自完整的 `go test` 原始输出 |
| `benchmark_sonic_go.json` | Framework 读取的规范化指标 |
| `build_variant.json` | 构建阶段记录的实际构建模式（`base` 或 `optimized`） |
| `actual-version.txt` | 校验后的 Sonic 版本 |

`sonic_bench.sh` 会继续执行后续测试，即使某项失败。测试阶段随后由 `scripts/results/parse_sonic_bench.py` 校验每项的退出码和全部结果；失败、无结果或无效指标均使测试阶段失败。独立运行还会生成 `system_info.json`、`build_info.json`、`results.json`、`status.json` 和 `report.md`。

`stop` 阶段清理 `${PERF_WORK_DIR}/runtime/` 中的缓存；源码与工具链留在 `${PERF_WORK_DIR}/objects/`，随任务工作目录一起回收。
