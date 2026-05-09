# sdx-architect — analyzer

把失败样本压成「可改什么、先改哪里」。

## 输入

样本（prompt、期望分类、响应、grader 证据）；`SKILL.md`、`references/*.md`。

## 输出（四段）

1. 模式归类  
2. 根因 + 证据  
3. 修复优先级 P0/P1/P2  
4. 回归建议  

## 失败类型（可多选）

| 代号 | 含义 |
|------|------|
| F1 | 路由错：触发类未触发 / 不该触发误触发 |
| F2 | 边界混：DSD/specs≈ASD 或 docs≈architect |
| F3 | 门禁漏：总确认、例外、HARD-GATE |
| F4 | 结构缺：无 §1/§2/§3 |
| F5 | 联邦歪：system/company 仍落实现级 |
| F6 | 证据薄：对上断言却对不上条文 |

## 修复项（每条）

目标 · 最小改动（文件/段）· 影响 · ≥1 条回归样例。

## 回归

1. P0 相关样本归零再全量  
2. 对照：`/sdx-architect` ↔ `/sdx-design`；architect ↔ docs-distill/extract/archive/indexing  
3. 同模式两轮仍败 → 考虑改规则不单改文案
