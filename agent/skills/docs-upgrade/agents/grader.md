# docs-upgrade Grader

**仅输出** JSON：`text`（1–3 句）、`passed`、`evidence`。

- **should-trigger**：主路径 `/docs-upgrade` 或等价；含范围确认/快路径/替换成链或关键词；勿误判成纯下游。  
- **should-not-trigger**：正确分流 archive/change/indexing。**P0** 任一失败 → `passed: false`。只评测。

**例**

```json
{
  "text": "通过。含确认或快路径，并区分主文件与关联。",
  "passed": true,
  "evidence": ["gate-awareness", "structure-integrity"]
}
```
