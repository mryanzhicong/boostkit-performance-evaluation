# Rust 1.99.1 性能测试

本用例在 x86_64、aarch64 Runner 上分别部署 Rust 官方预编译工具链
（rustc + cargo，static.rust-lang.org 发布），使用 Rust 官方性能基准套件
[rustc-perf](https://github.com/rust-lang/rustc-perf)（perf.rust-lang.org 的采集器）
的本地模式进行开箱性能对比，不从源码编译 Rust，也不做任何绑核或调优。

软件入口为 `rust_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和
停止阶段；直接执行入口脚本也使用这些阶段函数。基础版构建位于
`scripts/builders/base.sh`，公共路径在 `scripts/common.sh`，结果解析位于
`scripts/results/`。工作流可选择 `base` 或 `optimized`，默认 `base`；
`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Rust | 官方 [static.rust-lang.org/dist](https://static.rust-lang.org/dist/) 预编译 `rust-1.99.1-<目标三元组>.tar.xz` | 优先读取 `/home/runner/software/rust/`，缺失时下载；经 tarball 自带 `install.sh` 安装到本次任务私有目录 `${PERF_WORK_DIR}/rust-install` |
| rustc-perf | 上游仓库固定提交 `9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c`（collector 版本 0.1.0） | `git fetch --depth 1` 到 `${PERF_WORK_DIR}/rustc-perf`；也可预置 `/home/runner/software/rust/rustc-perf-<提交>.tar.gz` |
| 测量基础设施 | rustc-perf 自带的 `collector`、`rustc-fake`、`benchlib` | 由被测工具链在私有目录内以 `cargo build -p collector --release --locked` 构建 |

脚本通过 `dnf` 安装缺失的系统依赖：`git`、`curl`、`tar`、`xz`、`gcc`、`gcc-c++`、
`openssl-devel`（部分基准的 `openssl-sys` 依赖需要）、`perl`、`pkgconf`、`python3`
和 `perf`。collector 通过 Linux `perf` 采集用户态硬件计数器；Runner 需允许
`perf stat -e instructions:u,cycles:u`（`kernel.perf_event_paranoid` 默认值 2 即可，
本用例不改内核参数）。

## Rust 获取、部署与版本核对

tarball 名称与 SHA-256 取自官方 channel 清单 `channel-rust-stable.toml`（`xz_hash`）：

| 架构 | 包名 | SHA-256 |
|---|---|---|
| `x86_64` | `rust-1.99.1-x86_64-unknown-linux-gnu.tar.xz` | `231fcae47ee950621374725b5fc3b5441d2fbda2955ac45dd7dc816d8876cfe7` |
| `aarch64` | `rust-1.99.1-aarch64-unknown-linux-gnu.tar.xz` | `a48fb1e853be56ce9b8e2751f5464dbd5e16440cd81e237920f3a5e7e806333e` |

获取顺序为 `/home/runner/software/rust/` 离线包 → 本次任务目录缓存 → 官方地址
下载；无论来源都先校验 SHA-256 再解压。部署命令形态（`install.sh` 为 tarball
自带官方安装脚本，跳过 rust-docs 组件并禁用 ldconfig，不触碰系统目录）：

```bash
tar -xJf "${PERF_WORK_DIR}/rust-1.99.1-x86_64-unknown-linux-gnu.tar.xz" \
  -C "${PERF_WORK_DIR}/rust-unpack"
(cd "${PERF_WORK_DIR}/rust-unpack/rust-1.99.1-x86_64-unknown-linux-gnu" && \
  ./install.sh --prefix="${PERF_WORK_DIR}/rust-install" \
    --without=rust-docs,rust-docs-json-preview --disable-ldconfig)
"${PERF_WORK_DIR}/rust-install/bin/rustc" --version  # 必须报告 1.99.1
```

`rustc --version` 与 `cargo --version` 的完整输出（含提交哈希）保存到
`${PERF_WORK_DIR}/rustc-version.txt`、`cargo-version.txt`；解析出的版本号写入
`PERF_ACTUAL_VERSION_FILE`，不直接写请求版本。

## rustc-perf 获取与 collector 构建

```bash
git init -q "${PERF_WORK_DIR}/rustc-perf"
git -C "${PERF_WORK_DIR}/rustc-perf" remote add origin https://github.com/rust-lang/rustc-perf.git
git -C "${PERF_WORK_DIR}/rustc-perf" fetch --depth 1 origin 9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c
git -C "${PERF_WORK_DIR}/rustc-perf" checkout --detach FETCH_HEAD  # rev-parse HEAD 必须等于该提交
(cd "${PERF_WORK_DIR}/rustc-perf" && \
  CARGO_HOME="${PERF_WORK_DIR}/cargo" cargo build -p collector --release --locked)
```

collector（含基准包装器 `rustc-fake`）由刚部署的被测工具链构建，产物留在
`${PERF_WORK_DIR}/rustc-perf/target/release/`。模块缓存使用任务私有
`CARGO_HOME`（Framework 已指向任务目录），不使用系统 Rust 或全局 cargo 缓存。
未实现调优构建；`scripts/builders/optimized.sh` 直接失败。

## 正式测试

`test` 阶段在 rustc-perf 检出目录内运行官方采集器的两个本地子命令，被测
rustc 与 cargo 都指向本次任务私有安装：

```bash
# 编译性能：Primary 类别（21 个真实 crate）× Check/Debug/Opt × Full 场景
"${COLLECTOR_BIN}" bench_local "${RUSTC_BIN}" \
  --id boostkit-1.99.1-base --cargo "${CARGO_BIN}" \
  --profiles Check,Debug,Opt --scenarios Full --category Primary \
  --iterations 1 --db "${PERF_WORK_DIR}/rustc-perf-results.db"

# 生成代码质量：全部运行时基准组，官方默认 5 轮迭代
"${COLLECTOR_BIN}" bench_runtime_local "${RUSTC_BIN}" \
  --id boostkit-1.99.1-base --cargo "${CARGO_BIN}" \
  --iterations 5 --db "${PERF_WORK_DIR}/rustc-perf-results.db"
```

`--profiles`、`--scenarios`、`--category`、`--iterations` 均为 collector 官方
选项；Profile/场景组合刻意取官方默认减去增量场景（`Full` only），类别取
`Primary`。个别 crate（`cargo-0.87.1`、`serde-1.0.219`、`typenum-1.18.0`、
`typenum-1.18.0-new-solver`）按其上游 `perf-config.json` 在 1 和 4 两个前端
线程数下各测一次，指标名保留 `threads=<n>`。运行时基准共 12 组 35 项
（hashmap、parsing、compression、nes 等），由被测 rustc 以 release 档编译后
执行，`setarch -R` 关闭 ASLR，单轮计时取 `benchlib` 的性能计数器组。

`start` 阶段先对全部选中的基准目录执行 `cargo fetch --locked`，把依赖预取到
私有 `CARGO_HOME`，正式计时阶段不再访问网络；随后做一次 `perf stat` 冒烟验证。
基准编译在私有 `TMPDIR` 中进行，不污染系统目录。预计单架构总耗时 2–4 小时
（工具链部署约 10 分钟、collector 构建约 20–40 分钟、编译基准约 1.5–2.5 小时、
运行时基准约 30–60 分钟），峰值磁盘占用约 20 GiB。

## 指标与产物

指标从官方 SQLite 结果库（`pstat` / `runtime_pstat` 表，按 artifact 名
`boostkit-1.99.1-base` 和目标三元组过滤）严格解析，缺失即失败、不补零：

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `compile/<crate>/<profile>/threads=<n>/wall-time` | `pstat` 的 `wall-time` | s | 越小越好 |
| `compile/<crate>/<profile>/threads=<n>/instructions` | `pstat` 的 `instructions:u` | instructions | 越小越好 |
| `runtime/<group>/<bench>/wall-time` | `runtime_pstat` 的 `wall-time`（原始纳秒，除以 1e6 换算） | ms | 越小越好 |
| `runtime/<group>/<bench>/instructions` | `runtime_pstat` 的 `instructions:u` | instructions | 越小越好 |

编译侧 21 个 crate 中有 4 个按上游配置在 2 个前端线程数下测量，展开后为
25 × 3 档 = 75 个系列 × 2 个指标 = 150 个编译指标；运行时侧 35 项 × 1–2 个指标
（部分平台的硬件计数器不可用时仅记录 wall-time，解析器要求全有或全无，不做
估算）。报告按 `compile` / `runtime` 两组分组；跨架构只配对同名指标，crate 集合
与负载参数（套件提交、profile、场景、迭代数）在两侧必须一致，CPU 核数等机器
差异记录在 `runtime_context` 中，不强行统一。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `benchmark_rust_compile.log` | `bench_local` 完整控制台输出 |
| `benchmark_rust_runtime.log` | `bench_runtime_local` 完整控制台输出 |
| `rustc_perf.db` | 官方 SQLite 结果库副本（原始结构化数据） |
| `benchmark_rust.json` | 严格解析后的指标、参数与原始测量行 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从产物读取的实际版本 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段无需停止服务（所有进程为测试阶段的子进程，随阶段结束退出）；
私有工作目录由 Framework 或独立入口清理。脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/rust/rust_test.sh \
  --version 1.99.1 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/rust/results/1.99.1
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于
该版本下的 `optimized/` 子目录。排错时可加 `--keep-workdir` 保留工具链、
rustc-perf 检出与 cargo 缓存。
