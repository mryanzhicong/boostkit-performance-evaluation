# Next.js 16.4.3 性能测试

本目录是 `Toolchain / nextjs` 的性能测试用例。它把交付手册
（`全量43款性能测试交付-20261030/手册/全量/18-Next.js.md`）要求的
“固定 1000 个静态页面、production build、再对 127.0.0.1:18181 串行 GET 100 次并校验
item-999”扩展为 **9 个场景 × 2 个指标** 的完整矩阵：既覆盖交付口径，也覆盖规模敏感性、
动态渲染、文件路由、增量构建、真实上游工程与生产服务器启动/请求延时。

## 1. 场景矩阵

| 场景 | 工程 | 负载 | 指标 | 单位 | 方向 |
|---|---|---|---|---|---|
| `build_static_1000` | `static_1000` | `next build`，1000 个静态项（`generateStaticParams`） | 构建耗时 | s | 越低越好 |
| `build_static_3000` | `static_3000` | 同上，3000 个静态项（规模敏感性） | 构建耗时 | s | 越低越好 |
| `build_dynamic_500` | `dynamic_500` | `next build`，`force-dynamic` 路由（不预渲染） | 构建耗时 | s | 越低越好 |
| `build_routes_500` | `routes_500` | `next build`，500 个文件系统路由（路由表/编译规模） | 构建耗时 | s | 越低越好 |
| `build_incremental_1000` | `static_1000` | 冷构建一次后快照 `.next`，每次测量前恢复快照再 `next build` | 热构建耗时 | s | 越低越好 |
| `build_upstream` | `upstream` | 官方 `vercel/next.js` `examples/with-typescript`（pages router + TS 类型检查） | 构建耗时 | s | 越低越好 |
| `serve_startup_1000` | `static_1000` | `next start` 到首个 HTTP 200 的启动延时 | 启动延时 | s | 越低越好 |
| `serve_get_100_static` | `static_1000` | 串行 GET `/items/item-999` 100 次并逐条校验内容 | 单次请求延时中位数 | s | 越低越好 |
| `serve_get_100_dynamic` | `dynamic_500` | 串行 GET `/dyn/item-42` 100 次并逐条校验内容（SSR） | 单次请求延时中位数 | s | 越低越好 |

每个场景同时记录 **峰值 RSS**（`<场景>_rss`，MiB，越低越好），因此共 18 个指标。
所有指标的统计口径一致：**1 次预热 + 5 次独立测量取中位数**（`PERF_REPS` 可覆盖，1~50），
同时保留全部样本、最小值、最大值、均值与标准差。

> 单连接串行请求的倒数**不是**高并发 QPS。交付手册明确要求“不要调用并发 QPS”，
> 因此这里只报告串行请求延时，不报告吞吐速率，避免把延时倒数包装成吞吐结论。

## 2. 为什么是这套矩阵

* **交付口径**（1000 静态页 + production build + loopback GET ×100 + 校验 item-999）由
  `static_1000` 的两个 build/serve 场景覆盖，不另做一套“只跑冒烟”的实现。
* **规模敏感性**：`static_3000` 用来观察静态生成是否线性放大，避免“页面数刚好适配小样本”的偶然结论。
* **不同渲染模式**：`dynamic_500` 用 `force-dynamic` 关闭预渲染，`routes_500` 用 500 个
  文件系统路由放大路由表与编译单元数量；两者与静态生成不是同一瓶颈，不能互相替代。
* **增量构建**：`build_incremental_1000` 每次从**同一份冷构建快照**恢复 `.next`，
  因此测到的热构建速度来自同一状态，样本之间没有缓存漂移。
* **真实上游工程**：Next.js 没有官方性能压测套件，单靠自造工程会脱离真实用法。
  因此直接内置官方 `examples/with-typescript`（pages router + TypeScript 类型检查），
  版本、来源与改动都在 `fixtures/upstream/ref.txt` 中说明，并由 `manifest.sha256` 固定。
* **生产服务器**：构建快不等于服务快，`next start` 的启动延时与两种路由的串行请求延时
  单独测量，且每次请求都校验 HTTP 200 与内容标记，失败即判整轮失败。

## 3. 固定输入

| 输入 | 值 |
|---|---|
| Next.js | `16.4.3`（官方 tarball，仓库内 `fixtures/projects.json` 之外的资产在构建阶段校验 SHA-256/SHA-512） |
| React / react-dom | `19.3.1` / `19.3.1`（Next.js peer 范围 `^18.2.0 \|\| ^19.0.0`） |
| Node.js | 官方 `v22.23.4` 二进制（Next.js `engines.node` `>=20.9.0`，自带 npm 10.9.9） |
| TypeScript 及类型包 | `5.9.3` / `@types/node 22.20.5` / `@types/react 19.3.0` / `@types/react-dom 19.3.0` |
| 依赖锁 | `fixtures/dependencies/package-lock.json`（lockfileVersion 3，含 x64/arm64 两套 `@next/swc-*`） |
| 生成工程 | `scripts/fixtures/generate_projects.py`，4 个工程的目录树摘要记录在 `fixtures/projects.json` |
| 上游工程 | `vercel/next.js@v16.4.3` 的 `examples/with-typescript`，`fixtures/upstream/manifest.sha256` 固定 16 个文件 |

**跨架构一致性**：`parameters` 只包含 `x86_64` 与 `aarch64` 完全一致的值（版本、engines 范围、
registry、锁文件摘要、工程树摘要、上游清单摘要、相对命令、固定并行度）。
Node.js 归档、npm 平台包、`@next/swc-*` 这类架构相关事实只写入
`build_provenance.json` 与每个指标的 `native_backend` 证据字段，**不进入参数签名**。
`results.json` 中记录的命令一律是相对命令（`next build`、`next start + 100 serial loopback GET …`），
wrapper/work 目录的绝对路径只出现在 `runs/<场景>/rep<i>.log` 的 `# command:` 行里。
这样两个架构的 `parameter_signature` 相同，`compare_pair` 才能对比同口径结果。

**离线测量**：依赖只在 build 阶段安装一次（`npm ci`），随后做一次**离线重装验证**
（关闭代理 + `--offline`，从私有 npm cache 重装成功才算通过）。测量阶段把
`HTTP_PROXY/HTTPS_PROXY` 指向 `http://127.0.0.1:9`（必然失败），任何试图联网的
构建都会立即失败，而不是悄悄变慢或改变负载。构建阶段用 `actual-version.txt`
记录实测版本，`next --version` 与请求版本不一致时构建直接失败（退出码 30）。

## 4. 目录结构

```
software/Toolchain/nextjs/
├── case.yaml                       # 框架契约：6 阶段 shell-functions + 4 个输出 + 指标采集
├── nextjs_test.sh                  # 独立入口（不依赖 framework/，可在仓库外拷贝运行）
├── scripts/
│   ├── common.sh                   # 固定版本、路径、9 个场景表、计数/复制工具
│   ├── run_timed.py                # 单次测量：墙钟、子进程峰值 RSS、退出码、源文件数
│   ├── builders/
│   │   ├── dispatch.sh             # 变体分发；base 写 build_variant.json
│   │   ├── base.sh                 # 安装 Node/Next、锁文件依赖、离线重装验证、生成工程
│   │   └── optimized.sh            # 保留变体：未实现，打印原因并返回 30，不写 build_variant.json
│   ├── fixtures/
│   │   ├── generate_projects.py    # 确定性生成 static_1000/static_3000/dynamic_500/routes_500
│   │   ├── verify_fixtures.py      # 校验工程摘要、上游清单、锁文件与原生包
│   │   ├── projects.json           # 4 个工程的树摘要、源文件数、预期 HTML 页数
│   │   ├── dependencies/           # 共享依赖的 package.json + package-lock.json
│   │   └── upstream/               # 官方 with-typescript 工程（MIT，含 LICENSE/ref.txt/manifest.sha256）
│   ├── stages/
│   │   ├── start.sh                # 校验运行时、版本、工程与元数据齐备
│   │   ├── test.sh                 # 执行 9 个场景（重置状态 + 预热 + N 次测量）并调用解析器
│   │   └── stop.sh                 # 清理并确认没有残留的 next start 进程
│   └── results/
│       ├── http_probe.py           # 启动服务器、串行请求、逐条校验内容，输出 [next-http] 证据行
│       ├── parse_benchmark.py      # 严格校验证据并聚合 18 个指标（失败即非零退出）
│       └── standalone_runtime.py   # 独立入口的 environment/build_info/report/finalize
└── README.md
```

## 5. 状态重置与正确性校验

* **build 场景**：每次测量前删除工程内 `.next`，保证是冷构建；
  `build_incremental_1000` 则先做一次不计时的冷构建，把 `.next` 快照为 `.next-cold`，
  之后每次测量前删除 `.next` 并恢复快照。
* **serve 场景**：不计时地做一次 production 构建，之后每次测量只重新启动 `next start`，
  构建产物保持不变；服务器在退出前用进程组信号清理，端口未释放即判失败。
* **证据链**：每次测量同时写 `runs/<场景>/rep<i>.log`（原始输出 + 独立证据行）与
  `runs/<场景>/rep<i>.json`（墙钟/RSS/退出码/源文件数）。解析器逐项检查：
  退出码为 0、未超时、墙钟与 RSS 有限且为正、源文件数与构建阶段记录一致、
  构建日志包含 `Compiled successfully` 且不含失败标记、`.next/BUILD_ID` 存在、
  预渲染 HTML 页数等于预期（1005/3005/5/505/9）、动态路由出现在
  `routes-manifest.json`、HTTP 场景的请求数/校验数/路径/内容标记完全匹配、
  日志中不存在 `ERROR:`。
* **增量缓存确实命中**：用同一工程的冷构建编译时间做自校准，
  要求热构建编译时间 < 冷构建编译时间的 50%（x86_64 实测约 1.1 s vs 0.11 s），
  在 aarch64 慢机上同样成立，而不是写死一个绝对阈值。

## 6. 运行方式

### 6.1 框架（CI 使用）

```bash
python3 framework/run_case.py \
  --case software/Toolchain/nextjs/case.yaml \
  --version 16.4.3 \
  --architecture x86_64 \
  --run-id local-20261031T120000Z-1 \
  --stage build
# 依次执行 build → start → test → stop → finalize
```

非预置资产（Node.js 归档、Next.js tarball）第一次构建时会下载并校验；
在 CI 中可预置到 `/home/runner/software/nextjs/` 以避免网络依赖。

### 6.2 独立入口（仓库外可运行）

```bash
cp -a software/Toolchain/nextjs /tmp/nextjs-case
/tmp/nextjs-case/nextjs_test.sh --results-dir /tmp/nextjs-results
```

结果目录包含 `system_info.json`、`runtime_before/after.json`、`build_info.json`、
`build_provenance.json`、`actual-version.txt`、`runs/<场景>/rep<i>.{log,json}`、
`results.json`、`normalized_result.json`、`report.md`、`status.json`。
`--keep-workdir` 可保留隔离工作目录用于排查。

### 6.3 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `PERF_REPS` | `5` | 独立测量次数（1~50），另加 1 次预热 |
| `PERF_NPM_REGISTRY` | 华为云 npm 镜像 | 依赖安装使用的 registry |
| `PERF_NEXT_HTTP_PORT` | `18181` | loopback 服务器端口 |
| `SOFTWARE_VERSION` / `EXPECTED_ARCH` / `PERF_VARIANT` | `16.4.3` / `x86_64` / `base` | 框架传入 |
| `NEXT_OFFLINE_DIR` | `/home/runner/software/nextjs` | 预置离线资产目录 |

## 7. 已知边界

* 性能结论只来自 aarch64 runner 的框架运行；其它架构只用于功能与链路验证。
* 静态生成并行度固定为 2（`experimental.cpus`，写入参数），否则同一个负载会随
  runner 的 CPU 数变化，跨架构不可比。
* Next.js 16 的生产构建由 Turbopack 完成，构建时间包含类型检查（上游工程）与
  静态生成；不同版本之间不能直接对比本仓库的历史数字。
* 国内网络访问 GitHub 不稳定时，`PERF_NPM_REGISTRY` 与 Node.js 镜像可覆盖；
  所有资产仍会被 SHA-256/SHA-512 校验，镜像被篡改会导致构建失败。
* 并发跑其它用例会带来测量噪声（共享资源），此时样本离散度会变差，应按 `stdev`
  判断是否需要重跑，而不是只看中位数。
