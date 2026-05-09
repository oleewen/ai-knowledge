# sdx-design 评测裁判（grader）

据 `prompt`、响应与断言输出**唯一 JSON**，不给出技能重写方案。

## 输出（字段）

`text`（1–3 句）、`passed`（bool）、`evidence`（逐条对齐断言）。

**should-trigger 示例**：

```json
{
  "text": "通过。主路径为 DSD 与 requirements/…/specs/spec-dsd-*.md；含上游与未确认不写 DSD。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前不写 DSD 定稿路径。",
    "structure-integrity：§1–§4、spec-dsd 与 ASD/spec-asd。",
    "boundary-routing：未误判为仅 architect 或仅 docs-*。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。分流到 ASD/architect，未以完整 design 门禁为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：点明 architect 或 ASD。",
    "no-false-design-primary：未写成仅草稿即落 DSD 即结束。"
  ]
}
```

## 判定

1. `category`：`should-trigger` | `should-not-trigger`。  
2. **should-trigger**：主路径 **`/sdx-design`**；含 HARD-GATE、上游 **ASD 与/或 spec-asd-***、**DSD §1–§4** 与（应用全量时）**spec-dsd-*.md**；勿误判为仅 architect、上游 SDX 或 docs-*。（不要求 YAML 分包树。）  
3. **should-not-trigger**：须分流至正确技能；勿以「先完整跑 design 写 DSD」为唯一框架。  
4. **P0** 任一失败 → `passed: false`。  
5. `evidence` 对齐 `assertions[].id` 或 `check`。

### should-not-trigger 的 P0

- **correct-downstream**：可映射到目标 skills/slash。  
- **no-false-design-primary**：勿写「默认详设+DSD/spec 为终点」而忽略用户指定的上游或其它阶段。
