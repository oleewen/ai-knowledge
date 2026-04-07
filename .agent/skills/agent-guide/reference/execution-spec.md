# 执行规范

agent-guide 的 Index 解析细则、探索策略与错误处理。SKILL.md 中已有的流程概述不在此重复。

三文件分工去重见 [three-file-spec.md](three-file-spec.md)；验收清单与反模式见 [quality-standards.md](quality-standards.md)。

---

## 1. Index 解析细则

### 落盘路径（命中即停）

按优先级查找，命中即停并记录实际相对路径（后续称「当前 INDEX」）：

1. 项目根 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`
2. `application/INDEX_GUIDE.md`、`application/INDEX-GUIDE.md`

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

- `.agent/rules/CONVENTIONS.md`：做目录浏览与文件头校验
- 已有根 `README.md`：更新时合并重复段落，保留有效表格/命令块结构
- `application/knowledge/`：只读各层 README/INDEX，不通读实体文档

---

## 3. 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Index 落盘路径不存在 | §1.1 搜索全部未命中 | 终止，提示用户运行 docs-indexing |
| Index 内容为空或格式异常 | 文件存在但无九章结构 | 警告，仅提取可用章节 |
| README.md 已存在冲突段落 | diff 比较 | 合并而非覆盖，保留有效命令块 |
| 模板路径不存在 | `test -f` 校验 | 警告，使用内置默认骨架 |
| AGENTS 路径引用失效 | 验证脚本检测 | 标记为 `[TODO: 路径待确认]` |
