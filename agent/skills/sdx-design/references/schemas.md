# 评测与 JSON 结构（sdx-design）

与 **skill-creator** 约定对齐：机器可读断言、评分产物与流水线字段须一致，便于 `eval-viewer` 与人工复核。

---

## `evals/evals.json`（样本集）

| 字段 | 说明 |
|------|------|
| `skill_name` | 固定 `sdx-design` |
| `version` | 样本集版本号 |
| `description` | 本文件用途（给人读） |
| `evals[]` | 见下单条 `eval` |

### 单条 `eval` 对象

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一标识，如 `design-trigger-001` |
| `category` | string | `should-trigger` 或 `should-not-trigger` |
| `prompt` | string | 模拟用户输入 |
| `expected_output` | string | 期望响应要点（给 grader/人审） |
| `assertions` | array | 断言列表，见下 |

### `assertions[]` 项

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 如 `gate-compliance` |
| `name` | string | 短标签 |
| `type` | string | 如 `must_include`、`must_not_conflict`、`should_include` |
| `check` | string | 可客观核对的判定语句 |
| `priority` | string | `P0`（硬）或 `P1`（软） |

**权威断言语义**：跑分/子代理 grading 须遵循 [agents/grader.md](../agents/grader.md)。

---

## `evals/eval-metadata-template.json`

单条评测回合的元数据壳；复制后把 `REPLACE_WITH_EVAL_ID` 等替换为真实值。断言数组可与 `evals.json` 同源复制。

---

## `grading.json`（grader 输出，供 viewer）

`agents/grader.md` 要求每条期望使用字段 **`text`**、**`passed`**、**`evidence`**（勿用 `name`/`met` 等别名），否则 eval-viewer 解析失败。

---

## 与仓库脚本的关系

- 结构化 DSD 检查：[scripts/validate-dsd.sh](../scripts/validate-dsd.sh)（非 JSON schema，为章节/元数据/引用启发式校验）。
- 写入拦截：`agent/hooks/sdx_gate_common.py --gate design`（见 SKILL.md「工程化支持」）。
