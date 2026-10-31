# Rust 1.99.1 性能测试

本用例在 x86_64、aarch64 Runner 上分别部署 Rust 官方预编译工具链
（rustc + cargo，static.rust-lang.org 发布），使用 Rust 官方性能基准套件
[rustc-perf](https://github.com/rust-lang/rustc-perf)（perf.rust-lang.org 的采集器）
的本地模式进行开箱性能对比，不从源码编译 Rust，不做任何绑核或调优。
**构建与测试全部在 openEuler 24.03 LTS SP4 容器内运行**（基镜像与用法参照 MySQL
用例），容器不绑核、不绑 NUMA、使用宿主机网络；源码、构建产物和结果目录通过 bind
mount 保存在宿主机本次任务目录。

软件入口为 `rust_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和
停止阶段；直接执行入口脚本也使用这些阶段函数。基础版构建位于
`scripts/builders/base.sh`，公共路径在 `scripts/common.sh`，结果解析位于
`scripts/results/`。工作流可选择 `base` 或 `optimized`，默认 `base`；
`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Rust | 官方 [static.rust-lang.org/dist](https://static.rust-lang.org/dist/) 预编译 `rust-1.99.1-<目标三元组>.tar.xz` | 宿主机优先读取 `/home/runner/software/rust/`，缺失时下载并校验；容器内经 tarball 自带 `install.sh` 安装到 `${PERF_WORK_DIR}/rust-install` |
| rustc-perf | 上游仓库固定提交 `9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c`（collector 版本 0.1.0） | 容器内 `git fetch --depth 1` 到 `${PERF_WORK_DIR}/rustc-perf`；也可预置 `/home/runner/software/rust/rustc-perf-<提交>.tar.gz` |
| 测量基础设施 | rustc-perf 自带的 `collector`、`rustc-fake`、`benchlib` | 容器内由被测工具链以 `cargo build -p collector --release --locked` 构建 |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载；SHA-256 校验后 `docker load` |

容器内通过 `dnf` 安装缺失的构建依赖：`git`、`curl`、`tar`、`xz`、`gcc`、`gcc-c++`、
`make`、`cmake`、`openssl-devel`（部分基准的 `openssl-sys` 与 collector 的 rustls
依赖需要）、`zlib-devel`、`perl`、`pkgconf`、`python3`、`perf`、`findutils`、`sed`、
`coreutils`、`diffutils`、`which`。容器内仓库切换为华为云 openEuler 镜像；启用
`PERF_PROXY` 时，容器挂载代理 CA 证书目录并执行 `update-ca-trust extract`，`git`、
`cargo` 与 `dnf` 的下载都通过代理。

未设置 `PERF_PROXY` 的直连 Runner（Blue）不能访问境外站点，因此 Rust 发行包默认改用
中科大镜像 `https://mirrors.ustc.edu.cn/rust-static/dist`，任务私有 `CARGO_HOME`
写入 `config.toml`，把 crates.io 替换为中科大 sparse 镜像
`sparse+https://mirrors.ustc.edu.cn/crates.io-index/`；设置 `PERF_PROXY` 时仍使用
官方 `static.rust-lang.org` 与 crates.io。两者都可用 `RUST_RELEASE_BASE`、
`RUST_CARGO_MIRROR_INDEX` 覆盖。

collector 通过 Linux `perf` 采集用户态硬件计数器（`instructions:u`、`cycles:u`），
因此容器额外授予 `PERFMON` capability；Runner 仍需保持
`kernel.perf_event_paranoid` 不超过 2（默认值即可，本用例不改内核参数）。

## 容器

每个任务创建且仅创建一个私有容器 `boostkit-rust-<架构>-<run-id>`，带
`boostkit.rust.run-id=<run-id>` 归属标签。启动方式：

```bash
docker run --detach --name "${RUST_CONTAINER_NAME}" \
  --label "boostkit.rust.run-id=${PERF_RUN_ID}" \
  --network=host --cap-add=PERFMON --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${RUST_CONTAINER_IMAGE}" sleep infinity
```

- 不使用 `--cpus`、`--cpuset-cpus`、`--cpuset-mems`：不绑核、不绑 NUMA。
- `--network=host`：容器直接使用宿主机网络。
- `--cap-add=PERFMON`：允许容器内的 `perf_event_open` 读取本进程用户态硬件计数器。
- `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 以宿主机原路径挂载，源码、构建产物和所有
  测试结果都落在宿主机指定目录。
- 镜像归档优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz`，
  校验通过后 `docker load`，并核对镜像架构与容器内 openEuler 版本。
- `stop` 阶段只停止并删除带本任务归属标签的容器，重复调用安全。

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
docker exec "${RUST_CONTAINER_NAME}" sh -c \
  "cd '${PERF_WORK_DIR}/rustc-perf' && \
   git init -q . && git remote add origin https://github.com/rust-lang/rustc-perf.git && \
   git fetch --depth 1 origin 9fa958a70781ab8abe5ee9e0875f0a9a62ecb20c && \
   git checkout --detach FETCH_HEAD"   # rev-parse HEAD 必须等于该提交
docker exec "${RUST_CONTAINER_NAME}" sh -c \
  "cd '${PERF_WORK_DIR}/rustc-perf' && \
   CARGO_HOME='${PERF_WORK_DIR}/cargo' cargo build -p collector --release --locked"
```

collector（含基准包装器 `rustc-fake`）由刚部署的被测工具链在容器内构建，产物留在
`${PERF_WORK_DIR}/rustc-perf/target/release/`。模块缓存使用任务私有
`CARGO_HOME`（Framework 已指向任务目录），不使用系统 Rust 或全局 cargo 缓存。
未实现调优构建；`scripts/builders/optimized.sh` 直接失败。

## 正式测试

`test` 阶段在容器内的 rustc-perf 检出目录运行官方采集器的两个本地子命令，被测
rustc 与 cargo 都指向本次任务私有安装：

```bash
# 编译性能：Primary 类别（21 个真实 crate）× Check/Debug/Opt × Full 场景
docker exec "${RUST_CONTAINER_NAME}" sh -c \
  "cd '${PERF_WORK_DIR}/rustc-perf' && '${COLLECTOR_BIN}' bench_local '${RUSTC_BIN}' \
     --id boostkit-1.99.1-base --cargo '${CARGO_BIN}' \
     --profiles Check,Debug,Opt --scenarios Full --category Primary \
     --iterations 1 --db '${PERF_WORK_DIR}/rustc-perf-results.db'"

# 生成代码质量：全部运行时基准组，官方默认 5 轮迭代
docker exec "${RUST_CONTAINER_NAME}" sh -c \
  "cd '${PERF_WORK_DIR}/rustc-perf' && '${COLLECTOR_BIN}' bench_runtime_local '${RUSTC_BIN}' \
     --id boostkit-1.99.1-base --cargo '${CARGO_BIN}' \
     --iterations 5 --db '${PERF_WORK_DIR}/rustc-perf-results.db'"
```

`--profiles`、`--scenarios`、`--category`、`--iterations` 均为 collector 官方
选项；Profile/场景组合刻意取官方默认减去增量场景（`Full` only），类别取
`Primary`。个别 crate（`cargo-0.87.1`、`serde-1.0.219`、`typenum-1.18.0`、
`typenum-1.18.0-new-solver`）按其上游 `perf-config.json` 在 1 和 4 两个前端
线程数下各测一次，指标名保留 `threads=<n>`。运行时基准共 12 组 35 项
（hashmap、parsing、compression、nes 等），由被测 rustc 以 release 档编译后
执行，`setarch -R` 关闭 ASLR，单轮计时取 `benchlib` 的性能计数器组。

`start` 阶段先对全部选中的基准目录在容器内执行 `cargo fetch --locked`，把依赖预取到
私有 `CARGO_HOME`，正式计时阶段不再访问网络；随后在容器内做一次 `perf stat` 冒烟验证。
基准编译在私有 `TMPDIR` 中进行，不污染系统目录。预计单架构总耗时 2–4 小时
（镜像加载与容器内依赖安装约 10–20 分钟、工具链部署约 10 分钟、collector 构建约
20–40 分钟、编译基准约 1.5–2.5 小时、运行时基准约 30–60 分钟），峰值磁盘占用约
20 GiB。

## 指标与产物

指标从官方 SQLite 结果库（`pstat` / `runtime_pstat` 表，按 artifact 名
`boostkit-1.99.1-base` 和目标三元组过滤）严格解析，缺失即失败、不补零。
collector 每次迭代写入一行，解析时按上游站点相同的口径取每个系列的最小值
（`MIN(value)`，即最快一轮）：

| 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|
| `compile/<crate>/<profile>/threads=<n>/wall-time` | `pstat` 的 `wall-time` | s | 越小越好 |
| `compile/<crate>/<profile>/threads=<n>/instructions` | `pstat` 的 `instructions:u` | instructions | 越小越好 |
| `runtime/<bench>/wall-time` | `runtime_pstat` 的 `wall-time`（原始纳秒，除以 1e6 换算） | ms | 越小越好 |
| `runtime/<bench>/instructions` | `runtime_pstat` 的 `instructions:u` | instructions | 越小越好 |

编译侧 21 个 crate 中有 3 个按上游配置在 2 个前端线程数下测量，展开后为
24 × 3 档 = 72 个系列 × 2 个指标 = 144 个编译指标；运行时侧 35 项 × 2 = 70 个指标
（`runtime` 指标名只使用数据库中的 benchmark 名，不含运行时分组前缀；部分平台的
硬件计数器不可用时仅记录 wall-time，解析器要求全有或全无，不做估算），合计 214 个
指标。报告按 `compile` / `runtime` 两组分组；跨架构只配对同名指标，crate 集合与
负载参数（套件提交、profile、场景、迭代数）在两侧必须一致，CPU 核数等机器差异
记录在 `runtime_context` 中，不强行统一。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `benchmark_rust_compile.log` | `bench_local` 完整控制台输出 |
| `benchmark_rust_runtime.log` | `bench_runtime_local` 完整控制台输出 |
| `rustc_perf.db` | 官方 SQLite 结果库副本（原始结构化数据） |
| `benchmark_rust.json` | 严格解析后的指标、参数与原始测量行 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从产物读取的实际版本 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段停止并删除本任务的容器（按归属标签校验），无需停止其他服务；宿主机的
`${PERF_WORK_DIR}` 由 Framework 或独立入口清理，`${RESULTS_DIR}` 保留。脱离 Workflow
执行完整流程（宿主机需可访问 Docker daemon）：

```bash
bash software/Toolchain/rust/rust_test.sh \
  --version 1.99.1 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/rust/results/1.99.1
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于
该版本下的 `optimized/` 子目录。排错时可加 `--keep-workdir` 保留工具链、
rustc-perf 检出与 cargo 缓存。
