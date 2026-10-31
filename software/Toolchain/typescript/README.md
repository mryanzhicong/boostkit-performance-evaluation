# TypeScript

TypeScript 7.0.2（原生编译器）负载性能用例。完整口径为**多场景编译器工作负载矩阵（三档规模全量类型检查 + 上游真实工程 + emit + 增量 + project references）**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **7.0.2** |
| 发布包 | `typescript-7.0.2.tgz`（官方发布包）<br>`https://registry.npmjs.org/typescript/-/typescript-7.0.2.tgz`<br>镜像：`https://mirrors.huaweicloud.com/repository/npm/typescript/-/typescript-7.0.2.tgz`<br>SHA-256 `da2513f4b95176d6dde8b51aab7afe8a927656c9d277369793f77f7e59371c08`<br>SHA-512（registry 发布 integrity，base64）`8FYau96o3NKOhbjKi/qNvG/W5jhzxkbdm5sj9AbZ/5T5sWqn3hJgLfGx27sRKZWTvyzCP8dLRBTf5tBTSRVUNA==` |
| 原生编译器后端 x86_64 | `@typescript/typescript-linux-x64-7.0.2.tgz`<br>`https://registry.npmjs.org/@typescript/typescript-linux-x64/-/typescript-linux-x64-7.0.2.tgz`<br>SHA-256 `7ecad6f67377e831856367ab062ef394f21506a611405bf8ac0ff039348637d3`<br>SHA-512 `EYdf2cNg7rgCWJnxCdJ+F3V39O8ihb37eHAu1LK8oAFizgTQbPOK7zHHXbPt8rX24COqODXeI3sIf0fCXG7H/A==` |
| 原生编译器后端 aarch64 | `@typescript/typescript-linux-arm64-7.0.2.tgz`<br>`https://registry.npmjs.org/@typescript/typescript-linux-arm64/-/typescript-linux-arm64-7.0.2.tgz`<br>SHA-256 `c83d931ac9dd7549cde6e71246aa9d6a9812843023df3e277fe3b5dcf41dd0ea`<br>SHA-512 `Qh4eU4/y3yDjnfjjyPYihMj5/ODIlmt+Bzu17OI+fiSRDW57QmU5SiN63exPRNJPKUzcc1INa1NXdrJ+MqHjUQ==` |
| TypeScript 声明运行时 | `engines.node = >=16.20.0` |
| 运行时（固定） | Node.js **v22.23.4**（`test_tools.nodejs`），不使用 Runner 预装 Node |
| Node x86_64 | `node-v22.23.4-linux-x64.tar.xz`<br>`https://nodejs.org/dist/v22.23.4/node-v22.23.4-linux-x64.tar.xz`<br>SHA-256 `1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce` |
| Node aarch64 | `node-v22.23.4-linux-arm64.tar.xz`<br>`https://nodejs.org/dist/v22.23.4/node-v22.23.4-linux-arm64.tar.xz`<br>SHA-256 `6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b` |
| 国内镜像 | Node：`https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v22.23.4/<归档>`<br>TypeScript：`https://mirrors.huaweicloud.com/repository/npm/` |

TypeScript 7 是原生编译器：`typescript` 包本身只是 ESM 启动器 + 编辑器/工具资产，真正的编译器二进制 `lib/tsc` 与标准库 `lib/lib.*.d.ts` 位于按平台发布的 `@typescript/typescript-linux-<arch>` 包。因此**按架构只选择原生后端包**，两架构执行的 JavaScript 启动代码完全一致。所有下载都核对官方校验值：Node 校验 SHA-256；TypeScript 与原生后端同时校验 SHA-256 与 registry 发布的 SHA-512 integrity；校验失败即 `build` 失败（返回 30），不降级、不跳过。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验系统依赖（`curl`、`tar`、`xz`、`sha256sum`、`python3`、`find`），缺失即 `build` 失败。
2. **资产解析**：优先使用预置目录 `/home/runner/software/typescript/` 中的 `node-v22.23.4-linux-<arch>.tar.xz`、`typescript-7.0.2.tgz`、`typescript-linux-<arch>-7.0.2.tgz`（逐字节校验后才使用），缺失或校验不符才从镜像/官方 registry 下载并校验——离线 Runner 只需预置这 3 个文件。
3. 解包固定版本 Node.js 到 `$PERF_WORK_DIR/node-install`，`node --version` 必须等于 `v22.23.4`。
4. 解包 TypeScript 与原生后端到 `$PERF_WORK_DIR/typescript-install/node_modules/{typescript,@typescript/typescript-linux-<arch>}`，并核对 `bin/tsc`、`lib/tsc`、`lib/lib.d.ts` 齐全。
5. 校验 `22.23.4` 满足 TypeScript 声明的 `engines.node = >=16.20.0`（内置比较器，支持 `||` 与 `>= > <= < = ^ ~`），不满足即 `build` 失败。
6. 解析出的编译器版本必须等于 `7.0.2` 并写入 `actual-version.txt`，否则 `build` 失败（框架据此校验 `requested_version == actual_version`；Node 版本单独记录在构建 provenance 中）。
7. **生成确定性工程矩阵**：由 `scripts/fixtures/generate_projects.py` 生成 `small`(100 模块)、`medium`(1000)、`large`(5000)、`emit`(1000)、`incremental`(1000)、`references`(lib 200 + app 300，两个 composite 工程)，并逐棵与随用例提交的 `fixtures/projects.json` 中的 SHA-256 树摘要比对；不一致即 `build` 失败。
8. **安装上游 fixture**：`zod 3.25.76` 的 `src/v3` 全量源码（13 个 `.ts`，含 `LICENSE`、`ref.txt` 来源记录、`manifest.sha256` 逐文件校验）。
9. 写出 `fixtures-metadata.json`：场景表（工程、命令、源文件数、编译文件数区间、检查时间上下界、必须产出的产物）与全部跨架构参数。
10. 生成测量包装器 `$PERF_WORK_DIR/bin/tsc`：私有 `HOME`、`TZ=UTC`、`LC_ALL=C`、`NO_COLOR=1`、`HTTP(S)_PROXY=http://127.0.0.1:9`，保证 build 自检、正式测量与独立入口使用完全相同的环境，并让任何意外网络访问立即失败。

离线约定：将下列文件预置到 `/home/runner/software/typescript/` 时优先使用并强制校验，缺失才联网下载：`node-v22.23.4-linux-x64.tar.xz`、`node-v22.23.4-linux-arm64.tar.xz`、`typescript-7.0.2.tgz`、`typescript-linux-x64-7.0.2.tgz`、`typescript-linux-arm64-7.0.2.tgz`。

## 3. 完整测试口径

交付手册中的 TypeScript 负载是"用 `tsc` 编译一个工程"的单点冒烟。本用例把它升级为**可解释、可复现、覆盖真实决策点的工作负载矩阵**：

| 场景 | 工程 | 测量命令 | 说明 |
|---|---|---|---|
| `check_small` | small | `tsc --noEmit -p tsconfig.json --extendedDiagnostics` | 100 模块（与手册负载同规模，Files 157） |
| `check_medium` | medium | 同上 | 1000 模块 × 10 倍规模（Files 1057） |
| `check_large` | large | 同上 | 5000 模块 × 50 倍规模（Files 5057） |
| `check_upstream` | upstream | 同上 | 上游真实工程 zod 3.25.76 `src/v3`（Files 71） |
| `emit_medium` | emit | `tsc -p tsconfig.json --extendedDiagnostics` | 1000 模块全量类型检查 + JS/d.ts/sourcemap 产物（1000 `.js` + 1000 `.d.ts`） |
| `incremental_warm_medium` | incremental | `tsc --noEmit -p tsconfig.json --extendedDiagnostics` | 冷构建后**无改动**再跑：必须命中 `.tsbuildinfo`（`Check time ≤ 0.010 s`） |
| `incremental_change_medium` | incremental | 同上 | 冷构建后**改 1 个模块**再跑：必须重新检查（`Check time ≥ 0.020 s`） |
| `references_build` | references | `tsc --build --verbose` | 库 + 应用两个 composite 工程的 project references 构建 |

固定条件：

- 每场景 **1 次预热 + 5 次独立正式测量**，报告**中位数**，同时保留每次样本、最小值、最大值、均值与标准差；`PERF_REPS` 可临时调小（仅用于本机链路验证，证据中如实记录）。
- **每次测量前整树重置**：从 `$PERF_WORK_DIR/project-templates/<工程>` 复制原始树（删除 `.tsbuildinfo`、`dist/` 与上一轮的源文件改动），不做增量修补，因此样本之间没有状态污染。
- 增量场景的"冷状态"由一次**不计时**的冷构建建立，其日志作为 `runs/<场景>/setup-<rep>-cold.log` 留证；因此"warm"测的是真实增量路径，而不是另一轮全量检查。
- **正确性校验**（不以 `exit 0` 为充分条件）：每个样本必须 `exit_code == 0`、未超时、墙钟与 RSS 为正、源文件数等于 build 记录值、日志不含任何 `error TS`、`Files:` 落在预期区间；场景还必须真的产出承诺的产物——emit 必须产出 1000 `.js` 与 1000 `.d.ts`，增量场景必须存在 `.tsbuildinfo`，references 必须构建 2 个工程并产出 2 个 `.tsbuildinfo` 与 lib 的 200 个 `.js`。缺样本、缺日志、非零退出、超时、NaN/0、源文件数不符、日志含编译诊断、产物缺失，均使 `test` 阶段直接失败，**不补零、不估算、不跳项**。
- 单次测量上限 900 s；8 场景 × 6 次在本机 x86_64 上 `test` 阶段约 **20 s**，`build` 阶段约 **4 s**，远低于 180 min 超时。
- 上游工程输入随用例提交（`fixtures/upstream/`，220 KB），两架构**逐字节相同**；`tsconfig.json` 用 `types: []`、`lib: ["ES2022","DOM"]`，不配置 `paths`/`rootDirs`，因此两台机器上被编译的程序完全一致，不会读取 Runner 上任何 `@types`。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好 | `scripts/run_timed.py` 测得的单次 tsc 子进程墙钟，取 5 次中位数 |
| `<场景>_rss` | `MiB` | 越低越好 | 同一子进程的 `ru_maxrss` 峰值，取 5 次中位数 |

共 8 个场景 × 2 项 = **16 个指标**，全部由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合；原始日志与逐次 JSON 留在结果目录的 `runs/` 作为一手证据。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。两架构使用同一套脚本、同一份确定性工程、同一个上游 fixture、同一个 Node.js/TypeScript 版本，仅原生后端包按架构选择。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 生成工程 → 8 场景测量 → 解析 → 报告），产出**不是**性能结论。
- 跨架构对齐：`normalized_result.parameters` 只包含两架构必然一致的量（TypeScript/Node 版本、`engines.node`、registry、TypeScript tarball SHA-256 与 integrity、6 个工程的模块数与树摘要、上游 fixture 的 manifest 摘要、场景的工程与命令）。**原生后端包名、二进制、工作目录绝对路径一律不进入参数**：包名与 SHA 记录在每个指标的 `native_backend` 字段与 `build_provenance.json` 中，因此 `parameter_signature` 在 aarch64 与 x86_64 上相同，可直接配对比较。
- 场景命令在参数中记为相对形式（如 `tsc --noEmit -p tsconfig.json --extendedDiagnostics`），不记录 `$PERF_WORK_DIR` 下的绝对路径——该路径含架构与 run_id，若写进参数会破坏跨架构签名。

本机 x86_64 链路验证（`PERF_REPS=5`，单次框架六阶段完整跑通，run id `local-fw-20261031215011`）实测中位数：`check_small` 0.064 s / 47.3 MiB、`check_medium` 0.217 s / 149.0 MiB、`check_large` 0.919 s / 640.7 MiB、`check_upstream` 0.215 s / 94.3 MiB、`emit_medium` 0.320 s / 255.4 MiB、`incremental_warm_medium` 0.215 s / 106.8 MiB、`incremental_change_medium` 0.269 s / 153.4 MiB、`references_build` 0.114 s / 65.7 MiB。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: typescript
version: 7.0.2
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/离线验证，自动清理私有工作目录，并写 7 个字段的 `build_info.json`）：

```bash
PERF_REPS=5 bash software/Toolchain/typescript/typescript_test.sh \
  --version 7.0.2 --variant base --results-dir /tmp/typescript-results
```

可覆盖的环境变量：`SOFTWARE_VERSION`、`EXPECTED_ARCH`、`PERF_VARIANT`、`RESULTS_DIR`、`PERF_WORK_DIR`、`PERF_REPS`、`PERF_TS_REGISTRY`、`TS_OFFLINE_DIR`。

## 7. 与旧交付"冒烟负载"的关系

- 旧交付只验证"`tsc` 能编译一个样例工程"，其绝对值不进入性能结论；本用例保留同等规模的 `check_small`（100 模块）作为对照点，并补齐 medium/large 两档规模，使规模敏感性可解释。
- 增量场景把 TypeScript 最有价值的优化路径（`.tsbuildinfo` 命中）变成可测指标：warm 场景要求 `Check time` 接近 0 才承认命中了增量状态，change 场景要求重新检查确实发生，避免"看起来很快"的空跑。
- `emit_medium` 与 `references_build` 覆盖真实 CI 的另两类工作（产物生成、composite 构建），而不是只测 `--noEmit`。
- 测量命令统一带 `--extendedDiagnostics`：它只增加统计输出、不改变编译工作量，用于证明"真的检查了/真的增量命中了/真的 emit 了"。

## 8. 故障排查

| 现象 | 原因与处理 |
|---|---|
| `build` 报资产 SHA-256/SHA-512 不一致 | 预置文件与固定版本不符（或被镜像替换）；删除 `/home/runner/software/typescript/` 中对应文件让其重新下载，或核对版本号 |
| `build` 报 `requested TypeScript ... but the compiler reports ...` | 固定版本与 tarball 不匹配；检查 `SOFTWARE_VERSION` 与 `TS_*` 常量 |
| `build` 报 `could not extract` / `native compiler binary is missing` | 原生后端包与架构不匹配；确认 `EXPECTED_ARCH` 与 `@typescript/typescript-linux-<arch>` 一致 |
| `test` 报 `Files:` 数量不在区间 | 工程被意外修改或工作目录被复用；删除 `$PERF_WORK_DIR` 后重跑（框架每次用独立 run 目录，正常不会发生） |
| `test` 报增量场景 `Check time` 检查时间异常 | `.tsbuildinfo` 未建立或未命中；查看 `runs/<场景>/setup-*.log`（冷构建）与 `rep*.log` 中的 `BuildInfo read time` |
| `test` 报 `dist/**/*.js` 数量不足 | TS 7 要求显式 `rootDir`；确认 `generate_projects.py` 生成的 `emit/tsconfig.json` 含 `rootDir: "./src"` |
| `stop` 报仍有 tsc 进程 | 上次中断的测量进程残留；`stop` 会按 `TSC_JS` 精确匹配并终止，不会误杀其他进程 |

## 9. 许可证

- 本用例脚本与生成的工程矩阵：随仓库许可证。
- `fixtures/upstream/` 为 zod 3.25.76 的 `src/v3` 源码子集，MIT 许可证，原文见 `fixtures/upstream/LICENSE`；来源与 tarball SHA-256 记录在 `fixtures/upstream/ref.txt`。
