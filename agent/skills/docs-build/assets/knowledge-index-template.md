# KNOWLEDGE-INDEX

> 扫描生成；非 SSOT。实体正文 ∈ 各视角 per-entity `{ID}.md`。

---

## 统一表头规范

- **标准表头**：`["层级","ID","别名（英文名）","名称","证据链"]`
- **字段语义**：`ID` 为完整实体 ID（如 `BU-EXAMPLE`）；`别名（英文名）` 为英文编码；`名称` 为中文名称
- **唯一性约束**：`层级+ID` 全知识库唯一；`层级+别名（英文名）` 全知识库唯一

---

## §1 业务视角（business · …）

| 层级 | ID | 别名（英文名） | 名称 | 证据链 |
|------|----|--------------|------|---------|
| {TYPE} | {TYPE}-{NAME} | {Alias} | {名称} | `{perspective}/…` |

---

## §2–§5

按层实体集分节（company / system / application 前缀不同）；由 `generate_knowledge_index.py` 扫描写入。
