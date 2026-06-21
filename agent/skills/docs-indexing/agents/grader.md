# docs-indexing — grader

据 `prompt`、响应与 **evals/evals.json** 断言输出：`text`、`passed`、`evidence`。细则以 evals 为准；本文件仅列评分原则。

## 原则

1. **should-trigger**：主轴 `/docs-indexing`；含 Qclose-1、`docs-indexing-gate`、根相对路径清单、INDEX/LOG 语义之一
2. **勿默许跳过闸门**：无 spec 直写须拒或仅限用户明示例外
3. **勿称中风险 / 无需 specs / 无 indexing hook**（违 CONVENTIONS），除非 prompt 谈关钩例外
4. 任一 P0 败 → `passed: false`

只判分，不改 SKILL。
