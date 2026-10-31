# react

React 19.3.1 服务端渲染性能用例。完整口径为**确定性 SSR 矩阵（3 种服务端 API × 3 种列表规模）+ 上游 facebook/react 源码服务端生产构建负载**，正式性能证据取自 GitHub Actions `Blue: Manual performance evaluation` 的 **aarch64** 运行。

## 1. 版本与来源

| 项 | 值 |
|---|---|
| 软件版本 | **19.3.1** |
| 版本来源 | npm registry `react` 包最新版（`https://registry.npmjs.org/react/latest` 指向 19.3.1） |
| react 制品 | `react-19.3.1.tgz`<br>`https://registry.npmmirror.com/react/-/react-19.3.1.tgz`<br>SHA-256 `56936913918dcf1f7a6fe58784e79df54b18200a88655ce809cf5e9c4ef871aa` |
| react-dom 制品 | `react-dom-19.3.1.tgz`<br>`https://registry.npmmirror.com/react-dom/-/react-dom-19.3.1.tgz`<br>SHA-256 `8b49975821eec6311e00d2b3f4b8337923253c876517388a33f9839c61ab262e` |
| scheduler 制品 | `scheduler-0.28.0.tgz`（react-dom 19.3.1 的运行时依赖）<br>`https://registry.npmmirror.com/scheduler/-/scheduler-0.28.0.tgz`<br>SHA-256 `302995d590e3c0a11eeb40d1d0f299c1df1800135d599d85cdd5faeb614f32d6` |
| Node.js 运行时 | **v20.19.0**（Iron LTS，内置 npm 10.8.2）<br>上游 React 仓库 `.nvmrc` 固定 `v20.19.0`，本用例跟随该固定值<br>x86_64：`node-v20.19.0-linux-x64.tar.xz` SHA-256 `b4e336584d62abefad31baecff7af167268be9bb7dd11f1297112e6eed3ca0d5`<br>aarch64：`node-v20.19.0-linux-arm64.tar.xz` SHA-256 `dbe339e55eb393955a213e6b872066880bb9feceaa494f4d44c7aac205ec2ab9`<br>镜像：`https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v20.19.0/`（官方 `SHASUMS256.txt` 校验值） |
| Yarn | **1.22.22**（上游 React 仓库 `packageManager` 固定值）<br>`yarn-1.22.22.tgz` SHA-256 `c17d3797fb9a9115bf375e31bfd30058cac6bc9c3b8807a3d8cb2094794b51ca` |
| 源码制品（上游工程负载） | `react-19.3.1-source.tar.gz`，GitHub tag 归档<br>`https://codeload.github.com/facebook/react/tar.gz/refs/tags/v19.3.1`<br>SHA-256 `350d7bd46030667a3421422f7bae6e30dd1e0955c21e777bf467961fa56de650` |
| 构建期 JRE | Runner 系统 `java-17-openjdk-headless`（仅 build 阶段依赖；上游 rollup 构建的 google-closure-compiler 步骤是 Java 程序）。未固定小版本，逐次运行把 `java -version` 写入 `build_info.json` 与 `results.json` |
| 包镜像 | `https://registry.npmmirror.com`（可用 `PERF_REACT_REGISTRY` 覆盖） |
| Node 镜像 | `https://mirrors.tuna.tsinghua.edu.cn/nodejs-release`（可用 `PERF_REACT_NODE_MIRROR` 覆盖；未命中时回退 `https://nodejs.org/dist`） |

所有归档在解包或安装前强制核对 SHA-256：不匹配、下载失败、解包失败一律 `build` 失败（返回非零），不降级、不跳过。React 19.3.1 的 npm 元数据声明 `engines.node >= 0.10`，但为保证可复现，本用例只承认上游仓库 `.nvmrc` 固定的 Node v20.19.0。

离线包约定：把下列文件预置到 `/home/runner/software/react/` 时优先使用并强制校验，缺失才联网下载（`PERF_REACT_OFFLINE_DIR` 可覆盖目录）：

```text
node-v20.19.0-linux-x64.tar.xz
node-v20.19.0-linux-arm64.tar.xz
yarn-1.22.22.tgz
react-19.3.1.tgz
react-dom-19.3.1.tgz
scheduler-0.28.0.tgz
react-19.3.1-source.tar.gz
```

## 2. 安装与构建

`build` 阶段（`scripts/builders/dispatch.sh` → `base.sh`）完成：

1. 校验系统依赖（`curl`、`tar`、`xz`、`sha256sum`、`python3`、`java`）；Runner 通过 `sudo -n dnf` 补齐缺失包，代理来自 `PERF_PROXY`。
2. 按 `uname -m` 选择本架构 Node 归档，核对 SHA-256 后解包到 `$PERF_WORK_DIR/node`；`node --version` 必须是 `v20.19.0`。
3. 安装固定 Yarn 1.22.22 到 `$PERF_WORK_DIR/yarn`；`yarn --version` 必须是 `1.22.22`。
4. 在 `$PERF_WORK_DIR/app` 用 **离线 npm install** 安装三个固定 tarball（react / react-dom / scheduler），并逐项复核实际版本为 19.3.1 / 19.3.1 / 0.28.0。
5. 解包上游 React 19.3.1 源码到 `$PERF_WORK_DIR/react-source`，复核 `packages/react/package.json` 的版本为 19.3.1；把上游 `yarn.lock` 中的 `registry.yarnpkg.com` 前缀改写到配置的镜像主机（锁文件内的完整性与包版本不变）。
6. 用固定 Yarn 安装上游源码依赖：`--frozen-lockfile --ignore-engines --ignore-scripts`。上游 devDependencies 含 electron / optipng-bin / gifsicle / jpegtran-bin 等只在文档与截图工具链使用的、需要从无关主机下载二进制的 postinstall 脚本；跳过这些脚本使安装过程不依赖无关下载源，同时不影响被测的 rollup 构建。
7. 冒烟校验（不计入测量）：离线运行时渲染 100 项 `renderToString`；用上游源码执行一次服务端生产 bundle 构建，确认 rollup + JSC 闭包编译链在进入测量阶段前可用。
8. 退出前写出 `build_variant.json`。

**测量阶段不需要网络**：矩阵只读 `$PERF_WORK_DIR/app` 中已安装的包；上游构建只读 `$PERF_WORK_DIR/react-source` 中已安装的 `node_modules`，`build/` 每次清空后重建，不下载任何依赖。

## 3. 完整测试口径

### 3.1 为什么不用"上游基准套件"

React 仓库没有面向 SSR 吞吐的上游性能基准套件：其 `scripts/` 中的构建/测试脚本产出的是正确性结果与构建产物，不产出可复现的 render/s 指标；社区常见的基准（如 js-framework-benchmark）测的是浏览器端交互，且不在 React 仓库内。手册建议的方法是 **React production SSR renderToString + 1000 项列表**，并明确"负载为附带 MIT 许可的自定义代码，不称为上游完整套件"。

因此本用例采用**确定性矩阵 + 上游源码构建负载**：

- 确定性矩阵：同一份 React 元素树、同一进程模型、固定渲染次数，覆盖 3 种服务端 API（`renderToString`、`renderToStaticMarkup`、`renderToPipeableStream`）与 3 种列表规模（100 / 1,000 / 10,000 项），可直接字节级复现并解释。
- 上游构建负载：从固定 tag 的 facebook/react 源码树出发，用上游自己的 rollup 脚本构建**矩阵运行时对应的服务端生产 bundle 集**（stable 通道，SSR + Flight 入口的 `NODE_PROD` / `ESM_PROD` / `NODE_ES2015` 产物），覆盖"构建性能"维度。

### 3.2 矩阵

每个场景 **1 次预热 + 5 次独立正式测量**，报中位数，同时保留每次样本、最小值、最大值、均值、标准差。每个场景是独立的 Node.js 进程。

| 场景 | 服务端 API | 列表项数 | 每轮渲染次数 | 说明 |
|---|---|---|---:|---|
| `render_to_string_100` | `renderToString` | 100 | 2000 | 小型树的同步 SSR |
| `static_markup_100` | `renderToStaticMarkup` | 100 | 2000 | 无 hydration 标记的同步 SSR |
| `stream_100` | `renderToPipeableStream` | 100 | 2000 | 流式 SSR，`onAllReady` 后 drain 到字符串 |
| `render_to_string_1000` | `renderToString` | 1,000 | 1000 | 手册建议负载的规模 |
| `static_markup_1000` | `renderToStaticMarkup` | 1,000 | 1000 | 同上 |
| `stream_1000` | `renderToPipeableStream` | 1,000 | 1000 | 同上 |
| `render_to_string_10000` | `renderToString` | 10,000 | 200 | 大型树同步 SSR |
| `static_markup_10000` | `renderToStaticMarkup` | 10,000 | 200 | 同上 |
| `stream_10000` | `renderToPipeableStream` | 10,000 | 200 | 同上 |
| `upstream_build` | 上游 rollup 构建 | - | - | 每次清空 `build/` 后完整构建服务端生产 bundle 集 |

共 10 个场景；矩阵 9 场景 × 3 项指标 + 上游构建 2 项指标 = **29 个指标**。

元素树结构固定：`ul.list[data-size=N]` 下 N 个 `li`，`li` 的 `className` 按奇偶为 `even`/`odd`、`data-index=i`、文本为 `item i`。渲染结果在校验列表项数量与首次渲染的 SHA-256 后才会被接受。

### 3.3 固定条件

- **Node.js v20.19.0 固定**（跟随上游 `.nvmrc`），npm 与 Node 同包分发，Yarn 1.22.22 固定（跟随上游 `packageManager`）；实测版本逐次写入 `build_info.json` / `results.json`。
- `NODE_ENV=production` 强制开启（缺失或不同即测量失败），确保 `react-dom/server` 走生产构建。
- 渲染次数固定（见 3.2 表），不按机器性能自适应；渲染在单个 Node.js 主线程内顺序执行，不使用 cluster/worker/多线程，避免把并行度混入指标。
- 每场景独立进程：进程启动、模块加载与 JIT 预热不计入批量墙钟（批量计时用 `process.hrtime.bigint()` 在进程内完成），但完整计入外部墙钟与峰值 RSS，两者都保留。
- 预热 10 次渲染后再开始计时，降低首次渲染的惰性初始化影响。
- 上游构建固定命令与类型：`node scripts/rollup/build.js <12 个服务端入口> --type=NODE_PROD,ESM_PROD,NODE_ES2015 --release-channel=stable`；每次测量前删除 `build/`，构建进程内不做增量复用（上游该脚本本身就是全量构建）。
- 测量阶段不联网、不注入编译器缓存、不设置 `NODE_OPTIONS`/`UV_THREADPOOL_SIZE` 等改变运行时的变量。
- 指标统计为 5 次独立测量的**中位数**；原始样本与完整 stdout+stderr 全部保留。

### 3.4 单架构耗时

本机 x86_64（WSL2，20 逻辑核，`PERF_REPS=5`，离线包已预置）六阶段实测：`build` 约 **2 分 12 秒**（其中上游源码依赖安装约 73 秒，上游构建冒烟约 56 秒），`test` 约 **6 分 24 秒**（矩阵 54 次独立进程 + 上游构建 6 次，上游构建单次中位数约 57 秒），六阶段合计约 **8 分 40 秒**。aarch64 专用 Runner 预计 **12–18 分钟**，远低于 `job_timeout_minutes=390` 与 `timeout_minutes=360`。

### 3.5 指标

| 指标 | 单位 | 方向 | 来源 |
|---|---|---|---|
| `<task>_<scale>` | `s` | 越低越好 | 进程内测得的固定渲染批次墙钟，取 5 次中位数 |
| `<task>_<scale>_rps` | `render/s` | 越高越好 | 批次渲染次数 / 批次墙钟，取 5 次中位数 |
| `<task>_<scale>_rss` | `MiB` | 越低越好 | 该次测量的 Node.js 子进程树 `ru_maxrss`，取 5 次中位数 |
| `upstream_build` | `s` | 越低越好 | 上游服务端生产 bundle 构建的外层墙钟，取 5 次中位数 |
| `upstream_build_rss` | `MiB` | 越低越好 | 该次构建进程树的 `ru_maxrss`，取 5 次中位数 |

全部 29 个指标由 `scripts/results/parse_benchmark.py` 从 `runs/<场景>/rep<i>.json`、`rep<i>.bench.json` 与 `rep<i>.log` 聚合；任一场景缺样本、`exit_code != 0`、超时、批量值非有限或非正、吞吐非正、缺少原始日志、`task`/`api`/`items`/`renders`/`warmup` 与固定口径不一致、渲染列表项数量不符、同一场景各次渲染的 markup SHA-256 不一致、`batch_seconds > wall_seconds`，均判定解析失败，`test` 阶段返回非零，**不补零、不估算**。

## 4. 架构与证据边界

- **正式性能证据**：GitHub Actions `Blue: Manual performance evaluation`，`architecture=aarch64`。
- **x86_64 本机 WSL**：只用于功能与链路验证（构建 → 运行 → 解析 → 报告），产出**不是**性能结论。
- 脚本保持架构无关：只用 `uname -m` 选择 Node 官方归档，不使用任何架构专用参数；两个架构使用同一份矩阵、同一套渲染次数与同一个上游构建命令。
- 负载边界：只覆盖服务器字符串渲染（`renderToString` / `renderToStaticMarkup` / `renderToPipeableStream`），**不覆盖**浏览器 hydration、交互、布局与网络层；Node.js 版本、JIT 与 GC 行为对结果影响很大，因此版本必须固定。
- 上游构建负载固定为服务端生产 bundle 集，不包含浏览器 UMD 包、devtool/TypeScript 包与 npm 发布打包步骤；这些产物与矩阵运行时无关，且其构建需要额外的文档工具链与全局 link 状态。该取舍在报告中同样标注。
- 跨架构对比只按同名场景配对；不把不同负载、不同语言/工具的耗时直接排序。

## 5. 运行方式

Actions（正式，aarch64）：

```text
Workflow: Blue: Manual performance evaluation
software: react
version: 19.3.1
architecture: aarch64
variant: base
update_baseline: false
```

独立入口（本机/调试）：

```bash
export PERF_REACT_OFFLINE_DIR=/home/runner/software/react   # 可选；默认即此路径
export PERF_REPS=5                                          # 默认 5；本机链路验证可临时降低并记录
bash software/Toolchain/react/react_test.sh \
  --version 19.3.1 --variant base --results-dir "$HOME/react-results"
```

`optimized` 变体尚未实现：`react_test.sh --variant optimized` 与框架的 optimized 构建立即明确失败（返回码 30），**不会**回退到 base，也不写 `build_variant.json`。

可选环境变量：

| 变量 | 作用 |
|---|---|
| `PERF_REPS` | 每个场景的独立测量次数，默认 5；本机链路验证可临时降低并在证据中记录 |
| `PERF_REACT_OFFLINE_DIR` | 覆盖离线包目录，默认 `/home/runner/software/react` |
| `PERF_REACT_REGISTRY` | 覆盖 npm registry 前缀，默认 `https://registry.npmmirror.com` |
| `PERF_REACT_NODE_MIRROR` | 覆盖 Node 归档镜像前缀，默认清华镜像 |

独立入口产出：`results.json`、`status.json`、`normalized_result.json`、`report.md`、`actual-version.txt`、`build_info.json`、`system_info.json`、`runtime_before.json`、`runtime_after.json`、`results.log`、`runs/`（每场景预热 + 5 次测量的完整原始日志、外层计时 JSON 与渲染明细 JSON）。框架六阶段运行时另有 `raw-output.log`（`test` 阶段完整控制台输出）与 `.perf-output/` 规范结果。

## 6. 与旧交付"冒烟负载"的关系

本地 43 款交付（2026-10-30）中的 React 负载是"固定 1,000 个 li 的 React 树，`NODE_ENV=production`，预热 10 次 + 计时 100 次 `renderToString`，3 次样本，`taskset -c 2`"，111 实测中位数 2380.063 render/s、0.04201569 s/100 次渲染，属于**链路冒烟**，只用于验证"装得起来、跑得起来、指标读得出来"，其数值不迁移进仓库、不作为性能结论。

本用例保留 1,000 项 `renderToString` 场景作为矩阵子集（`render_to_string_1000`），但口径更严格：每轮渲染次数提高到 1000（该规模下单次渲染约 0.1–0.5 ms，100 次渲染不足 0.05 s，计时噪声过大）、5 次独立样本取中位数、进程模型与树结构完全固定、markup 一致性校验；同时新增 `renderToStaticMarkup` / `renderToPipeableStream`、100 / 10,000 规模与上游构建负载。因渲染次数与树结构不同，本用例数值与旧交付数值不可直接对比。

## 7. 故障排查

| 现象 | 排查 |
|---|---|
| `build` 报 SHA-256 不匹配 | 检查 `/home/runner/software/react/` 预置包是否与本文档校验值一致；删除损坏缓存重试 |
| `build` 报 Node 版本不是 `v20.19.0` | 预置归档版本错误，或 `$PERF_WORK_DIR/node` 残留旧解包；清理该目录重试 |
| `build` 报 `yarn install` 失败 | 检查镜像可达性与 `PERF_REACT_REGISTRY`；锁文件已改写为本镜像主机，校验和仍按上游锁文件执行 |
| `build` 报找不到 `java` | 上游 rollup 构建的 closure 步骤需要 JRE；Runner 上安装 `java-17-openjdk-headless` 或预置 java |
| `build` 报上游构建冒烟失败 | 查看 `$PERF_WORK_DIR/upstream-build-smoke.log`；常见原因是磁盘不足（约需 4 GB）或 Node 版本不符 |
| `test` 报缺样本 | 查看 `runs/<场景>/` 下是否 5 个 `rep*.json`/`rep*.bench.json`/`rep*.log`；失败的那次测量会保留原始日志 |
| `test` 报 markup 不一致 | 渲染结果必须逐字节稳定；检查是否引入了随机数、时间戳或未固定版本的依赖 |
| `test` 报批量时间大于外层墙钟 | 计时口径异常，检查是否被其他高负载进程抢占或修改了 harness |
| 测量阶段出现网络访问 | 不应发生；矩阵与上游构建都只读已安装依赖，检查是否人为设置了 registry 或代理变量 |

## 9. 验证记录（x86_64 WSL2，仅链路验证，非性能结论）

| 编号 | 验证内容 | 方式 | 结果 |
|---|---|---|---|
| A | 独立入口端到端 | `react_test.sh --variant base`，`PERF_REPS=5` | passed；29 指标 / 10 场景；build 约 2 分 12 秒、test 约 6 分 24 秒 |
| B | 框架六阶段契约 | `framework/run_case.py` 依次 `prepare → build → start → test → stop → finalize` | 六阶段全绿，`status.json` 为 `passed`，`normalized_result.json` 29 指标，`report.md` 生成 |
| C | optimized 变体契约 | `--variant optimized` | 返回码 30，未写 `build_variant.json` 与 `results.json`，未回退 base |
| D | 测量阶段离线 | 在 `unshare -n` 的无网络命名空间内跑矩阵 1 次 + 上游构建 5 次 + 解析 | 全部成功：矩阵 4259.7 render/s（单次样本），上游构建 5/5 成功（每次 108 个产物），解析 29 指标 |
| E | 解析严格性 | 构造缺样本、JSON 截断、markup 不一致、元数据不一致四种异常 | 四种异常全部返回非零；未改动样本返回 0 |
| F | 目录可移植性 | 用例目录复制到仓库外运行（`PERF_REPS=1`） | passed；29 指标，生成文件中无仓库路径残留 |
| G | 目录与矩阵注册 | `framework/catalog.py validate`、`build_matrix` | 用例在校验清单内；react 在 x86_64 / aarch64 各一条，`timeout_minutes=360`、`job_timeout_minutes=390` |

上述记录中的耗时只说明链路可用与规模合理，数值不迁移为性能结论；正式证据只取 aarch64 专用 Runner 的 Actions 运行。

## 10. 许可证

React、react-dom、scheduler 采用 MIT License（Meta Platforms, Inc. 及贡献者）；Node.js 采用 MIT License；Yarn 采用 BSD 2-Clause License；JRE（OpenJDK）采用 GPL v2 + Classpath Exception。本用例自带的 SSR harness、计时与解析/报告脚本为本仓库原创，遵循仓库既有许可。
