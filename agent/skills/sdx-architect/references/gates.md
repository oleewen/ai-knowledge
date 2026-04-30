# sdx-architect 门禁规则

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

## 执行检查点

- 落盘前检查是否满足 `CONFIRMED` 或合法例外。
- 落盘后必须执行 validate，避免结构或路径不合规。
