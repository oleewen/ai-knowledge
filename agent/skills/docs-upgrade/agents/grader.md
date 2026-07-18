# docs-upgrade Grader

**仅输出** JSON：`text`（1–3 句）、`passed`、`evidence`。

## 判定

- **should-trigger**（须全部满足；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
  - 主路径 `/docs-upgrade` 或等价
  - 写前意图澄清 → 「澄清 → 生成 → 烤干」→ 当前单元与 `C/M/G/S/F`
  - 勿误判成纯下游
- **should-not-trigger**：正确分流 archive / change / indexing
- **P0** 任一失败 → `passed: false`；只评测

## P0 断言

- `intent-clarify`：写前六项清单 + 写前 `C` 门禁
- `unit-cycle`：澄清→生成→烤干主线
- `grilling-loop`：各当前单元默认必须烤干
- `single-unit-stop`：烤干收敛后停下等待动作
- `semantic-expansion-must-confirm`：关联/关键词扩展须先确认

材料：`SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`、本条 `expected_output`、`evals.json`。

**例**

```json
{
  "text": "通过。含意图澄清与澄清→生成→烤干，并区分主文件与关联。",
  "passed": true,
  "evidence": ["intent-clarify", "unit-cycle", "grilling-loop"]
}
```
