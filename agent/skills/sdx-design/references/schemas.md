# 评测 JSON 契约（sdx-design）

与 **skill-creator** 对齐，供流水线与 viewer 解析。

## `evals/evals.json`

| 字段 | 说明 |
|------|------|
| `skill_name` | `sdx-design` |
| `version` | 样本集版本 |
| `description` | 给人读的用途说明 |
| `evals[]` | 单条评测，见下 |

### 单条 `eval`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一，如 `design-trigger-001` |
| `category` | string | `should-trigger` \| `should-not-trigger` |
| `prompt` | string | 模拟输入 |
| `expected_output` | string | 期望要点 |
| `assertions` | array | 见下 |

### `assertions[]`

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 如 `gate-compliance` |
| `name` | string | 短标签 |
| `type` | string | `must_include`、`must_not_conflict` 等 |
| `check` | string | 可核对语句 |
| `priority` | string | `P0` \| `P1` |

断言语义遵循 [agents/grader.md](../agents/grader.md)。

## `evals/eval-metadata-template.json`

单回合元数据壳；替换占位符后与 `evals.json` 对齐。

## `grading.json` / grader 输出

字段 **`text`**、**`passed`**、**`evidence`**（勿用别名），否则 viewer 解析失败。

## 与脚本

- [validate-dsd.sh](../scripts/validate-dsd.sh)：章节/启发式校验，非 JSON schema。  
- 写前不再经 `preToolUse` gate；推进协议见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)。
