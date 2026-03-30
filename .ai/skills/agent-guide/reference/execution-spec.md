# 执行规范

agent-guide 技能的执行细节：Index 解析规则、探索策略、错误处理。

三文件分工去重见 [three-file-spec.md](three-file-spec.md)；验收清单与反模式见 [quality-standards.md](quality-standards.md)。

---

## 1. Index 解析（启动必做，唯一地图）

### 1.1 落盘路径（命中即停）

按优先级查找 **当前仓库** 下的 Index Guide，命中即停并 **记录实际相对路径**（后续一律称「当前 INDEX」）：

1. 项目根 `INDEX_GUIDE.md`、`INDEX-GUIDE.md`
2. `system/INDEX_GUIDE.md`、`system/INDEX-GUIDE.md`

### 1.2 命中后的行为

- **立即**以该落盘文件为 **唯一** 探索地图进入工作流步骤 2，**禁止**在本 Skill 内调用 document-indexing 或征求「重做/沿用」。
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
- `system/knowledge/`：只读各层 README/INDEX，不通读实体文档

---

## 3. 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Index 落盘路径不存在 | §1.1 搜索全部未命中 | 终止，提示用户运行 document-indexing |
| Index 内容为空或格式异常 | 文件存在但无九章结构 | 警告，仅提取可用章节 |
| README.md 已存在冲突段落 | diff 比较 | 合并而非覆盖，保留有效命令块 |
| 模板路径不存在 | `test -f` 校验 | 警告，使用内置默认骨架 |
| AGENTS 路径引用失效 | 验证脚本检测 | 标记为 `[TODO: 路径待确认]` |
