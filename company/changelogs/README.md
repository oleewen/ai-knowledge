---
type: Documentation
title: changelogs — 变更留痕与索引运维
---
# changelogs — 变更留痕与索引运维

索引入口见 [index.md](index.md)。

`company/` 知识库变更可追溯入口：仅约定 **Markdown** 日志产物，不重复阶段文档写作规范。阶段约定 SSOT 为本 README（无 `{dirname}_meta.yaml`）。

## Skill 指针

| Skill | 说明 |
|-------|------|
| [docs-change](../../agent/skills/docs-change/SKILL.md) | 聚合 git / CHANGELOG / 本地 mtime，**写入/更新** `CHANGE-LOG.md` |
| [docs-indexing](../../agent/skills/docs-indexing/SKILL.md) | 生成 `index.md`，在 `INDEXING-LOG.md` 主表**插入**一行（最新在上） |

命令清单与执行入口见 [../../agent/skills/README.md](../../agent/skills/README.md)。

## 索引维护

目录结构或日志约定变更时，须更新本 README 与相关 `index.md`（按需）。
