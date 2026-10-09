# x264 性能测试

版本 `0.164.x`。入口 `x264_test.sh`；四阶段函数与结果字段见 `case.yaml`。

## 构建

源码固定为 [GitHub x264 镜像](https://github.com/mirror/x264) 的 `stable` 分支，要求提交为 `31e19f92f00c7003fa115047ce50978bc98c3a0d`。缺少命令时用 `dnf` 安装，x86_64 还需 NASM；`PERF_PROXY` 非空时用于 dnf 代理。

```bash
git clone --branch stable --depth 1 https://github.com/mirror/x264.git x264-source
cd x264-source
./configure --enable-static --enable-pic
make -j"$(nproc)"
./x264 --version
```

脚本验证实际版本是 `0.164.x`，不做系统级安装。构建目录位于本次 `PERF_WORK_DIR`。

## 测试与指标

脚本用 `scripts/gen_yuv.py` 生成确定性的 I420 输入，默认 1280×720、50 帧，然后运行 `scripts/run_benchmark.py` 调用官方 `x264` CLI。测试覆盖 5 个 preset、3 个分辨率和 1/2/4/8/auto 线程；auto 不传 `--threads`，由 x264 自定。

原始编码输出保存为 `RESULTS_DIR/benchmark_encode.txt`，解析后的 `benchmark_x264.json` 保存每个场景的编码速度。报告指标是官方 `encoded N frames, X fps` 的 `X`，单位 fps，越高越好。

独立运行：

```bash
bash software/Media/x264/x264_test.sh --version 0.164.x --results-dir /home/runner/x264-results
```
