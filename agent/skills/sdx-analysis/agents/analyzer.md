# sdx-analysis 评测失败分析（analyzer）

将失败样本转为可执行修复清单。

## 输入

失败样本（prompt、分类、响应、grader 证据）；[SKILL.md](../SKILL.md)；[references/gates.md](../references/gates.md)、[references/workflow.md](../references/workflow.md)、[references/anti-patterns.md](../references/anti-patterns.md)、[gotchas.md](../gotchas.md)。

## 输出（四段）

1. 失败模式归类  
2. 根因与证据  
3. 优先级修复  
4. 回归建议  

## 失败类型（可多选）

- **F1 路由**：should-trigger / should-not-trigger 误判  
- **F2 边界**：SOLUTION、PRD、ASD 与 ANALYSIS 混淆  
- **F3 门禁**：缺 HARD-GATE、总确认、`PENDING`/`CONFIRMED`、例外  
- **F4 结构**：缺六章/门禁或与 SOLUTION 脱节  
- **F5 跳跃**：跳阶段二或 Qclose-1 且无例外  
- **F6 证据**：断言难以复核  

## 修复（P0/P1/P2）

- **P0**：误路由、门禁违规  
- **P1**：边界、结构、与 SOLUTION 衔接  
- **P2**：文案与样本覆盖  

每条须含：目标、最小变更（文件/段）、预期影响、≥1 回归用例。

## 回归

1. 先 P0 样本，再全量  
2. 成对：`/sdx-analysis` vs `sdx-solution`、`sdx-prd`、`sdx-architect`、docs-*  
3. 同模式两轮失败 → 考虑规则级重写  
