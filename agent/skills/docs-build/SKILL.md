---
name: docs-build
description: >
  从技术→数据→业务→产品四视角提取实体 ID，产出 *_knowledge.json（schema 2.1）、各视角 README 索引行、
  归并 `{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md`。依赖主 Index Guide。
  触发：初始化/同步知识实体、对齐 ID、补四视角资产、更新 KNOWLEDGE_INDEX、docs-indexing 下游要实体等；
  口语如「把代码里实体整理一下」「知识和代码对不上」。用户只要根 INDEX、overview、归档或 SDD 终稿为主路径 → 分流对应技能，勿单走本技能。
---

# docs-build（知识实体提取）

判定主路径 → 读 `references/` → 会话 spec + **Qclose-1** → 写 `{DOC_DIR}/knowledge/`。

**应用知识库**：`.docsconfig` 的 `DOC_DIR`，下文 `{DOC_DIR}/`。

## 边界

| 负责 | 不负责 |
|------|--------|
| 四视角 `*_knowledge.json`、README 索引表、`KNOWLEDGE_INDEX.md`、`validate-extraction.sh` | 根 `INDEX_GUIDE`（docs-indexing）；overview 蒸馏/抽取（docs-distill / docs-extract）；视角归档（docs-archive）；SDD 终稿 |

## 前置

- 主 Index Guide 可用（否则先 `/docs-indexing`）
- `{DOC_DIR}/knowledge/` 可写；spec 在 `docs/superpowers/specs/`

## 阅读顺序（先读后写）

1. `gates.md`（门禁、Qclose-1）
2. `workflow.md`（四阶段、参数）
3. `interaction-gate.md`（spec、节奏）
4. 阶段 1：`builtin-config.md`；阶段 2：`extraction-rules.md`；阶段 3：`readme-fill-spec.md`；阶段 4：`consolidation-spec.md`
5. 混淆：`core-concepts.md`；原则：`design-principles.md`；反模式：`anti-patterns.md`；SDD 边界：`brainstorming-integration.md`
6. 阶段 4 后：`quality-checklist.md`；操作坑：`gotchas.md`
7. 新建 spec：`assets/docs-build-session-spec-template.md`

## 门禁

阶段 1 后须 **Qclose-1**；`docs-build-gate: CONFIRMED` 前禁止写 `{DOC_DIR}/knowledge/`（例外见 `gates.md`）。

## 产出与校验

- Spec：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`
- 产物：各视角 `*_knowledge.json`、`README.md`、`KNOWLEDGE_INDEX.md`

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

## 评测

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

`python3 agent/hooks/sdx_gate_common.py --gate build`（`agent/hooks.json`）；证据 `<!-- docs-build-gate: CONFIRMED -->` + 目标文件名。详 `gates.md`、`agent/hooks/README.md`。

## 索引

全表见 [references/README.md](references/README.md)。
