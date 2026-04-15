# 执行规范

agent-guide 的 Index 解析细则、探索策略与错误处理。SKILL.md 中已有的流程概述不在此重复。

三文件分工去重见 [three-file-spec.md](three-file-spec.md)；验收清单与反模式见 [quality-standards.md](quality-standards.md)。

---

## 0. 需求对齐与路径选择

在**任何**落盘或覆盖根目录 `README.md`、`AGENTS.md` 之前，先判断走快速路径还是澄清路径（与 brainstorming 类流程对齐：**未对齐范围前不执行「生成」**）。

### 快速路径（默认）

同时满足时可跳过逐轮提问，直接进入 [§1](#1-index-解析细则)：

- 用户给出或自然语言可**唯一推断** `--output` 与 `--mode`（含明确同义表述，如「只更新 AGENTS」→ `agents` + `update`）。
- 任务范围明确指向本仓库入口文档，无「顺便重写其他目录文档」等歧义。

### 澄清路径（条件触发）

出现以下任一情况时进入澄清路径，**HARD-GATE**：未完成本节对齐前**不得**写入或覆盖 README/AGENTS：

- 未说明输出范围（只 README、只 AGENTS 或两者）。
- 未说明 `create` 与 `update`（首次初始化 vs 在已有文件上增量合并）。
- 指令过宽（如「整理一下项目文档」）且未限定为根目录 README/AGENTS。

**分步提问**：每次只问一个点；可先给出推荐（例如 `both` + `update`）请用户二选一或确认。对齐后再进入 §1。

### 与后续步骤的关系

§1 的 Index 技术门禁（无落盘 INDEX 则终止）仍然独立成立；步骤 0 解决的是**写哪些文件、以何种合并策略**，不替代 Index 解析。

---

## 1. Index 解析细则

### 落盘路径（命中即停）

按优先级查找，命中即停并记录实际相对路径（后续称「当前 INDEX」）：

1. `REPO_ROOT/INDEX_GUIDE.md`、`REPO_ROOT/INDEX-GUIDE.md`
2. `DOC_ROOT/INDEX_GUIDE.md`、`DOC_ROOT/INDEX-GUIDE.md`

### 命中后的行为

- 以该落盘文件为**唯一**探索地图，禁止在本 Skill 内调用 docs-indexing。
- 禁止用「用户粘贴的 Index 全文」替代落盘文件；仓库存在 §1.1 路径时一律以磁盘版本为准。

### 未命中时的降级例外

默认行为：终止，提示用户运行 `/docs-indexing`。

**显式降级**：仅当用户**明确声明**「仓库无 Index、授权用根 README/顶层目录做最小摸底」时，可生成**极简** README/AGENTS，并**必须**写明「无标准 INDEX、建议补 docs-indexing」；仍禁止捏造模块细节。

---

## 2. 探索策略

以 INDEX 为导航，只打开与「README 首屏 / AGENTS 契约」相关的文件，禁止通读全仓。

| INDEX 章节 | 探索用途 | 写入去向（摘要） |
|-----------|----------|-----------------|
| §1 元信息 | 技术栈、入口、命令 | README：简介 + Quick start；AGENTS：≤3 行 + 指针 |
| §2 拓扑 | 目录边界、依赖方向 | README：**唯一**详写目录树处；AGENTS：短列表 |
| §3 API 入口 | 按需打开 ⭐⭐⭐ 条目 | **不**粘贴进 AGENTS；一句指向当前 INDEX §3 |
| §4–§5 | 领域对象/组件配置 | 仅当 README 要写环境/运行方式时再读 |
| §6 未索引 | 盲区 | 须描述某路径 → 只补读该路径；否则「详见 INDEX §6」 |
| §7 查阅指北 | 检索顺序 | AGENTS 与此一致，不另写矛盾策略 |

### 轻量校验（可与 Index 对照）

- `agent/rules/CONVENTIONS.md`：做目录浏览与文件头校验
- 已有根 `README.md`：更新时合并重复段落，保留有效表格/命令块结构
- `DOC_ROOT/knowledge/`：只读各层 README/INDEX，不通读实体文档

---

## 3. 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Index 落盘路径不存在 | §1.1 搜索全部未命中 | 终止，提示用户运行 docs-indexing |
| Index 内容为空或格式异常 | 文件存在但无九章结构 | 警告，仅提取可用章节 |
| README.md 已存在冲突段落 | diff 比较 | 合并而非覆盖，保留有效命令块 |
| 模板路径不存在 | `test -f` 校验 | 警告，使用内置默认骨架 |
| AGENTS 路径引用失效 | 验证脚本检测 | 标记为 `[TODO: 路径待确认]` |
