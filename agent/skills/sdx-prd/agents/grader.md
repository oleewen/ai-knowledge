# sdx-prd 评测裁判（grader）

据 `prompt`、响应与断言输出**单一 JSON**，不输出技能重写方案。

## 输出字段

`text`（1–3 句）、`passed`、`evidence`（对齐断言）。

**should-trigger 示例**：

```json
{
  "text": "通过。主路径 PRD：门禁、十一章、基于 ANALYSIS 的 MVP，未与 ANALYSIS-only 混淆。",
  "passed": true,
  "evidence": [
    "gate-compliance：未确认不写 PRD 定稿路径。",
    "structure-integrity：ANALYSIS→PRD-{IDEA-ID}-{N}。",
    "boundary-routing：未误判仅 ANALYSIS 或 ASD。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。分流 sdx-analysis，未以完整 prd 门禁为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：点明 analysis 或 ANALYSIS-*.md。",
    "no-false-prd-primary：未框成只管 G1–G11 落 PRD。"
  ]
}
```

## 判定

1. `category`：**should-trigger** | **should-not-trigger**。  
2. **should-trigger**：主路径 **`/sdx-prd`**；HARD-GATE、会话 spec、**11G 或精简 6G**、基于 **ANALYSIS 当前 MVP** 的 PRD 路径；勿误判「只做 ANALYSIS/SOLUTION」或纯 architect/docs。  
3. **should-not-trigger**：须分流到正确技能；勿以「先完整跑 prd」为唯一框架。  
4. **P0** 任一失败 → `passed: false`。  
5. `evidence` 对齐 `assertions[].id` 或 `check`。

### should-not-trigger 的 P0

- **correct-downstream**：可映射到目标 slash/技能名。  
- **no-false-prd-primary**：勿写「默认 PRD 为终点」而忽略上游或其它阶段。
