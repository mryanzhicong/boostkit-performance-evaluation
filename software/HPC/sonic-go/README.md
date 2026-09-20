# Sonic Go 性能测试说明

本用例测试 [ByteDance Sonic](https://github.com/bytedance/sonic) 的 Go 实现：一个基于
JIT 和 SIMD 的 JSON 序列化、反序列化及 JSON 操作库。被测版本为官方正式版
`v1.15.2`，在 `x86_64` 和 `aarch64` 上使用**自源码编译的 Go 工具链**执行 sonic
基准矩阵。

`case.yaml` 将四阶段映射至 `sonic_go_test.sh`：`build` 下载 Go/Sonic 源码并编译
Go 工具链，`start` 校验运行条件，`test` 执行 sonic 基准矩阵，`stop` 清理运行时
缓存。入口脚本可独立运行。

## 依赖

脚本自动检查并安装缺失的 Git、curl、GCC、tar、gzip、coreutils、gawk、
util-linux（taskset）与 Python 3。Go 模块通过 `https://goproxy.cn` 下载。

编译 Go 源码需要 bootstrap Go（自举用），获取顺序：

1. Runner PATH 上已有的 Go（`command -v go` 命中即用）；
2. 均缺失时安装任务私有的官方二进制 `1.27.0`：离线目录
   `/home/runner/software/golang/go1.27.0.linux-<arch>.tar.gz` 优先，缺失时从
   `https://go.dev/dl` 下载并按脚本内声明的 SHA-256 校验，解压到
   `${PERF_WORK_DIR}/bootstrap-go` 后前置到 PATH。不使用系统包。

## 第 1 步：下载源码

- Go 工具链源码（openEuler 公开仓库，编译被测工具链用）：

  ```bash
  git clone -b go1.24.6 --depth 1 https://gitcode.com/openeuler/golang.git \
    "${PERF_WORK_DIR}/objects/go/src/go1.24.6"
  ```

- Sonic 源码为被测对象（官方正式版 tag，非 arm64 开发分支）：

  ```bash
  git clone -b v1.15.2 --depth 1 https://github.com/bytedance/sonic.git \
    "${PERF_WORK_DIR}/objects/go/src/sonic"
  ```

源码标签必须精确匹配（`git describe --tags --exact-match` 校验），否则构建
阶段失败；Sonic 实际版本写入 `actual-version.txt`。

## 第 2 步：编译 Go 1.24.6 工具链

**为什么先复制工作副本**：`make.bash` 在源码树内**就地**生成 `bin/go`，该工具链
的 `GOROOT` 指向整棵树（标准库源码就在树里），只拷 `bin/go` 出来无法使用。所以
每个 target 复制一份完整副本再在副本内编译：

```bash
cp -a "${PERF_WORK_DIR}/objects/go/src/go1.24.6" \
      "${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default"
cd "${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default"
# 脚本来自本用例目录 software/HPC/sonic-go/scripts/go/build_go.sh
bash <仓库路径>/software/HPC/sonic-go/scripts/go/build_go.sh default
```

`build_go.sh default` 的实际动作：校验当前目录是 Go 源码树（存在
`src/make.bash`）且 PATH 上有 bootstrap Go 后，执行官方标准流程
`cd src && ./make.bash`（无任何额外特性开关）。`make.bash` 的自举链：

1. 用 bootstrap Go 编译 `cmd/dist`（构建调度器）；
2. `dist` 用 bootstrap Go 编译 **toolchain1**，再用 toolchain1 编译
   **toolchain2**、toolchain2 编译 **toolchain3**（三轮自举消除宿主编译器影响）；
3. 最终编译 linux/`<arch>` 的标准库与全套命令（`go`、`build`、`gofmt` 等），
   产物就地落在副本内的 `bin/`、`pkg/`。

编译耗时几分钟到十几分钟，属正常。产物校验：

- `${TOOLCHAIN_DIR}/bin/go` 可执行，`go version` 输出 `go1.24.6`；
- `toolchain_meta.json` 已生成（记录源码 commit、分支、是否有未提交改动、
  编译模式、构建时间、二进制路径，供结果回溯）。

构建期 Go 环境处理：bootstrap 阶段的构建缓存显式指向
`${PERF_WORK_DIR}/runtime/bootstrap-go-build`（与测试阶段缓存隔离，见第 3 步）；
`GOTOOLCHAIN=local` 禁止 go.mod 版本触发工具链自动下载；测试进程显式
`unset GOROOT GOWORK GOFLAGS`——`GOROOT` 残留会让自编译工具链错用宿主机
`pkg/tool`（工具链版本错配），`GOWORK=off` 会与 Sonic 自带 `go.work` 的
replace 冲突，`GOFLAGS` 残留（如 `-mod=vendor`）会破坏 Sonic 的模块解析。

工具链就绪后准备 Sonic 基准包：在 `${SONIC_DIR}` 内用新工具链执行
`go mod download`（模块缓存位于 `${PERF_WORK_DIR}/runtime/module-cache`，
停止阶段清理）。

## 第 3 步：执行 sonic 基准矩阵

`test` 阶段调用 `scripts/go/sonic_bench.sh`：

```bash
bash scripts/go/sonic_bench.sh \
  --toolchain go1.24.6-default \
  --result "${RESULTS_DIR}/result-sonic-go1.24.6-default-base.json"
```

### 模式矩阵

三类 subject，模式由 sonic 的**运行时**环境变量控制（模式间编译产物相同，
`internal/native/dispatch_arm64.go` 与 `internal/encoder/vars/const.go` 在
init 时 `os.Getenv` 读取；`goexperiment/goarm64/gcflags/ldflags` 才是构建期
维度，本用例不使用）：

| subject | 模式 | `SONIC_USE_SVE_WRAPGOC` | `SONIC_USE_SVE_LINKNAME` | `SONIC_ENCODER_USE_VM` |
|---|---|---|---|---|
| encoder/decoder | DYN+JIT | 1 | 0 | （空） |
| encoder/decoder | SVE+JIT | 0 | 1 | （空） |
| encoder/decoder | NEON+JIT | 0 | 0 | （空） |
| encoder/decoder | DYN+VM | 1 | 0 | 1 |
| encoder/decoder | SVE+VM | 0 | 1 | 1 |
| encoder/decoder | NEON+VM | 0 | 0 | 1 |
| parser | DYN | 1 | 0 | （空） |
| parser | SVE | 0 | 1 | （空） |
| parser | NEON | 0 | 0 | （空） |

**双架构语义**：DYN / SVE / NEON 分派仅存在于 arm64（`dispatch_arm64.go`）；
`x86_64` 上这些开关不被读取，各模式执行同一条 amd64 路径。两个架构跑同一
模式矩阵是为了满足框架"跨架构指标集合完全一致"的对比要求，不代表
`x86_64` 上模式间存在实现差异。

### 每个模式的实际命令

每个模式执行前先清测试缓存（`go clean -testcache`，用户约定：不同测试之间
清测试缓存），然后在 Sonic 源码根目录执行（以 encoder 的 DYN+JIT 为例）：

```bash
taskset -c <全部可用核> env \
  GOEXPERIMENT= GOARM64= GOTOOLCHAIN=local SONIC_NO_ASYNC_GC=1 \
  SONIC_USE_SVE_WRAPGOC=1 SONIC_USE_SVE_LINKNAME=0 SONIC_ENCODER_USE_VM= \
  "${PERF_WORK_DIR}/objects/go/bin/go1.24.6-default/bin/go" \
  test -run='^$' -benchmem -benchtime=5s \
  -bench='^(BenchmarkEncoder_.*)$' ./encoder
```

要点：

- `GOEXPERIMENT=` / `GOARM64=` 显式置空：屏蔽全局残留，等价于未设置，go 回落
  到工具链烘焙默认；`GOTOOLCHAIN=local` 防止 go.mod 触发自动下载；
- `SONIC_NO_ASYNC_GC=1` 固定注入：关闭部分测试包 TestMain 默认启动的后台
  `runtime.GC()` 循环 goroutine（持续消耗 CPU 干扰基准）；
- 绑核：`taskset` 绑定全部可用核（默认读 `/proc/self/status` 的
  `Cpus_allowed_list`），实际绑核范围记入结果 JSON 的 `env.cpu_bind`；
- bench 范围：encoder/decoder 分别匹配 `^(BenchmarkEncoder_.*)$` /
  `^(BenchmarkDecoder_.*)$`（各 12 个 benchmark：
  `Benchmark<Type>_{Generic,Binding,Parallel}_{Sonic,Sonic_Fast,StdLib}`，
  v1.15.2 中无 JsonLarge/JsonSmall 数据集，固定用 TwitterJson）；parser 跑
  `-bench=.` 于 `./internal/native`（3 个 benchmark：
  `BenchmarkParseWithPadding/{Complex,Medium}` 与 `BenchmarkGetByPath`）。

15 个模式顺序执行（每个约 1.5 分钟，总计约 20 分钟）。

### 结果收集与汇总

- 每个模式的完整 `go test` 输出落 `${RESULTS_DIR}/logs/<用例名>/`
  `sonic-bench-<subject>-<mode>.raw.log`；
- 脚本用 awk 从 raw log 逐行提取 `Benchmark<Name>-<GOMAXPROCS>`（去掉并发度
  后缀）、迭代次数、`ns/op`、`B/op`、`allocs/op`；
- 全部模式跑完后由 python3 汇总为结果 JSON：`runs[]` 记录每个模式的
  `subject/mode/exit_code/bench_count/duration_sec/raw_log`，`results[]` 记录
  每条 benchmark 数据，顶层 `exit_code` 取各模式最大值。

`sonic_bench.sh` 自身退出码恒为 0（模式失败会继续跑完其余模式）；真实成败由
`scripts/parse_sonic_bench.py` 严格校验：`runs[]` 中任一模式 `exit_code` 非 0、
`results` 为空、数值非法（非有限数、`ns/op` 为 0）或指标重名，均直接失败并
使 `test` 阶段返回非零，不允许部分成功冒充成功。

## 指标和输出

`parse_sonic_bench.py` 把原始结果 JSON 规范化为框架指标格式，保留原始
subject / mode / benchmark 名称与原始单位，不筛选或重命名：

| 原始单位 | 含义 | 优化方向 |
|---|---|---|
| `ns/op` | 单次操作耗时 | 越小越好 |
| `B/op` | 单次操作分配字节数 | 越小越好 |
| `allocs/op` | 单次操作分配次数 | 越小越好 |

指标名 `<subject> :: <mode> :: <benchmark> :: <unit>`，按 `<subject>/<mode>`
分组（153 benchmark × 3 单位 = 459 条指标）。输出文件包括：

- `benchmark_sonic_go.txt`：`sonic_bench.sh` 完整控制台输出；
- `benchmark_sonic_go.json`：由原始结果规范化的全部指标（框架必需输出）；
- `result-sonic-go1.24.6-default-base.json`：`sonic_bench.sh` 原始结果 JSON；
- `logs/<用例名>/`：逐模式原始 `go test` 输出；
- `actual-version.txt`：校验后的 Sonic 版本；
- 独立运行时额外生成 `system_info.json`、`build_info.json`、`results.json`、
  `status.json` 和 `report.md`。

停止阶段清理 `${PERF_WORK_DIR}/runtime/`（模块缓存、GOPATH、bootstrap 构建
缓存）；工具链与源码位于 `${PERF_WORK_DIR}/objects/`，随任务工作目录整体回收。

## 独立执行

在仓库根目录执行：

```bash
bash software/HPC/sonic-go/sonic_go_test.sh --version 1.15.2
```

使用 `--results-dir <目录>` 指定持久结果目录；使用 `--keep-workdir` 保留本次
工作目录以便排查。
