# Cursor 项目配置

## Slash 命令（Skills）

| 命令 | 说明 |
|------|------|
| `/document-indexing` | 文档索引：为代码库/文档库生成面向下游 AI 的 Index Guide（拓扑/结构/精读三模式，七段标准输出，零幻觉路径精确）。 |
| `/agent-guide` | 生成/更新根目录 `AGENTS.md` 与 `README.md`；① document-indexing 产出 Index → ② agent-guide 产出 AGENTS/README |
| `/knowledge-build` | 知识库构建：① document-indexing 产出 Index → ② agent-guide 产出 AGENTS/README → ③ 按 Index 选择性阅读并写入 knowledge → ④ 验证。 |
| `/knowledge-upgrade` | 应用级知识库增量升级：① 应用内 document-indexing → ③ 按 applications/INDEX 与应用 knowledge 格式选择性阅读并回写 → ④ 验证（无 AGENTS/README 第二阶段）。 |
| `/knowledge-archive` | 归档 applications/ 知识库变更；将应用侧有效信息按 system/knowledge 与 CONTRIBUTING 规范上行补充系统库（联邦 SSOT、仅 ID 引用）。 |
| `/sdx-solution` | 解决方案阶段：需求提取与结构化 → 影响面评估 → 冲突识别与化解 → 方案制定与评估 → 文档输出与评审；产出 `solutions/SOLUTION-{ID}.md`，模板见 `.ai/rules/solution/solution-template.md`。 |
| `/sdx-analysis` | 需求分析阶段：深度研究与探索 → 需求细化与建模 → MVP 拆分与规划 → 依赖分析与风险评估 → 文档输出与评审；产出 `analysis/REQUIREMENT-{ID}.md`，模板见 `.ai/rules/analysis/requirement-template.md`。 |
| `/sdx-prd` | 需求交付·产品需求阶段：业务流程 → 用户故事与场景 → 用例建模 → 功能模块与交互设计 → 文档输出与评审；产出 `docs/requirements/.../PRD-{ID}.md`，模板见 `.ai/rules/requirement/prd-template.md`。 |
| `/sdx-design` | 需求交付·方案设计阶段：架构设计 → 详细设计 → 规约生成 → 文档输出与评审；产出 ADD、specs，模板见 `.ai/rules/requirement/add-template.md`。 |
| `/sdx-test` | 需求交付·测试设计阶段：测试策略与范围 → 测试用例设计 → 测试数据与环境 → 文档输出与评审；产出 TDD-{ID}.md，模板见 `.ai/rules/requirement/tdd-template.md`。 |

在 Chat 中输入 `/` 后选择对应命令即可调用（如 `/agent-guide`）；或使用 `@技能名`（如 `@agent-guide`、`@sdx-solution`）将 Skill 作为上下文附加。

**说明**：斜杠命令由 `.cursor/skills/<技能名>/SKILL.md` 提供，文件夹名即命令名（如 `skills/agent-guide` → `/agent-guide`）。
