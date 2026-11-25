# rapidjson 1.1.0 性能测试

本用例在 x86_64、aarch64 上分别构建 RapidJSON 的两个变体：上游原版（commit
`24b5e7a8b27f42fa16b96fc70aade9106cf7102f`，源码内 `RAPIDJSON_VERSION_STRING` 为 1.1.0），以及在同一
份源码上应用 BoostKit Kunpeng 优化补丁 `kunpeng_opti_v1.0.0.patch` 后的 Kunpeng 优化版（BoostKit
26.1.RC1 发布的 rapidjson v1.0.0）。两个变体都只构建上游自带的 GoogleTest 测试套件与
`test/perftest` 性能套件，性能指标全部来自 `perftest` 可执行文件中的 `RapidJson.*` 用例，不额外
编写替代基准程序。

构建与测量都在本次任务专属的 openEuler 24.03 LTS SP4 私有容器内执行；容器使用宿主网络，
**不限制 CPU、内存或 NUMA**，测量进程不绑核，也不设 NUMA 亲和。Framework 按 `case.yaml` 依次
调用构建、启动校验、测试、校验与停止函数；软件入口为 `rapidjson_test.sh`，独立入口复用同一组
阶段函数。

`base` 变体按上游默认 Release 口径构建：不应用补丁，只加 `-O3`（`perftest` 的测试文件本身按编译器
预定义宏自动选用上游的 SSE2/SSE4.2/NEON 实现）。`optimized` 变体应用 Kunpeng 补丁，并在 aarch64 上
追加 `-march=armv8.2-a+simd -DRAPIDJSON_NEON`，打开补丁新增的「UTF-8 内存流字符串扫描快速路径」
（`reader.h`）与「`Writer<StringBuffer>::WriteString` 字符串写出快速路径」（`writer.h`）。两个变体的
指标名称、语料与迭代次数完全相同，可直接配对比较。

## 软件与测试工具

| 项目 | 来源与版本 | 本次任务内的位置 |
|---|---|---|
| rapidjson（被测软件） | 上游 `Tencent/rapidjson` commit `24b5e7a8b27f42fa16b96fc70aade9106cf7102f`（`RAPIDJSON_VERSION_STRING` = 1.1.0，无对应 tag），官方归档 `rapidjson-1.1.0.tar.gz`，1,116,703 字节，SHA-256 `2d2601a82d2d3b7e143a3c8d43ef616671391034bc46891a9816b79cf2d3e7a8` | 优先读取公共离线目录 `/home/runner/software/rapidjson/`，缺失时下载到 `${PERF_WORK_DIR}/downloads/`；容器内解压为 `${PERF_WORK_DIR}/rapidjson-1.1.0`（base）与 `${PERF_WORK_DIR}/rapidjson-1.1.0-opt`（optimized） |
| BoostKit Kunpeng 优化补丁 | `boostkit/rapidjson` master（commit `68f72c2841095c84976b381986c2b4299127a58d`）的 `kunpeng_opti_v1.0.0.patch`，12,053 字节，SHA-256 `748f35b0a78feaa2b80ae8dc6852796611d51528ca5082cf0d595cf2e347ddba`；只修改 `include/rapidjson/reader.h`、`include/rapidjson/writer.h` | 随用例存放在 `fixtures/kunpeng_opti_v1.0.0.patch`（只读挂载），只在 `optimized` 变体应用 |
| GoogleTest | 上游 tag `release-1.12.1` 源码归档 `googletest-release-1.12.1.tar.gz`，854,944 字节，SHA-256 `81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2`；`perftest` 与 `unittest` 的测试框架 | 同一离线目录；容器内解压到源码树 `thirdparty/gtest/`，由 rapidjson 自己的 `FindGTestSrc` 找到 |
| 官方测试语料 | 随源码归档提供，`bin/data/sample.json`（687,491 字节，SHA-256 `9a56aaca1ad7363e1c7852ad12a336980e789db91bd9aabad64eea702320ab6f`）与 `bin/types/paragraphs.json`（33,764 字节，SHA-256 `2a37599db74922aae1e7bcd692751660d3a3fea4ae8dd13c99d1c3063585c1a5`） | 解压后位于 `${PERF_WORK_DIR}/rapidjson-1.1.0/bin/`，`perftest` 以该目录为工作目录读取 |
| 容器基础镜像 | [openEuler 24.03 LTS SP4 官方 Docker 归档](https://repo.openeuler.org/openEuler-24.03-LTS-SP4/docker_img/)，按架构取 `openEuler-docker.<arch>.tar.xz`，同目录 `.sha256sum` 校验 | 优先读取公共目录 `/home/runner/software/openEuler-24.03-LTS-SP4/`，缺失时下载到 `${PERF_WORK_DIR}`；校验 SHA-256 后 `docker load` |
| 容器内构建依赖 | `cmake`(≥3.13)、`gcc`、`gcc-c++`、`make`、`tar`、`gzip`、`patch`、`findutils`、`which`、`coreutils`、`python3` | 全部在容器内用 `dnf` 安装，不向宿主机安装 |

源码归档、补丁、GoogleTest 归档在两架构上完全相同，因此校验值表只有一组；只有基础镜像按架构
各自取归档。补丁随用例入库（12 KB），Blue 的 aarch64 Runner 不需要访问 gitcode。

## rapidjson 获取、构建与容器启动

脚本先确认 Docker daemon 可用（`docker info` 失败时构建阶段返回 30，并提示先启动 daemon）。
基础镜像归档 `openEuler-docker.<arch>.tar.xz` 与同名 `.sha256sum` 优先取上表的公共目录，缺失时才
从官方地址下载；校验后 `docker load`，再核对镜像架构与容器内发行版（以下是实际命令形态）：

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
docker run --rm --network=none "${RAPIDJSON_CONTAINER_IMAGE}" cat /etc/os-release
```

`/etc/os-release` 的 `VERSION_ID` 必须是 `24.03`，镜像架构必须是 `x86_64`→`amd64`、
`aarch64`→`arm64`；本用例不访问 Docker Hub。

每次构建使用容器 `boostkit-rapidjson-<架构>-<运行 ID>`，以 Runner 的 UID/GID 运行，把工作目录、
结果目录按原路径挂载进去，用例目录按只读方式挂载（供读取 `fixtures/` 下的补丁与场景清单）：

```bash
docker run --detach --name "${RAPIDJSON_CONTAINER_NAME}" \
  --label "boostkit.rapidjson.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  --mount "type=bind,source=${RESULTS_DIR},target=${RESULTS_DIR}" \
  --mount "type=bind,source=${SCRIPT_DIR},target=${SCRIPT_DIR},readonly" \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  "${RAPIDJSON_CONTAINER_IMAGE}" sleep infinity
```

容器内先安装依赖；正式工作流设置 `PERF_PROXY` 时，还会把 `/home/runner/software/anchors/` 只读挂到
`/etc/pki/ca-trust/source/anchors/`，在容器内执行 `update-ca-trust extract`，再把 openEuler 仓库地址
改为 `repo.huaweicloud.com/openeuler`。未设置代理时不挂载证书、不改仓库地址：

```bash
dnf install -y --setopt=install_weak_deps=False \
  cmake gcc gcc-c++ make tar gzip patch findutils which coreutils python3
```

源码与 GoogleTest 按「公共离线目录 → 本次工作目录 → 官方地址」的顺序获取，两份归档都强制校验
SHA-256；补丁直接取用例目录下已入库的副本并校验其 SHA-256。离线目录缺失且下载不可用时构建阶段
返回 30，不会跳过校验继续构建（以下是实际命令形态）：

```bash
OFFLINE="/home/runner/software/rapidjson"
mkdir -p "${PERF_WORK_DIR}/downloads"
for name in rapidjson-1.1.0.tar.gz googletest-release-1.12.1.tar.gz; do
  if [ -s "${OFFLINE}/${name}" ]; then
    cp -f "${OFFLINE}/${name}" "${PERF_WORK_DIR}/downloads/${name}"
  else
    case "${name}" in
      rapidjson-1.1.0.tar.gz)
        url="https://codeload.github.com/Tencent/rapidjson/tar.gz/24b5e7a8b27f42fa16b96fc70aade9106cf7102f" ;;
      googletest-release-1.12.1.tar.gz)
        url="https://codeload.github.com/google/googletest/tar.gz/refs/tags/release-1.12.1" ;;
    esac
    curl -fSL --retry 3 --connect-timeout 30 -o "${PERF_WORK_DIR}/downloads/${name}.part" "${url}"
    mv "${PERF_WORK_DIR}/downloads/${name}.part" "${PERF_WORK_DIR}/downloads/${name}"
  fi
done
check() { printf '%s  %s\n' "$2" "$1" | sha256sum -c -; }
check "${PERF_WORK_DIR}/downloads/rapidjson-1.1.0.tar.gz" \
  2d2601a82d2d3b7e143a3c8d43ef616671391034bc46891a9816b79cf2d3e7a8
check "${PERF_WORK_DIR}/downloads/googletest-release-1.12.1.tar.gz" \
  81964fe578e9bd7c94dfdb09c8e4d6e6759e19967e397dbea48d1c10e45d0df2
check "${SCRIPT_DIR}/fixtures/kunpeng_opti_v1.0.0.patch" \
  748f35b0a78feaa2b80ae8dc6852796611d51528ca5082cf0d595cf2e347ddba
tar xzf "${PERF_WORK_DIR}/downloads/rapidjson-1.1.0.tar.gz" -C "${PERF_WORK_DIR}"
mv "${PERF_WORK_DIR}/rapidjson-24b5e7a8b27f42fa16b96fc70aade9106cf7102f" "${PERF_WORK_DIR}/rapidjson-1.1.0"
cp -a "${PERF_WORK_DIR}/rapidjson-1.1.0" "${PERF_WORK_DIR}/rapidjson-1.1.0-opt"
for src in "${PERF_WORK_DIR}/rapidjson-1.1.0" "${PERF_WORK_DIR}/rapidjson-1.1.0-opt"; do
  mkdir -p "${src}/thirdparty/gtest"
  tar xzf "${PERF_WORK_DIR}/downloads/googletest-release-1.12.1.tar.gz" \
    -C "${src}/thirdparty/gtest" --strip-components=1
done
```

`optimized` 的源码树只在副本上打补丁，`base` 的源码树保持上游原样（以下是实际命令形态）：

```bash
cd "${PERF_WORK_DIR}/rapidjson-1.1.0-opt"
patch -p1 --forward --no-backup-if-mismatch < "${SCRIPT_DIR}/fixtures/kunpeng_opti_v1.0.0.patch"
grep -q "ScanCopyUnescapedString(EncodedInputStream<UTF8<>, MemoryStream>&" include/rapidjson/reader.h
grep -q "Writer<StringBuffer>::WriteString" include/rapidjson/writer.h
```

构建使用 rapidjson 自己的 `CMakeLists.txt`，与 BoostKit 安装指南相同的 `Release` + `-O3` 口径，并
打开上游测试/性能套件。三个与本用例相关、必须显式给出的 CMake 参数是：`GOOGLETEST_VERSION`
（rapidjson 的 `FindGTestSrc` 直接 `add_subdirectory` 到 `thirdparty/gtest/googletest`，缺省时
googletest 的 CMake 因版本号为空而报错）、`RAPIDJSON_BUILD_DOC=OFF`（文档依赖 doxygen）与
`RAPIDJSON_BUILD_THIRDPARTY_GTEST=ON`（使用源码树内的 GoogleTest）。另外把 `-Wno-error` 放进
`CMAKE_CXX_FLAGS_RELEASE`，让它出现在 rapidjson 追加的 `-Werror` 之后：gcc ≥ 11 会对上游未改动的
`test/unittest/itoatest.cpp`、`uritest.cpp` 报 `stringop-overflow`/`array-bounds` 误报，`-Werror`
下 `unittest` 无法编译；只把警告降级为提示，`-Wall -Wextra` 仍开启，源码与 `-O3` 都不动（写成
`-Wno-error=xxx` 放在 `CMAKE_CXX_FLAGS` 里会被后面的 `-Werror` 覆盖，实测无效）：

```bash
ARCH="$(uname -m)"
for variant in base optimized; do
  src="${PERF_WORK_DIR}/rapidjson-1.1.0"
  [ "${variant}" = "optimized" ] && src="${PERF_WORK_DIR}/rapidjson-1.1.0-opt"
  extra=""
  if [ "${variant}" = "optimized" ] && [ "${ARCH}" = "aarch64" ]; then
    extra=" -march=armv8.2-a+simd -DRAPIDJSON_NEON"
  fi
  cmake -S "${src}" -B "${PERF_WORK_DIR}/build-${variant}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_FLAGS="-O3" \
    -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -Wno-error${extra}" \
    -DGOOGLETEST_VERSION=1.12.1 \
    -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF \
    -DRAPIDJSON_BUILD_TESTS=ON -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=ON
  cmake --build "${PERF_WORK_DIR}/build-${variant}" -j "$(nproc)" --target perftest unittest
done
```

上游 CMake 在该配置下还会向 `CMAKE_CXX_FLAGS` 追加 `-march=native`（`RAPIDJSON_ENABLE_INSTRUMENTATION_OPT`
默认 ON），Kunpeng 上不低于 `armv8.2-a+simd`，因此 `optimized` 的 `-DRAPIDJSON_NEON` 与补丁的 NEON
分支在两个架构上都按预期生效（x86_64 上补丁的 SSE 分支由 `perftest` 的 `RAPIDJSON_SSE42/SSE2` 宏
启用）。构建后核对两个可执行文件存在，并用一个最小用例做冒烟：要求退出码 0、XML 中恰好一个
`testcase` 且无 `failure`，否则构建阶段失败、不进入测量：

```bash
cd "${PERF_WORK_DIR}/rapidjson-1.1.0/bin"
"${PERF_WORK_DIR}/build-base/bin/perftest" \
  --gtest_filter='RapidJson.DocumentParse_MemoryPoolAllocator_SSE2:RapidJson.DocumentParse_MemoryPoolAllocator_SSE42:RapidJson.DocumentParse_MemoryPoolAllocator_NEON' \
  --gtest_repeat=1 --gtest_output=xml:"${PERF_WORK_DIR}/smoke.xml"
```

构建完成后把实际版本、四份来源（源码归档、补丁、GoogleTest、基础镜像）的 SHA-256、本次构建变体的
`perftest`/`unittest` 二进制 SHA-256、编译器标识、实际生效的编译宏写入 `build_variant.json`
（框架一次只构建一个变体，所以每个 `build_variant.json` 只描述本次变体的二进制），
并保留同一个容器供测试与校验阶段复用。**宿主机只做下载、SHA-256 校验、Docker 调用和结果解析**；
不向宿主机安装任何软件包，也不修改宿主机的镜像源、信任库或系统配置。受限网络下可用
`RAPIDJSON_DOCKER_EXTRA_ARGS` 追加 `docker run` 参数（例如 `--add-host` 指定内网镜像地址）；
Blue 的 aarch64 Runner 使用默认镜像源，不需要该变量。

- **脚本出处**：`scripts/common.sh`、`scripts/builders/dispatch.sh`、`scripts/builders/base.sh`、
  `scripts/builders/optimized.sh`、`fixtures/kunpeng_opti_v1.0.0.patch`、`fixtures/scenarios.json`。

## 数据与运行顺序

测试数据全部来自已校验的上游源码归档，不额外引入数据集，也不写 `$HOME`：

| 文件 | 字节 | SHA-256 | 用途 |
|---|---|---|---|
| `bin/data/sample.json` | 687,491 | `9a56aaca1ad7363e1c7852ad12a336980e789db91bd9aabad64eea702320ab6f` | 6 个整文件场景的输入（DOM 解析、SAX 解析、写出、美化写出） |
| `bin/types/paragraphs.json` | 33,764 | `2a37599db74922aae1e7bcd692751660d3a3fea4ae8dd13c99d1c3063585c1a5` | 长字符串密集的解析与写出场景（补丁的两条快速路径都以字符串扫描为主） |

执行顺序固定为：

1. **启动校验**：确认容器仍在运行、`boostkit.rapidjson.run-id` 标签与本次运行 ID 一致，当前变体的
   `perftest`/`unittest`、语料文件与补丁副本都可读，工作目录剩余空间足够（框架每次 build 只构建
   调用方请求的那个变体，所以 `start` 只校验本变体的产物）。
2. **准备结果目录**：为 8 个场景各建 `runs/<scenario>/` 子目录，`runs/` 位于 `${RESULTS_DIR}` 下。
3. **预热 1 次**：按下面第 4 步的命令形态，对当前变体的 8 个场景各执行一遍，输出落到
   `runs/<scenario>/rep0.*`，只记录、不参与统计。
4. **正式采样 5 次**：每次采样都对 8 个场景各起一个独立进程（进程内 `--gtest_repeat=5`），标准输出
   落 `rep<i>.log`、标准错误落 `rep<i>.err`、gtest XML 落 `rep<i>.xml`；`i` 从 1 开始。gtest 在
   重复运行时每次迭代都会覆盖 XML，所以指标以标准输出里 5 行 `(<X> ms total)` 的累加为准，XML 只
   作为「最后一次迭代无失败」的证据（以下是实际命令形态）：

```bash
BIN="${PERF_WORK_DIR}/build-${PERF_VARIANT}/bin/perftest"
declare -A tests=(
  [dom_parse]=DocumentParse_MemoryPoolAllocator
  [dom_parse_insitu]=DocumentParseInsitu_MemoryPoolAllocator
  [dom_parse_encoded_stream]=DocumentParseEncodedInputStream_MemoryStream
  [sax_parse]=ReaderParse_DummyHandler
  [sax_parse_paragraphs]=ReaderParse_DummyHandler_Paragraphs
  [writer_string_buffer]=Writer_StringBuffer
  [writer_string_buffer_paragraphs]=Writer_StringBuffer_Paragraphs
  [pretty_writer_string_buffer]=PrettyWriter_StringBuffer
)
for scenario in "${!tests[@]}"; do
  filter="RapidJson.${tests[${scenario}]}_SSE2:RapidJson.${tests[${scenario}]}_SSE42:RapidJson.${tests[${scenario}]}_NEON"
  docker exec "${RAPIDJSON_CONTAINER_NAME}" mkdir -p "${RESULTS_DIR}/runs/${scenario}"
  docker exec --workdir "${PERF_WORK_DIR}/rapidjson-1.1.0/bin" "${RAPIDJSON_CONTAINER_NAME}" \
    "${BIN}" --gtest_filter="${filter}" --gtest_repeat=5 \
    --gtest_output=xml:"${RESULTS_DIR}/runs/${scenario}/rep${i}.xml" \
    > "${RESULTS_DIR}/runs/${scenario}/rep${i}.log" \
    2> "${RESULTS_DIR}/runs/${scenario}/rep${i}.err"
done
```

5. **严格解析**：宿主机执行解析命令，把 8 个场景每轮 5 行的耗时换算成 16 项指标与中位数
   （见「指标与产物」）。
6. **校验**：运行上游完整单元测试 `unittest`（与 BoostKit 安装指南的 `ctest` 同一套用例、同一
   二进制，x86_64 上为 469 个用例、34 个测试套件），退出码必须为 0 且无失败；该步骤不参与指标，
   只作为补丁正确性证据：

```bash
"${PERF_WORK_DIR}/build-${PERF_VARIANT}/bin/unittest" \
  --gtest_output=xml:"${RESULTS_DIR}/unittest.xml" > "${RESULTS_DIR}/unittest.log" 2>&1
ctest --test-dir "${PERF_WORK_DIR}/build-${PERF_VARIANT}" -R unittest --output-on-failure
```

7. **清理**：停止阶段按 `boostkit.rapidjson.run-id` 标签移除本次容器，保留结果目录；
   `--keep-workdir` 时保留工作目录。

| # | 场景 | 上游用例（去掉架构后缀） | 语料 | 每轮迭代次数 | `--gtest_repeat` | 每轮参考耗时 |
|---|---|---|---|---|---|---|
| 1 | `dom_parse` | `DocumentParse_MemoryPoolAllocator` | `sample.json` | 1,000 | 5 | 1.0 – 1.3 s |
| 2 | `dom_parse_insitu` | `DocumentParseInsitu_MemoryPoolAllocator` | `sample.json` | 1,000 | 5 | 1.0 – 1.2 s |
| 3 | `dom_parse_encoded_stream` | `DocumentParseEncodedInputStream_MemoryStream` | `sample.json` | 1,000 | 5 | 1.0 – 1.3 s |
| 4 | `sax_parse` | `ReaderParse_DummyHandler` | `sample.json` | 1,000 | 5 | 0.9 – 1.2 s |
| 5 | `sax_parse_paragraphs` | `ReaderParse_DummyHandler_Paragraphs` | `paragraphs.json` | 10,000 | 5 | 0.25 – 0.35 s |
| 6 | `writer_string_buffer` | `Writer_StringBuffer` | `sample.json` | 1,000 | 5 | 0.5 – 0.7 s |
| 7 | `writer_string_buffer_paragraphs` | `Writer_StringBuffer_Paragraphs` | `paragraphs.json` | 10,000 | 5 | 0.13 – 0.20 s |
| 8 | `pretty_writer_string_buffer` | `PrettyWriter_StringBuffer` | `sample.json` | 1,000 | 5 | 0.7 – 0.9 s |

两个架构使用**同一矩阵**、同一语料、同一迭代次数与重复次数，只有架构和运行位置不同。8 个场景
每轮合计约 6 s，1 次预热 + 5 次采样约 40 s（不含构建与单元测试）。工作目录约 150 MB（base 的两份
源码树与构建目录约 44 MB，optimized 打完补丁后再加一份约 44 MB，参考 x86_64 实测）；结果目录按
「每场景每轮一个 log + 一个 err + 一个 XML + 一个 JSON」估算不足 10 MB；磁盘不足时构建阶段先报错，
不进入测量。

## 指标与产物

| 报告分组 | 指标 | 来源 | 单位 | 方向 |
|---|---|---|---|---|
| `dom_parse` | `dom_parse_ns_per_op`、`dom_parse_gb_per_s` | `runs/dom_parse/rep<i>.log` 中 5 行 `[==========] 1 test from 1 test suite ran. (<X> ms total)` 的 X 之和（用例 `DocumentParse_MemoryPoolAllocator_<架构后缀>`，`--gtest_repeat=5`） | ns/op、GB/s | ns/op 越小越好；GB/s 越大越好 |
| `dom_parse_insitu` | `dom_parse_insitu_ns_per_op`、`dom_parse_insitu_gb_per_s` | 同上，用例名 `DocumentParseInsitu_MemoryPoolAllocator_<架构后缀>` | ns/op、GB/s | 同上 |
| `dom_parse_encoded_stream` | `dom_parse_encoded_stream_ns_per_op`、`dom_parse_encoded_stream_gb_per_s` | 同上，用例名 `DocumentParseEncodedInputStream_MemoryStream_<架构后缀>`（补丁的 UTF-8 内存流快速路径） | ns/op、GB/s | 同上 |
| `sax_parse` | `sax_parse_ns_per_op`、`sax_parse_gb_per_s` | 同上，用例名 `ReaderParse_DummyHandler_<架构后缀>` | ns/op、GB/s | 同上 |
| `sax_parse_paragraphs` | `sax_parse_paragraphs_ns_per_op`、`sax_parse_paragraphs_gb_per_s` | 同上，用例名 `ReaderParse_DummyHandler_Paragraphs_<架构后缀>` | ns/op、GB/s | 同上 |
| `writer_string_buffer` | `writer_string_buffer_ns_per_op`、`writer_string_buffer_gb_per_s` | 同上，用例名 `Writer_StringBuffer_<架构后缀>`（补丁的字符串写出快速路径） | ns/op、GB/s | 同上 |
| `writer_string_buffer_paragraphs` | `writer_string_buffer_paragraphs_ns_per_op`、`writer_string_buffer_paragraphs_gb_per_s` | 同上，用例名 `Writer_StringBuffer_Paragraphs_<架构后缀>` | ns/op、GB/s | 同上 |
| `pretty_writer_string_buffer` | `pretty_writer_string_buffer_ns_per_op`、`pretty_writer_string_buffer_gb_per_s` | 同上，用例名 `PrettyWriter_StringBuffer_<架构后缀>` | ns/op、GB/s | 同上 |

指标总数 **16 项** = 8 个场景 × 2 项。分组规则：按 8 个场景名分组（即 `runs/` 下的子目录名）；
每个场景内一项耗时（`ns/op`，越小越好）、一项吞吐（`GB/s`，越大越好）。换算只在解析阶段做：
设某轮 5 行耗时之和为 `ΣX`（毫秒）、该场景迭代数为 `I`、语料字节数为 `B`，则
`ns/op = ΣX × 1e6 / (5 × I)`，`GB/s = B × 5 × I × 1000 / (ΣX × 1e9)`。写出类场景的 `GB/s` 按
**输入 JSON 的字节数**折算（`sample.json` 687,491 字节、`paragraphs.json` 33,764 字节）；写出后的
字节数随场景与实现变化（美化写出会插入换行与缩进），因此不用输出长度做分母。架构后缀
（`_SSE2`/`_SSE42`/`_NEON`）由编译器宏决定，解析时校验后缀并去掉，作为跨架构稳定的指标名；
跨架构只配对同名同参数的指标。

每项指标取 5 次采样（每次采样是独立进程、进程内 5 次迭代）的中位数写入结果；全部 6 个样本
（含预热 `rep0`）保留在 `runs/` 下，供复核与后续统计。预热 1 次、测量 5 次这两个默认值写在
`scripts/common.sh`（`RAPIDJSON_WARMUPS=1`、`PERF_REPS=5`），因为 `case.yaml` 的 schema 不接受
采样字段；`PERF_REPS` 可整体覆盖，但必须 ≥ 5。

| 产物 | 内容 |
|---|---|
| `build_variant.json` | 变体、四份来源的 SHA-256、本次变体二进制 SHA-256、编译器与生效宏、容器镜像 |
| `raw-output.log` | 全部场景、全部轮次的 `perftest` 原始标准输出（按场景与轮次分段） |
| `runs/<scenario>/rep<i>.log`、`rep<i>.err`、`rep<i>.xml`、`rep<i>.json` | 每次采样的标准输出、标准错误、gtest XML 原始输出与解析后的样本，不覆盖、不丢弃；gtest 的 XML 在 `--gtest_repeat` 下每次迭代都会覆盖，因此 XML 里只有最后一次迭代，指标以 `rep<i>.log` 的 5 行耗时之和为准 |
| `perftest_result.json` | 16 项指标、采样数、中位数与原始值；`case.yaml` 的 `metrics.source` |
| `unittest.log`、`unittest.xml` | 校验阶段上游完整单元测试的原始输出（不参与指标） |
| `results.json`、`report.md` | 独立入口生成的结果与报告；流水线由 Framework 生成正式结果 |

解析严格性：每个场景每轮必须恰好 5 行 `[==========] 1 test from 1 test suite ran. (<X> ms total)`
（对应 `--gtest_repeat=5`）、进程退出码 0、日志中没有 `[  FAILED  ]`、XML 中恰好一个 `testcase` 且
`failures="0"`，每行 `X` 都是有限正整数；用例名去掉架构后缀后必须与 `fixtures/scenarios.json`
登记的清单一致；缺场景、多场景、重复指标、迭代数或语料字节数与清单不符、日志或 XML 缺失、
行数不是 5，任一情况都让测试失败。解析器绝不补零、不降级，失败时保留全部原始输出以便定位。

## 独立运行

在已安装 Docker、且具备离线目录或网络代理的 Runner 上，从仓库根目录执行：

```bash
bash software/HPC/rapidjson/rapidjson_test.sh \
  --version 1.1.0 \
  --variant base \
  --results-dir /home/runner/rapidjson-results/1.1.0
bash software/HPC/rapidjson/rapidjson_test.sh \
  --version 1.1.0 \
  --variant optimized \
  --results-dir /home/runner/rapidjson-results/1.1.0
```

内部实际执行的命令展开如下（与 Framework 六阶段完全一致，只是路径来自参数）：

```bash
docker run --detach --name "${RAPIDJSON_CONTAINER_NAME}" \
  --label "boostkit.rapidjson.run-id=${PERF_RUN_ID}" \
  --network=host --user "$(id -u):$(id -g)" \
  --mount "type=bind,source=${PERF_WORK_DIR},target=${PERF_WORK_DIR}" \
  "${RAPIDJSON_CONTAINER_IMAGE}" sleep infinity
docker exec "${RAPIDJSON_CONTAINER_NAME}" dnf install -y --setopt=install_weak_deps=False \
  cmake gcc gcc-c++ make tar gzip patch findutils which coreutils python3
docker exec "${RAPIDJSON_CONTAINER_NAME}" cmake -S "${PERF_WORK_DIR}/rapidjson-1.1.0-opt" \
  -B "${PERF_WORK_DIR}/build-optimized" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-O3" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O3 -DNDEBUG -Wno-error -march=armv8.2-a+simd -DRAPIDJSON_NEON" \
  -DGOOGLETEST_VERSION=1.12.1 -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF \
  -DRAPIDJSON_BUILD_TESTS=ON -DRAPIDJSON_BUILD_THIRDPARTY_GTEST=ON
docker exec --workdir "${PERF_WORK_DIR}/rapidjson-1.1.0/bin" "${RAPIDJSON_CONTAINER_NAME}" \
  "${PERF_WORK_DIR}/build-optimized/bin/perftest" \
  --gtest_filter='RapidJson.Writer_StringBuffer_SSE2:RapidJson.Writer_StringBuffer_SSE42:RapidJson.Writer_StringBuffer_NEON' \
  --gtest_repeat=5 \
  --gtest_output=xml:"${RESULTS_DIR}/runs/writer_string_buffer/rep1.xml"
python3 software/HPC/rapidjson/scripts/results/parse_perftest.py \
  --runs-dir "${RESULTS_DIR}/runs" --results-dir "${RESULTS_DIR}" \
  --version 1.1.0 --architecture "$(uname -m)" --variant optimized --run-id "${PERF_RUN_ID}"
docker rm -f "${RAPIDJSON_CONTAINER_NAME}"
```

入口同样支持 `--keep-workdir` 保留本次私有目录以便排查。Framework 调用时结果直接写
`--results-dir`；独立入口在 `--variant optimized` 时多追加一层 `optimized/` 子目录，避免与
`base` 结果互相覆盖，且不更新基线。`--variant` 只接受 `base` 与 `optimized`，其他取值在参数解析
阶段返回 10。

- **脚本出处**：`rapidjson_test.sh`、`scripts/results/standalone_runtime.py`。

## 已知限制

- **不绑核、不设配额**：与仓库 `jemalloc`、`libavif` 用例一致（BoostKit 参考材料用
  `numactl -C <cpu>` 绑定单核）。因此本用例的绝对值不能与参考材料中的数字直接比较；跨架构只配对
  同名同参数的指标，核数差异不强行配对。
- **版本口径**：上游没有 `1.1.0` 的 tag，本用例固定到 `24b5e7a8…` 这个 commit，并按源码内
  `RAPIDJSON_VERSION_STRING` 记为 1.1.0；BoostKit 的 v1.0.0 是补丁自身的发布号（`kunpeng_opti_v1.0.0.patch`），
  两者不是同一套版本编号，报表里以用例版本 1.1.0 + 变体 `optimized` 表达。
- **`optimized` 依赖补丁副本**：补丁随用例入库，构建前强制校验 SHA-256；补丁缺失或不匹配时构建
  阶段**明确失败**（`return 30`）并说明原因，**不退回基础版**，也不会静默降级为 `base`。
- **`-Wno-error` 的来由**：gcc ≥ 11 在 `-Werror` 下对上游未改动的 `test/unittest/itoatest.cpp`、
  `uritest.cpp` 报 `stringop-overflow`/`array-bounds` 误报，`unittest` 无法编译；本用例把
  `-Wno-error` 放在 `CMAKE_CXX_FLAGS_RELEASE` 里（出现在上游追加的 `-Werror` 之后），只把警告降级
  为提示，`-Wall -Wextra` 与 `-O3` 都不变，源码不改。
- **`GOOGLETEST_VERSION` 必须显式传入**：rapidjson 的 `FindGTestSrc` 把
  `thirdparty/gtest/googletest` 作为子目录加入工程，而该子目录的 CMake 需要父工程提供
  `GOOGLETEST_VERSION`；不传时 configure 直接失败，与上游 CI 使用系统 `/usr/src/gtest` 的路径不同。
- **计时精度**：gtest 每次迭代只打印整数毫秒的 `(<X> ms total)`。每轮 `--gtest_repeat=5` 把 5 次
  迭代的整数毫秒相加，最坏量化误差是 5 × 0.5 ms；对最小的场景（`writer_string_buffer_paragraphs`，
  约 145 ms）为 1.7%，对 1 s 量级的场景低于 0.3%。再取 5 轮中位数，误差只会更小。每次迭代都会
  重新执行 fixture 的 `SetUp`（读取语料并建 DOM），这部分固定开销在两个架构与两个变体上一致。
- **场景裁剪**：上游 `test/perftest` 共 60 余个用例（含 JSON Schema、IStream 包装、编码校验等）。
  `ctest -R perftest` 会把它们全部跑一遍，本用例只采样其中 8 个与「DOM/SAX 解析、字符串写出」
  相关且耗时可控的用例，不改变其它用例的运行方式。每个场景的 `--gtest_filter` 显式枚举
  `_SSE2`/`_SSE42`/`_NEON` 三个架构后缀，避免 `Writer_StringBuffer_*` 误匹配
  `Writer_StringBuffer_Booleans_*` 等同名兄弟用例。
- **无网络直连 Docker Hub**：基础镜像只从 openEuler 官方归档或公共离线目录取；gitcode 上的补丁已
  随用例入库，构建阶段不需要访问 gitcode。

## 与参考材料的关系

- 构建与测试方法参考 BoostKit 的 [rapidjson 安装指南](https://gitcode.com/boostkit/rapidjson/blob/master/docs/zh/installation_guide.md)：
  同一 `cmake` Release 口径、同一 `-O3` 与 aarch64 推荐编译选项、同一 `ctest` 单元测试套件。
- 被测的优化实现来自 BoostKit 的 [Kunpeng RapidJSON 优化版](https://gitcode.com/boostkit/rapidjson)（v1.0.0），
  补丁原文即该仓库的 `kunpeng_opti_v1.0.0.patch`，本用例只把它应用到上游固定 commit 上。
- 性能口径来自上游 RapidJSON 自己的 `test/perftest` 套件（`rapidjson` 仓库 `bin/` 目录下的官方
  语料），没有自研 benchmark 程序；与参考材料的差异仅在采样规模（每场景 1 次预热 + 5 次采样）与
  不绑核。
