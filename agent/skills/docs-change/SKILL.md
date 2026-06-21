---
name: docs-change
description: >
  从 Git、CHANGELOG*、本地 mtime 三源采集变更，写入 {output_dir}/CHANGE-LOG.md，文末保留增量基线注释。
  触发：/docs-change、变更聚合、口述「记录改动」「最近改了什么」。
  分流：用户只要 docs-indexing/docs-build/docs-archive/docs-upgrade 为主路径 → 对应技能。
  门禁：无有效 .docsconfig 即中止；时间基准或 --output 歧义须先确认（无 SDD HTML gate）。
---

# docs-change：变更聚合

调度器：判定主责 → 读 references/ → 多源采集 → 更新 CHANGE-LOG.md。

## 边界

| 负责 | 不负责 |
|------|--------|
| CHANGE-LOG.md 多源聚合、倒序插入、文末基线 | INDEX_GUIDE、KNOWLEDGE_INDEX、overview 归档、全库术语替换 |
| | docs-indexing、docs-build、docs-archive、docs-upgrade |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [collection-rules.md](references/collection-rules.md)
4. [core-concepts.md](references/core-concepts.md)
5. [design-principles.md](references/design-principles.md)
6. [anti-patterns.md](references/anti-patterns.md)
7. [quality-checklist.md](references/quality-checklist.md)
8. [gotchas.md](gotchas.md)
9. 结构模板：[changes-index-template.md](assets/changes-index-template.md)

## 门禁

`.docsconfig` 硬门禁：解析失败即中止（[gates.md](references/gates.md)）。有歧义须确认；禁止宣称已更新 INDEX 或知识实体。

## 产出

- 输出：`{output_dir}/CHANGE-LOG.md`（默认 `${DOC_ROOT}/changelogs/`；参数见 [workflow.md](references/workflow.md)）
- 原始数据：`{output_dir}/.raw/`（[change-indexing.sh](scripts/change-indexing.sh)）

```bash
agent/skills/docs-change/scripts/change-indexing.sh --since "yyyy-MM-dd HH:mm:ss.SSS"
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。无 preToolUse 钩子。

## 下游

docs-indexing / docs-build 可消费 CHANGE-LOG.md（一行指针，详 workflow）。
