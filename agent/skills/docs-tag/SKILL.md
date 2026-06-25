---
name: docs-tag
description: >
  为 system/company overview 下 *-overview.md 做关键词相关度：候选词 → YAML 附录 → 表行 ✅ → 架构摘录（phase 3）。
  触发：/docs-tag、「扫描关键词」「给概览打标签」「phase 3」。
  分流：第三列提炼 / 全文术语 / INDEX → docs-extract、docs-upgrade、docs-indexing。
  门禁：脚本前步骤 1 确认 + 一次性复述全参数（gates.md）；无 SDD HTML gate。
---

# docs-tag（关键词标记）

门禁 → keyword_tag.py：1-scan → 选词 → 1-write → 2 → 3。自动化禁用 `--phase 1`（见 gotchas）。

## 边界

| 负责 | 不负责 |
|------|--------|
| `--file`、`--phase`、附录、表行 ✅、架构摘录 | index；extract 第三列；upgrade 全库替换 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)（含前置与 phase 说明）
3. [algorithm.md](references/algorithm.md)
4. [gotchas.md](gotchas.md)

## 门禁

脚本前：步骤 1 逐项确认 + 一次性复述全参数（[gates.md](references/gates.md)）。

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py ...
```

## 产出

更新后的 overview.md（附录、表行、架构摘录）。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。单测：`python3 -m pytest tests/ -q`（在技能目录下）。
