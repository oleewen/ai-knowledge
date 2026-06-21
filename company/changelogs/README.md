---
type: Documentation
title: changelogs — 变更留痕与索引运维
---
# changelogs — 变更留痕与索引运维

`company/` 知识库变更可追溯入口：仅约定 **Markdown** 日志产物，不重复阶段文档写作规范。阶段约定 SSOT 为本 README（无 `{dirname}_meta.yaml`）。

## 目录文件

| 文件 | 用途 |
|------|------|
| `README.md` | 本说明 |
| [CHANGE-LOG.md](CHANGE-LOG.md) | `company/` 侧维护性变更与 **docs-change** 聚合；文末 `<!-- docs-change:baseline_time_ms=... -->` 为增量基线 |
| [INDEXING-LOG.md](INDEXING-LOG.md) | **docs-indexing** 运行记录；主表**第一行** `indexing_finished_ms` 为增量锚点（[indexing-log-spec.md](../../agent/skills/docs-indexing/references/indexing-log-spec.md)） |

## 关联索引

- [../INDEX_GUIDE.md](../INDEX_GUIDE.md)
- 仓库根 [INDEX_GUIDE.md](../../INDEX_GUIDE.md)（按需）

## Skill 指针

| Skill | 说明 |
|-------|------|
| [docs-change](../../agent/skills/docs-change/SKILL.md) | 聚合 git / CHANGELOG / 本地 mtime，**写入/更新** `CHANGE-LOG.md` |
| [docs-indexing](../../agent/skills/docs-indexing/SKILL.md) | 生成 `INDEX_GUIDE.md`，在 `INDEXING-LOG.md` 主表**插入**一行（最新在上） |

命令清单与执行入口见 [../../agent/skills/README.md](../../agent/skills/README.md)。

## 索引维护

目录结构或日志约定变更时，须更新本 README 与相关 `INDEX_GUIDE.md`（按需）。
