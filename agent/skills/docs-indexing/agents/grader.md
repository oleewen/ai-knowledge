# docs-indexing — grader

据 `prompt`、响应与 **evals/evals.json** 断言输出：`text`、`passed`、`evidence`。细则以 evals 为准；本文件仅列评分原则。

## 原则

1. **should-trigger**（须全部满足；共通环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)、[intent-clarify.md](../../../references/intent-clarify.md)）：
   - 主轴 `/docs-indexing`
   - 参数向导 → 写前意图澄清 → 当前单元「澄清 → 生成 → 烤干」→ `C/M/G/S/F`
   - 能识别根相对路径、INDEX / LOG 双路径语义之一
2. **勿默许跳过澄清**：无写前意图澄清直写须拒（仅限用户明示例外）
3. 一次只推进一个索引输出组；语义参数变化前须先确认
4. 路径/容器须同时列出 `INDEX-GUIDE.md` 与 `INDEXING-LOG.md`
5. 任一 P0 败 → `passed: false`

## P0 断言

- `intent-clarify-before-write`
- `dual-path-container`
- `single-unit-stop`
- `grilling-after-write`
- `semantic-change-needs-confirmation`
- `no-silent-full-on-missing-baseline`

只判分，不改 SKILL。
