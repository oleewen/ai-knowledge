---
name: docs-upgrade
description: >
  定向改 Markdown、注释、配置文本；统一术语并沿引用链 + 关键词链式同步。
  触发：/docs-upgrade、「改文档」「统一术语」「把 X 换成 Y」；简写 a - b / a > b / a 2 b 均为 a→b。
  分流：用户只要 docs-archive/change/indexing/build 或仅 CHANGE-LOG/INDEX → 对应技能。
  门禁：任何写入前须范围确认与用户 C/S（见 gates.md）；无 SDD HTML gate。
---

# docs-upgrade：定向升级与链式对齐

判定归属 → 读 references/ → 范围确认 → 主改 → 关联检索 → 校验。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| MD/注释/配置文档性文本；引用链 + 关键词；范围确认书 | docs-change、docs-indexing、docs-archive、docs-build 主流程 |

## 最短路径

1. [gates.md](references/gates.md) + [docs-upgrade-scope-ack-template.md](assets/docs-upgrade-scope-ack-template.md)
2. [workflow.md](references/workflow.md)
3. 意图糊：[brainstorming-integration.md](references/brainstorming-integration.md)
4. 步骤 3：[related-doc-discovery.md](references/related-doc-discovery.md)、[semantic-keyword-discovery.md](references/semantic-keyword-discovery.md)
5. [core-concepts.md](references/core-concepts.md)、[design-principles.md](references/design-principles.md)、[anti-patterns.md](references/anti-patterns.md)
6. [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md)

## 门禁

任何写入前完成范围确认与用户 **C**/**S**（[gates.md](references/gates.md)）。业务规则/架构决断须用户拍板，勿编造。

## 产出

已改主文件与已确认关联；链校验见 quality-checklist。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。无专用 preToolUse 钩子。
