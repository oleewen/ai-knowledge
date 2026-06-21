---
name: docs-pull
description: >
  从已建联注册的远端应用库拉取文档，覆盖更新本仓库联邦镜像 applications/app-{APPNAME}/，并追加 pull 记录。
  触发：同步应用文档、更新联邦镜像、拉最新镜像、「docs-pull 一下」等（不必等用户说命令名）。
  分流：用户只要 docs-distill、docs-extract、docs-archive、SDD 终稿或只改 system overview → 不以本技能为唯一主路径。
---

# docs-pull：远端 → 联邦镜像

调度器：判定归属 → 读 `references/` → **低风险写盘确认**（见 CONVENTIONS 低风险表）→ 更新 `applications/app-{APPNAME}/`。

> **镜像** = `applications/app-{APPNAME}/`。远端 `{DOC_DIR}/` 是应用侧知识主库；本技能**默认不写**中央库 `{DOC_DIR}/` 本体。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 已注册 app 的远端文档 → 镜像；`pull-log.md`；manifest `last_pulled_*`（脚本）；`--dry-run` / `--force` 确认节奏 | 写 `system/knowledge/overview/`（extract/distill）；**docs-archive**；自动改写 `APPLICATIONS_INDEX.md`；SDD 终稿 |

## 前置

- `applications/app-{APPNAME}/` 与 `{APPNAME}_manifest.yaml` 已存在。
- 仓库根可调 `agent/skills/docs-pull/scripts/pull-docs.sh`。

## 读序

1. `references/gates.md`（低风险 ≠ SDX gate）  
2. `references/workflow.md`  
3. `references/manifest-spec.md`  
4. `references/core-concepts.md`  
5. `references/design-principles.md`、`references/anti-patterns.md`  
6. `references/quality-checklist.md`  
7. `references/brainstorming-integration.md`  
8. `gotchas.md`  
9. 可选：`assets/docs-pull-run-checklist.md`

## 门禁

实跑 rsync **前**满足 `references/gates.md` HARD-GATE；**不要**求 `{DOC_DIR}/superpowers/specs/` 或 HTML gate（与 CONVENTIONS 低风险一致）。

## 产出

- 镜像树：`applications/app-{APPNAME}/`  
- 记录：`applications/app-{APPNAME}/changelogs/pull-log.md`（追加）

命令示例：`references/workflow.md`。

## 评测

`evals/evals.json`、`evals/eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

本路径**无**专用 `preToolUse` 钩子；靠对话遵守 `gates.md`。

## 索引

全表：[references/README.md](references/README.md)。
