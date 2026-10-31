# npm

npm 12.2.1 包管理操作性能用例。完整口径为**多场景安装矩阵（冷/热、全量/增量、三档依赖规模 + 上游工程）**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **12.2.1** |
| 发布包 | `npm-12.2.1.tgz`（官方发布包）<br>`https://registry.npmjs.org/npm/-/npm-12.2.1.tgz`<br>镜像：`https://registry.npmmirror.com/npm/-/npm-12.2.1.tgz`<br>SHA-256 `228bd64aaef23270dbdbd2cf3d5ef5c467602ef38c4066246cef1984adab9a67`<br>SHA-512（registry 发布 integrity，base64）`bKCmFRVT/BB+YPEYbZwQ1XUI3N5t4xKSpU1MxOjo7z3iWzKBJ0ZXRC1xFdEN+TC7N5TdywaBzf2dMXGJq/e2PQ==` |
| npm 声明运行时 | `engines.node = ^22.22.2 \|\| ^24.15.0 \|\| >=26.0.0` |
| 运行时长（固定） | Node.js **v22.23.4**（`test_tools.nodejs`），不用 Runner 预装 Node/npm |
| Node x86_64 | `node-v22.23.4-linux-x64.tar.xz`<br>`https://nodejs.org/dist/v22.23.4/node-v22.23.4-linux-x64.tar.xz`<br>SHA-256 `1805bcd35e6815559bd2eb97db438d3fdb0eb3a5e6a977b7c1badca76337e9ce` |
| Node aarch64 | `node-v22.23.4-linux-arm64.tar.xz`<br>`https://nodejs.org/dist/v22.23.4/node-v22.23.4-linux-arm64.tar.xz`<br>SHA-256 `6287aa46b6c375d816e63ae66d024fbbfd70404825aabdfdf898a970871d2f4b` |
| 国内镜像 | Node：`https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v22.23.4/<归档>`<br>npm：`https://registry.npmmirror.com/npm/-/npm-12.2.1.tgz` |

npm 从官方 tarball 解包后用**固定版本 Node 直接执行** `bin/npm-cli.js`，不安装、不修改 Runner 的系统 npm。所有下载都核对官方校验值：Node 校验 SHA-256，npm 同时校验 SHA-256 与 registry 发布的 SHA-512 integrity；校验失败即 `build` 失败（返回 30），不降级、不跳过。

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验/安装系统依赖（`curl`、`tar`、`xz`、`gzip`、`sha256sum`、`gawk`、`python3`），Runner 通过 `sudo -n dnf` 补齐，代理来自 `PERF_PROXY`。
2. 解包固定版本 Node.js 到 `$PERF_WORK_DIR/node-install`，解包 npm 到 `$PERF_WORK_DIR/npm-install`，解析出的 `npm --version` 必须等于 `12.2.1`，并校验 `22.23.4` 满足 npm 的 `engines.node`，否则 `build` 失败（框架据 `actual-version.txt` 校验；Node 版本单独记录在 `build_info.json` 参数中）。
3. 生成 npm 启动包装器 `$PERF_WORK_DIR/bin/npm`：私有 `HOME`、私有缓存 `--cache $PERF_WORK_DIR/npm-cache`、固定 registry、`CI=1`，保证 build 预热、正式测量与独立入口使用完全相同的配置。
4. 校验随用例提交的 fixture：`fixtures/checksums.sha256` 逐个 `sha256sum -c`，再由 `scripts/verify_fixtures.py` 证明输入是确定性的（直接依赖精确钉版本、lockfile 完整 resolved/integrity、无网络回退空间）。
5. **联网预热**（不计入测量）：用三档 fixture 的 `npm ci` 与"无 lockfile 的 `npm install`"填满私有缓存，再预热增量场景的额外依赖。
6. **离线自检**：用同一缓存执行 `npm ci --offline` 与 `npm install --offline`，并复核安装后的包数与预热时一致；任一失败即 `build` 失败。
7. 退出前写出 fixture 元数据与 `build_variant.json`。

离线包约定：将下列文件预置到 `/home/runner/software/npm/` 时优先使用并强制校验，缺失才联网下载：`node-v22.23.4-linux-x64.tar.xz`、`node-v22.23.4-linux-arm64.tar.xz`、`npm-12.2.1.tgz`；另可预置**已预热缓存** `npm-cache.tar.gz`（需同目录 `.sha256` 校验文件）或 `npm-cache/` 目录，构建阶段将直接复用它并跳过联网预热。

## 3. 完整测试口径

交付手册中的 npm 负载是"固定 lockfile 的 `npm ci` 冒烟"，只验证"装得上、跑得起来"，其绝对值不进入性能结论。本用例把它升级为**可解释、可复现、覆盖真实决策点的操作矩阵**：

| 场景 | fixture | 任务 | 说明 |
|---|---|---|---|
| `ci_clean_small` | small | `npm ci` | ~50 包单服务依赖（express 4.21.2，lockfile 69 项） |
| `ci_clean_medium` | medium | `npm ci` | ~500 包 Web 工具链（webpack/babel/jest/ts/eslint/prettier，lockfile 569 项） |
| `ci_clean_large` | large | `npm ci` | ~2000 包 SSR 应用（gatsby/react + 完整工具链，lockfile 1630 项） |
| `ci_upstream` | upstream | `npm ci` | 上游真实工程 mocha v11.7.5 全量依赖（lockfile 1455 项，含其自带的 link 目录） |
| `install_resolve_small` | small | `npm install`（无 lockfile） | 解析器路径：整棵树从缓存 packument 重新求解 |
| `install_noop_medium` | medium | `npm install`（node_modules 已就绪） | 热状态空操作，反映 lockfile 一致时的最短路径 |
| `install_add_dep_medium` | medium | `npm install is-odd@3.0.1` | 已装树 + 新增 1 个依赖的增量安装 |
| `query_prod_medium` | medium | `npm query --offline ".prod"` | 只读遍历整棵已安装依赖树，输出 JSON（安装正确性诊断路径） |

固定条件：

- 统一 `npm_config_cache=<私有缓存>`、`npm_config_registry=<固定 registry>`、`CI=1`、`HOME=<私有 HOME>`，不使用 `~/.npm`、不读用户 `~/.npmrc`；
- 测量命令一律 `--offline --no-audit --no-fund --ignore-scripts`，**测量阶段禁止任何网络访问**：缓存未命中会直接失败，不会静默回退到联网（`npm ci` 与离线解析都经过 shuffle=0 的顺序校验）；
- **"冷/热"的边界**：本用例的"冷"指 `node_modules` 被删除（`npm ci` 每次都重装整棵树），"热"指 `node_modules` 已就绪的空操作。**网络冷缓存**（本机缓存为空、必须联网）不作为正式指标，只允许出现在 build 预热里；这与手册把"网络冷缓存"单列的做法一致，但正式矩阵不引入网络抖动；
- 预热统一使用 `https://mirrors.huaweicloud.com/repository/npm`（可用 `PERF_NPM_REGISTRY` 覆盖）。该镜像在 registry 路径上**直接返回 tarball**，与 lockfile 中 `resolved` 的 URL 完全一致，因此离线安装能命中预热缓存；需要重定向到其它域名取包的镜像会让离线缓存无法命中（见第 8 节）；
- 每场景 **1 次预热 + 5 次独立正式测量**，报告**中位数**，同时保留每次样本、最小值、最大值、均值与标准差；`PERF_REPS` 可临时降低（仅用于本机链路验证，证据中如实记录）；
- 每次测量前用提交的 fixture **整树重置**（不做增量补丁），并用 npm 自己写出的 `node_modules/.package-lock.json` 复核安装包数必须等于 build 记录的包数——安装"少装/错装"会让该场景直接失败，而不是给出一个"看起来很快"的数；
- 增量场景每次只新增同一个依赖（`is-odd@3.0.1`），no-op 场景不做任何修改，二者反映真实行为，不人为制造无效工作；只读遍历用 `npm query --offline ".prod"`：真实工程的依赖树普遍存在 peer 版本不匹配，`npm ls --all` 遇到这种情况会以 `ELSPROBLEMS` 非零退出，而解析器不允许掩盖非零退出码，因此不把 `npm ls --all` 作为测量命令；
- 所有 fixture 的 `package.json`/`package-lock.json` 随用例提交并由校验清单固定，两架构输入**逐字节相同**（`resolved` 的 registry origin 会按当次 registry 归一化，包路径、版本与 integrity 不变）。

上游工程边界：`ci_upstream` 使用 `mochajs/mocha` **v11.7.5** 的真实 `package.json`/`package-lock.json`（`fixtures/upstream/ref.txt` 记录来源），lockfile 里有一条指向仓库自身 `test/compiler-fixtures/esm-only-loader` 的 link 依赖，该目录随 fixture 一并提交，因此 `npm ci` 可以完全离线完成，不依赖仓库外部路径。

本机 x86_64 链路验证（`PERF_REPS=5`、热缓存，框架六阶段一次完整跑通）实测中位数：单次 `npm ci` small 0.314 s、medium 2.671 s、large 12.437 s、upstream 6.777 s；`install_resolve_small` 0.465 s、`install_noop_medium` 0.465 s、`install_add_dep_medium` 0.464 s、`query_prod_medium` 0.415 s。单架构 8 场景 × 6 次（预热 + 5 次正式）`test` 阶段约 2.7 min，加 build 预热（约 75 s）合计约 4 min，远低于 180 min 超时。

## 4. 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<场景>` | `s` | 越低越好 | `scripts/run_timed.py` 测得的单次 npm 子进程墙钟，取 5 次中位数 |
| `<场景>_rss` | `MiB` | 越低越好 | 同一子进程的 `ru_maxrss` 峰值，取 5 次中位数 |

共 8 个场景 × 2 项 = **16 个指标**，全部由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json` 与 `rep<i>.log` 聚合。任一场景缺样本、缺日志、`exit_code != 0`、超时、数值非有限、墙钟/RSS 非正、安装包数与 build 记录不一致，`test` 阶段直接返回非零：**不补零、不估算、不跳项**。

## 5. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。两架构使用同一套脚本、同一份 fixture、同一个 Node/npm 版本，仅 Node 归档按架构选择。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 预热 → 8 场景测量 → 解析 → 报告），产出**不是**性能结论。
- 跨架构对齐：`normalized_result.parameters` 只包含两架构必然一致的量（npm/Node 版本、engines、registry、缓存布局、场景命令、fixture 的 lockfile 版本与哈希），因此 `parameter_signature` 在 aarch64 与 x86_64 上相同，可直接配对比较。**实际安装包数**不进入参数（平台相关的可选原生依赖会让 x64/arm64 略有差异，本机实测 small/medium/large/upstream 分别为 69/531/1566/1427），它作为每个指标的附属证据单独记录。
- 场景命令在参数中记为相对形式（如 `npm ci --offline --no-audit --no-fund --ignore-scripts`），不记录 `$PERF_WORK_DIR` 下的 wrapper 绝对路径——该路径含架构与 run_id，若写进参数会让两架构签名不必要地不同；wrapper 的真实绝对路径仍逐次记录在 `runs/<场景>/rep<i>.log` 的 `# command:` 行中，作为一手证据。

## 6. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: npm
version: 12.2.1
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机调试）：

```bash
export PERF_WORK_DIR=$HOME/npm-work        # 可选；默认 /home/runner/boostkit-perf
export PERF_REPS=5                         # 默认 5；本机链路验证可临时降低并记录
bash software/Toolchain/npm/npm_test.sh \
  --version 12.2.1 --variant base --results-dir "$HOME/npm-results"
```

`optimized` 变体尚未实现：`npm_test.sh --variant optimized` 与框架的 optimized 构建会**立即明确失败（返回码 30）**，打印原因并**不写出** `build_variant.json`，不会回退到 base。

可选环境变量（默认全部不设置，行为与 CI 完全一致）：

| 变量 | 作用 |
|---|---|
| `PERF_NPM_REGISTRY` | 覆盖预热用 registry（默认华为云 npm 镜像）；必须选择在 registry 路径上直接返回 tarball 的镜像 |
| `PERF_NPM_OFFLINE_DIR` → `NPM_OFFLINE_DIR` | 覆盖离线包目录，默认 `/home/runner/software/npm` |
| `PERF_REPS` | 独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |
| `PERF_PROXY` | Runner 需要代理时传给 `curl` / `dnf` |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`runs/`（每次原始日志与计时 JSON）。

## 7. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 npm 负载是"固定 lockfile 的 `npm ci`"，属于**链路冒烟**：只验证"装得上、指标读得出"，其实测值不迁移进仓库、不作为性能结论。本用例把它保留为矩阵中的一个子集（`ci_clean_small`/`ci_clean_medium`/`ci_clean_large` 中的安装路径），真正的性能证据是覆盖冷/热、全量/增量、三档规模与上游真实工程，且每场景 5 次中位数的完整口径。

## 8. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报哈希不匹配 | 检查 `/home/runner/software/npm/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `npm --version` 不等于 12.2.1 | 预置包版本错误，或 `$PERF_WORK_DIR/npm-install` 残留旧解包；清理后重跑 |
| `Node.js ... does not satisfy npm engines.node` | 固定的 Node 版本被改动；12.2.1 要求 `^22.22.2 \|\| ^24.15.0 \|\| >=26.0.0` |
| 离线安装报 `Refusing to fetch ...` 或 `ENOTCACHED` | 预热缓存未命中：确认 `PERF_NPM_REGISTRY` 未指向**会重定向 tarball 的镜像**（如 `registry.npmmirror.com` 会 302 到 `cdn.npmmirror.com`，缓存键与 lockfile URL 不一致），或改用预置缓存 |
| `ci_upstream` 报 link 目录缺失 | 上游 fixture 的 `test/compiler-fixtures/esm-only-loader` 必须随 fixture 提交（校验清单已覆盖） |
| 解析报缺样本/日志 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json` 和 `rep*.log`；中途失败的 rep 会保留日志 |
| 解析报安装包数与 build 记录不一致 | 缓存不完整或 lockfile 被改动；删除私有缓存重跑 build |
| `ci_clean_large` 明显变慢 | 属预期：该场景每次重装 1566 个包；本机热缓存实测约 13.5 s/次 |

## 9. 许可证

npm 采用 Artistic License 2.0；Node.js 采用 MIT。随用例提交的 fixture 由其 package.json 声明的各依赖各自的许可证覆盖；本项目自带的校验、计时与解析脚本为本仓库原创，遵循仓库既有许可。
