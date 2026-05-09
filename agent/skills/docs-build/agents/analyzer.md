# docs-build — analyzer

失败样本 → P0/P1/P2 修复项。

## 输入

`SKILL.md`、`references/gates.md`、`workflow.md`、`anti-patterns.md`、`gotchas.md`

## 模式（多选）

- F1 路由误判
- F2 build ↔ indexing/distill/extract 混
- F3 门禁漏：Qclose-1、`CONFIRMED`、例外
- F4 缺四阶段/顺序/validate
- F5 误称无 spec gate（低风险幻觉）
- F6 证据薄

## 回归

对照：`/docs-build` vs `/docs-indexing`；build vs `sdx-*`。
