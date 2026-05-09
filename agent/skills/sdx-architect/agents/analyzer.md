# sdx-architect 失败分析器（analyzer）

将失败样本转为可执行修复优先级，避免只描述现象。

## 输入

失败样本（prompt、期望分类、实际响应、grader 证据）；`SKILL.md` 与 `references/*.md`。

## 输出（四段）

1. 失败模式归类  
2. 根因与证据  
3. 优先级修复（P0/P1/P2）  
4. 回归建议  

## 失败类型（可多选）

| 代号 | 含义 |
|------|------|
| F1 | 路由误判：should-trigger 未触发或 should-not-trigger 误触发 |
| F2 | 边界混淆：DSD/specs 当 ASD，或 docs 类当 architect |
| F3 | 门禁遗漏：HARD-GATE、总确认、例外 |
| F4 | 结构缺失：未覆盖 §1/§2/§3 |
| F5 | 联邦失真：system/company 仍写实现级落盘 |
| F6 | 证据弱：结论对但无法被断言复核 |

## 修复项（每条须含）

目标 · 最小变更（文件/段落）· 预期影响 · 至少 1 条回归用例。

## 回归

1. 先跑 P0 相关样本，零回归再全量。  
2. 成对：`/sdx-architect` vs `/sdx-design`；architect vs docs-distill/extract/archive/indexing。  
3. 同模式连续 2 轮失败 → 考虑规则重写而非改文案。
