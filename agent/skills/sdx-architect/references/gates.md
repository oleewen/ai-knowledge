# sdx-architect 门禁

顺序：准备 → 会话草稿 → 用户总确认 → ASD 落盘 → validate。阶段说明见 [workflow.md](workflow.md)。

## 核心门禁

**总确认前禁止写入** `{DOC_DIR}/requirements/**/ASD-*.md`。

## 例外

1. 用户明确要求跳过并直接写入。  
2. 环境变量 `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`。

## 状态

| 值 | 含义 |
|----|------|
| `PENDING` | 草稿，未总确认 |
| `CONFIRMED` | 可落盘 |

## 会话 spec 标记（与 validate-asd 一致）

`validate-asd.sh --gate-check` 检索固定字面量（区分大小写）：

- `<!-- sdx-architect-gate: PENDING -->`
- `<!-- sdx-architect-gate: CONFIRMED -->`

同一会话 spec 正文须出现目标 **`ASD-*.md` 完整文件名**（与落盘文件一致）。

## 检查点

落盘前：`CONFIRMED` 或合法例外。落盘后：必跑 validate。
