---
name: docs-tag
description: >
  为 Markdown 概览（如 *-overview.md）做关键词相关度：扫目录候选 → 选词 → YAML 附录 → 表行 ✅ → 架构摘录（phase 3）。
  触发：`/docs-tag`、`扫描关键词`、`给概览打标签`、`表格打勾`、`架构摘录`、`刷新摘录`、`phase 3`。
  仅第三列提炼 / 全文术语替换 / INDEX → 分流 docs-extract、docs-upgrade、docs-indexing。
---

# docs-tag（关键词标记）

门禁 → `keyword_tag.py`：`1-scan` → 选词 → `1-write` → `2` → `3`。**自动化禁用** `--phase 1`（`input()`，见 gotchas §7）。

概览附录维护；INDEX→**docs-indexing**；段落业务→**docs-extract**。

## 边界

| 负责 | 不负责 |
|------|--------|
| `--file`、`--phase`、`1-scan`/`1-write`/`2`/`3`、附录、表行 ✅（phase 2 忽略 HTML 注释）、`## 架构摘录` 投影 | `INDEX_GUIDE`；extract 第三列；upgrade 全库替换 |

分流：overview 提炼→extract；术语→upgrade；九章→indexing。

## 前置

- `--file` 存在  
- phase 含 1 时 keywords 齐备；Skill 用 `1-scan`+`1-write`+`2`+`3`（`3` 不需 keywords）  
- **仓库根**：`agent/skills/docs-tag/scripts/keyword_tag.py`

## 阅读顺序

1. `references/gates.md`  
2. `references/workflow.md`  
3. `references/algorithm.md`（候选词原理）  
4. `gotchas.md`

## 门禁

脚本前：步骤 1 逐项确认 + **一次性复述**全参数（[gates.md](references/gates.md)）。低风险（[CONVENTIONS.md](../../rules/CONVENTIONS.md)）；无 specs gate。

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py ...
```

## 评测

`evals/evals.json`、`eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

```bash
cd agent/skills/docs-tag && python3 -m pytest tests/ -q
```
