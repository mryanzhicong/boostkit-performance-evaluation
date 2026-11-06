# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境：128 passed、5 deselected。
- 精确排除已有的两项 Bash 4 和三项 Linux /proc 测试，不计为通过。
- Python compileall/Pyflakes、Shell bash -n、框架目录/矩阵及 git diff --check 通过。
- 静态检查固定 ARM JAR 内 libgluten/libvelox 及补充库 ELF：需要 GLIBC 2.38、GLIBCXX 3.4.30、Boost 1.84、ICU 74；所附 RE2 需要 Abseil 2308 ABI。详见 reference/native-abi.json。
- 已核对 openEuler 24.03 SP4 官方仓库：ICU 74.1、Boost 1.83。因此新增容器内源码构建固定 Boost 1.84.0 和 Abseil 20230802.3（其上游 CMake SOVERSION 为 2308.0.0）；源码摘要已冻结，不伪造库名或使用所附不匹配的 Abseil 2501。
- 只将递归 DT_NEEDED 实际需要且通过 ARM ELF 检查的五个附件库加入离线清单；不提交 87MB JAR 或库二进制。
- 本地未编译这些 ARM 依赖、未启动 Docker/服务器、未 SSH 或提交 Action，没有性能数值。源码构建、真实 ldd/JVM 加载、原生执行计划和 SF10000 全量查询仍待 ARM 运行验证。
