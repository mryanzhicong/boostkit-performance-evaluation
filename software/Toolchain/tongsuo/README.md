# Tongsuo 8.5.0 性能测试

本用例从**上游 tag 8.5.0 的源码归档**（commit `80cfbe3eb194a4d30da90742273c305ad4d096be`，
底层 OpenSSL 3.5.4，铜锁版本 8.5.0）在私有 openEuler 24.03 LTS SP4 容器内构建
`apps/openssl`，用其自带的 `apps/openssl speed` 跑 **10 个算法场景**（SM2、SM3、SM4-GCM/CBC、
ZUC-128-EEA3、AES-256-GCM、SHA-256、ECDSA P-256、RSA-2048、ECDH P-256），每个场景取
**1 次预热 + 6 次正式采样**的中位数，共 **19 个指标**。

- 正式证据只跑 **aarch64**（Kunpeng 950）；x86_64 仅用于本地功能自测，Blue 不派发 x86_64，
  报告里也不把两架构的绝对值直接比较。
- 容器规格：**不限制 CPU、内存或 NUMA**，每个任务一个独立的 openEuler 24.03 LTS SP4 容器，
  使用宿主网络（`--network=host`），以 Runner 用户身份运行。
- 入口脚本为 [`tongsuo_test.sh`](tongsuo_test.sh)，Framework 六阶段与独立运行共用
  `scripts/builders`、`scripts/stages` 中的同一批函数。
- `base` 是唯一实现的变体；调优版入口位于 `scripts/builders/optimized.sh`，目前**尚未实现**，
  选择后会在构建阶段明确失败并返回 10，不会退回基础版。
- 场景与上游 benchmark CI（`.github/workflows/speed-test.yml`）的算法矩阵对齐；差异只有两处：
  构建时去掉 `--strict-warnings` 与 `enable-fips`（前者把告警当错误，后者只影响 FIPS provider），
  并把公钥类操作的 `-seconds` 从工具默认的 10 s 统一压到 3 s，让 10 个场景共享同一时间预算。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| 被测软件 | Tongsuo 8.5.0，tag `8.5.0`，commit `80cfbe3eb194a4d30da90742273c305ad4d096be`；<https://github.com/Tongsuo-Project/Tongsuo>（Apache-2.0） | 源码归档 `${PERF_WORK_DIR}/Tongsuo-8.5.0`（容器内同路径） |
| 源码归档 | `Tongsuo-8.5.0.tar.gz`，53,695,695 B，SHA-256 `505085d457214e5662ea7109c3919fb75f695edf74c91ec6f690da0e58c07dea` | 优先读取 `/home/runner/software/tongsuo/downloads/`，缺失时按 URL 列表下载后校验 |
| 测量工具 `apps/openssl speed` | 与源码同版本，`./config no-shared enable-ntls enable-zuc enable-ec_elgamal enable-paillier enable-sm2 enable-sm3 enable-sm4` 后 `make -j` 就地构建 | `${PERF_WORK_DIR}/Tongsuo-8.5.0/apps/openssl` |
| 构建工具链（容器内） | openEuler 24.03 LTS SP4 自带 `gcc`、`make`、`perl` + `perl-Text-Template`、`binutils`、`glibc-devel` | 容器内 `/usr/bin`（`dnf install` 安装） |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/)，`openEuler-docker.<arch>.tar.xz`；优先读取 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载并按随归档发布的 `.sha256sum` 校验，然后 `docker load` | 本地镜像 `openeuler-24.03-lts-sp4`（脚本用 `docker load` 载入） |

## Tongsuo 获取、构建与容器启动

### 1. 获取源码

两个架构共用同一个归档（纯 C 源码，无预编译产物），按架构只有容器依赖不同：

| 架构 | 归档 | 字节数 | SHA-256 | 容器依赖 |
|---|---|---|---|---|
| aarch64 | `Tongsuo-8.5.0.tar.gz` | 53,695,695 | `505085d4…58c07dea` | `gcc make perl perl-Text-Template binutils glibc-devel` |
| x86_64 | `Tongsuo-8.5.0.tar.gz` | 53,695,695 | `505085d4…58c07dea` | 同上（本地自测用） |

实际命令形态：

```bash
mkdir -p /home/runner/software/tongsuo/downloads
curl -fSL --retry 3 -o /home/runner/software/tongsuo/downloads/Tongsuo-8.5.0.tar.gz \
  https://github.com/Tongsuo-Project/Tongsuo/archive/refs/tags/8.5.0.tar.gz
printf '%s  %s\n' 505085d457214e5662ea7109c3919fb75f695edf74c91ec6f690da0e58c07dea \
  Tongsuo-8.5.0.tar.gz | (cd /home/runner/software/tongsuo/downloads && sha256sum -c -)
tar -xzf /home/runner/software/tongsuo/downloads/Tongsuo-8.5.0.tar.gz \
  --strip-components=1 -C "${PERF_WORK_DIR}/Tongsuo-8.5.0"
```

归档缺失时按 `github.com` → `gh-proxy.com` → `ghfast.top` 的顺序下载，三者都必须通过同一个
SHA-256；校验失败即构建阶段返回 30，不会带病测量。

- **脚本出处**：`scripts/common.sh`（`tongsuo_fetch_archive` / `tongsuo_verify_archive`）

### 2. 容器创建

实际命令形态（容器名按架构与运行 ID 派生，标签把容器绑定到本次运行）：

```bash
docker run --detach --name "boostkit-tongsuo-${arch}-${PERF_RUN_ID}" \
  --label "boostkit.tongsuo.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --ulimit nofile=1048576:1048576 \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  openeuler-24.03-lts-sp4 sleep infinity
docker exec --user 0 "boostkit-tongsuo-${arch}-${PERF_RUN_ID}" dnf -y --setopt=install_weak_deps=False \
  --setopt=tsflags=noscripts install gcc make perl perl-Text-Template tar gzip curl which \
  coreutils findutils diffutils binutils glibc-devel
```

容器**不设** CPU、内存或 NUMA 配额（没有 `--cpus`、`--cpuset-cpus`、`--cpuset-mems`、`--memory`），
容器内 `nproc` 与 `sched_getaffinity` 看到的就是整机拓扑；start 阶段会把这两项打印进日志。
容器创建后脚本会把容器内 `/etc/yum.repos.d/openEuler.repo` 指向华为云镜像，再安装依赖。

- **脚本出处**：`scripts/common.sh` 的 container-runtime 区块（由
  `adaptation/scripts/add-container-block.py` 生成，勿手改）

### 3. 构建

```bash
cd "${PERF_WORK_DIR}/Tongsuo-8.5.0"
./config no-shared enable-ntls enable-zuc enable-ec_elgamal enable-paillier \
  enable-sm2 enable-sm3 enable-sm4
make -j16
./apps/openssl version -a
./apps/openssl version        # 期望输出以 "Tongsuo 8.5.0" 开头
```

`no-shared` 让 `apps/openssl` 直接链接 `libcrypto.a`/`libssl.a`，测量时不需要 `LD_LIBRARY_PATH`；
`make -j` 的并发数取 `nproc` 但封顶 16，避免在 384 vCPU 机器上把容器打爆。

- **脚本出处**：`scripts/builders/base.sh`

## 数据与运行顺序

用例不依赖外部数据集：`openssl speed` 自己造缓冲，输入全部在内存里生成。场景矩阵两个架构相同，
每个场景在容器内串行执行 1 次预热与 6 次正式采样，逻辑编号如下：

1. **预热**：`runs/<场景>/warmup1.log`，结果不参与统计，只用于把页缓存/频率拉到稳态；
2. **正式采样**：`runs/<场景>/rep{1..6}.log`，每次都是独立的 `openssl speed` 进程；
3. **严格解析**：解析器按场景检查样本文件集合与表结构，取中位数写 `results.json`，
   同时把 6 个原始值写 `samples.json`；
4. **汇总**：所有采样日志按场景与轮次拼接成 `benchmark_tongsuo.txt`。

| 场景 | 容器内命令 | 表类型 | 指标数 |
|---|---|---|---|
| `sm4_gcm` | `openssl speed -seconds 3 -evp sm4-gcm` | 对称/摘要表（6 种块长） | 2 |
| `sm4_cbc` | `openssl speed -seconds 3 -evp sm4-cbc` | 对称/摘要表（6 种块长） | 2 |
| `aes_256_gcm` | `openssl speed -seconds 3 -evp aes-256-gcm` | 对称/摘要表（6 种块长） | 2 |
| `zuc_128_eea3` | `openssl speed -seconds 3 -evp zuc-128-eea3` | 对称/摘要表（6 种块长） | 2 |
| `sm3` | `openssl speed -seconds 3 sm3` | 对称/摘要表（6 种块长） | 2 |
| `sha256` | `openssl speed -seconds 3 sha256` | 对称/摘要表（6 种块长） | 2 |
| `sm2_sign_verify` | `openssl speed -seconds 3 sm2` | 公钥签名表（sign/verify） | 2 |
| `ecdsa_p256` | `openssl speed -seconds 3 ecdsap256` | 公钥签名表（sign/verify） | 2 |
| `rsa2048` | `openssl speed -seconds 3 rsa2048` | 公钥签名表（sign/verify） | 2 |
| `ecdh_p256` | `openssl speed -seconds 3 ecdhp256` | 密钥交换表（op/s） | 1 |

实际命令形态：

```bash
# 采样在私有容器内执行，与阶段脚本同一形态：每个场景独立进程、独立计时
docker exec -e PERF_RUN_ID="${PERF_RUN_ID}" \
  "boostkit-tongsuo-${arch}-${PERF_RUN_ID}" \
  sh -c 'cd "$PERF_WORK_DIR/Tongsuo-8.5.0" && ./apps/openssl speed -seconds 3 -evp sm4-gcm'

# 其余场景同形（对称/摘要一次进程跑 6 种块长，各消耗 -seconds 3 秒）
./apps/openssl speed -seconds 3 -evp sm4-cbc
./apps/openssl speed -seconds 3 -evp aes-256-gcm
./apps/openssl speed -seconds 3 -evp zuc-128-eea3
./apps/openssl speed -seconds 3 sm3
./apps/openssl speed -seconds 3 sha256

# 公钥操作：sign/s、verify/s 与 op/s
./apps/openssl speed -seconds 3 sm2
./apps/openssl speed -seconds 3 ecdsap256
./apps/openssl speed -seconds 3 rsa2048
./apps/openssl speed -seconds 3 ecdhp256
```
```

`-seconds` 必须写在算法名之前：`openssl speed` 把第一个位置参数及其后的所有参数都当成算法名，
`speed sm3 -seconds 3` 会报 `speed: Unknown algorithm -seconds`。
每轮都重新调用 `apps/openssl`（不复用进程），样本之间没有共享状态；单轮耗时约 2.5 分钟，
6 轮正式采样加 1 轮预热合计约 18 分钟。

- **脚本出处**：`scripts/stages/test.sh`（采样循环）、`scripts/results/parse_benchmark.py`（严格解析）

## 指标与产物

`case.yaml` 的 `metrics.collection` 指向 `results.json` 的 `results[]`，字段为
`source_name` / `value` / `unit` / `direction` / `group`；指标名、单位与方向如下表，共
**19 个指标**，全部**越高越好**：

| 指标 | 来源（场景） | 单位 | 方向 |
|---|---|---|---|
| `sm4_gcm_16b_mb_per_sec` | `sm4_gcm` | MB/s | 越高越好 |
| `sm4_gcm_16384b_mb_per_sec` | `sm4_gcm` | MB/s | 越高越好 |
| `sm4_cbc_16b_mb_per_sec` | `sm4_cbc` | MB/s | 越高越好 |
| `sm4_cbc_16384b_mb_per_sec` | `sm4_cbc` | MB/s | 越高越好 |
| `aes_256_gcm_16b_mb_per_sec` | `aes_256_gcm` | MB/s | 越高越好 |
| `aes_256_gcm_16384b_mb_per_sec` | `aes_256_gcm` | MB/s | 越高越好 |
| `zuc_128_eea3_16b_mb_per_sec` | `zuc_128_eea3` | MB/s | 越高越好 |
| `zuc_128_eea3_16384b_mb_per_sec` | `zuc_128_eea3` | MB/s | 越高越好 |
| `sm3_16b_mb_per_sec` | `sm3` | MB/s | 越高越好 |
| `sm3_16384b_mb_per_sec` | `sm3` | MB/s | 越高越好 |
| `sha256_16b_mb_per_sec` | `sha256` | MB/s | 越高越好 |
| `sha256_16384b_mb_per_sec` | `sha256` | MB/s | 越高越好 |
| `sm2_sign_ops_per_sec` | `sm2_sign_verify` | ops/s | 越高越好 |
| `sm2_verify_ops_per_sec` | `sm2_sign_verify` | ops/s | 越高越好 |
| `ecdsa_p256_sign_ops_per_sec` | `ecdsa_p256` | ops/s | 越高越好 |
| `ecdsa_p256_verify_ops_per_sec` | `ecdsa_p256` | ops/s | 越高越好 |
| `rsa2048_sign_ops_per_sec` | `rsa2048` | ops/s | 越高越好 |
| `rsa2048_verify_ops_per_sec` | `rsa2048` | ops/s | 越高越好 |
| `ecdh_p256_ops_per_sec` | `ecdh_p256` | ops/s | 越高越好 |

产物清单（`${RESULTS_DIR}` 内）：

| 产物 | 说明 |
|---|---|
| `build_variant.json` | 变体、版本、架构、归档 SHA-256、tag commit、configure flags、镜像 |
| `actual-version.txt` | 容器内 `./apps/openssl version` 的首行（版本门禁） |
| `openssl-version.txt` | `./apps/openssl version -a` 全文 |
| `build-configure.log` / `build-make.log` | 配置与编译完整日志 |
| `benchmark_tongsuo.txt` | 全部场景 × 全部轮次的原始输出 |
| `results.json` | 19 个指标的中位数结果 |
| `samples.json` | 每个指标的 6 个原始采样值 |
| `runs/<场景>/warmup1.log`、`runs/<场景>/rep{1..6}.log` | 单轮原始日志 |

## 独立运行

```bash
cd software/Toolchain/tongsuo
./tongsuo_test.sh --version 8.5.0 --variant base --results-dir /tmp/tongsuo-run
# 本地快速自测（样本数低于 5 时只给 WARNING）：
TONGSUO_SAMPLES=1 ./tongsuo_test.sh --results-dir /tmp/tongsuo-smoke --keep-workdir
```

- **脚本出处**：`tongsuo_test.sh`

## 与「整机直跑」的差异

被测进程与测量进程都在同一个容器里，客户端/服务端角色都不存在：`speed` 是单进程、
单线程的微基准，容器使用 `--network=host` 但没有网络 I/O，也不限制 CPU、内存或 NUMA。
宿主机的职责只有三件事：下载并 SHA-256 校验源码归档、调用 Docker、运行严格结果解析；
**不向宿主机安装任何软件包**，也不修改宿主机的系统配置、信任库或软件源。源码解包、
依赖安装、编译与全部测量都在私有容器内完成。

## 已知限制

- **只覆盖算法层**：`speed` 不测 TLS/TLCP 握手、协议吞吐或端到端延迟；TLCP 双证书场景
  （`s_server -ntls -enc_cert … -sign_cert …`）需要外部压测器，不在本用例范围内。
- **不测后量子与同态**：`-kem-algorithms`、`-signature-algorithms`、`paillier`、`ecelgamal*`
  与白盒 SM4/`sdf` 依赖额外开关或硬件，本用例只跑与上游 benchmark CI 对齐的子集。
- **`optimized` 未实现**：选择该变体会在构建阶段明确失败并返回 10，不退回基础版。
- **单进程视角**：`speed` 不反映多核扩展性；需要并发扩展性时应改用 `-multi <N>` 并单独定义口径。
- **与上游 CI 的口径差异**：本用例统一用 `-seconds 3`（上游对称类 3 s、公钥类 10 s），
  并去掉 `--strict-warnings`/`enable-fips`；横向对比时必须用同一口径重跑。

## 故障排查

| 现象 | 处理 |
|---|---|
| `./config` 报 `Can't locate Text/Template.pm` | 容器内缺 `perl-Text-Template`，`dnf install perl-Text-Template` |
| `make` 在 384 vCPU 机器上被 OOM 杀掉 | `TONGSUO_BUILD_JOBS=16` 或更低；脚本默认已封顶 16 |
| 归档校验失败 | 确认下载的是 `refs/tags/8.5.0` 归档；`gh-proxy`/`ghfast` 代理必须逐字节透传 |
| 容器名冲突 | 容器名含 `PERF_RUN_ID`；确认上一次 stop 阶段是否被强杀，用 `docker ps -a` 清理残留 |
| 样本集合不匹配 | 解析器要求 `warmup.log` + `rep1..N.log` 恰好齐备，多一个或每少一个都会失败（不补零） |

## 许可证

Tongsuo 采用 Apache-2.0；用例脚本与文档随本仓库发布。上游致谢见源码树
`ACKNOWLEDGEMENTS.md` 与 `LICENSE.txt`。
