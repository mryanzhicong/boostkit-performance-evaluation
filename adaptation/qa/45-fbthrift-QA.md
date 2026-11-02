# fbthrift v2026.10.26.00 接入 QA

- 结论：**通过（本地 x86_64 证据完整）**。构建、启动、测试、停止、finalize
  六阶段在 Ubuntu 22.04 / x86_64 上全部通过，被测量程序是上游 fbthrift 自带的
  `ProtocolBench`（Google Benchmark），不是替代程序；30 个指标全部由严格解析器
  从原始 Google Benchmark JSON 与 GNU time 记录派生，无补零、无伪造。
- 证据边界：aarch64 侧只做了脚本与依赖映射的静态审查，**没有**在 aarch64 机器上
  实跑，最终结论必须在专用 Runner 上复核（见第 7、8 节）。
- 分支：`adapt-fbthrift-v2026.10.26.00`；工作副本
  `D:\workspace\Performance_evaluation\work\fbthrift\repo`。

## 1. 契约核对

### 1.1 文件清单与权限

| 文件 | 作用 | 权限（git index） |
|---|---|---|
| `software/Acceleration/fbthrift/README.md` | 中文说明，章节对齐 maven/folly 模板 | 100644 |
| `software/Acceleration/fbthrift/case.yaml` | 用例注册（category `Acceleration`） | 100644 |
| `software/Acceleration/fbthrift/fbthrift_test.sh` | 软件入口（四阶段 + system/finalize） | **100755** |
| `software/Acceleration/fbthrift/scripts/common.sh` | 私有路径、pinned 版本、多源下载、系统依赖 | 100644 |
| `software/Acceleration/fbthrift/scripts/builders/base.sh` | 依赖链与 fbthrift 构建、实际版本回读 | 100644 |
| `software/Acceleration/fbthrift/scripts/builders/dispatch.sh` | base/optimized 分派，写 `build_variant.json` | 100644 |
| `software/Acceleration/fbthrift/scripts/builders/optimized.sh` | 未实现的调优版，固定返回 30 | 100644 |
| `software/Acceleration/fbthrift/scripts/stages/start.sh` | 校验二进制/版本/用例清单 | 100644 |
| `software/Acceleration/fbthrift/scripts/stages/test.sh` | 预热 + 重复测量 + 调用解析器 | 100644 |
| `software/Acceleration/fbthrift/scripts/stages/stop.sh` | 幂等空操作（前台基准） | 100644 |
| `software/Acceleration/fbthrift/scripts/results/parse_benchmark.py` | 严格解析与统计 | **100755** |
| `software/Acceleration/fbthrift/scripts/results/standalone_runtime.py` | 独立运行的 system/build-info/finalize | **100755** |
| `software/Acceleration/fbthrift/scripts/scenarios.tsv` | 10 个场景的锚定矩阵 | 100644 |
| `config/categories.yaml` | 新增 `Acceleration: [fbthrift]` | 100644 |
| `.github/workflows/{compare-existing-results,development-performance-test,performance-test-blue,performance-test}.yml` | `software.options` 按字母序插入 `- fbthrift` | 100644 |
| `adaptation/qa/45-fbthrift-QA.md` | 本文件 | 100644 |

除 `fbthrift_test.sh`、`parse_benchmark.py`、`standalone_runtime.py` 外没有
其它可执行位；全部新增文件为 LF。未触碰 `framework/**`、`config/defaults.yaml`、
`.github/scripts/**` 或其它软件目录。

### 1.2 环境契约

`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`RESULTS_DIR`、`PERF_RUN_ID`、
`PERF_WORK_DIR`、`PERF_ACTUAL_VERSION_FILE` 均由 Framework 注入并在脚本中
使用；可调项 `PERF_REPS`（默认 5）、`PERF_WARMUP_RUNS`（默认 1）、
`PERF_BENCHMARK_MIN_TIME`（默认 5s）、`PERF_WARMUP_MIN_TIME`（默认 1s）、
`PERF_BUILD_JOBS`（默认 6）、`PERF_CMAKE_BIN`、`PERF_PROXY`、
`PERF_FBTHRIFT_OFFLINE_DIR`（默认 `/home/runner/software/fbthrift/`）。

退出码：参数错误 20、build 30、test 50、清理 60；`optimized` 变体在构建阶段
返回 30 且不写 `build_variant.json`。

## 2. 静态检查

```text
bash -n software/Acceleration/fbthrift/fbthrift_test.sh            # OK
bash -n scripts/common.sh scripts/builders/*.sh scripts/stages/*.sh # OK
python3 -m compileall -q software/Acceleration/fbthrift/scripts     # OK
python3 framework/catalog.py validate                              # 24 个 case 全部 OK
python3 framework/catalog.py matrix --software fbthrift --architecture x86_64
  -> {"category":"Acceleration","software":"fbthrift","version":"2026.10.26.00",
      "arch":"x86_64","runner_label":"PERF_RUNNER_X86_64",
      "timeout_minutes":240,"job_timeout_minutes":270,
      "case_path":"software/Acceleration/fbthrift/case.yaml"}
```

## 3. 六阶段本地验证

环境：Ubuntu 22.04.5 LTS（WSL2），root，20 vCPU（Intel i7-14700），23 GiB 内存，
GCC 11.4.0，CMake 3.31.6（`PERF_CMAKE_BIN=/root/venvs/perf/bin/cmake`，
系统自带 3.22.1 低于 fbthrift 要求的 3.24）。构建与测量期间同一台机器上还有
其它 3 个并行编译任务（共享负载，见第 8 节）。

命令（`framework/run_case.py` 逐阶段执行，`PERF_REPS=5`）：

```bash
python3 framework/run_case.py --case software/Acceleration/fbthrift/case.yaml \
  --version 2026.10.26.00 --architecture x86_64 \
  --run-id local-20261102-final --stage prepare|build|start|test|stop|finalize
```

| 阶段 | 退出码 | 耗时 | 关键产物 |
|---|---|---|---|
| prepare | 0 | 1 s | `system_info.json` |
| build | 0 | **529 s** | `build_variant.json`、`dependencies.json`、`benchmark_listing.txt` |
| start | 0 | <1 s | 二进制/版本/10 用例清单校验通过 |
| test | 0 | **511 s** | `benchmark_raw.txt`、`benchmark_fbthrift.json`、`runs/`（180 个文件） |
| stop | 0 | <1 s | `command-stop.log` |
| finalize | 0 | <1 s | `normalized_result.json`、`report.md`、`status.json` |

`status.json`：

```json
{"category":"Acceleration","software":"fbthrift","version":"2026.10.26.00",
 "architecture":"x86_64","run_id":"local-20261102-final","status":"passed",
 "stage":"complete","failed_stage":null,"exit_code":0,
 "cleanup_status":"pending","service_stop_status":"passed"}
```

`cleanup_status` 为 `pending` 是本地未跑 workflow 的清理步骤所致（Framework
的 `mark_cleanup` 由 workflow 的清理 job 调用）；六个阶段本身全部 passed。
`normalized_result.json` 中 `metrics` 共 **30** 项（10 场景 × 3 指标），
`parameter_signature` 与 `sources` 齐备。

另外先用 `PERF_REPS=1` 从零跑过一轮完整六阶段（build 445 s、test 120 s），
用于快速验证链路；正式数据用上面的 `PERF_REPS=5` 轮次。

## 4. 指标结果（本地 x86_64，5 次独立测量 + 1 次预热的中位数）

| 场景 | ns/op 中位数 | min | max | stdev | objects/s | 峰值 RSS (MiB) |
|---|---:|---:|---:|---:|---:|---:|
| binary_write_complex_struct | 21,177,650 | 20,831,204 | 31,767,060 | 4,795,094 | 47.2 | 207.1 |
| binary_read_complex_struct | 72,556,683 | 72,248,439 | 146,494,758 | 33,014,528 | 13.8 | 365.4 |
| binary_write_big_binary | 54.3 | 48.6 | 96.3 | 20.2 | 18,401,182 | 7.1 |
| binary_read_big_binary | 31.2 | 30.7 | 52.0 | 9.2 | 32,054,693 | 7.1 |
| binary_read_large_map_int | 23,010,152 | 22,654,879 | 24,990,038 | 1,107,277 | 43.5 | 106.5 |
| compact_write_complex_struct | 24,203,487 | 23,067,854 | 26,050,116 | 1,402,249 | 41.3 | 187.5 |
| compact_read_complex_struct | 98,346,656 | 96,953,364 | 118,109,422 | 9,021,747 | 10.2 | 346.0 |
| compact_write_big_binary | 56.6 | 53.7 | 64.5 | 4.2 | 17,659,740 | 7.1 |
| compact_read_big_binary | 34.1 | 31.5 | 58.1 | 11.3 | 29,346,863 | 7.3 |
| compact_read_large_map_int | 31,226,095 | 30,265,404 | 65,183,481 | 15,139,712 | 32.0 | 106.4 |

- 每个指标都带 5 个原始样本（`samples`）与 median/min/max/mean/stdev；
  例如 `binary_write_big_binary__ns_per_op` 的样本为
  `[54.71, 48.55, 48.88, 96.33, 54.34]`。
- 绝对量级由上游数据构造决定：`ComplexStruct` 内含 `LargeListMixed`（1,000,000
  个 `Mixed`）与 `LargeMapInt`（1,000,000 对），单次毫秒级；`BigBinary` 是
  10,000 字节 `folly::IOBuf`，走 IOBuf 链而不是逐字节拷贝，单次几十纳秒。
  两者不可横向比较，也不代表吞吐带宽。
- **序列化字节数没有产出**：上游 `ProtocolBench.cpp` 不调用
  `state.SetBytesProcessed()`，本次也没有给上游打补丁，因此
  `serialized_bytes_per_object` 显式为 `null` 并在 `parameters` 中写明原因
  （符合“若可得”的约定，不做估算）。
- `stdev` 偏大的场景（`binary_read_complex_struct`、`compact_read_large_map_int`）
  是共享机器上邻居编译负载导致的离群点，min/median 与第一次复测一致；正式
  数据应在空载 Runner 上采集。

## 5. 依赖来源与校验

| 组件 | tag | 归档 SHA-256 | 本地来源 |
|---|---|---|---|
| fbthrift | `v2026.10.26.00`（commit `c7fdfc9a80aa162c3934bf325c8e6ba56d15e845`） | `6ad18cfc24297120a536a0ef9c5a84f409c9aa4376057328e8dca9d45587d5a1` | 离线目录 → 校验 → 解包 `fbthrift-2026.10.26.00` |
| folly | `v2026.10.26.00` | `b47fe04b804adfb51c65cda6b171505e67b9d1d69621106e54697821d1bf7ebc` | 同上 |
| fmt | `12.1.0` | `ea7de4299689e12b6dddd392f9896f08fb0777ac7168897a244a6d6085043fea` | 同上 |
| fast_float | `v8.0.0` | `f312f2dc34c61e665f4b132c0307d6f70ad9420185fa831911bc24408acf625d` | 同上 |
| Google Benchmark | `v1.9.5` | `9631341c82bac4a288bef951f8b26b41f69021794184ece969f8473977eaa340` | 同上 |

系统库（本地实测版本，Runner 上用 dnf 对应包，版本可能不同）：boost 1.74、
glog 0.5.0、gflags 2.2.2、libevent 2.1.12、openssl 3.0.2、zlib 1.2.11、
zstd 1.4.8、xxhash 0.8.1、liblz4、libsodium、libunwind、jemalloc、`time`、
`ninja`、`patchelf`、`cmake`（3.31.6）。`dependencies.json` 记录了编译器、
CMake、CPU 与本次实际使用的 5 个归档来源及 SHA-256。

多源顺序：预置离线目录 → `codeload.github.com` → `github.com/archive` →
`gh-proxy.com` → `ghfast.top` → `hub.gitmirror.com`，每个来源都必须匹配同一
SHA-256；全部失败返回 30 并逐条打印尝试的 URL。本地两条路径都实测过：

- 离线路径：预置 `/home/runner/software/fbthrift/*.tar.gz`，
  `fetch_all_sources` 全部命中并解包成功；
- 网络路径：临时移走离线目录后，5 个归档全部通过 `codeload.github.com`
  下载并通过 SHA-256 校验（`NETWORK_FETCH_OK`）。

实际版本回读：fbthrift 的 CMake `project()` 固定 `VERSION 1.0.0`，安装树没有
日期版本文件，因此用“归档 SHA-256 + `ProtocolBench.cpp` /
`ProtocolBenchData.thrift` / folly `CMakeLists.txt` 内容指纹 + ProtocolBench
用例清单”三重证据确认后，从解包目录名读出 `2026.10.26.00` 写入
`PERF_ACTUAL_VERSION_FILE`，与请求版本比较后进入 `build_info.json`
（本机 `actual_version == requested_version == 2026.10.26.00`）。

## 6. 负向与故障路径实测

| 用例 | 期望 | 实测 |
|---|---|---|
| 删除某场景 `rep3.json` | 解析失败、test 50 | `ERROR: missing measurement evidence: .../rep3.json`，rc=1（阶段映射 50） |
| 把 `cpu_time` 改成 NaN | 拒绝非有限值 | `ERROR: cpu_time is not a positive finite number: nan`，rc=1 |
| 删除 GNU time 的 RSS 记录 | 拒绝缺 RSS | `ERROR: no 'Maximum resident set size' record`，rc=1 |
| 场景矩阵只有 5 行 | 拒绝 <6 场景 | `ERROR: scenario matrix must declare 6..10 scenarios, found 5`，rc=1 |
| 单轮 JSON 多出第二个 benchmark | 拒绝多行 | `ERROR: expected exactly 1 measured iteration row, found 2`，rc=1 |
| 下载源不可达 | build 30 且列出全部尝试 | `ERROR: every source for ... failed; tried:` + URL 列表 |
| `--variant optimized` | 30 且无 `build_variant.json` | rc=30，`ERROR: optimized fbthrift build is not implemented yet`，目录中无 `build_variant.json` |
| 未支持版本 `2026.10.27.00` | 参数错误 20 | rc=20，`ERROR: version 2026.10.27.00 has no verified source pins` |

## 7. Runner 适配审查

- **包管理双分支**：Runner 用 `dnf`，本地证据机用 `apt-get`；脚本按
  `command -v dnf` 分支，包名映射分别维护（boost-devel/libboost-all-dev、
  glog-devel/libgoogle-glog-dev、gflags、libevent、openssl、zlib、libzstd、
  xxhash、time、ninja、patchelf）。安装后对每个必需头文件用编译器重新探测，
  仍缺则 build 30，不会带着缺失依赖继续编译。`PERF_PROXY` 会传给包管理器与
  下载用的 curl。移除 double-conversion 与系统 benchmark 的依赖探测（前者
  已不在 folly 2026 依赖里，后者由本用例自建，见 README）。
- **CMake ≥ 3.24**：fbthrift 的 `cmake_minimum_required` 是 3.24；系统 cmake
  过旧且未显式给 `PERF_CMAKE_BIN` 时，脚本会尝试 `python3 -m pip install --user
  "cmake>=3.24,<4"` 并用装好的 cmake，仍失败才 build 30。本地用显式
  `PERF_CMAKE_BIN` 覆盖（pip 回退分支未在本地触发，属于未实测路径）。
- **GCC ≥ 11**：folly/fbthrift 需要 C++20；低于 11 直接 build 30 并提示。
  本地 11.4.0 通过。
- **架构分支**：按 `EXPECTED_ARCH`/`uname -m` 选基线指令集，x86_64 用
  `-march=x86-64-v2`，aarch64 用 `-march=armv8-a`；不做 host-tuned。folly 的
  x86 专属 SIMD 源文件由其 CMake 在非 x86 平台排除，aarch64 上不会尝试编译
  AVX2 文件。jemalloc 由 folly 构建时的头文件探测自动决定，不强制。
- **构建裁剪**：`THRIFT_RPC=OFF`、`THRIFT_TESTS=OFF`、`THRIFT_BENCHMARKS=ON`、
  `THRIFT_PY_DEPRECATED=OFF`；不构建 fizz/wangle/mvfst/fb303。原因：这四者只
  出现在上游 manifest 的 `feature_rpc=on` 分组里（fb303 与 fbthrift 的依赖
  方向相反），ProtocolBench 只链接协议库与 Folly，不经过 RPC 传输层。仓库地址
  事实核对：fizz 在 `facebookincubator/fizz`（`facebook/fizz` 返回 404），
  wangle/fb303/mvfst 在 `facebook/*`，四者的 `v2026.10.26.00` tag 实测均存在
  （codeload 200）。如果后续需要 RPC 服务器口径，需要打开 `THRIFT_RPC=ON`、
  追加 fizz/wangle/mvfst/fb303 + libsodium 依赖并重新做六阶段验证；当前用例
  明确只覆盖协议序列化/反序列化路径。
- **磁盘与时限**：单次 run 的私有工作目录约 2.6 GiB（install 占 894 MiB），
  `timeout_minutes` 240 足够（本地 5 次重复整轮约 17 分钟）。
- **aarch64 未实测**：仓库里没有 aarch64 机器，`catalog.py matrix` 只验证了
  x86_64；aarch64 的包名映射、`-march=armv8-a` 与协议基准数值必须在
  `PERF_RUNNER_AARCH64` 上复核。

## 8. 已知限制与风险

1. **aarch64 无本地证据**：只验证了脚本分支，未实跑；这是本用例最大的证据缺口。
2. **测量噪声**：本地测量时机器上还有 3 个并行编译任务，`ComplexStruct` 读
   场景的 stdev 达到 33–45%，出现 1.4–1.5 倍离群点；正式数据需空载 Runner。
3. **不是全量基准**：ProtocolBench 共 897 个用例，本用例固定 10 个用于跨版本
   对比，只在同一场景集合内可比。
4. **无字节数指标**：上游不报告 bytes processed，未打补丁，`serialized_bytes`
   为 `null`（已写明原因）。
5. **日期 tag 非 LTS**：fbthrift 每周发日期 tag，GitHub `releases/latest` 上
   是 2020 年旧 release，不能作为选版依据；重跑必须用固定 SHA-256 归档。
6. **依赖裁剪**：不构建 RPC/Python/测试栈，因此本用例的结论只覆盖协议
   序列化/反序列化路径，不代表 RPC 服务器性能；RPC 口径需要 `THRIFT_RPC=ON`
   加 fizz/wangle/mvfst/fb303 后重做验证（tag 与仓库地址见第 7 节）。
7. **BigBinary 的语义**：10 KB `folly::IOBuf` 走零拷贝链，ns/op 主要是协议
   封装开销，不能读成 10 KB 拷贝带宽。
8. **pip cmake 回退未实测**：逻辑存在，但本地用显式 `PERF_CMAKE_BIN` 跳过。
9. **系统库版本浮动**：dnf 与 apt 的 boost/glog/openssl 版本不同，跨架构数值
   对比只用于同架构回归，不作为跨平台结论。

## 9. 复现步骤

```bash
# 静态检查
bash -n software/Acceleration/fbthrift/fbthrift_test.sh
python3 framework/catalog.py validate
python3 framework/catalog.py matrix --software fbthrift --architecture x86_64

# 本地六阶段（需要 cmake >= 3.24；本机用 pip 安装的 cmake）
PERF_REPS=5 PERF_CMAKE_BIN=/root/venvs/perf/bin/cmake \
python3 framework/run_case.py --case software/Acceleration/fbthrift/case.yaml \
  --version 2026.10.26.00 --architecture x86_64 \
  --run-id <run-id> --stage prepare

# ... 依次 build / start / test / stop / finalize

# 负向检查
bash software/Acceleration/fbthrift/fbthrift_test.sh --variant optimized \
  --results-dir /tmp/fbthrift-optimized-check    # 期望 30，无 build_variant.json
```
