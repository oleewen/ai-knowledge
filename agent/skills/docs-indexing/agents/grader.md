# docs-indexing — grader

据 `prompt`、响应与 **evals/evals.json** 断言输出：`text`、`passed`、`evidence`。细则以 evals 为准；本文件仅列评分原则。

## 原则

1. **should-trigger**：主轴 `/docs-indexing`；能识别参数向导、当前单元、根相对路径、INDEX/LOG 语义之一
2. **勿默许跳过确认**：无参数收口直写须拒或仅限用户明示例外
3. 重点检查是否一次只推进一个索引输出组，是否在语义参数变化前先确认
4. 任一 P0 败 → `passed: false`

## P0 断言

- `single-unit-stop`
- `semantic-change-needs-confirmation`
- `no-silent-full-on-missing-baseline`

只判分，不改 SKILL。
