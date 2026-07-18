---
name: docs-tag
description: >
  为 system/company overview 下 *-overview.md 做关键词相关度：候选词 → YAML 附录 → 表行 ✅ → 架构摘录（phase 3）。
  触发：/docs-tag、「扫描关键词」「给概览打标签」「phase 3」。
  分流：第三列提炼 / 全文术语 / INDEX → docs-extract、docs-upgrade、docs-indexing。
  推进协议：轻流程；参数向导、当前单元、phase 执行、轻量校核、C/M/S/F 见 references 与 light-flow-actions。
---

# docs-tag（关键词标记）

参数向导 → 处理单个 overview 当前单元 → `keyword_tag.py` 子阶段 → **轻量校核** → 用户动作推进。  
**不**绑定意图澄清 / unit-cycle / 强制写后 grilling。自动化禁用 `--phase 1`（见 gotchas）。

## 输出硬约束（P0）

- 一次只处理一个“当前单元”：单个 overview 文件。
- 参数未收口前，不得对 `--file` 执行写入。
- 每个 phase 结果后做**轻量校核**（摘要检查点，见 workflow）；当前单元未收敛前，不得自动推进下一个 overview 文件。
- 语义性变更（`--file`、`--phase`、`--keywords`、`--scan-dir`、`--top-n`、是否继续下一 phase）必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- `phase 3` / `excerpt` 不需要 `keywords`；`phase 2` 无附录时不得静默继续，必须提示先 `1-scan` + `1-write`。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| `--file`、`--phase`、附录、表行 ✅、架构摘录 | index；extract 第三列；upgrade 全库替换 |

## 不这样用

- 不把旧“步骤 1 参数确认”当唯一主线；主线是参数向导收口后处理当前单元
- 不把单个 phase 当成独立当前单元；当前单元始终是单个 overview 文件
- 不把第三列表提炼、全库术语替换、INDEX 重建收成 `docs-tag`
- 不把本技能写成语义族「澄清 → 生成 → 烤干」

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)（含前置与 phase 说明）
3. [algorithm.md](references/algorithm.md)
4. [gotchas.md](gotchas.md)
5. [light-flow-actions.md](../../references/light-flow-actions.md) — 轻流程 `C/M/S/F`

## 最少输入

- `--file`
- `--phase`
- 若 phase 含 `1` 或 `all`，`--keywords`
- `--scan-dir`、`--top-n` 已展示默认值或已收口

## 当前单元

- 单个 overview 文件

当前单元收敛后，由用户用 `C/M/S/F` 推进（见 [light-flow-actions.md](../../references/light-flow-actions.md)）：

- `C`：确认当前单元并结束或进入下一个 overview 文件
- `M`：修改参数或 phase 策略后重跑
- `S`：暂存当前单元，跳过写入或跳过后续 phase
- `F`：在当前单元已收敛后，按既定参数补齐剩余 overview 文件

加深分析：`M` 调参重跑，或口述指定下一 phase；**无 `G`**。

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py ...
```

## 产出

更新后的 overview.md（附录、表行、架构摘录）。

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)。单测：`python3 -m pytest tests/ -q`（在技能目录下）。  
评测重点：参数收口、单单元停顿、phase 后轻量校核、不得静默推进下一文件、不得要求语义族 grilling。
