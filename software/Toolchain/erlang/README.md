# Erlang 29.1.2 性能测试用例

本用例属于 **Toolchain** 类别，按仓库适配契约（`case.yaml` 的 shell-functions 六阶段：
prepare/build/start/test/stop/finalize）实现，输出 `build_variant.json`、`raw-output.log`、
`results.json` 与 `runs/` 原始样本。正式性能证据来自 GitHub Actions
`Blue: Manual performance evaluation` 的 aarch64 运行；本机 x86_64 只做功能与链路验证。

## 1. 版本与制品来源

| 项目 | 值 |
|---|---|
| 目标版本 | **Erlang/OTP 29.1.2** |
| 官方源码 | `https://github.com/erlang/otp/releases/download/OTP-29.1.2/otp_src_29.1.2.tar.gz` |
| SHA-256 | `c79966661e35fe4aff8ec003db63682e3b33b10b672220d51bf93c0a9244b049`（GitHub Release 未附 `.sha256`，该值由官方 release 资产计算并在每次下载/离线副本上复核） |
| 源码大小 | 106,854,380 字节 |
| 离线预置目录 | `/home/runner/software/erlang/otp_src_29.1.2.tar.gz` |
| 镜像顺序 | `PERF_ERLANG_SOURCE_MIRROR` → ghfast.top → gh-proxy.com → 官方 github.com，每个源都校验同一 SHA-256 |

构建依赖：`gcc`、`make`、`tar`、`curl`、ncurses 与 OpenSSL 头文件。Runner
`dnf install gcc make tar curl bzip2 ncurses-devel openssl-devel`；Ubuntu
`apt-get install gcc make tar curl bzip2 libncurses-dev libssl-dev`，安装后逐条自检。

## 2. 安装与构建（固定口径）

```bash
./configure --prefix=<workdir>/otp-install --without-javac --without-odbc --without-wx
make -j4
make install
```

- 不构建 Java 接口、ODBC 与 wx，保持工具链基线最小；`-j4` 为并行上限（与 CI 其他任务共存）。
- 构建后读取 `releases/<vsn>/OTP_VERSION` 得到实际版本，必须为 `29.1.2`（写入
  `results/actual-version.txt`），并记录 `erlang:system_info(system_version)`。
- 构建日志保留在 `<workdir>/build/{configure,make,install}.log`，失败时打印尾部 40 行并以
  `30` 退出。

## 3. 上游基准：bencherl（固定 commit）

上游 **bencherl**（`softlab-ntua/bencherl`，最后更新 2015-03）固定到 commit
`317bdbf348def0b2f9ed32cb6621e21083b7e0ca`（master HEAD）。完整仓库约 154 MB（含基准数据与
分布式 harness），单节点运行只需以下三个**自包含** handler，构建时按固定 SHA-256 逐个下载并
校验（离线预置目录 `bencherl/` 优先）：

| 文件 | SHA-256 | 说明 |
|---|---|---|
| `bang.erl` | `fd01eb1135d7c3a2082d865a67d435b9345362405ee416879ed309fbf4aec8cb` | 消息突发（messaging burst） |
| `big.erl` | `8c430a9043edc9276778fda4a538172310d8814ccbb46ffd07913abab11d0fd5` | 环形消息传递（message passing ring） |
| `mbrot.erl` | `e70c48630a5d7e10740323c756ca8000e9fcfd0d004d184eeb0f2cce1f990619` | Mandelbrot 浮点算术 |

以 `number_of_cores = 1`、单节点执行：`M:bench_args(Version, Conf)` 取得参数集后调用
`M:run(Args, [], [])`。`bang`/`big`/`mbrot` 的 `run/3` 只返回 `ok`，因此其 RESULT 校验和取
**参数集推导出的确定性工作量**（消息数 / 参与进程数 / Mandelbrot 迭代数），用于证明预期参数集
被完整执行。`mbrot.erl` 的 `-compile(native).` 因 OTP 24+ 已移除 HiPE 而被构建脚本删除（唯一
源码改动，记录在 `build_variant.json` 的 `bencherl_patch`）。

## 4. 完整测试口径（20 场景 × 2 指标）

每场景**预热 1 次 + 5 次独立测量**，取中位数；`results.json` 保留全部样本与
min/max/mean/stdev。测量阶段完全离线，工作负载为仓库内 `benchmarks/perf_bench.erl`（含
bencherl handler），每个场景输出确定性的 `RESULT scenario=... checksum=...`，解析阶段逐场景核验。

| 场景 | 维度 | 规模 | 口径 |
|---|---|---|---|
| `bencherl_bang_short/long` | message | short/long | bencherl `bang` handler（消息突发，16²/79² 条消息，cores=1） |
| `bencherl_big_short/long` | message | short/long | bencherl `big` handler（环形消息传递，8/24 进程） |
| `bencherl_mbrot_short/long` | compute | short/long | bencherl `mbrot` handler（浮点 Mandelbrot，32/1372 次迭代） |
| `arith_int_small/large` | compute | 2M / 8M 次 | 整数加/乘/取模热循环 |
| `arith_float_small/large` | compute | 2M / 8M 次 | `math:sqrt`/除法/加法浮点循环（1e-9 相对容差） |
| `list_ops_small/large` | collections | 100k / 400k | `lists:seq/map/sort/sum` |
| `map_ops_small/large` | collections | 200k / 800k | `maps` put/get |
| `binary_ops_small/large` | binary | 20k / 80k | 64 位整数二进制构造与解析求和 |
| `ets_ops_small/large` | collections | 100k / 400k | `ets` 插入/查找循环 |
| `pingpong_small/large` | message | 100k / 400k | 双进程 ping-pong 消息往返（校验收包计数） |

指标：墙钟中位数（s，lower_is_better）+ 进程峰值 RSS 中位数（MiB，lower_is_better）。
RSS 由 GNU `/usr/bin/time -f %M` 读取被测进程本身；墙钟由 `scripts/run_timed.py` 测量。

严格解析：缺样本 / 非零退出 / 超时 / wall 或 RSS 非正 / 校验和不符 / 多出场景目录 →
`test` 阶段退出 `50`，不补零、不插值。

## 5. 架构边界

- aarch64（鲲鹏 / Blue runner）为正式性能证据；x86_64 本机运行只验证契约、六阶段流程和
  校验和，不作为性能结论。
- `bang`/`big`/`mbrot`/`pingpong` 会创建 Erlang 进程，但都在**单个 OS 进程、单个节点**内运行；
  不启动分布式节点、不使用 bencherl 的 slave/OTP 多版本 harness。
- `arith_float` 采用 `1e-9` 相对容差（同一 IEEE double 运算序列）；整数场景要求完全一致。

## 6. 运行方式

框架（等价于 CI）：

```bash
python3 framework/run_case.py \
  --case software/Toolchain/erlang/case.yaml \
  --version 29.1.2 --architecture aarch64 --run-id <run-id> \
  --stage prepare|build|start|test|stop|finalize
```

独立入口（可在仓库外运行）：

```bash
cd software/Toolchain/erlang
PERF_REPS=5 bash erlang_test.sh --results-dir /tmp/erlang-results
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`（`base`/`optimized`）、
`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`（默认 5）、`PERF_ERLANG_OFFLINE_DIR`、
`PERF_ERLANG_SOURCE_MIRROR`、`PERF_ERLANG_BENCHERL_DIR`、`BENCH_BUILD_JOBS`。`optimized`
变体保留：显式返回 `30`，不写 `build_variant.json`，不回落 base。

## 7. 实测记录（x86_64，仅链路验证）

见本条目 `adaptation/qa/37-erlang-QA.md`：本机六阶段耗时、20 场景中位数样本、5 重复一致性、
负向 `optimized`=30 与并发噪声说明。

## 8. 容器化执行

所有阶段都在本用例独占的 openEuler 24.03 LTS SP4 容器内执行
（`scripts/common.sh` 中 `container-runtime` 区块）；宿主机只保留 Docker、下载与校验工具、
Framework 以及严格结果解析。

| 项目 | 取值 |
| --- | --- |
| 镜像 | `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.x86_64.tar.xz`（缺失时才从 `repo.openeuler.org` 下载，随后用同目录 `.sha256sum` 校验并加载） |
| 容器名 | `boostkit-erlang-<arch>-<run-id>` |
| 标签 | `boostkit.erlang.run-id=<run-id>`；标签不匹配的容器一律不删除 |
| 挂载 | `${PERF_WORK_DIR}`（源码、构建树、ebin、runs）、`${RESULTS_DIR}`、用例目录（只读）、`/etc/passwd`、`/etc/group` |
| 网络 | host 网络；依赖安装走华为 openEuler 镜像，测量阶段离线 |
| 宿主机职责 | 镜像下载与 SHA-256 校验、OTP 源码/bencherl 文件下载与校验、结果解析、Framework 集成 |
| 容器职责 | dnf 安装 `gcc`/`make`/`ncurses-devel`/`openssl-devel`/`perl`/`python3` 等、源码解包、configure/make/install、`erl`/`erlc` 版本探测、workload 编译、全部计时进程 |
| 清理 | `stop_erlang_runtime` 先 `remove_erlang_container`，再报告证据目录；重复调用安全 |

容器内所有 dnf 安装统一带 `--setopt=install_weak_deps=False`：容器以只读方式挂载 `/etc/passwd`、`/etc/group`，弱依赖包的 rpm scriptlet（`groupadd`/`useradd`）会失败并让 dnf 非零退出。

计时命令通过 `erlang_container_exec_at` 进入容器执行，`docker exec` 不在计时窗口内。
独立入口 `erlang_test.sh` 同样需要可访问的 Docker daemon；否则 build 阶段返回 `30`。

## 9. 故障排查

- **configure 失败**：检查 `build/configure.log`；容器内已安装 ncurses/OpenSSL 头文件，
  若仍失败先确认 `prepare_erlang_build_container` 的 dnf 输出。
- **make 失败**：检查 `build/make.log`；`-j4` 为并行上限。
- **bencherl 文件下载失败**：优先离线目录 `bencherl/`；每个文件校验固定 SHA-256。
- **erlc 失败**：`mbrot.erl` 的 `-compile(native).` 必须已被构建脚本删除（OTP 24+ 无 HiPE）。
- **下载慢/失败**：优先离线目录；镜像同样校验 SHA-256。
- **校验和不符**：对比 `runs/<scenario>/rep*.log` 的 `RESULT` 行与
  `benchmarks/scenarios.psv` 的提交值。

## 10. 许可证

- Erlang/OTP：Apache License 2.0（见源码包 `LICENSE.txt`）。
- bencherl handler（`bang.erl`/`big.erl`/`mbrot.erl`）：Erlang Public License 1.1（文件头
  版权声明保留）；构建时按固定 SHA-256 获取、**不随本仓库再分发**。
- 本目录自写的 benchmark 驱动与适配脚本跟随仓库既有用例的 MIT 许可。
