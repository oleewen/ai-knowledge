# sdx-solution 评测失败分析（analyzer）

将失败样本转成可执行修复清单（非仅描述现象）。

## 输入

失败样本（含 prompt、期望分类、实际响应、grader 证据）；[SKILL.md](../SKILL.md)；[references/gates.md](../references/gates.md)、[references/workflow.md](../references/workflow.md)、[references/anti-patterns.md](../references/anti-patterns.md)、[gotchas.md](../gotchas.md)。

## 输出（四段）

1. 失败模式归类  
2. 根因假设与证据  
3. 优先级修复策略  
4. 回归评测建议  

## 失败类型（可多选）

- **F1 路由误判**：should-trigger 未触发或 should-not-trigger 误触发  
- **F2 边界混淆**：ANALYSIS/PRD/ASD 与「仅 SOLUTION」混淆  
- **F3 门禁遗漏**：未体现 HARD-GATE、spec 总确认、`PENDING`/`CONFIRMED`、合法例外  
- **F4 结构缺失**：七章/会话门禁/SOLUTION 约束缺失或与详设混写  
- **F5 阶段跳跃**：跳过阶段二或 Qclose-1 却宣称终稿且无例外依据  
- **F6 证据不足**：结论难被断言复核  

## 修复策略（P0/P1/P2）

- **P0**：误路由、门禁违规（先修）  
- **P1**：边界不清、结构不全、与 sdx-analysis 衔接弱  
- **P2**：表述与样本覆盖优化  

每条须含：目标、最小变更（文件/段）、预期影响、≥1 条回归用例。

## 回归

1. 先跑 P0 相关样本，零回归再全量  
2. 边界样本成对验：`/sdx-solution` vs `/sdx-analysis`、`/sdx-prd`、`/sdx-architect`、docs-*  
3. 同模式连续两轮失败 → 考虑规则级重写  
