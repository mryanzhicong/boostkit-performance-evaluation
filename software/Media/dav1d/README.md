# dav1d 1.5.4 AV1 解码性能测试

本用例在 x86_64、aarch64 上分别构建未经修改的上游 dav1d 1.5.4 和输入编码器
AOM 3.2.0，使用参考仓库 `Test/dav1d` 规定的 BQTerrace、messi 各 30 帧、
8-bit、QP32 素材，测量 16 帧级线程下 AV1 解码的毫秒/帧。构建、输入生成和
正式测试都在本次任务的 openEuler 24.03 LTS SP4 私有容器内执行。核对的参考
仓库提交为 `21154155f56328b708e2c78f4ce6bac08101fe68`。

软件入口为 `dav1d_test.sh`。Framework 通过 `case.yaml` 调用
`build → start → test → stop`；独立入口调用同一组函数。`scripts/builders/base.sh`
完成基础版构建，`scripts/stages/` 负责容器校验、输入准备、正式测试和清理，
`scripts/results/` 负责原始证据与指标转换。`optimized` 构建入口尚未实现，
选中后在构建阶段明确失败，不会退回基础版。

> 本用例是参考脚本的框架化移植：**源码、编译参数、AOM 输入编码命令、dav1d
> 解码命令和计时口径逐项保留，但驱动脚本不是逐字执行原 `run_bench.sh`**。
> 具体差异见“与参考脚本的差异”。

## 软件与测试工具

| 项目 | 来源与版本 | 预置归档（Runner 上的文件） | 解包/构建位置 |
|---|---|---|---|
| dav1d | [上游 1.5.4 源码归档](https://download.videolan.org/pub/videolan/dav1d/1.5.4/dav1d-1.5.4.tar.xz)，SHA-256 `686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5` | `/home/runner/software/dav1d/dav1d-1.5.4.tar.xz` | `${PERF_WORK_DIR}/sources/dav1d-1.5.4` |
| AOM | [boostkit/libavif 仓库](https://gitcode.com/boostkit/libavif) **根目录**的 `aom-3.2.0.tar.gz`，SHA-256 `34132ae827c469a223fe5fbb0e42ac342539649cf2b97764c9912d7333d79169` | `/home/runner/software/dav1d/aom-3.2.0.tar.gz` | `${PERF_WORK_DIR}/sources/aom-3.2.0` |
| 基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/) | `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz` 及同名 `.sha256sum` | `docker load` 后的镜像 |
| 测试输入 | `BQTerrace_1920x1080_60-dianbo.yuv`、`messi_1920x1080_25_1000.yuv` | `/home/runner/software/dav1d/video/` | 容器内同绝对路径 |
| Meson / Ninja | PyPI `meson==1.8.5`、`ninja==1.13.0` | 运行时从 PyPI 安装到 `${PERF_WORK_DIR}/meson` | 私有前缀 |

两个源码归档优先从 `/home/runner/software/dav1d/` 读取；dav1d 缺失时从
videolan 下载；AOM 缺失时从 `https://gitcode.com/boostkit/libavif.git`
浅克隆并复制 `aom-3.2.0.tar.gz`。无论来源都校验上表固定的 SHA-256，校验失败
立即停止。归档是 Runner 上的输入文件，不在 Git 仓库中；上表最后一列是解包后的
源码/构建位置，不是归档文件本身。可用 `DAV1D_ARCHIVE_DIR` 指定其他预置目录。

### 源码归档获取

dav1d 直接从 videolan 下载：

```bash
curl -fL -o dav1d-1.5.4.tar.xz \
  https://download.videolan.org/pub/videolan/dav1d/1.5.4/dav1d-1.5.4.tar.xz
sha256sum dav1d-1.5.4.tar.xz
# 686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5
```

AOM 归档位于 **boostkit/libavif 仓库根目录**，文件名 `aom-3.2.0.tar.gz`：

```bash
git clone --depth 1 https://gitcode.com/boostkit/libavif.git
ls -l libavif/aom-3.2.0.tar.gz
sha256sum libavif/aom-3.2.0.tar.gz
# 34132ae827c469a223fe5fbb0e42ac342539649cf2b97764c9912d7333d79169
```

预置到 Runner 时：

```bash
mkdir -p /home/runner/software/dav1d
cp libavif/aom-3.2.0.tar.gz /home/runner/software/dav1d/
sha256sum -c <<'EOF'
34132ae827c469a223fe5fbb0e42ac342539649cf2b97764c9912d7333d79169  /home/runner/software/dav1d/aom-3.2.0.tar.gz
EOF
```

GitCode 的 `.../raw/main/aom-3.2.0.tar.gz` 我们实测返回的是 HTML 页面，不是
文件本体，因此脚本使用“浅克隆后复制”，与参考仓库 `build_install.sh` 一致。
本机测试时把它放在 `$WORK_ROOT/archives/aom-3.2.0.tar.gz`，不要写入仓库。

## 容器与构建

脚本先检查 Docker daemon。镜像归档和同名 `.sha256sum` 优先取
`/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时才下载；随后校验
SHA-256、`docker load`，并核对镜像架构和容器内 `/etc/os-release`。开发环境可用
`DAV1D_CONTAINER_IMAGE=<已有镜像>` 指定已加载镜像，脚本仍会核对架构和
openEuler 24.03 LTS SP4 版本。

每次运行创建一个带任务标签的容器，名称为
`boostkit-dav1d-<架构>-<运行 ID>`，标签为 `boostkit.dav1d.run-id=<运行 ID>`。
容器使用宿主网络，不绑核、不限制 CPU/内存/NUMA；工作目录、结果目录、只读的
用例脚本目录以及视频目录（存在时）挂载到容器内相同绝对路径：

```bash
docker run --detach --name "${DAV1D_CONTAINER_NAME}" \
  --label "boostkit.dav1d.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount "type=bind,source=${DAV1D_VIDEO_DIR},target=${DAV1D_VIDEO_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${DAV1D_CONTAINER_IMAGE}" sleep infinity
```

正式工作流设置 `PERF_PROXY` 时，脚本把 `/home/runner/software/anchors/`
只读挂到容器 CA 目录并执行 `update-ca-trust extract`，只在本次容器内把
openEuler 仓库地址换成 `repo.huaweicloud.com/openeuler`，再用 `dnf` 安装
`gcc gcc-c++ make cmake python3 python3-pip pkgconf-pkg-config tar gzip xz git curl`，
x86_64 额外安装 `nasm`。没有代理时不挂载证书目录，也不执行证书更新；容器内
仓库地址仍按上述镜像策略替换。

Meson/Ninja 按参考脚本固定版本安装到私有前缀：

```bash
python3 -m pip install --prefix "${PERF_WORK_DIR}/meson" \
  --index-url https://mirrors.huaweicloud.com/repository/pypi/simple \
  "meson==1.8.5" "ninja==1.13.0"
```

dav1d 使用 Meson 构建：

```bash
python3 -m mesonbuild.mesonmain setup build \
  --prefix "$src/install" --libdir lib --buildtype release \
  -Dc_args=-ffp-contract=off -Denable_asm=true -Denable_tools=true \
  -Denable_tests=false -Dtestdata_tests=false
python3 -m mesonbuild.mesonmain compile -C build -j 8
python3 -m mesonbuild.mesonmain install -C build
```

AOM 只用于生成输入，按参考脚本使用通用 C、关闭运行时 SIMD 检测、单线程编码：

```bash
cmake -S . -B build-generic -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DAOM_TARGET_CPU=generic -DCONFIG_RUNTIME_CPU_DETECT=0 \
  -DENABLE_TESTS=OFF -DENABLE_DOCS=OFF -DENABLE_EXAMPLES=ON \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_C_FLAGS="-O2 -fno-fast-math -ffp-contract=off -fno-tree-vectorize -fPIC" \
  -DCMAKE_CXX_FLAGS="-O2 -fno-fast-math -ffp-contract=off -fno-tree-vectorize -fPIC"
cmake --build build-generic --target aomenc aomdec --parallel 8
```

不修改 dav1d 源码、不打算法补丁、不使用 OpenMP，保留原生 x86/ARM SIMD。
构建后在容器内执行 `dav1d --version`，实际版本必须为 `1.5.4` 并写入
`PERF_ACTUAL_VERSION_FILE`。

## 数据与运行顺序

两台 Runner 必须预置同一份 1920×1080、8-bit YUV420P 素材，至少包含 30 个
完整帧：

```text
/home/runner/software/dav1d/video/BQTerrace_1920x1080_60-dianbo.yuv
/home/runner/software/dav1d/video/messi_1920x1080_25_1000.yuv
```

参考数据校验值（与 x264 历史正式结果一致）：

| 文件 | 字节数 | 帧数 | SHA-256 |
|---|---:|---:|---|
| `BQTerrace_1920x1080_60-dianbo.yuv` | 1,866,240,000 | 600 | `5677e7ef3806d99d899d80157d69a1b875d99b089ce62a781c4f2ac6ea4d07a7` |
| `messi_1920x1080_25_1000.yuv` | 3,110,400,000 | 1000 | `1097fcd4c6590e9affa93be5ed0b679f4d8c1366bdfa29381fa594f54b253c1b` |

脚本不生成或下载视频。源文件 SHA-256 写入结果 `parameters`，跨架构比较要求
内容一致。开发时可把测试文件放在其他目录并用 `--video-dir` 或
`DAV1D_VIDEO_DIR` 指定；正式流水线使用上述默认路径。

1. `build`：准备镜像、创建唯一容器、安装依赖、在容器内构建 dav1d 和 AOM。
2. `start`：校验两个可执行文件、素材长度；在容器内用 AOM 编码两段素材的前
   30 帧为 `BQTerrace-30.ivf`、`messi-30.ivf`，记录源文件和码流 SHA-256。
   编码不计时；同一任务内校验通过后复用。
3. `test`：重新校验输入后，对两个视频各做 1 次预热解码，确认输出恰好为
   30 帧（93,312,000 字节）并记录输出 SHA-256；随后各计时 20 次。
4. `stop`：保存容器日志，只停止并删除带本次任务标签的容器。

AOM 输入编码命令固定为单线程、通用 C 构建，编码参数与参考脚本一致：

```bash
aomenc --codec=av1 --good --cpu-used=8 --passes=1 --threads=1 --row-mt=0 \
  --tile-columns=1 --end-usage=q --cq-level=32 --limit=30 \
  --width=1920 --height=1080 --fps=<60|25>/1 \
  --input-bit-depth=8 --bit-depth=8 --ivf -o <output.ivf> <source.yuv>
```

编码器在可写输出目录中运行（`cwd=<media>`），避免 `aomenc`/`dav1d` 的
sidecar 文件落到只读工作目录。

预热的解码命令为：

```bash
dav1d --input <stream.ivf> --threads 16 --framedelay 0 --filmgrain 1 --quiet \
  --muxer yuv --output <output.yuv>
```

正式计时把 muxer 改为 `null`、输出改为 `/dev/null`：

```bash
dav1d --input <stream.ivf> --threads 16 --framedelay 0 --filmgrain 1 --quiet \
  --muxer null --output /dev/null
```

计时口径与参考脚本一致：从启动解码进程到进程退出（含读取、解码和输出），
用完整命令耗时除以 30 帧得到 `ms/frame`，每个视频取 20 次样本的算术平均。
不设置 CPU 亲和性或 NUMA 绑定；两架构使用相同的线程数、码流参数和轮次。

## 指标与产物

| 场景 | 指标 | 来源 | 单位 | 方向 | 分组 |
|---|---|---|---|---|---|
| BQTerrace，16 帧级线程 | 每帧解码耗时 | 20 次计时的平均值 | ms/frame | 越小越好 | BQTerrace |
| messi，16 帧级线程 | 每帧解码耗时 | 20 次计时的平均值 | ms/frame | 越小越好 | messi |

共两个指标。16 线程是参考脚本的固定负载，不是机器相关参数；实际核数只记录在
结果 `runtime_context`。每个视频恰好需要 1 次预热和 20 次正式计时；缺失场景、
样本数不足、非有限或非正数值、码流/输出校验不一致、CSV 与原始证据不符都会让
测试失败。

指标盘点：每个场景纳入报告的是 20 次样本的算术平均 `ms_per_frame`；20 个原始
样本、中位数、最小值、最大值、样本标准差、预热耗时、命令和输入/输出 SHA-256
仅保留在 `decode_evidence/`；输入编码耗时和预热耗时不计入正式指标；实际核数、
CPU 型号和生成码流的 SHA-256 只写入 `runtime_context`，不参与跨架构负载配对。

| 产物 | 内容 |
|---|---|
| `benchmark_raw.log` | 正式测试的完整控制台输出 |
| `result_bench-dav1d.csv` | 与参考脚本相同的 `scenario,frames,ms_per_frame,status` 两行结果 |
| `decode_evidence/BQTerrace/`、`messi/` | 每个场景的预热/计时日志、命令、输出 SHA-256 和 20 个样本 |
| `decode_evidence/evidence.json` | 输入清单、参数、场景证据和运行环境 |
| `input_prepare/` | AOM 生成输入码流的日志 |
| `benchmark_dav1d.json` | 经 CSV 与证据校验后供 Framework 读取的两个指标及负载参数 |
| `container_runtime.log` | 停止阶段保存的容器日志 |

预热产生的解码 YUV 只写入本次任务私有目录，校验后删除；正式计时的解码输出
直接写入 `/dev/null`。

脱离 Workflow 执行完整流程：

```bash
bash software/Media/dav1d/dav1d_test.sh \
  --version 1.5.4 \
  --variant base \
  --results-dir /home/runner/dav1d-results/1.5.4
```

素材不在默认目录时可加：

```bash
bash software/Media/dav1d/dav1d_test.sh --version 1.5.4 \
  --video-dir /path/to/dav1d-video \
  --results-dir /home/runner/dav1d-results/1.5.4
```

独立运行默认清理自身创建的私有工作目录；需要保留现场时加 `--keep-workdir`。
Framework 分阶段运行时，输出写入传入的 `RESULTS_DIR`，源码、构建产物、码流和
预热输出写入传入的 `PERF_WORK_DIR`。

## 与参考脚本的差异

- 参考脚本在宿主机直接安装依赖并构建；本用例把依赖、两个软件的构建、输入
  编码和全部解码计时放进同一个私有容器，宿主机只执行 Docker、下载和解析。
- 参考脚本使用 `/home/test/Test/video`；本用例按 Runner 约定读取
  `/home/runner/software/dav1d/video`，并允许开发时用环境变量或
  `--video-dir` 覆盖。
- 参考脚本使用 `software/downloads` 和 `.bench-ready` 跨次复用；本用例每次
  任务使用私有目录重新构建，不复用半成品，避免不同任务/架构互相污染。
- 参考脚本通过 `bootstrap_env.sh` 在宿主机安装 Meson/Ninja；本用例在容器内用
  `pip --prefix` 安装固定版本，构建和测试使用 Runner UID。
- 参考脚本在脚本目录运行 AOM；本用例把编码器 cwd 设为可写媒体目录，避免
  sidecar 文件写入只读工作目录。
- 参考脚本以 root 运行；本用例的普通构建和测试使用 Runner 的 UID/GID，
  只有安装容器内 RPM 时使用容器 root。
- 参考脚本直接打印 CSV；本用例除保留同一 CSV 外，还保存每个场景的命令、
  日志和输出校验值，并由独立解析器核对后生成 Framework 指标。
