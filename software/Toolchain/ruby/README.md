# Ruby 4.0.9 性能测试用例

本用例属于 **Toolchain** 类别，按仓库适配契约（`case.yaml` 的 shell-functions 六阶段：
prepare/build/start/test/stop/finalize）实现，输出 `build_variant.json`、`raw-output.log`、
`results.json` 与 `runs/` 原始样本。正式性能证据来自 GitHub Actions
`Blue: Manual performance evaluation` 的 aarch64 运行；本机 x86_64 只做功能与链路验证。

## 1. 版本与制品来源

| 项目 | 值 |
|---|---|
| 目标版本 | **Ruby 4.0.9** |
| 官方源码 | `https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.9.tar.gz` |
| SHA-256 | `c35350682ff050b79702d57ade4516e7336063f510155d19fb2fb5b3f3909511`（ruby-lang 未发布 `.sha256` 附件，该值由官方归档计算并在每次下载/离线副本上复核） |
| 源码大小 | 23,946,524 字节 |
| 离线预置目录 | `/home/runner/software/ruby/ruby-4.0.9.tar.gz` |
| 镜像顺序 | `PERF_RUBY_SOURCE_MIRROR` → 官方 cache.ruby-lang.org，每个源都校验同一 SHA-256 |

构建依赖（在私有 openEuler 容器内 `dnf install`，见第 7 节）：`gcc`、`make`、`tar`、`curl`、`time`、
`python3` 及 OpenSSL / libyaml / zlib / readline / libffi / gdbm / ncurses / libxcrypt 的 `-devel` 头文件，
安装后逐条自检容器内命令与头文件可用性。

## 2. 安装与构建（固定口径，在私有容器内执行）

```bash
./configure --prefix=<workdir>/ruby-install --disable-install-doc --disable-yjit
make -j4
make install
```

- 仅构建 Ruby 核心与标准库，不安装文档；**YJIT 在构建期关闭**，避免把 JIT 状态带入基线。
- 构建后执行 `ruby --version`，实际版本必须为 `4.0.9`（写入
  `results/actual-version.txt`），并验证标准库 `benchmark` 可加载。
- 构建日志保留在 `<workdir>/build/{configure,make,install}.log`，失败时打印尾部 40 行并以
  `30` 退出。

## 3. 完整测试口径（17 场景 × 2 指标）

每场景**预热 1 次 + 5 次独立测量**，取中位数；`results.json` 保留全部样本与
min/max/mean/stdev。测量阶段完全离线，工作负载为仓库内 `benchmarks/bench.rb`，每个场景输出
确定性的 `RESULT scenario=... checksum=...`，解析阶段逐场景核验。

| 场景 | 维度 | 规模 | 口径 |
|---|---|---|---|
| `arith_int_small/large` | compute | 2M / 8M 次 | 整数加/乘/取模热循环 |
| `arith_float_small/large` | compute | 2M / 8M 次 | `Math.sqrt`/除法/加法浮点循环（1e-9 相对容差） |
| `string_concat_small/large` | strings | 200k / 800k 次 | 格式化字符串拼接，校验总长度 |
| `regex_subst_small/large` | strings | 20k / 80k 行 | 正则替换并统计替换次数 |
| `hash_ops_small/large` | hashing | 200k / 800k 键 | 字符串键 Hash 插入/查找/删除 |
| `array_sort_small/large` | sorting | 100k / 400k 值 | 固定 LCG 序列的数值排序 |
| `method_calls_small/large` | calls | 2M / 8M 次 | 两参数方法调用开销 |
| `block_yield_small/large` | blocks | 1M / 4M 次 | block/yield 调用开销 |
| `upstream_benchmark` | upstream | 固定 | **Ruby 标准库 `Benchmark.bm`**，原始报告保留在 `runs/` 日志 |

指标：墙钟中位数（s，lower_is_better）+ 进程峰值 RSS 中位数（MiB，lower_is_better）。
RSS 由 GNU `/usr/bin/time -f %M` 读取被测进程本身；墙钟由 `scripts/run_timed.py` 测量。

严格解析：缺样本 / 非零退出 / 超时 / wall 或 RSS 非正 / 校验和不符 / 多出场景目录 →
`test` 阶段退出 `50`，不补零、不插值。

## 4. 架构边界

- aarch64（鲲鹏 / Blue runner）为正式性能证据；x86_64 本机运行只验证契约、六阶段流程和
  校验和，不作为性能结论。
- `arith_float` 采用 `1e-9` 相对容差（同一 IEEE double 运算序列）；整数场景要求完全一致。

## 5. 运行方式

框架（等价于 CI；需要可用的 Docker daemon 与 openEuler 24.03 LTS SP4 镜像）：

```bash
python3 framework/run_case.py \
  --case software/Toolchain/ruby/case.yaml \
  --version 4.0.9 --architecture aarch64 --run-id <run-id> \
  --stage prepare|build|start|test|stop|finalize
```

独立入口（可在仓库外运行）：

```bash
cd software/Toolchain/ruby
PERF_REPS=5 bash ruby_test.sh --results-dir /tmp/ruby-results
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`（`base`/`optimized`）、
`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`（默认 5）、`PERF_RUBY_OFFLINE_DIR`、
`PERF_RUBY_SOURCE_MIRROR`、`BENCH_BUILD_JOBS`；容器相关：`RUBY_IMAGE_ARCHIVE_DIR`、
`RUBY_CONTAINER_IMAGE`、`RUBY_CONTAINER_NAME`、`RUBY_CONTAINER_HOME`、`RUBY_CA_ANCHORS_DIR`、
`RUBY_CONTAINER_EXTRA_ARGS`。`optimized` 变体保留：显式返回 `30`，不写 `build_variant.json`，
不回落 base。

## 6. 实测记录（x86_64，仅链路验证）

见本条目 `adaptation/qa/35-ruby-QA.md`：本机六阶段耗时、17 场景中位数样本、5 重复一致性、
负向 `optimized`=30 与并发噪声说明。

## 6. 运行记录

## 7. 容器化执行（openEuler 24.03 LTS SP4）

本用例的 build/start/test/stop 全部在本次任务专属的 openEuler 24.03 LTS SP4 容器内执行；
宿主只负责 Docker 编排、源码下载与 SHA-256 校验、framework 和严格解析器。

| 项 | 值 |
|---|---|
| 镜像 | `openEuler-docker.<arch>.tar.xz`（官方 `repo.openeuler.org`），加载后固定引用；镜像归档与 `.sha256sum` 同时校验，并校验架构与 `/etc/os-release` 的 `24.03` |
| 镜像归档目录 | `RUBY_IMAGE_ARCHIVE_DIR`，默认 `/home/runner/software/openEuler-24.03-LTS-SP4`（本地归档优先，缺失时才下载） |
| 容器名 | `boostkit-ruby-<arch>-<run-id>` |
| 标签 | `boostkit.ruby.run-id=<run-id>`（stop 阶段删除时校验，标签不符拒绝删除并返回 60） |
| 挂载 | `PERF_WORK_DIR`、`RESULTS_DIR`（可写）；用例目录只读（独立入口把结果放在用例目录内时可写）；`/etc/passwd`、`/etc/group`；`--network=host`，不额外加特权 |
| 容器内依赖 | `dnf install gcc make tar curl bzip2 ... openssl-devel libyaml-devel zlib-devel readline-devel libffi-devel gdbm-devel ncurses-devel libxcrypt-devel time python3`；统一带 `--setopt=install_weak_deps=False`，避免弱依赖 rpm scriptlet 在只读 `/etc/passwd` 挂载下创建用户/组失败 |
| 宿主职责 | 下载/离线复制源码包并校验 SHA-256、Docker 镜像准备、framework 六阶段、`parse_benchmark.py` |
| 容器职责 | 依赖安装、解包、`configure`/`make`/`make install`、版本探测、Benchmark 模块自检、全部被测 Ruby 进程 |

与整机执行的差异：被测进程及其父级计时驱动都在容器内，`docker exec` 的管理开销
不进入采样窗口（每个样本仍由 `run_timed.py` 对单个子进程计时）；RSS 仍由容器内
GNU time 取 `%M`，口径与迁移前一致。独立入口（`ruby_test.sh`）同样需要 Docker。

清理：`stop` 阶段先 `remove_ruby_container`（幂等；容器不存在直接返回 0），再报告保留的
work 目录；CI 取消任务残留的旧容器可用 `sweep_ruby_stale_containers` 清理，只匹配
`boostkit-ruby-` 前缀且 run-id 不同的容器。

## 7. 故障排查

- **configure 失败**：检查 `build/configure.log`；Ruby 需要 OpenSSL/libyaml/zlib/readline
  等 `-devel` 头文件，由 build 阶段在容器内 `dnf install` 并自检。
- **make 失败**：检查 `build/make.log`；`-j4` 为并行上限（与 CI 其他任务共存）。
- **下载慢/失败**：优先离线目录；镜像同样校验 SHA-256。
- **Benchmark 模块加载失败**：说明 `make install` 未完成或 `RUBYLIB` 被污染；本用例只使用
  构建出的 `bin/ruby` 及其默认标准库路径。
- **校验和不符**：对比 `runs/<scenario>/rep*.log` 的 `RESULT` 行与
  `benchmarks/scenarios.psv` 的提交值。

## 8. 许可证

Ruby 采用 Ruby License / BSD-2-Clause 双许可（见源码包 `COPYING`）；本目录自写的
benchmark 脚本与适配脚本跟随仓库既有用例的 MIT 许可。
