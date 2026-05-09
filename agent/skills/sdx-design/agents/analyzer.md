# sdx-design 失败分析（analyzer）

把失败样本压成 **P0/P1/P2** 修复项，不靠现象堆砌。

## 输入

prompt、期望类别、响应、grader 证据；`SKILL.md` 与 `references/gates|workflow|anti-patterns|design-principles|quality-checklist`。

## 输出（四段）

归类 · 根因+证据 · 优先级修复 · 回归建议。

## 失败类型（可多选）

| 代号 | 含义 |
|------|------|
| F1 | 路由误判 |
| F2 | 边界混淆（ASD/PRD vs DSD vs docs-*）|
| F3 | 门禁遗漏 |
| F4 | 缺 §1–§4、上游或 **spec-dsd** 互指 |
| F5 | 无 ASD/spec-asd 仍宣称实现级定稿且无例外依据 |
| F6 | 证据无法被断言复核 |

## 修复项（每条含）

目标 · 最小变更（文件/段）· 影响 · ≥1 条回归用例。

## 回归

1. P0 相关样本归零再全量。  
2. 成对：design vs architect；design vs docs-* / docs-build；design vs **sdx-test**（纯 TDD）。  
3. 同模式两轮失败 → 考虑规则重写。
