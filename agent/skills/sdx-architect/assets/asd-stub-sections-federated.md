# ASD 联邦概要（`KNOWLEDGE_TYPE` = system | company）

- **本库 ASD**：写 §1、§2、§3（架构级摘要表，可选用 [asd-spec-template.md](asd-spec-template.md)）。
- **应用库**：实现级接口、DDL、**spec-dsd-*.md**、**DSD** 由 **`/sdx-design`** 落盘并评审。

## ASD §2 末可选：下游承接

| 服务/子域 | 预计应用知识库 | DSD 占位（应用落盘后回填） |
|-----------|----------------|---------------------------|
| … | `application-foo` / 路径 | 待 `DSD-{IDEA-ID}-{N}.md` |

## 迁移说明

若历史单文件 ADD 含「§3 详细设计 / §4 需求规约」大块占位：删除该模式；现由 **ASD §3 摘要表 + 应用库 DSD** 承接，勿在 ASD 贴实现级伪章节。
