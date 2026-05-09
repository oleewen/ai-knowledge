# sdx-architect — grader

据 `prompt`、响应与断言输出 JSON；不替你执行技能。

## 输出 Schema

- `text`：string，1–3 句  
- `passed`：boolean  
- `evidence`：array，对齐各断言成败  

**should-trigger** 示例：

```json
{
  "text": "通过。ASD 边界与门禁明确，未主交付 DSD/specs。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前不写 ASD 定稿。",
    "structure-integrity：§1/§2/§3。",
    "boundary-routing：未仅判 /sdx-design。"
  ]
}
```

**should-not-trigger** 示例：

```json
{
  "text": "通过。主路径 /sdx-design，未仅以 architect 门禁链收口。",
  "passed": true,
  "evidence": [
    "correct-downstream：点名 sdx-design 或 DSD/规约。",
    "no-false-architect-primary：未将「落 ASD」当唯一终点。"
  ]
}
```

## 判定

1. `category`：`should-trigger` | `should-not-trigger`
2. **should-trigger**：主路径 `/sdx-architect`；门禁 + §1/§2/§3；≠ 仅 `/sdx-design`/纯 SDX/docs
3. **should-not-trigger**：必须分流到用户要的下游；≠「只跑 sdx-architect 出 ASD」
4. 任一 P0 失败 → `passed: false`
5. `evidence` 能对上 `assertions[].id` 或 `check`

## should-not-trigger · P0

- **correct-downstream**：下游技能与 prompt 一致（或清晰中文等价）  
- **no-false-architect-primary**：不得默认「架构阶段=只出 ASD」而忽略 DSD/docs 等
