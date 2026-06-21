---
name: docs-agent
description: >
  维护或初始化仓库根目录 README.md 与 AGENTS.md。
  触发：/docs-agent、入口与 INDEX 不同步、口述「写 README」「更新 AGENTS」。
  分流：用户只要 docs-indexing/docs-build/docs-upgrade 或 SDD/distill/extract → 对应技能。
  门禁：覆盖根 README/AGENTS 前须步骤 0 确认书与用户 C/S（见 gates.md）。
---

# 仓库入口文档（docs-agent）

步骤 0 对齐与门禁 → 读规范 → 依落盘 INDEX 生成根 README.md / AGENTS.md。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 根 README.md、AGENTS.md；`--output` / `--mode`；与 INDEX 对齐 | INDEX_GUIDE（docs-indexing）；实体（docs-build）；术语批量（docs-upgrade）；SDD / distill / extract 主流程 |

## 最短路径

1. [gates.md](references/gates.md)
2. [workflow.md](references/workflow.md)
3. [execution-spec.md](references/execution-spec.md)
4. [three-file-spec.md](references/three-file-spec.md)
5. [quality-standards.md](references/quality-standards.md)
6. [gotchas.md](gotchas.md)
7. [readme-skeleton.md](assets/readme-skeleton.md)、[agents-skeleton.md](assets/agents-skeleton.md)
8. [docs-skill-skeleton.md](references/docs-skill-skeleton.md) — docs 族结构 SSOT

## 门禁

覆盖根 README.md / AGENTS.md 前须步骤 0 确认与用户 **C** / **S**（[gates.md](references/gates.md)、[CONVENTIONS.md](../../rules/CONVENTIONS.md) 中等风险）。

## 产出

默认 `{REPO_ROOT}` 下 README.md、AGENTS.md（`--output` 可只其一）。

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 评测 / 脚本

评测：`evals/evals.json`、[grader.md](agents/grader.md)、[analyzer.md](agents/analyzer.md)。前置：INDEX 须已落盘（例外见 execution-spec.md）。
