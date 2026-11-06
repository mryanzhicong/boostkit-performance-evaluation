# 本地验证记录（2026-11-06）

- 环境：本地 macOS，Python 3.14 隔离测试环境。
- `pytest software/Bigdata/bolt/tests software/Bigdata/spark/tests framework/tests`：125 passed，5 deselected。
- 精确排除已有的两项 Bash 4 参数展开测试，以及三项依赖 Linux /proc 的进程扫描测试；完整运行时这五项因平台限制失败，不计为通过。
- Python compileall、Shell bash -n、git diff --check 通过；目录注册与三个手动工作流选项一致。
- 新增有效配置占位符、原文参数和架构/优化变体早期拒绝测试，相关子集 59 passed。
- Bolt ARM 发行包已下载并核验 ZIP 内容，包含文档指定 JAR 和 BiSheng 17.0.16；固定完整包 SHA-256。
- 未执行容器安装、数据生成、412 次 SQL、远程 SSH 或 GitHub Actions；没有性能实测数值。
- PR 为待运行验证的 Draft，不合并；SF10000、原文资源配置和原生 ABI 仍须未来授权后验证。

## SF100 与磁盘检查更新

- 默认规模改为 SF100；上轮 SF10000 是旧默认值，不再用于本轮配置。SQL 数量、测量轮次和 CPU/内存参数保持不变。
- 磁盘只记录，不设硬性容量拦截；运行时每 10 秒及阶段结束采样文件系统空间，采样日志写满不另行触发阈值停止。实际业务写入错误仍返回失败并执行清理。
- 本轮本地检查：132 项通过，5 项已有平台测试精确排除；新增低磁盘不拦截、CPU 检查保留和磁盘日志写满容错测试。
- 未启动 Action、未部署服务器或执行性能测试。
