# 核心概念（sdx-prd）

## IDEA-ID

沿用上游 IDEA-ID；定义见 [sdx-analysis：IDEA-ID](../../sdx-analysis/references/core-concepts.md#idea-id)。

| 项目 | 对应值 |
| --- | --- |
| 直接上游 | `{DOC_DIR}/features/FEATURE-{IDEA-ID}.md` |
| PRD 路径 | `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/PRD-{IDEA-ID}-{N}.md` |
| `id` | `PRD-{IDEA-ID}-{N}`，与文件名一致 |
| `parent` | `FEATURE-{IDEA-ID}` |
| `mvp_phase` | `MVP-Phase-{N}`，与目录及 FEATURE 阶段一致 |

`N` 为正整数。IDEA-ID 可以含连字符，解析文件名时以最后一段数字识别 `N`。沿用既有实体编号，不因精简或补段重编号。

## 追溯关系

| 对象 | 对齐依据 |
| --- | --- |
| US | 当前 MVP 的 FR；规则引用 BR |
| UC | 与 US 双向映射；参与者使用业务角色 |
| BR | 继承 FEATURE 的规则；按需回溯其 ANALYSIS 或已引用 knowledge |
| EX | 指向流程步骤、触发条件与处理方式 |
| AC | 指向 US，包含可观察的验收条件 |
| NAC | 指向 §9 的指标与度量；不适用时说明理由 |

ANALYSIS / SOLUTION 是背景与溯源材料，不是 `parent`；只读取本段需要且已核实的内容。

## 术语快照

| 概念 | 口径 |
| --- | --- |
| 业务流程 | 主、分支、异常；角色与输入输出；规则用 BR 引用 |
| 用户故事 | 角色、能力、价值；可独立演示；正常与边界/异常 GWT |
| 用例 | 图与 UC 描述对应，含前后置、主成功与扩展场景 |
| 功能模块 | 业务能力域，不按前后端或中间件分层 |
| 深度 | `quick` 聚焦补段；`standard` 常规细化；`deep` 深化异常与验收。均保留模板和当前 MVP 边界 |
