# 软件分类目录

`software/` 当前包含 `Database/redis` 一个软件测试用例，其余分类保留为空目录。

允许的分类由 `config/categories.yaml` 统一定义：`AI`、`Bigdata`、`Storage`、`Database`、`Media`、`HPC`、`Middleware`、`Toolchain` 和 `Others`。空分类目录中的 `.gitkeep` 只用于让目录能够被 Git 保存。

后续人工接入软件时，目录结构为：

```text
software/<category>/<software>/
├── case.yaml
├── <software>_test.sh
└── scripts/                 # 仅在用例需要辅助程序时创建
```

- `case.yaml`：声明软件版本、staged command 接口、正式参数、预期输出和指标方向；不得声明架构或 Runner 标签。
- `<software>_test.sh`：已有测试用例的执行入口，接收版本、架构、输出目录和阶段名，并实现 build、validate、start-service、test、stop-service、collect-report。
- `scripts/`：软件私有的基准、结果转换或辅助程序；没有需要时不创建。

当前阶段不自动生成测试用例。加入新软件前，应先人工编写并审核上述必要文件。
