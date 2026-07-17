---
name: docs-build
description: >
  从五视角提取实体 ID，产出 per-entity {ID}.md、各视角 README、扫描生成 KNOWLEDGE_INDEX.md。依赖主 Index Guide。
  按「澄清 → 生成 → 烤干」处理单个构建单元；写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一批。
  触发：初始化/同步知识实体、对齐 ID、docs-indexing 下游要实体等。
  分流：用户只要 INDEX、overview、归档或 SDD 为主路径 → 对应技能。
  推进协议：参数向导、意图澄清、当前单元、烤干、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-build

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户动作推进。
主路径是“依赖主 Index Guide，按视角批次或实体批次生成 `{DOC_DIR}/knowledge/`”。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个视角批次、单个路径组，或单批实体集合。
- 参数未收口前，不得写 `{DOC_DIR}/knowledge/`。
- 当前单元**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入正文。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 意图澄清第 6 项「写入路径/容器」**必须**写明：当前视角批次或实体批次，以及本轮将写入的 `{DOC_DIR}/knowledge/` 下仓库根相对路径（含 per-entity `{ID}.md`、README、`KNOWLEDGE_INDEX.md` 等）。
- 语义性变更（视角范围、输出路径、跳过策略、置信度策略、实体 ID、是否补 README/KNOWLEDGE_INDEX）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- 当前单元写入终稿后，必须进入自动 `grilling`（烤干）循环；仅当当前单元已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一批。
- `C` 同符异义：意图澄清阶段 = 授权写入；烤干阶段 = 确认本单元并推进。禁止无阶段横幅裸发动作字母。
- 校验失败、路径不明、规则未覆盖时，必须停下澄清，不得静默继续。

## 边界

- 负责：五视角 per-entity、README、`KNOWLEDGE_INDEX.md`、`validate-extraction.sh`
- 不负责：index；docs-okf 迁移；distill/extract；docs-archive；SDD

## 不这样用

- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-build` 偷换成 `docs-indexing`、overview、归档或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 配置 / 规则 | [builtin-config.md](references/builtin-config.md)、[extraction-rules.md](references/extraction-rules.md) |
| README / 归并 | [readme-fill-spec.md](references/readme-fill-spec.md)、[consolidation-spec.md](references/consolidation-spec.md) |
| 核心概念 | [core-concepts.md](references/core-concepts.md) |
| 终检 / 易错 | [quality-checklist.md](references/quality-checklist.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 主 Index Guide 可用
- `{DOC_DIR}` 可解析
- 可确定的视角范围
- `--skip-existing`、`--confidence-threshold`、`--emit-report` 等策略已收口

## 当前单元

- 单个视角批次
- 或单个路径组
- 或单批实体集合

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一批或结束
- `M`：修改参数或范围；修改后按所在阶段重入澄清或烤干
- `G`：仅写后；在已收敛基础上追加深挖 grilling
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，先批确认剩余批次意图，再按既定参数补齐

## 产出

- 产物：各视角 `{ID}.md`、README、KNOWLEDGE_INDEX.md

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
评测重点：意图澄清、单单元停顿、路径/容器含 knowledge 批次、校验后再继续。
