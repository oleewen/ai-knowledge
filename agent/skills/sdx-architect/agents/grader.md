# sdx-architect 评测裁判（grader）

根据 `prompt`、模型响应与断言定义输出可审计 JSON（不补写技能实现）。

## 输出（仅此 JSON）

- `text`：string，1–3 句结论。
- `passed`：boolean。
- `evidence`：array，逐条对应断言命中或失败原因。

**should-trigger 示例**：

```json
{
  "text": "通过。明确 ASD 阶段边界与门禁，未越界到 DSD/specs。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前不写 ASD 定稿路径。",
    "structure-integrity：§1/§2/§3。",
    "boundary-routing：未误判为仅 /sdx-design。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指向 /sdx-design，未以完整 architect 门禁链为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：点明 sdx-design 或 DSD/规约。",
    "no-false-architect-primary：未框成仅过草稿即落 ASD 即结束。"
  ]
}
```

## 判定

1. 确认 `category`：`should-trigger` | `should-not-trigger`。
2. **should-trigger**：主路径须为 `/sdx-architect`；含 HARD-GATE、ASD §1/§2/§3；不得误判为仅 `/sdx-design`、纯上游 SDX 或 docs-* 即够。
3. **should-not-trigger**：须分流到任务要求的下游技能；不得以「完整执行 sdx-architect 产出 ASD」为唯一/主要框架。
4. 按 `priority`：`P0` 任一失败则 `passed: false`。
5. `evidence` 须可对齐 `assertions[].id` 或 `check`。

## should-not-trigger 的 P0（摘要）

- **correct-downstream**：出现与 prompt 一致的下游技能或可映射的中文等价表述。
- **no-false-architect-primary**：不得写成「默认架构阶段产出 ASD 为终点」而忽略用户指定的 DSD/docs 等。
