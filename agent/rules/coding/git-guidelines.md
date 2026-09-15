# Git提交规范指南

> Conventional Commits；**本仓 Agent 强制**（非「按需启用」）。

**结论**：未获用户确认不得 `commit`/`push`；`origin` 远程优先 SSH；message 为 `<type>(<scope>): <中文主题>`。

## 提交前确认（强制）

**禁止**未经用户同意执行 `git commit` / `git push`。须先给变更摘要与建议说明，用户**明确确认**后再执行。

**例外**：同一会话用户明确说「请提交」并认可说明 → 可直接执行。

## 远程：SSH 优先

适用：Agent 对本仓 `origin` 的 `fetch` / `pull` / `push`。

| 规则 | 要求 |
| --- | --- |
| 默认 | fetch/push URL 均用 SSH（例：`git@github.com:{owner}/{repo}.git`） |
| 配置范围 | 不改全局 `git config`；仅允许仓库级 `git remote set-url` |
| 用户否决 | 同会话要求保留/使用 HTTPS → 不自动切 SSH |

### 静默修正（已确认远程操作之后、执行之前）

1. `git remote get-url origin`
2. 若为 `http://` / `https://` → 转 SSH 并执行：
   ```bash
   git remote set-url origin <ssh-url>
   git remote set-url --push origin <ssh-url>
   ```
3. 继续原定远程命令；若曾切换，回复中简述（例：「已将 `origin` 从 HTTPS 切换为 SSH：…」）
4. 已是 `git@` / `ssh://` → 跳过
5. HTTPS 失败（如 443 超时）→ 按上流程切 SSH **重试一次**；仍失败则停并上报，不无限重试
6. 非 GitHub 主机 → **不**自动转换；告知需手动配 SSH URL

| HTTPS | SSH |
| --- | --- |
| `https://github.com/{owner}/{repo}.git` | `git@github.com:{owner}/{repo}.git` |
| `https://github.com/{owner}/{repo}` | `git@github.com:{owner}/{repo}.git` |

## 提交格式

### 语言（含 IDE「生成提交说明」）

- 首行：`<type>(<scope>): <中文主题>`；必要时空行后正文
- **type** 小写英文（下表）；**scope** 英文或项目缩写；subject/body/**列表用中文**
- **禁止**：除 type 前缀外，仅用英文写 subject/body

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型

| 类型 | 用途 |
| --- | --- |
| `feature` | 新功能 |
| `fix` | 缺陷修复 |
| `docs` | 文档/注释/README |
| `style` | 纯格式，不影响行为 |
| `refactor` | 重构（无新功能；可含性能整理） |
| `performance` | 专指性能优化 |
| `test` | 测试 |
| `chore` | 构建/依赖/配置 |
| `revert` | 回退 |

示例：

```text
docs(sdx-solution): 补充工作流说明与易错点

- 同步 audience 与 workflow 章节
- 明确用户确认闸门表述
```

```text
fix(order): 修复订单金额计算错误

- 修正 BigDecimal 精度丢失
- 补充边界测试

Fixes: PROJ-456
```

紧急修复（含安全）一律用 `fix`；footer 可带 `Security:` / issue 号。

## 原则与清单

1. **原子**：一提交一逻辑变更  
2. **完整**：含必要代码与测试  
3. **可回滚**：可独立回滚  
4. **可追溯**：关联需求/问题（有则写 footer）

**提交前**

- [ ] 单测通过  
- [ ] 符合项目编码规范  
- [ ] message 格式正确、范围准确  
- [ ] 已关联需求/问题编号（若有）

**大功能**：功能分支多次提交后，合并可用 `git merge --squash` 收成一次完整 message（仍须用户确认后再 commit）。

push 与 commit 同属文首确认闸门；**无**自动 rebase / 自动 push。
