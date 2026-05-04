# docs-pull 写盘闸门与确认规则

[SKILL.md](../SKILL.md) 为主干；四步工作流与脚本见 [workflow.md](workflow.md)。

---

## 与 SDX / docs-extract 闸门的区别（必须理解）

- 按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 总表，**docs-pull 为低风险技能**：**不**要求 `docs/superpowers/specs/` 中间会话 spec，**不**使用 `<!-- …-gate: PENDING|CONFIRMED -->` 式 HTML 标记，**无** `preToolUse` 钩子拦截本路径。
- 本页 **HARD-GATE** 指：**在非 `--dry-run` 真正改写 `applications/app-{APPNAME}/` 之前**，须在对话中满足下文条件并完成必要确认（与「参数确认」同层，而非 SDD 产物闸门）。

---

## 写盘 HARD-GATE（实跑 rsync / 覆盖镜像前）

须**同时**满足：

1. **目标应用已明确**：`--app` 已给出，或用户已从列表中选定唯一应用。
2. **目标分支已明确**：`--branch` 已给出，或自动探测（`main` → `master`）已成功，或用户已确认使用某一分支。
3. **manifest 可读且 `repo_url` 非空**；否则终止，见 [gotchas.md](../gotchas.md)。
4. 若将使用 **`--force`** 或存在**大范围覆盖**语义（例如「全部覆盖」「不管本地差异」），须取得用户**一句显式确认**后再执行。

**允许快路径**：用户已明确给出 `--app`、`--branch`，且无 `--force`/冲突语义时，可直接执行（或先 `--dry-run` 再实跑，由用户一句话指定）。

---

## 何时必须停下问用户（不猜）

| 情况 | 动作 |
|------|------|
| 未指定 `--app` 且存在 **多个** 已注册应用 | 列出候选，**每次只问一个**：先选定应用，再谈分支。 |
| `git clone` / 指定分支失败 | 提示原因，列出远端可用分支（若可获取），给选项；**不**自动换分支除非用户明确授权。 |
| `main` 与 `master` 均不存在 | 终止，请用户指定 `--branch`。 |
| `repo_url` 缺失或为空 | 终止，请用户补 manifest。 |
| 意图不清（如「同步一下」且多应用未点名） | 先列应用再问选哪一个。 |
| 用户说「全部同步」多应用 | 明确是**逐个应用各过一次写盘确认**，还是只对单一应用执行；禁止默认静默扫全部，除非用户明确授权。 |

---

## 实跑前简短确认（建议话术）

在 HARD-GATE 已满足、且非纯 `--dry-run` 时，建议复述一行事实并请确认，例如：

> 将以分支 `{branch}` 从 `{repo_url}` 同步到 `applications/app-{APPNAME}/`，是否继续？

用户拒绝则中止。

---

## 与「完整 brainstorming / SDD」的边界

若目标超出「把已登记应用的远端文档拉到联邦镜像」（例如重组 `applications/`、改多仓合并策略、重定义 `docs_root` 约定），应先完成需求澄清或设计任务，再回到本技能的参数与 manifest 事实。本页**不替代**应用级 SDD 或仓库级设计文档。
