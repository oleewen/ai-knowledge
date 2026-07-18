---
name: docs-pull
description: >
  按 knowledge-links.yaml 从本地 path 同步到联邦槽位（system/application-{APPNAME}/ 或 company/system-{SYSNAME}/），并追加槽位 changelogs/CHANGE-LOG.md。
  触发：/docs-pull、从应用/系统本地仓回拉到联邦槽位、同步槽位、按 knowledge-links 拉取。
  分流：推送中央规约到应用库 → docs-push；overview 蒸馏 / 归档 / SDD → 对应技能。
  推进协议：轻流程；参数向导、当前槽位单元、风险校核、C/M/S/F 见 references 与 [light-flow-actions.md](../../references/light-flow-actions.md)。
---

# docs-pull

参数向导 → 处理单个槽位当前单元 → 风险校核 → 用户动作推进。

## 输出硬约束（P0）

- 一次只处理一个“当前槽位单元”：单个 `application-{app_name}` 或 `system-{sys_name}`。
- 参数未收口前，不得执行槽位同步。
- `--all` 也必须先处理并校核一个当前槽位单元，未收敛前不得静默推进后续槽位。
- 路径不存在、非 Git 工作区、目标 `.docsconfig` 缺失、槽位目录不存在、`knowledge-links.yaml` 字段不完整等风险项，必须先给出结论、推荐方案与数字选项；未获确认不得继续。
- 当前槽位单元同步后，必须补写槽位 `changelogs/CHANGE-LOG.md`；未完成追溯前，不得视为当前单元完成。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| application → system、system → company 槽位同步；槽位 CHANGE-LOG 追溯 | docs-push 中央规约下发；docs-distill/docs-archive/SDD 正文 |

## 不这样用

- 不把 `docs-push` 的中央规约复制主路径收成 `docs-pull`
- 不在 `--all` 场景下一口气静默同步所有槽位
- 不做远端 clone、分支拉取或跨仓初始化

## 最短路径

1. [references/gates.md](references/gates.md)
2. [references/workflow.md](references/workflow.md)
3. [light-flow-actions.md](../../references/light-flow-actions.md) — `C/M/S/F`
4. [gotchas.md](gotchas.md)

## 最少输入

- `knowledge-links.yaml`
- `--app` / `--sys-name` / `--all` 三者之一
- 本地 `path` 可访问
- 槽位已由 `docs-link` 创建

## 当前槽位单元

- 单个 `application-{app_name}` 槽位
- 单个 `system-{sys_name}` 槽位

当前槽位单元收敛后，动作字母见 [light-flow-actions.md](../../references/light-flow-actions.md)（`C/M/S/F`，无 `G`）。

## 产出

- 同步后的槽位目录
- 槽位 `changelogs/CHANGE-LOG.md` 追溯记录

```bash
bash agent/skills/docs-pull/scripts/pull-slots.sh --app <app_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --sys-name <sys_name>
bash agent/skills/docs-pull/scripts/pull-slots.sh --all
```

## 评测 / 脚本

评测：`evals/evals.json`。
评测重点：单槽位停顿、`--all` 批量继续需确认、CHANGE-LOG 追溯必须跟随同步。
