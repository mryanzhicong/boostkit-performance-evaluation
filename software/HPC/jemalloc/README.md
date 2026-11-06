# jemalloc 5.4.0 接入进度

## 当前范围

已准备在私有 openEuler 24.03 LTS SP4 容器中构建上游原版 jemalloc 5.4.0。当前只提供构建入口；`malloc_benchmark` 工具尚未收到，测试、指标解析、Framework `case.yaml` 和工作流选项均未启用，避免产出不完整的性能报告。

上游源码使用 [jemalloc 5.4.0 官方发布包](https://github.com/jemalloc/jemalloc/releases/tag/5.4.0)，不打优化补丁。容器使用与现有容器用例相同的 openEuler 24.03 LTS SP4 镜像，采用 host 网络，构建文件写入 `/home/runner/boostkit-perf/jemalloc/5.4.0/<架构>/<run-id>/`，不安装到宿主机。

## 构建

在仓库根目录执行，例如：

```bash
bash software/HPC/jemalloc/scripts/builders/base.sh \
  --architecture aarch64 --run-id local-check-1
```

脚本优先使用 `/home/runner/software/jemalloc/jemalloc-5.4.0.tar.bz2`；没有时下载官方发布包。容器镜像优先使用 `/home/runner/software/openEuler-24.03-LTS-SP4/openEuler-docker.<架构>.tar.xz` 及其 `.sha256sum`；缺失时下载并校验。容器内通过 `dnf` 安装构建依赖，执行 `./configure --prefix=<私有目录> && make -j "$(nproc)" && make install`，最后检查 `jemalloc-config --version` 和 `libjemalloc.so.2`。脚本结束会删除本次容器，保留私有构建目录以供核查。

## 等待测试工具

收到 `malloc_benchmark` 源码后，再核对三种 `-mode` 的语义、编译规则、结果字段，以及如何明确让测试进程加载本次构建的 jemalloc。之后补齐两架构一致的测试矩阵、结果解析和 Framework 接口。不会直接沿用示例中的固定 384 线程或 x86 专用编译参数到 aarch64。
