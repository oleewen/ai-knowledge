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
- **F3 协议回退**：退回已删除的 HTML gate / CONFIRMED / 会话 spec / 写前 hook 主线  
- **F4 参数向导缺失**：未体现逐项确认或快捷组合入口  
- **F5 段落循环缺失**：未体现意图澄清、分段「澄清 → 生成 → 烤干」、`C/M/G/F` 等协议  
- **F6 回改规则缺失**：前文回改、当前段重开、再澄清与再 grill 等约束缺失  
- **F7 证据不足**：结论难被断言复核  
- **F8 F 语义误解**：把 `F` 错写为提前结束流程、整篇重生成、覆盖已确认前文重写，或跳过剩余意图批确认  
- **F9 意图澄清缺失**：跳过写前六项清单/写前 `C` 直接写正文 

## 修复策略（P0/P1/P2）

- **P0**：误路由、参数向导/意图澄清/段落协议遗漏、`F` 语义误解（先修）  
- **P1**：边界不清、结构不全、与 sdx-analysis 衔接弱  
- **P2**：表述与样本覆盖优化  

每条须含：目标、最小变更（文件/段）、预期影响、≥1 条回归用例。

## 回归

1. 先跑 P0 相关样本，零回归再全量  
2. 边界样本成对验：`/sdx-solution` vs `/sdx-analysis`、`/sdx-prd`、`/sdx-architect`、docs-*  
3. 同模式连续两轮失败 → 考虑规则级重写  
