# docs-archive 会话 spec 骨架

路径约定：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-archive.md`

复制后替换占位；用户确认方案确认书前保留 `PENDING` 行。详见 [references/gates.md](../references/gates.md)。

---

## 1. 背景与目标

- 来源 overview：`<path/to/XX-overview.md>`（可选锚点：`#章节`）
- 归档意图（一句话）：

## 2. 解析摘要（步骤 0）

- 将写入的**目标文件 basename 列表**（须与方案确认书一致）：`<file1.md>、<file2.md>、…`
- 缺失或存疑的副标题链接：`<无则写「无」>`

## 3. 方案确认书指针

- 方案确认书正文位置：`<本会话内章节锚点 / 或粘贴摘要>`
- 来源清理策略：`<删除已归档片段 / 仅保留索引壳 / 保留不动>`
- 冲突策略：`<以来源为准 / 以目标为准 / 并列待裁决>`

## 4. 门禁进度（可选）

与 `sdx-*` 会话 spec 同构时，两列锚到**本文件内**小节。示例见 [sdx-solution 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G1](#g1-…) | … | 草案/已确认 | … |

## 5. 风险与待定

- `<无则写「无」>`

---

<!-- docs-archive-gate: PENDING -->

用户确认方案确认书后：将上一行改为 `<!-- docs-archive-gate: CONFIRMED -->`。本 spec 正文须至少出现一次上述**目标文件 basename**之一（供钩子证据校验）。
