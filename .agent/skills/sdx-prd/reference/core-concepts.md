# 核心概念口径（sdx-prd）

与 [workflow-spec.md](workflow-spec.md) 中的术语一致；三阶段流程与算法落位见该文件。

## IDEA-ID

**IDEA-ID** 的定义见 [sdx-solution：core-concepts §IDEA-ID](../../sdx-solution/reference/core-concepts.md#idea-id)。

本阶段终稿路径示例：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md`；上游 `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`。目录名、文件名须共用同一 **IDEA-ID**，`{N}` 为 MVP 阶段编号，与 `--mvp` 及 `mvp_phase` 一致。

| 概念 | 口径 |
|------|------|
| **业务流程设计** | 主流程与分支/异常流程；参与角色、输入输出、业务规则；跨系统交互（可 Mermaid） |
| **用户故事建模** | INVEST；Given-When-Then 验收标准；覆盖正常/备选/异常/边界；关联 FR-n、BR-n |
| **用例建模** | 用例图 + 用例描述（参与者、前后置、主成功场景、扩展场景、业务规则引用）；与 US-n 双向映射 |
| **功能模块设计** | 按**业务能力域**划分模块与关系；信息架构、操作流程、校验与反馈 |
| **PRD 文档** | 严格遵循 [../assets/prd-template.md](../assets/prd-template.md) 十一章结构 |
