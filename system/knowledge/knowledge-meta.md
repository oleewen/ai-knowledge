---
type: Perspective Tree Meta
title: 知识树元数据（system/knowledge）
---
# 知识树元数据（system/knowledge）

系统知识库五视角知识树元数据 SSOT。实例索引见 [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md)。

---

## 1. 概览

| 字段 | 值 |
| --- | --- |
| meta_id | `DIR-SYSTEM-KNOWLEDGE` |
| layer_scope | system |
| perspectives | business, product, application, data, technical |

---

## 2. 子目录

| 目录 | 视角 | meta | 实例索引 |
| --- | --- | --- | --- |
| business/ | 业务 | [business-meta.md](business/business-meta.md) | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §1 |
| product/ | 产品 | [product-meta.md](product/product-meta.md) | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §2 |
| application/ | 应用 | [application-meta.md](application/application-meta.md) | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §3 |
| data/ | 数据 | [data-meta.md](data/data-meta.md) | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §4 |
| technical/ | 技术 | [technical-meta.md](technical/technical-meta.md) | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) §5 |

**子文件**：[README.md](README.md)

---

## 3. 角色

| 字段 | 值 |
| --- | --- |
| is_single_source_of_truth | true（系统层实体与叙事 SSOT） |
| upstream | `company/knowledge/`（公司级 BD/CAP/PL/SYS/MDG/TPL 首次定义） |
| downstream | `application/knowledge/`（API/TBL/MW/CMP 及实现映射） |

---

## 4. 索引

| 类型 | 路径 |
| --- | --- |
| system_index | [../INDEX_GUIDE.md](../INDEX_GUIDE.md) |
| per_perspective_readmes | business/README.md, product/README.md, application/README.md, data/README.md, technical/README.md |
| governance | [../../agent/knowledge/knowledge-governance.md](../../agent/knowledge/knowledge-governance.md) |
| entity_index | [KNOWLEDGE_INDEX.md](KNOWLEDGE_INDEX.md) |
| design | [../DESIGN.md](../DESIGN.md) |

---

## 5. 系统层 BD 落盘例外

与 `company/`、`application/` 区分；实现 SSOT 见 [../DESIGN.md](../DESIGN.md) §系统层 BD 落盘。

| 层级 | 路径 | 说明 |
| --- | --- | --- |
| company | `company/knowledge/business/BD-{NAME}/BD-{NAME}.md` | 公司 SSOT |
| system | `knowledge/business/BD-{NAME}.md` | 视角根单文件 reference（`definition_scope: reference`，`layer_scope: system`；上游 SSOT 见 # SSOT 段） |
| system | `knowledge/business/BSD-{NAME}/` | BSD→BC→AGG→AB 域扁平树 SSOT |
| application | `application/knowledge/business/BSD-{NAME}/BD-*.md` | 应用 reference |

`okf_lib.entity_relpath(bundle="system", BD)` → `knowledge/business/{full_id}.md`

---

## 6. 关联文档

| 路径 | 说明 |
| --- | --- |
| [README.md](README.md) | 五视角架构入口 |
| [../INDEX_GUIDE.md](../INDEX_GUIDE.md) | system 索引 |
| [../../INDEX_GUIDE.md](../../INDEX_GUIDE.md) | 仓库根索引 |
| [../DESIGN.md](../DESIGN.md) | 系统库设计契约 |
| [../../company/knowledge/knowledge-meta.md](../../company/knowledge/knowledge-meta.md) | 公司级知识树元数据 |
| [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md) | 命名 SSOT |

---

## 7. docs-build meta_read_order

| 顺序 | 路径 |
| --- | --- |
| 1 | docs_meta.md |
| 2 | knowledge/knowledge-meta.md |
| 3 | knowledge/business/business-meta.md |
| 4 | knowledge/product/product-meta.md |
| 5 | knowledge/application/application-meta.md |
| 6 | knowledge/data/data-meta.md |
| 7 | knowledge/technical/technical-meta.md |
| 8 | changelogs/README.md |
| 9 | ../agent/knowledge/knowledge-governance.md |
