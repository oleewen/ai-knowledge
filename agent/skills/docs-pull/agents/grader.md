# docs-pull Grader

**仅输出** JSON：`text`（1–3 句）、`passed`、`evidence`。

- **should-trigger**：联邦镜像为主；manifest/分支/`repo_url`/写盘前确认或 `--dry-run`；**勿**谎称必须 `superpowers/spec` HTML `CONFIRMED`（另有用户要求除外）。  
- **should-not-trigger**：分流 distill/extract/SDD。**P0** 任一失败 → `passed: false`。只评测。

**例**

```json
{
  "text": "通过。低风险闸门 + applications/app-*，未捏造 spec gate。",
  "passed": true,
  "evidence": ["gate-awareness", "scope-federal-mirror"]
}
```
