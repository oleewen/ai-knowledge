---
name: docs-indexing
description: >
  生成九章索引指南（各文档根固定为 INDEX-GUIDE.md），维护各 DOC_DIR 下 changelogs/INDEXING-LOG.md 主表（最新在上）。
  按「澄清 → 生成 → 烤干」处理单个索引输出单元；写前意图澄清，写入后自动 grilling 至收敛，用户确认后再推进下一单元。
  触发：/docs-indexing、建/更索引、文档地图、Onboarding、口述「整理 INDEX」。
  分流：用户只要 docs-build/distill/extract/SDD 为主路径 → 对应技能，勿单跑本技能。
  推进协议：参数向导、意图澄清、当前单元、烤干、C/M/G/S/F 见 references/workflow.md 与 references/gates.md。
---

# docs-indexing

读 references/ → 参数向导 → 分段「澄清 → 生成 → 烤干」→ 用户动作推进。
主路径是“生成单个索引输出组并维护对应 `INDEXING-LOG.md`”。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个索引输出组。
- 参数未收口前，不得写索引指南或 `INDEXING-LOG.md`。
- 当前单元**写入前**必须完成**意图澄清**（公共六项 + 阶段横幅「当前阶段：意图澄清」）；未获写前 `C` 不得写入正文。契约见 [intent-clarify.md](../../references/intent-clarify.md)。
- 意图澄清第 6 项「写入路径/容器」**必须**列出本轮将写入的仓库根相对路径：`INDEX-GUIDE.md` 与对应 `changelogs/INDEXING-LOG.md`。
- 语义性变更（`mode/depth/output/since`、目标路径、增量基线策略、导航路径）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- 当前单元写入终稿后，必须进入自动 `grilling`（烤干）循环；仅当当前单元已收敛，或打出必须等待用户确认的语义性问题时，才把控制权交还用户。
- 自动 `grilling` 收敛后，输出 `C/M/G/S/F` 选项并停止等待用户选择；须标明「当前阶段：烤干」；不得自动推进下一输出组。
- `C` 同符异义：意图澄清阶段 = 授权写入；烤干阶段 = 确认本单元并推进。禁止无阶段横幅裸发动作字母。
- 无基线且请求 incremental 时，必须先让用户确认 full/中止/补 since，不能静默继续。

## 边界

- 负责：各文档根 `INDEX-GUIDE.md`、`INDEXING-LOG.md`、full/incremental、深度 1–3
- 不负责：实体与 `KNOWLEDGE_INDEX`（docs-build）；OKF（docs-okf）；SDD；overview（distill/extract）

## 不这样用

- 不把写前意图澄清当成完整 grilling Skill 深挖
- 不把 `docs-indexing` 偷换成 `docs-build`、overview 或 SDD 主路径

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 | [workflow.md](references/workflow.md) |
| 推进协议 | [gates.md](references/gates.md) |
| 意图澄清 | [intent-clarify.md](../../references/intent-clarify.md) |
| grilling / 烤干 | [grilling-skill.md](../../references/grilling-skill.md) |
| 参数与基线 | [scan-config-onboarding.md](references/scan-config-onboarding.md) |
| 扫描规范 | [scan-spec.md](references/scan-spec.md) |
| 质量与九章 | [quality-standards.md](references/quality-standards.md)、[nine-chapter-spec.md](references/nine-chapter-spec.md) |
| 日志规范 | [indexing-log-spec.md](references/indexing-log-spec.md) |
| 易错 / 反模式 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |

## 最少输入

- 仓库根可解析
- `mode`、`depth` 已收口
- `output` 与 `since` 策略已收口
- 若增量模式，已确认基线策略

## 当前单元

- 单个索引输出组

例如：

- 根 `INDEX-GUIDE.md` + 根 `INDEXING-LOG.md`（若本轮维护）
- 某个 `DOC_DIR/INDEX-GUIDE.md` + `{DOC_DIR}/changelogs/INDEXING-LOG.md`

当前单元收敛后，由用户用 `C/M/G/S/F` 推进：

- `C`：确认当前单元并进入下一个输出组或结束
- `M`：修改参数或路径；修改后按所在阶段重入澄清或烤干
- `G`：仅写后；在已收敛基础上追加深挖 grilling
- `S`：暂存当前单元，跳过写入
- `F`：在当前单元已收敛后，先批确认剩余输出组意图，再按既定参数补齐

## 产出

- 产物：索引指南（固定为 `INDEX-GUIDE.md`）、`INDEXING-LOG.md`

```bash
agent/skills/docs-indexing/scripts/indexing.sh --mode <mode> --depth <depth>
```

INDEX 落盘后建议刷新 OKF：见 [docs-okf/references/workflow.md](../docs-okf/references/workflow.md)。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。
评测重点：意图澄清、单单元停顿、路径/容器双路径、基线异常不静默降级。
