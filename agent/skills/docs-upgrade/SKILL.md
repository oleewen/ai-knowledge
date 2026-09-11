---
name: docs-upgrade
description: >
  将当前工程知识库（读 .docsconfig）对齐元库最新模板结构：结构/模板以元库为准，
  正文以本库为准；已改 md 按元库 H2/H3 重填本库正文；未落位节清单逐项确认。
  支持 @ 指定文件/目录强制对齐元库对应路径（与整树互斥；破跳过；逐文件 C）。
  元库来自 DOC_ROOT/knowledge-links.yaml 的唯一 type: meta（path 优先 + fetch）。
  用户提到 /docs-upgrade、升级知识库、对齐元库模板、从 meta 刷新骨架、不丢已有知识升级、
  指定文件对齐元库、@ 文件强制对齐时，使用本技能。
  分流：首次装机 → docs-install / agent-install；本仓 Agent 树追新 → agent-install；生态 skills 追新 → skill-upgrade；
  联邦登记 → docs-link；联邦槽位 → docs-pull；规约下发 → docs-push。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-upgrade

## 输出硬约束（P0）

- 当前单元：单个工程 `DOC_ROOT` 的一次升级计划（文档树；不含 Agent）。
- **两模式互斥**：调用带 ≥1 个有效 `@` 文件/目录 → **指定文件强制对齐**；无 `@` → **整树**。同一次调用不混用。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。参数未收口前不得写盘。
- 整树：默认先 **dry-run 清单**；清单未 `C` 前不得实跑。文件模式：先 **解析总览 `C`**，再 **逐文件 `C`**。
- **禁止**调用会清空 `DOC_DIR` 的 `docs-install.sh --scope=knowledge` 主路径。
- 合并契约：结构/模板=元库；正文=本库；已改判定=规范化后与元库同路径内容不等；已改 md=本库正文填入元库 H2/H3；未落位节=清单确认后才落；本库独有路径永不删。
- 文件模式强制：指定路径两边都有的 `.md` **破跳过**，一律结构重填；本缺元有 → 仅 scaffold 该路径；元缺 / 软链路径 / 顶层遗留槽位名 → 该条拒绝。非 md：可进名单；已存在不覆盖；仅缺则可 scaffold。`*-slots/changelogs/**` 本有则整文件本库胜（强制也不破）。
- `knowledge-links.yaml` 永不被元库模板覆盖。
- **槽位根放开**：`application-slots/`、`system-slots/` 下**非软链真文件**进四桶 / 重填 / 文件模式（与普通路径同）。**凡软链一律跳过**（不跟随）。顶层遗留 `application-*` / `system-*`（不含上述两 slots 名）仍硬忽略。槽位**实例**同步仍归 `/docs-pull`。
- `*-slots/changelogs/**`：本无可 scaffold；本有整文件本库胜（不进结构重填）。
- 文件模式**不强制** `{REPO_ROOT}/.docs-init/` 备份（依赖 git）。整树 scaffold 仍按脚本备份。
- 文件模式由 Skill/Agent 编排写盘；脚本暂不加 `--path`。
- 宣称单元完成前须按 [audience-and-language.md](../../references/audience-and-language.md) 轻流程默认读者表做写后 **A/B**（文件模式：整单结束一次）。

## 边界

| 负责 | 不负责 |
| --- | --- |
| 读 `.docsconfig` + `type: meta`；fetch 元库；出变更清单；备份（整树）；新增骨架；编排 H2/H3 结构重填与未落位确认；`@` 指定文件/目录强制对齐 | 首次装机（→ docs-install / agent-install）；Agent 树追新（→ agent-install）；生态 skills（→ skill-upgrade）；docs-link **登记操作**（→ `/docs-link`）；docs-pull/push；语义改文；脚本 `--path` 过滤（暂无） |

## 不这样用

- 不把升级写成「清空 DOC_DIR 再 docs-install」
- 不在未确认时覆盖已改正文或丢弃未落位节
- 不把 Agent / 槽位实例同步（docs-pull）/ 首次装机收成本技能
- 缺少 `.docsconfig` 或唯一 `type: meta` 时不得猜测元库
- 不把整树与文件模式混在同一单元
- 不跟随软链写入或重填（含 `*-slots` 下实例软链）

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 / 合并规则 | [parameters.md](references/parameters.md)、[merge-rules.md](references/merge-rules.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 脚本说明 | [scripts/docs-upgrade.sh](scripts/docs-upgrade.sh) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- 当前工程可读的 `.docsconfig`（含 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` / `KNOWLEDGE_TYPE`）
- `{DOC_ROOT}/knowledge-links.yaml` 恰好一条 `type: meta`（或本次 `--meta-path`）
- 整树：是否 dry-run（默认是）已收口
- 文件模式：≥1 个有效 `@` 文件或目录（解析后须有可处理项或明确拒绝项清单）

## 产出与脚本

- 正式（整树）：对齐后的 `DOC_ROOT`（新骨架 + 已确认重填 + 已确认未落位）；备份在 `{REPO_ROOT}/.docs-init/upgrade-{stamp}/`
- 正式（文件）：已 `C` 的指定路径（强制重填 / scaffold）；无强制 `.docs-init` 备份
- 预览（整树）：四桶清单（新增骨架 / 跳过 / 结构重填 / 本库独有）+ 后续未落位节清单
- 预览（文件）：`@` 展开去重后的动作总览（强制重填 / scaffold / 非 md 跳过覆盖 / 元缺拒绝 / 软链拒绝 / 遗留槽位拒绝 / changelogs 本库胜）
- 收敛后：产物校核 + 受众 A/B → [light-flow-actions.md](../../references/light-flow-actions.md)

```bash
# 整树：在目标工程根（含 .docsconfig）执行；脚本位于中央库本技能
bash /path/to/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --dry-run
bash /path/to/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold
# 文件模式：无脚本 --path；由 Skill 按 @ 编排（见 workflow / parameters）
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：禁清空 install、meta 解析、清单闸门、未落位逐项、写后 A/B、与 docs-install 分流、文件模式互斥与逐文件 `C`。
