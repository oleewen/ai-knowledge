# Cursor — Slash 与 Skills

`.cursor/skills/` 下各子目录的 **`SKILL.md`** 即 Slash 命令的实现说明（如 `/document-indexing`、`/document-change`）。由 **Agent 按文档步骤执行**；**不是** 仓库 `scripts/` 里的 Bash 可执行文件。

| 入口 | 说明 |
|------|------|
| [../.ai/skills/README.md](../.ai/skills/README.md) | Slash 命令一览与调用说明（与本文档同步） |
| [skills/document-indexing/SKILL.md](skills/document-indexing/SKILL.md) | 根目录 `INDEX_GUIDE.md` + `system/changelogs/indexing-log.jsonl`（`PROJECT_INDEX.md` 可为短入口） |
| [skills/document-change/SKILL.md](skills/document-change/SKILL.md) | `system/changelogs/changes-index.*`（供增量索引） |

人类/Agent 总入口：根目录 `README.md`、`AGENTS.md`、`INDEX_GUIDE.md`（`PROJECT_INDEX.md` 短入口）。
