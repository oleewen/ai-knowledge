# 执行规范与验证清单

agent-guide 技能的详细执行规范，包含 Index 解析、探索策略、三文件分工去重、验收标准与反模式。

---

## 1. Index 解析（启动必做，唯一地图）

### 1.1 落盘路径（命中即停）

按优先级查找 **当前仓库** 下的 Index Guide，命中即停并 **记录实际相对路径**（后续一律称「当前 INDEX」）：

1. 项目根 `INDEX_GUIDE.md`、`PROJECT_INDEX.md`（短入口）、`INDEX.md`（兼容别名）、`INDEX-GUIDE.md`
2. `docs/INDEX_GUIDE.md`、`docs/INDEX-GUIDE.md`

### 1.2 命中后的行为

- **立即**以该落盘文件为 **唯一** 探索地图进入工作流步骤 3，**禁止**在本 Skill 内调用 document-indexing 或征求「重做/沿用」。
- **禁止**用「用户粘贴的 Index 全文」替代落盘文件；仓库存在 §1.1 路径时一律以磁盘版本为准。

### 1.3 未命中任何落盘 Index

- **不**生成或更新 README/AGENTS（避免无地图编造结构）。
- 向用户说明：请先执行 `/document-indexing` 再执行本 Skill。
- **例外（显式降级）**：仅当用户 **明确声明**「仓库无 Index、授权用根 README/pom.xml/顶层目录做最小摸底」时，可生成 **极简** README/AGENTS，并 **必须** 写明「无标准 INDEX、建议补 document-indexing」；仍禁止捏造模块细节。

---

## 2. 探索策略：以 INDEX 为地图、最小阅读集

**原则**：Index 为导航与待办清单；只打开与「README 首屏 / AGENTS 契约」相关的文件，**禁止**为写 AGENTS 通读全仓。

| Index 章节 | 探索用途 | 写入去向（摘要） |
|-----------|----------|------------------|
| §1 元信息 | 技术栈、入口、命令 | README：简介 + Quick start；AGENTS：≤3 行 + 指针 |
| §2 拓扑 | 目录边界、依赖方向 | README：**唯一**详写目录树/结构处；AGENTS：短列表 |
| §3 API 入口 | **按需**打开 ⭐⭐⭐ 条目 | **不**粘贴进 AGENTS；一句指向当前 INDEX §3 |
| §4–§5 | 领域对象/表/数据流；组件配置/启动 | 仅当 README 要写环境/运行方式时再读 |
| §6 未索引 | 盲区 | 须描述某路径 → **只补读该路径**；否则「详见 INDEX §6」 |
| §7 查阅指北 | 检索顺序 | AGENTS 与此 **一致**，不另写矛盾策略 |

### 轻量校验（可与 Index 对照）

- `.ai/rules/CONVENTIONS.md`、`.ai/rules/`：做目录浏览与文件头校验
- 已有根 `README.md`：更新时合并重复段落，保留有效表格/命令块结构
- `knowledge/` 或 `system/knowledge/`：只读各层 README/INDEX，不通读实体文档

---

## 3. 三文件分工与去重（单一事实源）

| 文件 | 读者 | 放什么 | 不放什么 |
|------|------|--------|----------|
| **当前 INDEX** | AI 检索 | 九章、路径精要、未索引声明 | 冗长教程、重复命令百科 |
| **README.md** | 人类、GitHub 首屏 | H1 + 一句话、Quick start、文档索引表、目录结构 | Agent 角色与禁止项长文 |
| **AGENTS.md** | AI | 角色、约束、工作流、禁止项、短关键路径 | 完整命令手册、§3 API 入口全表副本 |

### 去重硬规则

1. **命令块、选项说明、大链接表** → 只放在 README；AGENTS 用「详见 README.md」+ 可选一条最常用示例。
2. **项目概述/技术栈**（AGENTS）各 **≤3 行**；细节见 README 与 INDEX §1。
3. **查阅顺序**（AGENTS 一句话）：当前主 Index 相对路径 → `README.md` → 子域 `**/INDEX.md` 或规范路径。

---

## 4. 产出规范

### 4.1 建议顺序：先 README，后 AGENTS

避免 AGENTS 写满命令后再在 README 重复粘贴；AGENTS 内链指向 README 已定稿的小节。

### 4.2 README.md

按 [.ai/skills/agent-guide/assets/readme-skeleton.md](../assets/readme-skeleton.md) 骨架生成，核心要求：

- 新读者约 30 秒内知道「是什么、下一步点哪」
- 相对路径可点、表格不空洞
- 与 INDEX §2 目录树 **一致**，禁止第二套矛盾树

### 4.3 AGENTS.md

按 [.ai/skills/agent-guide/assets/agents-skeleton.md](../assets/agents-skeleton.md) 骨架生成，核心要求：

- 基准为项目 `.ai/rules/agents-template.md`（可裁剪，禁止与模板语义冲突）
- 首条参考为 §1 确定的当前主 Index 相对路径
- INDEX §6 或未读路径不得写成已核实结论

---

## 5. 验收清单

### 发布前勾选

- [ ] README 与 AGENTS **无大段重复**
- [ ] AGENTS **未**堆叠 INDEX §3 级 API 入口表
- [ ] README 文档表、AGENTS「参考」、当前 INDEX 内路径 **一致、可跳转**
- [ ] AGENTS 首条参考 **非**误写路径
- [ ] 命令在 README 中 **可复制执行**（或明确链到含命令的子文档）
- [ ] 规范/模板路径在磁盘上 **存在**

### 反模式（禁止）

| 反模式 | 说明 |
|--------|------|
| AGENTS 重写文档索引表 | 在 AGENTS 里重写一份「完整文档索引表」 |
| Skill 内调用 document-indexing | 在本 Skill 执行流程内调用 document-indexing 或等待用户选择是否重做索引 |
| 无 Index 编造细节 | 无落盘 Index 且用户未授权例外时编造目录/模块细节 |
| 目录树矛盾 | README 与 INDEX §2 目录树互相矛盾 |
| 未索引写成已读 | 把「未索引」区域写死为已读事实 |

---

## 6. 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Index 落盘路径不存在 | §1.1 搜索全部未命中 | 终止，提示用户运行 document-indexing |
| Index 内容为空或格式异常 | 文件存在但无九章结构 | 警告，仅提取可用章节 |
| README.md 已存在冲突段落 | diff 比较 | 合并而非覆盖，保留有效命令块 |
| 模板路径不存在 | `test -f` 校验 | 警告，使用内置默认骨架 |
| AGENTS 路径引用失效 | 验证脚本检测 | 标记为 `[TODO: 路径待确认]` |
