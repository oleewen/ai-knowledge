---
name: docs-pull
description: >
  从已建联远端应用库拉取文档，覆盖更新联邦镜像 applications/app-{APPNAME}/，并追加 pull 记录。
  触发：同步应用文档、更新联邦镜像、docs-pull 等。
  分流：用户只要 distill/extract/archive/SDD 或只改 system overview → 对应技能。
  门禁：实跑 rsync 前满足 gates.md HARD-GATE；无 SDD HTML gate（低风险）。
---

# docs-pull：远端 → 联邦镜像

判定归属 → 读 references/ → 低风险写盘确认 → 更新 `applications/app-{APPNAME}/`。

镜像 = `applications/app-{APPNAME}/`；默认不写中央 `{DOC_DIR}/` 本体。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 已注册 app 远端 → 镜像；pull-log；manifest 更新 | overview（extract/distill）；docs-archive；APPLICATIONS_INDEX；SDD 终稿 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [manifest-spec.md](references/manifest-spec.md)
4. [core-concepts.md](references/core-concepts.md)、[anti-patterns.md](references/anti-patterns.md)
5. [quality-checklist.md](references/quality-checklist.md)
6. [brainstorming-integration.md](references/brainstorming-integration.md)
7. [gotchas.md](gotchas.md)

## 门禁

实跑 rsync 前满足 [gates.md](references/gates.md)；不要求 superpowers specs 或 HTML gate。

## 产出

- 镜像：`applications/app-{APPNAME}/`
- 记录：`applications/app-{APPNAME}/changelogs/pull-log.md`

命令见 [workflow.md](references/workflow.md)。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。无专用 preToolUse 钩子。
