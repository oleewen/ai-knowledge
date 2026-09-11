---
name: docs-pull
description: >
  按 knowledge-links.yaml 校验/修复联邦槽位软链（system/application-slots/application-{NAME} 或 company/system-slots/system-{NAME}），
  软链失效时按 type=child 的 repository clone/pull 到 path，并追加层共用 changelogs/CHANGE-LOG.md。
  用户提到 /docs-pull、从应用/系统本地仓回拉到联邦槽位、同步槽位、按 knowledge-links 拉取时，使用本技能。
  分流：推送中央规约到应用库 → docs-push；联邦建联 → docs-link；overview 蒸馏 / 归档 / SDD → 对应技能。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-pull

## 输出硬约束（P0）

- 当前单元：单个 `application-slots/application-{NAME}` 或 `system-slots/system-{NAME}` 槽位（软链）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得执行同步。
- `--all` 也须先处理并校核一个当前槽位；未收敛前不得静默推进后续槽位。
- 路径不存在、非 Git 工作区、origin 与 repository 不匹配、工作区 dirty、目标 `.docsconfig` 缺失、links 字段不完整等风险须先确认；未确认不得继续。
- 同步后必须补写层共用 `application-slots/changelogs/CHANGE-LOG.md` 或 `system-slots/changelogs/CHANGE-LOG.md`；未完成追溯不得视为单元完成。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 软链校验/修复；child clone/pull（默认分支）；旧真目录静默迁移；共用 CHANGE-LOG | docs-push 中央规约下发；docs-distill / docs-archive / SDD 正文；docs-link 建联写 yaml（→ `/docs-link`） |

## 不这样用

- 不把 `docs-push` 中央规约复制主路径收成 `docs-pull`
- 不在 `--all` 下一口气静默同步所有槽位
- 不在脏工作区上强制 pull / reset

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- `knowledge-links.yaml`
- `--app` / `--sys-name` / `--all` 三者之一
- child `repository` + `path`；槽位软链通常已由 `docs-link` 创建（缺失时本技能可建）

## 产出与脚本

- 正式：指向下级 `DOC_ROOT` 的槽位软链；层共用 `changelogs/CHANGE-LOG.md` 追溯
- 收敛后动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
bash agent/skills/docs-pull/scripts/pull-slots.sh --app <app_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --sys-name <sys_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --all
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：单槽位停顿、`--all` 批量须确认、CHANGE-LOG 须跟随同步。
