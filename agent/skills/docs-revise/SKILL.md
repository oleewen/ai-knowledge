---
name: docs-revise
description: >
  定向修订 Markdown、注释和配置中的文档性文本，用于术语统一、事实/表述/链接纠错及关联文档同步。
  用户指定替换映射或使用 /docs-revise 时适用；整篇结构精简与 SSOT 去重用 docs-simplify，索引重建和 overview 归档用对应技能。
---

# docs-revise

在确认的范围内修订同一概念，检查受影响引用，并提供可核对的变更与验证结果。

仅收集版本变更供后续索引时，先用 `git log` / `git diff` 获取变更证据；需要更新索引再转 `docs-indexing`，不进入正文修订流程。

## 执行

1. 先读请求中的路径与检索限制。目标已点名时，首次文档操作直接读取这些路径；`rg --files` 只用于目标未定位且允许查找的情况。收口改动、语义边界和关联范围；只有缺口会影响决策时才追问。简写解析见 [core-concepts.md](references/core-concepts.md)。
2. 按 [gates.md](references/gates.md) 确认当前单元，再依 [workflow.md](references/workflow.md) 修改、烤干和停顿。已有明确授权继续有效。
3. 需要关联同步时，按 [related-doc-discovery.md](references/related-doc-discovery.md) 检查一层入站/出站；无直接链接的同概念表述再读 [semantic-keyword-discovery.md](references/semantic-keyword-discovery.md)。检索命中只产生候选。
4. 用 [quality-checklist.md](references/quality-checklist.md) 核对实际 diff、引用及受众；报告已改文件、验证结果和未处理候选。

## 约束

- 单元是一个主文件或一个已确认批次。用户限定「仅本文件 / 不要关联 / 不要全库搜」时，以该限制为边界。
- 术语相同不等于概念相同。标题锚点、ID、配置键、代码字面量和历史引文须单独判断，不能随正文批量替换。
- 无法核实的事实、路径或承诺标为待确认，不补造。
- 涉及四层 `knowledge/` 时，先读 [knowledge-governance.md](../../knowledge/knowledge-governance.md) 的业务引用边界；不得链接到 knowledge 外文档、下层文档或手写跨层爬链。跨层 HTTP 用规定生成函数，无 parent 则纯 ID；无法判断时停问。

## 按需读取

| 情形 | 资源 |
| --- | --- |
| 需要展示范围与授权 | [范围模板](assets/docs-revise-scope-ack-template.md) |
| 意图多解或候选过多 | [范围预检](references/brainstorming-integration.md) |
| 受众口吻与信息边界 | [audience-and-language.md](references/audience-and-language.md) |
| 复核常见失误 | [gotchas.md](gotchas.md) |
| 维护或评测技能 | [evaluation.md](references/evaluation.md) |

烤干修订后的 hunk 精简遵循 [单元推进协议](../../references/unit-cycle-protocol.md)，不嵌套完整 docs-simplify 环。收敛后仍需整篇结构或去重时，再交 docs-simplify。
