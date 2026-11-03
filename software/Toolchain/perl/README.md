# Perl 5.44.0 性能测试用例

本用例属于 **Toolchain** 类别，按仓库适配契约（`case.yaml` 的 shell-functions 六阶段：
prepare/build/start/test/stop/finalize）实现，输出 `build_variant.json`、`raw-output.log`、
`results.json` 与 `runs/` 原始样本。正式性能证据来自 GitHub Actions
`Blue: Manual performance evaluation` 的 aarch64 运行；本机 x86_64 只做功能与链路验证。

## 1. 版本与制品来源

| 项目 | 值 |
|---|---|
| 目标版本 | **Perl 5.44.0** |
| 官方源码 | `https://www.cpan.org/src/5.0/perl-5.44.0.tar.gz` |
| 官方 SHA-256 | `3b855066b92491cb40e86affb1ca57d1a388aa43e51b91c7806a32c2f65f96c3`（cpan.org 官方 `.sha256` 文件） |
| 源码大小 | 21,265,451 字节 |
| 离线预置目录 | `/home/runner/software/perl/perl-5.44.0.tar.gz` |
| 镜像顺序 | `PERF_PERL_SOURCE_MIRROR` → 清华 TUNA CPAN → 阿里云 CPAN → 官方 cpan.org，每一源都校验同一 SHA-256 |

构建只需要 `gcc`、`make`、`tar`、`curl`（官方 tarball 自带 `Configure`，不需要
autoconf/automake）。Runner 使用 `dnf install gcc make tar curl bzip2 xz`，Ubuntu 使用
`apt-get install gcc make tar curl bzip2 xz-utils`；脚本在安装后逐条自检命令是否存在。

## 2. 安装与构建（固定口径）

构建在用例独占的 openEuler 24.03 LTS SP4 容器内执行（`prepare_perl_build_container` 用
dnf 安装 `gcc`/`make`/`python3` 等，宿主不装构建包）：

```bash
# 容器内，工作目录 <workdir>/perl-src
./Configure -des -Dprefix=<workdir>/perl-install \
    -Dman1dir=none -Dman3dir=none -Dcc=gcc \
    -Dcf_by=perf -Dcf_email=perf@example.com
make -j4
make install
```

- 不含线程选项、调试选项和第三方 CPAN 模块；只使用 Perl 核心发行版自带的 `Benchmark`。
- 构建完成后执行 `perl -e 'print $^V'` 与 `perl -v`，实际版本必须等于 `5.44.0`
  （写入 `results/actual-version.txt`），并验证核心 `Benchmark` 模块可加载。
- 构建日志保留在 `<workdir>/build/{configure,make,install}.log`，失败时把尾部 40 行打印到
  stdout 并以 `30` 退出。

## 3. 完整测试口径（15 场景 × 2 指标）

每场景**预热 1 次 + 5 次独立测量**，取中位数；`results.json` 保留全部样本与
min/max/mean/stdev。测量阶段完全离线，工作负载由仓库内 `benchmarks/bench.pl` 生成，
每个场景输出确定性的 `RESULT scenario=... checksum=...`，解析阶段逐场景核验。

| 场景 | 维度 | 规模 | 口径 |
|---|---|---|---|
| `arith_int_small/large` | compute | 2M / 8M 次 | 整数加/乘/取模热循环 |
| `arith_float_small/large` | compute | 2M / 8M 次 | `sqrt`/除法/加法浮点循环（IEEE double，1e-9 相对容差） |
| `string_concat_small/large` | strings | 200k / 800k 次 | 格式化字符串拼接，校验总长度 |
| `regex_subst_small/large` | strings | 20k / 80k 行 | 正则替换统计替换次数 |
| `hash_ops_small/large` | hashing | 200k / 800k 键 | 字符串键哈希插入/查找/删除 |
| `array_sort_small/large` | sorting | 100k / 400k 值 | 固定 LCG 序列的数值排序 |
| `sub_calls_small/large` | calls | 2M / 8M 次 | 两参数子程序调用开销 |
| `upstream_benchmark` | upstream | 固定 | **Perl 核心 `Benchmark` 模块** `timethese`，原始报告保留在 `runs/` 日志 |

指标：墙钟中位数（s，lower_is_better）+ 进程峰值 RSS 中位数（MiB，lower_is_better）。
RSS 由 GNU `/usr/bin/time -f %M` 读取被测进程本身；墙钟由 `scripts/run_timed.py` 测量。

严格解析：缺样本 / 非零退出 / 超时 / wall 或 RSS 非正 / 校验和不符 / 多出场景目录 →
`test` 阶段退出 `50`，不补零、不插值。

## 4. 架构边界

- aarch64（鲲鹏 / Blue runner）为正式性能证据；x86_64 本机运行只验证契约、六阶段流程和
  校验和，不作为性能结论。
- `arith_float` 采用 `1e-9` 相对容差：两端均为同一 IEEE double 运算序列，容差只吸收编译
  器对 `sqrt` 的处理差异；整数场景要求完全一致。

## 5. 运行方式

框架（等价于 CI）：

```bash
python3 framework/run_case.py \
  --case software/Toolchain/perl/case.yaml \
  --version 5.44.0 --architecture aarch64 --run-id <run-id> \
  --stage prepare|build|start|test|stop|finalize
```

独立入口（可在仓库外运行）：

```bash
cd software/Toolchain/perl
PERF_REPS=5 bash perl_test.sh --results-dir /tmp/perl-results
```

环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`（`base`/`optimized`）、
`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`（默认 5）、`PERF_PERL_OFFLINE_DIR`、
`PERF_PERL_SOURCE_MIRROR`、`BENCH_BUILD_JOBS`。`optimized` 变体保留：显式返回 `30`，
不写 `build_variant.json`，不回落 base。

## 6. 实测记录（x86_64，仅链路验证）

见本条目 `adaptation/qa/34-perl-QA.md`：记录本机六阶段各阶段耗时、15 场景中位数样本、
5 重复一致性、负向 `optimized`=30 结果与并发噪声说明。

## 7. 容器化执行

所有阶段都在本用例独占的 openEuler 24.03 LTS SP4 容器内执行
（`scripts/common.sh` 中 `container-runtime` 区块）；宿主机只保留 Docker、下载与校验工具、
Framework 以及严格结果解析。

| 项目 | 取值 |
| --- | --- |
| 镜像 | `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.x86_64.tar.xz`（缺失时才从 `repo.openeuler.org` 下载，随后用同目录 `.sha256sum` 校验并加载） |
| 容器名 | `boostkit-perl-<arch>-<run-id>` |
| 标签 | `boostkit.perl.run-id=<run-id>`；标签不匹配的容器一律不删除 |
| 挂载 | `${PERF_WORK_DIR}`（源码、构建树、安装 prefix、runs）、`${RESULTS_DIR}`、用例目录（只读）、`/etc/passwd`、`/etc/group` |
| 网络 | host 网络；依赖安装走华为 openEuler 镜像，测量阶段离线 |
| 宿主机职责 | 镜像下载与 SHA-256 校验、Perl 源码归档下载与官方 SHA-256 校验、结果解析、Framework 集成 |
| 容器职责 | dnf 安装 `gcc`/`make`/`python3` 等、源码解包、`Configure`/`make`/`make install`、`perl -v`/`$^V` 版本探测、`Benchmark` 模块可用性检查、workload smoke、全部计时进程与 `run_timed.py` |
| 清理 | `stop_perl_runtime` 先 `remove_perl_container`（幂等），再报告证据目录；重复调用安全 |

容器内所有 dnf 安装统一带 `--setopt=install_weak_deps=False`：容器以只读方式挂载 `/etc/passwd`、`/etc/group`，弱依赖包的 rpm scriptlet（`groupadd`/`useradd`）会失败并让 dnf 非零退出。

计时命令通过 `perl_container_exec_at` 进入容器执行，`docker exec` 不在计时窗口内。
独立入口 `perl_test.sh` 同样需要可访问的 Docker daemon；否则 build 阶段返回 `30`。

## 8. 故障排查

- **下载慢/失败**：优先使用离线目录；镜像同样校验官方 SHA-256，任何源内容不一致立即失败。
- **Configure 失败**：检查 `build/configure.log`；容器内已装 `gcc`/`make`，
  若仍失败先确认 `prepare_perl_build_container` 的 dnf 输出。
- **make 失败**：检查 `build/make.log`，`-j4` 是并行构建上限（与 CI 其他任务共存）。
- **Benchmark 模块加载失败**：说明 `make install` 未完成或 `@INC` 被环境变量污染；
  本用例只用构建出的 `bin/perl` 及其默认 `@INC`。
- **校验和不符**：说明负载、解释器或源码被改动；直接对比 `runs/<scenario>/rep*.log` 中
  `RESULT` 行与 `benchmarks/scenarios.psv` 的提交值。

## 9. 许可证

Perl 采用 Artistic License 1.0 / GPL 1.0 双许可（见源码包 `Copying`）；本目录自写的
benchmark 脚本与适配脚本跟随仓库既有用例的 MIT 许可。
