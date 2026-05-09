# docs-distill Grader

**仅输出** JSON：`text`（1–3 句）、`passed`、`evidence`。

**判定**：  
- **should-trigger**：主路径 `/docs-distill` 或等价；含 HARD-GATE、PENDING/CONFIRMED（或例外）、双日志、`dry-run`（若适用）；勿误判成仅 indexing/archive/SDD。  
- **should-not-trigger**：正确分流 docs-extract 等。**P0** 任一失败 → `passed: false**。只评测，不改技能。

材料：`SKILL.md`、`gates`、`workflow`、`gotchas`、`evals`。

**例**

```json
{
  "text": "通过。含阶段 3 与 dry-run；PENDING 下未谎称已写 overview。",
  "passed": true,
  "evidence": ["gate-compliance", "distill-scope"]
}
```
