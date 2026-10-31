# Clang 23.1.4 性能测试

本用例在 x86_64、aarch64 Runner 上部署 LLVM 官方预编译 Clang 工具链
（`LLVM-23.1.4-Linux-X64.tar.xz` / `LLVM-23.1.4-Linux-ARM64.tar.xz`），使用 SQLite
官方固定版本源码（amalgamation 与 `speedtest1`）作为基准负载，进行开箱性能对比。
不从源码编译 LLVM，不安装系统级 Clang 软件包，不做绑核或调优。**构建与测试全部在
openEuler 24.03 LTS SP4 容器内运行**（基镜像与用法参照 MySQL 用例），容器不绑核、
不绑 NUMA、使用宿主机网络；源码、工具链和结果目录通过 bind mount 保存在宿主机。

软件入口为 `clang_test.sh`。Framework 通过 `case.yaml` 分别调用构建、启动、测试和
停止阶段；直接执行入口脚本也使用这些阶段函数。基础版构建位于
`scripts/builders/base.sh`，公共路径在 `scripts/common.sh`，结果处理位于
`scripts/results/`。工作流可选择 `base` 或 `optimized`，默认 `base`；
`optimized` 构建尚未实现，选择后会在构建阶段明确失败，不会退回基础版。

## 软件与测试工具

| 项目 | 来源与版本 | 位置 |
|---|---|---|
| Clang | [LLVM 官方 GitHub Release](https://github.com/llvm/llvm-project/releases/tag/llvmorg-23.1.4) 预编译 tarball | 宿主机优先读取 `/home/runner/software/clang/`，缺失时下载并校验；容器内解压到 `${PERF_WORK_DIR}/llvm` |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | 优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载；SHA-256 校验后 `docker load` |
| SQLite amalgamation | 官方 `https://www.sqlite.org/2026/sqlite-amalgamation-3540100.zip`（版本 3.54.1） | `${PERF_WORK_DIR}/benchmark/amalgamation/` |
| SQLite 源码树 | 官方 `https://www.sqlite.org/2026/sqlite-src-3540100.zip`（含 `speedtest1.c`） | `${PERF_WORK_DIR}/benchmark/sqlite-src/` |

SQLite 官方公布的是 SHA3-256（不提供 SHA-256），脚本用 `python3 hashlib.sha3_256`
校验；LLVM tarball 使用官方 Release 的 SHA-256。两者校验失败都会中止。

| 包 | 下载地址 | 校验值 |
|---|---|---|
| `LLVM-23.1.4-Linux-X64.tar.xz` | <https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.4/LLVM-23.1.4-Linux-X64.tar.xz> | SHA-256 `25d814fda50d5fb0084b42be09605d8b1595d49d5e2e03a3345d7e112ff6f9f3` |
| `LLVM-23.1.4-Linux-ARM64.tar.xz` | <https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.4/LLVM-23.1.4-Linux-ARM64.tar.xz> | SHA-256 `9b27cf263d711aa6ebfd4045ab241d947bd09b3cd19ffa5728f48a80c9eb3a91` |
| `sqlite-amalgamation-3540100.zip` | <https://www.sqlite.org/2026/sqlite-amalgamation-3540100.zip> | SHA3-256 `92281c86e2957f9b9305890f9ac04204caa7b677cc868dc326d942689df28e30` |
| `sqlite-src-3540100.zip` | <https://www.sqlite.org/2026/sqlite-src-3540100.zip> | SHA3-256 `877c6f4996ce7adb368686bce21638de9e3d91534832ad3d9d119037d1bc22ad` |

离线包文件名与上游资产完全一致（LLVM 为 `LLVM-<版本>-Linux-X64/ARM64.tar.xz`，SQLite 为
官方 zip 文件名），不带额外后缀；版本由表中的校验值固定。

下载源按运行环境选择：设置 `PERF_PROXY` 时使用上表的官方地址并走代理；Blue 直连 Runner
访问境外站点受限时，LLVM tarball 默认改用清华 TUNA 的 GitHub Release 镜像：

| 架构 | 镜像地址 |
|---|---|
| `x86_64` | <https://mirrors.tuna.tsinghua.edu.cn/github-release/llvm/llvm-project/LLVM%2023.1.4/LLVM-23.1.4-Linux-X64.tar.xz> |
| `aarch64` | <https://mirrors.tuna.tsinghua.edu.cn/github-release/llvm/llvm-project/LLVM%2023.1.4/LLVM-23.1.4-Linux-ARM64.tar.xz> |

TUNA 镜像的文件大小与官方 Release 资产一致（2017061664 / 1829686400 字节），下载后仍按
上表 SHA-256 校验。SQLite 没有已核实的国内镜像，因此 Blue 直连 Runner 必须把两个 zip
预置到 `/home/runner/software/clang/`；缺失且未设置 `SQLITE_BENCHMARK_BASE` 时会明确
失败而不是长时间重试。`LLVM_ARCHIVE_URL`、`LLVM_RELEASE_BASE`、`SQLITE_BENCHMARK_BASE`
均可覆盖默认选择。

脚本在容器内通过 `dnf` 安装缺失的系统依赖：`tar`、`xz`、`unzip`、`sed`、`findutils`、
`gawk`、`coreutils`、`curl`、`python3`、`which`、`diffutils`、`bash`；容器内仓库切换为
华为云 openEuler 镜像。启用 `PERF_PROXY` 时，容器挂载代理 CA 证书并执行
`update-ca-trust extract`，下载走代理。

## 部署与版本核对

LLVM tarball 优先读取 `/home/runner/software/clang/<包名>`，其次本次任务目录缓存
（离线包会先复制到该目录，容器才能读取），最后使用上节选择的下载地址（代理环境为官方
GitHub Release，直连环境为 TUNA 镜像）。
解压后脚本自动定位携带 `bin/clang` 的目录并作为工具链根目录：

以下命令在私有容器内执行（归档先复制到 `${PERF_WORK_DIR}`，容器才能读取）：

```bash
docker exec "${CLANG_CONTAINER_NAME}" tar -xJf \
  "${PERF_WORK_DIR}/LLVM-23.1.4-Linux-X64.tar.xz" -C "${PERF_WORK_DIR}/llvm-unpack"
docker exec "${CLANG_CONTAINER_NAME}" "${PERF_WORK_DIR}/llvm/bin/clang" --version  # 必须报告 23.1.4
```

构建阶段还会检查 `clang`、`clang++` 可执行、`ldd` 无缺失依赖，并把实际版本写入
`PERF_ACTUAL_VERSION_FILE`，不直接写请求版本。工具链仅位于本次任务私有目录。

## 容器

每个任务创建且仅创建一个私有容器 `boostkit-clang-<架构>-<run-id>`，带
`boostkit.clang.run-id=<run-id>` 归属标签。启动方式：

```bash
docker run --detach --name "${CLANG_CONTAINER_NAME}" \
  --label "boostkit.clang.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${CLANG_CONTAINER_IMAGE}" sleep infinity
```

- 不使用 `--cpus`、`--cpuset-cpus`、`--cpuset-mems`：不绑核、不绑 NUMA。
- `--network=host`：容器直接使用宿主机网络。
- `${PERF_WORK_DIR}` 与 `${RESULTS_DIR}` 以宿主机原路径挂载，工具链和所有测试结果都
  落在宿主机指定目录。
- 容器内仓库切换为华为云 openEuler 镜像；启用 `PERF_PROXY` 时挂载代理 CA 证书并执行
  `update-ca-trust extract`，`dnf`/`curl` 下载走代理。
- `stop` 阶段只停止并删除带本任务归属标签的容器，重复调用安全。

## 基准数据与正式测试

`start` 阶段下载并校验两份 SQLite 包，在容器内解压到 `${PERF_WORK_DIR}/benchmark/`，
再以被测 clang 冒烟构建 `speedtest1` 并运行 `--size 100 --memdb` 一次，确认工具链、基准源码和
链接环境可用；冒烟产物随后丢弃。正式测试只对已验证的组合计时。

`test` 阶段在容器内固定每档 5 轮（`CLANG_ROUNDS` 可覆盖），用 `date +%s.%N`
前后差值计时：

1. **compile 场景**（编译吞吐）：对 `sqlite3.c` 分别以 `-O0`、`-O2`、`-Os` 各编译
   5 轮，记录每轮墙钟时间与 `sqlite3.o` 大小：

   ```bash
   "${CLANG_BIN}" -O2 -c sqlite3.c -o sqlite3-O2-r1.o
   ```

2. **speedtest1 场景**（生成代码质量）：以 `-O2` 构建官方 `speedtest1`，再以
   `--memdb` 分别按 `--size 100000` 和 `--size 500000` 各运行 5 轮，记录每轮墙钟
   时间与可执行文件大小：

   ```bash
   "${CLANG_BIN}" -O2 -I"${AMALGAMATION_DIR}" speedtest1.c sqlite3.c -lm -o speedtest1
   ./speedtest1 --size 100000 --memdb test.db
   ```

固定负载参数写入结果的 `parameters`：SQLite 3.54.1、三个编译档位、两个运行档位、
5 轮。CPU 型号与核数记录在系统信息中，不跨架构强行统一。预计单架构耗时约
30–60 分钟（tarball 下载 5–15 分钟、解压 2–5 分钟、5 档 × 5 轮基准 15–30 分钟）。

## 指标与产物

每个"场景 + 负载档位"组合保留 3 个字段，不做平均、加权或跨场景聚合，总计
`5 × 3 = 15` 个指标：

| 字段 | 指标名格式 | 单位 | 方向 |
|---|---|---|---|
| median wall time | `compile sqlite3.c --opt=<档位>: median wall time` / `speedtest1 --size=<档位>: median wall time` | s | 越小越好 |
| fastest wall time | 同上，`: fastest wall time` | s | 越小越好 |
| artifact size | 同上，`: artifact size` | KiB | 越小越好 |

解析器要求 5 个负载档位全部出现、轮数一致且等于 5、墙钟时间为有限正数、产物大小
为正数；缺失或异常时失败，不补零、不估算。报告按 `compile` / `speedtest1` 分组，
每行是负载档位，列为三个字段。

| `${RESULTS_DIR}` 中的产物 | 内容 |
|---|---|
| `sqlite_clang_raw.log` | 每轮结构化 `result scenario=...` 行与完整控制台输出 |
| `benchmark_clang.json` | 15 个指标、来源字段与固定参数 |
| `build_variant.json` | 构建变体标识 |
| `actual-version.txt` | 从产物读取的实际版本 |
| `results.json`、`status.json`、`report.md` | 独立入口生成的状态、指标与单架构报告 |

`stop` 阶段停止并删除本任务的容器（按归属标签校验），无需停止其他服务；宿主机的
`${PERF_WORK_DIR}` 由 Framework 或独立入口清理，`${RESULTS_DIR}` 保留。脱离 Workflow 执行完整流程：

```bash
bash software/Toolchain/clang/clang_test.sh \
  --version 23.1.4 \
  --variant base \
  --results-dir /home/runner/boostkit-perf/clang/results/23.1.4
```

独立运行时 `--variant` 可选 `base` 或 `optimized`，默认 `base`；调优版结果位于该版本
下的 `optimized/` 子目录。排错时可加 `--keep-workdir` 保留 LLVM 工具链和基准源码。
