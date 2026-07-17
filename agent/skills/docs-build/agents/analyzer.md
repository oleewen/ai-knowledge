# docs-build — analyzer

失败样本 → P0/P1/P2 修复项。

## 输入

`SKILL.md`、`references/gates.md`、`workflow.md`、`anti-patterns.md`、`gotchas.md`

## 模式（多选）

- F1 路由误判
- F2 build ↔ indexing/distill/extract 混
- F3 缺参数向导、意图澄清或当前单元
- F4 缺执行顺序/validate/动作停顿
- F5 语义变更未确认或校验失败仍继续
- F6 证据薄
- F7 路径/容器缺 knowledge 批次信息
- F8 写前 grilling 与意图澄清混名

## 回归

对照：`/docs-build` vs `/docs-indexing`；build vs `sdx-*`；与 intent-clarify 契约一致性。
