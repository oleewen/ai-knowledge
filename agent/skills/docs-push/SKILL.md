---
name: docs-push
description: >
  按 knowledge-links.yaml 将中央规约复制到各应用本机 path×doc_dir（legacy spec → specs/；spec-asd → requirements/…/specs/）。
  触发：推 spec 到应用库、按 knowledge-links 同步、docs-push。
  分流：仅 docs-pull/distill/SDD/overview 时 → 对应技能；DSD 正文一般不经本技能。
  推进协议：轻流程；参数向导、当前目标单元、风险校核、C/M/S/F 见 references 与 [light-flow-actions.md](../../references/light-flow-actions.md)。
---

# docs-push：spec 推送到建联目标

参数向导 → 处理单个目标 repo/path 当前单元 → 风险校核 → 用户动作推进。

## 输出硬约束（P0）

- 一次只处理一个“当前目标单元”：单个 repo/path 组。
- 非 `--dry-run` 写盘前，参数未收口时不得执行 `copy`。
- 当前目标单元校核完成前，不得自动推进下一个目标。
- `git push`、覆盖目标文件、`git-op` 选择、`--branch` 切换等语义性风险项必须先给出结论、推荐方案与数字选项；未获确认不得执行。
- `--dry-run` 结果未确认前，不得静默切到实跑。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| legacy / spec-asd 规约路由与复制；Git 四档 | DSD 正文（sdx-design）；docs-pull 镜像回拉 |

## 不这样用

- 不把旧“先 dry-run 再 copy”写成无停顿流水线；dry-run 后应先校核当前目标单元
- 不把 `docs-pull` 镜像回拉或 DSD 正文编写主路径收成 `docs-push`
- 不在未确认 `git push` 时静默推进远端操作

## 最短路径

1. [gates.md](references/gates.md)
2. [parameters.md](references/parameters.md)
3. [workflow.md](references/workflow.md)
4. [light-flow-actions.md](../../references/light-flow-actions.md) — `C/M/S/F`
5. [gotchas.md](gotchas.md)

## 最少输入

- `--specs-dir`
- `--links`
- `--mode`
- `--git-op` 与必要时的 `--branch`

## 当前目标单元

- 单个目标 repo/path 组

当前目标单元收敛后，动作字母见 [light-flow-actions.md](../../references/light-flow-actions.md)（`C/M/S/F`，无 `G`）。

## 产出

目标应用本机 `{doc_dir}/specs/` 或 `requirements/…/specs/`（YAML + 脚本为准）。

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir DIR --links system/knowledge-links.yaml --mode path
```

## 评测 / 脚本

评测：[evals/evals.json](evals/evals.json)。`--specs-dir` 与 `--links` 细则见 parameters.md。
评测重点：单目标停顿、dry-run 路由确认、git-op 风险确认、不得静默 push。
