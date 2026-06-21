# docs-indexing 会话 spec

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)。
`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`。替换占位；总确认前 `PENDING`。

## 1. 范围

- `INDEX_GUIDE`：`<如 application/INDEX_GUIDE.md>`
- `INDEXING-LOG`：`<如 application/changelogs/INDEXING-LOG.md>`
- docs-change / 基线：`<说明>`

## 2. Qclose-1

- `mode` · `depth` · `output` · `since`
- 用户：**C / M / S**

## 3. 写入路径清单（钩子）

与工具 **逐字一致** 的根相对路径（每行一条；只写本轮真会动的）：

- …

## 4. 门禁进度（可选）

同 sdx 则锚本节；例 [sdx-solution 模板](../../sdx-solution/assets/solution-session-spec-template.md)。

---

`<!-- docs-indexing-gate: PENDING -->` → 总确认 `CONFIRMED`；HTML 注释与例外见 [gates.md](../references/gates.md)。
