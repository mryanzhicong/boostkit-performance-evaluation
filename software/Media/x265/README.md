# x265 性能测试

支持 `4.1`、`4.2`，默认 `4.2`。入口 `x265_test.sh`；四阶段函数与产物见 `case.yaml`。

## 构建

从 [x265 官方仓库](https://bitbucket.org/multicoreware/x265_git)取得指定标签，在本次 `PERF_WORK_DIR` 中构建 CLI。缺少命令时用 `dnf` 安装，x86_64 还需 NASM；`PERF_PROXY` 非空时用于 dnf 代理。

```bash
git clone --branch 4.2 --depth 1 https://bitbucket.org/multicoreware/x265_git.git x265-source
mkdir x265-build
cd x265-build
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_CLI=ON -DENABLE_SHARED=OFF ../x265-source/source
make -j"$(nproc)"
./x265 --version
```

若浅克隆标签失败，脚本执行完整克隆后检出指定版本。实际版本必须与请求版本一致；不安装到系统。

## 测试与指标

脚本用 `scripts/gen_yuv.py` 生成确定性 I420 输入，默认 1280×720、50 帧，再由 `scripts/run_benchmark.py` 调用官方 x265 CLI。测试覆盖 5 个 preset、3 个分辨率和 1/2/4/8 线程池；preset 与分辨率比较固定 `--pools 8`，避免不同架构自动展开不同规模的线程池。

原始编码输出为 `RESULTS_DIR/benchmark_encode.txt`，归一化结果为 `benchmark_x265.json`。报告按场景展示官方编码摘要中的 fps，越高越好。

独立运行：

```bash
bash software/Media/x265/x265_test.sh --version 4.2 --results-dir /home/runner/x265-results
```
