# Index 解析、探索与错误处理

步骤 0：[gates.md](gates.md)。分工：[three-file-spec.md](three-file-spec.md)。验收：[quality-standards.md](quality-standards.md)。

## 1. Index 解析

**路径（命中即停）**，记下相对路径为「当前 INDEX」：

1. `REPO_ROOT/INDEX_GUIDE.md`、`INDEX-GUIDE.md`
2. `DOC_ROOT/` 同上

**命中后**：仅以该文件为地图；不调 docs-indexing；不以用户粘贴替换磁盘（磁盘优先）。

**未命中**：默认终止 → `/docs-indexing`。  
**例外**：用户**明确**授权「无 Index、仅用根 README/顶层摸底」→ 可写**极简**双文件并声明「建议补 indexing」；仍禁止捏造模块细节。

## 2. 探索

以 INDEX 导航；只开与 README 首屏 / AGENTS 契约相关文件。**禁止通读全仓**。

| 章节 | 探索 | 写入（摘要） |
| ---- | ---- | ------------ |
| §1 | 技术栈、入口、命令 | README 简介+Qstart；AGENTS ≤3 行+指针 |
| §2 | 拓扑 | README **唯一详写树**；AGENTS 短列表 |
| §3 | ⭐⭐⭐ 按需打开 | **不**贴进 AGENTS；一句「见当前 INDEX §3」 |
| §4–§5 | 组件/配置 | 仅 README 要写运行/环境时再读 |
| §6 | 未索引 | 写某路径则只读该路径；否则「详见 §6」 |
| §7 | 查阅指北 | AGENTS 与此一致 |

**轻量对照**：`agent/rules/CONVENTIONS.md`；已有根 README 在 `update` 时合并；`DOC_ROOT/knowledge/` 只读各层 README/INDEX。

## 3. 错误处理

| 场景 | 处理 |
| ---- | ---- |
| 无落盘 Index | 终止 → docs-indexing |
| Index 空或结构异常 | 警告，仅取可用节 |
| README 已有内容 | diff 合并，留有效命令块 |
| 模板缺失 | 警告，用内置骨架 |
| AGENTS 链失效 | 脚本标出；可标 `[TODO: 路径待确认]` |
