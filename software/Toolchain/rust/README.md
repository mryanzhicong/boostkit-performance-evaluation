# Rust 性能测试说明

本目录测试 Rust 官方预编译工具链（rustc + cargo，static.rust-lang.org
发布），并使用 ripgrep 官方 crate 发布版作为固定基准负载，进行 x86_64
与 aarch64 开箱性能对比。软件入口为 `rust_test.sh`，Framework 通过
`case.yaml` 调用其 `build`、`start`、`test`、`stop` 四个阶段；直接执行
该脚本也使用同一套阶段函数。

当前清单仅声明 Rust `1.98.1`。新增版本或架构时，必须同时在
`rust_test.sh` 中声明官方 tarball 文件名及其 SHA-256（取自官方
channel 清单 `channel-rust-stable.toml` 的 `xz_hash`），不能跳过校验。

## 构建与安装

这里的“构建”是部署官方预编译 tarball 并通过 tarball 自带的
`install.sh` 安装到任务私有前缀，不从源码编译 Rust，也不安装系统级
Rust 软件包。

1. 根据版本与架构选择官方 tarball。当前包名为：

   | 架构 | 包名 |
   |---|---|
   | `x86_64` | `rust-1.98.1-x86_64-unknown-linux-gnu.tar.xz` |
   | `aarch64` | `rust-1.98.1-aarch64-unknown-linux-gnu.tar.xz` |

2. 依次在以下位置获取包：

   1. `/home/runner/software/rust/<包名>` 的本地离线包；
   2. 当前任务工作目录中的同名缓存包；
   3. Rust 官方发布地址 `https://static.rust-lang.org/dist/`。

3. 使用官方 channel 清单中声明的 SHA-256 校验包完整性，校验失败立即退出。
4. 解压后执行 tarball 自带的官方安装脚本，装入本次任务的
   `PERF_WORK_DIR/rust`（跳过 rust-docs 组件，禁用 ldconfig，不触碰系统
   目录）：

   ```bash
   tar -xJf "${PERF_WORK_DIR}/rust-1.98.1-x86_64-unknown-linux-gnu.tar.xz" \
     -C "${PERF_WORK_DIR}/rust-unpack"
   (cd "${PERF_WORK_DIR}/rust-unpack/rust-1.98.1-x86_64-unknown-linux-gnu" && \
     ./install.sh --prefix="${PERF_WORK_DIR}/rust" \
       --without=rust-docs --disable-ldconfig)
   ```

5. 验证 `rustc`、`cargo` 可执行，且 `rustc --version` 报告的版本与请求
   版本一致。

在 Runner 预置离线包时，应使用与目标架构相符的文件名。例如 aarch64：

```bash
sudo install -d -o runner -g runner /home/runner/software/rust
sudo install -o runner -g runner rust-1.98.1-aarch64-unknown-linux-gnu.tar.xz \
  /home/runner/software/rust/
sha256sum /home/runner/software/rust/rust-1.98.1-aarch64-unknown-linux-gnu.tar.xz
```

## 基准就绪（start）

Rust 没有常驻服务。`start` 阶段把固定基准负载布置到本次任务的
`PERF_WORK_DIR/benchmark` 目录：

| 组件 | 固定来源 |
|---|---|
| ripgrep `15.2.0` | 官方 crates.io 发布包 `https://static.crates.io/crates/ripgrep/ripgrep-15.2.0.crate`（SHA-256 校验，附带 `Cargo.lock`） |
| 搜索语料 | `scripts/gen_corpus.py` 以固定种子确定性生成（64 MiB 与 512 MiB 两档） |

`.crate` 包本身做 SHA-256 校验；其 `Cargo.lock` 锁定全部依赖版本，
`cargo` 在获取与构建时逐一校验每个依赖的 crates.io 校验和（cargo 内建
完整性机制），等价于对整个依赖树做了校验。`start` 阶段执行
`cargo fetch --locked` 预取依赖到任务私有 `CARGO_HOME`（Runner 配置了
`PERF_PROXY` 时自动透传给 cargo 的 HTTP 层），随后以 release 档完成
一次完整冒烟构建并空跑一次 `rg --version` 与语料搜索，确认工具链与
负载全部可用；`test` 阶段的所有构建均以 `--offline --locked` 执行，
不引入网络抖动。

## 性能测试

测试评估编译器的两个维度，与 clang 用例同构（编译吞吐 + 生成代码
质量），轮数固定为每档 5 轮（`RUST_ROUNDS` 可覆盖），耗时用
`date +%s.%N` 前后差值测量：

1. **compile 场景**（编译吞吐）：对 ripgrep 整个 workspace 分别以三个
   cargo 优化档全量构建，对应 clang 的 `-O0/-O2/-Os` 阶梯：

   | 档位 | 命令 |
   |---|---|
   | `dev` | `cargo build --locked --offline`（opt-level=0） |
   | `release` | `cargo build --release --locked --offline`（opt-level=3） |
   | `opt-level=s` | `RUSTFLAGS="-C opt-level=s" cargo build --release --locked --offline` |

   每轮使用独立的 `CARGO_TARGET_DIR` 干净构建，记录墙钟时间与 `rg`
   二进制大小：

   ```bash
   (cd "${RIPGREP_DIR}" && CARGO_TARGET_DIR="${target_dir}" \
     cargo build --release --locked --offline --quiet)
   ```

2. **search 场景**（生成代码质量）：单独构建 release 二进制，对两档
   确定性语料执行固定模式搜索，单线程 `-j1` 归一化并行度、`--no-mmap`
   固定读取路径，每档 5 轮计时：

   ```bash
   "${rg_binary}" -c --no-mmap -j1 --no-ignore --no-messages \
     boostkit-perf-needle-7f3a corpus-512mib.txt
   ```

   语料由固定种子生成，每 1000 行包含一次命中词，保证搜索必定成功且
   命中数跨架构一致。

完整控制台输出保留为 `ripgrep_benchmark_raw.log`，其中的
`result scenario=... workload=... round=...` 结构化行由
`scripts/collect_rust_benchmark.py` 汇总。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop
并保存同样的产物。例如：

```bash
bash software/Toolchain/rust/rust_test.sh \
  --version 1.98.1 \
  --results-dir /home/runner/boostkit-perf/rust/results/1.98.1
```

## 指标

每个“场景 + 负载档位”组合保留 3 个字段，不做平均、加权或跨场景聚合。
总计为：

```text
（3 个编译档位 + 2 个语料档位）× 3 个指标 = 15 个指标
```

| 原始字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `median wall time` | `compile ripgrep --profile=<档位>: median wall time` / `ripgrep search --corpus=<档位>MiB: median wall time` | s | 越小越好 | 每档 5 轮墙钟时间的中位数 |
| `fastest wall time` | `... --profile=<档位>: fastest wall time` / `... --corpus=<档位>MiB: fastest wall time` | s | 越小越好 | 每档 5 轮中的最快一轮 |
| `artifact size` | `... --profile=<档位>: artifact size` / `... --corpus=<档位>MiB: artifact size` | KiB | 越小越好 | 对应档位的 `rg` 二进制大小 |

报告按场景（compile / search）分组；每组以负载档位为行、三个字段
为列，便于在相同负载下比较 x86_64 与 aarch64。基准负载及其固定版本
（ripgrep `15.2.0`）会同时列在报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `ripgrep_benchmark_raw.log`：原始控制台输出；
- `results.json`：15 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务，仅移除本次任务的基准数据目录
`PERF_WORK_DIR/benchmark`（ripgrep 源码、cargo 构建目录与语料文件）。
Standalone 模式结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/rust/local-*` 工作目录（含 rust 安装前缀与
cargo 依赖缓存）；Framework 随后执行 Runner 级环境清理。
