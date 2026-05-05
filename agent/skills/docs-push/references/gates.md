# docs-push 闸门与确认

[SKILL.md](../SKILL.md) 为主干；命令与示例见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

---

## 与 CONVENTIONS 的关系

- 按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates) 总表，**docs-push 为低风险工程同步**：不要求 SDX 中间会话 spec，无 HTML gate 标记。
- **HARD-GATE** 指：在非 `--dry-run` **覆盖写入目标库文件**或执行 **`git push`** 前，须在对话中取得用户明确意图；**禁止**在未确认时代用户执行 `push` 或改写生产分支。

---

## 实跑 copy（写目标 specs）前

1. **`--links`** 指向的 `knowledge-links.yaml` 与 **`--specs-dir`** 已由用户确认。
2. **`--mode repo`** 时 **`--branch`** 已确认；知晓 `git checkout -B` 会移动/创建该分支尖端（见 [parameters.md](parameters.md)）。
3. 建议先 **`--dry-run`**，再实跑。

---

## Git 四档（`git` 子命令）

| 档位 | 须确认 |
|------|--------|
| `none` / `stage` | 仍建议用户知晓将触碰的仓库路径。 |
| `commit` | 用户已提供 `--message`（或由用户逐字确认 message）。 |
| `push` | **必须**用户一句显式授权后再执行（含 dry-run 预览后的「可以 push」）。 |
