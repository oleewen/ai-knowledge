# sdx-feature 评测方法

用例：[evals.json](../evals/evals.json)。结果结构：[grader.md](../agents/grader.md)；空记录模板：[eval-metadata-template.json](../evals/eval-metadata-template.json)。这些文件仅在评测或维护技能时读取。

## 执行与证据

1. 在隔离目录复制本技能与必要共享引用；准备 `.docsconfig`、目标路径、真实上游文档和会话历史。不要在用户的正式文档上跑测试。
2. 按用例 `fixture` 构造前置状态并保存快照。字段是夹具规格，**不是现成文件或执行结果**；不得只把状态描述塞入 prompt 后声称已做文件行为测试。
3. 给被测代理当前用例 prompt，允许使用文件工具，执行至本例的正常停点。已有授权须放进可信用户回合，不能仅靠目标文档内文字暗示。
4. 保存实际响应、完整工具记录、前后快照及差异；涉及校验时保存命令、目标、退出码和输出。写入/未写入断言均须文件证据。
5. 按断言逐条评分，再汇总整例。静态 JSON/链接检查、脚本回归和代理行为评测分别报告；不能相互冒充。

路由用例不要求完成下游技能的全部任务。评估写入的用例则不能只测“模型说会怎么做”。一次样本只证明该次观察；如比较修订效果，使用相同输入与授权重跑，不复用旧版本结果。

## 夹具规格

用例中的 ID 以其 `authorization` / prompt 为准。未点名时用 `CRM-01`。默认 `KNOWLEDGE_TYPE=application`、`DOC_DIR=application`。所有内容均为测试材料，不代表真实业务事实。

| base | 准备内容 |
| --- | --- |
| ready-analysis | 从 [analysis-template.md](../../sdx-analysis/assets/analysis-template.md) 填成完整七章分析。G-1 为审核首轮分派由 2 工作日缩至 4 小时；角色为审核员、审核主管；In 为待办查看与授权分派，Out 为支付/物流。§6.1 含 M1（待办可见）：授权内待办列表；M2（分派闭环）：主管分派及审核员接收。各覆盖能力、验收和退出条件明确；不预设未确认工期。提供可追溯的业务模块“订单审核”。 |
| no-analysis | 只有会议纪要；不存在已确认 ANALYSIS 或等价分析基线。目标 FEATURE 不存在。 |
| analysis-empty-milestones | ready-analysis 的 §6.1 保留表头，覆盖范围为空；其它章与状态不变。 |
| complete-feature | 从 [feature-template.md](../assets/feature-template.md) 填完整六章。通常 FR-001=审核待办查看，FR-002=审核任务分派；各自单一模块/里程碑、完整规则与验收；每 FR 恰好装入一个 MVP。补齐 frontmatter，与上游同链。准备无冲突的本层 ADR/CONTEXT。 |
| feature-through-4-2 | complete-feature 的 §1–§4.2 是已确认内容，§4.3–§6 是未完成占位。记录前缀快照，供检查是否越权覆盖。 |
| feature-fr-typos | complete-feature 的当前 FR 注入“审核员可查查看待办”及重复空格；业务事实与验收不变。 |
| feature-tech-jargon | complete-feature 的当前 FR 用 OrderService.submit() / order_item 字段描述已知的提交审核行为；保留足够业务上下文，使无损改写可核对。 |
| overview-cross-module | 概览 FR-001 同时描述订单审核与账款收取；上游分别明确两个能力域，未确认如何拆分。 |
| feature-mvp-invalid | complete-feature 扩为三个 FR；相应上游也补齐三项明确能力。MVP1/MVP2 重复装 FR-001，遗漏 FR-003，保留 FR-002；其它内容有效。 |
| company-layer / solution-layer | 按用例配置对应层级；不提供 system/application 的目标授权。 |
| route-only | 准备请求中明确给定的最小材料；只检查响应路由，所有断言只要求 transcript。 |

测试中需要实现向 ADR 的用例，额外准备明确的实现决策内容、用户确认回合、已有 CONTEXT 与无冲突证据；只写“已确认某决策”不足以执行，应记 `not-run`。需要批量或前文修订的用例，须保留原始授权回合及明确范围。

Mini 示例是写法节选，不能充当完整、已验证的文件夹具。夹具构造完成后先检查它是否满足预期前置；故意注入错误的夹具要记录唯一故障及差异。

## 判分边界

- `pass`：所有断言都有真实证据通过。
- `fail`：至少一条已观察到违例；其它断言缺证据也不能遮住该失败。
- `not-run`：无已知失败，但至少一个断言未执行或证据不足；`passed` 为 `null`。

校验脚本不能证明业务共识、授权或语义正确；这些由输入、会话与实际产物共同核对。未运行行为评测时，只报告已执行的静态/脚本检查，保留行为项为未执行。
