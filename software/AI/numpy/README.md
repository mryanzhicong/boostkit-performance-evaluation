# NumPy 2.4.3 开箱性能用例（容器化）

本用例把 boostkit-performance-evaluation 框架接入 NumPy 2.4.3 的性能测量，提供两个变体：

* `variant=base`（**开箱性能**）：被测软件是 GitCode 上的**未修改导入基线** `289c872f`，测的是
  上游 NumPy 2.4.3 在本机上的原始性能；
* `variant=optimized`（**鲲鹏优化版**）：被测软件是 GitCode `boostkit/numpy` **master 分支**上的
  鲲鹏优化版 2.4.3，测量其分支尖端 `HEAD`；运行命令按指导换成 `asv run HEAD~1..HEAD`，该 range
  经 `git rev-list --first-parent` 只选中尖端 `HEAD`（`HEAD~1` 是 range 的排除端，其 commit/tree
  记入 `numpy-source.txt` 作为来源信息）。

两个变体都跑完《numpy 开箱性能测试指导》给出的 1256 条聚合 ASV 用例，输出 `results/`（ASV
原始结果）、`html/`（ASV 报告）以及逐用例的严格解析结果 `results.json`。所有编译与测量都在
私有的 openEuler 24.03 LTS SP4 容器里完成，宿主机只负责调度 Docker 和运行结果校验器。

## 1. 测什么

| 项 | `variant=base`（开箱） | `variant=optimized`（鲲鹏优化版） |
| --- | --- | --- |
| 被测软件 | NumPy 2.4.3，boostkit 在 GitCode 上的**未修改导入基线** | NumPy 2.4.3，GitCode `boostkit/numpy` **master** 分支的鲲鹏优化版 |
| 被测提交 | `289c872fc2cc3a82a63a66b4c1a32e8ef6e80fb6`（`289c872f`，导入 NumPy 2.4.3 基线与 GitCode 门禁），tree `4011714d5de68c10c60cf6f083c3a49c1de0dfc4` | `master` 尖端 `HEAD`（构建时解析，记入 `numpy-source.txt` 与 `build_variant.json`）；`asv run HEAD~1..HEAD` 只选中该尖端，`HEAD~1` 只是 range 的排除端 |
| 用例套件 | boostkit main 分支的平台聚合 ASV 套件，提交 `95422b21eb5b43a2453e45b8531a3dd09c9b61ab`（`95422b2`），`benchmarks` tree `b76e6b454f70b2ceb13b7cfe8a22bce57717ac3f` | 同左（套件与源码分开钉住，见第 2 节） |
| 用例清单 | `fixtures/1200+juhe_benches.txt`，1256 条 id，`sha256 c1f41e0831d74a04e4eb9a6891b10ca1073dfbbf58721d97083e4cc6f1c16cfe`，94130 字节（逐字节随指导附件保留） | 同左 |
| 解释器 | CPython 3.14.10（官方源码在容器内 PGO 构建），`sha256 9e4996c19ae5a3df31f10c37723661f71d3455d73bd005f79df7098e5cc13192`，31671453 字节 | 同左 |
| 测量工具 | asv 0.6.4（`requirements.lock` 全量钉住：asv_runner 0.3.2 / build 1.6.1 / Cython 3.3.1 / meson 1.12.1 / meson-python 0.22.1 / ninja 1.13.2 / packaging 26.3 / setuptools 84.2.1 / virtualenv 21.15.5 / wheel 0.48.0） | 同左（ASV 另按 `asv.conf.json` 为被测提交建环境） |
| 运行环境 | openEuler 24.03 LTS SP4 私有容器（`--network=host`、`--user $(id -u):$(id -g)`、每 run 一个 `boostkit-numpy-<arch>-<run-id>` 容器） | 同左；测量窗口内需要可用的 PyPI / GitHub 镜像（见第 3、8 节） |
| 指标 | 每个聚合用例的**单次调用耗时（秒）**，方向 `lower_is_better`，单位 `s`，`group` 为"模块.类" | 同左 |

`optimized` 的"取点"与 `base` 不同：优化版没有固定哈希，指导要求"换 commit 再测一次"，本用例把它
落地为**测 master 尖端**——`build_numpy_optimized` 克隆 `master`、解析 `HEAD` 与 `HEAD~1` 的
commit/tree 并写 `numpy-source.txt`；start/test 阶段据此校验工作区，test 阶段按指导把命令换成
`asv run HEAD~1..HEAD`，让 ASV 自己构建并测量尖端 `HEAD`（该 range 经 `git rev-list --first-parent`
只选中 `HEAD`，`HEAD~1` 仅作 range 排除端留档）。优化版默认**不启用 KML FFT 后端**（它需要
HPCKit/KML 库），只启用源码内的 NEON/Highway 等鲲鹏优化；`fft-backend` 因此保持默认可构建。

一次 run 产出 **1256 条指标**（1 条清单 id = 1 条指标），与
`1200+juhe_benches.txt` 的行数一致：清单里 1216 条是上游规范用例的精选参数组合，40 条是
`aggregate_950.*` 平台聚合用例。

## 2. 为什么把"被测代码"和"用例套件"分成两个钉子

指导给出的优化前取点是 `289c872f`，但该提交里还**没有** `aggregate_920b/`、`aggregate_950/`
这两个聚合用例目录——它们是 2026-07-22 的 `173744c "PERF: add platform aggregate benchmark
scripts"` 才加进 main 的（`289c872f` 之后 103 个提交）。也就是说：

* 指导附件里的 1256 条 id **不可能**在 `289c872f` 的套件里全部解析（实测：用 `289c872f`
  自带的套件只有 1216 条可解析，40 条 `aggregate_950.*` 全部缺失）；
* 而"开箱性能"要测的又必须是**未优化的 2.4.3 源码**。

因此本用例按"参考 main 下面的测试内容"把两者分开钉住：**被测 NumPy 源码 = `289c872f`，
用例套件 = main 的 `95422b2`**。套件逐字节 vendor 到 `asv_bench/`，由
`asv_bench/manifest.sha256` 在每个 stage 校验，因此 main 后续再变也不会改掉本用例的测量口径。
实测在该组合下 1256 条 id **全部**解析成功（`asv-selection.json` 记录了解析摘要）。

`optimized` 变体沿用同一颗套件钉子，只把"被测代码"换成 master 分支：这样 base 与 optimized
的差异只来自 NumPy 源码（鲲鹏优化），而不来自用例集合。

## 3. 容器化执行

`scripts/common.sh` 中的 `# >>> container-runtime:begin/end` 区块由
`adaptation/scripts/add-container-block.py` 生成（模板
`adaptation/scripts/container-block.template.sh`），提供
`require_numpy_docker` / `prepare_numpy_container_image` / `start_numpy_container` /
`check_numpy_container` / `numpy_container_exec[_at|_root]` / `sweep_numpy_stale_containers` /
`remove_numpy_container`，容器名 `boostkit-numpy-<arch>-<run-id>`、标签
`boostkit.numpy.run-id=<run-id>`，镜像按 `repo.openeuler.org` 的官方
`openEuler-docker.<arch>.tar.xz` 校验 sha256 后 `docker load`，并校验 `/etc/os-release`
确为 24.03。

各 stage 的分工：

| stage | 在哪里执行 | 做什么 |
| --- | --- | --- |
| build | 容器内（宿主只调度） | `dnf` 装工具链（gcc/gcc-c++/make/git-core/pkgconf/openblas-devel/zlib-devel/libffi-devel/openssl-devel/bzip2-devel/xz-devel/sqlite-devel/ncurses-devel/readline-devel/gdbm-devel/libuuid-devel/ca-certificates）→ 下载并校验 CPython 3.14.10 源码 → `configure --enable-optimizations` + `make -j` + `make install` → 建 venv 装 `requirements.lock` → clone 被测提交并校验 commit/tree（`base`：`289c872f`；`optimized`：`master` 尖端 `HEAD`，range 排除端 `HEAD~1` 的 commit/tree 一并写入 `numpy-source.txt`）→ 初始化 **6 个** submodule（pythoncapi-compat / highway / pocketfft / vendored-meson / x86-simd-sort / svml；后两个在 aarch64 上不参与编译，但 numpy 的 `license-files` 要求它们的 LICENSE 文件存在，必须先探测 github.com 是否可达（25 s 超时）再按 gh-proxy → ghfast 顺序重写）→ `python -m build --wheel --no-isolation` → 安装 wheel → vendor 套件到 `${PERF_WORK_DIR}/asv_bench` 并校验 manifest → `asv machine --yes` → 写 `build_variant.json` |
| start | 容器内校验 | 复核 CPython/NumPy 版本、被测 commit+tree（`base` 固定 `289c872f`；`optimized` 读 `numpy-source.txt` 的 `HEAD`）、套件 manifest、机器注册；跑一条廉价用例强制 ASV discovery，写出 `benchmarks.json`；把 1256 条 id 解析成 `runs/expected.json`（解析失败在测量前就报错） |
| test | 容器内测量 + 宿主解析 | 容器内 `asv run`：`base` 用 `--python=same --set-commit-hash <289c872f> --no-pull`；`optimized` 用 `asv run HEAD~1..HEAD --no-pull`（ASV 为该提交新建虚拟环境并按 `asv.conf.json` 自行构建 NumPy）；两者都 `--record-samples -a rounds=1 -a repeat=6 -b <1256 条精确正则>` → `asv publish` 出 `html/` → 原始结果/case 样本/`asv show` 落到 `runs/`；宿主上的 `scripts/results/parse_benchmark.py` 严格复核并写 `results.json` |
| stop | 宿主 | 按 run-id 标签删除本 run 的容器、清理同前缀的陈旧容器、确认没有残留测量进程（幂等） |

`dnf` 事务带 `--setopt=install_weak_deps=False --setopt=tsflags=noscripts`：容器把
`/etc/passwd`、`/etc/group` 只读挂载，任何"创建服务用户"的 rpm scriptlet 都会失败
（openEuler 的 `git` Requires: systemd，systemd 的 `dbus-daemon` `%prein` 直接返回 6）。
这些 scriptlet 只管理本用例从不使用的守护进程与用户，所以整笔事务跳过 scriptlet，随后显式
`ldconfig` 并**编译+链接**一个调用 `openblas` 的小程序，证明工具链真的可用；`git` 也只装
提供二进制的 `git-core`。NumPy 的 `pyproject.toml` 把 meson-python 指向
`vendored-meson/meson/meson.py`，缺了它构建会报 `Could not find the specified meson`；
`--no-isolation` 构建还需要 `patchelf`，已钉进 `requirements.lock`。

`optimized` 变体在构建阶段多做三件事，都是为了 ASV 自己构建被测量的 `HEAD`：

* 把测量 venv 里的 `patchelf` 与 `ninja` 装到 `/usr/local/bin`：ASV 用 `asv.conf.json` 的
  `build_command` 做**隔离**构建（`python -m build --wheel`），meson-python 需要 PATH 上有
  这两个可执行文件；
* 给容器内 git 配 `protocol.file.allow=always`，并在 github.com 不可达时把 submodule 的镜像
  ``url.<mirror>.insteadOf`` 写进全局配置：ASV 会在被测提交的 checkout 里递归初始化 submodule；
* 把 PyPI 镜像（`PIP_INDEX_URL` / `PIP_EXTRA_INDEX_URL` / `PIP_TRUSTED_HOST`）导出给 ASV：
  它要为被测提交创建虚拟环境、安装 `build` / `asv_runner` / `pympler` 与 NumPy 的构建依赖。

容器内的编译与测量都继承 `NUMPY_MEASUREMENT_ENV`：`OMP/OPENBLAS/MKL/NUMEXPR/VECLIB/BLIS`
线程数全部为 1、`PYTHONHASHSEED=0`、`LC_ALL=C`、`TZ=UTC`、`HOME=${PERF_WORK_DIR}/home`，
并且把 `http(s)_proxy` 指向 `127.0.0.1:9`、`--no-pull`——`base` 的测量窗口内不会有任何网络
I/O；`optimized` 由 `numpy_asv_env` 去掉这几项代理封堵并注入 PyPI 镜像，因为 ASV 要在测量窗口
内现场建环境、构建被测提交。

## 4. 测量协议

* asv 0.6.4 在 `--python=same`（复用已装 NumPy 的 venv）下**不允许**把提交号当位置参数
  （`No range spec may be specified if benchmarking in an existing environment`），
  因此指导里的 `asv run 289c872f ...` 等价改写为
  `asv run --python=same --set-commit-hash 289c872f ...`，记录进结果文件的 `commit_hash`
  仍是同一个提交，可在 `runs/asv-results.json` 里核对。
* `-b "$(cat 1200+juhe_benches.txt)"` 会把整个文件当成**一条**正则，asv 会报
  `No benchmarks selected`；本用例把每行归一化（还原缺失的 `\` 转义）后 `re.escape`
  成精确正则，**每行一个 `-b`**。
* 采样：`PERF_WARMUPS`（默认 1）个预热样本 + `PERF_REPS`（默认 5）个有效样本，共
  `repeat=6`、`rounds=1`；解析器丢掉第 1 个样本，对其余 5 个取中位数（同时记录
  min/max/mean 与全部原始样本）。`PERF_REPS<5` 只允许本地冒烟。
* `optimized` 按指导原文执行 `asv run HEAD~1..HEAD -b ...`：asv 0.6.4 **只允许在非既有环境
  模式**下接受范围参数（`--python=same` 会报 `No range spec may be specified if benchmarking
  in an existing environment`），所以该变体不使用 `--python=same`，而是让 ASV 为被测提交创建
  虚拟环境、按 `asv.conf.json` 的 `build_command` 构建并安装 NumPy。`HEAD~1..HEAD` 经
  `git rev-list --first-parent` 只解析出 `{HEAD}`，因此**本次只构建/测量尖端一个提交**；
  `HEAD~1` 只是 range 的排除端，其 commit/tree 记入 `numpy-source.txt` 与 `build_variant.json`
  留档。若需要父提交的数值，另跑一次 `asv run HEAD~2..HEAD~1`（或直接用 `variant=base` 的基线）；
  若某次结果里恰好有父提交的记录，`runs/asv-results-parent.json` / `runs/asv-show-parent.txt`
  会一并保留，但不会进入 `results.json`。
* `optimized` 的解析仍要求"结果里的 commit_hash == 构建阶段记录的 `HEAD`"，这条期望值经
  `NUMPY_EXPECTED_COMMIT` 传给解析器；`base` 不设该变量，行为与之前完全一致。
* 解析器是硬校验：提交号、Python 3.14、每条 id 的样本条数必须恰好是 `1+PERF_REPS`、
  数值必须有限且为正、指标名不得重复；任何一条不满足就返回 50，**绝不补零或跳过**。

## 5. 目录结构

```
software/AI/numpy/
├── case.yaml                     # 4 stage + 4 outputs + metrics collection
├── README.md
├── numpy_test.sh                 # 单机复现入口（build→start→test→stop 一把跑完）
├── requirements.lock             # 容器内 venv 的全量钉版
├── asv_bench/                    # main@95422b2 的聚合 ASV 套件（逐字节 vendor）
│   ├── asv.conf.json             # repo=../src/numpy, results/html/env 相对本目录
│   ├── benchmarks/               # 44 个模块（含 aggregate_920b/ aggregate_950/）
│   ├── LICENSE.txt  PROVENANCE.md  manifest.sha256
├── fixtures/1200+juhe_benches.txt
├── scripts/
│   ├── common.sh                 # 钉版常量 + 容器区块
│   ├── benchmarks/select_benchmarks.py   # 清单 → 精确正则 / 解析成 expected.json
│   ├── results/parse_benchmark.py        # ASV 结果 → results.json + runs/samples.json
│   ├── builders/{dispatch,base,optimized}.sh
│   └── stages/{start,test,stop}.sh
└── tests/                        # 容器生命周期 + 解析器单测（pytest）
```

运行期工作目录 `${PERF_WORK_DIR}`：`src/numpy`、`cpython-source/`、`cpython-build/`、
`cpython-install/`、`numpy-venv/`、`wheelhouse/`、`asv_bench/{results,html,env}`、`home/`；
`optimized` 另有 `numpy-source.txt`（branch / head / head_tree / parent / parent_tree / range，
start 与 test 阶段据此复核工作区）。
结果目录：`build_variant.json`、`results.json`、`runs/`（`asv-results.json`、
`asv-benchmarks.json`、`asv-machine.json`、`samples.json`、`asv-run.log`、`asv-show.txt`、
`expected.json`；`optimized` 另含 `asv-results-parent.json`、`asv-show-parent.txt`）、
`asv/results/`、`asv/html/`。

## 6. 怎么跑

框架（六阶段，x86_64 本地；变体由环境变量 `PERF_VARIANT` 选择，默认 `base`）：

```bash
python3 framework/run_case.py --case software/AI/numpy/case.yaml --version 2.4.3 \
    --architecture x86_64 --run-id local-1 --stage prepare   # build/start/test/stop/finalize 同理

PERF_VARIANT=optimized python3 framework/run_case.py --case software/AI/numpy/case.yaml \
    --version 2.4.3 --architecture aarch64 --run-id local-opt-1 --stage build  # 其余阶段同理
```

单机一把跑完（自带容器创建与清理）：

```bash
./software/AI/numpy/numpy_test.sh                 # 默认 1 预热 + 5 样本，variant=base
PERF_REPS=1 ./software/AI/numpy/numpy_test.sh     # 冒烟
PERF_VARIANT=optimized ./software/AI/numpy/numpy_test.sh   # 测 master 尖端（HEAD~1..HEAD）
```

Blue 工作流（`.github/workflows/performance-test-blue.yml`）：`software=numpy`、
`version=2.4.3`、`architecture=all`（aarch64 + x86_64 两条线）、`variant=base` 或
`variant=optimized`。aarch64 用 `PERF_RUNNER_ARM64` 上的专用 runner，x86_64 用
`PERF_RUNNER_X86_64`。`variant=optimized` 需要 runner 上的容器能访问 PyPI 与 GitHub 镜像。

## 7. 与指导的差异（逐条可核对）

1. `asv run 289c872f` → `asv run --python=same --set-commit-hash 289c872f --no-pull`：
   asv 0.6.4 在既有环境模式下不接受范围参数。
2. `-b "$(cat 1200+juhe_benches.txt)"` → 每行一条精确正则：asv 的 `-b` 是
   `action="append"`，整文件作为一条正则匹配不到任何用例。
3. 清单里 8 行少了转义（如 `bench_ufunc.NDArrayGetItem.time_methods_getitem\(\(-1, 0\), 'big')`
   末尾右括号未转义），归一化后才能精确匹配；归一化在 `select_benchmarks.py` 里做，
   原始文件不改。
4. 聚合套件取 main（`95422b2`）而不是 `289c872f`：见第 2 节。
5. Python 3.14 由官方源码在容器内 PGO 构建（openEuler 24.03 仓库只有 3.12），
   `configure --enable-optimizations --with-ensurepip`，与 python.org 官方二进制同样的优化档。
6. 指标方向统一为 `lower_is_better`（耗时），单位 `s`，`group` 取"模块.类"。
7. 容器内只装 `git-core` 并让 dnf 事务跳过 rpm scriptlet（只读 `/etc/passwd` 下的必然结果，
   见第 3 节），工具链可用性由 `ldconfig` + 真实编译链接验证兜底。
8. `optimized` 变体按指导原文执行 `asv run HEAD~1..HEAD`，因此**不**使用 `--python=same`：
   asv 0.6.4 禁止在既有环境里指定范围参数，且只有该模式才会按 `asv.conf.json` 为被测提交
   构建/安装 NumPy。build 阶段仍先自建一份 HEAD 的 wheel，用于版本与环境证据。
9. `optimized` 的测量窗口需要 PyPI 镜像：ASV 建环境、装构建依赖、隔离构建 NumPy 都在窗口内；
   镜像经 `numpy_pip_index_env` 导出，`numpy_asv_env` 只对 optimized 去掉 `http(s)_proxy` 封堵。
10. meson-python 的隔离构建需要 PATH 上的 `ninja` 与 `patchelf`，而 `requirements.lock` 只把它
    们装进测量 venv；`optimized` 构建把 `${VENV_DIR}/bin/{patchelf,ninja}` 安装到
    `/usr/local/bin`。
11. 容器内 git 需要 `protocol.file.allow=always` 与可用的 GitHub 镜像
    （`url.<mirror>.insteadOf`）才能让 ASV 在被测提交的 checkout 里递归初始化 submodule。

## 8. 已知限制

* `variant=optimized` 的测量不再零网络：ASV 要在测量窗口内为被测 `HEAD` 建一个虚拟环境
  （装 `build` / `asv_runner` / `pympler` 与 NumPy 构建依赖）并递归初始化 submodule，
  容器必须能访问 PyPI 与 GitHub（或其镜像）；网络不通会直接失败，不会静默降级。
* `variant=optimized` 会在容器里构建两次 NumPy（build 阶段的 HEAD wheel + ASV 的 `HEAD`），
  单次 run 仍明显长于 base，300 min 上限内的余量更小；aarch64 首次运行建议观察一次耗时。
* `variant=optimized` 默认不启用 KML FFT 后端（需要 HPCKit/KML），FFT 走 pocketfft；如需 KML，
  要另行准备 KML 库并显式传 `-Dfft-backend=kml -Dfft-include-dir=... -Dfft-lib-dir=...`。
* `optimized` 测的是 master 尖端，同一 run-id 在不同时间跑出的 HEAD 可能不同；对比时以
  `build_variant.json` / `numpy-source.txt` 记录的 commit 为准，不要按 run-id 对齐。
* 40 条 `aggregate_950.*` 只在 main 套件里存在；若把套件切回 `289c872f`，解析器会直接失败
  而不是静默少 40 条指标。
* 1256 条指标会让报告体量明显大于其他用例（这是"1200+ 聚合用例"本身决定的）。
* 容器内完整构建（CPython PGO + NumPy）约十几分钟，叠加测量时间后单条流水线仍在
  `execution.timeout_minutes: 300` 之内。
* 两个变体都**不修改 OS/BIOS 参数**：不写 `sysctl` / `/proc/sys` / `/sys`，不改 CPU governor、
  THP、hugepage、tuned，也不碰 BIOS/MSR。`optimized` 只换被测源码（master 尖端），并在容器里
  补上 ASV 构建所需的用户态工具（`/usr/local/bin/{patchelf,ninja}`、`$HOME` 下的 git/pip 配置）；
  容器启动参数（`--network=host`、`--ulimit nofile=…`）对 base/optimized 完全一致，因此两者
  的差异只来自 NumPy 源码本身（以及 ASV 的构建/环境方式）。
