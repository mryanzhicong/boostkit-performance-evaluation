# 软件分类目录

`software/` 当前包含 `Database/redis` 一个软件测试用例，其余分类保留为空目录。

分类和各分类的软件注册列表由 `config/categories.yaml` 统一定义。空分类在 YAML 中直接留空；有软件时在分类下列出软件名。空分类目录中的 `.gitkeep` 只用于让目录能够被 Git 保存。

加入软件时必须同时完成注册和目录接入。Catalog 会双向校验：登记的软件必须存在对应 `case.yaml`，实际存在的用例也必须已经登记；同一软件不能出现在多个分类。

后续人工接入软件时，目录结构为：

```text
software/<category>/<software>/
├── case.yaml
├── <software>_test.sh
└── scripts/                 # 仅在用例需要辅助程序时创建
```

- `case.yaml`：使用 `execution.stages` 显式声明 build、start、test、stop 各自的 Shell 脚本和函数入口，使用顶级 `outputs` 声明每个结果的逻辑名称、路径、生成阶段、格式和必要性，并让 `metrics` 通过逻辑输出名声明指标提取规则；不得声明架构或 Runner 标签。
- `<software>_test.sh`：已有测试用例的阶段函数实现，通过环境变量接收版本、架构和输出目录。四个阶段键固定为 build、start、test、stop，但对应函数应使用 `build_<software>`、`start_<software>_service`、`run_<software>_benchmarks`、`stop_<software>_service` 一类易读名称，并在 `case.yaml` 中显式映射。脚本被加载时不得自动执行阶段，也不再接收阶段名进行分发。
- `scripts/`：软件私有的基准、结果转换或辅助程序；没有需要时不创建。

阶段函数结束前必须生成归属于该阶段的必要输出。Framework 会立即校验文件存在、非空以及声明的 JSON 格式；指标来源必须引用必要 JSON 输出的逻辑名称，不能直接依赖文件路径。软件脚本不生成通用日志、Markdown、文本摘要、跨架构报告或永久历史，这些由 Framework 统一负责。

固定性能方案的命令、并发、数据规模等软件专用参数只在软件脚本中维护，不在 `case.yaml` 复制一份。结果 JSON 应使用顶级 `parameters` 对象记录可跨架构比较的工作负载定义，机器相关解析值放入 `runtime_context`；Framework 将据此生成参数签名并校验两个架构的测试方案一致。需要多套方案时应在软件内部定义明确的 profile，再单独扩展清单选择能力。

当前阶段不自动生成测试用例。加入新软件前，应先人工编写并审核上述必要文件。
