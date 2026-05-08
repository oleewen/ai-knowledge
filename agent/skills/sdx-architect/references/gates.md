# sdx-architect 门禁规则

[SKILL.md](../SKILL.md) 为主干；流程与阶段见 [workflow.md](workflow.md)。

---

## 核心门禁

- 流程顺序必须为：准备 -> 会话草稿 -> 用户总确认 -> ASD落盘 -> validate。
- **总确认前，禁止写入** `{DOC_DIR}/requirements/**/ASD-*.md`。

## 合法例外

仅以下场景可在总确认前写入 ASD 正式文件：

1. **用户明确要求**跳过门禁并直接写入。
2. 环境变量显式开启：`SDX_ARCHITECT_ALLOW_ASD_WRITE=1`。

除以上两项外，一律按门禁执行。

## 状态建议

- `PENDING`：草稿阶段，未获总确认。
- `CONFIRMED`：已获总确认，可执行落盘。

## 会话 spec HTML 标记（与 validate-asd 一致）

会话草稿（如 `docs/superpowers/specs/...`）中须使用**固定字面量**（区分大小写），供 `validate-asd.sh --gate-check` 检索：

- 草稿：`<!-- sdx-architect-gate: PENDING -->`
- 已确认：`<!-- sdx-architect-gate: CONFIRMED -->`

另须在同一会话 spec 正文中出现目标 **`ASD-*.md` 完整文件名**，与落盘文件一致。

## 执行检查点

- 落盘前检查是否满足 `CONFIRMED` 或合法例外。
- 落盘后必须执行 validate，避免结构或路径不合规。
