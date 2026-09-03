# Sonic Go 性能测试说明

本用例测试 [ByteDance Sonic](https://github.com/bytedance/sonic) 的 Go 实现：一个基于
JIT 和 SIMD 的 JSON 序列化、反序列化及 JSON 操作库。当前版本为 `1.15.2`，在
`x86_64` 和 `aarch64` 上以同一套上游基准进行开箱性能对比。

`case.yaml` 将四阶段映射至 `sonic_go_test.sh`：`build` 下载源码与模块并编译基准包，
`start` 校验运行条件，`test` 执行上游基准，`stop` 无后台服务需要停止。入口脚本可独立运行。

## 依赖与构建

脚本自动检查并安装缺失的 Git、curl、GCC、tar、gzip、coreutils、gawk 与 Python 3。
测试使用任务私有的官方预编译 Go `1.26.7`，不使用 Runner 上已有的系统 Go。

Go 压缩包优先从 Runner 的离线目录读取：

```text
/home/runner/software/golang/go1.26.7.linux-amd64.tar.gz
/home/runner/software/golang/go1.26.7.linux-arm64.tar.gz
```

离线包缺失时，脚本从下列官方地址下载对应架构的压缩包，并以脚本内声明的
SHA-256 校验：

```text
https://go.dev/dl/go1.26.7.linux-<amd64|arm64>.tar.gz
```

Go 安装到本次任务的 `${PERF_WORK_DIR}/go-install`；模块缓存、编译缓存和 `GOPATH`
位于 `/home/runner/sonic-go-work/<Sonic版本>/<架构>/<运行ID>/`，停止阶段会清理。
Go 模块通过 `https://goproxy.cn` 下载。

构建阶段按以下命令获取 Sonic `v1.15.2`，并只编译官方基准涉及的包：

```bash
git clone --branch v1.15.2 --depth 1 \
  https://github.com/bytedance/sonic.git sonic-go-source
tar -xzf go1.26.7.linux-<架构>.tar.gz \
  -C go-install --strip-components=1
export GOROOT="$PWD/go-install"
export PATH="$GOROOT/bin:$PATH"
cd sonic-go-source
go mod download
for benchmark_dir in encoder decoder ast external_jsonlib_test/benchmark_test; do
  (
    cd "${benchmark_dir}"
    go mod download
    go test -run='^$'
  )
done
```

源码标签必须精确为 `v1.15.2`，否则构建阶段失败；实际版本写入 `actual-version.txt`。
私有 Go 的版本和架构也必须分别精确为 `1.26.7` 与当前任务架构。

## 官方性能测试

性能阶段在源码根目录原样执行 Sonic `v1.15.2` 自带的 `scripts/bench.sh`：

```bash
export SONIC_ENCODER_USE_VM=""
export SONIC_USE_SVE_WRAPGOC=1
bash -e scripts/bench.sh
```

该脚本设置 `SONIC_NO_ASYNC_GC=1`，并依次测试以下官方包和场景：

- `encoder`：编码基准，固定 `100000x`；
- `decoder`：解码基准，固定 `100000x`；
- `ast`：Get/Set，固定 `1000000x`；Parser/Encode，固定 `10000x`；节点和路径操作，固定 `10000000x`；
- `external_jsonlib_test/benchmark_test`：编码/解码，固定 `100000x`；Get/Set，固定 `1000000x`；Parser，固定 `10000x`。

`bash -e` 只增加“任一官方命令失败即失败”的错误处理，不改变上游脚本中的命令、参数或测试矩阵。
两个 `SONIC_*` 变量仅在性能阶段导出，并写入 `benchmark_sonic_go.json` 的 `environment` 字段。

## 指标和输出

上游 Go 基准每一行可能包含多个原始字段。结果保留原始包路径、完整 benchmark 名称
（包括 Go 输出的并发度后缀）和原始单位，不筛选或重命名：

| 原始单位 | 含义 | 优化方向 |
|---|---|---|
| `ns/op` | 单次操作耗时 | 越小越好 |
| `B/op` | 单次操作分配字节数 | 越小越好 |
| `allocs/op` | 单次操作分配次数 | 越小越好 |
| `MB/s` 或其他 `/s` | 吞吐量 | 越大越好 |

报告按上游 Go 包路径分组。输出文件包括：

- `benchmark_sonic_go.txt`：完整上游控制台输出；
- `benchmark_sonic_go.json`：由原始输出规范化的全部指标；
- `actual-version.txt`：校验后的 Sonic 版本；
- 独立运行时额外生成 `system_info.json`、`build_info.json`、`results.json`、`status.json` 和 `report.md`。

## 独立执行

在仓库根目录执行：

```bash
bash software/HPC/sonic-go/sonic_go_test.sh --version 1.15.2
```

使用 `--results-dir <目录>` 指定持久结果目录；使用 `--keep-workdir` 保留本次工作目录以便排查。
