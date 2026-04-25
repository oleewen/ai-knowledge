# 闸门、索引与链接约定

供 `docs-archive` 在探索目标与自检链接时使用。

**目录**：[文档产出闸门](#文档产出闸门) · [INDEX_GUIDE](#index_guide) · [站内 Markdown 链接](#站内-markdown-链接) · [Git](#git)

---

## 文档产出闸门

若写入路径落在仓库 [AGENTS.md](../../../../AGENTS.md) 所述**文档产出闸门**（如 `{DOC_DIR}` 下受管终稿、`system/architecture/` 等），须先核对 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md) 第三节与相关 `sdx-*`、`docs-distill` 规则，**不得绕过既有总确认流程**。

## INDEX_GUIDE

- 仓库根 [INDEX_GUIDE.md](../../../../INDEX_GUIDE.md) 与子域 `INDEX_GUIDE.md`：**按需查阅**，用于确认路径权威性、索引边界与是否需同步导航表。

## 站内 Markdown 链接

- 显示文本建议为**仓库根相对路径**；链接目标须为相对当前文件的合法路径，确保可点击。细则见 [AGENTS.md](../../../../AGENTS.md)「站内 Markdown 链接」。

## Git

- **禁止**未经用户同意自动 `git commit` / `git push`。见 [git-guidelines.md](../../../rules/coding/git-guidelines.md)。
