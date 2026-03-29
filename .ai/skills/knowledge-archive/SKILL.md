---
name: knowledge-archive
description: >
  知识归档与上行同步：① 汇总并归档 applications/ 或 application/ 下各应用知识库文件的更新记录；
  ② 将应用侧经核实的有效信息，按系统知识库格式（system/knowledge、CONTRIBUTING、INDEX）补充进系统级各视角文件。
  使用 /knowledge-archive。
---

# 知识归档与系统库同步（knowledge-archive）

本 Skill 做两件事：**（一）应用知识库变更归档**；**（二）应用有效信息上行补充系统知识库**。二者可同一次执行，也可分步。

## 适用前提

- **应用侧约定**：以 [applications/README.md](../../../applications/README.md)、[applications/INDEX.md](../../../applications/INDEX.md) 为准——联邦单元、`manifest.yaml`、全局唯一 ID（`APP-*`、`MS-*`、`ENT-*` 等）。
- **系统侧约定**：以 [system/knowledge/README.md](../../../system/knowledge/README.md)、[system/CONTRIBUTING.md](../../../system/CONTRIBUTING.md)、[system/DESIGN.md](../../../system/DESIGN.md)、[system/INDEX.md](../../../system/INDEX.md) 为准——四视角 YAML/_meta、跨视角仅 ID 引用、单一事实源（SSOT）。

## 联邦原则（必须遵守）

| 层级 | 适合放什么 | 不适合 |
|------|------------|--------|
| **应用知识库** | 接口细节、本仓 Schema、部署参数、manifest、应用内四视角实例 | 把全系统业务域再在应用里当唯一权威重复定义 |
| **系统知识库** | 跨应用映射、系统边界、应用注册（`technical/{SYS}/{APP}.yaml`）、聚合与实体 ID 契约、产品/API 关联字段 | 大段复制应用内 OpenAPI 全文（应保留 `docs_manifest_path` 与 ID 引用） |

上行时：**提炼有效信息**（新服务 ID、新 API 契约摘要、归属 `app_id`、与 product/business 的 ID 链接），改写为 **系统文件要求的字段与结构**，禁止破坏已有 ID 与引用链。

---

## （一）归档：所有应用知识库文件的更新

**目标**：形成可追溯的「本轮/本批」应用知识变更记录，便于审计与后续同步系统库。

### 1. 范围

- 主库内：`applications/*/`（联邦模式）下各应用（排除仅模板说明用的空壳目录时以用户指定为准），或 `application/`（独立模式） 下应用文档。
- 外仓：用户给出路径列表或 **应用知识库根目录**（模板目录名可仍为 `app-APPNAME/`）时，仅处理用户声明的 **应用知识根**（与 `INDEX_GUIDE.md` / `INDEX.md`、`knowledge/` 同级树）。

### 2. 发现变更的方式（择一或组合）

- **Git**：自上次归档标签/提交或用户给定区间，对 `applications/**`（或各应用知识路径）做 `git diff` / 文件列表统计。
- **清单驱动**：用户粘贴「已修改文件路径」列表。
- **全量快照**：无基线时，记录当前各应用 `INDEX_GUIDE.md` / `INDEX.md`、`knowledge/` 下主要文件清单与哈希或行数摘要（轻量索引，非通读）。

### 3. 归档产物（建议）

| 产物 | 路径建议 | 内容 |
|------|----------|------|
| **批次归档** | `changelogs/upstream-from-applications/ARCHIVE-{YYYYMMDD}-{批次简述}.md`（目录不存在则创建） | 按应用分节：变更文件路径、变更类型（新增/修改/删除）、一句话摘要、可选提交号 |
| **应用内留痕** | `applications/<app>/CHANGELOG.md` 或 `applications/<app>/archive/promotion-notes.md` | 追加本节同步摘要，与应用 README 中联邦说明一致 |

**归档文档必备字段示例**：

```markdown
## 应用 your-app（APP-XXX）
| 路径 | 动作 | 摘要 |
|------|------|------|
| knowledge/technical/... | 修改 | 新增 MS-YYY 接口登记 |
```

---

## （二）上行：应用有效信息 → 系统知识库

**目标**：依据应用侧已核实内容，**补充、完善** `system/knowledge/` 下对应文件，不违背 CONTRIBUTING 与 DESIGN。

### 1. 输入

- （一）的归档清单或用户指定的应用文件列表。
- 应用 **`manifest.yaml`**、**`application/knowledge/knowledge_meta.yaml`** 等各 `{scope}_meta.yaml`（若存在）、各视角下 **YAML/Markdown** 中与系统相关的 ID 与关系。

### 2. 映射指引（按 CONTRIBUTING）

| 应用侧信息 | 系统侧落点 |
|------------|------------|
| 应用身份、仓库、manifest 路径 | `knowledge/technical/{SYS}/{APP-ID}.yaml`：`repo_url`、`docs_manifest_path`、`service_ids` |
| 新 **MS-***（入口簇）、API 清单（摘要级） | 更新 `{APP-ID}.yaml` 的 `service_ids`；**MS-*** 须与 **knowledge-extract §8.1.2** 一致（**仅** apis 宿主聚类，**非** Maven 模块名）；API 细节以 manifest 为 SSOT |
| 限界上下文由本应用实现 | `knowledge/business/business_meta.yaml` → `layers` 中 `key: bc` 的 `fields.implemented_by_app_id` |
| 数据实体归属应用 | `knowledge/data/data_meta.yaml` → `layers`（`key: ds` / `key: ent`）中 `owned_by_app_id` / `app_id` 等约定；与聚合的 `maps_to_aggregate_id` / `persisted_as_entity_ids` |
| 产品功能调用本应用 API | `knowledge/product/product_meta.yaml` → `layers`（`key: ft`）的 `invokes_api_ids` |
| 跨域架构决策 | 必要时新增 `knowledge/constitution/adr/ADR-*.md` |

### 3. 撰写规则

- **先读再写**：打开拟修改的系统文件与相邻元数据 YAML（各视角 `*_meta.yaml` 等），确认现有 ID。
- **只增不改 ID**：已有实体 **禁止改 id**；新增实体 ID 须全局唯一且符合 [system/knowledge/constitution/standards/NAMING-CONVENTIONS.md](../../../system/knowledge/constitution/standards/NAMING-CONVENTIONS.md)（若存在）。
- **交叉引用仅 ID**：正文与 YAML 关联字段只写 ID，不写重复长描述。
- **更新索引**：变更影响全局导航时，同步 [system/INDEX.md](../../../system/INDEX.md) 或对应视角 `README.md`（见 system/knowledge/README.md §4）。

### 4. 质量自检（与 knowledge-build 第四阶段对齐）

- 新增/修改的 YAML 可被解析；无断链 ID。
- 应用独有细节仍保留在应用库；系统库无大段与 manifest 重复的冗余正文。
- 若某条信息应用侧与系统侧冲突，**以代码与 manifest 为准**或标为待人工确认，不强行覆盖系统权威域定义。

---

## 执行顺序建议

1. 与用户确认：**仅归档** / **仅上行** / **归档 + 上行**。
2. 确认应用列表与（可选）Git 基线。
3. 执行（一），落盘归档文件。
4. 执行（二），按映射表改系统库，最后跑自检。
5. Git 提交信息建议：`docs: 应用知识归档与系统库同步（<应用名>）` 或拆分两笔提交。

---

## 参考

- [applications/README.md](../../../applications/README.md)、[applications/INDEX.md](../../../applications/INDEX.md)
- [system/knowledge/README.md](../../../system/knowledge/README.md)、[system/CONTRIBUTING.md](../../../system/CONTRIBUTING.md)、[system/DESIGN.md](../../../system/DESIGN.md)、[system/INDEX.md](../../../system/INDEX.md)
- 应用内增量维护：视项目而定（可配合 `knowledge-extract` 等）
- 系统库从零构建：[.ai/skills/knowledge-build/SKILL.md](../knowledge-build/SKILL.md)（编排说明，组合 document-indexing / agent-guide / knowledge-extract 等）
