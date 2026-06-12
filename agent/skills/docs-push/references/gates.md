# docs-push 闸门

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（会话 spec 落在 `{DOC_DIR}/superpowers/specs/`，排除 `requirements/**/specs/`）。
命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-push 为**低风险工程同步**：不要 SDX 中间 spec、无 HTML gate。

**HARD-GATE**：非 `--dry-run` **覆盖目标文件**或执行 **`git push`** 前，须在对话取得用户明确同意；**禁止**未确认替用户 `push` 或改生产分支。

## copy 前

1. `--links` 与 `--specs-dir` 已确认。
2. `--mode repo` 时 **`--branch`** 已确认（`checkout -B` 会创建/移动该分支尖端，见 parameters）。
3. 建议先 **`--dry-run`**。

## `git` 子命令

| 档位 | 确认 |
|------|------|
| `none` / `stage` | 仍建议用户知晓将触碰的仓库 |
| `commit` | 用户已定 `--message`（或逐字确认） |
| `push` | **须**一句显式授权后再执行 |
