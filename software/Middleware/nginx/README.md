# nginx 性能测试说明

本目录测试 nginx 官方源码发布版（nginx.org），使用官方 k6 发布版作为
负载发生器，对静态文件服务进行 x86_64 与 aarch64 开箱性能对比。软件
入口为 `nginx_test.sh`，Framework 通过 `case.yaml` 调用其 `build`、
`start`、`test`、`stop` 四个阶段；直接执行该脚本也使用同一套阶段函数。

当前清单仅声明 nginx `1.30.4`（stable 分支最新版）。新增版本时，必须
同时在 `nginx_test.sh` 中声明官方源码包文件名及其 SHA-256，不能跳过
校验。

## 构建与安装

nginx 官方仅以源码形式分发，这里的“构建”是从官方源码包编译（与
gcc、glibc 用例的源码构建方式一致），不安装发行版 nginx 软件包：

1. 从官方地址 `https://nginx.org/download/nginx-1.30.4.tar.gz` 获取
   源码包（依次使用 `/home/runner/software/nginx/` 本地离线包、当前
   任务工作目录中的同名缓存包、官方下载地址）；
2. 使用清单中声明的 SHA-256 校验包完整性，校验失败立即退出；
3. 以默认配置项编译安装到本次任务的 `PERF_WORK_DIR/nginx-install`：

   ```bash
   ./configure --prefix="${PERF_WORK_DIR}/nginx-install" \
     --http-log-path=... --error-log-path=... --pid-path=...
   make -j"$(getconf _NPROCESSORS_ONLN)" install
   ```

   编译选项保持 nginx 默认（开启 rewrite/gzip 等默认模块，优化标志为
   官方默认的 `-O`），仅把安装前缀与日志/PID 路径指向任务目录；
4. 验证 `nginx -v` 报告的版本与请求版本一致。

编译所需 `pcre2-devel`、`zlib-devel` 及缺失的系统命令由脚本自动通过
`dnf` 安装；非 root Runner 使用 `sudo -n dnf`（与 mysql 用例安装
`libaio-devel`、`openssl-devel` 的方式一致）。

在 Runner 预置离线包时：

```bash
sudo install -d -o runner -g runner /home/runner/software/nginx
sudo install -o runner -g runner nginx-1.30.4.tar.gz /home/runner/software/nginx/
sha256sum /home/runner/software/nginx/nginx-1.30.4.tar.gz
```

负载发生器 k6 复用 envoy 用例的获取方式：官方 GitHub Release 预编译
二进制 `k6 v2.2.0`（按架构选择 `linux-amd64`/`linux-arm64`，SHA-256
校验；支持 `PERF_GITHUB_DOWNLOAD_PROXY` 下载代理，同样可从
`/home/runner/software/nginx/` 离线预置）。

## 服务启动

`start` 阶段在任务私有目录 `PERF_WORK_DIR/runtime` 中组装并启动一个
一次性 nginx 实例：

1. 生成确定性静态文件：`file-1k.bin`（1 KiB）与 `file-100k.bin`
   （100 KiB），内容为零填充，逐文件校验字节数；
2. 写入最小化配置：`worker_processes auto`、`worker_connections
   4096`、`sendfile on`、`tcp_nopush on`、`keepalive_timeout 65s`
   （`sendfile`/`tcp_nopush` 与官方默认 `conf/nginx.conf` 一致）、
   `access_log off`；服务只绑定 `127.0.0.1`，端口由运行 ID 稳定派生
   （与 mysql 用例相同的 cksum 派生方式），避免并发任务固定占用端口；
3. 启动前先探测端口，若已有服务在监听则拒绝启动，不会连接或复用
   预先存在的服务；
4. 启动后轮询就绪，并对两个场景文件逐字节冒烟校验（GET 返回字节数
   与磁盘文件一致）后才进入测试阶段。

核心启动与冒烟命令如下（路径、端口由任务运行时生成）：

```bash
"${NGINX_PREFIX}/sbin/nginx" -p "${RUNTIME_DIR}" -c "${RUNTIME_DIR}/nginx.conf"
curl -sf "http://127.0.0.1:${NGINX_PORT}/file-1k.bin" | wc -c   # == 1024
curl -sf "http://127.0.0.1:${NGINX_PORT}/file-100k.bin" | wc -c # == 102400
```

## 性能测试

测试采用固定版本的官方负载发生器，以 mysql 用例的并发阶梯方式执行：

| 组件 | 固定来源 |
|---|---|
| nginx `1.30.4` | `https://nginx.org/download/nginx-1.30.4.tar.gz`（SHA-256 校验） |
| k6 `2.2.0` | `https://github.com/grafana/k6/releases/download/v2.2.0/`（SHA-256 校验，envoy 用例同款） |

正式流程如下：

1. 两个静态文件场景（`1KiB`、`100KiB`），每档并发按 128、256、512、
   1024 VU 阶梯执行（对应 mysql 的线程阶梯）；
2. 每次运行固定时长 30 秒（`K6_DURATION_SECONDS` 可覆盖），HTTP
   keepalive 连接复用（k6 默认行为）；
3. k6 汇总导出为 JSON，保留 `http_reqs.rate`、`http_req_duration.avg`、
   `http_req_duration.p(95)` 三个字段，要求 `http_req_failed.rate`
   必须为 0（任何失败请求即判失败）；
4. 完整控制台输出保留为 `nginx_k6_raw.log`，结构化结果汇总为
   `results.json`。

实际执行命令形态如下：

```bash
k6 run --vus 128 --duration 30s \
  --summary-export benchmark_static_1KiB_vus128_summary.json \
  nginx_k6_request.js   # NGINX_TARGET=http://127.0.0.1:<port>/file-1k.bin
```

可以脱离 Workflow 执行完整流程；脚本会依次执行 build、start、test、
stop 并保存同样的产物。例如：

```bash
bash software/Middleware/nginx/nginx_test.sh \
  --version 1.30.4 \
  --results-dir /home/runner/boostkit-perf/nginx/results/1.30.4
```

## 指标

每个“场景 + 并发档位”组合保留 3 个字段，不做平均、加权或跨场景聚合。
总计为：

```text
2 个文件场景 × 4 个并发档位 × 3 个指标 = 24 个指标
```

| k6 汇总字段 | 报告中的指标名格式 | 单位 | 优化方向 | 含义 |
|---|---|---|---|---|
| `http_reqs.rate` | `k6 static <场景> --vus=<并发>: RPS` | requests/s | 越大越好 | 每秒完成的请求数 |
| `http_req_duration.avg` | `k6 static <场景> --vus=<并发>: avg latency` | ms | 越小越好 | 请求延迟平均值 |
| `http_req_duration.p(95)` | `k6 static <场景> --vus=<并发>: p95 latency` | ms | 越小越好 | 请求延迟 95 分位 |

报告按文件场景（1KiB / 100KiB）分组；每个场景中再按并发 VU 数展示
RPS 与两项延迟，便于在相同负载下比较 x86_64 与 aarch64。测试工具及
其固定版本（k6 `2.2.0`）会同时列在报告的“测试环境”部分。

## 结果与清理

`case.yaml` 要求以下测试产物：

- `nginx_k6_raw.log`：k6 原始控制台输出（含每档运行的完整输出）；
- `results.json`：24 个结构化指标及其来源文件名。

`stop` 阶段优先通过 `nginx -s quit` 优雅关闭本次实例，必要时对 PID
执行 SIGTERM→SIGKILL 兜底，确认端口不可达后移除本次运行时目录
（静态文件、配置与日志）。Standalone 模式结束时还会删除本次任务专属
的 `/home/runner/boostkit-perf/nginx/local-*` 工作目录（含编译产物与
k6）；Framework 随后执行 Runner 级环境清理。
