---
name: docs-pull
description: >
  按 knowledge-links.yaml 拉取 child 仓库并校验或修复联邦槽位软链。
  用于 /docs-pull、同步已登记的应用、系统或解决方案槽位；结果包含下级仓 commit。
  新建联邦登记用 docs-link；规约设计由 sdx-design 只读引用中央来源，不提供跨仓下发。
---

# docs-pull

## 输出硬约束（P0）

- `knowledge-links.yaml` 的 `path` 统一使用 `${WORK_SPACE}/…`；按文件所属库配置展开，缺配置、旧格式或越界即停止。读写与迁移细则见 [knowledge-governance.md](../../knowledge/knowledge-governance.md)「knowledge-links 路径契约」。
- 当前单元：单个 `application-slots/application-{NAME}`、`system-slots/system-{NAME}` 或 `solution-slots/solution-{NAME}` 槽位（软链）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得执行同步。
- `--all` 也须先处理并校核一个当前槽位；未收敛前不得静默推进后续槽位。
- 路径不存在、非 Git 工作区、origin 与 repository 不匹配、工作区 dirty、目标 `.docsconfig` 缺失、links 字段不完整等风险须先确认；未确认不得继续。
- 同步后须在输出中给出下级仓 `commit`（与 `source`/`action`）；追溯以 git 为准，不再写 `CHANGE-LOG.md`。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 软链校验/修复；child clone/pull（已有仓当前分支）；经删除授权替换旧真目录；SYNC 输出含 git commit | 中央规约复制；docs-distill / docs-archive / SDD 正文；docs-link 建联写 yaml（→ `/docs-link`） |

## 不这样用

- 不复制中央规约；应用设计按 `sdx-design` 只读中央 ASD/spec-asd
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
- `--app` / `--sys-name` / `--sln-name` / `--all` 四者之一
- child `repository` + `path`；槽位软链通常已由 `docs-link` 创建（缺失时本技能可建）

## 产出与脚本

- 正式：指向下级 `文档目录` 的槽位软链；`SYNC_OK` 行含 `commit`/`source`/`action`（git 追溯）
- 收敛后动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
bash agent/skills/docs-pull/scripts/pull-slots.sh --app <app_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --sys-name <sys_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --sln-name <sln_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --all
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：单槽位停顿、`--all` 批量须确认、输出含 git commit。
