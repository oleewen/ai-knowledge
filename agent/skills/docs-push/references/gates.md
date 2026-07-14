# docs-push 风险控制与确认点

命令细节见 [parameters.md](parameters.md)、[workflow.md](workflow.md)。

## 与 CONVENTIONS

按 [agent/rules/CONVENTIONS.md](../../../rules/CONVENTIONS.md#artifact-gates)，docs-push 为**低风险工程同步**：按参数确认与风险校核推进。

非 `--dry-run` **覆盖目标文件**或执行 **`git push`** 前，须在对话取得用户明确同意；**禁止**未确认替用户 `push` 或改生产分支。

## 参数确认

参数向导至少收口以下内容：

- `--links`
- `--specs-dir`
- `--mode`
- `--git-op`
- `--branch`（需要时）
- `--strict`

建议先 **`--dry-run`**。

## 风险与动作

以下情况属于风险项，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- `--dry-run` 路由结果与预期不一致
- `mode=repo` 时需要切分支
- `git-op=commit` 或 `push`
- 当前目标单元涉及覆盖已有目标文件

推荐会话格式：

```text
即将执行 /docs-push，当前参数如下：
- specs-dir: <路径>
- links: <路径>
- mode: <path|repo>
- git-op: <none|stage|commit|push>
- 当前目标单元: <repo/path 组>

C 确认当前目标单元 / M 修改参数 / S 跳过当前目标 / F 补齐剩余目标
```

## `git` 子命令

| 档位 | 确认 |
| ---- | ---- |
| `none` / `stage` | 仍建议用户知晓将触碰的仓库 |
| `commit` | 用户已定 `--message`（或逐字确认） |
| `push` | **须**一句显式授权后再执行 |
