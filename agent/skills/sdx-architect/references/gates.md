# sdx-architect 门禁

流程：准备 → 草稿 → 用户总确认 → 落盘 → validate（[workflow.md](workflow.md)）。

## 核心

总确认前禁止 `{DOC_DIR}/requirements/**/ASD-*.md`。

## 例外

1. 用户明示跳过门禁直接写入  
2. `SDX_ARCHITECT_ALLOW_ASD_WRITE=1`

## 状态

| 值 | 含义 |
|----|------|
| `PENDING` | 未总确认 |
| `CONFIRMED` | 可落盘 |

## 会话 spec 标记

- 路径：符合 `{DOC_DIR}/superpower/specs/`（见 [session-spec-path.md](../../../references/session-spec-path.md)）。（`validate-asd.sh --gate-check`，大小写敏感）

- `<!-- sdx-architect-gate: PENDING -->`
- `<!-- sdx-architect-gate: CONFIRMED -->`

spec 正文须含目标 **`ASD-*.md` 全名**（与落盘一致）。

## 检查点

落盘：须 `CONFIRMED` 或合法例外；落盘后：运行 validate。
