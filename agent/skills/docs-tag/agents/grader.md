# docs-tag — grader

据 prompt、响应与断言输出 **仅** JSON：`text`、`passed`、`evidence`。

**should-trigger** 例：

```json
{
  "text": "通过。复述参数、1-scan→1-write→2、根相对脚本路径。",
  "passed": true,
  "evidence": ["param-gate", "subphase-path"]
}
```

**should-not-trigger** 例：

```json
{
  "text": "通过。主轴 docs-extract，未框 tag 扛第三列。",
  "passed": true,
  "evidence": ["correct-downstream", "no-false-tag-primary"]
}
```

## 规则

- `must_include`：可归入满足即可（同义可）
- `must_not_conflict`：无明文反 `check`
- 任一 **P0** 败 → `passed: false`
- **推进协议**：轻流程 `C/M/S/F`（无 `G`、不绑意图澄清 / 语义族 grilling）；见 [light-flow-actions.md](../../../references/light-flow-actions.md)

材料：`SKILL.md`、`gates`/`workflow`、`gotchas`、eval 断言表。
