# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境，完整本地检查首次为 125 passed、5 deselected。
- 精确排除已有的两项 Bash 4 和三项 Linux /proc 测试；这五项不计为通过。
- 随后补充有效配置路径和架构/优化变体早期拒绝测试，相关子集 59 passed。
- Python compileall、Shell bash -n、目录注册、工作流矩阵及 git diff --check 通过。
- Apache 0.5.3 server 使用官方 SHA-512；本地固定 Gluten 1.3.0 bridge JAR 的 SHA-256，确认包含文档要求的管理器类。该类上游支持 row shuffle。
- 未运行服务器、Docker 部署或 Action；Gluten bridge 与 Celeborn 0.5.3 的实际二进制兼容性、Worker 注册及正数远程 shuffle 数据仍待验证。
- 无性能实测数据；Draft PR 不合并，不更新基线。

## SF100 与磁盘检查更新

- 默认规模改为 SF100；上轮 SF10000 是旧默认值，不再用于本轮配置。SQL 数量、测量轮次和 CPU/内存参数保持不变。
- 磁盘只记录，不设硬性容量拦截；运行时每 10 秒及阶段结束采样文件系统空间，采样日志写满不另行触发阈值停止。实际业务写入错误仍返回失败并执行清理。
- 本轮本地检查：64 项通过（组件、公共 Spark 与目录/矩阵子集）；新增低磁盘不拦截、CPU 检查保留和磁盘日志写满容错测试。
- 未启动 Action、未部署服务器或执行性能测试。

## 2026-11-07 双架构适配与 Action 修复

- #265 选择 all，x86 构建因旧 ARM-only 限制被拒绝；完整错误保存在任务证据目录。
- 开放 Celeborn aarch64/x86_64；其他尚未适配的组件保留自身架构限制，不把 ARM 原生库放到 x86。
- 使用 Apache 官方 Gluten 1.3.0 Spark35 发布归档，固定官方 SHA-512；其内部 JAR 与所附 x86 JAR SHA-256 相同。从中确定性生成 Java-only bridge，移除原生二进制和失效签名，保留原 Java 类、SPI、许可证，生成物另固定 SHA-256。
- 双架构均使用原生 Spark 的 row shuffle 与文档指定 Gluten CelebornShuffleManager，不额外启用 GlutenPlugin；JDK 和原始数据生成器按各自架构下载。
- 本地相关子集 67 项通过；完整回归 135 passed、5 项已有平台测试精确排除。架构选择、公共下载路径和 Java-only 构建确定性已测试。
- SF100、原资源参数、103 查询/412 次文件执行、磁盘只记录策略保持不变；真实兼容性与性能结论以重启后的 Action 产物为准。

- 补充实际 Celeborn 安装分支回归，修复 tarfile 局部导入遮蔽问题；相关子集 68 项通过。首次修复运行在部署前被停止并由新提交替代，避免执行已知有问题的版本。

- #265 ARM 端在下载 Spark 时 SSL 连接超时，尚未进入实际安装。新增 Apache/Maven 华为镜像优先、原摘要校验、传输停滞超时与内容寻址下载缓存，镜像错误内容不能通过摘要检查。相关子集 69 项通过。
