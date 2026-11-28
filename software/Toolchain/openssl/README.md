# openssl 4.1.0 性能测试

本用例在 x86_64、aarch64 上分别用上游 OpenSSL 4.1.0 的源码构建同一份 `base` 变体，
并用上游自带的 `openssl speed`（`apps/speed.c`）度量 8 个密码学场景的吞吐与运算速率，
用上游完整的 `make test`（`test/run_tests.pl`，3,619 个测试）做正确性门禁。
被测软件、性能基准程序与测试套件全部来自同一份官方归档，没有自研 benchmark、
没有第三方补丁，也没有改一行源码。

构建与测量都在本次任务专属的 openEuler 24.03 LTS SP4 私有容器内执行；容器使用宿主网络，
**不限制 CPU、内存或 NUMA**，测量进程不绑核，也不设 NUMA 亲和，与仓库里的 `jemalloc`、
`libavif` 等用例口径一致。Framework 按 `case.yaml` 依次调用构建、启动校验、测试、校验与
停止函数；软件入口为 `openssl_test.sh`，独立入口复用同一组阶段函数。

`base` 变体按上游默认的 Release 口径构建：`./Configure no-shared`（目标自动选择
`linux-x86_64` / `linux-aarch64`），编译器选项沿用上游该目标的默认值（`-Wall -O3 -DNDEBUG`，
aarch64/x86_64 的汇编实现全部启用），不额外追加 `-march`/`-mcpu`，也不打补丁，因此结果可被
任何人在同一版本上完全复现。`optimized` 变体尚未实现：选择后在构建阶段**明确失败**
（`return 30`）并说明原因，不会退回 `base`，也不会静默降级。两个架构使用同一份源码、
同一套 `speed` 参数、同一套测试用例，只有架构和运行位置不同。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| OpenSSL（被测软件） | 上游 tag `openssl-4.1.0`（commit `2f4e3a5fec05394068cfa7379890ab552483a8a6`，2026-10-23 发布）的 GitHub 不可变 tag 源码归档 `openssl-openssl-4.1.0.tar.gz`，55,917,193 字节，SHA-256 `2a54158eb6861c07cefc92f1a1d68b12d5ecc0883d53c61a092995b221c7d5fe`；与官方 `openssl-4.1.0.tar.gz` 是同一个 commit 的两种打包（release 资产 CDN 在 Blue aarch64 Runner 上不可达，`codeload.github.com` 可达，因此固定用 tag 归档，构建仍走上游自己的 `./Configure`，与上游 CI 在 git checkout 上的做法一致） | 优先读取公共离线目录 `/home/runner/software/openssl/`，缺失时下载到 `${PERF_WORK_DIR}/downloads/`；容器内解压为 `${PERF_WORK_DIR}/openssl-openssl-4.1.0` |
| 性能基准程序 | 上游自带的 `openssl speed`（`apps/speed.c`，与 `libcrypto` 同一份源码编译，不引入外部 benchmark 依赖），输出用 `-mr` 机器可读格式解析 | 构建产物 `${PERF_WORK_DIR}/install-base/bin/openssl`（`no-shared` 静态链接，8.3 MB） |
| 正确性测试套件 | 上游自带 `test/run_tests.pl`（`make test`，Perl + `Test::More`）：402 个测试文件、3,619 个测试，上游 CI 用的就是它 | 构建树 `${PERF_WORK_DIR}/openssl-openssl-4.1.0/test/`，与构建树一起复用，不额外安装 |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/)，按架构取 `openEuler-docker.<arch>.tar.xz`，同目录 `.sha256sum` 校验 | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |
| 容器内构建与测试依赖 | `perl`、`perl-Test-Simple`、`perl-Time-HiRes`、`make`、`gcc`、`gawk`、`tar`、`gzip`、`diffutils`、`findutils`、`which`、`coreutils` | 全部在容器内用 `dnf` 安装，不向宿主机安装 |

所有输入都来自上游官方归档：`openssl speed` 在进程内生成临时 RSA/EC/Ed25519 密钥，
`make test` 使用源码树自带的测试证书与脚本。版本号、编译器选项、实际生效的宏在构建阶段
写入 `build_variant.json`，便于复核。

## openssl 获取、构建与容器启动

脚本先确认 Docker daemon 可用（`docker info` 失败时构建阶段返回 30，并提示先启动 daemon）。
基础镜像归档 `openEuler-docker.<arch>.tar.xz` 与同名 `.sha256sum` 优先取上表的公共目录，缺失时
才从官方地址下载；校验后 `docker load`，再核对镜像架构与容器内发行版（以下是实际命令形态）：

```bash
ARCH="$(uname -m)"                                  # x86_64 / aarch64
IMAGE_DIR="/home/runner/software/openEuler-24.03-LTS-SP4"
ARCHIVE="${IMAGE_DIR}/openEuler-docker.${ARCH}.tar.xz"
if [ ! -s "${ARCHIVE}" ]; then
  ARCHIVE="${PERF_WORK_DIR}/openEuler-docker.${ARCH}.tar.xz"
  curl -fSL --retry 3 --connect-timeout 30 -o "${ARCHIVE}.part" \
    "https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${ARCH}/openEuler-docker.${ARCH}.tar.xz"
  curl -fSL --retry 3 --connect-timeout 30 -o "${ARCHIVE}.sha256sum" \
    "https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/${ARCH}/openEuler-docker.${ARCH}.tar.xz.sha256sum"
  mv "${ARCHIVE}.part" "${ARCHIVE}"
fi
( cd "$(dirname "${ARCHIVE}")" && sha256sum -c "$(basename "${ARCHIVE}").sha256sum" )
docker load -i "${ARCHIVE}"
docker run --rm --network=none "${OPENSSL_CONTAINER_IMAGE}" cat /etc/os-release
```

`/etc/os-release` 的 `VERSION_ID` 必须是 `24.03`，镜像架构必须是 `x86_64`→`amd64`、
`aarch64`→`arm64`；本用例不访问 Docker Hub。

每次构建使用容器 `boostkit-openssl-<架构>-<运行 ID>`，以 Runner 的 UID/GID 运行，把工作目录与
结果目录按原路径挂载进去（以下是实际命令形态）：

```bash
docker run --detach --name "${OPENSSL_CONTAINER_NAME}" \
  --label "boostkit.openssl.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${OPENSSL_CONTAINER_IMAGE}" sleep infinity
```

容器内先安装构建与测试依赖；正式工作流设置 `PERF_PROXY` 时，还会把
`/home/runner/software/anchors/` 只读挂到 `/etc/pki/ca-trust/source/anchors/`，在容器内执行
`update-ca-trust extract`，并让容器内的 `dnf`/`curl` 走代理。容器启动后容器块会把镜像里的
`/etc/yum.repos.d/openEuler.repo` 从 `repo.openeuler.org` 改写成
`repo.huaweicloud.com/openeuler`（无论是否设置代理都执行，便于国内网络）；本地 DNS 不可用时，
通过 `OPENSSL_DOCKER_EXTRA_ARGS` 追加 `--add-host repo.huaweicloud.com:<IP>` 即可，Blue 的
aarch64 Runner 不需要该变量：

```bash
dnf install -y --setopt=install_weak_deps=False \
  perl perl-Test-Simple perl-Time-HiRes make gcc gawk \
  tar gzip diffutils findutils which coreutils
```

源码归档按「公共离线目录 → 本次工作目录」的顺序获取，缺失时才下载，并强制校验 SHA-256；
下载候选按 `codeload.github.com` 的 tag 归档 → `api.github.com` 的 tarball 端点 →
`github.com/.../archive` 依次尝试，每个候选都用同一个 SHA-256 校验，校验不过就丢弃并换下一个；
全部失败时构建阶段返回 30，不会跳过校验继续构建。之所以不直接用 release 资产
（`github.com/openssl/openssl/releases/download/...`）：Blue aarch64 Runner 上 `github.com:443`
连接超时、`release-assets.githubusercontent.com` 传输会被中断（曾连续失败两次，`curl` 报
`HTTP/2 PROTOCOL_ERROR` 与 `transfer closed with ... bytes remaining`），而 `codeload.github.com`
可达。下载参数同时做了收敛：只用 HTTP/1.1、断点续传、失败重试 5 次、连接超时 30 s、低速阈值
（< 1 KB/s 持续 60 s 即中断换源）与 1 h 总上限，因此单个源卡死不会耗尽整个 job
（以下是实际命令形态）：

```bash
OFFLINE="/home/runner/software/openssl"
NAME="openssl-openssl-4.1.0.tar.gz"
mkdir -p "${PERF_WORK_DIR}/downloads"
if [ -s "${OFFLINE}/${NAME}" ]; then
  cp -f "${OFFLINE}/${NAME}" "${PERF_WORK_DIR}/downloads/${NAME}"
else
  for url in \
    "https://codeload.github.com/openssl/openssl/tar.gz/refs/tags/openssl-4.1.0" \
    "https://api.github.com/repos/openssl/openssl/tarball/refs/tags/openssl-4.1.0" \
    "https://github.com/openssl/openssl/archive/refs/tags/openssl-4.1.0.tar.gz"; do
    curl -fSL --http1.1 --continue-at - --retry 5 --retry-all-errors --retry-delay 5 \
      --connect-timeout 30 --speed-limit 1024 --speed-time 60 --max-time 3600 \
      -o "${PERF_WORK_DIR}/downloads/${NAME}.part" "${url}" || continue
    printf '%s  %s\n' 2a54158eb6861c07cefc92f1a1d68b12d5ecc0883d53c61a092995b221c7d5fe "${NAME}" \
      | sha256sum -c - && break
    rm -f "${PERF_WORK_DIR}/downloads/${NAME}.part"
  done
  [ -s "${PERF_WORK_DIR}/downloads/${NAME}.part" ] || exit 30
  mv "${PERF_WORK_DIR}/downloads/${NAME}.part" "${PERF_WORK_DIR}/downloads/${NAME}"
fi
printf '%s  %s\n' 2a54158eb6861c07cefc92f1a1d68b12d5ecc0883d53c61a092995b221c7d5fe "${NAME}" \
  | sha256sum -c -
tar xzf "${PERF_WORK_DIR}/downloads/${NAME}" -C "${PERF_WORK_DIR}"
```

构建完全用上游的 `Configure`/`make`，不做任何源码修改；`no-shared` 让 `openssl` 静态链接，
测量时不需要 `LD_LIBRARY_PATH`，也避免动态库路径带来的偶发失败。上游该目标的默认编译选项
（`gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DL_ENDIAN -DOPENSSL_PIC -DNDEBUG`）
原样保留，本用例不追加任何 `-march`/`-mcpu`/`-flto`：

```bash
cd "${PERF_WORK_DIR}/openssl-4.1.0"
./Configure no-shared \
  --prefix="${PERF_WORK_DIR}/install-base" \
  --openssldir="${PERF_WORK_DIR}/install-base/ssl"
make -j"$(nproc)"
make install_sw
"${PERF_WORK_DIR}/install-base/bin/openssl" version -a
```

同一次构建里同时产出 `apps/openssl`（含 `speed`）和 `test/run_tests.pl` 所需的测试二进制，
因此测试阶段不需要第二次编译。构建完成后用一个最小用例做冒烟：要求退出码 0、输出含
`+F:6:sha256:` 行且数值为正，否则构建阶段失败、不进入测量：

```bash
"${PERF_WORK_DIR}/install-base/bin/openssl" speed -mr -seconds 1 -bytes 16384 sha256 \
  > "${PERF_WORK_DIR}/smoke.txt" 2>&1
grep -q '^+F:6:sha256:' "${PERF_WORK_DIR}/smoke.txt"
```

构建完成后把版本、源码归档 SHA-256、二进制 SHA-256、编译器与生效宏（`configdata.pm` 的
`CFLAGS`/`target`）、容器镜像写入 `build_variant.json`，并保留同一个容器供测试与校验阶段复用。
**宿主机只做下载、SHA-256 校验、Docker 调用和结果解析**；不向宿主机安装任何软件包，也不修改
宿主机的镜像源、信任库或系统配置。受限网络下可用 `OPENSSL_DOCKER_EXTRA_ARGS` 追加
`docker run` 参数（例如 `--add-host` 指定内网镜像地址）；Blue 的 aarch64 Runner 使用默认镜像源，
不需要该变量。

实测参考（openEuler 24.03 LTS SP4 容器，20 vCPU x86_64，工作目录在 ext4 上）：`Configure`
约 6 s，`make -j20` 约 25 s，`make install_sw` 约 2 s（构建 1,812 个对象文件）；同一命令在
Windows 挂载的 9p 目录（`/mnt/d`）上 `make` 实测 460 s，慢一个数量级，因此正式运行务必把
`PERF_WORK_DIR` 放在本地盘。构建树约 2.0 GB，安装目录约 31 MB，归档约 56 MB（tag 源码归档比
release tarball 略大，因为包含完整 git 快照），因此工作目录按 2.5 GB 预留。

- **脚本出处**：`scripts/common.sh`、`scripts/builders/dispatch.sh`、`scripts/builders/base.sh`、
  `scripts/builders/optimized.sh`。

## 数据与运行顺序

本用例不引入任何外部数据集：`openssl speed` 在进程内生成密钥并复用固定长度的输入缓冲，
`make test` 用源码树自带的证书与脚本，二者都不写 `$HOME`。每个场景的输入规模由命令行固定，
记录在 `fixtures/scenarios.json` 中：

| 场景 | `openssl speed` 参数 | 单轮计时 | 说明 |
|---|---|---|---|
| `sha256` | `-mr -seconds 2 -bytes 16384 sha256` | 2 s | 16 KiB 块上的 SHA-256 摘要 |
| `sha512` | `-mr -seconds 2 -bytes 16384 sha512` | 2 s | 16 KiB 块上的 SHA-512 摘要 |
| `aes_128_gcm` | `-mr -seconds 2 -bytes 16384 -evp aes-128-gcm` | 2 s | AES-128-GCM（AEAD，含 tag 校验） |
| `aes_256_gcm` | `-mr -seconds 2 -bytes 16384 -evp aes-256-gcm` | 2 s | AES-256-GCM（AEAD） |
| `chacha20_poly1305` | `-mr -seconds 2 -bytes 16384 -evp chacha20-poly1305` | 2 s | ChaCha20-Poly1305（AEAD） |
| `rsa2048` | `-mr -seconds 2 rsa2048` | 20 s | RSA-2048 签名/验签（含上游一并测的 raw 与 KEM 块） |
| `ecdsa_p256` | `-mr -seconds 2 ecdsap256` | 4 s | ECDSA P-256（prime256v1）签名/验签 |
| `ed25519` | `-mr -seconds 2 ed25519` | 4 s | Ed25519 签名/验签 |

上游 `speed` 用**进程 CPU 时间**做分母（没有加 `-elapsed`），单线程运行（没有加 `-multi`），
因此指标反映单核能力，不受容器核数影响；`rsa2048` 一轮要跑 10 个计时块（raw sign/verify/
encrypt/decrypt + KEM keygen/encaps/decaps + 签名 keygen/sign/verify），所以单轮 20 s。

执行顺序固定为：

1. **启动校验**：确认容器仍在运行、`boostkit.openssl.run-id` 标签与本次运行 ID 一致，
   `install-base/bin/openssl`、`configdata.pm`、源码树 `test/` 都可读，工作目录剩余空间足够。
2. **预热 1 次**：按下面第 4 步的命令形态，对 8 个场景各执行一遍，输出落到
   `runs/<scenario>/rep0.*`，只记录、不参与统计。
3. **准备结果目录**：为 8 个场景各建 `runs/<scenario>/` 子目录，`runs/` 位于 `${RESULTS_DIR}` 下。
4. **正式采样 5 次**：每次采样对 8 个场景各起一个独立进程，标准输出落 `rep<i>.log`、
   标准错误落 `rep<i>.err`；`i` 从 1 开始（以下是实际命令形态）：

```bash
BIN="${PERF_WORK_DIR}/install-base/bin/openssl"
declare -A args=(
  [sha256]="-mr -seconds 2 -bytes 16384 sha256"
  [sha512]="-mr -seconds 2 -bytes 16384 sha512"
  [aes_128_gcm]="-mr -seconds 2 -bytes 16384 -evp aes-128-gcm"
  [aes_256_gcm]="-mr -seconds 2 -bytes 16384 -evp aes-256-gcm"
  [chacha20_poly1305]="-mr -seconds 2 -bytes 16384 -evp chacha20-poly1305"
  [rsa2048]="-mr -seconds 2 rsa2048"
  [ecdsa_p256]="-mr -seconds 2 ecdsap256"
  [ed25519]="-mr -seconds 2 ed25519"
)
for scenario in "${!args[@]}"; do
  docker exec "${OPENSSL_CONTAINER_NAME}" mkdir -p "${RESULTS_DIR}/runs/${scenario}"
  docker exec "${OPENSSL_CONTAINER_NAME}" \
    "${BIN}" speed ${args[${scenario}]} \
    > "${RESULTS_DIR}/runs/${scenario}/rep${i}.log" \
    2> "${RESULTS_DIR}/runs/${scenario}/rep${i}.err"
done
```

5. **严格解析**：宿主机执行解析命令，从 8 份日志的 `-mr` 行换算成 16 项指标与中位数
   （见「指标与产物」）。
6. **校验**：在构建树里跑上游完整测试套件（与上游 CI 的 `make test` 完全相同，只是把
   `HARNESS_JOBS` 固定为 8 以便结果可复现），退出码必须为 0、输出含 `Result: PASS` 且没有
   `Result: FAIL`；该步骤不参与指标，只作为正确性证据：

```bash
cd "${PERF_WORK_DIR}/openssl-4.1.0"
HARNESS_JOBS=8 make test > "${RESULTS_DIR}/test.log" 2>&1
grep -q '^Result: PASS$' "${RESULTS_DIR}/test.log"
```

日志里还会出现一行 `Result: NOTESTS`：这是 `make test` 对「本构建没有 FIPS 测试」的空跑，
不算失败；解析时以同时满足 `Result: PASS` 与主结果行 `Files=402, Tests=3619` 为准。

单轮 8 个场景合计约 38–39 s，1 次预热 + 5 次采样约 4 min；`make test` 在 20 vCPU 上
`HARNESS_JOBS=8` 实测 68–337 s（402 个测试文件、3,619 个测试，另有 9 个 external provider 用例
因未启用外部测试而 skip，属于上游默认行为；耗时差异来自宿主机负载）。结果目录按「每场景每轮
一个 log + 一个 err + 一个 JSON」估算不足 5 MB。

7. **清理**：停止阶段按 `boostkit.openssl.run-id` 标签移除本次容器，保留结果目录；
   `--keep-workdir` 时保留工作目录（约 2.5 GB）。

## 指标与产物

| 报告分组 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| `sha256` | `sha256_bytes_per_s`、`sha256_ops_per_s` | `runs/sha256/rep<i>.log` 的 `+F:6:sha256:<bytes/s>` 与 `+R:<n>:sha256:<t>`（`ops/s = n / t`） | B/s、op/s | 越大越好 |
| `sha512` | `sha512_bytes_per_s`、`sha512_ops_per_s` | 同上，名称换成 `sha512`（`+F:7:sha512:`） | B/s、op/s | 同上 |
| `aes_128_gcm` | `aes_128_gcm_bytes_per_s`、`aes_128_gcm_ops_per_s` | `+F:25:AES-128-GCM:<bytes/s>` 与 `+R:<n>:AES-128-GCM:<t>` | B/s、op/s | 同上 |
| `aes_256_gcm` | `aes_256_gcm_bytes_per_s`、`aes_256_gcm_ops_per_s` | 同上，名称换成 `AES-256-GCM` | B/s、op/s | 同上 |
| `chacha20_poly1305` | `chacha20_poly1305_bytes_per_s`、`chacha20_poly1305_ops_per_s` | 同上，名称换成 `ChaCha20-Poly1305` | B/s、op/s | 同上 |
| `rsa2048` | `rsa2048_sign_per_s`、`rsa2048_verify_per_s` | `+F9:<n>:<keygens/s>:<sign/s>:<verify/s>`（签名路径；raw RSA 的 `+F2` 不取） | op/s | 同上 |
| `ecdsa_p256` | `ecdsa_p256_sign_per_s`、`ecdsa_p256_verify_per_s` | `+F4:3:<bits>:<sign/s>:<verify/s>`（`+DTP` 头必须是 `256:sign:prime256v1`） | op/s | 同上 |
| `ed25519` | `ed25519_sign_per_s`、`ed25519_verify_per_s` | `+F4:22:<bits>:<sign/s>:<verify/s>`（`+DTP` 头必须是 `253:sign:Ed25519`） | op/s | 同上 |

指标总数 **16 项** = 8 个场景 × 2 项。分组规则：按 8 个场景名分组（即 `runs/` 下的子目录名）；
对称场景（前 5 个）一项吞吐（`B/s`）、一项运算速率（`op/s`，1 op = 处理一个 16 KiB 块），
非对称场景（后 3 个）一项签名速率、一项验签速率，16 项指标全部是「越大越好」。`-mr` 输出里
`+F` 的第 3 列是实测字节/秒（浮点），`+R` 是「次数:名称:实测秒数」，因此 `op/s` 与 `B/s` 是两条
独立证据；解析时校验对称场景的 `|B/s − 16384 × op/s| / B/s < 0.01`（非对称场景校验
`op/s` 与 `+R` 的次数/秒数一致），不满足即判失败，防止 `+F`/`+R` 错配。

每项指标取 5 次采样（每次采样是独立进程）的中位数写入结果，全部 6 个样本（含预热 `rep0`）
保留在 `runs/` 下，供复核与后续统计。预热 1 次、测量 5 次这两个默认值写在 `scripts/common.sh`
（`OPENSSL_WARMUPS=1`、`PERF_REPS=5`）与 `fixtures/scenarios.json`，因为 `case.yaml` 的 schema
不接受采样字段；`PERF_REPS` 可整体覆盖（< 5 时脚本打印 WARNING 并照常采样本数，只用于链路自检，
正式口径固定 5）。`-seconds` 与 `-bytes` 不允许覆盖，保证跨架构、跨运行口径一致。

| 产物 | 内容 |
|---|---|
| `build_variant.json` | 版本、源码归档 SHA-256、二进制 SHA-256、编译器与生效宏、容器镜像 |
| `raw-output.log` | 全部场景、全部轮次的 `openssl speed` 原始标准输出（按场景与轮次分段） |
| `runs/<scenario>/rep<i>.log`、`rep<i>.err`、`rep<i>.json` | 每次采样的原始输出、标准错误与解析后的样本，不覆盖、不丢弃 |
| `speed_result.json` | 16 项指标、采样数、中位数与原始值；`case.yaml` 的 `metrics.source` |
| `test.log`、`test_summary.json` | 校验阶段 `make test` 的完整输出与解析结果（文件数、测试数、PASS/FAIL） |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

解析严格性：每个场景每轮必须恰好有一条匹配的 `+DT`/`+DTP` 头（名称、秒数、块大小或位长都要
对得上）、一条 `+R`（非对称场景两条：签名与验签各一条）、一条匹配的 `+F`，进程退出码 0，
所有数值是有限正数，且 `ops/s` 与 `B/s` 的一致性校验通过；缺场景、多场景、重复指标、头不匹配、
数值非正或自相矛盾、日志缺失，任一情况都让测试失败。解析器绝不补零、不降级，失败时保留全部
原始输出以便定位。

## 独立运行

在已安装 Docker、且具备离线目录或网络代理的 Runner 上，从仓库根目录执行：

```bash
bash software/Toolchain/openssl/openssl_test.sh \
  --version 4.1.0 \
  --variant base \
  --results-dir /home/runner/openssl-results/4.1.0
```

内部实际执行的命令展开如下（与 Framework 六阶段完全一致，只是路径来自参数）：

```bash
docker run --detach --name "${OPENSSL_CONTAINER_NAME}" \
  --label "boostkit.openssl.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  "${OPENSSL_CONTAINER_IMAGE}" sleep infinity
docker exec "${OPENSSL_CONTAINER_NAME}" dnf install -y --setopt=install_weak_deps=False \
  perl perl-Test-Simple perl-Time-HiRes make gcc gawk \
  tar gzip diffutils findutils which coreutils
docker exec --workdir "${PERF_WORK_DIR}/openssl-4.1.0" "${OPENSSL_CONTAINER_NAME}" \
  ./Configure no-shared --prefix="${PERF_WORK_DIR}/install-base" \
  --openssldir="${PERF_WORK_DIR}/install-base/ssl"
docker exec --workdir "${PERF_WORK_DIR}/openssl-4.1.0" "${OPENSSL_CONTAINER_NAME}" make -j"$(nproc)"
docker exec --workdir "${PERF_WORK_DIR}/openssl-4.1.0" "${OPENSSL_CONTAINER_NAME}" make install_sw
docker exec "${OPENSSL_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/install-base/bin/openssl" speed -mr -seconds 2 -bytes 16384 -evp aes-128-gcm \
  > "${RESULTS_DIR}/runs/aes_128_gcm/rep1.log" 2> "${RESULTS_DIR}/runs/aes_128_gcm/rep1.err"
docker exec --workdir "${PERF_WORK_DIR}/openssl-4.1.0" "${OPENSSL_CONTAINER_NAME}" \
  env HARNESS_JOBS=8 make test > "${RESULTS_DIR}/test.log" 2>&1
python3 software/Toolchain/openssl/scripts/results/parse_speed.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --version 4.1.0 --architecture "$(uname -m)" --variant base --run-id "${PERF_RUN_ID}"
docker rm -f "${OPENSSL_CONTAINER_NAME}"
```

`parse_speed.py` 的 `--fixtures`、`--warmups`、`--reps` 都有默认值（取 `fixtures/scenarios.json` 与
`PERF_REPS`），因此上面的命令可以直接运行；需要显式覆盖时再传。`-mr` 的 `+DT`/`+DTP`/`+R` 行在
stderr、`+H`/`+F` 在 stdout，解析器两份都读，所以每轮必须同时保留 `rep<i>.log` 与 `rep<i>.err`。

入口同样支持 `--keep-workdir` 保留本次私有目录以便排查；`--variant` 只接受 `base` 与
`optimized`，其他取值在参数解析阶段返回 10；`optimized` 在构建阶段返回 30（见「已知限制」）。
结果落在 `--results-dir` 下，不更新基线。

- **脚本出处**：`openssl_test.sh`、`scripts/results/standalone_runtime.py`。

### 与整机直跑的差异

- **配额**：容器不设 CPU、内存、NUMA 限制，也不绑核，与整机直跑（默认调度）在资源维度一致；
  `openssl speed` 是单线程、CPU 时间计时的微基准，容器开销对绝对值的影响在噪声量级。
- **网络**：容器使用宿主网络，但测量阶段完全离线（`speed` 不联网，`make test` 只在本机回环
  地址上建立进程内连接）；只有构建阶段访问 openEuler 镜像源与 GitHub 归档。
- **客户端位置**：没有独立客户端。`openssl speed` 是单进程基准，`make test` 里涉及 TLS/QUIC
  的用例使用进程内回环连接，都不依赖外部服务或对端机器。

## 已知限制

- **不绑核、不设配额**：与仓库 `jemalloc`、`libavif` 用例一致。Kunpeng 机型核数多，单线程
  `speed` 的值主要由单核频率与微架构决定，因此跨架构只配对同名同参数的指标，不把核数差异
  折算进结果。
- **`optimized` 未实现**：OpenSSL 没有对应的 BoostKit 优化版补丁，本用例不为凑变体而自造优化；
  选择 `optimized` 时构建阶段**明确失败**（`return 30`）并提示只有 `base` 可用，**不退回基础版**。
- **`rsa2048` 单轮 20 s**：上游在 4.x 中把 raw RSA、KEM 与签名路径都放进 `rsa2048` 的计时块，
  共有 10 块；本用例只取其中的签名/验签两项，但没有裁剪上游的计时范围，因此该场景偏长。
- **单线程、CPU 时间**：没有加 `-multi`（多进程聚合吞吐）也没有加 `-elapsed`（墙钟），
  因此不度量多核扩展性；需要多核数据时应另开用例，而不是修改本用例口径。
- **覆盖面**：只度量摘要、AEAD 与三类签名；不覆盖 TLS 握手、kTLS、provider 加载、异步引擎
  （KAE 等硬件加速需要专用设备，Runner 上没有）。`make test` 中 9 个 external provider 用例
  因未启用 `enable-external-tests` 而 skip，属于上游默认行为。
- **构建占用**：OpenSSL 必须在源码树内构建，构建树约 2.0 GB（含测试二进制与对象文件），
  工作目录按 2.5 GB 预留；`--keep-workdir` 会保留整棵树。
- **版本口径**：固定到上游 tag `openssl-4.1.0`（commit `2f4e3a5f…`），不叠加 openEuler 发行版
  补丁，因此结果可与上游官方归档逐字节对得上；发行版自带 openssl（如 3.0.x）的数字不能直接比较。

## 与参考材料的关系

- 构建与测试方法完全来自上游 [INSTALL.md](https://github.com/openssl/openssl/blob/openssl-4.1.0/INSTALL.md)：
  同一套 `./Configure` + `make` + `make test`（`test/run_tests.pl`）流程，同一批 Perl 依赖。
- 性能口径来自上游自带的 [`apps/speed.c`](https://github.com/openssl/openssl/blob/openssl-4.1.0/apps/speed.c)
  （`openssl speed`），没有自研 benchmark；`-mr` 机器可读格式也是上游为该工具提供的官方输出。
- 正确性门禁与上游 CI 一致：[`.github/workflows/ci.yml`](https://github.com/openssl/openssl/blob/openssl-4.1.0/.github/workflows/ci.yml)
  的各个构建 job 在编译完成后执行的正是 `make test`（经由 `.github/workflows/make-test`）。
- 与仓库内其它用例的差异：本用例没有 BoostKit 参考实现可对照（BoostKit 未发布 openssl 优化仓），
  因此不设 `optimized` 变体，也不引用任何 external patch；采样规模按本仓库契约取
  1 次预热 + 5 次采样、中位数上报，上游 CI 本身不做性能采样。
