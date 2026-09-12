---
name: docs-link
description: >
  在源知识库登记/注销目标知识库：双边 knowledge-links.yaml（源 child、子仓唯一 type:parent），
  并维护联邦槽位软链（system/application-slots/application-{NAME} 或 company/system-slots/system-{NAME}）。
  薄封装 agent/skills/docs-link/scripts/docs-link.sh（--link|--unlink --target … [--app-name] [--rewrite-http] [--dry-run]）。
  用户提到 /docs-link、知识库建联、联邦登记、link/unlink knowledge-links、建槽位软链、注销应用/系统链路时，使用本技能。
  分流：槽位回拉/修复 → docs-pull；中央规约下发 → docs-push；装机 → docs-install / agent-install；元库骨架对齐 → docs-upgrade。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-link

## 输出硬约束（P0）

- 当前单元：一对**源仓** × 一个 `--target` 的 `--link` 或 `--unlink`（单目标；多目标须逐个确认）。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得实跑写盘。
- **源仓 cwd 闸门**：当前工作区须为合法源边 Git 根（`.docsconfig` 的 `KNOWLEDGE_TYPE` 为 `company` 或 `system`）。否则**停**，要求切换到源仓工作区后再跑；不代 `cd`、不发明 `--source-root`。
- 默认先 `--dry-run` 出变更预览；dry-run 摘要未确认前，不得静默真写。
- `--rewrite-http` 默认关；仅用户明示「换父/改跨层 HTTP」才加，且单独二次确认。
- `app_name` / 系统名：参数向导必问（可预填脚本推断值）；确认后再传 `--app-name`（或接受预填）。
- 脚本 SSOT：`agent/skills/docs-link/scripts/docs-link.sh`（及同目录 `link-config.sh`）。宣称单元完成前须写后受众 **A/B**。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 编排 `docs-link.sh` 的 link/unlink；参数向导与写盘闸门；双边 links + 槽位软链 | 槽位 clone/pull 与 git 追溯（→ docs-pull）；中央规约复制（→ docs-push）；装机（→ docs-install / agent-install）；改正文（除用户明示的 `--rewrite-http`） |

## 不这样用

- 不把「先 dry-run 再真写」写成无停顿流水线
- 不在应用仓（`KNOWLEDGE_TYPE=application`）或其他非法源边静默代跑
- 不默认开启 `--rewrite-http`
- 不把 docs-pull / docs-push / docs-install / agent-install 主路径收成本技能
- 不一次静默 link/unlink 多个 `--target`

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- 合法源仓工作区（company → system，或 system → application）
- `--link` 或 `--unlink`（二选一）
- `--target`（目标知识库仓库根，或已登记 remote URL）
- system→application 时的应用名（向导确认后的 `--app-name`）

## 产出与脚本

- 正式：源/目标 `knowledge-links.yaml` 更新；槽位软链创建或移除（unlink 保留层共用 changelogs）
- 收敛后动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
# 须在源 Git 仓库根执行（或从中央库调用技能脚本路径）
bash agent/skills/docs-link/scripts/docs-link.sh --link --target <目标仓库根> [--app-name=<名>] [--dry-run]
bash agent/skills/docs-link/scripts/docs-link.sh --unlink --target <目标仓库根> [--dry-run]
# 仅用户明示换父改正文时：
bash agent/skills/docs-link/scripts/docs-link.sh --link --target <目标仓库根> --app-name=<名> --rewrite-http [--dry-run]
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：源仓闸门、单目标停顿、默认 dry-run、`--rewrite-http` 须明示、与 pull/push/bootstrap 分流。
