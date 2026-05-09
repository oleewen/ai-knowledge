# sdx-prd 失败分析（analyzer）

把失败样本压成可执行修复项，不靠现象堆砌。

## 输入

prompt、期望类、响应、grader 证据；`SKILL.md`；`gates|workflow|anti-patterns|design-principles|quality-checklist|gotchas`。

## 输出（四段）

归类 · 根因+证据 · P0/P1/P2 修复 · 回归建议。

## 失败类型（可多选）

| 代号 | 含义 |
|------|------|
| F1 | 路由误判 |
| F2 | 边界混淆（ANALYSIS/SOLUTION/ASD ↔ PRD；纯 PRD 误判下游） |
| F3 | 门禁遗漏（HARD-GATE、spec、PENDING/CONFIRMED） |
| F4 | 缺十一章/G 映射或与 ANALYSIS/MVP 脱节 |
| F5 | 跳阶段二或 Qclose-1 直终稿且无例外 |
| F6 | 结论无法被断言复核 |

## 修复项（每条含）

目标 · 最小变更（文件/段）· 影响 · ≥1 回归用例。

## 回归

1. P0 样本零回归 → 全量。  
2. 成对：**sdx-prd** vs **sdx-analysis**；vs **sdx-solution**/architect；vs docs-distill/extract/indexing。  
3. 同模式两轮失败 → 考虑规则重写。
