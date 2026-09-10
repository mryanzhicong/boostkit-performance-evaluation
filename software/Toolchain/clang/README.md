# Clang/LLVM 性能测试说明

本目录测试 LLVM 官方预编译的 Clang `22.1.8` 工具链（Linux X64/ARM64
tarball），并使用 SQLite 官方发布的固定版本基准源码（amalgamation +
`speedtest1`）进行 x86_64 与 aarch64 开箱性能对比。软件入口为
`clang_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、`start`、
`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 Clang `22.1.8`。新增版本或架构时，必须同时在
`clang_test.sh` 中声明官方 tarball 文件名及其 SHA-256，不能跳过校验。

## 构建与安装

这里的“构建”是部署 LLVM 官方预编译 tarball，不从源码编译 LLVM，也不
安装系统级 LLVM 软件包。

1. 根据版本与架构选择官方 tarball。当前包名为：

   | 架构 | 包名 |
   |---|---|
   | `x86_64` | `LLVM-22.1.8-Linux-X64.tar.xz` |
   | `aarch64` | `LLVM-22.1.8-Linux-ARM64.tar.xz` |

2. 依次在以下位置获取包：

   1. `/home/runner/software/clang/<包名>` 的本地离线包；
   2. 当前任务工作目录中的同名缓存包；
   3. LLVM 官方 GitHub Release 地址
      `https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/`。

3. 使用清单中声明的官方 SHA-256 校验包完整性，校验失败立即退出。
4. 解压到本次任务的 `PERF_WORK_DIR/llvm`（tarball 无论解压出版本化目录
   还是直接展开 `bin/`/`lib/`，脚本都会定位到实际携带 `bin/clang` 的目录），
   验证 `clang`、`clang++` 可执行、动态依赖完整，且 `clang --version`
   报告的版本与请求版本一致。该目录仅供本次任务使用。
5. 运行时缺失的系统命令由脚本自动通过 `dnf` 安装；非 root Runner 使用
   `sudo -n dnf`。

脚本实际使用的下载和校验命令形态如下。`<包名>` 按上表选择：

```bash
curl -fSL --retry 3 --connect-timeout 30 \
  -o "${PERF_WORK_DIR}/<包名>" \
  "https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/<包名>"
sha256sum "${PERF_WORK_DIR}/<包名>"
tar -xJf "${PERF_WORK_DIR}/<包名>" -C "${LLVM_UNPACK_DIR}"
```

在 Runner 预置离线包时，应使用与目标架构相符的文件名。例如 aarch64：

```bash
sudo install -d -o runner -g runner /home/runner/software/clang
sudo install -o runner -g runner LLVM-22.1.8-Linux-ARM64.tar.xz \
  /home/runner/software/clang/
sha256sum /home/runner/software/clang/LLVM-22.1.8-Linux-ARM64.tar.xz
```

## 基准就绪（start）

Clang 没有常驻服务。`start` 阶段把固定的 SQLite 基准源码布置到本次任务
的 `PERF_WORK_DIR/benchmark` 目录：

| 组件 | 固定来源 |
|---|---|
| SQLite amalgamation | `https://www.sqlite.org/2026/sqlite-amalgamation-3530400.zip` |
| SQLite 源码树（含 `speedtest1.c`） | `https://www.sqlite.org/2026/sqlite-src-3530400.zip` |

两个包都使用 SQLite 官方发布的 SHA3-256 校验（SQLite 官网不提供
SHA-256），由 `python3 hashlib.sha3_256` 计算：

```bash
python3 -c 'import hashlib,sys; print(hashlib.sha3_256(open(sys.argv[1],"rb").read()).hexdigest())' \
  "${PERF_WORK_DIR}/benchmark/sqlite-amalgamation-3530400.zip"
```

源码就绪后，`start` 阶段用被测 clang 完整构建并空跑一次 `speedtest1`
（`--size 100 --memdb`），确认工具链、基准源码和链接环境全部可用后丢弃
冒烟产物；`test` 阶段只对已验证的组合计时。

## 性能测试

测试评估编译器的两个维度：**编译吞吐**（编译同一源码的耗时）与
**生成代码质量**（`-O2` 产物运行 `speedtest1` 的耗时），同时保留每次
构建的产物大小。轮数固定为每档 5 轮（`CLANG_ROUNDS` 可覆盖），耗时用
`date +%s.%N` 前后差值测量：

1. **compile 场景**：对 `sqlite3.c`（约 26 万行 amalgamation）分别以
   `-O0`、`-O2`、`-Os` 各编译 5 轮，串行单文件编译，记录每轮墙钟时间
   与 `sqlite3.o` 目标文件大小：

   ```bash
   "${CLANG_BIN}" -O2 -c sqlite3.c -o sqlite3-O2-r1.o
   ```

2. **speedtest1 场景**：用被测 clang 以 `-O2` 构建官方 `speedtest1`，
   再以 `--memdb`（内存数据库）分别按 `--size 100000` 和
   `--size 500000` 各运行 5 轮，记录每轮墙钟时间与可执行文件大小：

   ```bash
   "${CLANG_BIN}" -O2 -I"${AMALGAMATION_DIR}" \
     test/speedtest1.c sqlite3.c -lm -o speedtest1
   (cd <round-dir> && ../speedtest1 --size 100000 --memdb test.db)
   ```

完整控制台输出（含 `speedtest1` 每轮逐项输出）保留为
`sqlite_clang_raw.log`，其中的 `result scenario=... workload=... round=...`
结构化行由 `scripts/collect_clang_benchmark.py` 汇总。

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、stop
并保存同样的产物。例如：

```bash
bash software/Toolchain/clang/clang_test.sh \
  --version 22.1.8 \
  --results-dir /home/runner/boostkit-perf/clang/results/22.1.8
```

## 指标

每个“场景 + 负载档位”组合保留 3 个字段，不做平均、加权或跨场景聚合。
总计为：

```text
（3 个编译档位 + 2 个运行档位）× 3 个指标 = 15 个指标
```

| 原始字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `median wall time` | `compile sqlite3.c --opt=<档位>: median wall time` / `speedtest1 --size=<档位>: median wall time` | s | 越小越好 | 每档 5 轮墙钟时间的中位数 |
| `fastest wall time` | `... --opt=<档位>: fastest wall time` / `... --size=<档位>: fastest wall time` | s | 越小越好 | 每档 5 轮中的最快一轮 |
| `artifact size` | `... --opt=<档位>: artifact size` / `... --size=<档位>: artifact size` | KiB | 越小越好 | `sqlite3.o` 目标文件 / `speedtest1` 可执行文件大小 |

报告按场景（compile / speedtest1）分组；每组以负载档位为行、三个字段
为列，便于在相同负载下比较 x86_64 与 aarch64。测试工具及其固定版本会
同时列在报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `sqlite_clang_raw.log`：原始控制台输出；
- `results.json`：15 个结构化指标及其来源文件名。

`stop` 阶段没有需要停止的服务，仅移除本次任务的基准数据目录
`PERF_WORK_DIR/benchmark`（SQLite 源码、编译产物与运行目录）。
Standalone 模式结束时还会删除本次任务专属的
`/home/runner/boostkit-perf/clang/local-*` 工作目录；Framework 随后执行
Runner 级环境清理。
