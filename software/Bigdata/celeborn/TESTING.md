# 本地验证记录（2026-11-06）

- 本地 macOS / Python 3.14 隔离环境，完整本地检查首次为 125 passed、5 deselected。
- 精确排除已有的两项 Bash 4 和三项 Linux /proc 测试；这五项不计为通过。
- 随后补充有效配置路径和架构/优化变体早期拒绝测试，相关子集 59 passed。
- Python compileall、Shell bash -n、目录注册、工作流矩阵及 git diff --check 通过。
- Apache 0.5.3 server 使用官方 SHA-512；本地固定 Gluten 1.3.0 bridge JAR 的 SHA-256，确认包含文档要求的管理器类。该类上游支持 row shuffle。
- 未运行服务器、Docker 部署或 Action；Gluten bridge 与 Celeborn 0.5.3 的实际二进制兼容性、Worker 注册及正数远程 shuffle 数据仍待验证。
- 无性能实测数据；Draft PR 不合并，不更新基线。
