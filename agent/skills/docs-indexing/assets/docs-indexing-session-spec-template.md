# docs-indexing 会话 spec 骨架

路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`

复制后替换占位；总确认前保留 `PENDING`。

---

## 1. 背景与范围

- 本轮 `DOC_ROOT` / 输出 `INDEX_GUIDE.md` 路径：`<例如 application/INDEX_GUIDE.md>`
- 本轮 `INDEXING-LOG.md` 路径：`<例如 application/changelogs/INDEXING-LOG.md>`
- 依赖：`docs-change` 是否已跑、增量基线是否可用：`<说明>`

## 2. 已确认参数（Qclose-1）

- `mode`：`<full|incremental>`
- `depth`：`<1|2|3>`
- `output`：`<路径>`
- `since`：`<epoch ms 或 N/A>`
- 用户选择：`<C / M / S>`

## 3. 本轮写入路径清单（钩子证据）

须与工具调用中的仓库根相对路径**逐字一致**（每行一条）：

- `<例如 application/INDEX_GUIDE.md>`
- `<例如 application/changelogs/INDEXING-LOG.md>`

（若本轮仅更新其中之一，可只列将实际写入的路径。）

## 4. 门禁进度（可选）

与 `sdx-*` 同构时锚到本文件内小节。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

---

<!-- docs-indexing-gate: PENDING -->

（总确认后：`<!-- docs-indexing-gate: CONFIRMED -->`，且正文须含上节所列完整相对路径。）
