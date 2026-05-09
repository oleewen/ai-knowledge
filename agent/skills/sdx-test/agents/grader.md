# sdx-test 评测裁判（grader）

据 `prompt`、响应与断言输出唯一 JSON：**text**（1–3 句）、**passed**、**evidence**。

**should-trigger 示例**：

```json
{
  "text": "通过。主路径为 TDD/会话 spec，含未确认不写终稿与 PRD/DSD 追溯。",
  "passed": true,
  "evidence": [
    "gate-compliance：总确认前禁写 TDD 定稿路径。",
    "structure-integrity：六章或用例/回归/进出标准。",
    "boundary-routing：未仅 sdx-prd 或纯 docs-*。"
  ]
}
```

**should-not-trigger 示例**：

```json
{
  "text": "通过。主路径指 sdx-prd/PRD，未以完整 sdx-test 为唯一交付。",
  "passed": true,
  "evidence": [
    "correct-downstream：PRD 或 /sdx-prd。",
    "no-false-test-primary：未框成过 Gn 即落 TDD 结束。"
  ]
}
```

## 判定

1. `category`：`should-trigger` / `should-not-trigger`  
2. **should-trigger**：主路径 **`/sdx-test`**；须 HARD-GATE（未确认不写 `…/TDD-*.md`）、**PRD 基线**、TDD/用例/回归/进出等意识；不得误判为仅 **sdx-design**、仅 **sdx-prd** 或 **docs-*** 即够  
3. **should-not-trigger**：须拒绝本技能为主路径或明确分流；不得「先完整 sdx-test 再写 TDD」为唯一框架  
4. **P0** 任一失败 → `passed: false`  
5. `evidence` 映射 `assertions[].id` 或 `check`  
6. 不写实现方案  

### should-not-trigger 的 P0

- **correct-downstream**：与 prompt 一致的技能或产物（可中文，须可映射）  
- **no-false-test-primary**：不得忽略用户已指定阶段而默认 TDD 为终点  
