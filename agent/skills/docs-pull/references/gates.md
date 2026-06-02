# 写盘闸门

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（会话 spec 落在 `{DOC_DIR}/superpower/specs/`，排除 `requirements/**/specs/`）。
主干：[SKILL.md](../SKILL.md)；脚本：[workflow.md](workflow.md)。

## 与 SDX/extract 区别

CONVENTIONS **低风险**：**不要**会话 spec、`<!-- …-gate -->` HTML、`preToolUse` 拦本路径。  
本页 HARD-GATE = **非 `--dry-run` 真要改镜像前**，对话内需满足以下条件（与参数确认同级，≠ SDD 产物闸）。

## HARD-GATE（实跑 rsync 前）

**同时**满足：

1. **app**：`--app` 已定，或多 app 场景用户**已选一个**。  
2. **分支**：`--branch` 已定，或 `main`→`master` 探测**成功**。  
3. **manifest**：可读且 **`repo_url` 非空**（否则停，见 [gotchas.md](../gotchas.md)）。  
4. **`--force` 或大范围覆盖**用语 → **用户一句话确认**后再跑。

**快路径**：用户已给 `--app`+`--branch` 且无 force/歧义 → 可直接跑（或先 `--dry-run`）。

## 须停问（勿猜）

| 情况 | 动作 |
| ---- | ------ |
| 多 app、未点名 | **一次一问**列候选 → 选型 |
| clone/分支失败 | 报错；列远端分支（若可得）；不换分支除非用户明示 |
| 无 main/master | **停**，请 `--branch` |
| `repo_url` 空/缺 | **停**，补 manifest |
| 「同步一下」意图糊 | 先列应用 |
| 「全部同步」多 app | 明确：**逐 app 各自确认**，或用户明示授权静默全扫 |

## 建议复述（非纯 dry-run）

> 将以 `{branch}` 从 `{repo_url}` 同步到 `applications/app-{APPNAME}/`，是否继续？

拒 → 中止。

## 边界

超出「登记应用远端文档 → 镜像」的（重组 `applications/`、多仓策略、重写联邦契约）→ 先方案/ADR，再回到 manifest 与本脚本。此文**不代替** SDD。
