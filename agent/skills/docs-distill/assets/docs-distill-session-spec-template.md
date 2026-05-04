# docs-distill 会话 spec 骨架

路径约定：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-distill.md`

复制后替换尖括号占位；**不要**在取得用户总确认前删除 `PENDING` 行。

---

## 1. 背景与目标

- 应用：`<APPNAME>`
- 触发原因：`<例如 CHANGE-LOG 新版本条目 / 用户口头请求>`

## 2. 参数与范围

- `--app`：`<值或「全部已登记应用」>`
- `--since`：`<无则写「自动锚点」或具体 id>`
- `--full`：`<是/否>`
- 是否已 `--dry-run`：`<是/否，结论一句话>`

## 3. 蒸馏区间摘要

- 候选变更区间：`<起止 changelog_id 或 BEGIN→HEAD>`
- 目标文件：`system/architecture/overview/<APPNAME>-overview.md`（`<新建 | 更新>`）

## 4. 门禁进度（可选）

与 `sdx-*` 会话 spec 同构时，两列表格锚到**本文件**小节。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

## 5. 风险与待定

- `<无则写「无」>`

---

<!-- docs-distill-gate: PENDING -->

（用户总确认后改为：`<!-- docs-distill-gate: CONFIRMED -->`）
