---
name: docs-push
description: >
  按 knowledge-links.yaml 将中央规约复制到各应用本机 path×doc_dir（legacy spec → specs/；spec-asd → requirements/…/specs/）。
  用户提到 /docs-push、推 spec 到应用库、按 knowledge-links 同步规约时，使用本技能。
  分流：仅 docs-pull / distill / SDD / overview 时 → 对应技能；DSD 正文一般不经本技能。
  推进见 light-flow-actions（C/M/S/F，无 G）与 references/gates.md。
---

# docs-push

## 输出硬约束（P0）

- 当前单元：单个目标 repo/path 组。
- 轻流程：参数向导 → 风险校核 → `C/M/S/F`（无 `G`、不绑意图澄清）→ [light-flow-actions.md](../../references/light-flow-actions.md)；细节 [gates.md](references/gates.md)。非 `--dry-run` 写盘前参数未收口不得 `copy`。
- 当前目标单元校核完成前，不得自动推进下一目标。
- `git push`、覆盖目标、`git-op`、`--branch` 等语义风险须先确认；未确认不得执行。
- `--dry-run` 结果未确认前，不得静默切到实跑。

## 边界

| 负责 | 不负责 |
| --- | --- |
| legacy / spec-asd 规约路由与复制；Git 四档 | DSD 正文（sdx-design）；docs-pull 镜像回拉 |

## 不这样用

- 不把「先 dry-run 再 copy」写成无停顿流水线；dry-run 后须先校核当前目标
- 不把 `docs-pull` 回拉或 DSD 正文主路径收成 `docs-push`
- 不在未确认 `git push` 时静默推进远端

## 路由

| 目的 | 文件 |
| --- | --- |
| 流程 / 风险 | [workflow.md](references/workflow.md)、[gates.md](references/gates.md) |
| 参数 | [parameters.md](references/parameters.md) |
| 轻流程动作 | [light-flow-actions.md](../../references/light-flow-actions.md) |
| 易错 | [gotchas.md](gotchas.md) |

## 最少输入

- `--specs-dir`、`--links`、`--mode`
- `--git-op` 与必要时的 `--branch`

## 产出与脚本

- 正式：目标应用本机 `{doc_dir}/specs/` 或 `requirements/…/specs/`（YAML + 脚本为准）
- 收敛后动作见 [light-flow-actions.md](../../references/light-flow-actions.md)（本技能有 `S`，无 `G`）

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir DIR --links system/knowledge-links.yaml --mode path
```

## 评测

`evals/evals.json`、[grader.md](agents/grader.md)（P0 断言为准）。重点：单目标停顿、dry-run 路由确认、git-op 风险确认、不得静默 push。
