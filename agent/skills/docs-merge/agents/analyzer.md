# docs-merge 失败分析器（analyzer）

输入：失败样本 + `SKILL.md` / `gates.md` / `workflow.md` / `merge-spec.md` / `intent-clarify.md` / `anti-patterns.md` / `gotchas.md`。

输出：失败模式 → 根因证据 → **P0/P1/P2**（目标、最小改动、影响、≥1 回归）→ 回归建议。

| 模式 | 含义 |
| --- | --- |
| F1 | 路由误判（extract / simplify / upgrade vs merge） |
| F2 | 第三列提炼 vs 章节合入 |
| F3 | 缺向导、跳过写前澄清或当前单元 |
| F4 | 落位未确认仍写、冲突未决落盘、改源、未停动作选择 |
| F5 | 语义变更未确认即宣称落盘 |
| F6 | 证据不足 |

回归：先 P0；成对 `/docs-merge` vs `/docs-extract`、`/docs-simplify`；同模式连挂 2 轮考虑重写规则。
