# Git提交规范指南

> Git版本控制规范，基于Conventional Commits标准

## 提交前用户确认（强制，全仓库）

**禁止**未经用户同意执行 `git commit` / `git push`。提交前须说明变更摘要与建议提交说明，待用户**明确确认**后再执行。**例外**：用户在同一会话中明确指令「请提交」并认可说明时可直接执行。

---

## 远程传输：SSH 优先

本节规范 **Agent** 在本仓库执行远程 Git 操作时的传输方式。

### 默认协议

涉及 **`origin`** 的 `git fetch` / `git pull` / `git push` 时，fetch 与 push URL 均优先使用 **SSH**（GitHub 示例：`git@github.com:{owner}/{repo}.git`）。

- 不修改全局 `git config`；仅允许仓库级 `git remote set-url`。
- 用户在同一会话明确要求保留或使用 HTTPS 时，不自动切换。

### Agent 执行流程（静默修正）

在用户已确认远程操作（例如已同意 `git push`）后、实际执行 `fetch` / `pull` / `push` **之前**：

1. 读取 `origin` URL：`git remote get-url origin`
2. 若 URL 以 `http://` 或 `https://` 开头，按下方规则转换为 SSH，并执行：
   ```bash
   git remote set-url origin <ssh-url>
   git remote set-url --push origin <ssh-url>
   ```
3. 继续原定远程命令。
4. 若曾切换 URL，操作完成后在回复中简要说明，例如：「已将 `origin` 从 HTTPS 切换为 SSH：`git@github.com:oleewen/ai-knowledge.git`」。

若远程操作因 HTTPS 连接失败（如 443 超时），按上述流程切换 SSH 后**重试一次**；仍失败则停止并上报错误，不无限重试。

URL 已是 `git@` 或 `ssh://` 形式时跳过修正。

### GitHub HTTPS → SSH 转换

| HTTPS | SSH |
|-------|-----|
| `https://github.com/{owner}/{repo}.git` | `git@github.com:{owner}/{repo}.git` |
| `https://github.com/{owner}/{repo}` | `git@github.com:{owner}/{repo}.git` |

非 GitHub 主机不自动转换；告知用户需手动配置 SSH URL。

---

## 提交格式规范

### 语言与适用范围（含 IDE 生成提交说明）

编写或生成任意 commit message（含 Cursor / VS Code「生成提交说明」）时：

- **格式**：首行 `<type>(<scope>): <中文主题>`，必要时空行后接正文；**type** 小写英文（与下表一致），**scope** 可用英文或项目缩写；subject、body、列表用**中文**。
- **禁止**：除类型前缀外，勿仅用英文撰写 subject/body。

示例：

```
docs(sdx-solution): 补充工作流说明与易错点

- 同步 audience 与 workflow 章节
- 明确用户确认闸门表述
```

### 标准格式
```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

### 提交类型说明

| 类型 | 描述 | 使用场景 |
|------|------|----------|
| **feature** | 新增功能 | 添加新功能、新特性 |
| **fix** | 修复bug | 修复代码缺陷、异常处理 |
| **docs** | 文档注释 | 更新文档、注释、README |
| **style** | 代码格式 | 不影响代码运行的格式调整 |
| **refactor** | 重构优化 | 代码重构、性能优化，不增加新功能 |
| **performance** | 性能优化 | 专门用于性能相关优化 |
| **test** | 增加测试 | 添加测试用例、测试框架 |
| **chore** | 构建工具 | 构建过程、依赖管理、配置文件 |
| **revert** | 回退代码 | 撤销之前的提交 |

### 提交示例

#### 功能开发
```
feature(appeal): 添加申诉单创建功能

- 实现Appeal聚合根的创建逻辑
- 添加申诉验证规则
- 集成领域事件发布

Resolves: PROJ-123
```

#### Bug修复
```
fix(order): 修复订单金额计算错误

- 修正BigDecimal精度丢失问题
- 添加金额范围验证
- 补充边界测试用例

Fixes: PROJ-456
```

#### 文档更新
```
docs(api): 更新申诉API文档

- 补充申诉创建接口参数说明
- 添加错误码对照表
- 更新接口版本信息
```

#### 代码重构
```
refactor(domain): 优化订单状态机实现

- 将状态转换逻辑提取到独立类
- 使用策略模式处理状态转换
- 减少领域模型的复杂度
```

### 紧急修复
```
hotfix(security): 修复SQL注入漏洞

- 更新MyBatis参数绑定方式
- 添加输入验证
- 补充安全测试用例

Security: CVE-2023-XXXX
```

## 提交原则

### 核心原则
1. **原子性**: 每个提交只包含一个逻辑变更
2. **完整性**: 提交必须包含完整的变更（代码+测试）
3. **可回滚**: 每个提交都可以独立回滚
4. **可追溯**: 提交信息必须关联需求或问题

### 提交前检查清单
- [ ] 代码通过所有单元测试
- [ ] 代码符合项目编码规范
- [ ] 提交信息格式正确
- [ ] 变更范围描述准确
- [ ] 关联需求/问题编号

### 提交后流程
1. **自动rebase**: 提交后自动rebase远程代码
2. **冲突处理**: 如有冲突需手动解决
3. **自动推送**: 无冲突时自动push到远程

## 特殊情况处理

### 大功能拆分
当功能过大时，使用`--squash`合并多个相关提交：
```bash
# 创建功能分支
git checkout -b feature/large-feature

# 开发过程中多次提交
git commit -m "feature(large): 第一部分实现"
git commit -m "feature(large): 第二部分实现"
git commit -m "feature(large): 第三部分实现"

# 合并为一个提交
git checkout main
git merge --squash feature/large-feature
git commit -m "feature(large): 完整功能实现"
```
