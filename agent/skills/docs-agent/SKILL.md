---
name: docs-agent
description: >
  维护或初始化仓库根目录 README.md 与 AGENTS.md，按「澄清 → 生成 → 烤干」处理单个入口文档当前单元。
  触发：/docs-agent、入口与 INDEX 不同步、口述「写 README」「更新 AGENTS」。
  分流：用户只要 docs-indexing/docs-build/docs-upgrade 或 SDD/distill/extract → 对应技能。
  推进协议：参数向导、写前意图澄清、当前单元、烤干、C/M/G/S/F 见 references/gates.md 与 references/workflow.md。
compatibility: Bash 5+；校验脚本 agent/skills/docs-agent/scripts/validate-guide.sh。
---

# 仓库入口文档（docs-agent）

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户动作推进。
主路径是“依落盘 `INDEX-GUIDE.md` 生成并维护单个根入口文档”。

## 输出硬门禁（P0）

- 一次只处理一个“当前单元”（`README.md` 或 `AGENTS.md`）；禁止一口气补齐双文件（除非用户显式 `F` 且已完成剩余单元意图批确认）。
- 参数未收口前，不得写根 `README.md` / `AGENTS.md`。
- 当前单元**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入正文。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 当前单元写入终稿后，必须进入自动 `grilling`（烤干）循环；仅当当前单元已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一入口文件。
- `C` 同符异义：意图澄清阶段 = 授权写入；烤干阶段 = 确认本单元并推进。禁止无阶段横幅裸发动作字母。
- `F` 仅表示在当前单元已收敛后，先批确认剩余未完成入口文件意图，再一次性补齐；不得覆盖已确认前文，不得跳过意图批确认。
- 语义性变更（`output` / `mode`、覆盖还是合并、README/AGENTS 职责边界、是否保留现有内容）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- `both` 模式下默认顺序为先 `README.md`，后 `AGENTS.md`；前一单元未收敛前，不得静默写入后一单元。
- `grilling` 过程中如发现**语义性问题**（改变职责边界/覆盖策略/保留口径等），必须先给出结论、推荐修订与数字选项并等待用户确认；未获确认不得修订当前单元。
- 仅**非语义性修订**（不改变含义的错别字/编号/排版等）可在当前单元默认授权下直接修订；不确定时按语义性处理。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 根 README.md、AGENTS.md；`--output` / `--mode`；与 `INDEX-GUIDE.md` 对齐 | index（docs-indexing）；实体（docs-build）；术语批量（docs-upgrade）；SDD / distill / extract 主流程 |

## 不这样用

- 不走前置草稿 + 集中收口主线；主线是参数向导后分段「澄清 → 生成 → 烤干」
- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不在本技能内重写或替代 `INDEX-GUIDE.md`；INDEX 主路径仍是 `docs-indexing`
- 不把术语链式替换、overview 维护、实体索引等任务收成 `docs-agent`

## 路由

| 目的 | 文件 |
| ---- | ---- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 执行细则 | [execution-spec.md](references/execution-spec.md)、[three-file-spec.md](references/three-file-spec.md) |
| 质量 / 易错 | [quality-standards.md](references/quality-standards.md)、[gotchas.md](gotchas.md) |
| 模板 | [readme-skeleton.md](assets/readme-skeleton.md)、[agents-skeleton.md](assets/agents-skeleton.md) |
| docs 族结构 | [docs-skill-skeleton.md](references/docs-skill-skeleton.md) |

## 最少输入

- 已落盘的 `INDEX-GUIDE.md`
- `output`、`mode` 已收口
- 根入口文件目标路径可解析
- 若涉及覆盖/合并边界，已确认风险策略

## 推进协议

意图澄清、单元推进、前文回改、烤干与用户动作 `C/M/G/S/F` 见 [gates.md](references/gates.md)。

## 产出

默认 `{REPO_ROOT}` 下 README.md、AGENTS.md（`--output` 可只其一）。

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
`docs-agent` 评测聚焦意图澄清、当前单元推进协议与结构校验。前置：`INDEX-GUIDE.md` 须已落盘（例外见 execution-spec.md）。
