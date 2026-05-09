# sdx-test 评测失败分析（analyzer）

将失败样本转为可修复优先级清单。

## 输入

失败样本（prompt、分类、响应、grader 证据）；[SKILL.md](../SKILL.md)；[references/gates.md](../references/gates.md)、[references/workflow.md](../references/workflow.md)、[references/anti-patterns.md](../references/anti-patterns.md)、[references/design-principles.md](../references/design-principles.md)、[references/quality-checklist.md](../references/quality-checklist.md)。

## 输出（四段）

1. 失败模式归类  
2. 根因与证据  
3. 优先级修复  
4. 回归评测建议  

## 失败类型（可多选）

- **F1 路由**：should-trigger / should-not-trigger 误判  
- **F2 边界**：PRD/DSD/ASD/docs 与 TDD 主路径混淆  
- **F3 门禁**：缺 HARD-GATE、总确认、例外  
- **F4 结构**：缺六章意识、追溯或进出标准  
- **F5 PRD**：无 PRD 仍宣称可定稿且无依据  
- **F6 证据**：断言难复核  

## 修复（P0/P1/P2）

- **P0**：误路由、门禁违规  
- **P1**：边界、用例与 DSD 脱节、回归不可执行  
- **P2**：文案与样本  

每条须含：目标、最小变更、预期影响、≥1 回归用例。

## 回归

1. 先 P0，再全量  
2. 成对：`/sdx-test` vs `sdx-prd`、`sdx-design`、`sdx-architect`、docs-*、`sdx-solution`  
3. 同模式两轮失败 → 考虑规则重写  
