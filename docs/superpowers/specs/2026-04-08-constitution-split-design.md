# constitution 拆分：应用知识库规范 vs 系统知识库规范

**日期**：2026-04-08  
**状态**：已实施（2026-04-08）  
**决议**：物理落点采用 **方案 A** — 在 `application/` 根下建立 `**application/constitution/`**（与 `knowledge/`、`solutions/` 等平级）；原 `**application/knowledge/constitution/**` 不再作为 SSOT 目录（迁移后删除或仅保留短期重定向说明）。

---

## 1. 背景与目标

- 当前 **宪法与治理层**（术语表、命名规范、原则、ADR 模板）集中在 `application/knowledge/constitution/`，与四视角并列，语义上混合了：
  - **应用知识库 SSOT** 规则（实体 ID、四视角、阶段文档共用命名）；
  - 与 **组织级 `system/`**（槽位、`architecture/`）相关的叙述散见于个别文档（如 `naming-conventions.md` 中的应用模板路径说明）。
- **目标**：
  1. **应用知识库规范**：整体迁至 `**application/constitution/`**，作为中央库「应用侧」治理与术语/ADR 的单一入口（与 `application/knowledge/` 四视角 **并列、非从属**）。
  2. **系统知识库规范**：在 `**system/constitution/`** 建立组织级规范入口（槽位命名、与 `application/` 的边界、可选术语对照），与 `system/architecture/`、`system/application-{name}/` 叙事一致。

---

## 2. 三种实施策略（对比）


| 策略              | 做法                                                                             | 优点         | 缺点               |
| --------------- | ------------------------------------------------------------------------------ | ---------- | ---------------- |
| **Ⅰ 整目录迁移（推荐）** | `application/knowledge/constitution` → `application/constitution`；更新元数据与全库相对链接 | 路径清晰、无重复正文 | 一次性链接改动面大，需跑断链检查 |
| **Ⅱ 复制 + 废弃**   | 新目录完整复制，旧路径只保留 README「已迁移」                                                     | 外部旧链接短期仍可达 | 双份维护窗口、易不一致      |
| **Ⅲ 仅抽象「系统规范」** | 应用侧不动，只在 `system/constitution` 新增；应用侧逐步摘句                                      | 改动最小       | 与已选 **A** 冲突，不推荐 |


**推荐**：**策略 Ⅰ**，配合 `knowledge/README.md` 与 `knowledge_meta.yaml` 中 **删除 `constitution` 子目录**、改为 **显式指向 `../constitution/`** 的导航与索引字段。

---

## 3. 目录与内容归属

### 3.1 `application/constitution/`（应用知识库规范）

**迁移对象（原 `knowledge/constitution/` 下全部）**：

- `README.md`、`constitution_meta.yaml`、`GLOSSARY.md`
- `principles/`（含 `architecture-principles.yaml`、`principles_meta.yaml`）
- `standards/`（含 `naming-conventions.md`、`standards_meta.yaml`）
- `adr/`（含 `adr-template.md`、`adr_meta.yaml`）

**元数据 ID**：`constitution_meta.yaml` 中 `id: DIR-KNOWLEDGE-CONSTITUTION` 等建议改为 `**DIR-APPLICATION-CONSTITUTION`**（或保留 ID、在 `description` 中声明路径变更），**禁止**在未同步下游引用时批量改 YAML 内被引用的历史 ID（若有）。

**与 `knowledge/` 关系**：

- `application/knowledge/` **仅保留四视角**（business / product / technical / data）。
- `knowledge_meta.yaml`：
  - `child_directories` **去掉** `constitution`；
  - `role.perspectives` 中是否保留 `constitution`：**建议保留为逻辑视角**，但注明物理路径为 `**../constitution`**（或改为 `integration.sibling: application/constitution` 等新字段 —— 实现时与 `docs-build` / `KNOWLEDGE_INDEX` 约定对齐）。

### 3.2 `system/constitution/`（系统知识库规范）

**新建（最小可用）**：

- `README.md`：说明本目录约束 **组织级系统知识库**（仓库顶层 `system/`： `architecture/`、`application-{name}/` 槽位），与 `**application/` 应用 SSOT** 的职责边界（引用 `application/constitution/` 与 `application/DESIGN.md`）。
- `constitution_meta.yaml`（或 `system_constitution_meta.yaml`）：`id` 建议 `**DIR-SYSTEM-CONSTITUTION`**，`role.kind` 与 `application/constitution` 区分。
- 可选：`GLOSSARY.md` 片段或「术语对照」表 —— **不复制**应用侧全文，仅列系统侧特有术语（如「槽位」「镜像」「组织级 architecture」）。

**不放这里**：四视角实体命名、IDEA-ID 规则 —— **仍以 `application/constitution/standards/` 为 SSOT**，`system/constitution` 只作边界与引用。

---

## 4. 全库需同步修改的引用面（非穷举）

- `application/DESIGN.md`：`knowledge/constitution/...` → `constitution/...`（相对 `application/` 根）。
- `application/docs_meta.yaml`：`naming_conventions.reference` 等路径。
- `application/knowledge/README.md`：子目录表删除 constitution 行，改为「宪法层见 [../constitution](../constitution)」。
- `application/solutions/`、`application/analysis/`、`application/requirements/` 各 README / `*_meta.yaml` 中指向 `../knowledge/constitution/...` 的链接。
- 根 `INDEX_GUIDE.md`、`application/INDEX_GUIDE.md` §3 中「宪法层」路径（若存在）。
- `.agent/skills/docs-build` 等若硬编码 `knowledge/constitution`，需按 Skill 约定更新。

---

## 5. 联邦与应用模板路径

- `naming-conventions.md` 中 `**applications/app-APPNAME/knowledge/constitution/`** 等旧路径：改为 **「联邦单元内与中央库同构：根级 `constitution/` 与 `knowledge/` 并列」**（或指向 `application/constitution` 相对联邦根的具体约定），避免与已删除模板矛盾。
- `docs-init` 落盘目标工程时：若仍复制 `application/` 全树，将自然带上 `**application/constitution/`**；§2.1 子集是否包含 `constitution/`：**建议包含**（与 `knowledge/` 同属核心治理文件）— 在 **单独 ADR 或本设计评审结论** 中写死清单。

---

## 6. 验收标准

- 仓库内无孤立目录 `application/knowledge/constitution/`
- `rg 'knowledge/constitution'` 无业务引用（允许 changelogs 历史记录提及）。
- `application/knowledge/knowledge_meta.yaml` 与四视角 README 一致。
- `system/constitution/README.md` 可被 `system/README.md` 索引。
- `validate-guide.sh`（若适用）与人工点检根 INDEX 链接。

---

## 7. 风险与回滚

- **风险**：外部文档/旧 PR 仍引用 `.../knowledge/constitution/...` —— 可在 `application/knowledge/constitution/README.md` 保留 **单文件重定向** 一版，90 天后删除（可选）。
- **回滚**：Git  revert 单次迁移提交；恢复 `knowledge_meta.yaml` 中的 `child_directories: constitution`。

---

## 8. 自审

- 与知识库 v2（`application` SSOT、`system/` 槽位）一致。
- 不默认修改 `application/knowledge/**/*_knowledge.json` 内实体 **ID**。

---

## 9. 后续步骤（实施阶段）

1. 评审本设计并确认 §2.1 子集是否纳入 `constitution/`。
2. `git mv` + 批量替换链接 + 更新 `docs_meta.yaml` / `knowledge_meta.yaml`。
3. 新建 `system/constitution/` 最小文件集。
4. 跑断链与 `validate-guide.sh`；按需 `/docs-indexing` 或手工更新 INDEX 字典。

