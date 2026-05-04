# docs-pull 与 brainstorming / SDD 的边界

`docs-pull` 的预检是 **「高风险参数与写盘事实确认」**，**不是** superpowers `/brainstorming` 的设计产出链，也**不是** `sdx-solution` 的会话 spec + G1–G7 门禁。

---

## 何时应离开本技能

- 重组 `applications/` 拓扑、合并多远端、改联邦契约 → 先设计 / ADR / 方案确认，再回 manifest 与脚本事实。
- 写入 `system/architecture/overview/` 第三列 → **docs-extract** / **docs-distill**。
- 写 `SOLUTION-*` / `ASD-*` 等 → **sdx-***。

---

## 可借鉴的节奏（仅形式）

「单次一个待确认点」「先 dry-run」与 brainstorming **形式**相近，但**不要求** `docs/superpowers/specs/*-design.md` 或 `…-sdx-solution.md` 作为门槛。详见 [gates.md](gates.md)。
