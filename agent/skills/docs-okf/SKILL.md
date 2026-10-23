---
name: docs-okf
description: >
  刷新 OKF bundle 的目录 index.md、生成 viz.html 并校验产物。
  用于 /docs-okf、OKF refresh、validate-okf 或 OKF 可视化更新。
  九章 INDEX-GUIDE 重建用 docs-indexing；实体提取及第四章视角导航用 docs-build。
---

# docs-okf

维护已有 OKF bundle。先确定目标工程、模式及可选 bundle；已有明确输入直接使用，缺项才询问。

## 执行

1. 读取目标工程 `.docsconfig`，按 [路径解析](references/path-resolution.md) 定位 bundle 与脚本树。配置无效或缺键即停止，不猜路径、不回退仓库内 `agent/`。
2. 按 [工作流](references/workflow.md) 运行所选模式：

   | 模式 | 结果 |
   | --- | --- |
   | `refresh` | 补治理文档 frontmatter，刷新目录索引、生成 viz，再校验 |
   | `validate` | 校验 bundle 与 index/viz 产物 |
   | `viz` | 仅重建可视化 |
   | `dry-run` | 仅打印 refresh 命令，不写盘、不执行校验 |

3. 任一步失败即停，报告失败阶段及已产生的文件；校验 ERROR 不得降为 WARN 后继续。摘要列 bundle、index/viz 写入情况、两类校验结果及第四章导航块状态；未执行的检查明确标注。

这是轻量运维流程，不引入单元循环或 grilling。交付摘要前按 [受众 A/B](../../references/audience-and-language.md#轻流程-ab含-okf) 检查工程维护者所需信息。

## 约束

- `generate_index.py` 更新根 `index.md` 的 OKF 标记块；子目录索引写入规则见工作流。九章骨架与实体导航分别由 [docs-indexing](../docs-indexing/SKILL.md)、[docs-build](../docs-build/SKILL.md) 维护。
- `knowledge-links.yaml` 的 `path` 使用 `${WORK_SPACE}/…`，按所属库配置展开；缺配置、旧格式或越界即停。详见 [knowledge-links 路径契约](../../knowledge/federation-config.md#knowledge-links-路径契约)。
- 修改 knowledge 索引或产物须遵守同一治理文件的「业务 knowledge 引用边界」：不得引入爬层、下层或 knowledge 外文档链；跨层 HTTP 仅由约定生成函数产生。

## 按需查阅

| 需要 | 资料 |
| --- | --- |
| 命令、写入范围、失败分流 | [workflow.md](references/workflow.md) |
| 配置门禁、覆盖优先级、嵌套路径 | [path-resolution.md](references/path-resolution.md) |
| 维护脚本、兼容入口与测试 | [scripts.md](references/scripts.md) |
| OKF 格式与命名 | [okf-spec.md](../../knowledge/okf-spec.md)、[naming-conventions.md](../../knowledge/naming-conventions.md) |
| 行为评测 | [evals.json](evals/evals.json)、[grader.md](agents/grader.md) |
