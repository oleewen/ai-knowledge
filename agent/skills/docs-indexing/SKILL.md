---
name: docs-indexing
description: >
  生成九章 `INDEX_GUIDE.md`，维护各 `DOC_DIR` 下 `changelogs/INDEXING-LOG.md` 主表（最新在上；见 indexing-log-spec）。
  支持 full/incremental 与深度 1/2/3。Agent/RAG 地图；下游 docs-build、docs-agent 依赖主 INDEX。
  触发：`/docs-indexing`、建/更索引、文档地图、Onboarding、口述「整理 INDEX」等。
  门禁：未完成 spec 与「用户总确认」（`docs-indexing-gate: CONFIRMED`）前禁止写任何 `INDEX_GUIDE.md` 与 `*/changelogs/INDEXING-LOG.md`（高风险；Hooks 下 `sdx_gate_common.py --gate indexing`）。
  用户只要 docs-build/distill/extract/SDD 为主路径 → 分流，勿单跑本技能。
---

# docs-indexing（文档索引）

判定路径 → 读 `references/` → **参数 Qclose-1** → 会话 spec + **路径清单** + **`docs-indexing-gate`** → 写 `INDEX_GUIDE` / `INDEXING-LOG`。

## 边界

| 负责 | 不负责 |
|------|--------|
| 各文档根九章 `INDEX_GUIDE`、`INDEXING-LOG`、full/incremental、深度 1–3 | `*_knowledge.json`、KNOWLEDGE_INDEX（docs-build）；SDD 终稿（sdx-*）；overview（distill/extract） |

## 前置

- 路径契约：[session-spec-path.md](../../references/session-spec-path.md)（`{DOC_DIR}/superpower/specs/`）
- `DOC_ROOT`、输出路径、`{DOC_DIR}/superpower/specs/` 可写
- 增量：弄清 `INDEXING-LOG` 基线或 `--since`（[indexing-log-spec.md](references/indexing-log-spec.md)）

## 阅读顺序

1. `gates.md` → `workflow.md` → `interaction-gate.md`
2. 步骤 1–2：`scan-config-onboarding.md`；步骤 4：`scan-spec.md`；步骤 5：`quality-standards.md`；步骤 6：`nine-chapter-spec.md`
3. 日志：`indexing-log-spec.md`；超范围：`brainstorming-integration.md`；反模式：`anti-patterns.md`；坑：`gotchas.md`
4. 新建 spec：`assets/docs-indexing-session-spec-template.md`

## 门禁

- 步骤 2：未 **Qclose-1（C）** 不得进扫描/写盘编排（[workflow.md](references/workflow.md)）
- 写入：须 `CONFIRMED` + spec **完整仓库根相对路径清单**，否则不落 `INDEX_GUIDE`/`INDEXING-LOG`（例外见 `gates.md`）

## 产出与脚本

- Spec：`{DOC_DIR}/superpower/specs/YYYY-MM-DD-<topic>-docs-indexing.md`
- 产物：`INDEX_GUIDE.md`、`INDEXING-LOG.md`（参数与脚本 invocation 与用户确认一致）

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

## 评测

`evals/evals.json`、`eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

`python3 agent/hooks/sdx_gate_common.py --gate indexing`；会话内需曾出现 `/docs-indexing` 激活（`sdx_session_gate.py`）。`agent/hooks.json`、`agent/hooks/README.md`、`gates.md`。

## 参考索引

[references/README.md](references/README.md)
